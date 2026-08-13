local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local HttpService = game:GetService('HttpService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local RepoFontBaseUrl = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/";

local Fonts = {
    ["Rubik Light"] = {
        Ttf = "Rubik-Light.ttf",
        RepoPath = "fonts/Rubik-Light.ttf",
        Url = RepoFontBaseUrl .. "fonts/Rubik-Light.ttf",
        FaceName = "Light",
        Weight = Enum.FontWeight.Light,
        WeightValue = 300,
    },
    Miracode = {
        Ttf = "Miracode.ttf",
        RepoPath = "fonts/Miracode.ttf",
        Url = RepoFontBaseUrl .. "fonts/Miracode.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    Monocraft = {
        Ttf = "Monocraft.ttf",
        RepoPath = "fonts/Monocraft.ttf",
        Url = RepoFontBaseUrl .. "fonts/Monocraft.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ProggyClean = {
        Ttf = "ProggyClean.ttf",
        RepoPath = "fonts/ProggyClean.ttf",
        Url = RepoFontBaseUrl .. "fonts/ProggyClean.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ProggyTiny = {
        Ttf = "ProggyTiny.ttf",
        RepoPath = "fonts/ProggyTiny.ttf",
        Url = RepoFontBaseUrl .. "fonts/ProggyTiny.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ["XP Tahoma"] = {
        Ttf = "XP-Tahoma.ttf",
        RepoPath = "fonts/XP-Tahoma.ttf",
        Url = RepoFontBaseUrl .. "fonts/XP-Tahoma.ttf",
        FaceName = "Bold",
        Weight = Enum.FontWeight.Bold,
        WeightValue = 700,
    },
    ["Smallest Pixel"] = {
        Ttf = "Smallest-Pixel.ttf",
        RepoPath = "fonts/Smallest-Pixel.ttf",
        Url = RepoFontBaseUrl .. "fonts/Smallest-Pixel.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
};

local FontOrder = {
    "Rubik Light",
    "Miracode",
    "Monocraft",
    "ProggyClean",
    "ProggyTiny",
    "XP Tahoma",
    "Smallest Pixel",
};


local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(0, 85, 255);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    RiskColor = Color3.fromRGB(255, 50, 50),

    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.Code,
    FontName = 'Code',
    TextScale = 1;
    TextSize = 14;

    OpenedFrames = {};
    DependencyBoxes = {};

    Signals = {};
    ScreenGui = ScreenGui;
};

local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400);

        if Hue > 1 then
            Hue = 0;
        end;

        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
end))

local function GetPlayersString()
    local PlayerList = Players:GetPlayers();

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    
    return TeamList;
end;


Library.Fonts = Fonts;
Library.FontOrder = FontOrder;

function Library:RegisterRepoFont(Name, FileName)
    assert(type(Name) == 'string' and Name ~= '', 'RegisterRepoFont: invalid font name');
    assert(type(FileName) == 'string' and FileName ~= '', 'RegisterRepoFont: invalid file name');

    local CleanFileName = FileName:gsub('\\', '/'):match('([^/]+)$');
    assert(CleanFileName and CleanFileName:lower():match('%.ttf$'), 'RegisterRepoFont: expected a .ttf file');

    Fonts[Name] = {
        Ttf = CleanFileName;
        RepoPath = 'fonts/' .. CleanFileName;
        Url = RepoFontBaseUrl .. 'fonts/' .. CleanFileName;
    };

    if not table.find(FontOrder, Name) then
        table.insert(FontOrder, Name);
    end;

    return Fonts[Name];
end;
Library.PropertyTweens = setmetatable({}, { __mode = 'k' });
Library.BaseTextSizes = setmetatable({}, { __mode = 'k' });
Library.FadeBaselines = setmetatable({}, { __mode = 'k' });

function Library:GetFontNames()
    local Result = {};

    for _, Name in ipairs(Library.FontOrder) do
        table.insert(Result, Name);
    end;

    return Result;
end;

function Library:ApplyFont(Instance)
    if not Instance then
        return;
    end;

    if typeof(Library.Font) == 'Font' then
        pcall(function()
            Instance.FontFace = Library.Font;
        end);
    else
        pcall(function()
            Instance.Font = Library.Font;
        end);
    end;
end;

function Library:UpdateFont()
    for _, Descendant in ipairs(ScreenGui:GetDescendants()) do
        if Descendant:IsA('TextLabel') or Descendant:IsA('TextBox') or Descendant:IsA('TextButton') then
            Library:ApplyFont(Descendant);
        end;
    end;
end;

function Library:LoadFont(Name)
    local Info = Fonts[Name];
    local GetCustomAsset = getcustomasset or getsynasset;

    if not Info or not GetCustomAsset or not writefile then
        return false;
    end;

    local Success, LoadedFont = pcall(function()
        if makefolder then
            if not isfolder or not isfolder('FormaAssets') then
                pcall(makefolder, 'FormaAssets');
            end;

            if not isfolder or not isfolder('FormaAssets/Fonts') then
                pcall(makefolder, 'FormaAssets/Fonts');
            end;
        end;

        local TtfPath = 'FormaAssets/Fonts/' .. Info.Ttf;
        local RepoPath = Info.RepoPath or ('fonts/' .. Info.Ttf);
        local FontUrl = Info.Url or (RepoFontBaseUrl .. RepoPath);

        writefile(TtfPath, game:HttpGet(FontUrl));

        local TtfAsset = GetCustomAsset(TtfPath);
        local FamilyPath = TtfPath:gsub('%.ttf$', '.font');
        local FamilyData = {
            name = Name;
            faces = {
                {
                    name = Info.FaceName or 'Regular';
                    weight = Info.WeightValue or 400;
                    style = 'normal';
                    assetId = TtfAsset;
                };
            };
        };

        writefile(FamilyPath, HttpService:JSONEncode(FamilyData));

        local Face;
        local FamilyAsset = GetCustomAsset(FamilyPath);

        pcall(function()
            Face = Font.new(FamilyAsset, Info.Weight or Enum.FontWeight.Regular, Enum.FontStyle.Normal);
        end);

        if not Face then
            pcall(function()
                Face = Font.new(TtfAsset);
            end);
        end;

        return Face;
    end);

    if not Success or not LoadedFont then
        return false;
    end;

    Library.Font = LoadedFont;
    Library.FontName = Name;
    Library:UpdateFont();
    return true;
end;

function Library:SetFont(Name)
    return Library:LoadFont(Name);
end;

function Library:GetScaledTextSize(BaseSize)
    BaseSize = tonumber(BaseSize) or 14;
    local Scale = (Library.TextSize or 14) / 14;
    return math.max(6, math.floor((BaseSize * Scale) + 0.5));
end;

function Library:SetTextSize(Size)
    Size = math.clamp(math.floor((tonumber(Size) or 14) + 0.5), 9, 24);
    Library.TextSize = Size;
    Library.TextScale = Size / 14;

    for Instance, BaseSize in next, Library.BaseTextSizes do
        if Instance and Instance.Parent then
            pcall(function()
                Instance.TextSize = Library:GetScaledTextSize(BaseSize);
            end);
        end;
    end;

    return Size;
end;

function Library:SetTextScale(Scale)
    return Library:SetTextSize(14 * math.clamp(tonumber(Scale) or 1, 0.65, 1.75));
end;

Library:LoadFont('Rubik Light');

function Library:TweenProperty(Instance, Property, Value, Duration)
    if not Instance then
        return;
    end;

    local InstanceTweens = Library.PropertyTweens[Instance];

    if not InstanceTweens then
        InstanceTweens = {};
        Library.PropertyTweens[Instance] = InstanceTweens;
    end;

    local Previous = InstanceTweens[Property];

    if Previous then
        pcall(function()
            Previous:Cancel();
        end);
    end;

    local Tween;
    local Success = pcall(function()
        Tween = TweenService:Create(
            Instance,
            TweenInfo.new(Duration or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { [Property] = Value }
        );
    end);

    if not Success or not Tween then
        Instance[Property] = Value;
        return;
    end;

    InstanceTweens[Property] = Tween;
    Tween:Play();

    Tween.Completed:Connect(function()
        if InstanceTweens[Property] == Tween then
            InstanceTweens[Property] = nil;
        end;
    end);
end;

function Library:GetFadePropertyNames(Instance)
    local Properties = {};

    if Instance:IsA('GuiObject') then
        table.insert(Properties, 'BackgroundTransparency');
    end;

    if Instance:IsA('TextLabel') or Instance:IsA('TextBox') or Instance:IsA('TextButton') then
        table.insert(Properties, 'TextTransparency');
        table.insert(Properties, 'TextStrokeTransparency');
    end;

    if Instance:IsA('ImageLabel') or Instance:IsA('ImageButton') then
        table.insert(Properties, 'ImageTransparency');
    end;

    if Instance:IsA('ScrollingFrame') then
        table.insert(Properties, 'ScrollBarImageTransparency');
    end;

    if Instance:IsA('UIStroke') then
        table.insert(Properties, 'Transparency');
    end;

    return Properties;
end;

function Library:PrimeFadeTree(Root)
    if not Root then
        return;
    end;

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Properties = Library:GetFadePropertyNames(Instance);
        if #Properties > 0 then
            local Cache = Library.FadeBaselines[Instance];
            if not Cache then
                Cache = {};
                Library.FadeBaselines[Instance] = Cache;
            end;

            for _, Property in ipairs(Properties) do
                if Cache[Property] == nil then
                    local Success, Value = pcall(function()
                        return Instance[Property];
                    end);

                    if Success then
                        Cache[Property] = Value;
                    end;
                end;
            end;
        end;
    end;
end;

function Library:SetFadeTree(Root, Hidden)
    if not Root then
        return;
    end;

    Library:PrimeFadeTree(Root);

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            for Property, Baseline in next, Cache do
                pcall(function()
                    Instance[Property] = Hidden and 1 or Baseline;
                end);
            end;
        end;
    end;
end;

function Library:TweenFadeTree(Root, Hidden, Duration)
    if not Root then
        return;
    end;

    Library:PrimeFadeTree(Root);
    Duration = Duration or 0.2;

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            for Property, Baseline in next, Cache do
                Library:TweenProperty(Instance, Property, Hidden and 1 or Baseline, Duration);
            end;
        end;
    end;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return Library:Notify(event);
        end;

        return Library:Notify(event:sub(i + 1), 3);
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    local IsTextObject = _Instance:IsA('TextLabel') or _Instance:IsA('TextBox') or _Instance:IsA('TextButton');
    local ExplicitTextSize = IsTextObject and Properties.TextSize or nil;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    if IsTextObject then
        local BaseSize = ExplicitTextSize or Library.BaseTextSizes[_Instance] or _Instance.TextSize;
        Library.BaseTextSizes[_Instance] = BaseSize;
        _Instance.TextSize = Library:GetScaledTextSize(BaseSize);
    end;

    return _Instance;
end;

function Library:AddCorner(Instance, Radius)
    if not Instance then
        return nil;
    end;

    local Corner = Instance:FindFirstChildOfClass('UICorner');
    if not Corner then
        Corner = Library:Create('UICorner', {
            Parent = Instance;
        });
    end;

    Corner.CornerRadius = UDim.new(0, Radius or 3);
    return Corner;
end;


function Library:AddAccentGlow(Instance, Scale)
    if not Instance then
        return;
    end;

    Scale = tonumber(Scale) or 1;
    local Layers = {
        { 0.70, 0.42 },
        { 0.92, 0.54 },
        { 1.14, 0.66 },
        { 1.38, 0.76 },
        { 1.64, 0.84 },
        { 1.90, 0.90 },
        { 2.18, 0.95 },
    };

    for Index, Info in ipairs(Layers) do
        local Name = 'FormaAccentGlow' .. Index;
        local Stroke = Instance:FindFirstChild(Name);

        if not Stroke then
            Stroke = Library:Create('UIStroke', {
                Name = Name;
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Color = Library.AccentColor;
                LineJoinMode = Enum.LineJoinMode.Round;
                Thickness = Info[1] * Scale;
                Transparency = Info[2];
                Parent = Instance;
            });

            Library:AddToRegistry(Stroke, {
                Color = 'AccentColor';
            });
        else
            Stroke.Thickness = Info[1] * Scale;
            Stroke.Transparency = Info[2];
        end;
    end;
end;

function Library:AddTopCorners(Instance, Radius)
    if not Instance then
        return nil;
    end;

    Radius = Radius or 3;
    Library:AddCorner(Instance, Radius);

    local BottomSquare = Library:Create('Frame', {
        BackgroundColor3 = Instance.BackgroundColor3;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 1, -Radius);
        Size = UDim2.new(1, 0, 0, Radius);
        ZIndex = Instance.ZIndex;
        Parent = Instance;
    });

    Instance:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
        BottomSquare.BackgroundColor3 = Instance.BackgroundColor3;
    end);

    return BottomSquare;
end;

function Library:AddTabAccentCap(Instance)
    local Cap = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        ZIndex = Instance.ZIndex + 5;
        Parent = Instance;
    });

    local Top = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 2, 0, 0);
        Size = UDim2.new(1, -4, 0, 1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    local Left = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 1);
        Size = UDim2.new(0, 1, 0.62, -1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    local Right = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0);
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(1, 0, 0, 1);
        Size = UDim2.new(0, 1, 0.62, -1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    for _, Side in ipairs({ Left, Right }) do
        Library:Create('UIGradient', {
            Rotation = 90;
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.25),
                NumberSequenceKeypoint.new(1, 1),
            });
            Parent = Side;
        });
    end;

    for _, Element in ipairs({ Top, Left, Right }) do
        Library:AddToRegistry(Element, {
            BackgroundColor3 = 'AccentColor';
        });
    end;

    local function SetActive(Active)
        local Transparency = Active and 0 or 1;
        for _, Element in ipairs({ Top, Left, Right }) do
            Library:TweenProperty(Element, 'BackgroundTransparency', Transparency, 0.18);
        end;
    end;

    SetActive(false);
    return SetActive;
end;

function Library:CreateSlidingTabIndicator(Layer, Height)
    local Controller = {};
    local Connection;
    local VisualLeft = 0;
    local VisualRight = 0;
    local TargetLeft = 0;
    local TargetRight = 0;
    local TargetY = 0;
    local Direction = 1;

    local Indicator = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.fromOffset(0, Height or 21);
        Visible = false;
        ZIndex = 20;
        Parent = Layer;
    });

    Library:AddCorner(Indicator, 3);

    local Stroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        LineJoinMode = Enum.LineJoinMode.Round;
        Thickness = 1;
        Transparency = 0;
        Parent = Indicator;
    });

    Library:Create('UIGradient', {
        Rotation = 90;
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.30, 0.01),
            NumberSequenceKeypoint.new(0.55, 0.22),
            NumberSequenceKeypoint.new(0.78, 0.76),
            NumberSequenceKeypoint.new(1, 1),
        });
        Parent = Stroke;
    });

    Library:AddToRegistry(Stroke, { Color = 'AccentColor'; });

    local function RenderIndicator()
        local Width = math.max(VisualRight - VisualLeft, 1);
        Indicator.Position = UDim2.fromOffset(VisualLeft, TargetY);
        Indicator.Size = UDim2.fromOffset(Width, Height or Indicator.Size.Y.Offset);
    end;

    local function StopAnimation()
        if Connection then
            Connection:Disconnect();
            Connection = nil;
        end;
    end;

    local function StartAnimation()
        if Connection then
            return;
        end;

        Connection = RenderStepped:Connect(function(Delta)
            if not Indicator.Parent then
                StopAnimation();
                return;
            end;

            local LeftDistance = math.abs(TargetLeft - VisualLeft);
            local RightDistance = math.abs(TargetRight - VisualRight);
            local Settling = math.max(LeftDistance, RightDistance) < 7;
            local LeadSpeed = Settling and 31 or 27;
            local TrailSpeed = Settling and 31 or 15;
            local LeftSpeed = Direction < 0 and LeadSpeed or TrailSpeed;
            local RightSpeed = Direction > 0 and LeadSpeed or TrailSpeed;

            local LeftAlpha = 1 - math.exp(-Delta * LeftSpeed);
            local RightAlpha = 1 - math.exp(-Delta * RightSpeed);
            VisualLeft = VisualLeft + ((TargetLeft - VisualLeft) * LeftAlpha);
            VisualRight = VisualRight + ((TargetRight - VisualRight) * RightAlpha);

            if LeftDistance <= 0.08 and RightDistance <= 0.08 then
                VisualLeft = TargetLeft;
                VisualRight = TargetRight;
                RenderIndicator();
                StopAnimation();
                return;
            end;

            RenderIndicator();
        end);
    end;

    function Controller:MoveTo(Button, Instant)
        if not Button or not Button.Parent or Button.AbsoluteSize.X <= 0 then
            return;
        end;

        local NewLeft = Button.AbsolutePosition.X - Layer.AbsolutePosition.X;
        local NewRight = NewLeft + Button.AbsoluteSize.X;
        local NewY = Button.AbsolutePosition.Y - Layer.AbsolutePosition.Y;

        if Instant or not Indicator.Visible or (VisualRight - VisualLeft) <= 0 then
            StopAnimation();
            VisualLeft = NewLeft;
            VisualRight = NewRight;
            TargetLeft = NewLeft;
            TargetRight = NewRight;
            TargetY = NewY;
            Indicator.Visible = true;
            RenderIndicator();
            return;
        end;

        local CurrentCenter = (VisualLeft + VisualRight) * 0.5;
        local TargetCenter = (NewLeft + NewRight) * 0.5;
        Direction = TargetCenter >= CurrentCenter and 1 or -1;
        TargetLeft = NewLeft;
        TargetRight = NewRight;
        TargetY = NewY;
        Indicator.Visible = true;
        StartAnimation();
    end;

    function Controller:Refresh(Button)
        self:MoveTo(Button, true);
    end;

    Controller.Frame = Indicator;
    return Controller;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    });

    Library:ApplyFont(_Instance);
    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            );

            if ObjPos.Y > (Cutoff or 40) then
                return;
            end;

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                );

                RenderStepped:Wait();
            end;
        end;
    end)
end;

function Library:AddToolTip(Info, HoverInstance)
    if type(Info) ~= 'string' and type(Info) ~= 'table' then
        return
    end

    local function NormalizeTooltipText(Value)
        if type(Value) == 'table' then
            local Lines = {};
            for _, Line in ipairs(Value) do
                table.insert(Lines, tostring(Line));
            end;
            return table.concat(Lines, '\n');
        end;

        return type(Value) == 'string' and Value or '';
    end;

    local Title = type(Info) == 'table' and (Info.Title or Info.title) or nil
    local TextValue = type(Info) == 'table' and (Info.Text or Info.Description or Info.text or Info.description or Info.Lines or Info.lines or Info[1]) or Info

    Title = type(Title) == 'string' and Title or nil
    local Text = NormalizeTooltipText(TextValue)

    if not Title and Text == '' then
        return
    end

    local MaxWidth = type(Info) == 'table' and tonumber(Info.MaxWidth or Info.Width) or nil
    MaxWidth = math.clamp(MaxWidth or 280, 120, 500)

    local PaddingX = 7
    local PaddingY = 5
    local Gap = Title and Text ~= '' and 2 or 0
    local TitleX, TitleY = 0, 0
    local TextX, TextY = 0, 0

    if Title then
        TitleX, TitleY = Library:GetTextBounds(Title, Library.Font, 14, Vector2.new(MaxWidth, 10000))
    end

    if Text ~= '' then
        TextX, TextY = Library:GetTextBounds(Text, Library.Font, 13, Vector2.new(MaxWidth, 10000))
    end

    local ContentWidth = math.max(TitleX, TextX, 60)
    local Width = math.min(MaxWidth, ContentWidth) + (PaddingX * 2)
    local Height = PaddingY * 2 + TitleY + TextY + Gap

    local Tooltip = Library:Create('Frame', {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(Width, Height),
        ZIndex = 100,
        Parent = Library.ScreenGui,
        Visible = false,
    })

    local Content = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromScale(1, 1),
        ZIndex = Tooltip.ZIndex,
        Parent = Tooltip,
    })

    Library:AddCorner(Content, 3);

    local Stroke = Library:Create('UIStroke', {
        Color = Library.OutlineColor,
        Thickness = 1,
        Transparency = 1,
        LineJoinMode = Enum.LineJoinMode.Round,
        Parent = Content,
    })

    Library:AddToRegistry(Content, {
        BackgroundColor3 = 'MainColor';
    });

    Library:AddToRegistry(Stroke, {
        Color = 'OutlineColor';
    });

    local TitleLabel
    local BodyLabel

    if Title then
        TitleLabel = Library:CreateLabel({
            Position = UDim2.fromOffset(PaddingX, PaddingY),
            Size = UDim2.new(1, -(PaddingX * 2), 0, TitleY),
            TextSize = 14,
            Text = Title,
            TextColor3 = Library.AccentColor,
            TextTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = Tooltip.ZIndex + 1,
            Parent = Content,
        });

        Library.RegistryMap[TitleLabel].Properties.TextColor3 = 'AccentColor'
    end

    if Text ~= '' then
        BodyLabel = Library:CreateLabel({
            Position = UDim2.fromOffset(PaddingX, PaddingY + TitleY + Gap),
            Size = UDim2.new(1, -(PaddingX * 2), 0, TextY),
            TextSize = 13,
            Text = Text,
            TextColor3 = Library.FontColor,
            TextTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = Tooltip.ZIndex + 1,
            Parent = Content,
        });
    end

    local TitleStroke = TitleLabel and TitleLabel:FindFirstChildOfClass('UIStroke')
    local BodyStroke = BodyLabel and BodyLabel:FindFirstChildOfClass('UIStroke')

    if TitleStroke then
        TitleStroke.Transparency = 1
    end

    if BodyStroke then
        BodyStroke.Transparency = 1
    end

    local IsHovering = false
    local AnimationId = 0
    local FollowConnection
    local ActiveTweens = {}

    local function CancelTweens()
        for _, Tween in next, ActiveTweens do
            pcall(function()
                Tween:Cancel()
            end)
        end

        table.clear(ActiveTweens)
    end

    local function PlayTween(Instance, TweenInfoValue, Properties)
        local Tween = TweenService:Create(Instance, TweenInfoValue, Properties)
        table.insert(ActiveTweens, Tween)
        Tween:Play()
        return Tween
    end

    local function GetTargetPosition()
        local Camera = workspace.CurrentCamera
        local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
        local X = Mouse.X + 18
        local Y = Mouse.Y + 20

        if X + Width + 8 > Viewport.X then
            X = Mouse.X - Width - 14
        end

        if Y + Height + 8 > Viewport.Y then
            Y = Mouse.Y - Height - 14
        end

        return Vector2.new(math.max(8, X), math.max(8, Y))
    end

    local function StartFollowing()
        if FollowConnection then
            FollowConnection:Disconnect()
        end

        local Target = GetTargetPosition()
        Tooltip.Position = UDim2.fromOffset(Target.X, Target.Y)

        FollowConnection = RunService.RenderStepped:Connect(function(Delta)
            if not Tooltip.Visible then
                return
            end

            local Goal = GetTargetPosition()
            local Current = Vector2.new(Tooltip.Position.X.Offset, Tooltip.Position.Y.Offset)
            local Alpha = 1 - math.exp(-Delta * 28)
            local Next = Current:Lerp(Goal, Alpha)

            Tooltip.Position = UDim2.fromOffset(Next.X, Next.Y)
        end)
    end

    local function Show()
        AnimationId = AnimationId + 1
        local CurrentId = AnimationId

        CancelTweens()
        IsHovering = true
        Tooltip.Visible = true
        Content.Position = UDim2.fromOffset(0, 8)
        Content.BackgroundTransparency = 1
        Stroke.Transparency = 1

        if TitleLabel then
            TitleLabel.TextTransparency = 1
        end

        if BodyLabel then
            BodyLabel.TextTransparency = 1
        end

        if TitleStroke then
            TitleStroke.Transparency = 1
        end

        if BodyStroke then
            BodyStroke.Transparency = 1
        end

        StartFollowing()

        local MoveInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local FadeInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        PlayTween(Content, MoveInfo, {
            Position = UDim2.fromOffset(0, 0),
        })

        PlayTween(Content, FadeInfo, {
            BackgroundTransparency = 0,
        })

        PlayTween(Stroke, FadeInfo, {
            Transparency = 0,
        })

        if TitleLabel then
            PlayTween(TitleLabel, FadeInfo, {
                TextTransparency = 0,
            })
        end

        if BodyLabel then
            PlayTween(BodyLabel, FadeInfo, {
                TextTransparency = 0,
            })
        end

        if TitleStroke then
            PlayTween(TitleStroke, FadeInfo, {
                Transparency = 0,
            })
        end

        if BodyStroke then
            PlayTween(BodyStroke, FadeInfo, {
                Transparency = 0,
            })
        end

        task.delay(0.28, function()
            if CurrentId == AnimationId then
                table.clear(ActiveTweens)
            end
        end)
    end

    local function Hide()
        if not Tooltip.Visible then
            return
        end

        AnimationId = AnimationId + 1
        local CurrentId = AnimationId

        CancelTweens()
        IsHovering = false

        local MoveInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local FadeInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        PlayTween(Content, MoveInfo, {
            Position = UDim2.fromOffset(0, -5),
        })

        PlayTween(Content, FadeInfo, {
            BackgroundTransparency = 1,
        })

        PlayTween(Stroke, FadeInfo, {
            Transparency = 1,
        })

        if TitleLabel then
            PlayTween(TitleLabel, FadeInfo, {
                TextTransparency = 1,
            })
        end

        if BodyLabel then
            PlayTween(BodyLabel, FadeInfo, {
                TextTransparency = 1,
            })
        end

        if TitleStroke then
            PlayTween(TitleStroke, FadeInfo, {
                Transparency = 1,
            })
        end

        if BodyStroke then
            PlayTween(BodyStroke, FadeInfo, {
                Transparency = 1,
            })
        end

        task.delay(0.2, function()
            if CurrentId ~= AnimationId or IsHovering then
                return
            end

            Tooltip.Visible = false

            if FollowConnection then
                FollowConnection:Disconnect()
                FollowConnection = nil
            end

            table.clear(ActiveTweens)
        end)
    end

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        Show()
    end)

    HoverInstance.MouseLeave:Connect(Hide)

    return Tooltip
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    local function Apply(PropertiesToApply)
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesToApply do
            local Value = Library[ColorIdx] or ColorIdx;

            if typeof(Value) == 'Color3' then
                Library:TweenProperty(Instance, Property, Value, 0.17);
            else
                Instance[Property] = Value;
            end;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end;

    HighlightInstance.MouseEnter:Connect(function()
        Apply(Properties);
    end);

    HighlightInstance.MouseLeave:Connect(function()
        Apply(PropertiesDefault);
    end);
end;

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

        return true;
    end;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, FontValue, Size, Resolution)
    Size = Library:GetScaledTextSize(Size);
    local MaxResolution = Resolution or Vector2.new(1920, 1080);

    if typeof(FontValue) == 'Font' then
        local Success, Bounds = pcall(function()
            local Params = Instance.new('GetTextBoundsParams');
            Params.Text = Text;
            Params.Font = FontValue;
            Params.Size = Size;
            Params.Width = MaxResolution.X;

            local Result = TextService:GetTextBoundsAsync(Params);
            Params:Destroy();
            return Result;
        end);

        if Success and Bounds then
            return Bounds.X, Bounds.Y;
        end;

        FontValue = Enum.Font.Code;
    end;

    local Bounds = TextService:GetTextSize(Text, Size, FontValue, MaxResolution);
    return Bounds.X, Bounds.Y;
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx];
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end;
    end;
end;

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end

    if Library.OnUnload then
        Library.OnUnload()
    end

    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end))

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;

        assert(Info.Default, 'AddColorPicker: Missing default value.');

        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local CheckerFrame = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });

        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        Library:AddCorner(PickerFrameOuter, 3);
        Library:AddCorner(PickerFrameInner, 3);

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });

        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });

        local HueCursor = Library:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });

        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });

        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });

        Library:ApplyFont(HueBox);

        Library:ApplyTextStroke(HueBox);

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        });

        local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor
        });

        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
        
        if Info.Transparency then 
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameInner;
            });

            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            });

            Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            });

            TransparencyCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            });
        end;

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title;
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,

                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });

            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });

                Library:OnHighlight(Button, Button, 
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    Callback()
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify('Copied color!', 2)
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)

            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library:Notify('Copied hex code to clipboard!', 2)
            end)

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)
        end

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

        Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
        Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        local PickerAnimationId = 0;
        local PickerTweens = {}

        local function GetPickerTargetPosition()
            return UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end;

        local function CancelPickerTweens()
            for _, Tween in next, PickerTweens do
                pcall(function() Tween:Cancel(); end);
            end;
            table.clear(PickerTweens);
        end;

        local function PlayPickerTween(Instance, InfoValue, Properties)
            local Tween = TweenService:Create(Instance, InfoValue, Properties);
            table.insert(PickerTweens, Tween);
            Tween:Play();
            return Tween;
        end;

        function ColorPicker:Show()
            for Frame in next, Library.OpenedFrames do
                if Frame.Name == 'Color' and Frame ~= PickerFrameOuter then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerAnimationId = PickerAnimationId + 1;
            CancelPickerTweens();

            local TargetPosition = GetPickerTargetPosition();
            if not PickerFrameOuter.Visible then
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 28);
                Library:SetFadeTree(PickerFrameOuter, true);
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = TargetPosition;
            });
            Library:TweenFadeTree(PickerFrameOuter, false, 0.26);
        end;

        function ColorPicker:Hide()
            if not PickerFrameOuter.Visible then
                Library.OpenedFrames[PickerFrameOuter] = nil;
                return;
            end;

            PickerAnimationId = PickerAnimationId + 1;
            local CurrentId = PickerAnimationId;
            CancelPickerTweens();
            Library.OpenedFrames[PickerFrameOuter] = nil;

            local TargetPosition = GetPickerTargetPosition();
            Library:TweenFadeTree(PickerFrameOuter, true, 0.20);
            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 12);
            });

            ExitTween.Completed:Connect(function(State)
                if CurrentId ~= PickerAnimationId or State == Enum.PlaybackState.Cancelled then
                    return;
                end;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                Library:SetFadeTree(PickerFrameOuter, false);
                table.clear(PickerTweens);
            end);
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end);

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinX = TransparencyBoxInner.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);
        end;

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide();
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' }
            Info.Mode = 'Toggle'
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = '<' .. Info.Default .. '>';
            TextWrapped = false;
            ZIndex = 8;
            Parent = PickInner;
        });

        local function ResizeKeyDisplay()
            local Width = math.max(DisplayLabel.TextBounds.X, select(1, Library:GetTextBounds(DisplayLabel.Text, Library.Font, 13)));
            PickOuter.Size = UDim2.fromOffset(math.max(28, Width + 6), 15);
        end;

        local function SetKeyDisplay(Key)
            DisplayLabel.Text = '<' .. tostring(Key) .. '>';
            ResizeKeyDisplay();
            task.defer(ResizeKeyDisplay);
        end;

        DisplayLabel:GetPropertyChangedSignal('TextBounds'):Connect(ResizeKeyDisplay);
        SetKeyDisplay(Info.Default);

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        });

        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
        end);

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18);
            TextSize = 13;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        },  true);

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            });

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;

                KeyPicker.Mode = Mode;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;

                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();

            ContainerLabel.Text = string.format('<%s> %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);

            ContainerLabel.Visible = true;
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

            local YSize = 0
            local XSize = 0

            for _, Label in next, Library.KeybindContainer:GetChildren() do
                if Label:IsA('TextLabel') and Label.Visible then
                    YSize = YSize + 18;
                    if (Label.TextBounds.X > XSize) then
                        XSize = Label.TextBounds.X
                    end
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false;
                end

                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            SetKeyDisplay(Key);
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value)
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end

        local Picking = false;

        PickOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Picking = true;

                DisplayLabel.Text = '<...>';

                local Break;
                local Text = '';

                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;

                        Text = Text .. '.';
                        DisplayLabel.Text = Text;

                        wait(0.4);
                    end;
                end);

                wait(0.2);

                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    Break = true;
                    Picking = false;

                    SetKeyDisplay(Key);
                    KeyPicker.Value = Key;

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

                    Library:AttemptSave();

                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick()
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ModeSelectOuter.Visible = false;
                end;
            end;
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update();
            end;
        end))

        KeyPicker:Update();

        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};

    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end

        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(Text)
            TextLabel.Text = Text

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize();
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Label;
    end;

    function Funcs:AddButton(...)
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)
            local Props = select(1, ...)
            if type(Props) == 'table' then
                Obj.Text = Props.Text
                Obj.Func = Props.Func
                Obj.DoubleClick = Props.DoubleClick
                Obj.Tooltip = Props.Tooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
            end

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end

        ProcessButtonParams('Button', Button, ...)

        local Groupbox = self;
        local Container = Groupbox.Container;

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                ZIndex = 5;
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            });

            Library:AddCorner(Outer, 3);
            Library:AddCorner(Inner, 3);

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            });

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent')
                local connection = event:Once(function(...)

                    if type(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then
                    return false
                end

                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return false
                end

                return true
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

                    Button.Label.TextColor3 = Library.AccentColor
                    Button.Label.Text = 'Are you sure?'
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

                    Button.Label.TextColor3 = Library.FontColor
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, 'Locked', false)

                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func);
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' or type(tooltip) == 'table' then
                Library:AddToolTip(tooltip, self.Outer)
            end
            return self
        end

        function Button:AddButton(...)
            local SubButton = {}

            ProcessButtonParams('SubButton', SubButton, ...)

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' or type(tooltip) == 'table' then
                    Library:AddToolTip(tooltip, self.Outer)
                end
                return SubButton
            end

            if type(SubButton.Tooltip) == 'string' or type(SubButton.Tooltip) == 'table' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)
            return SubButton
        end

        if type(Button.Tooltip) == 'string' or type(Button.Tooltip) == 'table' then
            Button:AddTooltip(Button.Tooltip)
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container

        local Divider = {
            Type = 'Divider',
        }

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        });

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end

    function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(1);

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });

        Library:AddCorner(TextBoxOuter, 3);
        Library:AddCorner(TextBoxInner, 3);

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        })

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = 7;
            Parent = Container;
        });

        Library:ApplyFont(Box);

        Library:ApplyTextStroke(Box);

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                    local currentCursorPos = Box.Position.X.Offset + width

                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });

        Library:AddCorner(ToggleOuter, 3);
        Library:AddCorner(ToggleInner, 3);

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            local BackgroundKey = Toggle.Value and 'AccentColor' or 'MainColor';
            local BorderKey = Toggle.Value and 'AccentColorDark' or 'OutlineColor';

            Library:TweenProperty(ToggleInner, 'BackgroundColor3', Library[BackgroundKey], 0.18);
            Library:TweenProperty(ToggleInner, 'BorderColor3', Library[BorderKey], 0.18);

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = BackgroundKey;
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = BorderKey;
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave();
            end;
        end);

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)
            ToggleLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
        end

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 5 + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 1;
            Step = tonumber(Info.Step or Info.Increment);
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
        };

        if not Slider.Step or Slider.Step <= 0 then
            Slider.Step = Slider.Rounding == 0 and 1 or (10 ^ -Slider.Rounding);
        end;

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        local SliderRow = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        local function CreateNudgeButton(Text, Position, AnchorPoint)
            local Outer = Library:Create('Frame', {
                AnchorPoint = AnchorPoint;
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = Position;
                Size = UDim2.fromOffset(17, 13);
                ZIndex = 6;
                Parent = SliderRow;
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 7;
                Parent = Outer;
            });

            Library:AddCorner(Outer, 3);
            Library:AddCorner(Inner, 3);

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:CreateLabel({
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1, 1);
                Text = Text;
                TextSize = 14;
                ZIndex = 8;
                Parent = Inner;
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer;
        end;

        local DecreaseOuter = CreateNudgeButton('−', UDim2.new(0, 0, 0.5, 0), Vector2.new(0, 0.5));
        local IncreaseOuter = CreateNudgeButton('+', UDim2.new(1, 0, 0.5, 0), Vector2.new(1, 0.5));

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(20, 0);
            Size = UDim2.new(1, -40, 0, 13);
            ZIndex = 5;
            Parent = SliderRow;
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 6;
            Parent = SliderOuter;
        });

        Library:AddCorner(SliderOuter, 3);
        Library:AddCorner(SliderInner, 3);

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        Library:AddCorner(Fill, 3);
        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        if Info.Compact then
            Library:CreateLabel({
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(5, 0);
                Size = UDim2.new(1, -10, 1, 0);
                Text = Info.Text;
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 8;
                Parent = SliderInner;
            });
        end;

        local Thumb = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Position = UDim2.new(0, 20, 0.5, 0);
            Size = UDim2.fromOffset(7, 13);
            ZIndex = 10;
            Parent = SliderRow;
        });

        Library:AddCorner(Thumb, 3);
        Library:AddToRegistry(Thumb, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        local ValueBadge = Library:Create('Frame', {
            Active = true;
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 27, 0.5, 0);
            Size = UDim2.fromOffset(46, 13);
            ZIndex = 11;
            Parent = SliderRow;
        });

        Library:AddCorner(ValueBadge, 3);
        Library:AddToRegistry(ValueBadge, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local ValueLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(1, 1);
            Text = tostring(Slider.Value);
            TextSize = 13;
            ZIndex = 12;
            Parent = ValueBadge;
        });

        local ValueEditHitbox = Library:Create('TextButton', {
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            Text = '';
            ZIndex = 13;
            Parent = ValueBadge;
        });

        local ValueEditor = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClearTextOnFocus = false;
            Size = UDim2.fromScale(1, 1);
            Text = tostring(Slider.Value);
            TextColor3 = Library.FontColor;
            TextSize = 13;
            TextStrokeTransparency = 0;
            Visible = false;
            ZIndex = 14;
            Parent = ValueBadge;
        });

        Library:ApplyFont(ValueEditor);
        Library:ApplyTextStroke(ValueEditor);
        Library:AddToRegistry(ValueEditor, {
            TextColor3 = 'FontColor';
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, SliderRow);
        end

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
            Thumb.BackgroundColor3 = Library.AccentColor;
            Thumb.BorderColor3 = Library.AccentColorDark;
        end;

        local VisualX = 0;
        local TargetX = 0;
        local VisualConnection;
        local IsDragging = false;
        local BadgeVisualX;
        local BadgeTargetX = 0;

        local function TrackWidth()
            local Width = SliderInner.AbsoluteSize.X;
            if Width <= 0 then
                Width = math.max(SliderRow.AbsoluteSize.X - 40, 1);
            end;

            Slider.MaxSize = math.max(Width, 1);
            return Slider.MaxSize;
        end;

        local function RenderSliderVisual(Delta, Instant)
            local Width = TrackWidth();
            VisualX = math.clamp(VisualX, 0, Width);
            Fill.Size = UDim2.new(0, VisualX, 1, 0);

            local ThumbX = SliderOuter.Position.X.Offset + VisualX;
            Thumb.Position = UDim2.new(0, ThumbX, 0.5, 0);

            local BadgeWidth = ValueBadge.Size.X.Offset;
            local RowWidth = SliderRow.AbsoluteSize.X;
            local PutRight = (ThumbX + 7 + BadgeWidth) <= RowWidth;
            BadgeTargetX = PutRight and (ThumbX + 7) or (ThumbX - 7 - BadgeWidth);

            if Instant or BadgeVisualX == nil then
                BadgeVisualX = BadgeTargetX;
            else
                local BadgeAlpha = 1 - math.exp(-(Delta or (1 / 60)) * 22);
                BadgeVisualX = BadgeVisualX + ((BadgeTargetX - BadgeVisualX) * BadgeAlpha);

                if math.abs(BadgeTargetX - BadgeVisualX) <= 0.05 then
                    BadgeVisualX = BadgeTargetX;
                end;
            end;

            ValueBadge.AnchorPoint = Vector2.new(0, 0.5);
            ValueBadge.Position = UDim2.new(0, BadgeVisualX, 0.5, 0);
        end;

        local function StopVisualAnimation()
            if VisualConnection then
                VisualConnection:Disconnect();
                VisualConnection = nil;
            end;
        end;

        local function StartVisualAnimation()
            if VisualConnection then
                return;
            end;

            VisualConnection = RenderStepped:Connect(function(Delta)
                if not Fill.Parent then
                    StopVisualAnimation();
                    return;
                end;

                local Speed = IsDragging and 38 or 24;
                local Alpha = 1 - math.exp(-Delta * Speed);
                VisualX = VisualX + ((TargetX - VisualX) * Alpha);

                if math.abs(TargetX - VisualX) <= 0.05 then
                    VisualX = TargetX;
                end;

                RenderSliderVisual(Delta, false);

                local BadgeSettled = BadgeVisualX == nil or math.abs(BadgeTargetX - BadgeVisualX) <= 0.05;
                if not IsDragging and VisualX == TargetX and BadgeSettled then
                    StopVisualAnimation();
                end;
            end);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value));
        end;

        function Slider:Display(Instant)
            local Suffix = Info.Suffix or '';
            ValueLabel.Text = tostring(Slider.Value) .. Suffix;

            local LabelWidth = math.clamp(ValueLabel.TextBounds.X + 12, 32, 72);
            ValueBadge.Size = UDim2.fromOffset(LabelWidth, 13);

            local Width = TrackWidth();
            TargetX = Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Width);

            if Instant then
                StopVisualAnimation();
                VisualX = TargetX;
                RenderSliderVisual(0, true);
            else
                StartVisualAnimation();
            end;
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(Library:MapValue(X, 0, TrackWidth(), Slider.Min, Slider.Max));
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);
            if not Num then
                return;
            end;

            Num = Round(math.clamp(Num, Slider.Min, Slider.Max));
            Slider.Value = Num;
            Slider:Display(false);

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        local LastValueBadgeClick = 0;

        local function BeginValueEdit()
            ValueEditor.Text = tostring(Slider.Value);
            ValueEditor.Visible = true;
            ValueLabel.Visible = false;

            task.defer(function()
                if not ValueEditor.Visible then
                    return;
                end;

                ValueEditor:CaptureFocus();
                ValueEditor.CursorPosition = #ValueEditor.Text + 1;
                ValueEditor.SelectionStart = 1;
            end);
        end;

        ValueEditHitbox.MouseButton1Click:Connect(function()
            local Now = os.clock();

            if Now - LastValueBadgeClick <= 0.3 then
                LastValueBadgeClick = 0;
                BeginValueEdit();
            else
                LastValueBadgeClick = Now;
            end;
        end);

        ValueEditor.FocusLost:Connect(function()
            local TypedValue = tonumber(ValueEditor.Text);

            if TypedValue then
                Slider:SetValue(TypedValue);
                Library:AttemptSave();
            end;

            ValueEditor.Visible = false;
            ValueLabel.Visible = true;
            ValueEditor.Text = tostring(Slider.Value);
        end);

        local function Nudge(Direction)
            Slider:SetValue(Slider.Value + (Slider.Step * Direction));
            Library:AttemptSave();
        end;

        local NudgeHoldSequence = 0;

        local function BindNudgeButton(Button, Direction)
            Button.InputBegan:Connect(function(Input)
                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Library:MouseIsOverOpenedFrame() then
                    return;
                end;

                NudgeHoldSequence = NudgeHoldSequence + 1;
                local Sequence = NudgeHoldSequence;
                Nudge(Direction);

                task.spawn(function()
                    local Started = os.clock();

                    while Sequence == NudgeHoldSequence and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local Elapsed = os.clock() - Started;

                        if Elapsed < 0.35 then
                            task.wait(0.025);
                        else
                            local Interval = math.max(0.035, 0.105 - math.min(Elapsed - 0.35, 2.4) * 0.028);
                            task.wait(Interval);

                            if Sequence == NudgeHoldSequence and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                Nudge(Direction);
                            end;
                        end;
                    end;
                end);
            end);
        end;

        BindNudgeButton(DecreaseOuter, -1);
        BindNudgeButton(IncreaseOuter, 1);

        local function BeginDrag(Input)
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Library:MouseIsOverOpenedFrame() then
                return;
            end;

            IsDragging = true;

            local function UpdateFromMouse()
                local Width = TrackWidth();
                local nX = math.clamp(Mouse.X - SliderInner.AbsolutePosition.X, 0, Width);
                local nValue = Slider:GetValueFromXOffset(nX);

                if nValue ~= Slider.Value then
                    Slider:SetValue(nValue);
                end;
            end;

            UpdateFromMouse();

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                UpdateFromMouse();
                RenderStepped:Wait();
            end;

            IsDragging = false;
            Slider:Display(false);
            Library:AttemptSave();
        end;

        SliderInner.InputBegan:Connect(BeginDrag);
        Thumb.InputBegan:Connect(BeginDrag);

        SliderInner:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            Slider:Display(false);
        end);

        Slider:Display(true);
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;
        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;

        if not Info.Compact then
            local DropdownLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddCorner(DropdownOuter, 3);
        Library:AddCorner(DropdownInner, 3);

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS = 8;

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            ClipsDescendants = true;
            Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, 0);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        Library:AddCorner(ListOuter, 3);
        Library:AddToRegistry(ListOuter, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ListHeight = MAX_DROPDOWN_ITEMS * 20 + 2
        local ListGap = 5
        local ListTargetPosition = UDim2.fromOffset(0, 0)

        local function RecalculateListPosition()
            ListTargetPosition = UDim2.fromOffset(
                DropdownOuter.AbsolutePosition.X,
                DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + ListGap
            );

            if not Dropdown.Opened then
                ListOuter.Position = ListTargetPosition;
            end;
        end;

        local function RecalculateListSize(YSize)
            local RequestedHeight = tonumber(YSize) or (MAX_DROPDOWN_ITEMS * 20 + 2);
            ListHeight = math.clamp(RequestedHeight, 1, MAX_DROPDOWN_ITEMS * 20 + 2);
            ListOuter.Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), ListHeight);
        end;

        RecalculateListPosition();
        RecalculateListSize();

        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BackgroundTransparency = 1;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddCorner(ListInner, 3);

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local DropdownGradient = DropdownInner:FindFirstChildOfClass('UIGradient');
        if DropdownGradient then
            DropdownGradient:Clone().Parent = ListOuter;
        end;

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 0,
            ScrollBarImageColor3 = Library.AccentColor,
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor'
        })

        local ScrollTrack = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(1, -1, 0, 4);
            Size = UDim2.new(0, 3, 1, -8);
            ZIndex = 24;
            Parent = ListInner;
        });

        local ScrollThumb = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0);
            BackgroundColor3 = Library.AccentColor;
            BackgroundTransparency = 0;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 0, 0, 0);
            Size = UDim2.new(0, 2, 0, 18);
            ZIndex = 25;
            Parent = ScrollTrack;
        });

        Library:AddCorner(ScrollThumb, 1);
        Library:AddToRegistry(ScrollThumb, {
            BackgroundColor3 = 'AccentColor';
        });

        Library:Create('UIGradient', {
            Rotation = 90;
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.62),
                NumberSequenceKeypoint.new(0.16, 0),
                NumberSequenceKeypoint.new(0.84, 0),
                NumberSequenceKeypoint.new(1, 0.62),
            });
            Parent = ScrollThumb;
        });

        local function UpdateDropdownScrollVisuals()
            local ViewportHeight = Scrolling.AbsoluteSize.Y;
            local ContentHeight = Scrolling.AbsoluteCanvasSize.Y;

            if ViewportHeight <= 0 then
                ScrollTrack.Visible = false;
                return;
            end;

            local Scrollable = ContentHeight > ViewportHeight + 1;
            ScrollTrack.Visible = Scrollable;

            if not Scrollable then
                return;
            end;

            local TrackHeight = math.max(ScrollTrack.AbsoluteSize.Y, 1);
            local ThumbHeight = math.clamp(TrackHeight * (ViewportHeight / ContentHeight), 18, TrackHeight);
            local MaxTravel = math.max(TrackHeight - ThumbHeight, 0);
            local MaxCanvas = math.max(ContentHeight - ViewportHeight, 1);
            local ThumbY = MaxTravel * math.clamp(Scrolling.CanvasPosition.Y / MaxCanvas, 0, 1);

            ScrollThumb.Size = UDim2.new(0, 2, 0, ThumbHeight);
            ScrollThumb.Position = UDim2.new(0.5, 0, 0, ThumbY);
        end;

        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
            UpdateDropdownScrollVisuals(false);
        end);
        Scrolling:GetPropertyChangedSignal('AbsoluteCanvasSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(false); end);
        end);
        Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(true); end);
        end);
        ListOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(false); end);
        end);

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};

                Count = Count + 1;

                local Button = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, -5, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    local TextColorKey = Selected and 'AccentColor' or 'FontColor';
                    Library:TweenProperty(ButtonLabel, 'TextColor3', Library[TextColorKey], 0.16);
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = TextColorKey;
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 8);

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
            RecalculateListSize(Y);
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues;
            end;

            Dropdown:BuildDropdownList();
        end;

        local DropdownTweens = {}
        local DropdownAnimationId = 0

        local function CancelDropdownTweens()
            for _, Tween in next, DropdownTweens do
                pcall(function()
                    Tween:Cancel()
                end)
            end
            table.clear(DropdownTweens)
        end

        local function PlayDropdownTween(Instance, InfoValue, Properties)
            local Tween = TweenService:Create(Instance, InfoValue, Properties)
            table.insert(DropdownTweens, Tween)
            Tween:Play()
            return Tween
        end

        local DropdownScrollConnection;

        local function StopDropdownAutoScroll()
            if DropdownScrollConnection then
                DropdownScrollConnection:Disconnect();
                DropdownScrollConnection = nil;
            end;
        end;

        local function StartDropdownAutoScroll()
            StopDropdownAutoScroll();
            DropdownScrollConnection = RenderStepped:Connect(function(Delta)
                if not Dropdown.Opened or not ListOuter.Visible then
                    StopDropdownAutoScroll();
                    return;
                end;

                local Position = ListOuter.AbsolutePosition;
                local Size = ListOuter.AbsoluteSize;
                local MouseInsideX = Mouse.X >= Position.X and Mouse.X <= Position.X + Size.X;
                if not MouseInsideX then
                    return;
                end;

                local Edge = math.min(22, Size.Y * 0.22);
                local Direction = 0;
                local Strength = 0;

                if Mouse.Y >= Position.Y + Size.Y - Edge and Mouse.Y <= Position.Y + Size.Y + 4 then
                    Direction = 1;
                    Strength = math.clamp((Mouse.Y - (Position.Y + Size.Y - Edge)) / math.max(Edge, 1), 0, 1);
                elseif Mouse.Y <= Position.Y + Edge and Mouse.Y >= Position.Y - 4 then
                    Direction = -1;
                    Strength = math.clamp(((Position.Y + Edge) - Mouse.Y) / math.max(Edge, 1), 0, 1);
                end;

                if Direction ~= 0 then
                    local MaxCanvas = math.max(Scrolling.AbsoluteCanvasSize.Y - Scrolling.AbsoluteSize.Y, 0);
                    local NewY = math.clamp(Scrolling.CanvasPosition.Y + (Direction * (70 + 170 * Strength) * Delta), 0, MaxCanvas);
                    Scrolling.CanvasPosition = Vector2.new(Scrolling.CanvasPosition.X, NewY);
                end;
            end);
        end;

        function Dropdown:OpenDropdown()
            if Dropdown.Opened then
                return;
            end;

            Dropdown.Opened = true;
            DropdownAnimationId = DropdownAnimationId + 1;
            CancelDropdownTweens();
            RecalculateListPosition();
            RecalculateListSize(ListHeight);

            ListOuter.Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 6);
            Library:SetFadeTree(ListOuter, true);
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;

            PlayDropdownTween(ListOuter, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = ListTargetPosition;
            });
            Library:TweenFadeTree(ListOuter, false, 0.24);
            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = 180;
            });

            StartDropdownAutoScroll();
        end;

        function Dropdown:CloseDropdown()
            if not Dropdown.Opened and not ListOuter.Visible then
                return;
            end;

            Dropdown.Opened = false;
            DropdownAnimationId = DropdownAnimationId + 1;
            local CurrentId = DropdownAnimationId;
            CancelDropdownTweens();
            StopDropdownAutoScroll();
            Library.OpenedFrames[ListOuter] = nil;

            Library:TweenFadeTree(ListOuter, true, 0.19);
            local ExitTween = PlayDropdownTween(ListOuter, TweenInfo.new(0.21, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 4);
            });
            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = 0;
            });

            ExitTween.Completed:Connect(function(State)
                if CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then
                    return;
                end;

                ListOuter.Visible = false;
                ListOuter.Position = ListTargetPosition;
                Library:SetFadeTree(ListOuter, false);
                table.clear(DropdownTweens);
            end);
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if Dropdown.Opened then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Opened then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:BuildDropdownList();
        Dropdown:Display();

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)
            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)
                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Options[Idx] = Dropdown;

        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };
        
        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });

        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });

        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });

        local DependencyAnimationId = 0;
        local DependencySizeTween;
        local DependencyFadeTween;
        local DependencyVisible = false;

        local function CancelDependencyTweens()
            if DependencySizeTween then
                pcall(function() DependencySizeTween:Cancel(); end);
                DependencySizeTween = nil;
            end;

            if DependencyFadeTween then
                pcall(function() DependencyFadeTween:Cancel(); end);
                DependencyFadeTween = nil;
            end;
        end;

        local function SetDependencyVisible(Visible, Instant)
            DependencyAnimationId = DependencyAnimationId + 1;
            local CurrentId = DependencyAnimationId;
            CancelDependencyTweens();

            local Height = Layout.AbsoluteContentSize.Y;
            DependencyVisible = Visible;

            if Visible then
                Holder.Visible = true;

                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, Height);
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                Library:SetFadeTree(Holder, true);
                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, Height)
                });
                Library:TweenFadeTree(Holder, false, 0.20);
                DependencySizeTween:Play();
            else
                if not Holder.Visible then
                    Holder.Size = UDim2.new(1, 0, 0, 0);
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, 0);
                    Holder.Visible = false;
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                Library:TweenFadeTree(Holder, true, 0.16);
                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(1, 0, 0, 0)
                });

                DependencySizeTween.Completed:Connect(function(State)
                    if CurrentId ~= DependencyAnimationId or DependencyVisible or State == Enum.PlaybackState.Cancelled then
                        return;
                    end;

                    Holder.Visible = false;
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                end);

                DependencySizeTween:Play();
            end;
        end;

        function Depbox:Resize(Instant)
            local Height = Layout.AbsoluteContentSize.Y;
            if DependencyVisible and Holder.Visible then
                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, Height);
                else
                    Library:TweenProperty(Holder, 'Size', UDim2.new(1, 0, 0, Height), 0.18);
                end;
            end;
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize(false);
        end);

        Holder:GetPropertyChangedSignal('Size'):Connect(function()
            Groupbox:Resize();
        end);

        function Depbox:Update()
            local ShouldShow = true;
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Value = Dependency[2];
                if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                    ShouldShow = false;
                    break;
                end;
            end;
            SetDependencyVisible(ShouldShow, false);
        end;

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;
            Depbox:Update();
        end;

        Depbox.Container = Frame;

        setmetatable(Depbox, BaseGroupbox);

        table.insert(Library.DependencyBoxes, Depbox);

        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

do
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

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });
    Library:AddCorner(WatermarkOuter, 3);
    Library:AddCorner(WatermarkInner, 3);
    Library:AddAccentGlow(WatermarkInner, 0.9);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);

    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    }, true);
    Library:AddCorner(KeybindOuter, 3);
    Library:AddCorner(KeybindInner, 3);
    Library:AddAccentGlow(KeybindInner, 0.9);

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    });

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20);
        Position = UDim2.fromOffset(5, 2),
        TextXAlignment = Enum.TextXAlignment.Left,

        Text = 'Keybinds';
        ZIndex = 104;
        Parent = KeybindInner;
    });

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20);
        Position = UDim2.new(0, 0, 0, 20);
        ZIndex = 1;
        Parent = KeybindInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14);
    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = InnerFrame;
    });

    local LeftColor = Library:Create('Frame', {
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

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

    task.spawn(function()
        wait(Time or 5);

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

        wait(0.4);

        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(...)
    local Arguments = { ... }
    local Config = { AnchorPoint = Vector2.zero }

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false;
    end

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = {
        Tabs = {};
    };

    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    Library:MakeDraggable(Outer, 25);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    });

    local WindowCornerRadius = UDim.new(0, 3);

    Library:Create('UICorner', {
        CornerRadius = WindowCornerRadius;
        Parent = Outer;
    });

    Library:Create('UICorner', {
        CornerRadius = WindowCornerRadius;
        Parent = Inner;
    });

    Library:AddAccentGlow(Inner, 1);

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(0, 0, 0, 25);
        Text = Config.Title or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 1;
        Parent = Inner;
    });

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 1;
        Parent = Inner;
    });

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8, 0, 8);
        Size = UDim2.new(1, -16, 0, 21);
        ZIndex = 1;
        Parent = MainSectionInner;
    });

    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });

    local TabIndicatorLayer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = TabArea.Position;
        Size = TabArea.Size;
        ZIndex = 12;
        Parent = MainSectionInner;
    });
    local MainTabIndicator = Library:CreateSlidingTabIndicator(TabIndicatorLayer, 21);

    TabListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if Window.ActiveTab and Window.ActiveTab.Button then
            task.defer(function()
                if Window.ActiveTab and Window.ActiveTab.Button then
                    MainTabIndicator:Refresh(Window.ActiveTab.Button);
                end;
            end);
        end;
    end);

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 2;
        Parent = MainSectionInner;
    });
    
    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
            VisualGroups = {};
        };

        local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16);

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 3;
            Parent = TabArea;
        });

        Library:AddTopCorners(TabButton, 3);

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Name;
            ZIndex = 4;
            Parent = TabButton;
        });

        local function UpdateTabButtonWidth()
            local Width = math.max(TabButtonLabel.TextBounds.X, 1) + 12;
            TabButton.Size = UDim2.new(0, Width, 1, 0);

            if Tab.Active then
                task.defer(function()
                    MainTabIndicator:Refresh(TabButton);
                end);
            end;
        end;

        TabButtonLabel:GetPropertyChangedSignal('TextBounds'):Connect(UpdateTabButtonWidth);
        task.defer(UpdateTabButtonWidth);

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, -1, 1, -1);
            Size = UDim2.new(1, 2, 0, 4);
            BackgroundTransparency = 1;
            ZIndex = 8;
            Parent = TabButton;
        });

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        });

        Tab.Active = false;
        Tab.ContentAnimationId = 0;
        Tab.Button = TabButton;

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 7);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        });

        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
            Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        local function SetTabVisualGroups(Target, Duration, Stagger)
            local Hidden = Target >= 0.5;

            if not Duration or Duration <= 0 then
                Library:SetFadeTree(TabFrame, Hidden);
            else
                Library:TweenFadeTree(TabFrame, Hidden, Duration);
            end;
        end;

        function Tab:ShowTab()
            if Tab.Active then
                MainTabIndicator:MoveTo(TabButton, false);
                return;
            end;

            for _, OtherTab in next, Window.Tabs do
                if OtherTab ~= Tab then
                    OtherTab:HideTab();
                end;
            end;

            Tab.Active = true;
            Window.ActiveTab = Tab;
            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            MainTabIndicator:MoveTo(TabButton, not MainTabIndicator.Frame.Visible);

            TabFrame.Position = UDim2.new(0, 0, 0, 7);
            TabFrame.Visible = true;
            SetTabVisualGroups(1, 0);

            task.defer(function()
                if Tab.Active then
                    SetTabVisualGroups(0, 0.22, 0.018);
                    Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, 0), 0.26);
                end;
            end);
        end;

        function Tab:HideTab()
            if not Tab.Active then
                return;
            end;

            Tab.Active = false;
            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
            local CurrentAnimation = Tab.ContentAnimationId;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.14);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.14);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            SetTabVisualGroups(1, 0.14, 0);
            Library:TweenProperty(TabFrame, 'Position', UDim2.new(0, 0, 0, -4), 0.17);

            task.delay(0.17, function()
                if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                    TabFrame.Visible = false;
                    TabFrame.Position = UDim2.new(0, 0, 0, 7);
                end;
            end);
        end;

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
            TabListLayout:ApplyLayout();
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });
            table.insert(Tab.VisualGroups, BoxOuter);

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local GroupboxLabelWidth = Library:GetTextBounds(Info.Name, Library.Font, 14);
            local GroupboxLabel = Library:CreateLabel({
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Library.BackgroundColor;
                BackgroundTransparency = 0;
                BorderSizePixel = 0;
                Size = UDim2.fromOffset(GroupboxLabelWidth + 12, 16);
                Position = UDim2.new(0.5, 0, 0, 0);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Center;
                ZIndex = 6;
                Parent = BoxInner;
            });

            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';

            local function UpdateGroupboxLegendSize()
                GroupboxLabel.Size = UDim2.fromOffset(
                    math.max(GroupboxLabel.TextBounds.X + 12, 20),
                    math.max(GroupboxLabel.TextBounds.Y + 2, 16)
                );
            end;
            GroupboxLabel:GetPropertyChangedSignal('TextBounds'):Connect(UpdateGroupboxLegendSize);
            task.defer(UpdateGroupboxLegendSize);

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });

            function Groupbox:Resize()
                local Size = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);

            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; });
        end;

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });
            table.insert(Tab.VisualGroups, BoxOuter);

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 10;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });

            local TabboxIndicatorLayer = Library:Create('Frame', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = TabboxButtons.Position;
                Size = TabboxButtons.Size;
                ZIndex = 12;
                Parent = BoxInner;
            });
            local TabboxIndicator = Library:CreateSlidingTabIndicator(TabboxIndicatorLayer, 18);

            function Tabbox:AddTab(Name)
                local Tab = {};

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });

                Library:AddTopCorners(Button, 3);

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, -1, 1, -1);
                    Size = UDim2.new(1, 2, 0, 4);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                Tab.Active = false;
                Tab.ContentAnimationId = 0;

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                            Position = UDim2.new(0, 4, 0, 25);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Tab:Show()
                    if Tab.Active then
                        TabboxIndicator:MoveTo(Button, false);
                        return;
                    end;

                    for _, OtherTab in next, Tabbox.Tabs do
                        if OtherTab ~= Tab then
                            OtherTab:Hide();
                        end;
                    end;

                    Tab.Active = true;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    Container.Visible = true;
                    Block.Visible = true;
                    TabboxIndicator:MoveTo(Button, not TabboxIndicator.Frame.Visible);

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 20), 0.25);
                    Library:SetFadeTree(Container, true);
                    Library:TweenFadeTree(Container, false, 0.22);

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Tab.Active = false;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    local CurrentAnimation = Tab.ContentAnimationId;

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                    Library:TweenFadeTree(Container, true, 0.16);
                    Library:TweenProperty(Container, 'Position', UDim2.new(0, 4, 0, 17), 0.16);

                    task.delay(0.16, function()
                        if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                            Container.Visible = false;
                            Container.Position = UDim2.new(0, 4, 0, 25);
                            Block.Visible = false;
                        end;
                    end);
                end;

                function Tab:Resize()
                    local TabCount = 0;

                    for _, Child in next, TabboxButtons:GetChildren() do
                        if not Child:IsA('UIListLayout') then
                            TabCount = TabCount + 1;
                        end;
                    end;

                    if TabCount <= 0 then
                        return;
                    end;

                    for _, TabButtonObject in next, TabboxButtons:GetChildren() do
                        if not TabButtonObject:IsA('UIListLayout') then
                            TabButtonObject.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    task.defer(function()
                        for _, ExistingTab in next, Tabbox.Tabs do
                            if ExistingTab.Active and ExistingTab.Button then
                                TabboxIndicator:Refresh(ExistingTab.Button);
                                break;
                            end;
                        end;
                    end);

                    if (not Container.Visible) then
                        return;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                end;

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show();
                        Tab:Resize();
                    end;
                end);

                Tab.Container = Container;
                Tab.Button = Button;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);

                Tab:AddBlank(3);
                Tab:Resize();

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:ShowTab();
            end;
        end);

        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;

        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });

    local TransparencyCache = {};
    local Toggled = false;
    local Fading = false;

    function Library:Toggle()
        if Fading then
            return;
        end;

        local FadeTime = Config.MenuFadeTime;
        Fading = true;
        Toggled = (not Toggled);
        ModalElement.Modal = Toggled;

        if Toggled then
            Outer.Visible = true;

            task.spawn(function()
                local State = InputService.MouseIconEnabled;

                local CursorAssetPath = 'FormaAssets/cursor.png';
                local CursorAssetUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/cursor.png';
                local GetCustomAsset = getcustomasset or getsynasset;
                local Cursor;

                if GetCustomAsset and writefile and isfile then
                    pcall(function()
                        if isfolder and makefolder and not isfolder('FormaAssets') then
                            makefolder('FormaAssets');
                        end;

                        if not isfile(CursorAssetPath) then
                            writefile(CursorAssetPath, game:HttpGet(CursorAssetUrl));
                        end;

                        Cursor = Library:Create('ImageLabel', {
                            BackgroundTransparency = 1;
                            BorderSizePixel = 0;
                            Image = GetCustomAsset(CursorAssetPath);
                            ImageColor3 = Library.AccentColor;
                            Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
                            Size = UDim2.fromOffset(13, 16);
                            ZIndex = 1000;
                            Visible = true;
                            Parent = ScreenGui;
                        });

                        Library:AddToRegistry(Cursor, {
                            ImageColor3 = 'AccentColor';
                        });
                    end);
                end;

                if Cursor then
                    while Toggled and ScreenGui.Parent do
                        InputService.MouseIconEnabled = false;
                        Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
                        RenderStepped:Wait();
                    end;

                    InputService.MouseIconEnabled = State;
                    Cursor:Destroy();
                else
                    InputService.MouseIconEnabled = State;
                end;
            end);
        end;

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {};

            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency');
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                table.insert(Properties, 'TextTransparency');
            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency');
            end;

            local Cache = TransparencyCache[Desc];

            if (not Cache) then
                Cache = {};
                TransparencyCache[Desc] = Cache;
            end;

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop];
                end;

                if Cache[Prop] == 1 then
                    continue;
                end;

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
            end;
        end;

        task.wait(FadeTime);

        Outer.Visible = Toggled;

        Fading = false;
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    if Config.AutoShow then task.spawn(Library.Toggle) end

    Window.Holder = Outer;
    Library.WindowHolder = Outer;

    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

Library:SetFont('Rubik Light');

getgenv().Library = Library
return Library