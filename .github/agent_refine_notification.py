from pathlib import Path

path = Path('Library.lua')
text = path.read_text()

old_area = """do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });

    local WatermarkOuter = Library:Create('CanvasGroup', {
"""

new_area = """do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 380, 0, 320);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library.NotificationEntries = {};
    Library.NotificationGap = 6;

    local function StepNotificationSpring(Current, Velocity, Target, SmoothTime, Delta)
        local Dt = math.min(math.max(tonumber(Delta) or 0, 0), 0.05);
        local Omega = 2 / math.max(SmoothTime, 0.001);
        local X = Omega * Dt;
        local Exp = 1 / (1 + X + (0.48 * X * X) + (0.235 * X * X * X));
        local Change = Current - Target;
        local Temp = (Velocity + (Omega * Change)) * Dt;
        local NewVelocity = (Velocity - (Omega * Temp)) * Exp;
        local NewValue = Target + ((Change + Temp) * Exp);

        if math.abs(Target - NewValue) < 0.001 and math.abs(NewVelocity) < 0.001 then
            return Target, 0;
        end
        return NewValue, NewVelocity;
    end

    function Library:ReflowNotifications()
        local Y = 0;
        for _, Entry in ipairs(Library.NotificationEntries) do
            if Entry.Outer and Entry.Outer.Parent and not Entry.Exiting then
                Entry.TargetY = Y;
                Y = Y + Entry.Height + Library.NotificationGap;
            end
        end
    end

    function Library:RegisterNotificationMotion(Outer, Inner, Height, ProgressBar, Duration)
        local Entry = {
            Outer = Outer;
            Inner = Inner;
            Height = Height;
            ProgressBar = ProgressBar;
            Duration = math.max(tonumber(Duration) or 5, 0.1);
            Started = os.clock();
            TargetY = 0;
            VisualY = 0;
            StackVelocity = 0;
            SlideX = -62;
            SlideTarget = 0;
            SlideVelocity = 0;
            Exiting = false;
        };

        table.insert(Library.NotificationEntries, Entry);
        Library:ReflowNotifications();
        Entry.VisualY = Entry.TargetY + 10;
        Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
        Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
        return Entry;
    end

    function Library:BeginNotificationExit(Entry)
        if not Entry or Entry.Exiting then return; end
        Entry.Exiting = true;
        Entry.SlideTarget = -62;
        if Entry.ProgressBar and Entry.ProgressBar.Parent then
            Entry.ProgressBar.Size = UDim2.new(1, 0, 1, 0);
        end
        Library:ReflowNotifications();
    end

    function Library:ReleaseNotificationMotion(Entry)
        if not Entry then return; end
        local Index = table.find(Library.NotificationEntries, Entry);
        if Index then table.remove(Library.NotificationEntries, Index); end
        Library:ReflowNotifications();
    end

    Library:GiveSignal(RenderStepped:Connect(function(Delta)
        local Dirty = false;
        for Index = #Library.NotificationEntries, 1, -1 do
            local Entry = Library.NotificationEntries[Index];
            if not Entry.Outer or not Entry.Outer.Parent then
                table.remove(Library.NotificationEntries, Index);
                Dirty = true;
            else
                Entry.VisualY, Entry.StackVelocity = StepNotificationSpring(
                    Entry.VisualY,
                    Entry.StackVelocity,
                    Entry.TargetY,
                    0.17,
                    Delta
                );
                Entry.SlideX, Entry.SlideVelocity = StepNotificationSpring(
                    Entry.SlideX,
                    Entry.SlideVelocity,
                    Entry.SlideTarget,
                    Entry.Exiting and 0.09 or 0.13,
                    Delta
                );

                Entry.Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
                Entry.Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);

                if Entry.ProgressBar and Entry.ProgressBar.Parent and not Entry.Exiting then
                    local Progress = math.clamp((os.clock() - Entry.Started) / Entry.Duration, 0, 1);
                    Entry.ProgressBar.Size = UDim2.new(Progress, 0, 1, 0);
                end
            end
        end
        if Dirty then Library:ReflowNotifications(); end
    end));

    local WatermarkOuter = Library:Create('CanvasGroup', {
"""

old_notify = """    Text = tostring(Text or '');
    Title = Title ~= nil and tostring(Title) or '';
    local HasTitle = Title ~= '';
    local TextSize = HasTitle and 13 or 14;
    local TextWidth, TextHeight = Library:GetTextBounds(Text, Library.Font, TextSize);
    local TitleWidth, TitleHeight = 0, 0;
    if HasTitle then
        TitleWidth, TitleHeight = Library:GetTextBounds(Title, Library.Font, 14);
    end;
    local XSize = math.max(TextWidth, TitleWidth) + 14;
    local YSize = HasTitle and (TitleHeight + TextHeight + 10) or (TextHeight + 7);
    local Duration = math.max(tonumber(Time) or 5, 0.1);

    local NotifyOuter = Library:Create('CanvasGroup', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, XSize, 0, YSize);
        ClipsDescendants = false;
        GroupTransparency = 1;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(-28, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });
"""

new_notify = """    Text = tostring(Text or '');
    Title = Title ~= nil and tostring(Title) or '';
    local HasTitle = Title ~= '';
    local TextSize = 14;
    local TextWidth, TextHeight = Library:GetTextBounds(Text, Library.Font, TextSize);
    local TitleWidth, TitleHeight = 0, 0;
    if HasTitle then
        TitleWidth, TitleHeight = Library:GetTextBounds(Title, Library.Font, 15);
    end;
    local XSize = math.max(math.max(TextWidth, TitleWidth) + 24, 190);
    local YSize = HasTitle and (TitleHeight + TextHeight + 18) or (TextHeight + 14);
    local Duration = math.max(tonumber(Time) or 5, 0.1);

    local NotifyOuter = Library:Create('CanvasGroup', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(8, 0);
        Size = UDim2.new(0, XSize, 0, YSize);
        ClipsDescendants = false;
        GroupTransparency = 1;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(-62, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });
"""

old_labels = """    if HasTitle then
        local NotifyTitle = Library:CreateLabel({
            Position = UDim2.fromOffset(5, 1);
            Size = UDim2.new(1, -10, 0, TitleHeight + 2);
            Text = Title;
            TextColor3 = Library.AccentColor;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            ZIndex = 104;
            Parent = InnerFrame;
        });
        Library.RegistryMap[NotifyTitle].Properties.TextColor3 = 'AccentColor';
    end;

    Library:CreateLabel({
        Position = UDim2.fromOffset(5, HasTitle and (TitleHeight + 3) or 0);
        Size = UDim2.new(1, -10, 0, TextHeight + (HasTitle and 2 or 7));
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = TextSize;
        ZIndex = 103;
        Parent = InnerFrame;
    });
"""

new_labels = """    if HasTitle then
        local NotifyTitle = Library:CreateLabel({
            Position = UDim2.fromOffset(8, 3);
            Size = UDim2.new(1, -16, 0, TitleHeight + 2);
            Text = Title;
            TextColor3 = Library.AccentColor;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 15;
            ZIndex = 104;
            Parent = InnerFrame;
        });
        Library.RegistryMap[NotifyTitle].Properties.TextColor3 = 'AccentColor';
    end;

    Library:CreateLabel({
        Position = UDim2.fromOffset(8, HasTitle and (TitleHeight + 6) or 2);
        Size = UDim2.new(1, -16, 0, TextHeight + 3);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = TextSize;
        ZIndex = 103;
        Parent = InnerFrame;
    });
"""

old_progress = """    local TimeTrack = Library:Create('Frame', {
        BackgroundColor3 = Library.OutlineColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 3, 1, -3);
        Size = UDim2.new(1, -6, 0, 2);
        ZIndex = 105;
        Parent = NotifyInner;
    });
    Library:AddToRegistry(TimeTrack, {
        BackgroundColor3 = 'OutlineColor';
    }, true);

    local TimeBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = 106;
        Parent = TimeTrack;
    });
    Library:AddToRegistry(TimeBar, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    Library:SetUnifiedFadeProgress(NotifyOuter, 0);
    Library:Animate(NotifyInner, { Position = UDim2.fromOffset(0, 0); }, 0.30, nil, 'Notification');
    Library:TweenUnifiedFade(NotifyOuter, 1, 0.24, nil, 'Fade');

    local TimeBarTween = TweenService:Create(
        TimeBar,
        TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 1, 0) }
    );
    TimeBarTween:Play();

    task.delay(Duration, function()
        if not NotifyOuter.Parent then return; end
        Library:Animate(NotifyInner, { Position = UDim2.fromOffset(-28, 0); }, 0.22, nil, 'NotificationExit');
        Library:TweenUnifiedFade(NotifyOuter, 0, 0.20, function(State)
            if State ~= Enum.PlaybackState.Cancelled and NotifyOuter.Parent then NotifyOuter:Destroy(); end
        end, 'Fade');
    end);
"""

new_progress = """    local ProgressClip = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.new(0, 7, 1, -4);
        Size = UDim2.new(1, -14, 0, 2);
        ZIndex = 105;
        Parent = InnerFrame;
    });

    local TimeBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = 106;
        Parent = ProgressClip;
    });
    Library:AddToRegistry(TimeBar, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    Library:AddMovingAccentGradient(TimeBar, 1.6);

    local Motion = Library:RegisterNotificationMotion(NotifyOuter, NotifyInner, YSize, TimeBar, Duration);
    Library:SetUnifiedFadeProgress(NotifyOuter, 0);
    Library:TweenUnifiedFade(NotifyOuter, 1, 0.28, nil, 'Fade');

    task.delay(Duration, function()
        if not NotifyOuter.Parent then return; end
        Library:BeginNotificationExit(Motion);
        Library:TweenUnifiedFade(NotifyOuter, 0, 0.28, function(State)
            if State ~= Enum.PlaybackState.Cancelled then
                Library:ReleaseNotificationMotion(Motion);
                if NotifyOuter.Parent then NotifyOuter:Destroy(); end
            end
        end, 'Fade');
    end);
"""

replacements = [
    (old_area, new_area, 'notification area'),
    (old_notify, new_notify, 'notification sizing'),
    (old_labels, new_labels, 'notification labels'),
    (old_progress, new_progress, 'notification progress/motion'),
]

for old, new, label in replacements:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, found {count}')
    text = text.replace(old, new, 1)

path.write_text(text)
