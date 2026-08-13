from pathlib import Path

path = Path('Library.lua')
text = path.read_text()

needle = """        function Dropdown:SetValues(NewValues)\n            if NewValues then\n                Dropdown.Values = NewValues;\n            end;\n"""
insert = """        function Dropdown:OnChanged(Func)\n            Dropdown.Changed = Func;\n            Func(Dropdown.Value);\n        end;\n\n        function Dropdown:SetValues(NewValues)\n            if NewValues then\n                Dropdown.Values = NewValues;\n            end;\n"""

count = text.count(needle)
if count != 1:
    raise SystemExit(f'expected one dropdown SetValues anchor, got {count}')

text = text.replace(needle, insert, 1)

if text.count("function Dropdown:OnChanged(Func)") != 1:
    raise SystemExit('Dropdown OnChanged missing or duplicated')

path.write_text(text)
