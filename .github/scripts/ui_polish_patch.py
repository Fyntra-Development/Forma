from pathlib import Path
import re

library_path = Path('Library.lua')
theme_path = Path('addons/ThemeManager.lua')
library = library_path.read_text()
theme = theme_path.read_text()


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 exact match, got {count}')
    return text.replace(old, new, 1)


def regex_once(text, pattern, repl, label, flags=re.S):
    new_text, count = re.subn(pattern, repl, text, count=1, flags=flags)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 regex match, got {count}')
    return new_text

# ThemeManager: Marin placement and literal text-size slider.
theme = replace_once(
    theme,
    "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.64);",
    "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.83);",
    'Marin anchor',
)

theme = replace_once(
    theme,
    """\t\tgroupbox:AddSlider('ThemeManager_TextSize', {\n\t\t\tText = 'Text size';\n\t\t\tDefault = 100;\n\t\t\tMin = 75;\n\t\t\tMax = 150;\n\t\t\tRounding = 0;\n\t\t\tStep = 5;\n\t\t\tSuffix = '%';\n\t\t})\n\t\tOptions.ThemeManager_TextSize:OnChanged(function()\n\t\t\tself.Library:SetTextScale(Options.ThemeManager_TextSize.Value / 100)\n\t\tend)""",
    """\t\tgroupbox:AddSlider('ThemeManager_TextSize', {\n\t\t\tText = 'Text size';\n\t\t\tDefault = 14;\n\t\t\tMin = 9;\n\t\t\tMax = 24;\n\t\t\tRounding = 0;\n\t\t\tStep = 1;\n\t\t})\n\t\tOptions.ThemeManager_TextSize:OnChanged(function()\n\t\t\tself.Library:SetTextSize(Options.ThemeManager_TextSize.Value)\n\t\tend)""",
    'ThemeManager literal text size',
)

# Literal base text size while preserving the existing relative hierarchy.
library = replace_once(
    library,
    "    TextScale = 1;\n",
    "    TextScale = 1;\n    TextSize = 14;\n",
    'Library TextSize field',
)

library = regex_once(
    library,
    r"function Library:GetScaledTextSize\(BaseSize\).*?function Library:SetTextScale\(Scale\).*?end;\n\nLibrary:LoadFont\('Rubik Light'\);",
    """function Library:GetScaledTextSize(BaseSize)\n    BaseSize = tonumber(BaseSize) or 14;\n    local Scale = (Library.TextSize or 14) / 14;\n    return math.max(6, math.floor((BaseSize * Scale) + 0.5));\nend;\n\nfunction Library:SetTextSize(Size)\n    Size = math.clamp(math.floor((tonumber(Size) or 14) + 0.5), 9, 24);\n    Library.TextSize = Size;\n    Library.TextScale = Size / 14;\n\n    for Instance, BaseSize in next, Library.BaseTextSizes do\n        if Instance and Instance.Parent then\n            pcall(function()\n                Instance.TextSize = Library:GetScaledTextSize(BaseSize);\n            end);\n        end;\n    end;\n\n    return Size;\nend;\n\nfunction Library:SetTextScale(Scale)\n    return Library:SetTextSize(14 * math.clamp(tonumber(Scale) or 1, 0.65, 1.75));\nend;\n\nLibrary:LoadFont('Rubik Light');""",
    'Literal text size API',
)

# Reusable tight, blended accent glow.
glow_helper = r"""
function Library:AddAccentGlow(Instance, Scale)
    if not Instance then
        return;
    end;

    Scale = tonumber(Scale) or 1;
    local Layers = {
        { 0.72, 0.42 },
        { 0.98, 0.54 },
        { 1.24, 0.66 },
        { 1.52, 0.76 },
        { 1.82, 0.84 },
        { 2.12, 0.90 },
        { 2.42, 0.95 },
    };

    for Index, Info in ipairs(Layers) do
        local Name = 'FormaAccentGlow' .. Index;
        local Stroke = Instance:FindFirstChild(Name);

        if not Stroke then
            Stroke = Library:Create('UIStroke', {
                Name = Name;
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = Library.AccentColor;
                LineJoinMode = Enum.LineJoinMode.Round;
                Thickness = Info[1] * Scale;
                Transparency = Info[2];
                Parent = Instance;
            });

            Library:AddToRegistry(Stroke, {
                Color = 'AccentColor';
            });
        else
            Stroke.Thickness = Info[1] * Scale;
            Stroke.Transparency = Info[2];
        end;
    end;
end;

"""
library = replace_once(
    library,
    "function Library:AddTopCorners(Instance, Radius)\n",
    glow_helper + "function Library:AddTopCorners(Instance, Radius)\n",
    'Accent glow helper',
)

# Replace the staged/tweened indicator with independent leading/trailing edges.
new_indicator = r"""function Library:CreateSlidingTabIndicator(Layer, Height)
    local Controller = {};
    local Connection;
    local VisualLeft = 0;
    local VisualRight = 0;
    local TargetLeft = 0;
    local TargetRight = 0;
    local TargetY = 0;
    local Direction = 1;

    local Indicator = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.fromOffset(0, Height or 21);
        Visible = false;
        ZIndex = 20;
        Parent = Layer;
    });

    Library:AddCorner(Indicator, 3);

    local Stroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        LineJoinMode = Enum.LineJoinMode.Round;
        Thickness = 1;
        Transparency = 0;
        Parent = Indicator;
    });

    Library:Create('UIGradient', {
        Rotation = 90;
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.30, 0.01),
            NumberSequenceKeypoint.new(0.55, 0.22),
            NumberSequenceKeypoint.new(0.78, 0.76),
            NumberSequenceKeypoint.new(1, 1),
        });
        Parent = Stroke;
    });

    Library:AddToRegistry(Stroke, { Color = 'AccentColor'; });

    local function RenderIndicator()
        local Width = math.max(VisualRight - VisualLeft, 1);
        Indicator.Position = UDim2.fromOffset(VisualLeft, TargetY);
        Indicator.Size = UDim2.fromOffset(Width, Height or Indicator.Size.Y.Offset);
    end;

    local function StopAnimation()
        if Connection then
            Connection:Disconnect();
            Connection = nil;
        end;
    end;

    local function StartAnimation()
        if Connection then
            return;
        end;

        Connection = RenderStepped:Connect(function(Delta)
            if not Indicator.Parent then
                StopAnimation();
                return;
            end;

            local LeftDistance = math.abs(TargetLeft - VisualLeft);
            local RightDistance = math.abs(TargetRight - VisualRight);
            local Settling = math.max(LeftDistance, RightDistance) < 7;
            local LeadSpeed = Settling and 31 or 27;
            local TrailSpeed = Settling and 31 or 15;
            local LeftSpeed = Direction < 0 and LeadSpeed or TrailSpeed;
            local RightSpeed = Direction > 0 and LeadSpeed or TrailSpeed;

            local LeftAlpha = 1 - math.exp(-Delta * LeftSpeed);
            local RightAlpha = 1 - math.exp(-Delta * RightSpeed);
            VisualLeft = VisualLeft + ((TargetLeft - VisualLeft) * LeftAlpha);
            VisualRight = VisualRight + ((TargetRight - VisualRight) * RightAlpha);

            if LeftDistance <= 0.08 and RightDistance <= 0.08 then
                VisualLeft = TargetLeft;
                VisualRight = TargetRight;
                RenderIndicator();
                StopAnimation();
                return;
            end;

            RenderIndicator();
        end);
    end;

    function Controller:MoveTo(Button, Instant)
        if not Button or not Button.Parent or Button.AbsoluteSize.X <= 0 then
            return;
        end;

        local NewLeft = Button.AbsolutePosition.X - Layer.AbsolutePosition.X;
        local NewRight = NewLeft + Button.AbsoluteSize.X;
        local NewY = Button.AbsolutePosition.Y - Layer.AbsolutePosition.Y;

        if Instant or not Indicator.Visible or (VisualRight - VisualLeft) <= 0 then
            StopAnimation();
            VisualLeft = NewLeft;
            VisualRight = NewRight;
            TargetLeft = NewLeft;
            TargetRight = NewRight;
            TargetY = NewY;
            Indicator.Visible = true;
            RenderIndicator();
            return;
        end;

        local CurrentCenter = (VisualLeft + VisualRight) * 0.5;
        local TargetCenter = (NewLeft + NewRight) * 0.5;
        Direction = TargetCenter >= CurrentCenter and 1 or -1;
        TargetLeft = NewLeft;
        TargetRight = NewRight;
        TargetY = NewY;
        Indicator.Visible = true;
        StartAnimation();
    end;

    function Controller:Refresh(Button)
        self:MoveTo(Button, true);
    end;

    Controller.Frame = Indicator;
    return Controller;
end;

"""
library = regex_once(
    library,
    r"function Library:CreateSlidingTabIndicator\(Layer, Height\).*?function Library:ApplyTextStroke",
    new_indicator + "function Library:ApplyTextStroke",
    'Sliding tab indicator',
)

# Multiline tooltip input: strings, explicit newlines, or arrays of lines.
library = replace_once(
    library,
    """    local Title = type(Info) == 'table' and (Info.Title or Info.title) or nil\n    local Text = type(Info) == 'table' and (Info.Text or Info.Description or Info.text or Info.description or Info[1]) or Info\n\n    Title = type(Title) == 'string' and Title or nil\n    Text = type(Text) == 'string' and Text or ''""",
    """    local function NormalizeTooltipText(Value)\n        if type(Value) == 'table' then\n            local Lines = {};\n            for _, Line in ipairs(Value) do\n                table.insert(Lines, tostring(Line));\n            end;\n            return table.concat(Lines, '\\n');\n        end;\n\n        return type(Value) == 'string' and Value or '';\n    end;\n\n    local Title = type(Info) == 'table' and (Info.Title or Info.title) or nil\n    local TextValue = type(Info) == 'table' and (Info.Text or Info.Description or Info.text or Info.description or Info.Lines or Info.lines or Info[1]) or Info\n\n    Title = type(Title) == 'string' and Title or nil\n    local Text = NormalizeTooltipText(TextValue)""",
    'Tooltip multiline normalization',
)

# Color picker: make the CanvasGroup itself transparent and animate only GroupTransparency.
library = replace_once(
    library,
    """        local PickerFrameOuter = Library:Create('CanvasGroup', {\n            Name = 'Color';\n            BackgroundColor3 = Color3.new(1, 1, 1);\n            BorderColor3 = Color3.new(0, 0, 0);""",
    """        local PickerFrameOuter = Library:Create('CanvasGroup', {\n            Name = 'Color';\n            BackgroundTransparency = 1;\n            BorderSizePixel = 0;""",
    'Color picker shell',
)

library = regex_once(
    library,
    r"        local PickerAnimationId = 0;\n        local PickerTweens = \{\}.*?        local function GetPickerTargetPosition\(\)",
    """        local PickerAnimationId = 0;\n        local PickerTweens = {}\n\n        local function GetPickerTargetPosition()""",
    'Remove color picker descendant fade cache',
)

library = regex_once(
    library,
    r"        local function TweenPickerFade\(Hidden, Duration\).*?        function ColorPicker:Show\(\)",
    "        function ColorPicker:Show()",
    'Remove color picker descendant tween',
)

library = regex_once(
    library,
    r"        function ColorPicker:Show\(\).*?        function ColorPicker:SetValue\(HSV, Transparency\)",
    """        function ColorPicker:Show()\n            for Frame in next, Library.OpenedFrames do\n                if Frame.Name == 'Color' and Frame ~= PickerFrameOuter then\n                    Frame.Visible = false;\n                    Library.OpenedFrames[Frame] = nil;\n                end;\n            end;\n\n            PickerAnimationId = PickerAnimationId + 1;\n            CancelPickerTweens();\n\n            local TargetPosition = GetPickerTargetPosition();\n            PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 26);\n            PickerFrameOuter.GroupTransparency = 1;\n            PickerFrameOuter.Visible = true;\n            Library.OpenedFrames[PickerFrameOuter] = true;\n\n            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {\n                Position = TargetPosition;\n            });\n            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {\n                GroupTransparency = 0;\n            });\n        end;\n\n        function ColorPicker:Hide()\n            if not PickerFrameOuter.Visible then\n                Library.OpenedFrames[PickerFrameOuter] = nil;\n                return;\n            end;\n\n            PickerAnimationId = PickerAnimationId + 1;\n            local CurrentId = PickerAnimationId;\n            CancelPickerTweens();\n            Library.OpenedFrames[PickerFrameOuter] = nil;\n\n            local TargetPosition = GetPickerTargetPosition();\n            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 10);\n                GroupTransparency = 1;\n            });\n\n            ExitTween.Completed:Connect(function(State)\n                if CurrentId ~= PickerAnimationId or State == Enum.PlaybackState.Cancelled then\n                    return;\n                end;\n\n                PickerFrameOuter.Visible = false;\n                PickerFrameOuter.Position = TargetPosition;\n                PickerFrameOuter.GroupTransparency = 1;\n                table.clear(PickerTweens);\n            end);\n        end;\n\n        function ColorPicker:SetValue(HSV, Transparency)""",
    'Color picker animation',
)

# Dropdown: detach the popup, keep a full-size list, fade/move instead of expanding, and edge auto-scroll.
library = regex_once(
    library,
    r"        local ListHeight = MAX_DROPDOWN_ITEMS \* 20 \+ 2\n\n        local function RecalculateListPosition\(\).*?        RecalculateListPosition\(\);",
    """        local ListHeight = MAX_DROPDOWN_ITEMS * 20 + 2\n        local ListGap = 5\n        local ListTargetPosition = UDim2.fromOffset(0, 0)\n\n        local function RecalculateListPosition()\n            ListTargetPosition = UDim2.fromOffset(\n                DropdownOuter.AbsolutePosition.X,\n                DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + ListGap\n            );\n\n            if not Dropdown.Opened then\n                ListOuter.Position = ListTargetPosition;\n            end;\n        end;\n\n        local function RecalculateListSize(YSize)\n            ListHeight = YSize or (MAX_DROPDOWN_ITEMS * 20 + 2);\n            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight);\n        end;\n\n        RecalculateListPosition();""",
    'Detached dropdown positioning',
)

library = replace_once(
    library,
    "            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);",
    "            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 8);",
    'Dropdown bottom padding',
)

library = regex_once(
    library,
    r"        function Dropdown:OpenDropdown\(\).*?        end;\n\n        function Dropdown:CloseDropdown\(\).*?        end;",
    """        local DropdownScrollConnection;\n\n        local function StopDropdownAutoScroll()\n            if DropdownScrollConnection then\n                DropdownScrollConnection:Disconnect();\n                DropdownScrollConnection = nil;\n            end;\n        end;\n\n        local function StartDropdownAutoScroll()\n            StopDropdownAutoScroll();\n            DropdownScrollConnection = RenderStepped:Connect(function(Delta)\n                if not Dropdown.Opened or not ListOuter.Visible then\n                    StopDropdownAutoScroll();\n                    return;\n                end;\n\n                local Position = ListOuter.AbsolutePosition;\n                local Size = ListOuter.AbsoluteSize;\n                local MouseInsideX = Mouse.X >= Position.X and Mouse.X <= Position.X + Size.X;\n                if not MouseInsideX then\n                    return;\n                end;\n\n                local Edge = math.min(22, Size.Y * 0.22);\n                local Direction = 0;\n                local Strength = 0;\n\n                if Mouse.Y >= Position.Y + Size.Y - Edge and Mouse.Y <= Position.Y + Size.Y + 4 then\n                    Direction = 1;\n                    Strength = math.clamp((Mouse.Y - (Position.Y + Size.Y - Edge)) / math.max(Edge, 1), 0, 1);\n                elseif Mouse.Y <= Position.Y + Edge and Mouse.Y >= Position.Y - 4 then\n                    Direction = -1;\n                    Strength = math.clamp(((Position.Y + Edge) - Mouse.Y) / math.max(Edge, 1), 0, 1);\n                end;\n\n                if Direction ~= 0 then\n                    local MaxCanvas = math.max(Scrolling.AbsoluteCanvasSize.Y - Scrolling.AbsoluteSize.Y, 0);\n                    local NewY = math.clamp(Scrolling.CanvasPosition.Y + (Direction * (70 + 170 * Strength) * Delta), 0, MaxCanvas);\n                    Scrolling.CanvasPosition = Vector2.new(Scrolling.CanvasPosition.X, NewY);\n                end;\n            end);\n        end;\n\n        function Dropdown:OpenDropdown()\n            if Dropdown.Opened then\n                return;\n            end;\n\n            Dropdown.Opened = true;\n            DropdownAnimationId = DropdownAnimationId + 1;\n            CancelDropdownTweens();\n            RecalculateListPosition();\n            RecalculateListSize(ListHeight);\n\n            ListOuter.Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 4);\n            ListInner.GroupTransparency = 1;\n            ListOuter.Visible = true;\n            Library.OpenedFrames[ListOuter] = true;\n\n            PlayDropdownTween(ListOuter, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {\n                Position = ListTargetPosition;\n            });\n            PlayDropdownTween(ListInner, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {\n                GroupTransparency = 0;\n            });\n            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Rotation = 180;\n            });\n\n            StartDropdownAutoScroll();\n        end;\n\n        function Dropdown:CloseDropdown()\n            if not Dropdown.Opened and not ListOuter.Visible then\n                return;\n            end;\n\n            Dropdown.Opened = false;\n            DropdownAnimationId = DropdownAnimationId + 1;\n            local CurrentId = DropdownAnimationId;\n            CancelDropdownTweens();\n            StopDropdownAutoScroll();\n            Library.OpenedFrames[ListOuter] = nil;\n\n            local ExitTween = PlayDropdownTween(ListInner, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {\n                GroupTransparency = 1;\n            });\n            PlayDropdownTween(ListOuter, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 3);\n            });\n            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Rotation = 0;\n            });\n\n            ExitTween.Completed:Connect(function(State)\n                if CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then\n                    return;\n                end;\n\n                ListOuter.Visible = false;\n                ListOuter.Position = ListTargetPosition;\n                table.clear(DropdownTweens);\n            end);\n        end;""",
    'Dropdown fade animation and edge scroll',
)

# Center the main tab row.
library = replace_once(
    library,
    """    local TabListLayout = Library:Create('UIListLayout', {\n        Padding = UDim.new(0, Config.TabPadding);\n        FillDirection = Enum.FillDirection.Horizontal;\n        SortOrder = Enum.SortOrder.LayoutOrder;""",
    """    local TabListLayout = Library:Create('UIListLayout', {\n        Padding = UDim.new(0, Config.TabPadding);\n        FillDirection = Enum.FillDirection.Horizontal;\n        HorizontalAlignment = Enum.HorizontalAlignment.Center;\n        SortOrder = Enum.SortOrder.LayoutOrder;""",
    'Centered main tabs',
)

# Track whole groupbox shells as CanvasGroups so tab transitions include borders/titles.
library = replace_once(
    library,
    """        local Tab = {\n            Groupboxes = {};\n            Tabboxes = {};\n        };""",
    """        local Tab = {\n            Groupboxes = {};\n            Tabboxes = {};\n            VisualGroups = {};\n        };""",
    'Tab visual groups',
)

library = replace_once(
    library,
    """        local TabFrame = Library:Create('CanvasGroup', {\n            Name = 'TabFrame',\n            BackgroundTransparency = 1;\n            GroupTransparency = 1;\n            Position = UDim2.new(0, 0, 0, 8);""",
    """        local TabFrame = Library:Create('Frame', {\n            Name = 'TabFrame',\n            BackgroundTransparency = 1;\n            Position = UDim2.new(0, 0, 0, 7);""",
    'Tab frame root',
)

visual_helper = """        local function SetTabVisualGroups(Target, Duration, Stagger)\n            for Index, Group in ipairs(Tab.VisualGroups) do\n                if Group and Group.Parent then\n                    if not Duration or Duration <= 0 then\n                        Group.GroupTransparency = Target;\n                    else\n                        local Delay = (Stagger or 0) * (Index - 1);\n                        task.delay(Delay, function()\n                            if Group and Group.Parent then\n                                Library:TweenProperty(Group, 'GroupTransparency', Target, Duration);\n                            end;\n                        end);\n                    end;\n                end;\n            end;\n        end;\n\n"""
library = replace_once(
    library,
    "        function Tab:ShowTab()\n",
    visual_helper + "        function Tab:ShowTab()\n",
    'Tab visual fade helper',
)

library = regex_once(
    library,
    r"        function Tab:ShowTab\(\).*?        function Tab:SetLayoutOrder\(Position\)",
    """        function Tab:ShowTab()\n            if Tab.Active then\n                MainTabIndicator:MoveTo(TabButton, false);\n                return;\n            end;\n\n            for _, OtherTab in next, Window.Tabs do\n                if OtherTab ~= Tab then\n                    OtherTab:HideTab();\n                end;\n            end;\n\n            Tab.Active = true;\n            Window.ActiveTab = Tab;\n            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';\n            MainTabIndicator:MoveTo(TabButton, not MainTabIndicator.Frame.Visible);\n\n            TabFrame.Position = UDim2.new(0, 0, 0, 7);\n            TabFrame.Visible = true;\n            SetTabVisualGroups(1, 0);\n\n            task.defer(function()\n                if Tab.Active then\n                    SetTabVisualGroups(0, 0.22, 0.018);\n                    Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, 0), 0.26);\n                end;\n            end);\n        end;\n\n        function Tab:HideTab()\n            if not Tab.Active then\n                return;\n            end;\n\n            Tab.Active = false;\n            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n            local CurrentAnimation = Tab.ContentAnimationId;\n\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.14);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.14);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';\n            SetTabVisualGroups(1, 0.14, 0);\n            Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, -4), 0.17);\n\n            task.delay(0.17, function()\n                if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then\n                    TabFrame.Visible = false;\n                    TabFrame.Position = UDim2.new(0, 0, 0, 7);\n                end;\n            end);\n        end;\n\n        function Tab:SetLayoutOrder(Position)""",
    'Main tab transition',
)

# Convert both top-level groupbox shells to CanvasGroups and register them for tab fades.
library = replace_once(
    library,
    """            local BoxOuter = Library:Create('Frame', {\n                BackgroundColor3 = Library.BackgroundColor;\n                BorderColor3 = Library.OutlineColor;\n                BorderMode = Enum.BorderMode.Inset;\n                Size = UDim2.new(1, 0, 0, 507 + 2);""",
    """            local BoxOuter = Library:Create('CanvasGroup', {\n                BackgroundColor3 = Library.BackgroundColor;\n                BorderColor3 = Library.OutlineColor;\n                BorderMode = Enum.BorderMode.Inset;\n                GroupTransparency = Tab.Active and 0 or 1;\n                Size = UDim2.new(1, 0, 0, 507 + 2);""",
    'Groupbox CanvasGroup',
)

library = replace_once(
    library,
    """            Library:AddToRegistry(BoxOuter, {\n                BackgroundColor3 = 'BackgroundColor';\n                BorderColor3 = 'OutlineColor';\n            });\n\n            local BoxInner =""",
    """            Library:AddToRegistry(BoxOuter, {\n                BackgroundColor3 = 'BackgroundColor';\n                BorderColor3 = 'OutlineColor';\n            });\n            table.insert(Tab.VisualGroups, BoxOuter);\n\n            local BoxInner =""",
    'Register groupbox visual group',
)

library = replace_once(
    library,
    """            local BoxOuter = Library:Create('Frame', {\n                BackgroundColor3 = Library.BackgroundColor;\n                BorderColor3 = Library.OutlineColor;\n                BorderMode = Enum.BorderMode.Inset;\n                Size = UDim2.new(1, 0, 0, 0);""",
    """            local BoxOuter = Library:Create('CanvasGroup', {\n                BackgroundColor3 = Library.BackgroundColor;\n                BorderColor3 = Library.OutlineColor;\n                BorderMode = Enum.BorderMode.Inset;\n                GroupTransparency = Tab.Active and 0 or 1;\n                Size = UDim2.new(1, 0, 0, 0);""",
    'Tabbox CanvasGroup',
)

# This is the second BoxOuter registry block; target by the following BoxInner + Highlight signature.
library = regex_once(
    library,
    r"(            Library:AddToRegistry\(BoxOuter, \{\n                BackgroundColor3 = 'BackgroundColor';\n                BorderColor3 = 'OutlineColor';\n            \}\);\n\n            local BoxInner = Library:Create\('Frame', \{\n                BackgroundColor3 = Library.BackgroundColor;\n                BorderColor3 = Color3.new\(0, 0, 0\);\n                Size = UDim2.new\(1, -2, 1, -2\);\n                Position = UDim2.new\(0, 1, 0, 1\);\n                ZIndex = 4;\n                Parent = BoxOuter;\n            \}\);\n\n            Library:AddToRegistry\(BoxInner, \{\n                BackgroundColor3 = 'BackgroundColor';\n            \}\);\n\n            local Highlight =)",
    lambda m: m.group(1).replace("            });\n\n            local BoxInner", "            });\n            table.insert(Tab.VisualGroups, BoxOuter);\n\n            local BoxInner", 1),
    'Register tabbox visual group',
)

# Center tabbox rows too.
library = regex_once(
    library,
    r"(            Library:Create\('UIListLayout', \{\n                FillDirection = Enum.FillDirection.Horizontal;\n)                HorizontalAlignment = Enum.HorizontalAlignment.Left;\n(                SortOrder = Enum.SortOrder.LayoutOrder;\n                Parent = TabboxButtons;)",
    r"\1                HorizontalAlignment = Enum.HorizontalAlignment.Center;\n\2",
    'Centered tabbox tabs',
)

# Keybind badges become clean <Key> text with no boxed background.
library = replace_once(
    library,
    """        local PickOuter = Library:Create('Frame', {\n            BackgroundColor3 = Color3.new(0, 0, 0);\n            BorderColor3 = Color3.new(0, 0, 0);\n            Size = UDim2.new(0, 28, 0, 15);""",
    """        local PickOuter = Library:Create('Frame', {\n            BackgroundTransparency = 1;\n            BorderSizePixel = 0;\n            Size = UDim2.new(0, 28, 0, 15);""",
    'Keypicker outer badge',
)

library = replace_once(
    library,
    """        local PickInner = Library:Create('Frame', {\n            BackgroundColor3 = Library.BackgroundColor;\n            BorderColor3 = Library.OutlineColor;\n            BorderMode = Enum.BorderMode.Inset;\n            Size = UDim2.new(1, 0, 1, 0);""",
    """        local PickInner = Library:Create('Frame', {\n            BackgroundTransparency = 1;\n            BorderSizePixel = 0;\n            Size = UDim2.new(1, 0, 1, 0);""",
    'Keypicker inner badge',
)

library = replace_once(
    library,
    """        local DisplayLabel = Library:CreateLabel({\n            Size = UDim2.new(1, 0, 1, 0);\n            TextSize = 13;\n            Text = Info.Default;\n            TextWrapped = true;\n            ZIndex = 8;\n            Parent = PickInner;\n        });""",
    """        local DisplayLabel = Library:CreateLabel({\n            Size = UDim2.new(1, 0, 1, 0);\n            TextSize = 13;\n            Text = '<' .. Info.Default .. '>';\n            TextWrapped = false;\n            ZIndex = 8;\n            Parent = PickInner;\n        });\n\n        local function SetKeyDisplay(Key)\n            local Text = '<' .. tostring(Key) .. '>';\n            DisplayLabel.Text = Text;\n            local Width = select(1, Library:GetTextBounds(Text, Library.Font, 13));\n            PickOuter.Size = UDim2.fromOffset(math.max(28, Width + 6), 15);\n        end;\n\n        SetKeyDisplay(Info.Default);""",
    'Keypicker angle display',
)

library = replace_once(library, "            DisplayLabel.Text = Key;\n            KeyPicker.Value = Key;", "            SetKeyDisplay(Key);\n            KeyPicker.Value = Key;", 'Keypicker SetValue display')
library = replace_once(library, "                    DisplayLabel.Text = Key;\n                    KeyPicker.Value = Key;", "                    SetKeyDisplay(Key);\n                    KeyPicker.Value = Key;", 'Keypicker picked display')
library = replace_once(library, "                DisplayLabel.Text = '';", "                DisplayLabel.Text = '<...>';", 'Keypicker picking display')
library = replace_once(
    library,
    "            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);",
    "            ContainerLabel.Text = string.format('<%s> %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);",
    'Keybind menu angle display',
)

# Replace the old window glow stack with the shared smoother glow.
library = regex_once(
    library,
    r"    local WindowGlowLayers = \{.*?    end;\n\n    local WindowLabel",
    "    Library:AddAccentGlow(Inner, 1);\n\n    local WindowLabel",
    'Window glow stack',
)

# Watermark gets the same blended accent glow.
library = replace_once(
    library,
    """    Library:AddToRegistry(WatermarkInner, {\n        BorderColor3 = 'AccentColor';\n    });""",
    """    Library:AddToRegistry(WatermarkInner, {\n        BorderColor3 = 'AccentColor';\n    });\n    Library:AddCorner(WatermarkOuter, 3);\n    Library:AddCorner(WatermarkInner, 3);\n    Library:AddAccentGlow(WatermarkInner, 0.9);""",
    'Watermark glow',
)

# Keybind menu uses an accent border and matching glow.
library = replace_once(
    library,
    """    local KeybindInner = Library:Create('Frame', {\n        BackgroundColor3 = Library.MainColor;\n        BorderColor3 = Library.OutlineColor;""",
    """    local KeybindInner = Library:Create('Frame', {\n        BackgroundColor3 = Library.MainColor;\n        BorderColor3 = Library.AccentColor;""",
    'Keybind accent border',
)

library = replace_once(
    library,
    """    Library:AddToRegistry(KeybindInner, {\n        BackgroundColor3 = 'MainColor';\n        BorderColor3 = 'OutlineColor';\n    }, true);""",
    """    Library:AddToRegistry(KeybindInner, {\n        BackgroundColor3 = 'MainColor';\n        BorderColor3 = 'AccentColor';\n    }, true);\n    Library:AddCorner(KeybindOuter, 3);\n    Library:AddCorner(KeybindInner, 3);\n    Library:AddAccentGlow(KeybindInner, 0.9);""",
    'Keybind glow registry',
)

# Keep the final default font call aligned with the actual registered name.
library = library.replace("Library:SetFont('Rubik');", "Library:SetFont('Rubik Light');")

# Sanity checks for the requested behavior.
required = [
    "function Library:SetTextSize(Size)",
    "HorizontalAlignment = Enum.HorizontalAlignment.Center;",
    "function Library:AddAccentGlow(Instance, Scale)",
    "local function StartDropdownAutoScroll()",
    "DisplayLabel.Text = '<...>';",
    "SetTabVisualGroups(0, 0.22, 0.018)",
    "PickerFrameOuter.GroupTransparency = 1;",
]
for token in required:
    if token not in library:
        raise SystemExit(f'missing Library token: {token}')

if "VisibleAnchor = Vector2.new(0.08, 0.83);" not in theme:
    raise SystemExit('Marin corrected anchor missing')
if "Default = 14;" not in theme or "self.Library:SetTextSize" not in theme:
    raise SystemExit('literal ThemeManager text size missing')

library_path.write_text(library)
theme_path.write_text(theme)
