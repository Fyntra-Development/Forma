from pathlib import Path

p = Path('Library.lua')
s = p.read_text()

def rep(old, new, label):
    global s
    n = s.count(old)
    if n != 1:
        raise SystemExit(f'{label}: expected 1 match, found {n}')
    s = s.replace(old, new, 1)

rep("""        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };
""", """        local SettingsInfo = type(Info.Settings) == 'table' and Info.Settings or {};
        local SettingsEnabled = Info.Settings == true or type(Info.Settings) == 'table' or Info.EnableSettings == true;
        local function Setting(Name, Fallback)
            local Value = SettingsInfo[Name];
            if Value == nil then Value = Info[Name]; end;
            return Value == nil and Fallback or Value;
        end;

        local InitialMode = tostring(Setting('Mode', 'Solid'));
        if InitialMode ~= 'Solid' and InitialMode ~= 'Fade' and InitialMode ~= 'Rainbow' then InitialMode = 'Solid'; end;
        if not SettingsEnabled then InitialMode = 'Solid'; end;
        local H, S, V = Color3.toHSV(Info.Default);
        local DefaultColor2 = Color3.fromHSV((H + 0.5) % 1, S, V);
        local InitialColor1 = Setting('Color1', Info.Default);
        local InitialColor2 = Setting('Color2', DefaultColor2);
        if typeof(InitialColor1) ~= 'Color3' then InitialColor1 = Info.Default; end;
        if typeof(InitialColor2) ~= 'Color3' then InitialColor2 = DefaultColor2; end;

        local ColorPicker = {
            Value = Info.Default;
            SolidColor = Info.Default;
            Color1 = InitialColor1;
            Color2 = InitialColor2;
            Transparency = Info.Transparency or 0;
            Mode = InitialMode;
            Speed = math.clamp(tonumber(Setting('Speed', 1)) or 1, 0.25, 4);
            SettingsEnabled = SettingsEnabled;
            EditingTarget = 'Solid';
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };
""", 'colorpicker state')

old_header = """        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title;
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

"""
new_header = """        local ColorControls = { SatVibMapOuter, HueSelectorOuter, HueBoxOuter, RgbBoxBase };
        if TransparencyBoxOuter then table.insert(ColorControls, TransparencyBoxOuter); end;
        local ActiveTab = 'Color';
        local AnimationElapsed = 0;
        local RainbowHueOffset = ColorPicker.Hue;
        local ModeButtons = {};
        local SettingsContent, FadeDependency, Color1Preview, Color2Preview;
        local SpeedSection, SpeedFill, SpeedCursor, SpeedValueLabel;
        local SelectTab, SetEditorFromColor, RefreshSettingsVisuals, PrepareManualEdit, ApplyOutputColor, ComputeAnimatedColor;

        local TabBar = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(4, 3);
            Size = UDim2.new(1, -8, 0, 18);
            ZIndex = 22;
            Parent = PickerFrameInner;
        });
        local ColorTab = Library:CreateLabel({
            Active = true;
            Size = SettingsEnabled and UDim2.new(0.5, -2, 1, -1) or UDim2.new(1, 0, 1, -1);
            Text = 'Color';
            TextSize = 13;
            TextColor3 = Library.AccentColor;
            ZIndex = 23;
            Parent = TabBar;
        });
        Library.RegistryMap[ColorTab].Properties.TextColor3 = 'AccentColor';
        local SettingsTab;
        if SettingsEnabled then
            SettingsTab = Library:CreateLabel({
                Active = true;
                Position = UDim2.new(0.5, 2, 0, 0);
                Size = UDim2.new(0.5, -2, 1, -1);
                Text = 'Settings';
                TextSize = 13;
                ZIndex = 23;
                Parent = TabBar;
            });
        end;
        local TabIndicator = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, -1);
            Size = SettingsEnabled and UDim2.new(0.5, -2, 0, 1) or UDim2.new(1, 0, 0, 1);
            ZIndex = 24;
            Parent = TabBar;
        });
        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });

        if SettingsEnabled then
            SettingsContent = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(0, 24);
                Size = UDim2.new(1, 0, 1, -24);
                Visible = false;
                ZIndex = 18;
                Parent = PickerFrameInner;
            });
            Library:CreateLabel({
                Position = UDim2.fromOffset(8, 3);
                Size = UDim2.new(1, -16, 0, 16);
                Text = 'Mode';
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 19;
                Parent = SettingsContent;
            });
            local ModeRow = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 22);
                Size = UDim2.new(1, -14, 0, 22);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            for Index, Mode in ipairs({ 'Solid', 'Fade', 'Rainbow' }) do
                local Outer = Library:Create('Frame', {
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    BorderColor3 = Color3.new(0, 0, 0);
                    Position = UDim2.new((Index - 1) / 3, Index == 1 and 0 or 2, 0, 0);
                    Size = UDim2.new(1 / 3, -3, 1, 0);
                    ZIndex = 19;
                    Parent = ModeRow;
                });
                local Inner = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 20;
                    Parent = Outer;
                });
                local Label = Library:CreateLabel({
                    Active = true;
                    Size = UDim2.fromScale(1, 1);
                    Text = Mode;
                    TextSize = 12;
                    ZIndex = 21;
                    Parent = Inner;
                });
                Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
                ModeButtons[Mode] = { Inner = Inner; Label = Label; };
                Outer.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        ColorPicker:SetMode(Mode);
                        Library:AttemptSave();
                    end;
                end);
            end;

            FadeDependency = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 53);
                Size = UDim2.new(1, -14, 0, 58);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            local function MakeFadeRow(Text, Y, Index)
                Library:CreateLabel({
                    Position = UDim2.fromOffset(1, Y);
                    Size = UDim2.new(1, -42, 0, 22);
                    Text = Text;
                    TextSize = 13;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 20;
                    Parent = FadeDependency;
                });
                local Outer = Library:Create('Frame', {
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    Position = UDim2.new(1, -34, 0, Y + 3);
                    Size = UDim2.fromOffset(30, 16);
                    ZIndex = 20;
                    Parent = FadeDependency;
                });
                local Preview = Library:Create('Frame', {
                    BackgroundColor3 = Index == 1 and ColorPicker.Color1 or ColorPicker.Color2;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 21;
                    Parent = Outer;
                });
                Library:AddToRegistry(Preview, { BorderColor3 = 'OutlineColor'; });
                Outer.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
                    ColorPicker.EditingTarget = Index == 1 and 'Color1' or 'Color2';
                    SetEditorFromColor(Index == 1 and ColorPicker.Color1 or ColorPicker.Color2);
                    SelectTab('Color', true);
                end);
                return Preview;
            end;
            Color1Preview = MakeFadeRow('Color 1', 0, 1);
            Color2Preview = MakeFadeRow('Color 2', 29, 2);

            SpeedSection = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 119);
                Size = UDim2.new(1, -14, 0, 45);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            SpeedValueLabel = Library:CreateLabel({
                Position = UDim2.fromOffset(1, 0);
                Size = UDim2.new(1, -2, 0, 16);
                Text = 'Speed';
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 20;
                Parent = SpeedSection;
            });
            local Track = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.fromOffset(1, 22);
                Size = UDim2.new(1, -2, 0, 8);
                ZIndex = 20;
                Parent = SpeedSection;
            });
            Library:AddToRegistry(Track, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            SpeedFill = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(0, 0, 1, 0);
                ZIndex = 21;
                Parent = Track;
            });
            Library:AddToRegistry(SpeedFill, { BackgroundColor3 = 'AccentColor'; });
            SpeedCursor = Library:Create('Frame', {
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromScale(0, 0.5);
                Size = UDim2.fromOffset(3, 12);
                ZIndex = 22;
                Parent = Track;
            });
            Track.InputBegan:Connect(function(Input)
                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
                repeat
                    local MinX, MaxX = Track.AbsolutePosition.X, Track.AbsolutePosition.X + Track.AbsoluteSize.X;
                    local Alpha = (math.clamp(Mouse.X, MinX, MaxX) - MinX) / math.max(MaxX - MinX, 1);
                    ColorPicker:SetSpeed(0.25 + Alpha * 3.75);
                    RenderStepped:Wait();
                until not InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
                Library:AttemptSave();
            end);
        end;

"""
rep(old_header, new_header, 'colorpicker tabs/settings ui')

anchor = """        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });

"""
helpers = r'''        local function SetTabLabel(Label, Active)
            if not Label then return; end;
            Label.TextColor3 = Active and Library.AccentColor or Library.FontColor;
            local Data = Library.RegistryMap[Label];
            if Data then Data.Properties.TextColor3 = Active and 'AccentColor' or 'FontColor'; end;
        end;

        local function SetColorControlsVisible(Visible)
            for _, Control in ipairs(ColorControls) do Control.Visible = Visible; end;
        end;

        local function UpdateOutputVisuals(Color)
            DisplayFrame.BackgroundColor3 = Color;
            DisplayFrame.BackgroundTransparency = ColorPicker.Transparency;
            DisplayShade.BackgroundColor3 = Library:GetNeutralBlendShade();
            DisplayShade.BackgroundTransparency = ColorPicker.Transparency;
            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = Color;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;
        end;

        local function RefreshEditorVisuals()
            local EditorColor = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);
            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);
            local Hex = '#' .. EditorColor:ToHex();
            local Rgb = table.concat({ math.floor(EditorColor.R * 255), math.floor(EditorColor.G * 255), math.floor(EditorColor.B * 255) }, ', ');
            if not HueBox:IsFocused() and HueBox.Text ~= Hex then HueBox.Text = Hex; end;
            if not RgbBox:IsFocused() and RgbBox.Text ~= Rgb then RgbBox.Text = Rgb; end;
        end;

        SetEditorFromColor = function(Color)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker:SetHSVFromRGB(Color);
            RefreshEditorVisuals();
        end;

        local function FireCallbacks()
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        ApplyOutputColor = function(Color, Fire, SyncEditor)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker.Value = Color;
            UpdateOutputVisuals(Color);
            if SyncEditor then SetEditorFromColor(Color); end;
            if Fire then FireCallbacks(); end;
        end;

        ComputeAnimatedColor = function()
            if ColorPicker.Mode == 'Rainbow' then
                return Color3.fromHSV((RainbowHueOffset + AnimationElapsed * ColorPicker.Speed / 6) % 1, 1, 1);
            elseif ColorPicker.Mode == 'Fade' then
                local Phase = (AnimationElapsed * ColorPicker.Speed / 4) % 1;
                local Alpha = 0.5 - 0.5 * math.cos(Phase * math.pi * 2);
                return ColorPicker.Color1:Lerp(ColorPicker.Color2, Alpha);
            end;
            return ColorPicker.SolidColor;
        end;

        RefreshSettingsVisuals = function()
            if not SettingsEnabled then return; end;
            for Mode, Button in pairs(ModeButtons) do
                local Active = Mode == ColorPicker.Mode;
                Button.Inner.BackgroundColor3 = Active and Library.AccentColor:Lerp(Library.MainColor, 0.72) or Library.MainColor;
                SetTabLabel(Button.Label, Active);
            end;
            FadeDependency.Visible = ColorPicker.Mode == 'Fade';
            Color1Preview.BackgroundColor3 = ColorPicker.Color1;
            Color2Preview.BackgroundColor3 = ColorPicker.Color2;
            SpeedSection.Visible = ColorPicker.Mode ~= 'Solid';
            SpeedSection.Position = UDim2.fromOffset(7, ColorPicker.Mode == 'Fade' and 119 or 53);
            SpeedValueLabel.Text = string.format('Speed  %.2fx', ColorPicker.Speed);
            local Alpha = math.clamp((ColorPicker.Speed - 0.25) / 3.75, 0, 1);
            SpeedFill.Size = UDim2.new(Alpha, 0, 1, 0);
            SpeedCursor.Position = UDim2.new(Alpha, 0, 0.5, 0);
        end;

        SelectTab = function(Name, PreserveTarget)
            if Name == 'Settings' and not SettingsEnabled then Name = 'Color'; end;
            ActiveTab = Name;
            SetColorControlsVisible(Name == 'Color');
            if SettingsContent then SettingsContent.Visible = Name == 'Settings'; end;
            SetTabLabel(ColorTab, Name == 'Color');
            SetTabLabel(SettingsTab, Name == 'Settings');
            if SettingsEnabled then
                Library:Animate(TabIndicator, {
                    Position = Name == 'Settings' and UDim2.new(0.5, 2, 1, -1) or UDim2.new(0, 0, 1, -1)
                }, 0.14, nil, 'TabIndicator');
            end;
            if Name == 'Color' and not PreserveTarget then
                if ColorPicker.Mode == 'Solid' then
                    ColorPicker.EditingTarget = 'Solid';
                    SetEditorFromColor(ColorPicker.SolidColor);
                else
                    ColorPicker.EditingTarget = 'Live';
                    SetEditorFromColor(ColorPicker.Value);
                end;
            end;
            if Name == 'Settings' then RefreshSettingsVisuals(); end;
        end;

        PrepareManualEdit = function()
            if ColorPicker.EditingTarget == 'Live' then
                ColorPicker.SolidColor = ColorPicker.Value;
                ColorPicker.EditingTarget = 'Solid';
                ColorPicker:SetMode('Solid', true);
                SetEditorFromColor(ColorPicker.SolidColor);
            end;
        end;

        function ColorPicker:SetMode(Mode, Internal)
            Mode = tostring(Mode or 'Solid');
            if not SettingsEnabled or (Mode ~= 'Solid' and Mode ~= 'Fade' and Mode ~= 'Rainbow') then Mode = 'Solid'; end;
            ColorPicker.Mode = Mode;
            AnimationElapsed = 0;
            if Mode == 'Solid' then
                ColorPicker.EditingTarget = 'Solid';
                ApplyOutputColor(ColorPicker.SolidColor, true, ActiveTab == 'Color');
            else
                ColorPicker.EditingTarget = 'Live';
                if Mode == 'Rainbow' then RainbowHueOffset = select(1, Color3.toHSV(ColorPicker.Value)); end;
                ApplyOutputColor(ComputeAnimatedColor(), true, ActiveTab == 'Color');
            end;
            RefreshSettingsVisuals();
            if not Internal then Library:SafeCallback(ColorPicker.ModeChanged, ColorPicker.Mode); end;
        end;

        function ColorPicker:SetSpeed(Speed)
            ColorPicker.Speed = math.clamp(tonumber(Speed) or ColorPicker.Speed or 1, 0.25, 4);
            RefreshSettingsVisuals();
            Library:SafeCallback(ColorPicker.SpeedChanged, ColorPicker.Speed);
        end;

        function ColorPicker:SetFadeColor(Index, Color)
            if typeof(Color) ~= 'Color3' then return; end;
            if tonumber(Index) == 1 then ColorPicker.Color1 = Color else ColorPicker.Color2 = Color end;
            RefreshSettingsVisuals();
            if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live'); end;
        end;

        function ColorPicker:GetAnimationSettings()
            return { Mode = ColorPicker.Mode; Speed = ColorPicker.Speed; Color1 = ColorPicker.Color1; Color2 = ColorPicker.Color2; SolidColor = ColorPicker.SolidColor; };
        end;

        function ColorPicker:SetAnimationSettings(Data)
            if type(Data) ~= 'table' then return; end;
            if typeof(Data.SolidColor) == 'Color3' then ColorPicker.SolidColor = Data.SolidColor; end;
            if typeof(Data.Color1) == 'Color3' then ColorPicker.Color1 = Data.Color1; end;
            if typeof(Data.Color2) == 'Color3' then ColorPicker.Color2 = Data.Color2; end;
            if Data.Speed ~= nil then ColorPicker.Speed = math.clamp(tonumber(Data.Speed) or ColorPicker.Speed, 0.25, 4); end;
            ColorPicker:SetMode(Data.Mode or ColorPicker.Mode, true);
        end;

        function ColorPicker:OnModeChanged(Func)
            ColorPicker.ModeChanged = Func;
            Func(ColorPicker.Mode);
        end;

        function ColorPicker:OnSpeedChanged(Func)
            ColorPicker.SpeedChanged = Func;
            Func(ColorPicker.Speed);
        end;

        ColorTab.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then SelectTab('Color', false); end;
        end);
        if SettingsTab then
            SettingsTab.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then SelectTab('Settings', false); end;
            end);
        end;

'''
rep(anchor, anchor + helpers, 'colorpicker helpers')

rep("""                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
""", """                if success and typeof(result) == 'Color3' then
                    PrepareManualEdit();
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
""", 'hex manual edit')
rep("""                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
""", """                if r and g and b then
                    PrepareManualEdit();
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
""", 'rgb manual edit')

old_display = """        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library.OutlineColor;
            });
            DisplayShade.BackgroundColor3 = Library:GetNeutralBlendShade();
            DisplayShade.BackgroundTransparency = ColorPicker.Transparency;

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;
"""
new_display = """        function ColorPicker:Display()
            local Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            if ColorPicker.EditingTarget == 'Color1' then
                ColorPicker.Color1 = Color;
                if Color1Preview then Color1Preview.BackgroundColor3 = Color; end;
                if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, false); end;
            elseif ColorPicker.EditingTarget == 'Color2' then
                ColorPicker.Color2 = Color;
                if Color2Preview then Color2Preview.BackgroundColor3 = Color; end;
                if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, false); end;
            else
                ColorPicker.SolidColor = Color;
                ColorPicker.EditingTarget = 'Solid';
                ApplyOutputColor(Color, true, false);
            end;
            RefreshEditorVisuals();
        end;
"""
rep(old_display, new_display, 'display logic')

rep("""        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;
""", """        function ColorPicker:SetValue(HSV, Transparency, PreserveMode)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker.SolidColor = Color;
            if not PreserveMode then ColorPicker:SetMode('Solid', true);
            elseif ColorPicker.Mode == 'Solid' then ApplyOutputColor(Color, true, ActiveTab == 'Color'); end;
            if ColorPicker.Mode == 'Solid' then SetEditorFromColor(Color); end;
        end;

        function ColorPicker:SetValueRGB(Color, Transparency, PreserveMode)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker.SolidColor = Color;
            if not PreserveMode then ColorPicker:SetMode('Solid', true);
            elseif ColorPicker.Mode == 'Solid' then ApplyOutputColor(Color, true, ActiveTab == 'Color'); end;
            if ColorPicker.Mode == 'Solid' then SetEditorFromColor(Color); end;
        end;
""", 'set value methods')

rep("""        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
""", """        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                PrepareManualEdit();
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
""", 'sat/vib manual edit')
rep("""        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
""", """        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                PrepareManualEdit();
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
""", 'hue manual edit')

rep("""                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RenderStepped:Wait();
""", """                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));
                        UpdateOutputVisuals(ColorPicker.Value);
                        FireCallbacks();
                        RenderStepped:Wait();
""", 'transparency dynamic-safe update')

old_end = """        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;
"""
new_end = """        if SettingsEnabled then
            Library:GiveSignal(RenderStepped:Connect(function(Delta)
                if ColorPicker.Mode == 'Solid' then return; end;
                AnimationElapsed = AnimationElapsed + math.min(tonumber(Delta) or 0, 0.1);
                local SyncEditor = PickerFrameOuter.Visible and ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live';
                ApplyOutputColor(ComputeAnimatedColor(), true, SyncEditor);
            end));
        end;

        RefreshSettingsVisuals();
        SelectTab('Color', true);
        ColorPicker:SetMode(InitialMode, true);
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;
"""
rep(old_end, new_end, 'colorpicker initialization')

p.write_text(s)

sp = Path('addons/SaveManager.lua')
s = sp.read_text()
old = """\t\tColorPicker = {\n\t\t\tSave = function(idx, object)\n\t\t\t\treturn { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }\n\t\t\tend,\n\t\t\tLoad = function(idx, data)\n\t\t\t\tif Options[idx] then \n\t\t\t\t\tOptions[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)\n\t\t\t\tend\n\t\t\tend,\n\t\t},\n"""
new = """\t\tColorPicker = {\n\t\t\tSave = function(idx, object)\n\t\t\t\tlocal solid = object.SolidColor or object.Value\n\t\t\t\tlocal data = { type = 'ColorPicker', idx = idx, value = solid:ToHex(), transparency = object.Transparency }\n\t\t\t\tif object.SettingsEnabled then\n\t\t\t\t\tdata.mode, data.speed = object.Mode, object.Speed\n\t\t\t\t\tdata.color1 = object.Color1 and object.Color1:ToHex() or nil\n\t\t\t\t\tdata.color2 = object.Color2 and object.Color2:ToHex() or nil\n\t\t\t\tend\n\t\t\t\treturn data\n\t\t\tend,\n\t\t\tLoad = function(idx, data)\n\t\t\t\tlocal picker = Options[idx]\n\t\t\t\tif picker then\n\t\t\t\t\tpicker:SetValueRGB(Color3.fromHex(data.value), data.transparency, true)\n\t\t\t\t\tif picker.SetAnimationSettings and data.mode then\n\t\t\t\t\t\tpicker:SetAnimationSettings({ Mode = data.mode, Speed = data.speed, SolidColor = Color3.fromHex(data.value), Color1 = data.color1 and Color3.fromHex(data.color1) or nil, Color2 = data.color2 and Color3.fromHex(data.color2) or nil })\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\tend,\n\t\t},\n"""
if s.count(old) != 1:
    raise SystemExit(f'SaveManager parser: expected 1 match, found {s.count(old)}')
s = s.replace(old, new, 1)
sp.write_text(s)
