--!strict

local Tokens = {}

Tokens.Primitives = {
    Color = {
        White = Color3.fromRGB(255, 255, 255),
        Black = Color3.fromRGB(0, 0, 0),
        Blue = Color3.fromRGB(0, 85, 255),
        Error = Color3.fromRGB(255, 50, 50),
    },
    Space = {
        Hairline = 1,
        XXS = 2,
        XS = 4,
        SM = 6,
        MD = 8,
        LG = 12,
        XL = 16,
        XXL = 24,
    },
    Radius = {
        None = 0,
        Small = 2,
        Control = 3,
        Window = 4,
        Floating = 4,
    },
    Motion = {
        Short = 0.11,
        Base = 0.18,
        Long = 0.27,
        DragResponse = 0.055,
        ResizeResponse = 0.065,
    },
    Stroke = {
        Hairline = 1,
        Accent = 2,
    },
}

Tokens.Semantic = {
    Surface = {
        Canvas = "BackgroundColor",
        Panel = "MainColor",
        Elevated = "Contrast",
        Recessed = "Inline",
        GradientTop = "UpperGradient",
        GradientBottom = "LowerGradient",
    },
    Text = {
        Primary = "FontColor",
        Subtle = "DisabledTextColor",
    },
    Border = {
        Default = "OutlineColor",
    },
    Accent = {
        Primary = "AccentColor",
        Shade = "BlendShade",
        Danger = "RiskColor",
    },
}

Tokens.Components = {
    Window = {
        Fill = "Semantic.Surface.Panel",
        Border = "Semantic.Border.Default",
        CornerRadius = "Primitives.Radius.Window",
    },
    Groupbox = {
        Fill = "Semantic.Surface.Canvas",
        Outline = "Semantic.Border.Default",
        Gap = "Primitives.Space.MD",
    },
    Control = {
        Fill = "Semantic.Surface.Elevated",
        GradientTop = "Semantic.Surface.GradientTop",
        GradientBottom = "Semantic.Surface.GradientBottom",
        Text = "Semantic.Text.Primary",
        MutedText = "Semantic.Text.Subtle",
        CornerRadius = "Primitives.Radius.Control",
    },
    Dropdown = {
        Fill = "Semantic.Surface.Elevated",
        Popup = "Semantic.Surface.Panel",
        Outline = "Semantic.Border.Default",
        Highlight = "Semantic.Accent.Primary",
    },
    ColorPicker = {
        Fill = "Semantic.Surface.Canvas",
        Shell = "Semantic.Surface.Panel",
        Outline = "Semantic.Border.Default",
        Accent = "Semantic.Accent.Primary",
    },
    Keybind = {
        Fill = "Semantic.Surface.Panel",
        Accent = "Semantic.Accent.Primary",
        MutedText = "Semantic.Text.Subtle",
    },
    Utility = {
        Fill = "Semantic.Surface.Panel",
        Outline = "Semantic.Border.Default",
        Glow = "Semantic.Accent.Primary",
    },
    Notification = {
        Fill = "Semantic.Surface.Panel",
        Accent = "Semantic.Accent.Primary",
        Danger = "Semantic.Accent.Danger",
    },
}

local function ReadPath(Reference: string): any
    local Parts = string.split(Reference, ".")
    local Value: any = Tokens
    for _, Part in ipairs(Parts) do
        if type(Value) ~= "table" then return nil end
        Value = Value[Part]
        if Value == nil then return nil end
    end
    return Value
end

function Tokens.Resolve(Library: any, Path: string): any
    assert(type(Path) == "string", "Tokens.Resolve expects a dot-separated path")
    local Seen = {}
    local Value: any = Path

    for _ = 1, 12 do
        if type(Value) ~= "string" then return Value end
        if Seen[Value] then
            error("Circular token reference: " .. Value, 2)
        end
        Seen[Value] = true

        local Alias = ReadPath(Value)
        if Alias ~= nil then
            Value = Alias
        else
            local Current = Library and Library[Value]
            if Current ~= nil then return Current end
            error("Unknown Forma token: " .. Value, 2)
        end
    end
    error("Forma token reference depth exceeded", 2)
end

function Tokens.ResolveGroup(Library: any, Path: string): { [string]: any }
    local Group = ReadPath(Path)
    assert(type(Group) == "table", "Unknown Forma token group: " .. tostring(Path))
    local Resolved = {}
    for Name, Value in pairs(Group) do
        Resolved[Name] = if type(Value) == "table"
            then Tokens.ResolveGroup(Library, Path .. "." .. Name)
            else Tokens.Resolve(Library, Path .. "." .. Name)
    end
    return Resolved
end

return Tokens
