from pathlib import Path

p = Path('Library.lua')
s = p.read_text()

# Replace the Target HUD implementation wholesale so layout/auto-target state stay coherent.
start = s.index('function Library:CreateTargetHUD(Config)')
end = s.index('function Library:Notify(Text, Time)', start)
replacement = Path('.github/patches/target-hud-v3.txt').read_text().rstrip() + '\n\n'
s = s[:start] + replacement + s[end:]

old_watermark = """    local WatermarkTextOutline = WatermarkLabel:FindFirstChildOfClass('UIStroke');
    if WatermarkTextOutline then
        WatermarkTextOutline.Color = Color3.new(0, 0, 0);
        WatermarkTextOutline.Thickness = 1.2;
        WatermarkTextOutline.Transparency = 0.06;
        WatermarkTextOutline.LineJoinMode = Enum.LineJoinMode.Round;
    end
"""
new_watermark = """    WatermarkLabel.TextStrokeColor3 = Color3.new(0, 0, 0);
    WatermarkLabel.TextStrokeTransparency = 0.08;

    local WatermarkTextOutline = WatermarkLabel:FindFirstChildOfClass('UIStroke');
    if not WatermarkTextOutline then
        WatermarkTextOutline = Library:Create('UIStroke', {
            Name = 'FormaWatermarkTextOutline';
            Color = Color3.new(0, 0, 0);
            Thickness = 1.1;
            Transparency = 0.08;
            LineJoinMode = Enum.LineJoinMode.Round;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
            Parent = WatermarkLabel;
        });
    else
        WatermarkTextOutline.Color = Color3.new(0, 0, 0);
        WatermarkTextOutline.Thickness = 1.1;
        WatermarkTextOutline.Transparency = 0.08;
        WatermarkTextOutline.LineJoinMode = Enum.LineJoinMode.Round;
        pcall(function() WatermarkTextOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; end);
    end
"""
if old_watermark not in s:
    raise SystemExit('watermark outline marker missing')
s = s.replace(old_watermark, new_watermark, 1)

old_drag_start = """        CancelPositionTween();
        State.Dragging = true;
"""
new_drag_start = """        CancelPositionTween();
        State.ReleaseSequence = (State.ReleaseSequence or 0) + 1;
        local ReleaseSequence = State.ReleaseSequence;
        State.Dragging = true;
"""
if old_drag_start not in s:
    raise SystemExit('drag start marker missing')
s = s.replace(old_drag_start, new_drag_start, 1)

old_release = """        State.Dragging = false;
        State.TargetPosition = UDim2.fromOffset(Target.X, Target.Y);

        if Instance.Parent then
            local Manager = Library.MenuManager;
            local ReleaseDuration = 0.14;
            if Manager and Manager.GetReleaseDuration then
                ReleaseDuration = Manager:GetReleaseDuration();
            end
            Library:TweenMenuProperty(Instance, 'Position', State.TargetPosition, ReleaseDuration);
        end
"""
new_release = """        State.Dragging = false;
        State.TargetPosition = UDim2.fromOffset(Target.X, Target.Y);

        if Instance.Parent then
            local Manager = Library.MenuManager;
            local ReleaseDuration = 0.28;
            local ReleaseStyle = Enum.EasingStyle.Quint;
            local ReleaseDirection = Enum.EasingDirection.Out;

            if Manager then
                if Manager.GetReleaseDuration then
                    ReleaseDuration = Manager:GetReleaseDuration();
                end
                if Manager.GetEasingStyle then
                    ReleaseStyle = Manager:GetEasingStyle();
                end
                if Manager.GetEasingDirection then
                    ReleaseDirection = Manager:GetEasingDirection();
                end
            end

            ReleaseDuration = math.max(tonumber(ReleaseDuration) or 0.28, 0.08);
            local StartAnchor = Vector2.new(
                Instance.AbsolutePosition.X + (Instance.AbsoluteSize.X * Instance.AnchorPoint.X),
                Instance.AbsolutePosition.Y + (Instance.AbsoluteSize.Y * Instance.AnchorPoint.Y)
            );
            local Started = os.clock();

            while Instance.Parent and State.ReleaseSequence == ReleaseSequence do
                local Alpha = math.clamp((os.clock() - Started) / ReleaseDuration, 0, 1);
                local StyleAlpha = TweenService:GetValue(Alpha, ReleaseStyle, ReleaseDirection);
                local SmoothAlpha = Alpha * Alpha * (3 - (2 * Alpha));
                local Eased = math.clamp((StyleAlpha * 0.62) + (SmoothAlpha * 0.38), 0, 1);
                local Position = StartAnchor:Lerp(Target, Eased);
                Instance.Position = UDim2.fromOffset(Position.X, Position.Y);

                if Alpha >= 1 then
                    break;
                end
                RenderStepped:Wait();
            end

            if Instance.Parent and State.ReleaseSequence == ReleaseSequence then
                Instance.Position = State.TargetPosition;
            end
        end
"""
if old_release not in s:
    raise SystemExit('drag release marker missing')
s = s.replace(old_release, new_release, 1)

p.write_text(s)
