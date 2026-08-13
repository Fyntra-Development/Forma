from pathlib import Path

library_path = Path('Library.lua')
theme_path = Path('addons/ThemeManager.lua')
library = library_path.read_text()
theme = theme_path.read_text()

# --- Global text scaling ----------------------------------------------------
needle = """    Font = Enum.Font.Code,\n    FontName = 'Code',\n\n    OpenedFrames = {};\n"""
replacement = """    Font = Enum.Font.Code,\n    FontName = 'Code',\n    TextScale = 1;\n\n    OpenedFrames = {};\n"""
assert library.count(needle) == 1, 'Library text-scale table anchor mismatch'
library = library.replace(needle, replacement, 1)

needle = """Library.PropertyTweens = setmetatable({}, { __mode = 'k' });\n\nfunction Library:GetFontNames()\n"""
replacement = """Library.PropertyTweens = setmetatable({}, { __mode = 'k' });\nLibrary.BaseTextSizes = setmetatable({}, { __mode = 'k' });\n\nfunction Library:GetFontNames()\n"""
assert library.count(needle) == 1, 'BaseTextSizes anchor mismatch'
library = library.replace(needle, replacement, 1)

needle = """function Library:SetFont(Name)\n    return Library:LoadFont(Name);\nend;\n\nLibrary:LoadFont('Rubik Light');\n"""
replacement = """function Library:SetFont(Name)\n    return Library:LoadFont(Name);\nend;\n\nfunction Library:GetScaledTextSize(BaseSize)\n    BaseSize = tonumber(BaseSize) or 16;\n    return math.max(6, math.floor((BaseSize * Library.TextScale) + 0.5));\nend;\n\nfunction Library:SetTextScale(Scale)\n    Scale = math.clamp(tonumber(Scale) or 1, 0.75, 1.5);\n    Library.TextScale = Scale;\n\n    for Instance, BaseSize in next, Library.BaseTextSizes do\n        if Instance and Instance.Parent then\n            pcall(function()\n                Instance.TextSize = Library:GetScaledTextSize(BaseSize);\n            end);\n        end;\n    end;\nend;\n\nLibrary:LoadFont('Rubik Light');\n"""
assert library.count(needle) == 1, 'SetTextScale insertion anchor mismatch'
library = library.replace(needle, replacement, 1)

old_create = """function Library:Create(Class, Properties)\n    local _Instance = Class;\n\n    if type(Class) == 'string' then\n        _Instance = Instance.new(Class);\n    end;\n\n    for Property, Value in next, Properties do\n        _Instance[Property] = Value;\n    end;\n\n    return _Instance;\nend;\n"""
new_create = """function Library:Create(Class, Properties)\n    local _Instance = Class;\n\n    if type(Class) == 'string' then\n        _Instance = Instance.new(Class);\n    end;\n\n    local IsTextObject = _Instance:IsA('TextLabel') or _Instance:IsA('TextBox') or _Instance:IsA('TextButton');\n    local ExplicitTextSize = IsTextObject and Properties.TextSize or nil;\n\n    for Property, Value in next, Properties do\n        _Instance[Property] = Value;\n    end;\n\n    if IsTextObject then\n        local BaseSize = ExplicitTextSize or Library.BaseTextSizes[_Instance] or _Instance.TextSize;\n        Library.BaseTextSizes[_Instance] = BaseSize;\n        _Instance.TextSize = Library:GetScaledTextSize(BaseSize);\n    end;\n\n    return _Instance;\nend;\n"""
assert library.count(old_create) == 1, 'Library:Create block mismatch'
library = library.replace(old_create, new_create, 1)

needle = """function Library:GetTextBounds(Text, FontValue, Size, Resolution)\n    local MaxResolution = Resolution or Vector2.new(1920, 1080);\n"""
replacement = """function Library:GetTextBounds(Text, FontValue, Size, Resolution)\n    Size = Library:GetScaledTextSize(Size);\n    local MaxResolution = Resolution or Vector2.new(1920, 1080);\n"""
assert library.count(needle) == 1, 'GetTextBounds scale anchor mismatch'
library = library.replace(needle, replacement, 1)

# --- Connected, sliding tab accent indicator -------------------------------
insert_anchor = """function Library:ApplyTextStroke(Inst)\n"""
indicator_code = r'''function Library:CreateSlidingTabIndicator(Layer, Height)
    local Controller = {};
    local AnimationId = 0;
    local ActiveTweens = {};

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
            NumberSequenceKeypoint.new(0.32, 0.02),
            NumberSequenceKeypoint.new(0.58, 0.28),
            NumberSequenceKeypoint.new(0.82, 0.86),
            NumberSequenceKeypoint.new(1, 1),
        });
        Parent = Stroke;
    });

    Library:AddToRegistry(Stroke, {
        Color = 'AccentColor';
    });

    local function CancelTweens()
        for _, Tween in next, ActiveTweens do
            pcall(function() Tween:Cancel(); end);
        end;
        table.clear(ActiveTweens);
    end;

    local function Play(Properties, Duration, Style, Direction)
        local Tween = TweenService:Create(
            Indicator,
            TweenInfo.new(Duration, Style, Direction or Enum.EasingDirection.Out),
            Properties
        );
        table.insert(ActiveTweens, Tween);
        Tween:Play();
        return Tween;
    end;

    function Controller:MoveTo(Button, Instant)
        if not Button or not Button.Parent or Button.AbsoluteSize.X <= 0 then
            return;
        end;

        AnimationId = AnimationId + 1;
        local CurrentId = AnimationId;
        CancelTweens();

        local TargetX = Button.AbsolutePosition.X - Layer.AbsolutePosition.X;
        local TargetY = Button.AbsolutePosition.Y - Layer.AbsolutePosition.Y;
        local TargetWidth = Button.AbsoluteSize.X;
        local IndicatorHeight = Height or Button.AbsoluteSize.Y;

        if Instant or not Indicator.Visible or Indicator.Size.X.Offset <= 0 then
            Indicator.Position = UDim2.fromOffset(TargetX, TargetY);
            Indicator.Size = UDim2.fromOffset(TargetWidth, IndicatorHeight);
            Indicator.Visible = true;
            return;
        end;

        Indicator.Visible = true;

        local CurrentX = Indicator.Position.X.Offset;
        local Delta = TargetX - CurrentX;
        local Extra = math.min(70, (math.abs(Delta) * 0.45) + 6);
        local StretchX;

        if Delta >= 0 then
            StretchX = CurrentX + (Delta * 0.55);
        else
            StretchX = TargetX - 6;
        end;

        local StretchTween = Play({
            Position = UDim2.fromOffset(StretchX, TargetY);
            Size = UDim2.fromOffset(TargetWidth + Extra, IndicatorHeight);
        }, 0.13, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);

        StretchTween.Completed:Connect(function(State)
            if CurrentId ~= AnimationId or State == Enum.PlaybackState.Cancelled then
                return;
            end;

            table.clear(ActiveTweens);
            Play({
                Position = UDim2.fromOffset(TargetX, TargetY);
                Size = UDim2.fromOffset(TargetWidth, IndicatorHeight);
            }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
        end);
    end;

    function Controller:Refresh(Button)
        self:MoveTo(Button, true);
    end;

    Controller.Frame = Indicator;
    return Controller;
end;

'''
assert library.count(insert_anchor) == 1, 'Sliding indicator insertion anchor mismatch'
library = library.replace(insert_anchor, indicator_code + insert_anchor, 1)

# --- Color picker: explicit full-content fade + larger downward travel ------
needle = """        local PickerAnimationId = 0;\n        local PickerTweens = {};\n\n        local function GetPickerTargetPosition()\n"""
replacement = r'''        local PickerAnimationId = 0;
        local PickerTweens = {};
        local PickerFadeDefaults = nil;

        local function CapturePickerFadeDefaults()
            if PickerFadeDefaults then
                return;
            end;

            PickerFadeDefaults = setmetatable({}, { __mode = 'k' });
            local Objects = { PickerFrameOuter };

            for _, Descendant in ipairs(PickerFrameOuter:GetDescendants()) do
                table.insert(Objects, Descendant);
            end;

            for _, Object in ipairs(Objects) do
                local Properties = {};

                if Object:IsA('GuiObject') then
                    Properties.BackgroundTransparency = Object.BackgroundTransparency;
                end;

                if Object:IsA('TextLabel') or Object:IsA('TextBox') or Object:IsA('TextButton') then
                    Properties.TextTransparency = Object.TextTransparency;
                    Properties.TextStrokeTransparency = Object.TextStrokeTransparency;
                end;

                if Object:IsA('ImageLabel') or Object:IsA('ImageButton') then
                    Properties.ImageTransparency = Object.ImageTransparency;
                end;

                if Object:IsA('UIStroke') then
                    Properties.Transparency = Object.Transparency;
                end;

                if next(Properties) then
                    PickerFadeDefaults[Object] = Properties;
                end;
            end;
        end;

        local function SetPickerFadeHidden(Hidden)
            CapturePickerFadeDefaults();

            for Object, Properties in next, PickerFadeDefaults do
                if Object and Object.Parent then
                    for Property, BaseValue in next, Properties do
                        Object[Property] = Hidden and 1 or BaseValue;
                    end;
                end;
            end;
        end;

        local function GetPickerTargetPosition()
'''
assert library.count(needle) == 1, 'Picker fade insertion anchor mismatch'
library = library.replace(needle, replacement, 1)

needle = """        local function PlayPickerTween(Instance, InfoValue, Properties)\n            local Tween = TweenService:Create(Instance, InfoValue, Properties);\n            table.insert(PickerTweens, Tween);\n            Tween:Play();\n            return Tween;\n        end;\n\n        function ColorPicker:Show()\n"""
replacement = r'''        local function PlayPickerTween(Instance, InfoValue, Properties)
            local Tween = TweenService:Create(Instance, InfoValue, Properties);
            table.insert(PickerTweens, Tween);
            Tween:Play();
            return Tween;
        end;

        local function TweenPickerFade(Hidden, Duration)
            CapturePickerFadeDefaults();
            local TweenInfoValue = TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

            for Object, Properties in next, PickerFadeDefaults do
                if Object and Object.Parent then
                    local Targets = {};
                    for Property, BaseValue in next, Properties do
                        Targets[Property] = Hidden and 1 or BaseValue;
                    end;
                    PlayPickerTween(Object, TweenInfoValue, Targets);
                end;
            end;
        end;

        function ColorPicker:Show()
'''
assert library.count(needle) == 1, 'TweenPickerFade insertion anchor mismatch'
library = library.replace(needle, replacement, 1)

old_show = """            local TargetPosition = GetPickerTargetPosition();\n\n            if not PickerFrameOuter.Visible then\n                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 8);\n                PickerFrameOuter.GroupTransparency = 1;\n            end;\n\n            PickerFrameOuter.Visible = true;\n            Library.OpenedFrames[PickerFrameOuter] = true;\n\n            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {\n                Position = TargetPosition;\n                GroupTransparency = 0;\n            });\n"""
new_show = """            local TargetPosition = GetPickerTargetPosition();\n\n            if not PickerFrameOuter.Visible then\n                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 18);\n                PickerFrameOuter.GroupTransparency = 1;\n                SetPickerFadeHidden(true);\n            end;\n\n            PickerFrameOuter.Visible = true;\n            Library.OpenedFrames[PickerFrameOuter] = true;\n\n            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {\n                Position = TargetPosition;\n            });\n            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {\n                GroupTransparency = 0;\n            });\n            TweenPickerFade(false, 0.24);\n"""
assert library.count(old_show) == 1, 'ColorPicker Show block mismatch'
library = library.replace(old_show, new_show, 1)

old_hide = """            local TargetPosition = GetPickerTargetPosition();\n            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 5);\n                GroupTransparency = 1;\n            });\n\n            ExitTween.Completed:Connect(function()\n"""
new_hide = """            local TargetPosition = GetPickerTargetPosition();\n            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {\n                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 9);\n                GroupTransparency = 1;\n            });\n            TweenPickerFade(true, 0.17);\n\n            ExitTween.Completed:Connect(function()\n"""
assert library.count(old_hide) == 1, 'ColorPicker Hide block mismatch'
library = library.replace(old_hide, new_hide, 1)

needle = """                PickerFrameOuter.Visible = false;\n                PickerFrameOuter.Position = TargetPosition;\n                PickerFrameOuter.GroupTransparency = 0;\n                table.clear(PickerTweens);\n"""
replacement = """                PickerFrameOuter.Visible = false;\n                PickerFrameOuter.Position = TargetPosition;\n                PickerFrameOuter.GroupTransparency = 0;\n                SetPickerFadeHidden(false);\n                table.clear(PickerTweens);\n"""
assert library.count(needle) == 1, 'Picker reset block mismatch'
library = library.replace(needle, replacement, 1)

# --- Main tabs: shared elastic indicator + content crossfade ----------------
needle = """    local TabListLayout = Library:Create('UIListLayout', {\n        Padding = UDim.new(0, Config.TabPadding);\n        FillDirection = Enum.FillDirection.Horizontal;\n        SortOrder = Enum.SortOrder.LayoutOrder;\n        Parent = TabArea;\n    });\n\n    local TabContainer = Library:Create('Frame', {\n"""
replacement = """    local TabListLayout = Library:Create('UIListLayout', {\n        Padding = UDim.new(0, Config.TabPadding);\n        FillDirection = Enum.FillDirection.Horizontal;\n        SortOrder = Enum.SortOrder.LayoutOrder;\n        Parent = TabArea;\n    });\n\n    local TabIndicatorLayer = Library:Create('Frame', {\n        BackgroundTransparency = 1;\n        BorderSizePixel = 0;\n        Position = TabArea.Position;\n        Size = TabArea.Size;\n        ZIndex = 12;\n        Parent = MainSectionInner;\n    });\n    local MainTabIndicator = Library:CreateSlidingTabIndicator(TabIndicatorLayer, 21);\n\n    local TabContainer = Library:Create('Frame', {\n"""
assert library.count(needle) == 1, 'Main tab indicator layer anchor mismatch'
library = library.replace(needle, replacement, 1)

needle = """        local SetTabAccentActive = Library:AddTabAccentCap(TabButton);\n\n        local TabFrame = Library:Create('Frame', {\n            Name = 'TabFrame',\n            BackgroundTransparency = 1;\n            Position = UDim2.new(0, 0, 0, 0);\n            Size = UDim2.new(1, 0, 1, 0);\n            Visible = false;\n            ZIndex = 2;\n            Parent = TabContainer;\n        });\n"""
replacement = """        Tab.Active = false;\n        Tab.ContentAnimationId = 0;\n\n        local TabFrame = Library:Create('CanvasGroup', {\n            Name = 'TabFrame',\n            BackgroundTransparency = 1;\n            GroupTransparency = 1;\n            Position = UDim2.new(0, 0, 0, 8);\n            Size = UDim2.new(1, 0, 1, 0);\n            Visible = false;\n            ZIndex = 2;\n            Parent = TabContainer;\n        });\n"""
assert library.count(needle) == 1, 'Main TabFrame block mismatch'
library = library.replace(needle, replacement, 1)

needle = """        local Blocker = Library:Create('Frame', {\n"""
# Inject dynamic width update before blocker, after the label exists.
replacement = """        local function UpdateTabButtonWidth()\n            local Width = math.max(TabButtonLabel.TextBounds.X, 1) + 12;\n            TabButton.Size = UDim2.new(0, Width, 1, 0);\n\n            if Tab.Active then\n                task.defer(function()\n                    MainTabIndicator:Refresh(TabButton);\n                end);\n            end;\n        end;\n\n        TabButtonLabel:GetPropertyChangedSignal('TextBounds'):Connect(UpdateTabButtonWidth);\n        task.defer(UpdateTabButtonWidth);\n\n        local Blocker = Library:Create('Frame', {\n"""
# only replace the first Blocker in Window:AddTab by restricting to segment after TabButtonLabel
segment_start = library.index("        local TabButtonLabel = Library:CreateLabel({")
segment_end = library.index("        local TabFrame =", segment_start)
segment = library[segment_start:segment_end]
assert segment.count(needle) == 1, 'Main tab blocker anchor mismatch'
segment = segment.replace(needle, replacement, 1)
library = library[:segment_start] + segment + library[segment_end:]

old_show_hide = """        function Tab:ShowTab()\n            for _, Tab in next, Window.Tabs do\n                Tab:HideTab();\n            end;\n\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';\n            SetTabAccentActive(true);\n            TabFrame.Visible = true;\n        end;\n\n        function Tab:HideTab()\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.16);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.16);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';\n            SetTabAccentActive(false);\n            TabFrame.Visible = false;\n        end;\n"""
new_show_hide = """        function Tab:ShowTab()\n            if Tab.Active then\n                MainTabIndicator:MoveTo(TabButton, false);\n                return;\n            end;\n\n            for _, OtherTab in next, Window.Tabs do\n                if OtherTab ~= Tab then\n                    OtherTab:HideTab();\n                end;\n            end;\n\n            Tab.Active = true;\n            Window.ActiveTab = Tab;\n            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';\n            MainTabIndicator:MoveTo(TabButton, not MainTabIndicator.Frame.Visible);\n\n            if not TabFrame.Visible then\n                TabFrame.Position = UDim2.new(0, 0, 0, 8);\n                TabFrame.GroupTransparency = 1;\n            end;\n\n            TabFrame.Visible = true;\n            Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, 0), 0.28);\n            Library:TweenProperty(TabFrame, 'GroupTransparency', 0, 0.22);\n        end;\n\n        function Tab:HideTab()\n            Tab.Active = false;\n            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n            local CurrentAnimation = Tab.ContentAnimationId;\n\n            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.16);\n            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.16);\n            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';\n\n            if TabFrame.Visible then\n                Library:TweenProperty(TabFrame, 'GroupTransparency', 1, 0.16);\n                Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, -4), 0.18);\n\n                task.delay(0.18, function()\n                    if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then\n                        TabFrame.Visible = false;\n                        TabFrame.Position = UDim2.new(0, 0, 0, 8);\n                        TabFrame.GroupTransparency = 1;\n                    end;\n                end);\n            end;\n        end;\n"""
assert library.count(old_show_hide) == 1, 'Main tab Show/Hide block mismatch'
library = library.replace(old_show_hide, new_show_hide, 1)

# Keep centered groupbox legends responsive to the text-size setting.
needle = """            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';\n\n            local Container = Library:Create('Frame', {\n"""
replacement = """            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';\n\n            local function UpdateGroupboxLegendSize()\n                GroupboxLabel.Size = UDim2.fromOffset(\n                    math.max(GroupboxLabel.TextBounds.X + 12, 20),\n                    math.max(GroupboxLabel.TextBounds.Y + 2, 16)\n                );\n            end;\n            GroupboxLabel:GetPropertyChangedSignal('TextBounds'):Connect(UpdateGroupboxLegendSize);\n            task.defer(UpdateGroupboxLegendSize);\n\n            local Container = Library:Create('Frame', {\n"""
assert library.count(needle) == 1, 'Groupbox legend sizing anchor mismatch'
library = library.replace(needle, replacement, 1)

# --- Tabboxes: same connected elastic indicator + content reveal -----------
needle = """            Library:Create('UIListLayout', {\n                FillDirection = Enum.FillDirection.Horizontal;\n                HorizontalAlignment = Enum.HorizontalAlignment.Left;\n                SortOrder = Enum.SortOrder.LayoutOrder;\n                Parent = TabboxButtons;\n            });\n\n            function Tabbox:AddTab(Name)\n"""
replacement = """            Library:Create('UIListLayout', {\n                FillDirection = Enum.FillDirection.Horizontal;\n                HorizontalAlignment = Enum.HorizontalAlignment.Left;\n                SortOrder = Enum.SortOrder.LayoutOrder;\n                Parent = TabboxButtons;\n            });\n\n            local TabboxIndicatorLayer = Library:Create('Frame', {\n                BackgroundTransparency = 1;\n                BorderSizePixel = 0;\n                Position = TabboxButtons.Position;\n                Size = TabboxButtons.Size;\n                ZIndex = 12;\n                Parent = BoxInner;\n            });\n            local TabboxIndicator = Library:CreateSlidingTabIndicator(TabboxIndicatorLayer, 18);\n\n            function Tabbox:AddTab(Name)\n"""
assert library.count(needle) == 1, 'Tabbox indicator layer anchor mismatch'
library = library.replace(needle, replacement, 1)

needle = """                local SetTabboxAccentActive = Library:AddTabAccentCap(Button);\n\n                local Container = Library:Create('Frame', {\n                    BackgroundTransparency = 1;\n                    Position = UDim2.new(0, 4, 0, 20);\n                    Size = UDim2.new(1, -4, 1, -20);\n                    ZIndex = 1;\n                    Visible = false;\n                    Parent = BoxInner;\n                });\n"""
replacement = """                Tab.Active = false;\n                Tab.ContentAnimationId = 0;\n\n                local Container = Library:Create('CanvasGroup', {\n                    BackgroundTransparency = 1;\n                    GroupTransparency = 1;\n                    Position = UDim2.new(0, 4, 0, 25);\n                    Size = UDim2.new(1, -4, 1, -20);\n                    ZIndex = 1;\n                    Visible = false;\n                    Parent = BoxInner;\n                });\n"""
assert library.count(needle) == 1, 'Tabbox Container block mismatch'
library = library.replace(needle, replacement, 1)

old_tabbox_show_hide = """                function Tab:Show()\n                    for _, Tab in next, Tabbox.Tabs do\n                        Tab:Hide();\n                    end;\n\n                    Container.Visible = true;\n                    Block.Visible = true;\n\n                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);\n                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);\n                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';\n                    SetTabboxAccentActive(true);\n\n                    Tab:Resize();\n                end;\n\n                function Tab:Hide()\n                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);\n                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);\n                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';\n                    SetTabboxAccentActive(false);\n\n                    task.delay(0.14, function()\n                        if Button.BackgroundColor3 == Library.MainColor then\n                            Container.Visible = false;\n                            Block.Visible = false;\n                        end;\n                    end);\n                end;\n"""
new_tabbox_show_hide = """                function Tab:Show()\n                    if Tab.Active then\n                        TabboxIndicator:MoveTo(Button, false);\n                        return;\n                    end;\n\n                    for _, OtherTab in next, Tabbox.Tabs do\n                        if OtherTab ~= Tab then\n                            OtherTab:Hide();\n                        end;\n                    end;\n\n                    Tab.Active = true;\n                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n                    Container.Visible = true;\n                    Block.Visible = true;\n                    TabboxIndicator:MoveTo(Button, not TabboxIndicator.Frame.Visible);\n\n                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);\n                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);\n                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';\n                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 20), 0.25);\n                    Library:TweenProperty(Container, 'GroupTransparency', 0, 0.2);\n\n                    Tab:Resize();\n                end;\n\n                function Tab:Hide()\n                    Tab.Active = false;\n                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;\n                    local CurrentAnimation = Tab.ContentAnimationId;\n\n                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);\n                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);\n                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';\n                    Library:TweenProperty(Container, 'GroupTransparency', 1, 0.14);\n                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 17), 0.16);\n\n                    task.delay(0.16, function()\n                        if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then\n                            Container.Visible = false;\n                            Container.Position = UDim2.new(0, 4, 0, 25);\n                            Container.GroupTransparency = 1;\n                            Block.Visible = false;\n                        end;\n                    end);\n                end;\n"""
assert library.count(old_tabbox_show_hide) == 1, 'Tabbox Show/Hide block mismatch'
library = library.replace(old_tabbox_show_hide, new_tabbox_show_hide, 1)

# --- ThemeManager: Marin + text-size slider --------------------------------
needle = "\tThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki' }\n"
replacement = "\tThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki', 'Marin Kitagawa' }\n"
assert theme.count(needle) == 1, 'OverlayOrder anchor mismatch'
theme = theme.replace(needle, replacement, 1)

needle = """\t\t['Ibuki'] = {\n\t\t\tFile = 'ibuki.png';\n\t\t\tSize = UDim2.fromOffset(300, 300);\n\t\t\tVisibleAnchor = Vector2.new(3 / 280, 193 / 280);\n\t\t};\n\t}\n"""
replacement = """\t\t['Ibuki'] = {\n\t\t\tFile = 'ibuki.png';\n\t\t\tSize = UDim2.fromOffset(300, 300);\n\t\t\tVisibleAnchor = Vector2.new(3 / 280, 193 / 280);\n\t\t};\n\t\t['Marin Kitagawa'] = {\n\t\t\tFile = 'marin-kitagawa.png';\n\t\t\tSize = UDim2.fromOffset(362, 240);\n\t\t\tVisibleAnchor = Vector2.new(0.08, 0.72);\n\t\t};\n\t}\n"""
assert theme.count(needle) == 1, 'Marin overlay metadata anchor mismatch'
theme = theme.replace(needle, replacement, 1)

needle = """\t\tOptions.ThemeManager_Font:OnChanged(function()\n\t\t\tself.Library:SetFont(Options.ThemeManager_Font.Value)\n\t\tend)\n\n\t\tgroupbox:AddToggle('ThemeManager_OverlayEnabled', { Text = 'UI overlay', Default = false })\n"""
replacement = """\t\tOptions.ThemeManager_Font:OnChanged(function()\n\t\t\tself.Library:SetFont(Options.ThemeManager_Font.Value)\n\t\tend)\n\n\t\tgroupbox:AddSlider('ThemeManager_TextSize', {\n\t\t\tText = 'Text size';\n\t\t\tDefault = 100;\n\t\t\tMin = 75;\n\t\t\tMax = 150;\n\t\t\tRounding = 0;\n\t\t\tStep = 5;\n\t\t\tSuffix = '%';\n\t\t})\n\t\tOptions.ThemeManager_TextSize:OnChanged(function()\n\t\t\tself.Library:SetTextScale(Options.ThemeManager_TextSize.Value / 100)\n\t\tend)\n\n\t\tgroupbox:AddToggle('ThemeManager_OverlayEnabled', { Text = 'UI overlay', Default = false })\n"""
assert theme.count(needle) == 1, 'Theme text-size control anchor mismatch'
theme = theme.replace(needle, replacement, 1)

# Structural assertions.
assert "SetTabAccentActive" not in library
assert "SetTabboxAccentActive" not in library
assert library.count("CreateSlidingTabIndicator") >= 3
assert "TargetPosition.Y.Offset - 18" in library
assert "TweenPickerFade(false, 0.24)" in library
assert "ThemeManager_TextSize" in theme
assert "marin-kitagawa.png" in theme

library_path.write_text(library)
theme_path.write_text(theme)
