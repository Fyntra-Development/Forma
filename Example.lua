local Repository = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/"

local function LoadFormaModule(Path)
    local Source = game:HttpGet(Repository .. Path)
    local Chunk, CompileError = loadstring(Source)

    assert(
        Chunk,
        ("Forma failed to compile %s:\n%s"):format(
            Path,
            tostring(CompileError)
        )
    )

    return Chunk()
end

local Library = LoadFormaModule("Library.lua")
local ThemeManager = LoadFormaModule("addons/ThemeManager.lua")
local SaveManager = LoadFormaModule("addons/SaveManager.lua")

local Toggles = getgenv().Toggles
local Options = getgenv().Options

local Players = game:GetService("Players")

Library.NotifyOnError = true

local Window = Library:CreateWindow({
    Title = "Forma",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Main = Window:AddTab("Controls"),
    Players = Window:AddTab("Players"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Tools"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local TargetHUDManualHealth = 100
local TargetHUDManualMaxHealth = 100
local TargetHUDUseManualHealth = false
local TargetHUDStatusLabel

local TargetHUD = Library:CreateTargetHUD({
    Visible = false,
    Position = UDim2.new(0.5, 285, 0.5, 120),

    AutoTargetMode = "Off",
    AutoDistanceMeter = false,

    HealthSmoothTime = 0.20,
    HealthGradientSpeed = 1.15,

    HealthProvider = function(Target)
        if TargetHUDUseManualHealth then
            return TargetHUDManualHealth, TargetHUDManualMaxHealth
        end

        if typeof(Target) == "Instance" and Target:IsA("Player") then
            local Character = Target.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                return Humanoid.Health, Humanoid.MaxHealth
            end
        end

        return nil, nil
    end,
})


local MainLeft = Tabs.Main:AddLeftGroupbox("Movement")

MainLeft:AddToggle("Enabled", {
    Text = "Enable movement controls",
    Default = false,
    Tooltip = "Enables the movement settings below.",
    Callback = function(Value)
        print("Movement controls:", Value)
    end,
})

Toggles.Enabled:OnChanged(function()
    print("Movement controls changed:", Toggles.Enabled.Value)
end)

local AutoSprintToggle = MainLeft:AddToggle("AutoSprint", {
    Text = "Auto sprint",
    Default = false,
    Tooltip = "Toggles sprint automatically while moving.",
})

AutoSprintToggle:AddKeyPicker("AutoSprintKey", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto sprint",
    NoUI = false,
    Callback = function(Value)
        print("Auto sprint key state:", Value)
    end,
    ChangedCallback = function(NewKey)
        print("Auto sprint key changed:", NewKey)
    end,
})

Toggles.AutoSprint:OnChanged(function()
    print("Auto sprint:", Toggles.AutoSprint.Value)
end)

MainLeft:AddDivider()

MainLeft:AddLabel("Movement profile")

MainLeft:AddLabel(
    "Adjust speed, smoothing, and hotkeys for the active movement profile.",
    true
)

MainLeft:AddButton({
    Text = "Save movement profile",
    Func = function()
        Library:Notify({
            Title = "Movement",
            Text = "Profile saved.",
            Duration = 4,
        })
    end,
    Tooltip = "Saves the current movement values.",
})

MainLeft:AddButton({
    Text = "Reset movement profile",
    Func = function()
        Options.WalkSpeed:SetValue(16)
        Options.DecimalSlider:SetValue(0.5)
        Options.CompactSlider:SetValue(50)
        Library:Notify({
            Title = "Movement",
            Text = "Profile reset.",
            Duration = 3,
        })
    end,
    Warning = true,
    ConfirmDuration = 3,
    Tooltip = "Restores the default movement values.",
})

local MainButton = MainLeft:AddButton({
    Text = "Start",
    Func = function()
        print("Movement started")
    end,
})

local SecondaryButton = MainButton:AddButton({
    Text = "Pause",
    Func = function()
        print("Movement paused")
    end,
})

SecondaryButton:AddTertiaryButton({
    Text = "Stop",
    Func = function()
        print("Movement stopped")
    end,
})

local ProfileButtonRow = MainLeft:AddButton({
    Text = "Save preset",
    Func = function()
        Library:Notify({ Title = "Presets", Text = "Preset saved.", Duration = 3 })
    end,
})

ProfileButtonRow:AddButton({
    Text = "Load preset",
    Func = function()
        Library:Notify({ Title = "Presets", Text = "Preset loaded.", Duration = 3 })
    end,
})

MainLeft:AddDivider()

MainLeft:AddSlider("WalkSpeed", {
    Text = "Walk speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        print("Slider callback:", Value)
    end,
})

Options.WalkSpeed:OnChanged(function()
    print("Walk speed changed:", Options.WalkSpeed.Value)
end)

MainLeft:AddSlider("DecimalSlider", {
    Text = "Movement smoothing",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        print("Decimal:", Value)
    end,
})

MainLeft:AddSlider("CompactSlider", {
    Text = "Movement volume",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true,
})

local ControlTabs = Tabs.Main:AddLeftTabbox("Control modes")
local RoutingTab = ControlTabs:AddTab("Routing")
local DisplayTab = ControlTabs:AddTab("Display")

RoutingTab:AddDropdown("RoutingMode", {
    Text = "Routing mode",
    Values = { "Automatic", "Manual", "Priority" },
    Default = 1,
})

local RoutingModeDependency = RoutingTab:AddDependencyBox()

RoutingModeDependency:AddToggle("CustomRoute", {
    Text = "Use custom route",
    Default = false,
})

RoutingModeDependency:AddDropdown("RouteEndpoint", {
    Text = "Route endpoint",
    Values = { "Nearest", "Spawn", "Objective" },
    Default = 1,
})

RoutingModeDependency:SetupDependencies({
    {
        Options.RoutingMode,
        { "Manual", "Priority" },
    },
})

DisplayTab:AddDropdown("StatusDisplay", {
    Text = "Status display",
    Values = { "Compact", "Detailed", "Minimal" },
    Default = 1,
})

local MainRight = Tabs.Main:AddRightGroupbox("Profile")

MainRight:AddInput("TextInput", {
    Text = "Display name",
    Default = "Player",
    Numeric = false,
    Finished = false,
    Placeholder = "Enter a display name",
    Callback = function(Value)
        print("Text input:", Value)
    end,
})

Options.TextInput:OnChanged(function()
    print("TextInput changed:", Options.TextInput.Value)
end)

MainRight:AddInput("NumericInput", {
    Text = "Retry limit",
    Default = "10",
    Numeric = true,
    Finished = true,
    Placeholder = "Enter a number",
    Callback = function(Value)
        print("Numeric input:", Value)
    end,
})

MainRight:AddInput("LimitedInput", {
    Text = "Profile tag",
    Default = "",
    Numeric = false,
    Finished = false,
    MaxLength = 16,
    Placeholder = "Up to 16 characters",
})

MainRight:AddDivider()

MainRight:AddDropdown("ServerRegion", {
    Text = "Server region",
    Values = {
        "Automatic",
        "US West",
        "US Central",
        "US East",
        "Europe",
        "Singapore",
        "Japan",
        "Australia",
    },
    Default = 1,
    Multi = false,
    Searchable = true,
    Tooltip = {
        Title = "Server region",
        Text = {
            "Filters the region list while you type.",
            "Automatic selects the lowest available latency.",
        },
    },
    Callback = function(Value)
        print("Dropdown:", Value)
    end,
})

Options.ServerRegion:OnChanged(function()
    print("Server region changed:", Options.ServerRegion.Value)
end)

local RegionDependency = MainRight:AddDependencyBox()

RegionDependency:AddToggle("RegionalRouting", {
    Text = "Use regional routing",
    Default = false,
})

RegionDependency:SetupDependencies({
    {
        Options.ServerRegion,
        { "US West", "US East" },
    },
})

MainRight:AddDropdown("MultiDropdown", {
    Text = "Visible ESP elements",
    Values = {
        "ESP",
        "Names",
        "Boxes",
        "Health",
        "Distance",
    },
    Default = {
        "ESP",
        "Names",
    },
    Multi = true,
    Searchable = false,
    Callback = function(Value)
        print("Multi dropdown changed")

        for Name, Enabled in pairs(Value) do
            print(Name, Enabled)
        end
    end,
})

local DistanceDependency = MainRight:AddDependencyBox()

DistanceDependency:AddToggle("ESPDistanceReadout", {
    Text = "Show distance readout",
    Default = false,
})

DistanceDependency:SetupDependencies({
    {
        Options.MultiDropdown,
        "Distance",
    },
})

local ColorLabel = MainRight:AddLabel("Accent preview")

ColorLabel:AddColorPicker("AccentPreview", {
    Default = Color3.fromRGB(0, 170, 255),
    Title = "Accent preview",
    Transparency = 0,
    Callback = function(Value)
        print("Color:", Value)
    end,
})

Options.AccentPreview:OnChanged(function()
    print(
        "Color changed:",
        Options.AccentPreview.Value,
        Options.AccentPreview.Transparency
    )
end)

local KeyLabel = MainRight:AddLabel("Quick action key")

KeyLabel:AddKeyPicker("StandaloneKey", {
    Default = "G",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Quick action",
    NoUI = false,
    Callback = function(Value)
        print("Standalone key state:", Value)
    end,
    ChangedCallback = function(New)
        print("Standalone key changed:", New)
    end,
})

Options.StandaloneKey:OnClick(function()
    print("Standalone key clicked:", Options.StandaloneKey:GetState())
end)

local DependencyGroup = Tabs.Main:AddRightGroupbox("Advanced movement")

DependencyGroup:AddToggle("DependencyMaster", {
    Text = "Enable advanced movement",
    Default = false,
})

local DependencyBox = DependencyGroup:AddDependencyBox()

DependencyBox:AddToggle("DependentToggle", {
    Text = "Use sprint threshold",
    Default = false,
})

DependencyBox:AddSlider("DependentSlider", {
    Text = "Sprint threshold",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
})

DependencyBox:AddDropdown("DependentDropdown", {
    Text = "Sprint mode",
    Values = {
        "Hold",
        "Toggle",
        "Always",
    },
    Default = 1,
})

DependencyBox:SetupDependencies({
    {
        Toggles.DependencyMaster,
        true,
    },
})

local NestedDependency = DependencyBox:AddDependencyBox()

NestedDependency:AddToggle("NestedToggle", {
    Text = "Use stamina reserve",
    Default = false,
})

NestedDependency:AddSlider("NestedSlider", {
    Text = "Stamina reserve",
    Default = 10,
    Min = 0,
    Max = 20,
    Rounding = 0,
})

NestedDependency:SetupDependencies({
    {
        Toggles.DependentToggle,
        true,
    },
})

local PlayersLeft = Tabs.Players:AddLeftGroupbox("Players")

PlayersLeft:AddDropdown("PlayerDropdown", {
    SpecialType = "Player",
    Text = "Target player",
    Tooltip = "Sets the player shown in the Target HUD.",
    Searchable = true,
    Callback = function(Value)
        print("Selected player:", Value)

        local Player = Value and Players:FindFirstChild(Value)
        TargetHUD:SetTarget(Player)

        if TargetHUDUseManualHealth then
            TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        end

        if Toggles.TrackPlayer and Toggles.TrackPlayer.Value and Player then
            TargetHUD:SetVisible(true)
        end
    end,
})

PlayersLeft:AddDropdown("TeamDropdown", {
    SpecialType = "Team",
    Text = "Team",
    Callback = function(Value)
        print("Selected team:", Value)
    end,
})

PlayersLeft:AddButton({
    Text = "Print target player",
    Func = function()
        print("Current player:", Options.PlayerDropdown.Value)
    end,
})

PlayersLeft:AddButton({
    Text = "Print selected team",
    Func = function()
        print("Current team:", Options.TeamDropdown.Value)
    end,
})

local PlayersRight = Tabs.Players:AddRightGroupbox("Target HUD")

PlayersRight:AddToggle("TrackPlayer", {
    Text = "Show Target HUD",
    Default = false,
    Tooltip = {
        Title = "Target HUD",
        Text = {
            "Shows the selected target avatar and username.",
            "Updates health, distance, meter text, and automatic targeting.",
        },
    },
})

Toggles.TrackPlayer:OnChanged(function()
    local SelectedName = Options.PlayerDropdown.Value
    local Player = SelectedName and Players:FindFirstChild(SelectedName)

    if not Player and TargetHUDUseManualHealth then
        Player = Players.LocalPlayer
    end

    if Player then
        TargetHUD:SetTarget(Player)
    end

    TargetHUD:SetVisible(Toggles.TrackPlayer.Value and Player ~= nil)
end)

PlayersRight:AddButton({
    Text = "Target local player",
    Func = function()
        TargetHUD:SetTarget(Players.LocalPlayer)
        TargetHUD:SetVisible(true)
        Toggles.TrackPlayer:SetValue(true)

        if TargetHUDUseManualHealth then
            TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        end
    end,
    Tooltip = "Uses your own player as the current target.",
})

PlayersRight:AddDropdown("TargetHUDAutoMode", {
    Text = "Automatic target mode",
    Values = {
        "Off",
        "Look",
        "Hover",
        "LookOrHover",
    },
    Default = 1,
    Multi = false,
    Tooltip = {
        Title = "Automatic targeting",
        Text = {
            "Look targets the player under the center camera ray.",
            "Hover targets the player under the mouse.",
            "LookOrHover accepts either.",
        },
    },
})

Options.TargetHUDAutoMode:OnChanged(function()
    TargetHUD:SetAutoTargetMode(Options.TargetHUDAutoMode.Value)
end)

PlayersRight:AddToggle("TargetHUDAutoDistance", {
    Text = "Automatic distance meter",
    Default = false,
    Tooltip = "Shows the selected target distance in studs when there is no custom meter override.",
})

Toggles.TargetHUDAutoDistance:OnChanged(function()
    TargetHUD:SetAutoDistanceMeter(Toggles.TargetHUDAutoDistance.Value)
end)

PlayersRight:AddDivider()

PlayersRight:AddToggle("TargetHUDManualHealth", {
    Text = "Override target health",
    Default = false,
    Tooltip = "Overrides the displayed target health without changing the player's real Humanoid health.",
})

Toggles.TargetHUDManualHealth:OnChanged(function()
    TargetHUDUseManualHealth = Toggles.TargetHUDManualHealth.Value

    if TargetHUDUseManualHealth then
        if not TargetHUD.Target then
            TargetHUD:SetTarget(Players.LocalPlayer)
        end

        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
        TargetHUD:SetVisible(true)
        Toggles.TrackPlayer:SetValue(true)
    else
        TargetHUD:Refresh()
    end
end)

PlayersRight:AddSlider("TargetHUDHealth", {
    Text = "Displayed health",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = " HP",
    Tooltip = "Sets the health value shown while the manual override is active.",
})

Options.TargetHUDHealth:OnChanged(function()
    TargetHUDManualHealth = Options.TargetHUDHealth.Value

    if TargetHUDUseManualHealth then
        TargetHUD:SetHealth(TargetHUDManualHealth, TargetHUDManualMaxHealth, false)
    end
end)

PlayersRight:AddButton({
    Text = "Damage -25 HP",
    Func = function()
        Options.TargetHUDHealth:SetValue(
            math.max(0, Options.TargetHUDHealth.Value - 25)
        )
    end,
}):AddButton({
    Text = "Heal +25 HP",
    Func = function()
        Options.TargetHUDHealth:SetValue(
            math.min(100, Options.TargetHUDHealth.Value + 25)
        )
    end,
})

PlayersRight:AddDivider()

PlayersRight:AddInput("TargetHUDMeterOverride", {
    Text = "Custom meter override",
    Default = "",
    Numeric = false,
    Finished = false,
    Placeholder = "42 meters",
})

Options.TargetHUDMeterOverride:OnChanged(function()
    local Value = Options.TargetHUDMeterOverride.Value
    TargetHUD:SetMeter(Value ~= "" and Value or nil)
end)

PlayersRight:AddInput("TargetHUDCustomLabel", {
    Text = "Custom HUD label",
    Default = "",
    Numeric = false,
    Finished = false,
    Placeholder = "Status text",
})

PlayersRight:AddButton({
    Text = "Apply custom label",
    Func = function()
        local Value = Options.TargetHUDCustomLabel.Value

        if Value == "" then
            if TargetHUDStatusLabel then
                TargetHUDStatusLabel:Destroy()
                TargetHUDStatusLabel = nil
            end
            return
        end

        if TargetHUDStatusLabel then
            TargetHUDStatusLabel:SetValue(Value)
        else
            TargetHUDStatusLabel = TargetHUD:AddLabel(
                "Status",
                Value,
                "StatusLabel"
            )
        end
    end,
}):AddButton({
    Text = "Remove custom label",
    Func = function()
        if TargetHUDStatusLabel then
            TargetHUDStatusLabel:Destroy()
            TargetHUDStatusLabel = nil
        end
    end,
})

PlayersRight:AddDivider()

PlayersRight:AddButton({
    Text = "Refresh Target HUD",
    Func = function()
        TargetHUD:Refresh()
    end,
}):AddButton({
    Text = "Clear Target HUD",
    Func = function()
        TargetHUD:SetAutoTargetMode("Off")
        Options.TargetHUDAutoMode:SetValue("Off")
        TargetHUD:SetTarget(nil)
        TargetHUD:SetVisible(false)
        Toggles.TrackPlayer:SetValue(false)
    end,
})


local VisualsLeft = Tabs.Visuals:AddLeftGroupbox("ESP")

local ESPToggle = VisualsLeft:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
})

ESPToggle:AddKeyPicker("ESPKey", {
    Default = "V",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "ESP",
})

VisualsLeft:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = true,
})

VisualsLeft:AddToggle("ESPNames", {
    Text = "Names",
    Default = true,
})

VisualsLeft:AddToggle("ESPHealth", {
    Text = "Health",
    Default = true,
})

VisualsLeft:AddToggle("ESPDistance", {
    Text = "Distance",
    Default = false,
})

VisualsLeft:AddToggle("ESPTeamCheck", {
    Text = "Team check",
    Default = true,
})

VisualsLeft:AddSlider("ESPMaxDistance", {
    Text = "Maximum distance",
    Default = 1000,
    Min = 50,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
})

VisualsLeft:AddLabel("ESP color"):AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "ESP color",
})

VisualsLeft:AddLabel("Visible color"):AddColorPicker("ESPVisibleColor", {
    Default = Color3.fromRGB(0, 255, 100),
    Title = "Visible ESP color",
})

local VisualsRight = Tabs.Visuals:AddRightGroupbox("World")

VisualsRight:AddToggle("CustomAmbient", {
    Text = "Custom ambient",
    Default = false,
})

VisualsRight:AddLabel("Ambient"):AddColorPicker("AmbientColor", {
    Default = Color3.fromRGB(128, 128, 128),
    Title = "Ambient color",
})

VisualsRight:AddToggle("CustomClockTime", {
    Text = "Custom time",
    Default = false,
})

VisualsRight:AddSlider("ClockTime", {
    Text = "Clock time",
    Default = 12,
    Min = 0,
    Max = 24,
    Rounding = 1,
})

VisualsRight:AddToggle("CustomFOV", {
    Text = "Custom FOV",
    Default = false,
})

VisualsRight:AddSlider("FOVValue", {
    Text = "Field of view",
    Default = 70,
    Min = 40,
    Max = 120,
    Rounding = 0,
})

local VisualDependency = VisualsRight:AddDependencyBox()

VisualDependency:AddSlider("AmbientStrength", {
    Text = "Ambient strength",
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 2,
})

VisualDependency:SetupDependencies({
    {
        Toggles.CustomAmbient,
        true,
    },
})

local MiscLeft = Tabs.Misc:AddLeftGroupbox("Notifications")

MiscLeft:AddButton({
    Text = "Short notification",
    Func = function()
        Library:Notify("Short notification", 2)
    end,
})

MiscLeft:AddButton({
    Text = "Long notification",
    Func = function()
        Library:Notify({
            Title = "Long Notification",
            Text = "This notification will stay visible for several seconds.",
            Duration = 6,
        })
    end,
})

MiscLeft:AddInput("CustomNotification", {
    Text = "Notification text",
    Default = "Custom notification",
    Finished = false,
})

MiscLeft:AddButton({
    Text = "Send custom notification",
    Func = function()
        Library:Notify({
            Title = "Custom Notification",
            Text = Options.CustomNotification.Value,
            Duration = 4,
        })
    end,
})

local MiscRight = Tabs.Misc:AddRightGroupbox("Runtime")

MiscRight:AddToggle("PrintRuntimeValues", {
    Text = "Print values every second",
    Default = false,
})

MiscRight:AddButton({
    Text = "Print current values",
    Func = function()
        print("Enabled:", Toggles.Enabled.Value)
        print("AutoSprint:", Toggles.AutoSprint.Value)
        print("WalkSpeed:", Options.WalkSpeed.Value)
        print("DecimalSlider:", Options.DecimalSlider.Value)
        print("TextInput:", Options.TextInput.Value)
        print("ServerRegion:", Options.ServerRegion.Value)
        print("PlayerDropdown:", Options.PlayerDropdown.Value)
        print("TargetHUDHealth:", Options.TargetHUDHealth.Value)
        print("TargetHUDAutoMode:", Options.TargetHUDAutoMode.Value)
        print("ESPEnabled:", Toggles.ESPEnabled.Value)
        print("ESPMaxDistance:", Options.ESPMaxDistance.Value)
        print("FOVValue:", Options.FOVValue.Value)
    end,
})

local UtilityTabs = Tabs.Misc:AddRightTabbox("Utilities")
local SessionTools = UtilityTabs:AddTab("Session")
local NetworkTools = UtilityTabs:AddTab("Network")

SessionTools:AddToggle("AutoReconnect", {
    Text = "Auto reconnect",
    Default = true,
})

SessionTools:AddInput("SessionNote", {
    Text = "Session note",
    Default = "",
    Finished = false,
    Placeholder = "Add a note",
})

SessionTools:AddButton({
    Text = "Reconnect now",
    Func = function()
        Library:Notify({
            Title = "Session",
            Text = "Reconnect requested.",
            Duration = 3,
        })
    end,
})

NetworkTools:AddDropdown("PreferredRegion", {
    Text = "Preferred region",
    Values = { "Automatic", "US West", "US East", "Europe", "Asia" },
    Default = 1,
})

NetworkTools:AddSlider("RetryDelay", {
    Text = "Retry delay",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Suffix = " sec",
})

NetworkTools:AddToggle("LowBandwidthMode", {
    Text = "Low bandwidth mode",
    Default = false,
})

local RuntimeThreadRunning = true

task.spawn(function()
    while RuntimeThreadRunning do
        task.wait(1)

        if Toggles.PrintRuntimeValues.Value then
            print("Auto sprint:", Toggles.AutoSprint.Value)
            print("Speed:", Options.WalkSpeed.Value)
            print("Region:", Options.ServerRegion.Value)
            print("Standalone key:", Options.StandaloneKey:GetState())
        end
    end
end)

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Forma - Loading...")

Library.KeybindFrame.Visible = true

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local Ping = 0

local WatermarkConnection

WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1

    if tick() - FrameTimer >= 1 then
        FPS = FrameCounter
        FrameCounter = 0
        FrameTimer = tick()

        local Success, Result = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)

        if Success then
            Ping = math.floor(Result)
        end
    end

    Library:SetWatermark(
        ("Forma - %d FPS | %d ms"):format(
            FPS,
            Ping
        )
    )
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
    Warning = true,
    ConfirmDuration = 3,
})

MenuGroup:AddLabel("Menu key"):AddKeyPicker("MenuKeybind", {
    Default = "End",
    NoUI = true,
    Text = "Menu key",
})

Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddToggle("ShowKeybindList", {
    Text = "Show keybind list",
    Default = true,
})

Toggles.ShowKeybindList:OnChanged(function()
    Library.KeybindFrame.Visible = Toggles.ShowKeybindList.Value
end)

MenuGroup:AddToggle("ShowWatermark", {
    Text = "Show watermark",
    Default = true,
})

Toggles.ShowWatermark:OnChanged(function()
    Library:SetWatermarkVisibility(
        Toggles.ShowWatermark.Value
    )
end)

MenuGroup:AddButton({
    Text = "Send status notification",
    Func = function()
        Library:Notify({
            Title = "Forma",
            Text = "Interface is working.",
            Duration = 3,
        })
    end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({
    "MenuKeybind",
    "ShowKeybindList",
    "ShowWatermark",
    "TrackPlayer",
    "TargetHUDAutoMode",
    "TargetHUDAutoDistance",
    "TargetHUDManualHealth",
    "TargetHUDHealth",
    "TargetHUDMeterOverride",
    "TargetHUDCustomLabel",
})

ThemeManager:SetFolder("FormaSettings")
SaveManager:SetFolder("FormaSettings")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:OnUnload(function()
    RuntimeThreadRunning = false

    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end

    print("Forma unloaded")
end)

SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "Forma",
    Text = "Interface loaded.",
    Duration = 4,
})
