from pathlib import Path

path = Path('Library.lua')
text = path.read_text()


def replace_once(old, new, label):
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, got {count}')
    text = text.replace(old, new, 1)

replace_once(
    """    local Layers = {\n        { 0.72, 0.42 },\n        { 0.98, 0.54 },\n        { 1.24, 0.66 },\n        { 1.52, 0.76 },\n        { 1.82, 0.84 },\n        { 2.12, 0.90 },\n        { 2.42, 0.95 },\n    };""",
    """    local Layers = {\n        { 0.70, 0.42 },\n        { 0.92, 0.54 },\n        { 1.14, 0.66 },\n        { 1.38, 0.76 },\n        { 1.64, 0.84 },\n        { 1.90, 0.90 },\n        { 2.18, 0.95 },\n    };""",
    'tight glow layers',
)

replace_once(
    """                        task.delay(Delay, function()\n                            if Group and Group.Parent then\n                                Library:TweenProperty(Group, 'GroupTransparency', Target, Duration);\n                            end;\n                        end);""",
    """                        task.delay(Delay, function()\n                            if Group and Group.Parent and (Target ~= 0 or Tab.Active) then\n                                Library:TweenProperty(Group, 'GroupTransparency', Target, Duration);\n                            end;\n                        end);""",
    'tab fade race guard',
)

replace_once(
    """        local function SetKeyDisplay(Key)\n            local Text = '<' .. tostring(Key) .. '>';\n            DisplayLabel.Text = Text;\n            local Width = select(1, Library:GetTextBounds(Text, Library.Font, 13));\n            PickOuter.Size = UDim2.fromOffset(math.max(28, Width + 6), 15);\n        end;\n\n        SetKeyDisplay(Info.Default);""",
    """        local function ResizeKeyDisplay()\n            local Width = math.max(DisplayLabel.TextBounds.X, select(1, Library:GetTextBounds(DisplayLabel.Text, Library.Font, 13)));\n            PickOuter.Size = UDim2.fromOffset(math.max(28, Width + 6), 15);\n        end;\n\n        local function SetKeyDisplay(Key)\n            DisplayLabel.Text = '<' .. tostring(Key) .. '>';\n            ResizeKeyDisplay();\n            task.defer(ResizeKeyDisplay);\n        end;\n\n        DisplayLabel:GetPropertyChangedSignal('TextBounds'):Connect(ResizeKeyDisplay);\n        SetKeyDisplay(Info.Default);""",
    'responsive key display width',
)

replace_once(
    """            local TargetPosition = GetPickerTargetPosition();\n            PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 26);\n            PickerFrameOuter.GroupTransparency = 1;\n            PickerFrameOuter.Visible = true;""",
    """            local TargetPosition = GetPickerTargetPosition();\n            if not PickerFrameOuter.Visible then\n                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 26);\n                PickerFrameOuter.GroupTransparency = 1;\n            end;\n            PickerFrameOuter.Visible = true;""",
    'color picker reopen continuity',
)

for token in [
    "{ 2.18, 0.95 }",
    "Target ~= 0 or Tab.Active",
    "DisplayLabel:GetPropertyChangedSignal('TextBounds')",
    "if not PickerFrameOuter.Visible then",
]:
    if token not in text:
        raise SystemExit(f'missing final token: {token}')

path.write_text(text)
