from pathlib import Path

p = Path('Library.lua')
s = p.read_text()

wm = """    local WatermarkLabel = Library:CreateLabel({\n        Position = UDim2.new(0, 5, 0, 0);\n        Size = UDim2.new(1, -4, 1, 0);\n        TextSize = 14;\n        TextXAlignment = Enum.TextXAlignment.Left;\n        ZIndex = 203;\n        Parent = InnerFrame;\n    });\n"""
if wm not in s:
    raise SystemExit('watermark marker missing')
s = s.replace(wm, wm + """\n    local WatermarkTextOutline = WatermarkLabel:FindFirstChildOfClass('UIStroke');\n    if WatermarkTextOutline then\n        WatermarkTextOutline.Color = Color3.new(0, 0, 0);\n        WatermarkTextOutline.Thickness = 1.2;\n        WatermarkTextOutline.Transparency = 0.06;\n        WatermarkTextOutline.LineJoinMode = Enum.LineJoinMode.Round;\n    end\n""", 1)

start = s.index('function Library:CreateTargetHUD(Config)')
end = s.index('function Library:Notify(Text, Time)', start)
parts = [path.read_text() for path in sorted(Path('.github/patches').glob('target-hud-*.txt'))]
if not parts:
    raise SystemExit('Target HUD patch chunks missing')
s = s[:start] + ''.join(parts) + '\n' + s[end:]
p.write_text(s)
