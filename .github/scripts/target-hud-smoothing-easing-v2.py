from pathlib import Path
p=Path('Library.lua')
s=p.read_text()
def r(old,new,label):
 global s
 if s.count(old)!=1: raise SystemExit(f'{label}: {s.count(old)} matches')
 s=s.replace(old,new,1)

r("""    Library:AddToRegistry(ContentFrame, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local AvatarOuter = Library:Create('Frame', {
""","""    Library:AddToRegistry(ContentFrame, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local function AddTargetHUDOutline(Frame, Name, Transparency)
        local Stroke = Library:Create('UIStroke', {
            Name = Name;
            Color = Library.OutlineColor;
            Thickness = 1;
            Transparency = Transparency or 0.08;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            LineJoinMode = Enum.LineJoinMode.Round;
            Parent = Frame;
        });
        Library:AddToRegistry(Stroke, { Color = 'OutlineColor'; }, true);
        return Stroke;
    end
    local ContentOutline = AddTargetHUDOutline(ContentFrame, 'FormaTargetContentOutline', 0.10);

    local AvatarOuter = Library:Create('Frame', {
""",'content outline')
r("""    Library:AddToRegistry(AvatarOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local Avatar = Library:Create('ImageLabel', {
""","""    Library:AddToRegistry(AvatarOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local AvatarOutline = AddTargetHUDOutline(AvatarOuter, 'FormaTargetAvatarOutline', 0.06);

    local Avatar = Library:Create('ImageLabel', {
""",'avatar outline')
r("""    Library:AddToRegistry(HealthOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local HealthInner = Library:Create('Frame', {
""","""    Library:AddToRegistry(HealthOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local HealthOutline = AddTargetHUDOutline(HealthOuter, 'FormaTargetHealthOutline', 0.04);

    local HealthInner = Library:Create('Frame', {
""",'health outline')

start=s.index("    local HealthGradient = Library:Create('UIGradient', {")
end=s.index("    local function CountVisibleLabels()",start)
health="""    local HealthGradient = Library:Create('UIGradient', {
        Rotation = 0;
        Offset = Vector2.new(-0.20, 0);
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 38, 38)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(180, 55, 55)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 120)),
            ColorSequenceKeypoint.new(0.72, Color3.fromRGB(180, 55, 55)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 38, 38)),
        });
        Parent = HealthFill;
    });

    local HealthDriver = Instance.new('NumberValue');
    HealthDriver.Name = 'FormaTargetHealthDriver';
    HealthDriver.Value = 0;
    HealthDriver.Parent = HealthOuter;
    local HealthVelocity = 0;
    local HealthGradientPhase = 0;
    local HealthSmoothTime = math.clamp(tonumber(Config.HealthSmoothTime or Config.HealthTweenTime) or 0.20, 0.06, 1.2);
    local HealthGradientSpeed = math.max(tonumber(Config.HealthGradientSpeed) or 1.15, 0);

    local function HealthColor(Ratio, Brightness, Saturation)
        return Color3.fromHSV(math.clamp(Ratio, 0, 1) * 0.33, Saturation or 0.78, Brightness);
    end

    local function UpdateHealthGradient(Ratio)
        local Deep = HealthColor(Ratio, 0.38, 0.84);
        local Base = HealthColor(Ratio, 0.68, 0.78);
        local Light = HealthColor(Ratio, 0.92, 0.62);
        local Shine = Light:Lerp(Color3.new(1, 1, 1), 0.20);
        HealthGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Deep),
            ColorSequenceKeypoint.new(0.24, Base),
            ColorSequenceKeypoint.new(0.50, Shine),
            ColorSequenceKeypoint.new(0.76, Base),
            ColorSequenceKeypoint.new(1, Deep),
        });
    end

    local function UpdateHealthVisual()
        local Ratio = math.clamp(HealthDriver.Value, 0, 1);
        HealthFill.Size = UDim2.new(Ratio, 0, 1, 0);
        UpdateHealthGradient(Ratio);
        if HUD.HealthAvailable then
            local Current = math.max(0, math.floor((Ratio * HUD.HealthMax) + 0.5));
            if type(HUD.HealthTextFormatter) == 'function' then
                local Success, Result = pcall(HUD.HealthTextFormatter, Current, HUD.HealthMax, Ratio, HUD.Target, HUD);
                HealthValueLabel.Text = Success and tostring(Result) or string.format('%d HP', Current);
            else
                HealthValueLabel.Text = string.format('%d HP', Current);
            end
        else
            HealthValueLabel.Text = '-- HP';
        end
    end

    local function StepHealthVisual(Delta)
        if not HUD.HealthAvailable or HUD.HealthTargetRatio < 0 then return; end
        local Target = math.clamp(HUD.HealthTargetRatio, 0, 1);
        local Current = math.clamp(HealthDriver.Value, 0, 1);
        local Dt = math.min(math.max(Delta, 0), 0.05);
        local Omega = 2 / math.max(HealthSmoothTime, 0.001);
        local X = Omega * Dt;
        local Exp = 1 / (1 + X + (0.48 * X * X) + (0.235 * X * X * X));
        local Change = Current - Target;
        local Temp = (HealthVelocity + (Omega * Change)) * Dt;
        HealthVelocity = (HealthVelocity - (Omega * Temp)) * Exp;
        local Next = Target + ((Change + Temp) * Exp);
        if math.abs(Target - Next) < 0.00005 and math.abs(HealthVelocity) < 0.00005 then Next=Target; HealthVelocity=0; end
        HealthDriver.Value = math.clamp(Next, 0, 1);
    end
    HealthDriver:GetPropertyChangedSignal('Value'):Connect(UpdateHealthVisual);

"""
s=s[:start]+health+s[end:]

start=s.index("    function HUD:SetHealth(Current, Maximum, Instant)")
end=s.index("    local function ResolveHealth(Target)",start)
sethealth="""    function HUD:SetHealth(Current, Maximum, Instant)
        Current = tonumber(Current);
        Maximum = tonumber(Maximum);
        if not Current or not Maximum or Maximum <= 0 then
            HUD.HealthAvailable = false;
            HUD.HealthMax = 100;
            HUD.HealthTargetRatio = 0;
            HealthVelocity = 0;
            HealthDriver.Value = 0;
            UpdateHealthVisual();
            return;
        end
        HUD.HealthAvailable = true;
        HUD.HealthMax = math.max(1, Maximum);
        HUD.HealthTargetRatio = math.clamp(Current / HUD.HealthMax, 0, 1);
        if Instant then
            HealthVelocity = 0;
            HealthDriver.Value = HUD.HealthTargetRatio;
        else
            UpdateHealthVisual();
        end
    end

"""
s=s[:start]+sethealth+s[end:]
s=s.replace("        if HealthTween then pcall(function() HealthTween:Cancel(); end); HealthTween = nil; end\n",'',1)
s=s.replace("        if HealthGradientTween then pcall(function() HealthGradientTween:Cancel(); end); end\n",'',1)
r("""    Library:GiveSignal(RenderStepped:Connect(function(Delta)
        if not Outer.Parent then return; end

        if HUD.Target and Outer.Visible then
""","""    Library:GiveSignal(RenderStepped:Connect(function(Delta)
        if not Outer.Parent then return; end

        StepHealthVisual(Delta);
        HealthGradientPhase = HealthGradientPhase + (Delta * HealthGradientSpeed);
        HealthGradient.Offset = Vector2.new(math.sin(HealthGradientPhase) * 0.22, 0);
        HealthGradient.Rotation = math.sin(HealthGradientPhase * 0.55) * 3.5;

        if HUD.Target and Outer.Visible then
""",'render driver')
r("""                local Alpha = math.clamp((os.clock() - Started) / ReleaseDuration, 0, 1);
                local StyleAlpha = TweenService:GetValue(Alpha, ReleaseStyle, ReleaseDirection);
                local SmoothAlpha = Alpha * Alpha * (3 - (2 * Alpha));
                local Eased = math.clamp((StyleAlpha * 0.62) + (SmoothAlpha * 0.38), 0, 1);
                local Position = StartAnchor:Lerp(Target, Eased);
""","""                local Alpha = math.clamp((os.clock() - Started) / ReleaseDuration, 0, 1);
                local Eased;
                if Manager and Manager.GetEasedAlpha then
                    local Success, Value = pcall(Manager.GetEasedAlpha, Manager, Alpha, 'Release');
                    if Success then Eased = Value; end
                end
                if Eased == nil then
                    local Raw = math.clamp(TweenService:GetValue(Alpha, ReleaseStyle, ReleaseDirection), 0, 1);
                    local Smooth = Alpha * Alpha * Alpha * (Alpha * ((Alpha * 6) - 15) + 10);
                    local Mixed = math.clamp(Smooth + ((Raw - Smooth) * 0.20), 0, 1);
                    Eased = Mixed * Mixed * Mixed * (Mixed * ((Mixed * 6) - 15) + 10);
                end
                local Position = StartAnchor:Lerp(Target, math.clamp(Eased, 0, 1));
""",'release easing')
r("""    HUD.ContentFrame = ContentFrame;
    HUD.Avatar = Avatar;
""","""    HUD.ContentFrame = ContentFrame;
    HUD.ContentOutline = ContentOutline;
    HUD.AvatarOutline = AvatarOutline;
    HUD.HealthOutline = HealthOutline;
    HUD.Avatar = Avatar;
""",'outline handles')
p.write_text(s)
block=s[s.index('function Library:CreateTargetHUD'):s.index('function Library:Notify',s.index('function Library:CreateTargetHUD'))]
assert 'local HealthTween' not in block
assert 'HealthGradientTween' not in block
assert 'FormaTargetContentOutline' in block and 'StepHealthVisual(Delta)' in block
assert 'Manager.GetEasedAlpha' in s
