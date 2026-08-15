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
    Title = "Example Window",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Main = Window:AddTab("Showcase"),
    Players = Window:AddTab("Player"),
    Visuals = Window:AddTab("Visual"),
    Misc = Window:AddTab("Misc"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local TargetHUDTestHealth = 100
local TargetHUDTestMaxHealth = 100
local TargetHUDUseManualHealth = false
local TargetHUDExampleLabel

local TargetHUD = Library:CreateTargetHUD({
    Visible = false,
    Position = UDim2.new(0.5, 285, 0.5, 120),

    AutoTargetMode = "Off",
    AutoDistanceMeter = false,

    -- These demonstrate the smoother health/gradient defaults.
    HealthSmoothTime = 0.20,
    HealthGradientSpeed = 1.15,

    HealthProvider = function(Target)
        if TargetHUDUseManualHealth then
            return TargetHUDTestHealth, TargetHUDTestMaxHealth
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


local MainLeft = Tabs.Main:AddLeftGroupbox("Control Showcase")

MainLeft:AddToggle("Enabled", {
    Text = "Enable showcase",
    Default = false,
    Tooltip = "Master toggle used by this showcase.",
    Callback = function(Value)
        print("[Showcase] Enabled:", Value)
    end,
})

Toggles.Enabled:OnChanged(function()
    print("[Showcase] Toggle changed:", Toggles.Enabled.Value)
end)

local FeatureToggle = MainLeft:AddToggle("FeatureToggle", {
    Text = "Toggle + keybind showcase",
    Default = false,
    Tooltip = "This toggle has a keybind attached.",
})

FeatureToggle:AddKeyPicker("FeatureKeybind", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Example feature",
    NoUI = false,
    Callback = function(Value)
        print("Feature keybind state:", Value)
    end,
    ChangedCallback = function(NewKey)
        print("Feature key changed:", NewKey)
    end,
})

Toggles.FeatureToggle:OnChanged(function()
    print("Feature toggle:", Toggles.FeatureToggle.Value)
end)

MainLeft:AddDivider()

MainLeft:AddLabel("Label showcase")

MainLeft:AddLabel(
    "This is a wrapped label showcase.\n\nUse wrapped labels when an example needs to display longer information inside a groupbox.",
    true
)

MainLeft:AddButton({
    Text = "Notification showcase",
    Func = function()
        Library:Notify({
            Title = "Forma Showcase",
            Text = "Example notification with an accent-colored title.",
            Duration = 4,
        })
    end,
    Tooltip = "Displays a titled notification.",
})

MainLeft:AddButton({
    Text = "Warning confirmation",
    Func = function()
        print("Confirmed dangerous action")
        Library:Notify({
            Title = "Confirmed",
            Text = "The warning action was confirmed.",
            Duration = 3,
        })
    end,
    Warning = true,
    ConfirmDuration = 3,
    Tooltip = "Flashes the accent once, then shows a three-second confirmation timer.",
})

local MainButton = MainLeft:AddButton({
    Text = "Primary button showcase",
    Func = function()
        print("Main button clicked")
    end,
})

local SecondaryButton = MainButton:AddButton({
    Text = "Secondary button",
    Func = function()
        print("Sub button clicked")
    end,
    Tooltip = "This is a sub-button.",
})

SecondaryButton:AddTertiaryButton({
    Text = "Tertiary button",
    Func = function()
        print("Tertiary button clicked")
    end,
    Tooltip = "Three-button rows stay proportional while the window resizes.",
})

MainLeft:AddDivider()

MainLeft:AddSlider("WalkSpeedExample", {
    Text = "Slider showcase",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        print("Slider callback:", Value)
    end,
})

Options.WalkSpeedExample:OnChanged(function()
    print("Example speed changed:", Options.WalkSpeedExample.Value)
end)

MainLeft:AddSlider("DecimalSlider", {
    Text = "Decimal slider",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        print("Decimal:", Value)
    end,
})

MainLeft:AddSlider("CompactSlider", {
    Text = "Compact slider",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true,
})

local MainRight = Tabs.Main:AddRightGroupbox("Input Showcase")

MainRight:AddInput("TextInput", {
    Text = "Text input",
    Default = "Hello showcase",
    Numeric = false,
    Finished = false,
    Placeholder = "Enter something...",
    Callback = function(Value)
        print("Text input:", Value)
    end,
})

Options.TextInput:OnChanged(function()
    print("TextInput changed:", Options.TextInput.Value)
end)

MainRight:AddInput("NumericInput", {
    Text = "Numeric input",
    Default = "10",
    Numeric = true,
    Finished = true,
    Placeholder = "Number...",
    Callback = function(Value)
        print("Numeric input:", Value)
    end,
})

MainRight:AddInput("LimitedInput", {
    Text = "Maximum 16 characters",
    Default = "",
    Numeric = false,
    Finished = false,
    MaxLength = 16,
    Placeholder = "Max 16 characters",
})

MainRight:AddDivider()

MainRight:AddDropdown("ExampleDropdown", {
    Text = "Searchable dropdown showcase",
    Values = {
        "Option A",
        "Option B",
        "Option C",
        "Option D",
        "Option E",
        "Option F",
        "Option G",
        "Option H",
        "Option I",
    },
    Default = 1,
    Multi = false,
    Searchable = true,
    Tooltip = {
        Title = "Searchable dropdown",
        Text = {
            "This dropdown opts into the search feature.",
            "Dropdowns without Searchable = true remain standard dropdowns.",
        },
    },
    Callback = function(Value)
        print("Dropdown:", Value)
    end,
})

Options.ExampleDropdown:OnChanged(function()
    print("Dropdown changed:", Options.ExampleDropdown.Value)
end)

MainRight:AddDropdown("MultiDropdown", {
    Text = "Multi-select showcase",
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

local ColorLabel = MainRight:AddLabel("Color picker showcase")

ColorLabel:AddColorPicker("ExampleColor", {
    Default = Color3.fromRGB(0, 170, 255),
    Title = "Showcase color",
    Transparency = 0,
    Callback = function(Value)
        print("Color:", Value)
    end,
})

Options.ExampleColor:OnChanged(function()
    print(
        "Color changed:",
        Options.ExampleColor.Value,
        Options.ExampleColor.Transparency
    )
end)

local KeyLabel = MainRight:AddLabel("Standalone keybind showcase")

KeyLabel:AddKeyPicker("StandaloneKey", {
    Default = "G",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Standalone key",
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

local DependencyGroup = Tabs.Main:AddRightGroupbox("Dependency Showcase")

DependencyGroup:AddToggle("DependencyMaster", {
    Text = "Reveal dependency examples",
    Default = false,
})

local DependencyBox = DependencyGroup:AddDependencyBox()

DependencyBox:AddToggle("DependentToggle", {
    Text = "Dependent toggle showcase",
    Default = false,
})

DependencyBox:AddSlider("DependentSlider", {
    Text = "Dependent slider showcase",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
})

DependencyBox:AddDropdown("DependentDropdown", {
    Text = "Dependent dropdown showcase",
    Values = {
        "One",
        "Two",
        "Three",
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
    Text = "Nested option",
    Default = false,
})

NestedDependency:AddSlider("NestedSlider", {
    Text = "Nested amount",
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

local PlayersLeft = Tabs.Players:AddLeftGroupbox("Player Selection Showcase")

PlayersLeft:AddDropdown("PlayerDropdown", {
    SpecialType = "Player",
    Text = "Target player",
    Tooltip = "Selects the player used by the Target HUD test bench.",
    Searchable = true,
    Callback = function(Value)
        print("Selected player:", Value)

        local Player = Value and Players:FindFirstChild(Value)
        TargetHUD:SetTarget(Player)

        if TargetHUDUseManualHealth then
            TargetHUD:SetHealth(TargetHUDTestHealth, TargetHUDTestMaxHealth, false)
        end

        if Toggles.TrackPlayer and Toggles.TrackPlayer.Value and Player then
            TargetHUD:SetVisible(true)
        end
    end,
})

PlayersLeft:AddDropdown("TeamDropdown", {
    SpecialType = "Team",
    Text = "Team showcase",
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

local PlayersRight = Tabs.Players:AddRightGroupbox("Target HUD Test Bench")

PlayersRight:AddToggle("TrackPlayer", {
    Text = "Show Target HUD",
    Default = false,
    Tooltip = {
        Title = "Target HUD",
        Text = {
            "Shows the selected target avatar and username.",
            "Use the controls below to test health smoothing, gradients, meter text, and automatic targeting.",
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
    Text = "Use local player as test target",
    Func = function()
        TargetHUD:SetTarget(Players.LocalPlayer)
        TargetHUD:SetVisible(true)
        Toggles.TrackPlayer:SetValue(true)

        if TargetHUDUseManualHealth then
            TargetHUD:SetHealth(TargetHUDTestHealth, TargetHUDTestMaxHealth, false)
        end
    end,
    Tooltip = "Useful for testing the Target HUD while you are alone in a server.",
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
    Text = "Use manual health test",
    Default = false,
    Tooltip = "Overrides the displayed target health without changing the player's real Humanoid health.",
})

Toggles.TargetHUDManualHealth:OnChanged(function()
    TargetHUDUseManualHealth = Toggles.TargetHUDManualHealth.Value

    if TargetHUDUseManualHealth then
        if not TargetHUD.Target then
            TargetHUD:SetTarget(Players.LocalPlayer)
        end

        TargetHUD:SetHealth(TargetHUDTestHealth, TargetHUDTestMaxHealth, false)
        TargetHUD:SetVisible(true)
        Toggles.TrackPlayer:SetValue(true)
    else
        TargetHUD:Refresh()
    end
end)

PlayersRight:AddSlider("TargetHUDHealth", {
    Text = "Test health",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Step = 1,
    Suffix = " HP",
    Tooltip = "Move this slider quickly to test continuous health-bar damping.",
})

Options.TargetHUDHealth:OnChanged(function()
    TargetHUDTestHealth = Options.TargetHUDHealth.Value

    if TargetHUDUseManualHealth then
        TargetHUD:SetHealth(TargetHUDTestHealth, TargetHUDTestMaxHealth, false)
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
    Placeholder = "Example: 42 meters",
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
    Placeholder = "Example label value",
})

PlayersRight:AddButton({
    Text = "Apply custom label",
    Func = function()
        local Value = Options.TargetHUDCustomLabel.Value

        if Value == "" then
            if TargetHUDExampleLabel then
                TargetHUDExampleLabel:Destroy()
                TargetHUDExampleLabel = nil
            end
            return
        end

        if TargetHUDExampleLabel then
            TargetHUDExampleLabel:SetValue(Value)
        else
            TargetHUDExampleLabel = TargetHUD:AddLabel(
                "Example",
                Value,
                "ExampleTestLabel"
            )
        end
    end,
}):AddButton({
    Text = "Remove custom label",
    Func = function()
        if TargetHUDExampleLabel then
            TargetHUDExampleLabel:Destroy()
            TargetHUDExampleLabel = nil
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


local VisualsLeft = Tabs.Visuals:AddLeftGroupbox("ESP Showcase")

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

local VisualsRight = Tabs.Visuals:AddRightGroupbox("World Showcase")

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

local MiscLeft = Tabs.Misc:AddLeftGroupbox("Notification Showcase")

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

local MiscRight = Tabs.Misc:AddRightGroupbox("Runtime Showcase")

MiscRight:AddToggle("PrintRuntimeValues", {
    Text = "Print values every second",
    Default = false,
})

MiscRight:AddButton({
    Text = "Print all example values",
    Func = function()
        print("Enabled:", Toggles.Enabled.Value)
        print("FeatureToggle:", Toggles.FeatureToggle.Value)
        print("WalkSpeedExample:", Options.WalkSpeedExample.Value)
        print("DecimalSlider:", Options.DecimalSlider.Value)
        print("TextInput:", Options.TextInput.Value)
        print("ExampleDropdown:", Options.ExampleDropdown.Value)
        print("PlayerDropdown:", Options.PlayerDropdown.Value)
        print("TargetHUDHealth:", Options.TargetHUDHealth.Value)
        print("TargetHUDAutoMode:", Options.TargetHUDAutoMode.Value)
        print("ESPEnabled:", Toggles.ESPEnabled.Value)
        print("ESPMaxDistance:", Options.ESPMaxDistance.Value)
        print("FOVValue:", Options.FOVValue.Value)
    end,
})

local RuntimeThreadRunning = true

task.spawn(function()
    while RuntimeThreadRunning do
        task.wait(1)

        if Toggles.PrintRuntimeValues.Value then
            print("Feature:", Toggles.FeatureToggle.Value)
            print("Speed:", Options.WalkSpeedExample.Value)
            print("Dropdown:", Options.ExampleDropdown.Value)
            print("Standalone key:", Options.StandaloneKey:GetState())
        end
    end
end)

Library:SetWatermarkVisibility(true)
-- The library automatically resolves the universe/place name for watermark metadata.
Library:SetWatermark("Example Showcase - Loading...")

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
        ("Example Showcase - %d FPS | %d ms"):format(
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
    Text = "Test notification",
    Func = function()
        Library:Notify({
            Title = "Forma",
            Text = "The example UI is working.",
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

ThemeManager:SetFolder("ExampleShowcase")
SaveManager:SetFolder("ExampleShowcase")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:OnUnload(function()
    RuntimeThreadRunning = false

    if WatermarkConnection then
        WatermarkConnection:Disconnect()
        WatermarkConnection = nil
    end

    print("Example showcase unloaded")
end)

SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title = "Forma Showcase",
    Text = "Example showcase loaded.",
    Duration = 4,
})
