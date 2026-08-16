from pathlib import Path

# Keep older configs deterministic: configs created before animated color modes should
# load as Solid instead of preserving a picker author's non-Solid default mode.
save_path = Path('addons/SaveManager.lua')
save = save_path.read_text()
old = """\t\t\tLoad = function(idx, data)\n\t\t\t\tlocal picker = Options[idx]\n\t\t\t\tif picker then\n\t\t\t\t\tpicker:SetValueRGB(Color3.fromHex(data.value), data.transparency, true)\n\t\t\t\t\tif picker.SetAnimationSettings and data.mode then\n\t\t\t\t\t\tpicker:SetAnimationSettings({ Mode = data.mode, Speed = data.speed, SolidColor = Color3.fromHex(data.value), Color1 = data.color1 and Color3.fromHex(data.color1) or nil, Color2 = data.color2 and Color3.fromHex(data.color2) or nil })\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\tend,\n"""
new = """\t\t\tLoad = function(idx, data)\n\t\t\t\tlocal picker = Options[idx]\n\t\t\t\tif picker then\n\t\t\t\t\tlocal HasAnimationData = data.mode ~= nil\n\t\t\t\t\tpicker:SetValueRGB(Color3.fromHex(data.value), data.transparency, HasAnimationData)\n\t\t\t\t\tif picker.SetAnimationSettings and HasAnimationData then\n\t\t\t\t\t\tpicker:SetAnimationSettings({ Mode = data.mode, Speed = data.speed, SolidColor = Color3.fromHex(data.value), Color1 = data.color1 and Color3.fromHex(data.color1) or nil, Color2 = data.color2 and Color3.fromHex(data.color2) or nil })\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\tend,\n"""
if save.count(old) != 1:
    raise SystemExit(f'SaveManager compatibility block: expected 1 match, found {save.count(old)}')
save_path.write_text(save.replace(old, new, 1))

# Demonstrate the opt-in API in the repository example without changing the default
# mode: developers can see how Settings, Fade endpoints, and speed are configured.
example_path = Path('Example.lua')
example = example_path.read_text()
old_example = """ColorLabel:AddColorPicker(\"AccentPreview\", {\n    Default = Color3.fromRGB(0, 170, 255),\n    Title = \"Accent preview\",\n    Transparency = 0,\n    Callback = function(Value)\n"""
new_example = """ColorLabel:AddColorPicker(\"AccentPreview\", {\n    Default = Color3.fromRGB(0, 170, 255),\n    Title = \"Accent preview\",\n    Transparency = 0,\n    Settings = {\n        Mode = \"Solid\",\n        Speed = 1,\n        Color1 = Color3.fromRGB(0, 170, 255),\n        Color2 = Color3.fromRGB(170, 70, 255),\n    },\n    Callback = function(Value)\n"""
if example.count(old_example) != 1:
    raise SystemExit(f'Example colorpicker block: expected 1 match, found {example.count(old_example)}')
example_path.write_text(example.replace(old_example, new_example, 1))
