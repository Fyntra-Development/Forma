from pathlib import Path
import re

path = Path('Library.lua')
source = path.read_text()

if "FormaAssets/cursor.png" not in source:
    pattern = re.compile(r"(?ms)^(?P<i>[ \t]*)local Cursor = Drawing\.new\('Triangle'\);.*?^(?P=i)CursorOutline:Remove\(\);")
    match = pattern.search(source)
    if not match:
        raise RuntimeError('default Linoria cursor block not found')

    i = match.group('i')
    replacement = f'''{i}local CursorAssetPath = 'FormaAssets/cursor.png';
{i}local CursorAssetUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/cursor.png';
{i}local GetCustomAsset = getcustomasset or getsynasset;
{i}local Cursor;

{i}if GetCustomAsset and writefile and isfile then
{i}    pcall(function()
{i}        if isfolder and makefolder and not isfolder('FormaAssets') then
{i}            makefolder('FormaAssets');
{i}        end;

{i}        if not isfile(CursorAssetPath) then
{i}            writefile(CursorAssetPath, game:HttpGet(CursorAssetUrl));
{i}        end;

{i}        Cursor = Library:Create('ImageLabel', {{
{i}            BackgroundTransparency = 1;
{i}            BorderSizePixel = 0;
{i}            Image = GetCustomAsset(CursorAssetPath);
{i}            ImageColor3 = Library.AccentColor;
{i}            Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
{i}            Size = UDim2.fromOffset(20, 24);
{i}            ZIndex = 1000;
{i}            Visible = true;
{i}            Parent = ScreenGui;
{i}        }});

{i}        Library:AddToRegistry(Cursor, {{
{i}            ImageColor3 = 'AccentColor';
{i}        }});
{i}    end);
{i}end;

{i}if Cursor then
{i}    while Toggled and ScreenGui.Parent do
{i}        InputService.MouseIconEnabled = false;
{i}        Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
{i}        RenderStepped:Wait();
{i}    end;

{i}    InputService.MouseIconEnabled = State;
{i}    Cursor:Destroy();
{i}else
{i}    InputService.MouseIconEnabled = State;
{i}end;'''
    source = source[:match.start()] + replacement + source[match.end():]

if 'local WindowGlowLayers =' not in source:
    window_pos = source.find('function Library:CreateWindow')
    if window_pos < 0:
        raise RuntimeError('CreateWindow not found')

    anchor = """    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    });"""
    anchor_pos = source.find(anchor, window_pos)
    if anchor_pos < 0:
        raise RuntimeError('window registry anchor not found')

    insert_at = anchor_pos + len(anchor)
    glow = """

    local WindowGlowLayers = {
        { Padding = 1, Thickness = 1.5, Transparency = 0.12 },
        { Padding = 3, Thickness = 2.5, Transparency = 0.52 },
        { Padding = 5, Thickness = 3.5, Transparency = 0.72 },
        { Padding = 8, Thickness = 4.5, Transparency = 0.86 },
    };

    for _, GlowInfo in ipairs(WindowGlowLayers) do
        local GlowFrame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(-GlowInfo.Padding, -GlowInfo.Padding);
            Size = UDim2.new(1, GlowInfo.Padding * 2, 1, GlowInfo.Padding * 2);
            ZIndex = 0;
            Parent = Outer;
        });

        local GlowStroke = Library:Create('UIStroke', {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Miter;
            Thickness = GlowInfo.Thickness;
            Transparency = GlowInfo.Transparency;
            Parent = GlowFrame;
        });

        Library:AddToRegistry(GlowStroke, {
            Color = 'AccentColor';
        });
    end;"""
    source = source[:insert_at] + glow + source[insert_at:]

if "Drawing.new('Triangle')" in source[source.find('function Library:CreateWindow'):]:
    raise RuntimeError('triangle cursor still present')
if "raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/cursor.png" not in source:
    raise RuntimeError('repo cursor URL missing')
if "ImageColor3 = 'AccentColor'" not in source:
    raise RuntimeError('accent cursor registry missing')
if 'local WindowGlowLayers =' not in source:
    raise RuntimeError('window glow missing')

path.write_text(source)
