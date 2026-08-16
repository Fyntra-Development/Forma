-- Forma example script
-- Structured after LinoriaLib's Example.lua, but adapted to Forma's API and additions.

local repo = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Toggles = getgenv().Toggles
local Options = getgenv().Options

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Stats = game:GetService('Stats')

Library.NotifyOnError = true

local Window = Library:CreateWindow({
    -- Center controls whether the menu starts centered.
    -- AutoShow controls whether it appears immediately after creation.
    -- Position and Size can also be supplied when you want a fixed starting layout.

    Title = 'Forma example',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Callbacks can be passed directly inside an element's options table.
-- For larger projects it is usually cleaner to create the UI first, then bind
-- behavior with Toggles/Options.INDEX:OnChanged(function(Value) ... end).

-- Tabs do not have to be stored in a table, this is only a convenient pattern.
local Tabs = {
    Main = Window:AddTab('Main'),
    ['Forma'] = Window:AddTab('Forma'),
    ['Target HUD'] = Window:AddTab('Target HUD'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groupboxes and Tabbox tabs expose the same control methods.
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Groupbox')

-- We can also access the tab through Window.Tabs:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Groupbox:AddToggle
-- Arguments: Index, Options
LeftGroupBox:AddToggle('MyToggle', {
    Text = 'This is a toggle',
    Default = true,
    Tooltip = 'This is a tooltip',

    Callback = function(Value)
        print('[cb] MyToggle changed to:', Value)
    end
})

-- Toggles is placed in getgenv() by the library.
-- The index passed to AddToggle is the key used here.
Toggles.MyToggle:OnChanged(function()
    print('MyToggle changed to:', Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(false)

-- Toggle:AddKeyPicker
-- Forma supports Always, Toggle, and Hold modes on toggle-attached keybinds.
local FeatureToggle = LeftGroupBox:AddToggle('FeatureToggle', {
    Text = 'Feature with keybind',
    Default = false,
})

FeatureToggle:AddKeyPicker('FeatureKeybind', {
    Default = 'F',
    SyncToggleState = true,
    Mode = 'Toggle',
    Modes = { 'Always', 'Toggle', 'Hold' },
    Text = 'Feature keybind',
    NoUI = false,

    Callback = function(Value)
        print('[cb] Feature key state:', Value)
    end,

    ChangedCallback = function(New)
        print('[cb] Feature key changed:', New)
    end
})

--[[
    Groupbox:AddButton
    Arguments: {
        Text = string,
        Func = function,
        DoubleClick = boolean,
        Tooltip = string,
        Warning = boolean,
        ConfirmDuration = number,
    }

    Buttons can add a second button with :AddButton().
    Forma also supports :AddTertiaryButton() for a responsive three-button row.
    Warning buttons show a confirmation countdown before running their action.
]]

local MyButton = LeftGroupBox:AddButton({
    Text = 'Button',
    Func = function()
        print('You clicked a button!')
    end,
    DoubleClick = false,
    Tooltip = 'This is the main button'
})

local MyButton2 = MyButton:AddButton({
    Text = 'Sub button',
    Func = function()
        print('You clicked the sub button!')
    end,
    DoubleClick = false,
    Tooltip = 'Second button in the responsive row'
})

MyButton2:AddTertiaryButton({
    Text = 'Third',
    Func = function()
        print('You clicked the tertiary button!')
    end,
    Tooltip = 'Third button in the responsive row'
})

LeftGroupBox:AddButton({
    Text = 'Warning action',
    Warning = true,
    ConfirmDuration = 3,
    Tooltip = 'Click again before the countdown ends to confirm.',
    Func = function()
        Library:Notify({
            Title = 'Warning action',
            Text = 'Confirmed.',
            Duration = 3,
        })
    end,
})

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap
LeftGroupBox:AddLabel('This is a label')
LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- Groupbox:AddDivider
-- Arguments: None
LeftGroupBox:AddDivider()

--[[
    Groupbox:AddSlider
    Arguments: Idx, SliderOptions

    SliderOptions: {
        Text = string,
        Default = number,
        Min = number,
        Max = number,
        Rounding = number,
        Step = number,
        Suffix = string,
        Compact = boolean,
        Tooltip = string,
    }

    Forma sliders smoothly filter the fill, thumb, and value badge while dragging.
    The logical value still updates immediately. The +/- nudge controls and the
    editable value badge are part of the normal slider implementation.
]]
LeftGroupBox:AddSlider('MySlider', {
    Text = 'This is my slider!',
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = ' studs',
    Compact = false,

    Callback = function(Value)
        print('[cb] MySlider changed to:', Value)
    end
})

-- Options is also placed in getgenv().
local Number = Options.MySlider.Value
print('Initial slider value:', Number)

Options.MySlider:OnChanged(function()
    print('MySlider changed to:', Options.MySlider.Value)
end)

Options.MySlider:SetValue(25)

LeftGroupBox:AddSlider('SmoothSlider', {
    Text = 'Decimal slider',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Step = 0.05,
})

LeftGroupBox:AddSlider('CompactSlider', {
    Text = 'Compact slider',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true,
})

-- Groupbox:AddInput
-- Arguments: Idx, Info
--
-- Forma textboxes use the animated input renderer/caret and smooth horizontal
-- scrolling while keeping the same normal input API.
LeftGroupBox:AddInput('MyTextbox', {
    Default = 'My textbox!',
    Numeric = false,
    Finished = false,

    Text = 'This is a textbox',
    Tooltip = 'Typing uses Forma\'s animated text/caret renderer.',
    Placeholder = 'Placeholder text',
    MaxLength = 32,

    Callback = function(Value)
        print('[cb] Text updated:', Value)
    end
})

Options.MyTextbox:OnChanged(function()
    print('Textbox changed:', Options.MyTextbox.Value)
end)

-- Groupbox:AddDropdown
-- Arguments: Idx, Info
LeftGroupBox:AddDropdown('MyDropdown', {
    Values = { 'This', 'is', 'a', 'dropdown' },
    Default = 1,
    Multi = false,
    Searchable = true,

    Text = 'A searchable dropdown',
    Tooltip = {
        Title = 'Searchable dropdown',
        Text = {
            'Forma can filter rows while you type.',
            'Rows also fade at the top and bottom of the scrolling viewport.',
        },
    },

    Callback = function(Value)
        print('[cb] Dropdown changed:', Value)
    end
})

Options.MyDropdown:OnChanged(function()
    print('Dropdown changed:', Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue('This')

-- Multi dropdowns return a table of selected entries.
LeftGroupBox:AddDropdown('MyMultiDropdown', {
    Values = { 'ESP', 'Names', 'Boxes', 'Health', 'Distance' },
    Default = { 'ESP', 'Names' },
    Multi = true,
    Searchable = false,

    Text = 'A multi dropdown',
    Tooltip = 'Multi-select values can also be used by dependency boxes.',
})

Options.MyMultiDropdown:OnChanged(function()
    print('Multi dropdown changed:')
    for Key, Value in next, Options.MyMultiDropdown.Value do
        print(Key, Value)
    end
end)

-- SpecialType can populate players and teams automatically.
LeftGroupBox:AddDropdown('MyPlayerDropdown', {
    SpecialType = 'Player',
    Text = 'A player dropdown',
    Searchable = true,
})

LeftGroupBox:AddDropdown('MyTeamDropdown', {
    SpecialType = 'Team',
    Text = 'A team dropdown',
})

-- Label:AddColorPicker
-- Arguments: Idx, Info
--
-- Settings is a Forma extension. It adds Color / Settings tabs and exposes
-- Solid, Fade, and Rainbow modes. Fade reveals Color 1 / Color 2 previews.
-- Fade and Rainbow use the normal Forma slider for speed, and the hue/SV cursors
-- visibly follow the animated output rather than remaining static.
LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
    Default = Color3.fromRGB(0, 170, 255),
    Title = 'Animated color',
    Transparency = 0,

    Settings = {
        Mode = 'Fade',
        Speed = 1.25,
        Color1 = Color3.fromRGB(0, 170, 255),
        Color2 = Color3.fromRGB(190, 70, 255),
    },

    Callback = function(Value)
        print('[cb] Color changed:', Value)
    end
})

Options.ColorPicker:OnChanged(function()
    print('Color changed:', Options.ColorPicker.Value)
    print('Transparency:', Options.ColorPicker.Transparency)
end)

Options.ColorPicker:OnModeChanged(function(Mode)
    print('Color mode changed:', Mode)
end)

Options.ColorPicker:OnSpeedChanged(function(Speed)
    print('Color speed changed:', Speed)
end)

-- A normal colorpicker still works exactly as before when Settings is omitted.
LeftGroupBox:AddLabel('Solid color'):AddColorPicker('SolidColorPicker', {
    Default = Color3.fromRGB(0, 255, 140),
    Title = 'Solid color',
})

-- Label:AddKeyPicker
-- Arguments: Idx, Info
LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
    Default = 'MB2',
    SyncToggleState = false,
    Mode = 'Toggle',
    Modes = { 'Always', 'Toggle', 'Hold' },
    Text = 'Standalone keybind',
    NoUI = false,

    Callback = function(Value)
        print('[cb] Keybind state:', Value)
    end,

    ChangedCallback = function(New)
        print('[cb] Keybind changed:', New)
    end
})

Options.KeyPicker:OnClick(function()
    print('Keybind clicked:', Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
    print('Keybind changed:', Options.KeyPicker.Value)
end)

-- Long text demonstrates the scroll reveal behavior used by overflowing groups.
local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Groupbox #2')
LeftGroupBox2:AddLabel('Long text can push a group past the visible area.\n\nScroll the page to see Forma\'s edge-fade/reveal behavior.\n\nThe same treatment is used for scrolling dropdown rows.', true)

-- Tabboxes are used the same way as in Linoria: create the box, then add tabs.
local TabBox = Tabs.Main:AddRightTabbox()

local Tab1 = TabBox:AddTab('Tab 1')
Tab1:AddToggle('Tab1Toggle', { Text = 'Tab 1 Toggle' })
Tab1:AddSlider('Tab1Slider', { Text = 'Tab 1 Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 })

local Tab2 = TabBox:AddTab('Tab 2')
Tab2:AddToggle('Tab2Toggle', { Text = 'Tab 2 Toggle' })
Tab2:AddDropdown('Tab2Dropdown', { Text = 'Tab 2 Dropdown', Default = 1, Values = { 'One', 'Two', 'Three' } })

-- Dependency boxes can depend on toggles, single dropdowns, or multi-dropdowns.
local RightGroupbox = Tabs.Main:AddRightGroupbox('Dependency boxes')
RightGroupbox:AddToggle('ControlToggle', { Text = 'Dependency box toggle' })

local Depbox = RightGroupbox:AddDependencyBox()
Depbox:AddToggle('DepboxToggle', { Text = 'Sub-dependency box toggle' })
Depbox:AddSlider('DepboxSlider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 })

Depbox:SetupDependencies({
    { Toggles.ControlToggle, true }
})

-- Forma dependency boxes animate their size/fade when visibility changes.
-- They can also be nested.
local SubDepbox = Depbox:AddDependencyBox()
SubDepbox:AddSlider('NestedSlider', { Text = 'Nested slider', Default = 10, Min = 0, Max = 20, Rounding = 0 })
SubDepbox:AddDropdown('NestedDropdown', { Text = 'Nested dropdown', Default = 1, Values = { 'a', 'b', 'c' } })

SubDepbox:SetupDependencies({
    { Toggles.DepboxToggle, true }
})

-- Dropdown dependency example.
RightGroupbox:AddDropdown('DependencyMode', {
    Text = 'Dependency mode',
    Values = { 'Automatic', 'Manual', 'Priority' },
    Default = 1,
})

local DropdownDepbox = RightGroupbox:AddDependencyBox()
DropdownDepbox:AddToggle('ManualOption', { Text = 'Manual / Priority option' })
DropdownDepbox:SetupDependencies({
    { Options.DependencyMode, { 'Manual', 'Priority' } }
})

-- Multi-dropdown dependency example.
local MultiDepbox = RightGroupbox:AddDependencyBox()
MultiDepbox:AddToggle('DistanceOption', { Text = 'Distance is selected' })
MultiDepbox:SetupDependencies({
    { Options.MyMultiDropdown, 'Distance' }
})

-- ============================================================================
-- Forma-specific examples
-- ============================================================================

local FormaLeft = Tabs.Forma:AddLeftGroupbox('Notifications')

-- Library:Notify
-- The old string form is still supported.
FormaLeft:AddButton({
    Text = 'Legacy notification',
    Func = function()
        Library:Notify('Legacy notification form', 3)
    end,
})

-- Titled notifications use a connected moving accent line, smooth width/slide
-- motion, a bottom lifetime bar, and smooth vertical stack reflow.
FormaLeft:AddButton({
    Text = 'Titled notification',
    Func = function()
        Library:Notify({
            Title = 'Forma Notification',
            Text = 'Smooth slide, animated accent gradient, and lifetime progress.',
            Duration = 6,
        })
    end,
})

FormaLeft:AddButton({
    Text = 'Notification stack',
    Func = function()
        for Index = 1, 4 do
            task.delay((Index - 1) * 0.12, function()
                Library:Notify({
                    Title = ('Notification %d'):format(Index),
                    Text = 'Watch the existing notifications move smoothly.',
                    Duration = 3.5 + Index * 0.35,
                })
            end)
        end
    end,
})

FormaLeft:AddInput('NotificationText', {
    Text = 'Notification text',
    Default = 'Custom notification',
    Finished = false,
})

FormaLeft:AddButton({
    Text = 'Send custom notification',
    Func = function()
        Library:Notify({
            Title = 'Custom Notification',
            Text = Options.NotificationText.Value,
            Duration = 4,
        })
    end,
})

local FormaRight = Tabs.Forma:AddRightGroupbox('Animated colorpicker')

FormaRight:AddLabel('Rainbow'):AddColorPicker('RainbowColorPicker', {
    Default = Color3.fromRGB(255, 80, 150),
    Title = 'Rainbow picker',
    Settings = {
        Mode = 'Rainbow',
        Speed = 1,
        Color1 = Color3.fromRGB(255, 80, 150),
        Color2 = Color3.fromRGB(80, 170, 255),
    },
})

FormaRight:AddLabel('Fade'):AddColorPicker('FadeColorPicker', {
    Default = Color3.fromRGB(80, 170, 255),
    Title = 'Fade picker',
    Settings = {
        Mode = 'Fade',
        Speed = 1,
        Color1 = Color3.fromRGB(80, 170, 255),
        Color2 = Color3.fromRGB(190, 70, 255),
    },
})

FormaRight:AddButton({
    Text = 'Set Fade mode',
    Func = function()
        Options.ColorPicker:SetMode('Fade')
    end,
}):AddButton({
    Text = 'Set Rainbow mode',
    Func = function()
        Options.ColorPicker:SetMode('Rainbow')
    end,
})

FormaRight:AddButton({
    Text = 'Set Solid mode',
    Func = function()
        Options.ColorPicker:SetMode('Solid')
    end,
})

-- ============================================================================
-- Target HUD
-- ============================================================================

local TargetHUDManualHealth = 100
local TargetHUDManualMaxHealth = 100
local TargetHUDUseManualHealth = false
local TargetHUDStatusLabel

local TargetHUD = Library:CreateTargetHUD({
    Visible = false,
    Position = UDim2.new(0.5, 285, 0.5, 120),
    AutoTargetMode = 'Off',
    AutoDistanceMeter = false,
    HealthSmoothTime = 0.20,
    HealthGradientSpeed = 1.15,

    HealthProvider = function(Target)
        if TargetHUDUseManualHealth then
            return TargetHUDManualHealth, TargetHUDManualMaxHealth
        end

        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            local Character = Target.Character
            local Humanoid = Character and Character:FindFirstChildOfClass('Humanoid')

            if Humanoid then
                return Humanoid.Health, Humanoid.MaxHealth
            end
        end

        return nil, nil
    end,
})

local HUDLeft = Tabs['Target HUD']:AddLeftGroupbox('Target')

HUDLeft:AddDropdown('TargetPlayer', {
    SpecialType = 'Player',
    Text = 'Target player',
    Searchable = true,
})

Options.TargetPlayer:OnChanged(function()
    local Name = Options.TargetPlayer.Value
    local Player = Name and Players:FindFirstChild(Name)
    TargetHUD:SetTarget(Player)

    if Toggles.ShowTargetHUD and Toggles.ShowTargetHUD.Value and Player then
        TargetHUD:SetVisible(true)
    end
end)

HUDLeft:AddToggle('ShowTargetHUD', {
    Text = 'Show Target HUD',
    Default = false,
})

Toggles.ShowTargetHUD:OnChanged(function()
    local Name = Options.TargetPlayer.Value
    local Player = Name and Players:FindFirstChild(Name)

    if not Player and TargetHUDUseManualHealth then
        Player = Players.LocalPlayer
    end

    if Player then TargetHUD:SetTarget(Player) end
    TargetHUD:SetVisible(Toggles.ShowTargetHUD.Value and Player ~= nil)
end)

HUDLeft:AddButton({
    Text = 'Target local player',
    Func = function()
        TargetHUD:SetTarget(Players.LocalPlayer)
        TargetHUD:SetVisible(true)
        Toggles.ShowTargetHUD:SetValue(true)
    end,
})

HUDLeft:AddDropdown('TargetMode', {
    Text = 'Automatic target mode',
    Values = { 'Off', 'Look', 'Hover', 'LookOrHover' },
    Default = 1,
    Tooltip = {
        Title = 'Automatic targeting',
        Text = {
            'Look uses the center camera ray.',
            'Hover uses the player under the mouse.',
            'LookOrHover accepts either.',
        },
    },
})

Options.TargetMode:OnChanged(function()
    TargetHUD:SetAutoTargetMode(Options.TargetMode.Value)
end)

HUDLeft:AddToggle('AutoDistance', {
    Text = 'Automatic distance meter',
    Default = false,
})

Toggles.AutoDistance:OnChanged(function()
    TargetHUD:SetAutoDistanceMeter(Toggles.AutoDistance.Value)
end)

local HUDRight = Tabs['Target HUD']:AddRightGroupbox('Health / labels')

-- The health bar uses a continuously damped follower instead of restarting a
-- tween whenever health changes. Rapidly press Damage/Heal to test it.
HUDRight:AddToggle('ManualHealth', {
    Text = 'Override target health',
    Default = false,
})

Toggles.ManualHealth:OnChanged(function()
    TargetHUDUseManualHealth = Toggles.ManualHealth.Value

    if TargetHUDUseManualHealth then
        if not TargetHUD.Target then TargetHUD:SetTarget(Players.LocalPlayer) end
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        TargetHUD:SetVisible(true)
        Toggles.ShowTargetHUD:SetValue(true)
    else
        TargetHUD:Refresh()
    end
end)

HUDRight:AddSlider('TargetHealth', {
    Text = 'Displayed health',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = ' HP',
})

Options.TargetHealth:OnChanged(function()
    TargetHUDManualHealth = Options.TargetHealth.Value

    if TargetHUDUseManualHealth then
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
    end
end)

HUDRight:AddButton({
    Text = 'Damage -25 HP',
    Func = function()
        Options.TargetHealth:SetValue(math.max(0, Options.TargetHealth.Value - 25))
    end,
}):AddButton({
    Text = 'Heal +25 HP',
    Func = function()
        Options.TargetHealth:SetValue(math.min(100, Options.TargetHealth.Value + 25))
    end,
})

HUDRight:AddInput('TargetMeter', {
    Text = 'Custom meter text',
    Default = '',
    Finished = false,
    Placeholder = '42 meters',
})

Options.TargetMeter:OnChanged(function()
    local Value = Options.TargetMeter.Value
    TargetHUD:SetMeter(Value ~= '' and Value or nil)
end)

HUDRight:AddInput('TargetLabel', {
    Text = 'Custom HUD label',
    Default = '',
    Finished = false,
    Placeholder = 'Status text',
})

HUDRight:AddButton({
    Text = 'Apply custom label',
    Func = function()
        local Value = Options.TargetLabel.Value

        if Value == '' then
            if TargetHUDStatusLabel then
                TargetHUDStatusLabel:Destroy()
                TargetHUDStatusLabel = nil
            end
            return
        end

        if TargetHUDStatusLabel then
            TargetHUDStatusLabel:SetValue(Value)
        else
            TargetHUDStatusLabel = TargetHUD:AddLabel('Status', Value, 'StatusLabel')
        end
    end,
}):AddButton({
    Text = 'Remove label',
    Func = function()
        if TargetHUDStatusLabel then
            TargetHUDStatusLabel:Destroy()
            TargetHUDStatusLabel = nil
        end
    end,
})

-- Library functions
-- Sets the watermark visibility.
Library:SetWatermarkVisibility(true)

-- Forma's watermark can show a metadata row in addition to its title/stats line.
Library:SetWatermarkInfo({
    ShowGameName = true,
    ShowUsername = true,
    ShowUserId = true,
    ShowDate = true,
})

-- Example of dynamically updating the watermark with FPS and ping.
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local Ping = 0

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1

    if tick() - FrameTimer >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0

        local Success, Result = pcall(function()
            return Stats.Network.ServerStatsItem['Data Ping']:GetValue()
        end)

        if Success then
            Ping = math.floor(Result)
        end
    end

    Library:SetWatermark(('Forma demo | %d fps | %d ms'):format(FPS, Ping))
end)

-- The keybind list, watermark, main window, and Target HUD use Forma's draggable
-- motion path. Their accent outlines use the shared moving accent treatment.
Library.KeybindFrame.Visible = true

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

-- NoUI hides this bind from the keybind list itself.
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddToggle('ShowKeybindList', {
    Text = 'Show keybind list',
    Default = true,
})

Toggles.ShowKeybindList:OnChanged(function()
    Library.KeybindFrame.Visible = Toggles.ShowKeybindList.Value
end)

MenuGroup:AddToggle('ShowWatermark', {
    Text = 'Show watermark',
    Default = true,
})

Toggles.ShowWatermark:OnChanged(function()
    Library:SetWatermarkVisibility(Toggles.ShowWatermark.Value)
end)

-- Addons:
-- SaveManager provides the config system.
-- ThemeManager provides themes, expanded Forma palette controls, fonts, text size,
-- optional overlays, and the menu animation/easing controls.

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({
    'MenuKeybind',
    'ShowKeybindList',
    'ShowWatermark',
    'ShowTargetHUD',
    'TargetMode',
    'AutoDistance',
    'ManualHealth',
    'TargetHealth',
    'TargetMeter',
    'TargetLabel',
})

ThemeManager:SetFolder('FormaSettings')
SaveManager:SetFolder('FormaSettings')

-- BuildConfigSection creates the normal config controls.
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- ApplyToTab creates the theme manager and, in Forma, also exposes the menu
-- manager's easing style, easing direction, and animation response controls.
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:OnUnload(function()
    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end

    print('Unloaded!')
    Library.Unloaded = true
end)

-- Forma SaveManager also persists colorpicker animation mode, speed, fade endpoints,
-- and solid color for colorpickers that enable Settings.
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = 'Forma',
    Text = 'Example loaded.',
    Duration = 4,
})