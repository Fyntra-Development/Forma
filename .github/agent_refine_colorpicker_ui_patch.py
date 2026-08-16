from pathlib import Path

path = Path('Library.lua')
s = path.read_text()

def rep(old, new, label):
    global s
    count = s.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, found {count}')
    s = s.replace(old, new, 1)

# Match the notification accent treatment on the colorpicker's accent line.
rep("""        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

""", """        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        Library:AddMovingAccentGradient(Highlight, 1.6);

""", 'colorpicker accent gradient')

# Add state for smooth live-picker following, mode color blending, and the reused slider.
rep("""        local ActiveTab = 'Color';
        local AnimationElapsed = 0;
        local RainbowHueOffset = ColorPicker.Hue;
        local ModeButtons = {};
        local SettingsContent, FadeDependency, Color1Preview, Color2Preview;
        local SpeedSection, SpeedFill, SpeedCursor, SpeedValueLabel;
        local SelectTab, SetEditorFromColor, RefreshSettingsVisuals, PrepareManualEdit, ApplyOutputColor, ComputeAnimatedColor;
""", """        local ActiveTab = 'Color';
        local AnimationElapsed = 0;
        local RainbowHueOffset = ColorPicker.Hue;
        local ModeTransitionFrom = ColorPicker.Value;
        local ModeTransitionElapsed = 1;
        local ModeTransitionDuration = 0.28;
        local VisualHue, VisualSat, VisualVib = ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib;
        local VisualTextElapsed = 0;
        local ModeAnimationId = 0;
        local ModeButtons = {};
        local SettingsContent, FadeDependency, Color1Preview, Color2Preview;
        local SpeedSection, SpeedSlider;
        local SelectTab, SetEditorFromColor, RefreshSettingsVisuals, UpdateModeLayout, PrepareManualEdit, ApplyOutputColor, ComputeAnimatedColor;
""", 'colorpicker animation state')

rep("""        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });

""", """        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });
        Library:AddMovingAccentGradient(TabIndicator, 1.6);

""", 'tab indicator accent gradient')

old_settings = """            FadeDependency = Library:Create('Frame', {
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
"""

new_settings = """            FadeDependency = Library:Create('CanvasGroup', {
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                GroupTransparency = 1;
                Position = UDim2.fromOffset(7, 53);
                Size = UDim2.new(1, -14, 0, 0);
                Visible = false;
                ZIndex = 19;
                Parent = SettingsContent;
            });
            local function MakeFadeRow(Text, Y, Index)
                Library:CreateLabel({
                    Position = UDim2.fromOffset(1, Y);
                    Size = UDim2.new(1, -40, 0, 22);
                    Text = Text;
                    TextSize = 13;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 20;
                    Parent = FadeDependency;
                });
                local Preview = Library:Create('Frame', {
                    BackgroundColor3 = Index == 1 and ColorPicker.Color1 or ColorPicker.Color2;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Position = UDim2.new(1, -31, 0, Y + 4);
                    Size = UDim2.fromOffset(28, 14);
                    ZIndex = 21;
                    Parent = FadeDependency;
                });
                Library:AddToRegistry(Preview, { BorderColor3 = 'OutlineColor'; });

                local PreviewShade = Library:Create('Frame', {
                    BackgroundColor3 = Library:GetNeutralBlendShade();
                    BackgroundTransparency = 0;
                    BorderSizePixel = 0;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 22;
                    Parent = Preview;
                });
                Library:AddToRegistry(PreviewShade, {
                    BackgroundColor3 = function()
                        return Library:GetNeutralBlendShade();
                    end;
                });
                Library:Create('UIGradient', {
                    Rotation = -135;
                    Transparency = Library:GetBlendShadeTransparency(0.42);
                    Parent = PreviewShade;
                });

                Preview.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
                    ColorPicker.EditingTarget = Index == 1 and 'Color1' or 'Color2';
                    SetEditorFromColor(Index == 1 and ColorPicker.Color1 or ColorPicker.Color2);
                    SelectTab('Color', true);
                end);
                return Preview;
            end;
            Color1Preview = MakeFadeRow('Color 1', 0, 1);
            Color2Preview = MakeFadeRow('Color 2', 29, 2);

            SpeedSection = Library:Create('CanvasGroup', {
                BackgroundTransparency = 1;
                GroupTransparency = 1;
                Position = UDim2.fromOffset(7, 119);
                Size = UDim2.new(1, -14, 0, 30);
                Visible = false;
                ZIndex = 19;
                Parent = SettingsContent;
            });
            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = SpeedSection;
            });
            SpeedSlider = Library:CreateEmbeddedSlider(SpeedSection, {
                Text = 'Speed';
                Default = ColorPicker.Speed;
                Min = 0.25;
                Max = 4;
                Rounding = 2;
                Step = 0.05;
                Suffix = 'x';
                BlankSize = 0;
                AllowOpenedFrameInteraction = true;
                Callback = function(Value)
                    local NewSpeed = math.clamp(tonumber(Value) or ColorPicker.Speed or 1, 0.25, 4);
                    if math.abs(NewSpeed - ColorPicker.Speed) < 0.0001 then return; end;
                    ColorPicker.Speed = NewSpeed;
                    if RefreshSettingsVisuals then RefreshSettingsVisuals(); end;
                    Library:SafeCallback(ColorPicker.SpeedChanged, ColorPicker.Speed);
                end;
            });
            for _, Descendant in ipairs(SpeedSection:GetDescendants()) do
                if Descendant:IsA('GuiObject') then
                    Descendant.ZIndex = Descendant.ZIndex + 16;
                end;
            end;
"""
rep(old_settings, new_settings, 'settings previews and standard speed slider')

# Smooth visual following for the animated picker without making callback output lag.
rep("""        local function RefreshEditorVisuals()
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
""", """        local function RefreshEditorVisuals(ColorOverride, UpdateText)
            local EditorColor = typeof(ColorOverride) == 'Color3'
                and ColorOverride
                or Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            local EditorHue, EditorSat, EditorVib = Color3.toHSV(EditorColor);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(EditorHue, 1, 1);
            CursorOuter.Position = UDim2.new(EditorSat, 0, 1 - EditorVib, 0);
            HueCursor.Position = UDim2.new(0, 0, EditorHue, 0);

            if UpdateText ~= false then
                local Hex = '#' .. EditorColor:ToHex();
                local Rgb = table.concat({ math.floor(EditorColor.R * 255), math.floor(EditorColor.G * 255), math.floor(EditorColor.B * 255) }, ', ');
                if not HueBox:IsFocused() and HueBox.Text ~= Hex then HueBox.Text = Hex; end;
                if not RgbBox:IsFocused() and RgbBox.Text ~= Rgb then RgbBox.Text = Rgb; end;
            end;
        end;

        SetEditorFromColor = function(Color)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker:SetHSVFromRGB(Color);
            VisualHue, VisualSat, VisualVib = ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib;
            VisualTextElapsed = 0;
            RefreshEditorVisuals(Color, true);
        end;

        local function StepAnimatedEditor(Color, Delta)
            if typeof(Color) ~= 'Color3' then return; end;
            local Dt = math.min(math.max(tonumber(Delta) or 0, 0), 0.05);
            local TargetHue, TargetSat, TargetVib = Color3.toHSV(Color);
            local Alpha = 1 - math.exp(-18 * Dt);
            local HueDelta = ((TargetHue - VisualHue + 0.5) % 1) - 0.5;
            VisualHue = (VisualHue + (HueDelta * Alpha)) % 1;
            VisualSat = VisualSat + ((TargetSat - VisualSat) * Alpha);
            VisualVib = VisualVib + ((TargetVib - VisualVib) * Alpha);

            VisualTextElapsed = VisualTextElapsed + Dt;
            local UpdateText = VisualTextElapsed >= (1 / 30);
            if UpdateText then VisualTextElapsed = 0; end;
            RefreshEditorVisuals(Color3.fromHSV(VisualHue, VisualSat, VisualVib), UpdateText);
        end;
""", 'smooth animated editor visuals')

# Animate mode button state, dependency reveal/collapse, and the reused slider's layout.
old_refresh = """        RefreshSettingsVisuals = function()
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
"""
new_refresh = """        RefreshSettingsVisuals = function()
            if not SettingsEnabled then return; end;
            for Mode, Button in pairs(ModeButtons) do
                local Active = Mode == ColorPicker.Mode;
                local TargetBackground = Active and Library.AccentColor:Lerp(Library.MainColor, 0.72) or Library.MainColor;
                local TargetText = Active and Library.AccentColor or Library.FontColor;
                Library:Animate(Button.Inner, { BackgroundColor3 = TargetBackground }, 0.16, nil, 'ColorPickerMode');
                Library:Animate(Button.Label, { TextColor3 = TargetText }, 0.15, nil, 'ColorPickerMode');
                local Data = Library.RegistryMap[Button.Label];
                if Data then Data.Properties.TextColor3 = Active and 'AccentColor' or 'FontColor'; end;
            end;
            Color1Preview.BackgroundColor3 = ColorPicker.Color1;
            Color2Preview.BackgroundColor3 = ColorPicker.Color2;
            if SpeedSlider and math.abs((SpeedSlider.Value or 0) - ColorPicker.Speed) > 0.0001 then
                SpeedSlider.Value = ColorPicker.Speed;
                SpeedSlider:Display(false);
            end;
        end;

        UpdateModeLayout = function(Instant)
            if not SettingsEnabled then return; end;
            ModeAnimationId = ModeAnimationId + 1;
            local CurrentId = ModeAnimationId;
            local ShowFade = ColorPicker.Mode == 'Fade';
            local ShowSpeed = ColorPicker.Mode ~= 'Solid';
            local SpeedY = ShowFade and 119 or 53;

            Library:CancelMotion(FadeDependency);
            Library:CancelMotion(SpeedSection);

            if ShowFade then
                FadeDependency.Visible = true;
                if Instant then
                    FadeDependency.Size = UDim2.new(1, -14, 0, 58);
                    FadeDependency.GroupTransparency = 0;
                else
                    if FadeDependency.Size.Y.Offset <= 0 then
                        FadeDependency.Size = UDim2.new(1, -14, 0, 0);
                        FadeDependency.GroupTransparency = 1;
                    end;
                    Library:Animate(FadeDependency, {
                        Size = UDim2.new(1, -14, 0, 58);
                        GroupTransparency = 0;
                    }, 0.22, nil, 'ColorPickerMode');
                end;
            elseif Instant then
                FadeDependency.Size = UDim2.new(1, -14, 0, 0);
                FadeDependency.GroupTransparency = 1;
                FadeDependency.Visible = false;
            elseif FadeDependency.Visible then
                Library:Animate(FadeDependency, {
                    Size = UDim2.new(1, -14, 0, 0);
                    GroupTransparency = 1;
                }, 0.18, function(State)
                    if CurrentId == ModeAnimationId and ColorPicker.Mode ~= 'Fade' and State ~= Enum.PlaybackState.Cancelled then
                        FadeDependency.Visible = false;
                    end;
                end, 'ColorPickerMode');
            end;

            if ShowSpeed then
                local WasVisible = SpeedSection.Visible;
                SpeedSection.Visible = true;
                if Instant then
                    SpeedSection.Position = UDim2.fromOffset(7, SpeedY);
                    SpeedSection.GroupTransparency = 0;
                else
                    if not WasVisible then
                        SpeedSection.Position = UDim2.fromOffset(7, SpeedY + 6);
                        SpeedSection.GroupTransparency = 1;
                    end;
                    Library:Animate(SpeedSection, {
                        Position = UDim2.fromOffset(7, SpeedY);
                        GroupTransparency = 0;
                    }, 0.22, nil, 'ColorPickerMode');
                end;
            elseif Instant then
                SpeedSection.Position = UDim2.fromOffset(7, 53);
                SpeedSection.GroupTransparency = 1;
                SpeedSection.Visible = false;
            elseif SpeedSection.Visible then
                local CurrentY = SpeedSection.Position.Y.Offset;
                Library:Animate(SpeedSection, {
                    Position = UDim2.fromOffset(7, CurrentY + 6);
                    GroupTransparency = 1;
                }, 0.18, function(State)
                    if CurrentId == ModeAnimationId and ColorPicker.Mode == 'Solid' and State ~= Enum.PlaybackState.Cancelled then
                        SpeedSection.Visible = false;
                        SpeedSection.Position = UDim2.fromOffset(7, 53);
                    end;
                end, 'ColorPickerMode');
            end;
        end;
"""
rep(old_refresh, new_refresh, 'mode settings transitions')

# Blend the generated color across mode changes instead of snapping to the new mode.
rep("""        function ColorPicker:SetMode(Mode, Internal)
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
""", """        function ColorPicker:SetMode(Mode, Internal)
            Mode = tostring(Mode or 'Solid');
            if not SettingsEnabled or (Mode ~= 'Solid' and Mode ~= 'Fade' and Mode ~= 'Rainbow') then Mode = 'Solid'; end;
            if Mode == ColorPicker.Mode and not Internal then
                RefreshSettingsVisuals();
                UpdateModeLayout(false);
                return;
            end;

            local PreviousColor = ColorPicker.Value;
            ColorPicker.Mode = Mode;
            AnimationElapsed = 0;
            ModeTransitionFrom = PreviousColor;
            ModeTransitionElapsed = Internal and ModeTransitionDuration or 0;

            if Mode == 'Solid' then
                ColorPicker.EditingTarget = 'Solid';
            else
                ColorPicker.EditingTarget = 'Live';
                if Mode == 'Rainbow' then RainbowHueOffset = select(1, Color3.toHSV(PreviousColor)); end;
            end;

            if Internal then
                local TargetColor = ComputeAnimatedColor();
                ApplyOutputColor(TargetColor, true, false);
                if ActiveTab == 'Color' then SetEditorFromColor(TargetColor); end;
            else
                VisualHue, VisualSat, VisualVib = Color3.toHSV(PreviousColor);
                VisualTextElapsed = 0;
            end;

            RefreshSettingsVisuals();
            UpdateModeLayout(Internal);
            if not Internal then Library:SafeCallback(ColorPicker.ModeChanged, ColorPicker.Mode); end;
        end;

        function ColorPicker:SetSpeed(Speed)
            ColorPicker.Speed = math.clamp(tonumber(Speed) or ColorPicker.Speed or 1, 0.25, 4);
            if SpeedSlider and math.abs((SpeedSlider.Value or 0) - ColorPicker.Speed) > 0.0001 then
                SpeedSlider.Value = ColorPicker.Speed;
                SpeedSlider:Display(false);
            end;
            RefreshSettingsVisuals();
            Library:SafeCallback(ColorPicker.SpeedChanged, ColorPicker.Speed);
        end;
""", 'mode color blend and speed sync')

# Keep endpoint previews styled correctly when edited.
# (They remain Frames, so the existing direct BackgroundColor3 updates stay valid.)

# Smoothly blend mode output and visually follow it with the hue/SV controls.
rep("""        if SettingsEnabled then
            Library:GiveSignal(RenderStepped:Connect(function(Delta)
                if ColorPicker.Mode == 'Solid' then return; end;
                AnimationElapsed = AnimationElapsed + math.min(tonumber(Delta) or 0, 0.1);
                local SyncEditor = PickerFrameOuter.Visible and ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live';
                ApplyOutputColor(ComputeAnimatedColor(), true, SyncEditor);
            end));
        end;
""", """        if SettingsEnabled then
            Library:GiveSignal(RenderStepped:Connect(function(Delta)
                local Dt = math.min(math.max(tonumber(Delta) or 0, 0), 0.1);
                local Transitioning = ModeTransitionElapsed < ModeTransitionDuration;
                if ColorPicker.Mode == 'Solid' and not Transitioning then return; end;

                if ColorPicker.Mode ~= 'Solid' then
                    AnimationElapsed = AnimationElapsed + Dt;
                end;
                if Transitioning then
                    ModeTransitionElapsed = math.min(ModeTransitionElapsed + Dt, ModeTransitionDuration);
                end;

                local TargetColor = ComputeAnimatedColor();
                local OutputColor = TargetColor;
                if ModeTransitionElapsed < ModeTransitionDuration then
                    local Alpha = math.clamp(ModeTransitionElapsed / ModeTransitionDuration, 0, 1);
                    local Eased = 1 - ((1 - Alpha) ^ 3);
                    OutputColor = ModeTransitionFrom:Lerp(TargetColor, Eased);
                end;

                local SyncEditor = PickerFrameOuter.Visible and ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live';
                ApplyOutputColor(OutputColor, true, false);
                if SyncEditor then StepAnimatedEditor(OutputColor, Dt); end;
            end));
        end;
""", 'renderstep smooth mode output')

# Let the standard slider be embedded in popups without registering a second public Option.
rep("""                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Library:MouseIsOverOpenedFrame() then
                    return;
                end;
""", """                if Input.UserInputType ~= Enum.UserInputType.MouseButton1
                    or (not Info.AllowOpenedFrameInteraction and Library:MouseIsOverOpenedFrame()) then
                    return;
                end;
""", 'slider nudge popup interaction')

rep("""            if (Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch)
                or Library:MouseIsOverOpenedFrame() then
                return;
            end;
""", """            if (Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch)
                or (not Info.AllowOpenedFrameInteraction and Library:MouseIsOverOpenedFrame()) then
                return;
            end;
""", 'slider drag popup interaction')

rep("""        Options[Idx] = Slider;
        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
""", """        if not Info.NoRegister then Options[Idx] = Slider; end;
        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
""", 'slider no-register support')

# Reuse the exact existing AddSlider implementation for embedded/popup controls.
rep("""    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

do
    Library.NotificationArea = Library:Create('Frame', {
""", """    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

function Library:CreateEmbeddedSlider(Container, Info)
    assert(Container and Container:IsA('GuiObject'), 'CreateEmbeddedSlider: invalid container.');
    local Host = { Container = Container; };
    function Host:Resize() end;
    setmetatable(Host, BaseGroupbox);

    local SliderInfo = table.clone(Info or {});
    SliderInfo.NoRegister = true;
    if SliderInfo.BlankSize == nil then SliderInfo.BlankSize = 0; end;
    return Host:AddSlider(nil, SliderInfo);
end;

do
    Library.NotificationArea = Library:Create('Frame', {
""", 'embedded standard slider helper')

path.write_text(s)
