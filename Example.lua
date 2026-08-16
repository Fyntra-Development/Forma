--[[
    Forma example script

    This file intentionally reads like a reference implementation rather than a
    minimal demo. It follows the documented/example-first layout used by Linoria,
    while covering the features that are specific to this fork.

    Forma-specific examples in this file include:
      * smooth sliders with nudge buttons and value editing
      * animated text input / caret behavior
      * searchable dropdowns with edge fades
      * dropdown and multi-dropdown dependency boxes
      * animated colorpicker Settings tabs (Solid / Fade / Rainbow)
      * warning confirmation buttons and responsive 2/3-button rows
      * smooth notifications with animated accent/progress bars and stacking
      * the Target HUD, automatic targeting, and smoothed health updates
      * watermark metadata, moving accent gradients, fonts, overlays, themes,
        save configs, and configurable menu motion/easing
]]

local repo = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/'

local function LoadFormaModule(path)
    local source = game:HttpGet(repo .. path)
    local chunk, compileError = loadstring(source)

    assert(chunk, ('Forma failed to compile %s:\n%s'):format(path, tostring(compileError)))
    return chunk()
end

local Library = LoadFormaModule('Library.lua')
local ThemeManager = LoadFormaModule('addons/ThemeManager.lua')
local SaveManager = LoadFormaModule('addons/SaveManager.lua')

local Toggles = getgenv().Toggles
local Options = getgenv().Options

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Stats = game:GetService('Stats')

Library.NotifyOnError = true

-- Library:CreateWindow
--
-- Forma keeps Linoria's normal window API while adding coordinated menu motion,
-- resize handles, moving accent outlines, smooth dragging, and game-name metadata.
local Window = Library:CreateWindow({
    Title = 'Forma Example',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

-- CALLBACK NOTE:
-- You can pass Callback functions directly into controls, but it is usually cleaner
-- to build the interface first and bind behavior with :OnChanged afterwards.
-- This example uses both forms so the API is easy to reference.

local Tabs = {
    Main = Window:AddTab('Controls'),
    Players = Window:AddTab('Players'),
    Visuals = Window:AddTab('Visuals'),
    Tools = Window:AddTab('Tools'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

--[[
    TARGET HUD SETUP

    Forma adds a standalone draggable Target HUD. It can use a Player directly,
    automatically acquire targets from the camera/mouse, accept custom health
    providers, display custom meter text, and host additional labels.
]]
local TargetHUDManualHealth = 100
local TargetHUDManualMaxHealth = 100
local TargetHUDUseManualHealth = false
local TargetHUDStatusLabel

local TargetHUD = Library:CreateTargetHUD({
    Visible = false,
    Position = UDim2.new(0.5, 285, 0.5, 120),

    AutoTargetMode = 'Off',
    AutoDistanceMeter = false,

    -- Rapid health changes follow this value smoothly instead of restarting a tween.
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

-- ============================================================================
-- Controls tab
-- ============================================================================

local ControlsLeft = Tabs.Main:AddLeftGroupbox('Basic controls')

-- Groupbox:AddToggle
-- Arguments: Index, Info
--
-- Info fields demonstrated here: Text, Default, Tooltip, Callback.
ControlsLeft:AddToggle('Enabled', {
    Text = 'Enable example feature',
    Default = false,
    Tooltip = 'Master toggle used by several examples below.',
    Callback = function(Value)
        print('[callback] Enabled:', Value)
    end,
})

Toggles.Enabled:OnChanged(function()
    print('Enabled changed:', Toggles.Enabled.Value)
end)

-- Toggle:AddKeyPicker
--
-- Forma supports Always, Toggle, and Hold modes on toggle-attached keybinds.
-- SyncToggleState keeps the parent toggle and the keybind state synchronized.
local AutoSprintToggle = ControlsLeft:AddToggle('AutoSprint', {
    Text = 'Auto sprint',
    Default = false,
    Tooltip = 'Example toggle with a synced keybind.',
})

AutoSprintToggle:AddKeyPicker('AutoSprintKey', {
    Default = 'F',
    SyncToggleState = true,
    Mode = 'Toggle',
    Modes = { 'Always', 'Toggle', 'Hold' },
    Text = 'Auto sprint',
    NoUI = false,

    Callback = function(Value)
        print('[callback] Auto sprint key state:', Value)
    end,

    ChangedCallback = function(NewKey)
        print('[callback] Auto sprint key changed:', NewKey)
    end,
})

ControlsLeft:AddDivider()

-- Groupbox:AddButton
--
-- Forma supports responsive secondary/tertiary button rows. Warning buttons can
-- require confirmation and display a countdown before the action is accepted.
local ActionButton = ControlsLeft:AddButton({
    Text = 'Start',
    Func = function()
        Library:Notify({ Title = 'Controls', Text = 'Started.', Duration = 2.5 })
    end,
    Tooltip = 'Primary button in a three-button row.',
})

local PauseButton = ActionButton:AddButton({
    Text = 'Pause',
    Func = function()
        Library:Notify({ Title = 'Controls', Text = 'Paused.', Duration = 2.5 })
    end,
})

PauseButton:AddTertiaryButton({
    Text = 'Stop',
    Func = function()
        Library:Notify({ Title = 'Controls', Text = 'Stopped.', Duration = 2.5 })
    end,
})

ControlsLeft:AddButton({
    Text = 'Reset values',
    Warning = true,
    ConfirmDuration = 3,
    Tooltip = 'Click again before the countdown ends to confirm.',
    Func = function()
        Options.WalkSpeed:SetValue(16)
        Options.Smoothing:SetValue(0.5)
        Options.CompactVolume:SetValue(50)
        Library:Notify({ Title = 'Controls', Text = 'Values reset.', Duration = 3 })
    end,
})

ControlsLeft:AddDivider()

-- Groupbox:AddSlider
-- Arguments: Index, Info
--
-- Required: Text, Default, Min, Max, Rounding
-- Common extras: Step, Suffix, Compact, Tooltip
--
-- Forma's slider fill, thumb, and value badge smoothly follow pointer input while
-- the logical value/callback remains immediate. +/- nudge controls and numeric
-- value editing use the same slider implementation.
ControlsLeft:AddSlider('WalkSpeed', {
    Text = 'Walk speed',
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = ' studs',
    Callback = function(Value)
        print('[callback] Walk speed:', Value)
    end,
})

ControlsLeft:AddSlider('Smoothing', {
    Text = 'Movement smoothing',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Step = 0.05,
})

ControlsLeft:AddSlider('CompactVolume', {
    Text = 'Volume',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true,
})

Options.WalkSpeed:OnChanged(function()
    print('WalkSpeed changed:', Options.WalkSpeed.Value)
end)

-- Groupbox:AddInput
--
-- Forma adds animated text rendering/caret motion and smooth horizontal scrolling
-- for long input. Numeric, Finished, MaxLength, and Placeholder remain supported.
local ControlsRight = Tabs.Main:AddRightGroupbox('Inputs & selection')

ControlsRight:AddInput('DisplayName', {
    Text = 'Display name',
    Default = 'Player',
    Numeric = false,
    Finished = false,
    Placeholder = 'Enter a display name',
})

ControlsRight:AddInput('RetryLimit', {
    Text = 'Retry limit',
    Default = '10',
    Numeric = true,
    Finished = true,
    Placeholder = 'Enter a number',
})

ControlsRight:AddInput('ProfileTag', {
    Text = 'Profile tag',
    Default = '',
    Numeric = false,
    Finished = false,
    MaxLength = 16,
    Placeholder = 'Up to 16 characters',
})

ControlsRight:AddDivider()

-- Groupbox:AddDropdown
--
-- Searchable = true creates a live search box. Forma also fades rows at the top
-- and bottom of the popup viewport while scrolling.
ControlsRight:AddDropdown('ServerRegion', {
    Text = 'Server region',
    Values = {
        'Automatic',
        'US West',
        'US Central',
        'US East',
        'Europe',
        'Singapore',
        'Japan',
        'Australia',
    },
    Default = 1,
    Multi = false,
    Searchable = true,
    Tooltip = {
        Title = 'Searchable dropdown',
        Text = {
            'Start typing after opening the dropdown to filter its rows.',
            'Scroll-edge text fades are handled automatically.',
        },
    },
})

-- Multi dropdowns return a map of selected values.
ControlsRight:AddDropdown('ESPElements', {
    Text = 'Visible ESP elements',
    Values = { 'ESP', 'Names', 'Boxes', 'Health', 'Distance' },
    Default = { 'ESP', 'Names' },
    Multi = true,
    Searchable = false,
})

Options.ESPElements:OnChanged(function()
    print('Selected ESP elements:')
    for Name, Enabled in pairs(Options.ESPElements.Value) do
        print('  ', Name, Enabled)
    end
end)

ControlsRight:AddDivider()

-- Label:AddColorPicker
--
-- Settings is a Forma extension. When enabled, the colorpicker contains a Color
-- tab and a Settings tab with Solid, Fade, and Rainbow modes.
--
-- Fade exposes Color 1 / Color 2 only when needed. Fade and Rainbow reuse the
-- library's normal slider for speed, animate the real picker cursor/hue rail, and
-- update the actual Value/callback continuously.
ControlsRight:AddLabel('Animated accent'):AddColorPicker('AnimatedAccent', {
    Default = Color3.fromRGB(0, 170, 255),
    Title = 'Animated accent',
    Transparency = 0,

    Settings = {
        Mode = 'Fade',
        Speed = 1.25,
        Color1 = Color3.fromRGB(0, 170, 255),
        Color2 = Color3.fromRGB(190, 70, 255),
    },
})

Options.AnimatedAccent:OnChanged(function(Value)
    print('Animated accent:', Value, 'transparency:', Options.AnimatedAccent.Transparency)
end)

Options.AnimatedAccent:OnModeChanged(function(Mode)
    print('Colorpicker mode:', Mode)
end)

Options.AnimatedAccent:OnSpeedChanged(function(Speed)
    print('Colorpicker speed:', Speed)
end)

ControlsRight:AddLabel('Static color'):AddColorPicker('StaticColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Normal colorpicker',
})

-- Label:AddKeyPicker can also create a standalone keybind.
ControlsRight:AddLabel('Quick action key'):AddKeyPicker('StandaloneKey', {
    Default = 'G',
    SyncToggleState = false,
    Mode = 'Toggle',
    Modes = { 'Always', 'Toggle', 'Hold' },
    Text = 'Quick action',
    NoUI = false,
})

Options.StandaloneKey:OnClick(function()
    print('Standalone key clicked:', Options.StandaloneKey:GetState())
end)

-- Tabboxes inherit the same control methods as normal groupboxes.
local ControlTabbox = Tabs.Main:AddLeftTabbox('Tabbox example')
local RoutingTab = ControlTabbox:AddTab('Routing')
local DisplayTab = ControlTabbox:AddTab('Display')

RoutingTab:AddDropdown('RoutingMode', {
    Text = 'Routing mode',
    Values = { 'Automatic', 'Manual', 'Priority' },
    Default = 1,
})

-- Groupbox:AddDependencyBox
--
-- Forma dependencies can match dropdown values in addition to toggles. A table of
-- dropdown values means "show for any of these" unless All is explicitly requested.
local RoutingDependency = RoutingTab:AddDependencyBox()
RoutingDependency:AddToggle('CustomRoute', { Text = 'Use custom route', Default = false })
RoutingDependency:AddDropdown('RouteEndpoint', {
    Text = 'Route endpoint',
    Values = { 'Nearest', 'Spawn', 'Objective' },
    Default = 1,
})
RoutingDependency:SetupDependencies({
    { Options.RoutingMode, { 'Manual', 'Priority' } },
})

DisplayTab:AddDropdown('StatusDisplay', {
    Text = 'Status display',
    Values = { 'Compact', 'Detailed', 'Minimal' },
    Default = 1,
})

-- Multi-dropdown dependencies are also supported.
local DistanceDependency = ControlsRight:AddDependencyBox()
DistanceDependency:AddToggle('DistanceReadout', {
    Text = 'Show distance readout',
    Default = false,
})
DistanceDependency:SetupDependencies({
    { Options.ESPElements, 'Distance' },
})

-- Nested dependency boxes animate their height/fade instead of popping in/out.
local AdvancedGroup = Tabs.Main:AddRightGroupbox('Nested dependencies')
AdvancedGroup:AddToggle('AdvancedEnabled', {
    Text = 'Enable advanced controls',
    Default = false,
})

local AdvancedDependency = AdvancedGroup:AddDependencyBox()
AdvancedDependency:AddToggle('ReserveEnabled', {
    Text = 'Use stamina reserve',
    Default = false,
})
AdvancedDependency:AddSlider('SprintThreshold', {
    Text = 'Sprint threshold',
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
})
AdvancedDependency:SetupDependencies({
    { Toggles.AdvancedEnabled, true },
})

local NestedDependency = AdvancedDependency:AddDependencyBox()
NestedDependency:AddSlider('StaminaReserve', {
    Text = 'Stamina reserve',
    Default = 10,
    Min = 0,
    Max = 20,
    Rounding = 0,
})
NestedDependency:SetupDependencies({
    { Toggles.ReserveEnabled, true },
})

-- ============================================================================
-- Players / Target HUD tab
-- ============================================================================

local PlayersLeft = Tabs.Players:AddLeftGroupbox('Target selection')

-- SpecialType = 'Player' and 'Team' automatically source live game values.
PlayersLeft:AddDropdown('PlayerDropdown', {
    SpecialType = 'Player',
    Text = 'Target player',
    Searchable = true,
    Tooltip = 'Sets the player displayed by the Target HUD.',
})

PlayersLeft:AddDropdown('TeamDropdown', {
    SpecialType = 'Team',
    Text = 'Team',
})

Options.PlayerDropdown:OnChanged(function(Value)
    local Player = Value and Players:FindFirstChild(Value)
    TargetHUD:SetTarget(Player)

    if TargetHUDUseManualHealth then
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
    end

    if Toggles.ShowTargetHUD and Toggles.ShowTargetHUD.Value and Player then
        TargetHUD:SetVisible(true)
    end
end)

PlayersLeft:AddButton({
    Text = 'Target local player',
    Func = function()
        TargetHUD:SetTarget(Players.LocalPlayer)
        TargetHUD:SetVisible(true)
        Toggles.ShowTargetHUD:SetValue(true)

        if TargetHUDUseManualHealth then
            TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        end
    end,
})

local PlayersRight = Tabs.Players:AddRightGroupbox('Target HUD')

PlayersRight:AddToggle('ShowTargetHUD', {
    Text = 'Show Target HUD',
    Default = false,
})

Toggles.ShowTargetHUD:OnChanged(function()
    local Name = Options.PlayerDropdown.Value
    local Player = Name and Players:FindFirstChild(Name)

    if not Player and TargetHUDUseManualHealth then
        Player = Players.LocalPlayer
    end

    if Player then TargetHUD:SetTarget(Player) end
    TargetHUD:SetVisible(Toggles.ShowTargetHUD.Value and Player ~= nil)
end)

-- Automatic target modes are Off, Look, Hover, and LookOrHover.
PlayersRight:AddDropdown('TargetHUDAutoMode', {
    Text = 'Automatic target mode',
    Values = { 'Off', 'Look', 'Hover', 'LookOrHover' },
    Default = 1,
    Tooltip = {
        Title = 'Automatic targeting',
        Text = {
            'Look uses the center camera ray.',
            'Hover uses the player under the mouse.',
            'LookOrHover accepts either source.',
        },
    },
})

Options.TargetHUDAutoMode:OnChanged(function(Value)
    TargetHUD:SetAutoTargetMode(Value)
end)

PlayersRight:AddToggle('TargetHUDAutoDistance', {
    Text = 'Automatic distance meter',
    Default = false,
})

Toggles.TargetHUDAutoDistance:OnChanged(function()
    TargetHUD:SetAutoDistanceMeter(Toggles.TargetHUDAutoDistance.Value)
end)

PlayersRight:AddDivider()

-- Manual health is useful for seeing the damped health follower without damaging
-- a real Humanoid. Rapidly press Damage/Heal to see that the bar does not restart.
PlayersRight:AddToggle('TargetHUDManualHealth', {
    Text = 'Override target health',
    Default = false,
})

Toggles.TargetHUDManualHealth:OnChanged(function()
    TargetHUDUseManualHealth = Toggles.TargetHUDManualHealth.Value

    if TargetHUDUseManualHealth then
        if not TargetHUD.Target then TargetHUD:SetTarget(Players.LocalPlayer) end
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        TargetHUD:SetVisible(true)
        Toggles.ShowTargetHUD:SetValue(true)
    else
        TargetHUD:Refresh()
    end
end)

PlayersRight:AddSlider('TargetHUDHealth', {
    Text = 'Displayed health',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = ' HP',
})

Options.TargetHUDHealth:OnChanged(function(Value)
    TargetHUDManualHealth = Value
    if TargetHUDUseManualHealth then
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
    end
end)

PlayersRight:AddButton({
    Text = 'Damage -25 HP',
    Func = function()
        Options.TargetHUDHealth:SetValue(math.max(0, Options.TargetHUDHealth.Value - 25))
    end,
}):AddButton({
    Text = 'Heal +25 HP',
    Func = function()
        Options.TargetHUDHealth:SetValue(math.min(100, Options.TargetHUDHealth.Value + 25))
    end,
})

PlayersRight:AddInput('TargetHUDMeter', {
    Text = 'Custom meter text',
    Default = '',
    Finished = false,
    Placeholder = '42 meters',
})

Options.TargetHUDMeter:OnChanged(function(Value)
    TargetHUD:SetMeter(Value ~= '' and Value or nil)
end)

PlayersRight:AddInput('TargetHUDStatus', {
    Text = 'Custom HUD label',
    Default = '',
    Finished = false,
    Placeholder = 'Status text',
})

PlayersRight:AddButton({
    Text = 'Apply custom label',
    Func = function()
        local Value = Options.TargetHUDStatus.Value

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

PlayersRight:AddButton({
    Text = 'Refresh HUD',
    Func = function()
        TargetHUD:Refresh()
    end,
}):AddButton({
    Text = 'Clear HUD',
    Func = function()
        TargetHUD:SetAutoTargetMode('Off')
        Options.TargetHUDAutoMode:SetValue('Off')
        TargetHUD:SetTarget(nil)
        TargetHUD:SetVisible(false)
        Toggles.ShowTargetHUD:SetValue(false)
    end,
})

-- ============================================================================
-- Visuals tab
-- ============================================================================

local VisualsLeft = Tabs.Visuals:AddLeftGroupbox('ESP example')

local ESPToggle = VisualsLeft:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
})

ESPToggle:AddKeyPicker('ESPKey', {
    Default = 'V',
    SyncToggleState = true,
    Mode = 'Toggle',
    Modes = { 'Always', 'Toggle', 'Hold' },
    Text = 'ESP',
})

VisualsLeft:AddToggle('ESPBoxes', { Text = 'Boxes', Default = true })
VisualsLeft:AddToggle('ESPNames', { Text = 'Names', Default = true })
VisualsLeft:AddToggle('ESPHealth', { Text = 'Health', Default = true })
VisualsLeft:AddToggle('ESPDistance', { Text = 'Distance', Default = false })

VisualsLeft:AddSlider('ESPMaxDistance', {
    Text = 'Maximum distance',
    Default = 1000,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Suffix = ' studs',
})

VisualsLeft:AddLabel('ESP color'):AddColorPicker('ESPColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'ESP color',
})

local VisualsRight = Tabs.Visuals:AddRightGroupbox('Color animation')

-- A second animated picker makes the new color modes easy to test without touching
-- the UI theme itself. Its top accent and tab indicator use the same moving gradient
-- as Forma notifications.
VisualsRight:AddLabel('World tint'):AddColorPicker('WorldTint', {
    Default = Color3.fromRGB(95, 135, 255),
    Title = 'World tint',
    Settings = {
        Mode = 'Rainbow',
        Speed = 0.8,
        Color1 = Color3.fromRGB(95, 135, 255),
        Color2 = Color3.fromRGB(255, 80, 155),
    },
})

VisualsRight:AddToggle('CustomFOV', {
    Text = 'Custom FOV',
    Default = false,
})

VisualsRight:AddSlider('FOVValue', {
    Text = 'Field of view',
    Default = 70,
    Min = 40,
    Max = 120,
    Rounding = 0,
})

local FOVDependency = VisualsRight:AddDependencyBox()
FOVDependency:AddSlider('FOVResponse', {
    Text = 'FOV response',
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Step = 0.05,
    Suffix = 's',
})
FOVDependency:SetupDependencies({
    { Toggles.CustomFOV, true },
})

-- ============================================================================
-- Tools tab
-- ============================================================================

local ToolsLeft = Tabs.Tools:AddLeftGroupbox('Notifications')

-- Library:Notify
--
-- Legacy string form is still supported.
ToolsLeft:AddButton({
    Text = 'Legacy notification',
    Func = function()
        Library:Notify('Legacy notification form', 3)
    end,
})

-- Titled notifications have a moving accent line and a bottom progress/time bar.
-- Entry/exit motion, width reveal, progress, and vertical stack reflow are all smooth.
ToolsLeft:AddButton({
    Text = 'Titled notification',
    Func = function()
        Library:Notify({
            Title = 'Forma Notification',
            Text = 'Accent gradient, lifetime bar, smooth slide, and stack motion.',
            Duration = 6,
        })
    end,
})

ToolsLeft:AddButton({
    Text = 'Notification stack',
    Func = function()
        for Index = 1, 4 do
            task.delay((Index - 1) * 0.12, function()
                Library:Notify({
                    Title = ('Notification %d'):format(Index),
                    Text = 'Watch existing notifications move smoothly in the stack.',
                    Duration = 3.5 + (Index * 0.35),
                })
            end)
        end
    end,
})

ToolsLeft:AddInput('CustomNotification', {
    Text = 'Notification text',
    Default = 'Custom notification',
    Finished = false,
})

ToolsLeft:AddButton({
    Text = 'Send custom notification',
    Func = function()
        Library:Notify({
            Title = 'Custom Notification',
            Text = Options.CustomNotification.Value,
            Duration = 4,
        })
    end,
})

local ToolsRight = Tabs.Tools:AddRightGroupbox('Runtime')

ToolsRight:AddToggle('PrintRuntimeValues', {
    Text = 'Print values every second',
    Default = false,
})

ToolsRight:AddButton({
    Text = 'Print current values',
    Func = function()
        print('Enabled:', Toggles.Enabled.Value)
        print('WalkSpeed:', Options.WalkSpeed.Value)
        print('ServerRegion:', Options.ServerRegion.Value)
        print('Color mode:', Options.AnimatedAccent.Mode)
        print('Color speed:', Options.AnimatedAccent.Speed)
        print('Player:', Options.PlayerDropdown.Value)
        print('Target HUD health:', Options.TargetHUDHealth.Value)
        print('ESP:', Toggles.ESPEnabled.Value)
    end,
})

local UtilityTabbox = Tabs.Tools:AddRightTabbox('Utility tabbox')
local SessionTab = UtilityTabbox:AddTab('Session')
local NetworkTab = UtilityTabbox:AddTab('Network')

SessionTab:AddToggle('AutoReconnect', {
    Text = 'Auto reconnect',
    Default = true,
})

SessionTab:AddInput('SessionNote', {
    Text = 'Session note',
    Default = '',
    Finished = false,
    Placeholder = 'Add a note',
})

NetworkTab:AddDropdown('PreferredRegion', {
    Text = 'Preferred region',
    Values = { 'Automatic', 'US West', 'US East', 'Europe', 'Asia' },
    Default = 1,
    Searchable = true,
})

NetworkTab:AddSlider('RetryDelay', {
    Text = 'Retry delay',
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = ' sec',
})

-- ============================================================================
-- Watermark / keybind HUD
-- ============================================================================

-- Forma's watermark separates the accent title from normal-color stats and adds a
-- metadata row for game name, username, user id, and date.
Library:SetWatermarkInfo({
    ShowGameName = true,
    ShowUsername = true,
    ShowUserId = true,
    ShowDate = true,
})

Library:SetWatermarkVisibility(true)
Library:SetWatermark('Forma - Loading...')

-- The keybind list and watermark are draggable and use the same moving accent
-- treatment as the main window / Target HUD.
Library.KeybindFrame.Visible = true

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local Ping = 0

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1

    if tick() - FrameTimer >= 1 then
        FPS = FrameCounter
        FrameCounter = 0
        FrameTimer = tick()

        local Success, Result = pcall(function()
            return Stats.Network.ServerStatsItem['Data Ping']:GetValue()
        end)

        if Success then Ping = math.floor(Result) end
    end

    Library:SetWatermark(('Forma - %d FPS | %d ms'):format(FPS, Ping))
end)

local RuntimeThreadRunning = true

task.spawn(function()
    while RuntimeThreadRunning do
        task.wait(1)

        if Toggles.PrintRuntimeValues.Value then
            print('WalkSpeed:', Options.WalkSpeed.Value)
            print('Region:', Options.ServerRegion.Value)
            print('Standalone key:', Options.StandaloneKey:GetState())
            print('Animated color mode:', Options.AnimatedAccent.Mode)
        end
    end
end)

-- ============================================================================
-- UI Settings / addons
-- ============================================================================

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Unload',
    Warning = true,
    ConfirmDuration = 3,
    Func = function()
        Library:Unload()
    end,
})

MenuGroup:AddLabel('Menu key'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu key',
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

MenuGroup:AddButton({
    Text = 'Show feature notification',
    Func = function()
        Library:Notify({
            Title = 'Forma',
            Text = 'Themes, fonts, overlays, configs, and motion settings are active.',
            Duration = 4,
        })
    end,
})

-- ThemeManager
--
-- Forma's ThemeManager exposes the expanded palette (including BlendShade,
-- inactive text, contrast, and inline colors), custom/built-in themes, repo fonts,
-- text size, optional character overlays, and persisted UI preferences.
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('FormaSettings')

-- ApplyToTab builds the Theme section. Forma also attaches its MenuManager here,
-- exposing easing style/direction and global animation response controls.
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- SaveManager
--
-- Colorpicker animation settings (mode, speed, Fade endpoints, solid color) are
-- persisted by Forma's SaveManager in addition to the normal Linoria values.
SaveManager:SetLibrary(Library)
SaveManager:SetFolder('FormaSettings')
SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({
    'MenuKeybind',
    'ShowKeybindList',
    'ShowWatermark',
    'ShowTargetHUD',
    'TargetHUDAutoMode',
    'TargetHUDAutoDistance',
    'TargetHUDManualHealth',
    'TargetHUDHealth',
    'TargetHUDMeter',
    'TargetHUDStatus',
})

SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Library:OnUnload
Library:OnUnload(function()
    RuntimeThreadRunning = false

    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end

    print('Forma unloaded')
end)

SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = 'Forma',
    Text = 'Example loaded. Open each tab to explore the fork-specific features.',
    Duration = 5,
})
