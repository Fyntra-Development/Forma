from pathlib import Path

path = Path('addons/ThemeManager.lua')
text = path.read_text()
old = """\t\t['Marin Kitagawa'] = {\n\t\t\tFile = 'marin-kitagawa.png';\n\t\t\tSize = UDim2.fromOffset(362, 240);\n\t\t\tVisibleAnchor = Vector2.new(0.08, 0.72);\n\t\t};"""
new = """\t\t['Marin Kitagawa'] = {\n\t\t\tFile = 'marin-kitagawa.png';\n\t\t\tSize = UDim2.fromOffset(300, 300);\n\t\t\tVisibleAnchor = Vector2.new(0.08, 0.64);\n\t\t};"""
if old not in text:
    raise SystemExit('Marin overlay block not found')
text = text.replace(old, new, 1)
path.write_text(text)
