from pathlib import Path

library_path = Path('Library.lua')
theme_path = Path('addons/ThemeManager.lua')
menu_path = Path('addons/MenuManager.lua')

library = library_path.read_text()
theme = theme_path.read_text()
menu = menu_path.read_text()

# 1) Shared unified fade driver: one progress value updates all renderable transparency properties together.
if 'function Library:SetUnifiedFadeProgress' not in library:
    marker = 'function Library:ResetMenuPositions(Animated)\n'
    if marker not in library:
        raise SystemExit('ResetMenuPositions marker missing')
    unified = r'''Library.UnifiedFadeControllers = setmetatable({}, { __mode = 'k' });

local function GetUnifiedFadeController(Root)
    local Controller = Library.UnifiedFadeControllers[Root];
    if Controller then
        return Controller;
    end

    local Driver = Instance.new('NumberValue');
    Driver.Name = 'FormaUnifiedFadeDriver';
    Driver.Value = 1;
    Driver.Parent = Root;

    Controller = {
        Driver = Driver;
        Progress = 1;
        Entries = {};
        Tween = nil;
    };
    Library.UnifiedFadeControllers[Root] = Controller;

    Driver:GetPropertyChangedSignal('Value'):Connect(function()
        local Progress = math.clamp(Driver.Value, 0, 1);
        Controller.Progress = Progress;

        for _, Entry in ipairs(Controller.Entries) do
            local Instance = Entry.Instance;
            if Instance and Instance.Parent then
                for Property, Baseline in next, Entry.Baseline do
                    pcall(function()
                        Instance[Property] = 1 + ((Baseline - 1) * Progress);
                    end);
                end
            end
        end
    end);

    return Controller;
end

local function RefreshUnifiedFadeEntries(Root, Controller)
    Library:PrimeFadeTree(Root);
    table.clear(Controller.Entries);

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        if Descendant ~= Controller.Driver then
            table.insert(Instances, Descendant);
        end
    end

    for _, Instance in ipairs(Instances) do
        local Baseline = Library.FadeBaselines[Instance];
        if Baseline then
            table.insert(Controller.Entries, {
                Instance = Instance;
                Baseline = Baseline;
            });
        end
    end
end

function Library:SetUnifiedFadeProgress(Root, Progress)
    if not Root then
        return;
    end

    local Controller = GetUnifiedFadeController(Root);
    if Controller.Tween then
        pcall(function() Controller.Tween:Cancel(); end);
        Controller.Tween = nil;
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    Controller.Progress = math.clamp(tonumber(Progress) or 0, 0, 1);
    Controller.Driver.Value = Controller.Progress;
end

function Library:TweenUnifiedFade(Root, Target, Duration, Completed)
    if not Root then
        return nil;
    end

    local Controller = GetUnifiedFadeController(Root);
    if Controller.Tween then
        pcall(function() Controller.Tween:Cancel(); end);
        Controller.Tween = nil;
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    local TargetProgress = math.clamp(tonumber(Target) or 0, 0, 1);
    local Tween = TweenService:Create(
        Controller.Driver,
        Library:GetMenuTweenInfo(Duration),
        { Value = TargetProgress }
    );

    Controller.Tween = Tween;
    Tween:Play();
    Tween.Completed:Connect(function(State)
        if Controller.Tween == Tween then
            Controller.Tween = nil;
            Controller.Progress = TargetProgress;
            Controller.Driver.Value = TargetProgress;
        end
        if Completed then
            Completed(State);
        end
    end);

    return Tween;
end

'''
    library = library.replace(marker, unified + marker, 1)

# 2) Crisp accent outline helper, independent from the retained soft glow.
if 'function Library:AddAccentOutline' not in library:
    marker = 'function Library:AddTopCorners(Instance, Radius)\n'
    if marker not in library:
        raise SystemExit('AddTopCorners marker missing')
    outline = r'''function Library:AddAccentOutline(Instance, Scale)
    if not Instance then
        return nil;
    end;

    Scale = math.max(tonumber(Scale) or 1, 0.25);
    local Stroke = Instance:FindFirstChild('FormaAccentOutline');
    if not Stroke then
        Stroke = Library:Create('UIStroke', {
            Name = 'FormaAccentOutline';
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Round;
            Thickness = 1.05 * Scale;
            Transparency = 0.04;
            Parent = Instance;
        });
        Library:AddToRegistry(Stroke, { Color = 'AccentColor'; });
    else
        Stroke.Thickness = 1.05 * Scale;
        Stroke.Transparency = 0.04;
    end
    return Stroke;
end;

'''
    library = library.replace(marker, outline + marker, 1)

# 3) Smooth dragging without restarting a tween every rendered frame.
start = library.index('function Library:MakeDraggable(Instance, Cutoff)')
end = library.index('function Library:AddToolTip(Info, HoverInstance)', start)
new_drag = r'''function Library:MakeDraggable(Instance, Cutoff)
    if not Instance then
        return nil;
    end

    local Existing = Library.DraggableStates[Instance];
    if Existing then
        return Existing;
    end

    Instance.Active = true;
    local State = {
        InitialPosition = Instance.Position;
        Dragging = false;
        TargetPosition = Instance.Position;
    };
    Library.DraggableStates[Instance] = State;

    local function CancelPositionTween()
        local InstanceTweens = Library.PropertyTweens[Instance];
        local PositionTween = InstanceTweens and InstanceTweens.Position;
        if PositionTween then
            pcall(function() PositionTween:Cancel(); end);
            InstanceTweens.Position = nil;
        end
    end

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return;
        end

        local ObjPos = Vector2.new(
            Mouse.X - Instance.AbsolutePosition.X,
            Mouse.Y - Instance.AbsolutePosition.Y
        );

        if ObjPos.Y > (Cutoff or 40) then
            return;
        end

        CancelPositionTween();
        State.Dragging = true;

        local Anchor = Instance.AnchorPoint;
        local Visual = Vector2.new(
            Instance.AbsolutePosition.X + (Instance.AbsoluteSize.X * Anchor.X),
            Instance.AbsolutePosition.Y + (Instance.AbsoluteSize.Y * Anchor.Y)
        );
        local Target = Visual;

        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Instance.Parent do
            Target = Vector2.new(
                Mouse.X - ObjPos.X + (Instance.AbsoluteSize.X * Anchor.X),
                Mouse.Y - ObjPos.Y + (Instance.AbsoluteSize.Y * Anchor.Y)
            );

            local Delta = RenderStepped:Wait();
            local Manager = Library.MenuManager;
            local SmoothTime = 0.075;
            if Manager and Manager.GetDragSmoothTime then
                SmoothTime = Manager:GetDragSmoothTime();
            end

            local Alpha = 1 - math.exp(-math.min(Delta, 0.05) / math.max(SmoothTime, 0.001));
            Visual = Visual:Lerp(Target, Alpha);
            Instance.Position = UDim2.fromOffset(Visual.X, Visual.Y);
        end

        State.Dragging = false;
        State.TargetPosition = UDim2.fromOffset(Target.X, Target.Y);

        if Instance.Parent then
            local Manager = Library.MenuManager;
            local ReleaseDuration = 0.14;
            if Manager and Manager.GetReleaseDuration then
                ReleaseDuration = Manager:GetReleaseDuration();
            end
            Library:TweenMenuProperty(Instance, 'Position', State.TargetPosition, ReleaseDuration);
        end
    end);

    return State;
end;

'''
library = library[:start] + new_drag + library[end:]

# 4) Restore crisp outline on requested HUD/window surfaces while retaining glow.
replacements = {
    "    Library:AddAccentGlow(KeybindInner, 0.9);\n": "    Library:AddAccentGlow(KeybindInner, 0.9);\n    Library:AddAccentOutline(KeybindInner, 1);\n",
    "    Library:AddAccentGlow(Inner, 0.95);\n": "    Library:AddAccentGlow(Inner, 0.95);\n    Library:AddAccentOutline(Inner, 1);\n",
    "    Library:AddAccentGlow(Inner, 1);\n\n    local WindowLabel": "    Library:AddAccentGlow(Inner, 1);\n    Library:AddAccentOutline(Inner, 1);\n\n    local WindowLabel",
}
for old, new in replacements.items():
    if old not in library:
        raise SystemExit(f'outline call-site missing: {old[:60]!r}')
    library = library.replace(old, new, 1)

# 5) Main tab contents use one shared fade progress rather than independent property tweens.
old = '''        local function SetTabVisualGroups(Target, Duration, Stagger)\n            local Hidden = Target >= 0.5;\n\n            if not Duration or Duration <= 0 then\n                Library:SetFadeTree(TabFrame, Hidden);\n            else\n                Library:TweenFadeTree(TabFrame, Hidden, Duration);\n            end;\n        end;\n'''
new = '''        local function SetTabVisualGroups(Target, Duration, Stagger)\n            local Hidden = Target >= 0.5;\n            local Progress = Hidden and 0 or 1;\n\n            if not Duration or Duration <= 0 then\n                Library:SetUnifiedFadeProgress(TabFrame, Progress);\n            else\n                Library:TweenUnifiedFade(TabFrame, Progress, Duration);\n            end;\n        end;\n'''
if old not in library:
    raise SystemExit('main tab visual group block missing')
library = library.replace(old, new, 1)
library = library.replace('SetTabVisualGroups(0, 0.38, 0.018);', 'SetTabVisualGroups(0, 0.42, 0);', 1)
library = library.replace("Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, 0), 0.42);", "Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, 0), 0.44);", 1)
library = library.replace('SetTabVisualGroups(1, 0.30, 0);', 'SetTabVisualGroups(1, 0.34, 0);', 1)
library = library.replace("Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, -5), 0.32);", "Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, -5), 0.34);", 1)
library = library.replace('task.delay(0.32, function()', 'task.delay(0.34, function()', 1)

# 6) Tabbox contents also fade as a single synchronized tree.
old_show = "                    Library:SetFadeTree(Container, true);\n                    Library:TweenFadeTree(Container, false, 0.22);"
new_show = "                    Library:SetUnifiedFadeProgress(Container, 0);\n                    Library:TweenUnifiedFade(Container, 1, 0.30);"
if old_show not in library:
    raise SystemExit('tabbox show fade block missing')
library = library.replace(old_show, new_show, 1)
old_hide = "                    Library:TweenFadeTree(Container, true, 0.16);\n                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 17), 0.16);\n\n                    task.delay(0.16, function()"
new_hide = "                    Library:TweenUnifiedFade(Container, 0, 0.24);\n                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 17), 0.24);\n\n                    task.delay(0.24, function()"
if old_hide not in library:
    raise SystemExit('tabbox hide fade block missing')
library = library.replace(old_hide, new_hide, 1)

# 7) Menu open/close: remove UIScale/text resizing and use a single shared fade driver.
library = library.replace("    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end", "    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.32 end", 1)
old_header = '''    local Toggled = false;\n    local Fading = false;\n    local ToggleAnimationId = 0;\n    local MenuScale = Library:Create('UIScale', {\n        Name = 'FormaMenuScale';\n        Scale = 1;\n        Parent = Outer;\n    });\n'''
new_header = '''    local Toggled = false;\n    local ToggleAnimationId = 0;\n    local CursorAnimationId = 0;\n'''
if old_header not in library:
    raise SystemExit('menu toggle header missing')
library = library.replace(old_header, new_header, 1)

# Cursor sessions cannot fight during rapid toggle reversals.
library = library.replace("    local function StartFormaCursor()\n        task.spawn(function()", "    local function StartFormaCursor()\n        CursorAnimationId = CursorAnimationId + 1;\n        local CurrentCursorId = CursorAnimationId;\n        task.spawn(function()", 1)
library = library.replace("                while Toggled and ScreenGui.Parent do", "                while Toggled and CurrentCursorId == CursorAnimationId and ScreenGui.Parent do", 1)
library = library.replace("            InputService.MouseIconEnabled = State;\n        end);\n    end;", "            if CurrentCursorId == CursorAnimationId then\n                InputService.MouseIconEnabled = State;\n            end\n        end);\n    end;", 1)

start = library.index('    function Library:Toggle()')
end = library.index('    Library:GiveSignal(InputService.InputBegan:Connect', start)
new_toggle = r'''    function Library:Toggle()
        Toggled = not Toggled;
        ToggleAnimationId = ToggleAnimationId + 1;
        local CurrentId = ToggleAnimationId;
        ModalElement.Modal = Toggled;

        local Manager = Library.MenuManager;
        local FadeTime = Manager and Manager.TweenSpeed or Config.MenuFadeTime;
        FadeTime = math.clamp(math.max(tonumber(FadeTime) or 0.32, 0.26), 0.26, 1.5);

        if Toggled then
            if not Outer.Visible then
                Library:SetUnifiedFadeProgress(Outer, 0);
                Outer.Visible = true;
            end

            Library:TweenUnifiedFade(Outer, 1, FadeTime);
            StartFormaCursor();
        else
            CursorAnimationId = CursorAnimationId + 1;
            Library:TweenUnifiedFade(Outer, 0, FadeTime, function(State)
                if CurrentId ~= ToggleAnimationId or Toggled or State == Enum.PlaybackState.Cancelled then
                    return;
                end
                Outer.Visible = false;
            end);
        end
    end

'''
library = library[:start] + new_toggle + library[end:]

# 8) MenuManager: slower defaults, duration floor, smooth drag response, smooth release.
menu = menu.replace("\tMenuManager.TweenSpeed = 0.24", "\tMenuManager.TweenSpeed = 0.32", 1)
old_getinfo = '''\tfunction MenuManager:GetTweenInfo(Duration)\n\t\treturn TweenInfo.new(\n\t\t\tmath.max(tonumber(Duration) or self.TweenSpeed or 0.24, 0.01),\n\t\t\tself:GetEasingStyle(),\n\t\t\tself:GetEasingDirection()\n\t\t)\n\tend\n'''
new_getinfo = '''\tfunction MenuManager:GetTweenInfo(Duration)\n\t\tlocal BaseSpeed = math.clamp(tonumber(self.TweenSpeed) or 0.32, 0.12, 1.25)\n\t\tlocal Requested = tonumber(Duration)\n\t\tlocal Minimum = math.max(BaseSpeed * 0.62, 0.10)\n\t\tlocal Effective = Requested and math.max(Requested, Minimum) or BaseSpeed\n\n\t\treturn TweenInfo.new(\n\t\t\tmath.clamp(Effective, 0.10, 1.5),\n\t\t\tself:GetEasingStyle(),\n\t\t\tself:GetEasingDirection()\n\t\t)\n\tend\n\n\tfunction MenuManager:GetDragSmoothTime()\n\t\treturn math.clamp((tonumber(self.TweenSpeed) or 0.32) * 0.28, 0.055, 0.18)\n\tend\n\n\tfunction MenuManager:GetReleaseDuration()\n\t\treturn math.clamp((tonumber(self.TweenSpeed) or 0.32) * 0.58, 0.10, 0.34)\n\tend\n'''
if old_getinfo not in menu:
    raise SystemExit('MenuManager GetTweenInfo block missing')
menu = menu.replace(old_getinfo, new_getinfo, 1)
menu = menu.replace("\t\tself.TweenSpeed = math.clamp(tonumber(Value) or 0.24, 0.05, 1)", "\t\tself.TweenSpeed = math.clamp(tonumber(Value) or 0.32, 0.12, 1.25)", 1)
menu = menu.replace("\t\t\tMin = 0.05;\n\t\t\tMax = 1;", "\t\t\tMin = 0.12;\n\t\t\tMax = 1.25;", 1)

# 9) ThemeManager no longer embeds MenuManager controls in Themes. ApplyToTab creates a sibling groupbox.
embedded = '''\t\tlocal menuManager = self:EnsureMenuManager()\n\t\tif menuManager and menuManager.CreateMenuManager and not Options.MenuManager_EasingStyle then\n\t\t\tgroupbox:AddDivider()\n\t\t\tgroupbox:AddLabel('Menu manager')\n\t\t\tmenuManager:CreateMenuManager(groupbox)\n\t\tend\n\n'''
if embedded not in theme:
    raise SystemExit('embedded MenuManager controls block missing')
theme = theme.replace(embedded, '', 1)
old_apply = '''\tfunction ThemeManager:ApplyToTab(tab)\n\t\tassert(self.Library, 'Must set ThemeManager.Library first!')\n\t\tlocal groupbox = self:CreateGroupBox(tab)\n\t\tself:CreateThemeManager(groupbox)\n\tend\n'''
new_apply = '''\tfunction ThemeManager:ApplyToTab(tab)\n\t\tassert(self.Library, 'Must set ThemeManager.Library first!')\n\t\tlocal groupbox = self:CreateGroupBox(tab)\n\t\tself:CreateThemeManager(groupbox)\n\n\t\tlocal menuManager = self:EnsureMenuManager()\n\t\tif menuManager and menuManager.BuildMenuSection and not Options.MenuManager_EasingStyle then\n\t\t\tmenuManager:BuildMenuSection(tab)\n\t\tend\n\tend\n'''
if old_apply not in theme:
    raise SystemExit('ThemeManager ApplyToTab block missing')
theme = theme.replace(old_apply, new_apply, 1)

library_path.write_text(library)
theme_path.write_text(theme)
menu_path.write_text(menu)
