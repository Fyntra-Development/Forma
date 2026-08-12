from pathlib import Path
import re

library_path = Path('Library.lua')
source = library_path.read_text()

source = source.replace(
    "local TweenService = game:GetService('TweenService');\n",
    "local TweenService = game:GetService('TweenService');\nlocal HttpService = game:GetService('HttpService');\n",
    1,
)

fonts_block = """
local Fonts = {
    ProggyTiny = {
        Ttf = "ProggyTiny.ttf",
        Url = "https://github.com/ocornut/imgui/raw/master/misc/fonts/ProggyTiny.ttf",
    },
    ProggyClean = {
        Ttf = "ProggyClean.ttf",
        Url = "https://github.com/ocornut/imgui/raw/master/misc/fonts/ProggyClean.ttf",
    },
    ["XP Tahoma"] = {
        Ttf = "XP Tahoma.ttf",
        Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/TAHOMA-8PT-BOLD-WINDOWS-XP.TTF",
    },
    ["Smallest Pixel"] = {
        Ttf = "smallest_pixel-7.ttf",
        Url = "https://raw.githubusercontent.com/sametexe001/luas/main/smallest_pixel-7.ttf",
    },
};

local FontOrder = {
    "ProggyClean",
    "ProggyTiny",
    "XP Tahoma",
    "Smallest Pixel",
};
"""

if 'local Fonts = {' not in source:
    anchor = "local Mouse = LocalPlayer:GetMouse();\n"
    if anchor not in source:
        raise RuntimeError('mouse anchor missing')
    source = source.replace(anchor, anchor + fonts_block + "\n", 1)

if 'FontName = ' not in source:
    source = source.replace(
        "    Font = Enum.Font.Code,\n",
        "    Font = Enum.Font.Code,\n    FontName = 'Code',\n",
        1,
    )

helpers = r'''
Library.Fonts = Fonts;
Library.FontOrder = FontOrder;
Library.PropertyTweens = setmetatable({}, { __mode = 'k' });

function Library:GetFontNames()
    local Result = {};

    for _, Name in ipairs(Library.FontOrder) do
        table.insert(Result, Name);
    end;

    return Result;
end;

function Library:ApplyFont(Instance)
    if not Instance then
        return;
    end;

    if typeof(Library.Font) == 'Font' then
        pcall(function()
            Instance.FontFace = Library.Font;
        end);
    else
        pcall(function()
            Instance.Font = Library.Font;
        end);
    end;
end;

function Library:UpdateFont()
    for _, Descendant in ipairs(ScreenGui:GetDescendants()) do
        if Descendant:IsA('TextLabel') or Descendant:IsA('TextBox') or Descendant:IsA('TextButton') then
            Library:ApplyFont(Descendant);
        end;
    end;
end;

function Library:LoadFont(Name)
    local Info = Fonts[Name];
    local GetCustomAsset = getcustomasset or getsynasset;

    if not Info or not GetCustomAsset or not writefile or not isfile then
        return false;
    end;

    local Success, LoadedFont = pcall(function()
        if makefolder then
            if not isfolder or not isfolder('FormaAssets') then
                pcall(makefolder, 'FormaAssets');
            end;

            if not isfolder or not isfolder('FormaAssets/Fonts') then
                pcall(makefolder, 'FormaAssets/Fonts');
            end;
        end;

        local TtfPath = 'FormaAssets/Fonts/' .. Info.Ttf;

        if not isfile(TtfPath) then
            writefile(TtfPath, game:HttpGet(Info.Url));
        end;

        local TtfAsset = GetCustomAsset(TtfPath);
        local FamilyPath = TtfPath:gsub('%.ttf$', '.font');
        local FamilyData = {
            name = Name;
            faces = {
                {
                    name = 'Regular';
                    weight = 400;
                    style = 'normal';
                    assetId = TtfAsset;
                };
            };
        };

        writefile(FamilyPath, HttpService:JSONEncode(FamilyData));

        local Face;
        local FamilyAsset = GetCustomAsset(FamilyPath);

        pcall(function()
            Face = Font.new(FamilyAsset);
        end);

        if not Face then
            pcall(function()
                Face = Font.new(TtfAsset);
            end);
        end;

        return Face;
    end);

    if not Success or not LoadedFont then
        return false;
    end;

    Library.Font = LoadedFont;
    Library.FontName = Name;
    Library:UpdateFont();
    return true;
end;

function Library:SetFont(Name)
    return Library:LoadFont(Name);
end;

function Library:TweenProperty(Instance, Property, Value, Duration)
    if not Instance then
        return;
    end;

    local InstanceTweens = Library.PropertyTweens[Instance];

    if not InstanceTweens then
        InstanceTweens = {};
        Library.PropertyTweens[Instance] = InstanceTweens;
    end;

    local Previous = InstanceTweens[Property];

    if Previous then
        pcall(function()
            Previous:Cancel();
        end);
    end;

    local Tween;
    local Success = pcall(function()
        Tween = TweenService:Create(
            Instance,
            TweenInfo.new(Duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { [Property] = Value }
        );
    end);

    if not Success or not Tween then
        Instance[Property] = Value;
        return;
    end;

    InstanceTweens[Property] = Tween;
    Tween:Play();

    Tween.Completed:Connect(function()
        if InstanceTweens[Property] == Tween then
            InstanceTweens[Property] = nil;
        end;
    end);
end;
'''

if 'function Library:TweenProperty' not in source:
    anchor = 'function Library:SafeCallback(f, ...)'
    pos = source.find(anchor)
    if pos < 0:
        raise RuntimeError('SafeCallback anchor missing')
    source = source[:pos] + helpers + '\n' + source[pos:]

old_create_label = """function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    });

    Library:ApplyTextStroke(_Instance);"""
new_create_label = """function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    });

    Library:ApplyFont(_Instance);
    Library:ApplyTextStroke(_Instance);"""
if old_create_label in source:
    source = source.replace(old_create_label, new_create_label, 1)
elif 'Library:ApplyFont(_Instance);' not in source:
    raise RuntimeError('CreateLabel block mismatch')

source = source.replace('            Font = Library.Font;\n', '')

for var in ('HueBox', 'Box'):
    if f'Library:ApplyFont({var});' not in source:
        pattern = re.compile(
            rf"(local {var} = Library:Create\('TextBox', \{{.*?\n\s*\}}\);)",
            re.S,
        )
        source, count = pattern.subn(rf"\1\n\n        Library:ApplyFont({var});", source, count=1)
        if count != 1:
            raise RuntimeError(f'failed to apply custom font to {var}')

old_bounds = """function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;"""
new_bounds = """function Library:GetTextBounds(Text, FontValue, Size, Resolution)
    local MaxResolution = Resolution or Vector2.new(1920, 1080);

    if typeof(FontValue) == 'Font' then
        local Success, Bounds = pcall(function()
            local Params = Instance.new('GetTextBoundsParams');
            Params.Text = Text;
            Params.Font = FontValue;
            Params.Size = Size;
            Params.Width = MaxResolution.X;

            local Result = TextService:GetTextBoundsAsync(Params);
            Params:Destroy();
            return Result;
        end);

        if Success and Bounds then
            return Bounds.X, Bounds.Y;
        end;

        FontValue = Enum.Font.Code;
    end;

    local Bounds = TextService:GetTextSize(Text, Size, FontValue, MaxResolution);
    return Bounds.X, Bounds.Y;
end;"""
if old_bounds in source:
    source = source.replace(old_bounds, new_bounds, 1)
elif "GetTextBoundsParams" not in source:
    raise RuntimeError('GetTextBounds block mismatch')

old_highlight = """function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;"""
new_highlight = """function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    local function Apply(PropertiesToApply)
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesToApply do
            local Value = Library[ColorIdx] or ColorIdx;

            if typeof(Value) == 'Color3' then
                Library:TweenProperty(Instance, Property, Value, 0.17);
            else
                Instance[Property] = Value;
            end;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end;

    HighlightInstance.MouseEnter:Connect(function()
        Apply(Properties);
    end);

    HighlightInstance.MouseLeave:Connect(function()
        Apply(PropertiesDefault);
    end);
end;"""
if old_highlight in source:
    source = source.replace(old_highlight, new_highlight, 1)
elif "local function Apply(PropertiesToApply)" not in source:
    raise RuntimeError('OnHighlight block mismatch')

old_toggle = """        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;"""
new_toggle = """        function Toggle:Display()
            local BackgroundKey = Toggle.Value and 'AccentColor' or 'MainColor';
            local BorderKey = Toggle.Value and 'AccentColorDark' or 'OutlineColor';

            Library:TweenProperty(ToggleInner, 'BackgroundColor3', Library[BackgroundKey], 0.18);
            Library:TweenProperty(ToggleInner, 'BorderColor3', Library[BorderKey], 0.18);

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = BackgroundKey;
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = BorderKey;
        end;"""
if old_toggle in source:
    source = source.replace(old_toggle, new_toggle, 1)
elif "local BackgroundKey = Toggle.Value" not in source:
    raise RuntimeError('Toggle Display block mismatch')

old_dropdown_selected = """                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';"""
new_dropdown_selected = """                    local TextColorKey = Selected and 'AccentColor' or 'FontColor';
                    Library:TweenProperty(ButtonLabel, 'TextColor3', Library[TextColorKey], 0.16);
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = TextColorKey;"""
if old_dropdown_selected in source:
    source = source.replace(old_dropdown_selected, new_dropdown_selected, 1)

old_glow_pattern = re.compile(
    r"    local WindowGlowLayers = \{.*?\n    end;\n\n    local WindowLabel =",
    re.S,
)
new_glow = """    local WindowGlowFrame = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(-1, -1);
        Size = UDim2.new(1, 2, 1, 2);
        ZIndex = 0;
        Parent = Outer;
    });

    local WindowGlowLayers = {
        { Thickness = 0.8, Transparency = 0.10 },
        { Thickness = 1.3, Transparency = 0.32 },
        { Thickness = 1.8, Transparency = 0.48 },
        { Thickness = 2.3, Transparency = 0.61 },
        { Thickness = 2.8, Transparency = 0.72 },
        { Thickness = 3.3, Transparency = 0.81 },
        { Thickness = 3.8, Transparency = 0.88 },
        { Thickness = 4.3, Transparency = 0.94 },
    };

    for _, GlowInfo in ipairs(WindowGlowLayers) do
        local GlowStroke = Library:Create('UIStroke', {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Miter;
            Thickness = GlowInfo.Thickness;
            Transparency = GlowInfo.Transparency;
            Parent = WindowGlowFrame;
        });

        Library:AddToRegistry(GlowStroke, {
            Color = 'AccentColor';
        });
    end;

    local WindowLabel ="""
source, glow_count = old_glow_pattern.subn(new_glow, source, count=1)
if glow_count != 1 and 'local WindowGlowFrame =' not in source:
    raise RuntimeError('window glow block mismatch')

source = source.replace('                            Size = UDim2.fromOffset(20, 24);', '                            Size = UDim2.fromOffset(13, 16);', 1)

if "Library:SetFont('ProggyClean');" not in source:
    anchor = 'getgenv().Library = Library'
    pos = source.rfind(anchor)
    if pos < 0:
        raise RuntimeError('library export anchor missing')
    source = source[:pos] + "Library:SetFont('ProggyClean');\n\n" + source[pos:]

for required in (
    'local Fonts = {',
    'function Library:LoadFont',
    'function Library:TweenProperty',
    "Size = UDim2.fromOffset(13, 16);",
    'local WindowGlowFrame =',
    "Library:SetFont('ProggyClean');",
):
    if required not in source:
        raise RuntimeError(f'missing Library.lua marker: {required}')

library_path.write_text(source)

theme_path = Path('addons/ThemeManager.lua')
theme = theme_path.read_text()

font_ui = """

		local FontNames = self.Library:GetFontNames()
		local DefaultFontIndex = table.find(FontNames, self.Library.FontName) or 1
		groupbox:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = FontNames, Default = DefaultFontIndex })
		Options.ThemeManager_Font:OnChanged(function()
			self.Library:SetFont(Options.ThemeManager_Font.Value)
		end)
"""

if "ThemeManager_Font" not in theme:
    anchor = "\t\tgroupbox:AddLabel('Font color')\t:AddColorPicker('FontColor', { Default = self.Library.FontColor });\n"
    if anchor not in theme:
        raise RuntimeError('ThemeManager font color anchor missing')
    theme = theme.replace(anchor, anchor + font_ui, 1)

theme_path.write_text(theme)
