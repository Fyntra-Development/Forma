from pathlib import Path
import re

library_path = Path('Library.lua')
source = library_path.read_text()

font_block_pattern = re.compile(
    r"local Fonts = \{.*?local FontOrder = \{.*?\n\};",
    re.S,
)
font_block = '''local RepoFontBaseUrl = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/fonts/";

local Fonts = {
    Rubik = {
        Ttf = "Rubik.ttf",
        RepoPath = "fonts/Rubik.ttf",
    },
};

local FontOrder = {
    "Rubik",
};'''
source, font_count = font_block_pattern.subn(font_block, source, count=1)
if font_count != 1:
    raise RuntimeError('Could not replace current Fonts/FontOrder block')

register_anchor = "Library.Fonts = Fonts;\nLibrary.FontOrder = FontOrder;\n"
register_block = '''Library.Fonts = Fonts;
Library.FontOrder = FontOrder;

function Library:RegisterRepoFont(Name, FileName)
    assert(type(Name) == 'string' and Name ~= '', 'RegisterRepoFont: invalid font name');
    assert(type(FileName) == 'string' and FileName ~= '', 'RegisterRepoFont: invalid file name');

    local CleanFileName = FileName:gsub('\\\\', '/'):match('([^/]+)$');
    assert(CleanFileName and CleanFileName:lower():match('%.ttf$'), 'RegisterRepoFont: expected a .ttf file');

    Fonts[Name] = {
        Ttf = CleanFileName;
        RepoPath = 'fonts/' .. CleanFileName;
    };

    if not table.find(FontOrder, Name) then
        table.insert(FontOrder, Name);
    end;

    return Fonts[Name];
end;
'''
if 'function Library:RegisterRepoFont' not in source:
    if register_anchor not in source:
        raise RuntimeError('Could not locate font registry anchor')
    source = source.replace(register_anchor, register_block, 1)

old_download = '''        local TtfPath = 'FormaAssets/Fonts/' .. Info.Ttf;

        if not isfile(TtfPath) then
            writefile(TtfPath, game:HttpGet(Info.Url));
        end;'''
new_download = '''        local TtfPath = 'FormaAssets/Fonts/' .. Info.Ttf;
        local RepoPath = Info.RepoPath or ('fonts/' .. Info.Ttf);
        local FontUrl = RepoFontBaseUrl .. RepoPath:match('([^/]+)$');

        if not isfile(TtfPath) then
            writefile(TtfPath, game:HttpGet(FontUrl));
        end;'''
if old_download not in source:
    raise RuntimeError('Could not locate current external font download block')
source = source.replace(old_download, new_download, 1)

source = source.replace("Library:SetFont('ProggyClean');", "Library:SetFont('Rubik');", 1)

window_start = source.find('function Library:CreateWindow')
if window_start < 0:
    raise RuntimeError('CreateWindow not found')

glow_start = source.find("    local WindowGlowFrame = Library:Create('Frame', {", window_start)
if glow_start < 0:
    raise RuntimeError('Current window glow start not found')
window_label = source.find("    local WindowLabel = Library:CreateLabel({", glow_start)
if window_label < 0:
    raise RuntimeError('Window label anchor not found')

new_glow = '''    local WindowCornerRadius = UDim.new(0, 2);

    Library:Create('UICorner', {
        CornerRadius = WindowCornerRadius;
        Parent = Outer;
    });

    Library:Create('UICorner', {
        CornerRadius = WindowCornerRadius;
        Parent = Inner;
    });

    local WindowGlowLayers = {
        { Thickness = 0.65, Transparency = 0.38 },
        { Thickness = 0.95, Transparency = 0.56 },
        { Thickness = 1.25, Transparency = 0.70 },
        { Thickness = 1.55, Transparency = 0.81 },
        { Thickness = 1.85, Transparency = 0.89 },
        { Thickness = 2.15, Transparency = 0.95 },
    };

    for _, GlowInfo in ipairs(WindowGlowLayers) do
        local GlowStroke = Library:Create('UIStroke', {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Round;
            Thickness = GlowInfo.Thickness;
            Transparency = GlowInfo.Transparency;
            Parent = Inner;
        });

        Library:AddToRegistry(GlowStroke, {
            Color = 'AccentColor';
        });
    end;

'''
source = source[:glow_start] + new_glow + source[window_label:]

for forbidden in (
    'ocornut/imgui',
    'sametexe001',
    'ProggyTiny',
    'ProggyClean',
    'XP Tahoma',
    'Smallest Pixel',
    'local WindowGlowFrame =',
):
    if forbidden in source:
        raise RuntimeError(f'Forbidden legacy font/glow marker remains: {forbidden}')

for required in (
    'local RepoFontBaseUrl =',
    'Rubik.ttf',
    'function Library:RegisterRepoFont',
    "Library:SetFont('Rubik');",
    'local WindowCornerRadius = UDim.new(0, 2);',
    'Thickness = 2.15',
    'Parent = Inner;',
):
    if required not in source:
        raise RuntimeError(f'Missing expected marker: {required}')

library_path.write_text(source)
