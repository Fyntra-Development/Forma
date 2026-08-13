from pathlib import Path
p = Path('Library.lua')
s = p.read_text()
old = "            InputService.MouseIconEnabled = State;\n        end);\n    end;\n\n    function Library:Toggle()"
new = "            if CurrentCursorId == CursorAnimationId then\n                InputService.MouseIconEnabled = State;\n            end\n        end);\n    end;\n\n    function Library:Toggle()"
if old not in s:
    raise SystemExit('cursor restore marker missing')
s = s.replace(old, new, 1)
p.write_text(s)
