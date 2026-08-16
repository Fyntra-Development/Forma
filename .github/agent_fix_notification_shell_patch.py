from pathlib import Path

path = Path('Library.lua')
text = path.read_text()

replacements = [
    (
"""    local NotifyOuter = Library:Create('CanvasGroup', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(8, 0);
""",
"""    local NotifyOuter = Library:Create('CanvasGroup', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(8, 0);
"""
    ),
    (
"""        Position = UDim2.new(0, 3, 1, -1);
        Size = UDim2.new(1, -4, 0, 2);
""",
"""        Position = UDim2.new(0, 3, 1, -1);
        Size = UDim2.new(1, -4, 0, 3);
"""
    ),
    (
"""        local TabIndicator = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, -1);
            Size = SettingsEnabled and UDim2.new(0.5, -2, 0, 1) or UDim2.new(1, 0, 0, 1);
            ZIndex = 24;
            Parent = TabBar;
        });
        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });
        Library:AddMovingAccentGradient(TabIndicator, 1.6);
""",
"""        local TabIndicator;
        if SettingsEnabled then
            TabIndicator = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, -1);
                Size = UDim2.new(0.5, -2, 0, 1);
                ZIndex = 24;
                Parent = TabBar;
            });
            Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });
            Library:AddMovingAccentGradient(TabIndicator, 1.6);
        end;
"""
    ),
]

for old, new in replacements:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'Expected exactly one match, found {count}: {old[:80]!r}')
    text = text.replace(old, new, 1)

path.write_text(text)
