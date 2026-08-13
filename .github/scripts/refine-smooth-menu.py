from pathlib import Path
p = Path('Library.lua')
s = p.read_text()
start = s.index('    local function StartFormaCursor()')
end = s.index('    function Library:Toggle()', start)
chunk = s[start:end]
old = '            InputService.MouseIconEnabled = State;\n'
new = "            if CurrentCursorId == CursorAnimationId then\n                InputService.MouseIconEnabled = State;\n            end\n"
if old not in chunk:
    raise SystemExit('cursor restore line missing')
chunk = chunk.replace(old, new, 1)
s = s[:start] + chunk + s[end:]
p.write_text(s)
