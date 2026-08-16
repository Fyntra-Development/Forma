from pathlib import Path

path = Path('Library.lua')
text = path.read_text()

replacements = []

replacements.append((
"""            SlideX = -62;
            SlideTarget = 0;
            SlideVelocity = 0;
            Exiting = false;
""",
"""            SlideX = -48;
            SlideTarget = 0;
            SlideVelocity = 0;
            RevealScale = 0.68;
            RevealTarget = 1;
            RevealVelocity = 0;
            Exiting = false;
""",
'notification motion state'))

replacements.append((
"""        Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
        Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
        return Entry;
""",
"""        Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
        Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
        Inner.Size = UDim2.new(Entry.RevealScale, 0, 1, 0);
        return Entry;
""",
'initial notification reveal'))

replacements.append((
"""        Entry.Exiting = true;
        Entry.SlideTarget = -62;
        if Entry.ProgressBar and Entry.ProgressBar.Parent then
""",
"""        Entry.Exiting = true;
        Entry.SlideTarget = -48;
        Entry.RevealTarget = 0.82;
        if Entry.ProgressBar and Entry.ProgressBar.Parent then
""",
'notification exit targets'))

replacements.append((
"""                Entry.SlideX, Entry.SlideVelocity = StepNotificationSpring(
                    Entry.SlideX,
                    Entry.SlideVelocity,
                    Entry.SlideTarget,
                    Entry.Exiting and 0.09 or 0.13,
                    Delta
                );

                Entry.Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
                Entry.Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
""",
"""                Entry.SlideX, Entry.SlideVelocity = StepNotificationSpring(
                    Entry.SlideX,
                    Entry.SlideVelocity,
                    Entry.SlideTarget,
                    Entry.Exiting and 0.14 or 0.19,
                    Delta
                );
                Entry.RevealScale, Entry.RevealVelocity = StepNotificationSpring(
                    Entry.RevealScale,
                    Entry.RevealVelocity,
                    Entry.RevealTarget,
                    Entry.Exiting and 0.16 or 0.22,
                    Delta
                );

                Entry.Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
                Entry.Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
                Entry.Inner.Size = UDim2.new(math.clamp(Entry.RevealScale, 0.05, 1), 0, 1, 0);
""",
'notification spring render'))

replacements.append((
"""        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(-62, 0);
        Size = UDim2.new(1, 0, 1, 0);
""",
"""        BorderMode = Enum.BorderMode.Inset;
        ClipsDescendants = true;
        Position = UDim2.fromOffset(-48, 0);
        Size = UDim2.new(1, 0, 1, 0);
""",
'notification shell clipping'))

replacements.append((
"""    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local ProgressClip = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.new(0, 7, 1, -4);
        Size = UDim2.new(1, -14, 0, 2);
        ZIndex = 105;
        Parent = InnerFrame;
    });
""",
"""    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.new(0, 3, 1, 0);
        ZIndex = 105;
        Parent = NotifyInner;
    });

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    local LeftGradient = Library:AddMovingAccentGradient(LeftColor, 1.6);
    if LeftGradient then LeftGradient.Rotation = 90; end

    local ProgressClip = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.new(0, 3, 1, -1);
        Size = UDim2.new(1, -4, 0, 2);
        ZIndex = 105;
        Parent = NotifyInner;
    });
""",
'accent line and progress placement'))

for old, new, label in replacements:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, found {count}')
    text = text.replace(old, new, 1)

path.write_text(text)
