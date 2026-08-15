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
Library.DraggableStates = setmetatable({}, { __mode = 'k' });

local MotionTransparencyProperties = {
    BackgroundTransparency = true;
    TextTransparency = true;
    TextStrokeTransparency = true;
    ImageTransparency = true;
    ScrollBarImageTransparency = true;
    Transparency = true;
    GroupTransparency = true;
}

local MotionColorProperties = {
    BackgroundColor3 = true;
    BorderColor3 = true;
    TextColor3 = true;
    TextStrokeColor3 = true;
    ImageColor3 = true;
    ScrollBarImageColor3 = true;
    Color = true;
    GroupColor3 = true;
}

local MotionSpatialProperties = {
    Position = true;
    CanvasPosition = true;
    AnchorPoint = true;
    Rotation = true;
    Scale = true;
    Value = true;
}

local MotionLayoutProperties = {
    Size = true;
    CanvasSize = true;
}

function Library:ResolveMotionContext(Properties, Context)
    if Context and Context ~= 'Property' then return Context; end

    local HasTransparency = false;
    local HasColor = false;
    local HasSpatial = false;
    local HasLayout = false;
    for Property in next, Properties do
        HasTransparency = HasTransparency or MotionTransparencyProperties[Property] == true;
        HasColor = HasColor or MotionColorProperties[Property] == true;
        HasSpatial = HasSpatial or MotionSpatialProperties[Property] == true;
        HasLayout = HasLayout or MotionLayoutProperties[Property] == true;
    end

    if HasTransparency and not HasSpatial then return 'Fade'; end
    if HasColor and not HasSpatial then return 'Color'; end
    if HasLayout and not HasSpatial then return 'Layout'; end
    return Context or 'Property';
end;

function Library:GetMenuTweenInfo(Duration, Context)
    local Manager = Library.MenuManager;
    if Manager and Manager.GetTweenInfo then
        local Success, Info = pcall(Manager.GetTweenInfo, Manager, Duration, Context);
        if Success and typeof(Info) == 'TweenInfo' then
            return Info;
        end
    end

    return TweenInfo.new(
        math.clamp(tonumber(Duration) or 0.16, 0.035, 1.5),
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    );
end;

function Library:CancelMotion(Instance, Property)
    local Motions = Instance and Library.PropertyTweens[Instance];
    if not Motions then return; end

    local Cancelled = {};
    local function Cancel(Token)
        if Token and not Cancelled[Token] then
            Cancelled[Token] = true;
            for TokenProperty in next, Token.Properties do
                if Motions[TokenProperty] == Token then Motions[TokenProperty] = nil; end
            end
            pcall(function() Token.Tween:Cancel(); end);
        end
    end

    if Property then
        Cancel(Motions[Property]);
    else
        for _, Token in next, Motions do Cancel(Token); end
    end
end;

function Library:Animate(Instance, Properties, Duration, Completed, Context)
    if not Instance or type(Properties) ~= 'table' or next(Properties) == nil then return nil; end

    Context = Library:ResolveMotionContext(Properties, Context);

    local HasChange = false;
    for Property, Value in next, Properties do
        local Success, Current = pcall(function() return Instance[Property]; end);
        if not Success or Current ~= Value then HasChange = true; break; end
    end
    if not HasChange then
        if Completed then pcall(Completed, Enum.PlaybackState.Completed); end
        return nil;
    end

    local InstanceTweens = Library.PropertyTweens[Instance];
    if not InstanceTweens then
        InstanceTweens = {};
        Library.PropertyTweens[Instance] = InstanceTweens;
    end

    -- Repeated layout/refresh events frequently ask for the same destination.
    -- Reuse the in-flight tween instead of restarting its easing curve, which
    -- otherwise creates the delayed, sticky feeling seen under rapid input.
    local SharedToken;
    local SameTarget = true;
    for Property, Value in next, Properties do
        local Previous = InstanceTweens[Property];
        if not Previous or Previous.Targets[Property] ~= Value or (SharedToken and SharedToken ~= Previous) then
            SameTarget = false;
            break;
        end
        SharedToken = Previous;
    end
    if SameTarget and SharedToken then
        if Completed then table.insert(SharedToken.Callbacks, Completed); end
        return SharedToken.Tween;
    end

    local PreviousTokens = {};
    for Property in next, Properties do
        local Previous = InstanceTweens[Property];
        if Previous and not PreviousTokens[Previous] then
            PreviousTokens[Previous] = true;
            pcall(function() Previous.Tween:Cancel(); end);
        end
    end

    local Tween;
    local Success = pcall(function()
        local Info = typeof(Duration) == 'TweenInfo' and Duration or Library:GetMenuTweenInfo(Duration, Context);
        Tween = TweenService:Create(Instance, Info, Properties);
    end);

    if not Success or not Tween then
        for Property, Value in next, Properties do
            pcall(function() Instance[Property] = Value; end);
        end
        if Completed then pcall(Completed, Enum.PlaybackState.Completed); end
        return nil;
    end

    local Token = {
        Tween = Tween;
        Properties = Properties;
        Targets = table.clone(Properties);
        Callbacks = {};
    };
    if Completed then table.insert(Token.Callbacks, Completed); end
    for Property in next, Properties do InstanceTweens[Property] = Token; end

    Tween.Completed:Connect(function(State)
        for Property in next, Properties do
            if InstanceTweens[Property] == Token then InstanceTweens[Property] = nil; end
        end
        for _, Callback in ipairs(Token.Callbacks) do pcall(Callback, State); end
        table.clear(Token.Callbacks);
    end);

    Tween:Play();
    return Tween;
end;

function Library:TweenMenuProperty(Instance, Property, Value, Duration, Completed)
    return Library:Animate(Instance, { [Property] = Value }, Duration, Completed, 'Property');
end;

function Library:TweenMenuFadeTree(Root, Hidden, Duration)
    if not Root then return nil; end
    if Root:IsA('CanvasGroup') then
        return Library:TweenUnifiedFade(Root, Hidden and 0 or 1, Duration);
    end

    Library:PrimeFadeTree(Root);
    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            local Properties = {};
            for Property, Baseline in next, Cache do
                Properties[Property] = Hidden and 1 or Baseline;
            end
            Library:Animate(Instance, Properties, Duration, nil, 'Fade');
        end
    end
end;

Library.UnifiedFadeControllers = setmetatable({}, { __mode = 'k' });

local function GetUnifiedFadeController(Root)
    local Controller = Library.UnifiedFadeControllers[Root];
    if Controller then
        return Controller;
    end

    local Driver = Instance.new('NumberValue');
    Driver.Name = 'FormaUnifiedFadeDriver';
    Driver.Value = 1;
    Driver.Parent = Root;

    Controller = {
        Driver = Driver;
        Progress = 1;
        Entries = {};
        Tween = nil;
    };
    Library.UnifiedFadeControllers[Root] = Controller;

    Driver:GetPropertyChangedSignal('Value'):Connect(function()
        local Progress = math.clamp(Driver.Value, 0, 1);
        Controller.Progress = Progress;

        for _, Entry in ipairs(Controller.Entries) do
            local Instance = Entry.Instance;
            if Instance and Instance.Parent then
                for Property, Baseline in next, Entry.Baseline do
                    pcall(function()
                        Instance[Property] = 1 + ((Baseline - 1) * Progress);
                    end);
                end
            end
        end
    end);

    return Controller;
end

local function RefreshUnifiedFadeEntries(Root, Controller)
    Library:PrimeFadeTree(Root);
    table.clear(Controller.Entries);

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        if Descendant ~= Controller.Driver then
            table.insert(Instances, Descendant);
        end
    end

    for _, Instance in ipairs(Instances) do
        local Baseline = Library.FadeBaselines[Instance];
        if Baseline then
            table.insert(Controller.Entries, {
                Instance = Instance;
                Baseline = Baseline;
            });
        end
    end
end

function Library:SetUnifiedFadeProgress(Root, Progress)
    if not Root then
        return;
    end

    local Value = math.clamp(tonumber(Progress) or 0, 0, 1);
    if Root:IsA('CanvasGroup') then
        Library:CancelMotion(Root, 'GroupTransparency');
        Root.GroupTransparency = 1 - Value;
        return;
    end

    local Controller = GetUnifiedFadeController(Root);
    if Controller.Tween then
        pcall(function() Controller.Tween:Cancel(); end);
        Controller.Tween = nil;
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    Controller.Progress = Value;
    Controller.Driver.Value = Controller.Progress;
end

function Library:TweenUnifiedFade(Root, Target, Duration, Completed, Context)
    if not Root then
        return nil;
    end

    local TargetProgress = math.clamp(tonumber(Target) or 0, 0, 1);
    if Root:IsA('CanvasGroup') then
        return Library:Animate(
            Root,
            { GroupTransparency = 1 - TargetProgress },
            Duration,
            Completed,
            Context or 'Fade'
        );
    end

    local Controller = GetUnifiedFadeController(Root);
    if Controller.Tween then
        pcall(function() Controller.Tween:Cancel(); end);
        Controller.Tween = nil;
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    local Tween = Library:Animate(
        Controller.Driver,
        { Value = TargetProgress },
        Duration,
        nil,
        Context or 'Fade'
    );

    Controller.Tween = Tween;
    if Tween then Tween.Completed:Connect(function(State)
        if Controller.Tween == Tween then
            Controller.Tween = nil;
            Controller.Progress = TargetProgress;
            Controller.Driver.Value = TargetProgress;
        end
        if Completed then
            Completed(State);
        end
    end); else
        Controller.Progress = TargetProgress;
        Controller.Driver.Value = TargetProgress;
        if Completed then Completed(Enum.PlaybackState.Completed); end
    end

    return Tween;
end

function Library:ResetMenuPositions(Animated)
    for Instance, State in next, Library.DraggableStates do
        if Instance and Instance.Parent and State.InitialPosition then
            if Animated then
                Library:TweenMenuProperty(Instance, 'Position', State.InitialPosition, nil);
            else
                Instance.Position = State.InitialPosition;
            end
        end
    end
end;

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
    return Library:Animate(Instance, { [Property] = Value }, Duration or 0.14, nil, 'Property');
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

    if Root:IsA('CanvasGroup') then
        Library:SetUnifiedFadeProgress(Root, Hidden and 0 or 1);
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

    if Root:IsA('CanvasGroup') then
        return Library:TweenUnifiedFade(Root, Hidden and 0 or 1, Duration or 0.14);
    end;

    Library:PrimeFadeTree(Root);
    Duration = Duration or 0.14;

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            local Properties = {};
            for Property, Baseline in next, Cache do
                Properties[Property] = Hidden and 1 or Baseline;
            end;
            Library:Animate(Instance, Properties, Duration, nil, 'Fade');
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

    if _Instance:IsA('UIStroke') then
        _Instance.LineJoinMode = Enum.LineJoinMode.Miter;
    end;

    return _Instance;
end;

function Library:AddCorner(Instance, Radius)
    if not Instance then
        return nil;
    end;

    for _, Child in ipairs(Instance:GetChildren()) do
        if Child:IsA('UICorner') then
            Child:Destroy();
        end;
    end;
    return nil;
end;


function Library:AddAccentGlow(Instance, Scale)
    if not Instance then
        return;
    end;

    Scale = math.max(tonumber(Scale) or 1, 0.05);

    for _, Child in ipairs(Instance:GetChildren()) do
        if (Child:IsA('UIStroke') and Child.Name:match('^FormaAccentGlow%d+$'))
            or (Child:IsA('Frame') and Child.Name:match('^FormaAccentGlowLayer%d+$')) then
            Child:Destroy();
        end
    end

    local Layers = {
        { 0.4,  1.4, 0.940 },
        { 1.2,  1.6, 0.948 },
        { 2.2,  1.8, 0.956 },
        { 3.5,  2.0, 0.964 },
        { 5.0,  2.2, 0.971 },
        { 6.8,  2.5, 0.977 },
        { 8.9,  2.8, 0.982 },
        { 11.3, 3.1, 0.987 },
        { 14.0, 3.5, 0.991 },
        { 17.0, 3.9, 0.994 },
        { 20.4, 4.3, 0.996 },
    };

    for Index, Info in ipairs(Layers) do
        local Spread = Info[1] * Scale;
        local Thickness = Info[2] * Scale;
        local Layer = Library:Create('Frame', {
            Name = 'FormaAccentGlowLayer' .. Index;
            Active = false;
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.fromScale(0.5, 0.5);
            Size = UDim2.new(1, Spread * 2, 1, Spread * 2);
            ZIndex = math.max(0, Instance.ZIndex - 1);
            Parent = Instance;
        });

        local Stroke = Library:Create('UIStroke', {
            Name = 'GlowStroke';
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Miter;
            Thickness = Thickness;
            Transparency = Info[3];
            Parent = Layer;
        });

        Library:AddToRegistry(Stroke, {
            Color = 'AccentColor';
        });
    end;
end;

function Library:AddAccentOutline(Instance, Scale)
    if not Instance then
        return nil;
    end;

    Scale = math.max(tonumber(Scale) or 1, 0.25);
    local Stroke = Instance:FindFirstChild('FormaAccentOutline');
    if not Stroke then
        Stroke = Library:Create('UIStroke', {
            Name = 'FormaAccentOutline';
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Miter;
            Thickness = 1.05 * Scale;
            Transparency = 0.14;
            Parent = Instance;
        });
        Library:AddToRegistry(Stroke, { Color = 'AccentColor'; });
    else
        Stroke.Thickness = 1.05 * Scale;
        Stroke.Transparency = 0.14;
    end
    return Stroke;
end;

function Library:AddTopCorners(Instance, Radius)
    if not Instance then
        return nil;
    end;

    Library:AddCorner(Instance, Radius);
    return nil;
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
            Library:TweenProperty(Element, 'BackgroundTransparency', Transparency, 0.11);
        end;
    end;

    SetActive(false);
    return SetActive;
end;

function Library:CreateSlidingTabIndicator(Layer, Height)
    local Controller = {};

    local Indicator = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.fromOffset(0, Height or 21);
        Visible = false;
        ZIndex = 20;
        Parent = Layer;
    });

    local Stroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        LineJoinMode = Enum.LineJoinMode.Miter;
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

    function Controller:MoveTo(Button, Instant)
        if not Button or not Button.Parent or Button.AbsoluteSize.X <= 0 then
            return;
        end;

        local NewLeft = Button.AbsolutePosition.X - Layer.AbsolutePosition.X;
        local NewY = Button.AbsolutePosition.Y - Layer.AbsolutePosition.Y;
        local TargetPosition = UDim2.fromOffset(NewLeft, NewY);
        local TargetSize = UDim2.fromOffset(Button.AbsoluteSize.X, Height or 21);

        if Instant or not Indicator.Visible or Indicator.AbsoluteSize.X <= 0 then
            Library:CancelMotion(Indicator);
            Indicator.Position = TargetPosition;
            Indicator.Size = TargetSize;
            Indicator.Visible = true;
            return;
        end;

        Indicator.Visible = true;
        local Travel = math.abs(NewLeft - Indicator.Position.X.Offset)
            + (math.abs(Button.AbsoluteSize.X - Indicator.Size.X.Offset) * 0.35);
        local Duration = 0.13 + math.clamp(Travel / 1800, 0, 0.055);
        Library:Animate(Indicator, {
            Position = TargetPosition;
            Size = TargetSize;
        }, Duration, nil, 'TabIndicator');
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
    if not Instance then
        return nil;
    end

    local Existing = Library.DraggableStates[Instance];
    if Existing then
        return Existing;
    end

    Instance.Active = true;
    local State = {
        InitialPosition = Instance.Position;
        Dragging = false;
        TargetPosition = Instance.Position;
        DragConnection = nil;
        InputConnection = nil;
        Input = nil;
        ObjectOffset = nil;
        Anchor = nil;
    };
    Library.DraggableStates[Instance] = State;

    local function Disconnect(ConnectionName)
        local Connection = State[ConnectionName];
        if Connection then
            Connection:Disconnect();
            State[ConnectionName] = nil;
        end
    end

    local function GetPointer(Input)
        if Input and Input.UserInputType == Enum.UserInputType.Touch then
            return Vector2.new(Input.Position.X, Input.Position.Y);
        end
        return Vector2.new(Mouse.X, Mouse.Y);
    end

    local function FinishDrag()
        if not State.Dragging then return; end

        -- Capture the pointer once more at release. Input may end between render
        -- steps, and using the previous frame's target is the source of the
        -- visible release snap.
        if State.Input and State.ObjectOffset and State.Anchor then
            local Pointer = GetPointer(State.Input);
            State.TargetAnchor = Vector2.new(
                Pointer.X - State.ObjectOffset.X + (Instance.AbsoluteSize.X * State.Anchor.X),
                Pointer.Y - State.ObjectOffset.Y + (Instance.AbsoluteSize.Y * State.Anchor.Y)
            );
        end

        State.Dragging = false;
        Disconnect('DragConnection');
        Disconnect('InputConnection');
        State.Input = nil;
        State.ObjectOffset = nil;
        State.Anchor = nil;

        if not Instance.Parent then return; end
        local Target = State.TargetAnchor;
        if not Target then return; end

        State.TargetPosition = UDim2.fromOffset(Target.X, Target.Y);
        local Anchor = Instance.AnchorPoint;
        local Current = Vector2.new(
            Instance.AbsolutePosition.X + (Instance.AbsoluteSize.X * Anchor.X),
            Instance.AbsolutePosition.Y + (Instance.AbsoluteSize.Y * Anchor.Y)
        );
        local Distance = (Target - Current).Magnitude;
        if Distance <= 0.35 then
            Instance.Position = State.TargetPosition;
            return;
        end

        local Manager = Library.MenuManager;
        local Duration = 0.055 + math.clamp(Distance / 1600, 0, 0.03);
        if Manager and Manager.GetReleaseDuration then
            local Success, Value = pcall(Manager.GetReleaseDuration, Manager, Distance);
            if Success and type(Value) == 'number' then Duration = Value; end
        end
        Library:Animate(Instance, { Position = State.TargetPosition }, Duration, nil, 'DragRelease');
    end

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return;
        end

        local Pointer = GetPointer(Input);
        local ObjPos = Pointer - Instance.AbsolutePosition;

        if ObjPos.Y > (Cutoff or 40) then
            return;
        end

        FinishDrag();
        Library:CancelMotion(Instance, 'Position');
        State.ReleaseSequence = (State.ReleaseSequence or 0) + 1;
        State.Dragging = true;

        local Anchor = Instance.AnchorPoint;
        State.Input = Input;
        State.ObjectOffset = ObjPos;
        State.Anchor = Anchor;
        State.VisualAnchor = Vector2.new(
            Instance.AbsolutePosition.X + (Instance.AbsoluteSize.X * Anchor.X),
            Instance.AbsolutePosition.Y + (Instance.AbsoluteSize.Y * Anchor.Y)
        );
        State.TargetAnchor = State.VisualAnchor;

        State.DragConnection = RenderStepped:Connect(function(Delta)
            if not State.Dragging or not Instance.Parent then
                FinishDrag();
                return;
            end

            local CurrentPointer = GetPointer(Input);
            State.TargetAnchor = Vector2.new(
                CurrentPointer.X - ObjPos.X + (Instance.AbsoluteSize.X * Anchor.X),
                CurrentPointer.Y - ObjPos.Y + (Instance.AbsoluteSize.Y * Anchor.Y)
            );

            -- Dragging follows the pointer directly. Smoothing cursor input by
            -- interpolating every frame adds latency and leaves the UI behind
            -- the cursor; only the sub-frame release correction is animated.
            State.VisualAnchor = State.TargetAnchor;
            Instance.Position = UDim2.fromOffset(State.VisualAnchor.X, State.VisualAnchor.Y);
        end);

        State.InputConnection = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then FinishDrag(); end
        end);
    end);

    return State;
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

    local Content = Library:Create('CanvasGroup', {
        BackgroundColor3 = Library.MainColor,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Position = UDim2.fromOffset(0, 4),
        Size = UDim2.fromScale(1, 1),
        ZIndex = Tooltip.ZIndex,
        Parent = Tooltip,
    })

    Library:AddCorner(Content, 3);

    local Stroke = Library:Create('UIStroke', {
        Color = Library.OutlineColor,
        Thickness = 1,
        Transparency = 0,
        LineJoinMode = Enum.LineJoinMode.Miter,
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
            TextTransparency = 0,
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
            TextTransparency = 0,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = Tooltip.ZIndex + 1,
            Parent = Content,
        });
    end

    local IsHovering = false
    local AnimationId = 0
    local FollowConnection
    local Hide

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

        FollowConnection = RunService.RenderStepped:Connect(function()
            if not Tooltip.Visible then
                return
            end
            local Goal = GetTargetPosition()
            Tooltip.Position = UDim2.fromOffset(Goal.X, Goal.Y)
        end)
    end

    local function Show()
        if Library.ActiveTooltipHide and Library.ActiveTooltipHide ~= Hide then
            Library.ActiveTooltipHide(true)
        end
        Library.ActiveTooltipHide = Hide

        AnimationId = AnimationId + 1
        local WasVisible = Tooltip.Visible
        Library:CancelMotion(Content)
        IsHovering = true
        Tooltip.Visible = true
        if not WasVisible then
            Content.Position = UDim2.fromOffset(0, 4)
            Content.GroupTransparency = 1
        end

        StartFollowing()
        Library:Animate(Content, {
            Position = UDim2.fromOffset(0, 0),
            GroupTransparency = 0,
        }, 0.11, nil, 'Tooltip')
    end

    Hide = function(Instant)
        if not Tooltip.Visible then
            if Library.ActiveTooltipHide == Hide then
                Library.ActiveTooltipHide = nil
            end
            return
        end

        if Instant then
            AnimationId = AnimationId + 1
            Library:CancelMotion(Content)
            IsHovering = false
            Tooltip.Visible = false
            Content.GroupTransparency = 1
            if FollowConnection then
                FollowConnection:Disconnect()
                FollowConnection = nil
            end
            if Library.ActiveTooltipHide == Hide then
                Library.ActiveTooltipHide = nil
            end
            return
        end

        AnimationId = AnimationId + 1
        local CurrentId = AnimationId

        Library:CancelMotion(Content)
        IsHovering = false

        Library:Animate(Content, {
            Position = UDim2.fromOffset(0, -3),
            GroupTransparency = 1,
        }, 0.09, function(State)
            if State == Enum.PlaybackState.Cancelled then return end
            if CurrentId ~= AnimationId or IsHovering then
                return
            end

            Tooltip.Visible = false
            if Library.ActiveTooltipHide == Hide then
                Library.ActiveTooltipHide = nil
            end

            if FollowConnection then
                FollowConnection:Disconnect()
                FollowConnection = nil
            end

        end, 'Tooltip')
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
                Library:TweenProperty(Instance, Property, Value, 0.10);
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

        local PickerFrameOuter = Library:Create('CanvasGroup', {
            Name = 'Color';
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            GroupTransparency = 1;
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

            updateMenuPosition()
            updateMenuSize()

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
            local Tween = Library:Animate(Instance, Properties, InfoValue, nil, 'Picker');
            if not Tween then return nil; end
            table.insert(PickerTweens, Tween);
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
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 5);
                Library:SetFadeTree(PickerFrameOuter, true);
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            PlayPickerTween(PickerFrameOuter, Library:GetMenuTweenInfo(0.15, 'Picker'), {
                Position = TargetPosition;
            });
            Library:TweenFadeTree(PickerFrameOuter, false, 0.12);
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
            Library:TweenFadeTree(PickerFrameOuter, true, 0.09);
            local ExitTween = PlayPickerTween(PickerFrameOuter, Library:GetMenuTweenInfo(0.11, 'Picker'), {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 4);
            });

            local function FinishHide(State)
                if CurrentId ~= PickerAnimationId or State == Enum.PlaybackState.Cancelled then
                    return;
                end;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                Library:SetFadeTree(PickerFrameOuter, false);
                table.clear(PickerTweens);
            end
            if ExitTween then
                ExitTween.Completed:Connect(FinishHide);
            else
                FinishHide(Enum.PlaybackState.Completed);
            end
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
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddCorner(PickOuter, 3);
        Library:AddCorner(PickInner, 3);
        Library:AddToRegistry(PickOuter, { BorderColor3 = 'Black'; });
        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = tostring(Info.Default);
            TextWrapped = false;
            ZIndex = 8;
            Parent = PickInner;
        });

        local function ResizeKeyDisplay()
            local Width = math.max(DisplayLabel.TextBounds.X, select(1, Library:GetTextBounds(DisplayLabel.Text, Library.Font, 13)));
            PickOuter.Size = UDim2.fromOffset(math.max(28, Width + 10), 15);
        end;

        local function SetKeyDisplay(Key)
            DisplayLabel.Text = tostring(Key);
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

                DisplayLabel.Text = '...';

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

            Library:TweenProperty(ToggleInner, 'BackgroundColor3', Library[BackgroundKey], 0.11);
            Library:TweenProperty(ToggleInner, 'BorderColor3', Library[BorderKey], 0.11);

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

        local IsDragging = false;

        local function TrackWidth()
            local Width = SliderInner.AbsoluteSize.X;
            if Width <= 0 then
                Width = math.max(SliderRow.AbsoluteSize.X - 40, 1);
            end;

            Slider.MaxSize = math.max(Width, 1);
            return Slider.MaxSize;
        end;

        local function GetSliderVisuals(TargetX)
            local Width = TrackWidth();
            TargetX = math.clamp(TargetX, 0, Width);

            local ThumbX = SliderOuter.Position.X.Offset + TargetX;

            local BadgeWidth = ValueBadge.Size.X.Offset;
            local RowWidth = SliderRow.AbsoluteSize.X;
            local PutRight = (ThumbX + 7 + BadgeWidth) <= RowWidth;
            local BadgeX = PutRight and (ThumbX + 7) or (ThumbX - 7 - BadgeWidth);
            return UDim2.new(0, TargetX, 1, 0), UDim2.new(0, ThumbX, 0.5, 0), UDim2.new(0, BadgeX, 0.5, 0);
        end;

        local function StopVisualAnimation()
            Library:CancelMotion(Fill, 'Size');
            Library:CancelMotion(Thumb, 'Position');
            Library:CancelMotion(ValueBadge, 'Position');
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
            local TargetX = Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Width);
            local FillSize, ThumbPosition, BadgePosition = GetSliderVisuals(TargetX);
            ValueBadge.AnchorPoint = Vector2.new(0, 0.5);

            if Instant then
                StopVisualAnimation();
                Fill.Size = FillSize;
                Thumb.Position = ThumbPosition;
                ValueBadge.Position = BadgePosition;
            else
                Library:Animate(Fill, { Size = FillSize }, 0.12, nil, 'Slider');
                Library:Animate(Thumb, { Position = ThumbPosition }, 0.12, nil, 'Slider');
                Library:Animate(ValueBadge, { Position = BadgePosition }, 0.12, nil, 'Slider');
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
            Slider:Display(IsDragging);

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

        local DragChangedConnection;
        local DragEndedConnection;

        local function StopSliderDrag()
            if not IsDragging then return; end
            IsDragging = false;
            if DragChangedConnection then DragChangedConnection:Disconnect(); DragChangedConnection = nil; end
            if DragEndedConnection then DragEndedConnection:Disconnect(); DragEndedConnection = nil; end
            Slider:Display(true);
            Library:AttemptSave();
        end;

        local function BeginDrag(Input)
            if (Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch)
                or Library:MouseIsOverOpenedFrame() then
                return;
            end;

            StopSliderDrag();
            IsDragging = true;

            local function UpdateFromX(PointerX)
                local Width = TrackWidth();
                local nX = math.clamp(PointerX - SliderInner.AbsolutePosition.X, 0, Width);
                local nValue = Slider:GetValueFromXOffset(nX);

                if nValue ~= Slider.Value then
                    Slider:SetValue(nValue);
                end;
            end;

            UpdateFromX(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.X or Mouse.X);
            DragChangedConnection = InputService.InputChanged:Connect(function(ChangedInput)
                if not IsDragging then return; end
                if Input.UserInputType == Enum.UserInputType.Touch then
                    if ChangedInput == Input then UpdateFromX(Input.Position.X); end
                elseif ChangedInput.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateFromX(Mouse.X);
                end
            end);
            DragEndedConnection = InputService.InputEnded:Connect(function(EndedInput)
                if EndedInput == Input
                    or (Input.UserInputType == Enum.UserInputType.MouseButton1
                        and EndedInput.UserInputType == Enum.UserInputType.MouseButton1) then
                    StopSliderDrag();
                end
            end);
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

        if not Info.Text then
            Info.Compact = true;
        end;

        local Searchable = Info.Searchable == true;
        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Searchable = Searchable;
            Callback = Info.Callback or function(Value) end;
        };

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

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
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
        Library:AddToRegistry(DropdownOuter, { BorderColor3 = 'Black'; });
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
            Size = UDim2.new(1, -22, 1, 0);
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

        local MAX_DROPDOWN_ITEMS = tonumber(Info.MaxVisibleItems) or 8;
        local POPUP_GAP = 5;
        local SEARCH_HEIGHT = 20;
        local VALUES_PADDING = 5;
        local ROW_HEIGHT = 20;
        local ListRowsHeight = ROW_HEIGHT;
        local ListTargetPosition = UDim2.fromOffset(0, 0);
        local SearchTargetPosition = UDim2.fromOffset(0, 0);
        local SearchOuter;
        local SearchBox;

        local ListOuter = Library:Create('CanvasGroup', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            ClipsDescendants = true;
            GroupTransparency = 1;
            Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), ROW_HEIGHT + (VALUES_PADDING * 2));
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        Library:AddCorner(ListOuter, 3);
        Library:AddToRegistry(ListOuter, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ListInner = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 21;
            Parent = ListOuter;
        });

        local DropdownGradient = DropdownInner:FindFirstChildOfClass('UIGradient');
        if DropdownGradient then
            DropdownGradient:Clone().Parent = ListOuter;
        end;

        if Searchable then
            SearchOuter = Library:Create('CanvasGroup', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), SEARCH_HEIGHT);
                GroupTransparency = 1;
                ZIndex = 26;
                Visible = false;
                Parent = ScreenGui;
            });

            local SearchInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 27;
                Parent = SearchOuter;
            });

            Library:AddCorner(SearchOuter, 3);
            Library:AddCorner(SearchInner, 3);
            Library:AddToRegistry(SearchOuter, { BorderColor3 = 'Black'; });
            Library:AddToRegistry(SearchInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            SearchBox = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ClearTextOnFocus = false;
                PlaceholderColor3 = Color3.fromRGB(155, 155, 155);
                PlaceholderText = Info.SearchPlaceholder or 'Search...';
                Position = UDim2.fromOffset(6, 0);
                Size = UDim2.new(1, -12, 1, 0);
                Text = '';
                TextColor3 = Library.FontColor;
                TextSize = 13;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 28;
                Parent = SearchInner;
            });
            Library:ApplyFont(SearchBox);
            Library:ApplyTextStroke(SearchBox);
            Library:AddToRegistry(SearchBox, { TextColor3 = 'FontColor'; });
        end

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.fromOffset(0, 0);
            Position = UDim2.fromOffset(VALUES_PADDING, VALUES_PADDING);
            Size = UDim2.new(1, -(VALUES_PADDING * 2), 0, ListRowsHeight);
            ScrollBarThickness = 0;
            ScrollBarImageTransparency = 0;
            ScrollBarImageColor3 = Library.AccentColor;
            ZIndex = 21;
            Parent = ListInner;
        });
        Library:AddToRegistry(Scrolling, { ScrollBarImageColor3 = 'AccentColor'; });

        local ScrollTrack = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(1, -2, 0, VALUES_PADDING + 4);
            Size = UDim2.new(0, 3, 0, math.max(ListRowsHeight - 8, 1));
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
        Library:AddToRegistry(ScrollThumb, { BackgroundColor3 = 'AccentColor'; });
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

        local ListLayout = Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        local function RecalculateListPosition()
            local Width = math.max(DropdownOuter.AbsoluteSize.X, 1);
            local BaseX = DropdownOuter.AbsolutePosition.X;
            local BaseY = DropdownOuter.AbsolutePosition.Y + DropdownOuter.AbsoluteSize.Y + POPUP_GAP;

            if Searchable then
                SearchTargetPosition = UDim2.fromOffset(BaseX, BaseY);
                ListTargetPosition = UDim2.fromOffset(BaseX, BaseY + SEARCH_HEIGHT + POPUP_GAP);
                SearchOuter.Size = UDim2.fromOffset(Width, SEARCH_HEIGHT);
                if not Dropdown.Opened then
                    SearchOuter.Position = SearchTargetPosition;
                end
            else
                ListTargetPosition = UDim2.fromOffset(BaseX, BaseY);
            end

            if not Dropdown.Opened then
                ListOuter.Position = ListTargetPosition;
            end
            ListOuter.Size = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2));
        end;

        local function RecalculateListSize(RowHeight, Animated)
            ListRowsHeight = math.clamp(tonumber(RowHeight) or ROW_HEIGHT, ROW_HEIGHT, (MAX_DROPDOWN_ITEMS * ROW_HEIGHT) + 1);
            local Width = math.max(DropdownOuter.AbsoluteSize.X, 1);
            local OuterSize = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2));
            local ScrollSize = UDim2.new(1, -(VALUES_PADDING * 2), 0, ListRowsHeight);
            local TrackSize = UDim2.new(0, 3, 0, math.max(ListRowsHeight - 8, 1));

            if Animated and Dropdown.Opened then
                Library:TweenMenuProperty(ListOuter, 'Size', OuterSize, 0.14);
                Library:TweenMenuProperty(Scrolling, 'Size', ScrollSize, 0.14);
                Library:TweenMenuProperty(ScrollTrack, 'Size', TrackSize, 0.14);
            else
                ListOuter.Size = OuterSize;
                Scrolling.Size = ScrollSize;
                ScrollTrack.Size = TrackSize;
            end
        end;

        local function UpdateDropdownScrollVisuals()
            local ViewportHeight = math.max(Scrolling.AbsoluteSize.Y, 0);
            local ContentHeight = math.max(Scrolling.AbsoluteCanvasSize.Y, ListLayout.AbsoluteContentSize.Y, 0);
            if ViewportHeight <= 0 or ContentHeight <= ViewportHeight + 1 then
                ScrollTrack.Visible = false;
                return;
            end

            ScrollTrack.Visible = true;
            local TrackHeight = math.max(ScrollTrack.AbsoluteSize.Y, 1);
            local MinThumbHeight = math.min(18, TrackHeight);
            local ThumbHeight = math.clamp(TrackHeight * (ViewportHeight / math.max(ContentHeight, 1)), MinThumbHeight, TrackHeight);
            local MaxTravel = math.max(TrackHeight - ThumbHeight, 0);
            local MaxCanvas = math.max(ContentHeight - ViewportHeight, 1);
            local ThumbY = MaxTravel * math.clamp(Scrolling.CanvasPosition.Y / MaxCanvas, 0, 1);

            ScrollThumb.Size = UDim2.new(0, 2, 0, ThumbHeight);
            ScrollThumb.Position = UDim2.new(0.5, 0, 0, ThumbY);
        end;

        ListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Scrolling.CanvasSize = UDim2.fromOffset(0, math.max(ListLayout.AbsoluteContentSize.Y, 1));
            task.defer(UpdateDropdownScrollVisuals);
        end);
        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(UpdateDropdownScrollVisuals);
        Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() task.defer(UpdateDropdownScrollVisuals); end);
        ListOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() task.defer(UpdateDropdownScrollVisuals); end);
        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);
        DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(RecalculateListPosition);

        function Dropdown:Display()
            local Str = '';
            if Info.Multi then
                for _, Value in next, Dropdown.Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. tostring(Value) .. ', ';
                    end
                end
                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end
            ItemList.Text = (Str == '' and '--' or tostring(Str));
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};
                for Value, Bool in next, Dropdown.Value do
                    if Bool then table.insert(T, Value); end
                end
                return T;
            end
            return Dropdown.Value and 1 or 0;
        end;

        local Buttons = {};
        local ButtonOrder = {};
        local ApplyDropdownSearch;

        function Dropdown:BuildDropdownList()
            table.clear(Buttons);
            table.clear(ButtonOrder);

            for _, Element in next, Scrolling:GetChildren() do
                if Element ~= ListLayout then
                    Element:Destroy();
                end
            end

            for Index, Value in ipairs(Dropdown.Values) do
                local Row = {};
                local Button = Library:Create('CanvasGroup', {
                    Active = true;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    ClipsDescendants = true;
                    GroupTransparency = 0;
                    LayoutOrder = Index;
                    Size = UDim2.new(1, -5, 0, ROW_HEIGHT);
                    ZIndex = 23;
                    Parent = Scrolling;
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Position = UDim2.new(0, 6, 0, 0);
                    Size = UDim2.new(1, -8, 0, ROW_HEIGHT);
                    TextSize = 14;
                    Text = tostring(Value);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Row.Button = Button;
                Row.Label = ButtonLabel;
                Row.Value = Value;

                function Row:UpdateButton()
                    local Selected = Info.Multi and Dropdown.Value[Value] or Dropdown.Value == Value;
                    local TextColorKey = Selected and 'AccentColor' or 'FontColor';
                    Library:TweenProperty(ButtonLabel, 'TextColor3', Library[TextColorKey], 0.10);
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = TextColorKey;
                end;

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or not Button.Active then
                        return;
                    end

                    local Selected = Info.Multi and Dropdown.Value[Value] or Dropdown.Value == Value;
                    local Try = not Selected;
                    if Dropdown:GetActiveValues() == 1 and not Try and not Info.AllowNull then
                        return;
                    end

                    if Info.Multi then
                        if Try then Dropdown.Value[Value] = true else Dropdown.Value[Value] = nil end
                    else
                        Dropdown.Value = Try and Value or nil;
                    end

                    for _, Other in ipairs(ButtonOrder) do Other:UpdateButton(); end
                    Dropdown:Display();
                    Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                    Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
                    Library:AttemptSave();
                end);

                Library:PrimeFadeTree(Button);
                Row:UpdateButton();
                Buttons[Button] = Row;
                table.insert(ButtonOrder, Row);
            end

            Dropdown:Display();
            if ApplyDropdownSearch then
                ApplyDropdownSearch(true);
            else
                local Rows = math.max(1, math.min(#ButtonOrder, MAX_DROPDOWN_ITEMS));
                RecalculateListSize((Rows * ROW_HEIGHT) + 1, false);
            end
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValue(NewValue)
            if Info.Multi then
                local NewSelection = {};
                if type(NewValue) == 'table' then
                    for Key, Value in next, NewValue do
                        if type(Key) == 'number' then
                            NewSelection[Value] = true;
                        elseif Value then
                            NewSelection[Key] = true;
                        end
                    end
                end
                Dropdown.Value = NewSelection;
            else
                if NewValue == nil and not Info.AllowNull then return; end
                if NewValue ~= nil and not table.find(Dropdown.Values, NewValue) then return; end
                Dropdown.Value = NewValue;
            end

            for _, Row in ipairs(ButtonOrder) do Row:UpdateButton(); end
            Dropdown:Display();
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then Dropdown.Values = NewValues; end
            Dropdown:BuildDropdownList();
        end;

        ApplyDropdownSearch = function(Instant)
            local Query = SearchBox and string.lower(SearchBox.Text or '') or '';
            local VisibleCount = 0;

            for _, Row in ipairs(ButtonOrder) do
                local Matches = Query == '' or string.find(string.lower(tostring(Row.Value)), Query, 1, true) ~= nil;
                if Matches then VisibleCount = VisibleCount + 1; end
                Row.Button.Active = Matches;

                if Instant then
                    Row.Button.Size = UDim2.new(1, -5, 0, Matches and ROW_HEIGHT or 0);
                    Library:SetFadeTree(Row.Button, not Matches);
                else
                    Library:TweenProperty(Row.Button, 'Size', UDim2.new(1, -5, 0, Matches and ROW_HEIGHT or 0), 0.13);
                    Library:TweenFadeTree(Row.Button, not Matches, Matches and 0.12 or 0.09);
                end
            end

            local Rows = math.max(1, math.min(VisibleCount, MAX_DROPDOWN_ITEMS));
            RecalculateListSize((Rows * ROW_HEIGHT) + 1, not Instant);
            Scrolling.CanvasPosition = Vector2.new(0, 0);
            task.defer(UpdateDropdownScrollVisuals);
        end;

        if SearchBox then
            SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
                ApplyDropdownSearch(false);
            end);
        end

        local DropdownTweens = {};
        local DropdownAnimationId = 0;
        local DropdownScrollConnection;

        local function CancelDropdownTweens()
            for _, Tween in next, DropdownTweens do
                pcall(function() Tween:Cancel(); end);
            end
            table.clear(DropdownTweens);
        end

        local function PlayDropdownTween(Instance, InfoValue, Properties)
            local Tween = Library:Animate(Instance, Properties, InfoValue, nil, 'Dropdown');
            if not Tween then return nil; end
            table.insert(DropdownTweens, Tween);
            return Tween;
        end

        local function StopDropdownAutoScroll()
            if DropdownScrollConnection then
                DropdownScrollConnection:Disconnect();
                DropdownScrollConnection = nil;
            end
        end

        local function StartDropdownAutoScroll()
            StopDropdownAutoScroll();
            DropdownScrollConnection = RenderStepped:Connect(function(Delta)
                if not Dropdown.Opened or not ListOuter.Visible then
                    StopDropdownAutoScroll();
                    return;
                end

                local Position = ListOuter.AbsolutePosition;
                local Size = ListOuter.AbsoluteSize;
                if Mouse.X < Position.X or Mouse.X > Position.X + Size.X then return; end

                local Edge = math.min(24, math.max(Size.Y * 0.24, 12));
                local Direction = 0;
                local Strength = 0;
                if Mouse.Y >= Position.Y + Size.Y - Edge and Mouse.Y <= Position.Y + Size.Y + 5 then
                    Direction = 1;
                    Strength = math.clamp((Mouse.Y - (Position.Y + Size.Y - Edge)) / Edge, 0, 1);
                elseif Mouse.Y <= Position.Y + Edge and Mouse.Y >= Position.Y - 5 then
                    Direction = -1;
                    Strength = math.clamp(((Position.Y + Edge) - Mouse.Y) / Edge, 0, 1);
                end

                if Direction ~= 0 then
                    local MaxCanvas = math.max(Scrolling.AbsoluteCanvasSize.Y - Scrolling.AbsoluteSize.Y, 0);
                    if MaxCanvas > 0 then
                        local NewY = math.clamp(Scrolling.CanvasPosition.Y + Direction * (90 + 220 * Strength) * Delta, 0, MaxCanvas);
                        Scrolling.CanvasPosition = Vector2.new(0, NewY);
                    end
                end
            end);
        end

        local function PointInside(Frame)
            if not Frame or not Frame.Visible then return false; end
            local P, S = Frame.AbsolutePosition, Frame.AbsoluteSize;
            return Mouse.X >= P.X and Mouse.X <= P.X + S.X and Mouse.Y >= P.Y and Mouse.Y <= P.Y + S.Y;
        end

        function Dropdown:OpenDropdown()
            if Dropdown.Opened then return; end
            Dropdown.Opened = true;
            DropdownAnimationId = DropdownAnimationId + 1;
            CancelDropdownTweens();

            if SearchBox and SearchBox.Text ~= '' then SearchBox.Text = ''; end
            ApplyDropdownSearch(true);
            RecalculateListPosition();

            if SearchOuter then
                SearchOuter.Position = UDim2.fromOffset(SearchTargetPosition.X.Offset, SearchTargetPosition.Y.Offset - 5);
                Library:SetFadeTree(SearchOuter, true);
                SearchOuter.Visible = true;
                Library.OpenedFrames[SearchOuter] = true;
                PlayDropdownTween(SearchOuter, Library:GetMenuTweenInfo(0.13, 'Dropdown'), { Position = SearchTargetPosition });
                Library:TweenMenuFadeTree(SearchOuter, false, 0.10);
            end

            ListOuter.Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 5);
            Library:SetFadeTree(ListOuter, true);
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            PlayDropdownTween(ListOuter, Library:GetMenuTweenInfo(0.14, 'Dropdown'), { Position = ListTargetPosition });
            Library:TweenMenuFadeTree(ListOuter, false, 0.11);
            PlayDropdownTween(DropdownArrow, Library:GetMenuTweenInfo(0.12, 'Dropdown'), { Rotation = 180 });
            StartDropdownAutoScroll();
        end;

        function Dropdown:CloseDropdown()
            if not Dropdown.Opened and not ListOuter.Visible then return; end
            Dropdown.Opened = false;
            DropdownAnimationId = DropdownAnimationId + 1;
            local CurrentId = DropdownAnimationId;
            CancelDropdownTweens();
            StopDropdownAutoScroll();
            Library.OpenedFrames[ListOuter] = nil;
            if SearchOuter then Library.OpenedFrames[SearchOuter] = nil; end

            Library:TweenMenuFadeTree(ListOuter, true, 0.09);
            local ExitTween = PlayDropdownTween(ListOuter, Library:GetMenuTweenInfo(0.11, 'Dropdown'), {
                Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 4)
            });

            if SearchOuter and SearchOuter.Visible then
                Library:TweenMenuFadeTree(SearchOuter, true, 0.08);
                PlayDropdownTween(SearchOuter, Library:GetMenuTweenInfo(0.10, 'Dropdown'), {
                    Position = UDim2.fromOffset(SearchTargetPosition.X.Offset, SearchTargetPosition.Y.Offset - 4)
                });
            end

            PlayDropdownTween(DropdownArrow, Library:GetMenuTweenInfo(0.10, 'Dropdown'), { Rotation = 0 });
            local function FinishClose(State)
                if CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then return; end
                ListOuter.Visible = false;
                ListOuter.Position = ListTargetPosition;
                Library:SetFadeTree(ListOuter, false);
                if SearchOuter then
                    SearchOuter.Visible = false;
                    SearchOuter.Position = SearchTargetPosition;
                    Library:SetFadeTree(SearchOuter, false);
                end
                table.clear(DropdownTweens);
            end
            if ExitTween then
                ExitTween.Completed:Connect(FinishClose);
            else
                FinishClose(Enum.PlaybackState.Completed);
            end
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if Dropdown.Opened then Dropdown:CloseDropdown() else Dropdown:OpenDropdown() end
            end
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Opened then
                if not PointInside(ListOuter) and not PointInside(SearchOuter) and not PointInside(DropdownOuter) then
                    Dropdown:CloseDropdown();
                end
            end
        end));

        Dropdown:BuildDropdownList();

        local Defaults = {};
        if type(Info.Default) == 'string' then
            local Index = table.find(Dropdown.Values, Info.Default);
            if Index then table.insert(Defaults, Index); end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Index = table.find(Dropdown.Values, Value);
                if Index then table.insert(Defaults, Index); end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default);
        end

        if next(Defaults) then
            for _, Index in ipairs(Defaults) do
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true;
                else
                    Dropdown.Value = Dropdown.Values[Index];
                    break;
                end
            end
            for _, Row in ipairs(ButtonOrder) do Row:UpdateButton(); end
            Dropdown:Display();
        end

        RecalculateListPosition();
        ApplyDropdownSearch(true);
        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Dropdown.SearchBox = SearchBox;
        Dropdown.SearchFrame = SearchOuter;
        Dropdown.ListFrame = ListOuter;
        Options[Idx] = Dropdown;
        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };
        
        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('CanvasGroup', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            GroupTransparency = 1;
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

            if Visible == DependencyVisible and Holder.Visible == Visible then
                if Visible then
                    if Instant then
                        Holder.Size = UDim2.new(1, 0, 0, Height);
                    else
                        Library:TweenProperty(Holder, 'Size', UDim2.new(1, 0, 0, Height), 0.13);
                    end
                    Groupbox:Resize();
                end
                return;
            end

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
                DependencySizeTween = Library:Animate(Holder, {
                    Size = UDim2.new(1, 0, 0, Height)
                }, 0.15, nil, 'Dependency');
                Library:TweenFadeTree(Holder, false, 0.11);
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

                Library:TweenFadeTree(Holder, true, 0.08);
                DependencySizeTween = Library:Animate(Holder, {
                    Size = UDim2.new(1, 0, 0, 0)
                }, 0.12, nil, 'Dependency');

                if DependencySizeTween then DependencySizeTween.Completed:Connect(function(State)
                    if CurrentId ~= DependencyAnimationId or DependencyVisible or State == Enum.PlaybackState.Cancelled then
                        return;
                    end;

                    Holder.Visible = false;
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                end); end
            end;
        end;

        function Depbox:Resize(Instant)
            local Height = Layout.AbsoluteContentSize.Y;
            if DependencyVisible and Holder.Visible then
                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, Height);
                else
                    Library:TweenProperty(Holder, 'Size', UDim2.new(1, 0, 0, Height), 0.13);
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
    Library:AddAccentOutline(WatermarkInner, 0.9);

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

    WatermarkLabel.TextStrokeColor3 = Color3.new(0, 0, 0);
    WatermarkLabel.TextStrokeTransparency = 0.08;

    local WatermarkTextOutline = WatermarkLabel:FindFirstChildOfClass('UIStroke');
    if not WatermarkTextOutline then
        WatermarkTextOutline = Library:Create('UIStroke', {
            Name = 'FormaWatermarkTextOutline';
            Color = Color3.new(0, 0, 0);
            Thickness = 1.1;
            Transparency = 0.08;
            LineJoinMode = Enum.LineJoinMode.Miter;
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
            Parent = WatermarkLabel;
        });
    else
        WatermarkTextOutline.Color = Color3.new(0, 0, 0);
        WatermarkTextOutline.Thickness = 1.1;
        WatermarkTextOutline.Transparency = 0.08;
        WatermarkTextOutline.LineJoinMode = Enum.LineJoinMode.Miter;
        pcall(function() WatermarkTextOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual; end);
    end

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
    Library:AddAccentOutline(KeybindInner, 1);

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


function Library:CreateTargetHUD(Config)
    Config = Config or {};

    if Library.TargetHUD and Library.TargetHUD.Destroy then
        Library.TargetHUD:Destroy();
    end

    local function NormalizeAutoTargetMode(Value)
        local Mode = string.lower(tostring(Value or 'Off'));
        if Mode == 'look' or Mode == 'crosshair' or Mode == 'camera' then
            return 'Look';
        elseif Mode == 'hover' or Mode == 'mouse' then
            return 'Hover';
        elseif Mode == 'lookorhover' or Mode == 'look_or_hover' or Mode == 'both' then
            return 'LookOrHover';
        end
        return 'Off';
    end

    local RequestedAutoMode = Config.AutoTargetMode or Config.TargetMode;
    if RequestedAutoMode == nil then
        if Config.AutoShowOnLook and Config.AutoShowOnHover then
            RequestedAutoMode = 'LookOrHover';
        elseif Config.AutoShowOnLook then
            RequestedAutoMode = 'Look';
        elseif Config.AutoShowOnHover then
            RequestedAutoMode = 'Hover';
        else
            RequestedAutoMode = 'Off';
        end
    end

    local HUD = {
        Target = nil;
        StaticInfo = nil;
        InfoProvider = Config.InfoProvider or Config.GetInfo;
        HealthProvider = Config.HealthProvider or Config.GetHealth;
        MeterProvider = Config.MeterProvider or Config.GetMeter;
        MeterText = Config.MeterText;
        AutoDistanceMeter = Config.AutoDistanceMeter == true;
        HealthTextFormatter = Config.HealthTextFormatter;
        AnimationId = 0;
        Visible = false;
        Labels = {};
        LabelOrder = {};
        ProviderLabelIds = {};
        HealthMax = 100;
        HealthAvailable = false;
        HealthTargetRatio = -1;
        AutoTargetMode = NormalizeAutoTargetMode(RequestedAutoMode);
        AutoTargetMaxDistance = math.max(tonumber(Config.AutoTargetMaxDistance or Config.MaxTargetDistance) or 1500, 1);
        AutoTargetCandidate = nil;
    };

    local BaseSize = Config.Size or UDim2.fromOffset(290, 148);
    local BaseHeight = math.max(BaseSize.Y.Offset, 148);

    local Outer = Library:Create('CanvasGroup', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = Config.Position or UDim2.new(0.5, 285, 0.5, 120);
        Size = UDim2.new(BaseSize.X.Scale, BaseSize.X.Offset, BaseSize.Y.Scale, BaseHeight);
        GroupTransparency = 1;
        Visible = false;
        ZIndex = 250;
        Parent = ScreenGui;
    });

    local HUDScale = Library:Create('UIScale', {
        Scale = 0.985;
        Parent = Outer;
    });

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(1, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 251;
        Parent = Outer;
    });

    Library:AddCorner(Outer, 3);
    Library:AddCorner(Inner, 3);
    Library:AddAccentGlow(Inner, 0.95);
    Library:AddAccentOutline(Inner, 1);
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    }, true);

    local ContentFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(6, 6);
        Size = UDim2.new(1, -12, 1, -12);
        ZIndex = 252;
        Parent = Inner;
    });
    Library:AddCorner(ContentFrame, 3);
    Library:AddToRegistry(ContentFrame, {
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
            LineJoinMode = Enum.LineJoinMode.Miter;
            Parent = Frame;
        });
        Library:AddToRegistry(Stroke, { Color = 'OutlineColor'; }, true);
        return Stroke;
    end
    local ContentOutline = AddTargetHUDOutline(ContentFrame, 'FormaTargetContentOutline', 0.10);

    local AvatarOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(8, 8);
        Size = UDim2.fromOffset(76, 76);
        ZIndex = 253;
        Parent = ContentFrame;
    });
    Library:AddCorner(AvatarOuter, 3);
    Library:AddToRegistry(AvatarOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local AvatarOutline = AddTargetHUDOutline(AvatarOuter, 'FormaTargetAvatarOutline', 0.06);

    local Avatar = Library:Create('ImageLabel', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(2, 2);
        Size = UDim2.new(1, -4, 1, -4);
        Image = '';
        ZIndex = 254;
        Parent = AvatarOuter;
    });
    Library:AddCorner(Avatar, 3);

    local Username = Library:CreateLabel({
        Position = UDim2.fromOffset(94, 8);
        Size = UDim2.new(1, -102, 0, 18);
        Text = 'No target';
        TextColor3 = Library.AccentColor;
        TextSize = 15;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 254;
        Parent = ContentFrame;
    });
    Library.RegistryMap[Username].Properties.TextColor3 = 'AccentColor';

    local LabelsContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(94, 47);
        Size = UDim2.new(1, -102, 0, 0);
        ZIndex = 254;
        Parent = ContentFrame;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 0);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = LabelsContainer;
    });

    local MeterLabel = Library:CreateLabel({
        Position = UDim2.fromOffset(94, 29);
        Size = UDim2.new(1, -102, 0, 14);
        Text = '';
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Center;
        ZIndex = 255;
        Visible = false;
        Parent = ContentFrame;
    });

    local HealthTitleLabel = Library:CreateLabel({
        AnchorPoint = Vector2.new(0, 1);
        Position = UDim2.new(0, 8, 1, -28);
        Size = UDim2.new(0.5, -8, 0, 14);
        Text = 'Health';
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 255;
        Parent = ContentFrame;
    });

    local HealthValueLabel = Library:CreateLabel({
        AnchorPoint = Vector2.new(1, 1);
        Position = UDim2.new(1, -8, 1, -28);
        Size = UDim2.new(0.5, -8, 0, 14);
        Text = '-- HP';
        TextSize = 12;
        TextXAlignment = Enum.TextXAlignment.Right;
        ZIndex = 255;
        Parent = ContentFrame;
    });

    local HealthOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        ClipsDescendants = true;
        Position = UDim2.new(0, 8, 1, -8);
        Size = UDim2.new(1, -16, 0, 14);
        ZIndex = 255;
        Parent = ContentFrame;
    });
    Library:AddCorner(HealthOuter, 3);
    Library:AddToRegistry(HealthOuter, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local HealthOutline = AddTargetHUDOutline(HealthOuter, 'FormaTargetHealthOutline', 0.04);

    local HealthInner = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = UDim2.fromOffset(1, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 256;
        Parent = HealthOuter;
    });
    Library:AddCorner(HealthInner, 2);

    local HealthFill = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = 256;
        Parent = HealthInner;
    });
    Library:AddCorner(HealthFill, 2);

    local HealthGradient = Library:Create('UIGradient', {
        Rotation = 90;
        Offset = Vector2.zero;
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(236, 95, 100)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(211, 63, 69)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(151, 39, 45)),
        });
        Parent = HealthFill;
    });

    local HealthDriver = Instance.new('NumberValue');
    HealthDriver.Name = 'FormaTargetHealthDriver';
    HealthDriver.Value = 0;
    HealthDriver.Parent = HealthOuter;
    local HealthSmoothTime = math.clamp(tonumber(Config.HealthSmoothTime or Config.HealthTweenTime) or 0.12, 0.05, 0.5);

    local function HealthBaseColor(Ratio)
        local Danger = Color3.fromRGB(211, 63, 69);
        local Warning = Color3.fromRGB(231, 166, 63);
        local Healthy = Color3.fromRGB(75, 195, 119);
        Ratio = math.clamp(Ratio, 0, 1);
        if Ratio < 0.5 then
            return Danger:Lerp(Warning, Ratio * 2);
        end
        return Warning:Lerp(Healthy, (Ratio - 0.5) * 2);
    end

    local function UpdateHealthGradient(Ratio)
        local Base = HealthBaseColor(Ratio);
        local Top = Base:Lerp(Color3.new(1, 1, 1), 0.18);
        local Bottom = Base:Lerp(Color3.new(0, 0, 0), 0.28);
        HealthGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Top),
            ColorSequenceKeypoint.new(0.52, Base),
            ColorSequenceKeypoint.new(1, Bottom),
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

    HealthDriver:GetPropertyChangedSignal('Value'):Connect(UpdateHealthVisual);

    local function CountVisibleLabels()
        local Count = 0;
        for _, Id in ipairs(HUD.LabelOrder) do
            local Handle = HUD.Labels[Id];
            if Handle and Handle.Label and Handle.Label.Parent and Handle.Visible ~= false then
                Count = Count + 1;
            end
        end
        return Count;
    end

    local function UpdateLayout()
        local Count = CountVisibleLabels();
        local ExtraRows = math.max(0, Count - 3);
        local Height = BaseHeight + (ExtraRows * 14);
        Outer.Size = UDim2.new(BaseSize.X.Scale, BaseSize.X.Offset, BaseSize.Y.Scale, Height);
        LabelsContainer.Size = UDim2.new(1, -102, 0, Count * 14);
    end

    local function RenderLabelHandle(Handle)
        if not Handle or not Handle.Label then return; end
        local Value = Handle.Value;
        if type(Value) == 'function' then
            local Success, Result = pcall(Value, HUD.Target, HUD, Handle);
            Value = Success and Result or '';
        end

        if Value == nil or tostring(Value) == '' then
            Handle.Label.Text = tostring(Handle.Name or '');
        elseif Handle.Name and tostring(Handle.Name) ~= '' then
            Handle.Label.Text = tostring(Handle.Name) .. ': ' .. tostring(Value);
        else
            Handle.Label.Text = tostring(Value);
        end
        Handle.Label.Visible = Handle.Visible ~= false;
    end

    local function CreateLabelHandle(Id, Name, Value, IsProvider)
        Id = tostring(Id);
        local Existing = HUD.Labels[Id];
        if Existing then
            Existing.Name = Name;
            Existing.Value = Value;
            Existing.IsProvider = IsProvider or false;
            RenderLabelHandle(Existing);
            return Existing;
        end

        local Label = Library:CreateLabel({
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 14);
            Text = '';
            TextSize = 12;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 255;
            Parent = LabelsContainer;
        });

        local Handle = {
            Id = Id;
            Name = Name;
            Value = Value;
            Label = Label;
            Visible = true;
            IsProvider = IsProvider or false;
        };

        function Handle:SetText(Text)
            Handle.Name = '';
            Handle.Value = Text;
            RenderLabelHandle(Handle);
        end

        function Handle:SetValue(NewValue)
            Handle.Value = NewValue;
            RenderLabelHandle(Handle);
        end

        function Handle:SetVisible(Visible)
            Handle.Visible = not not Visible;
            RenderLabelHandle(Handle);
            UpdateLayout();
        end

        function Handle:Destroy()
            HUD:RemoveLabel(Id);
        end

        HUD.Labels[Id] = Handle;
        table.insert(HUD.LabelOrder, Id);
        RenderLabelHandle(Handle);
        UpdateLayout();
        return Handle;
    end

    function HUD:AddLabel(Name, Value, Id)
        Id = Id or tostring(Name or ('Label' .. tostring(#HUD.LabelOrder + 1)));
        return CreateLabelHandle(Id, Name, Value, false);
    end

    function HUD:SetLabel(Name, Value)
        return HUD:AddLabel(Name, Value, tostring(Name));
    end

    function HUD:RemoveLabel(Id)
        Id = tostring(Id);
        local Handle = HUD.Labels[Id];
        if not Handle then return; end
        if Handle.Label then Handle.Label:Destroy(); end
        HUD.Labels[Id] = nil;
        local Index = table.find(HUD.LabelOrder, Id);
        if Index then table.remove(HUD.LabelOrder, Index); end
        local ProviderIndex = table.find(HUD.ProviderLabelIds, Id);
        if ProviderIndex then table.remove(HUD.ProviderLabelIds, ProviderIndex); end
        UpdateLayout();
    end

    function HUD:ClearLabels(IncludeProvider)
        local Remove = {};
        for Id, Handle in next, HUD.Labels do
            if IncludeProvider or not Handle.IsProvider then
                table.insert(Remove, Id);
            end
        end
        for _, Id in ipairs(Remove) do HUD:RemoveLabel(Id); end
    end

    local function ClearProviderLabels()
        local Ids = table.clone(HUD.ProviderLabelIds);
        for _, Id in ipairs(Ids) do HUD:RemoveLabel(Id); end
        table.clear(HUD.ProviderLabelIds);
    end

    local function ApplyProviderInfo(Info)
        local Entries = {};

        local function Queue(Name, Value)
            table.insert(Entries, { Name or '', Value });
        end

        if type(Info) == 'string' or type(Info) == 'number' then
            Queue('', Info);
        elseif type(Info) == 'table' then
            if #Info > 0 then
                for _, Entry in ipairs(Info) do
                    if type(Entry) == 'table' then
                        Queue(Entry[1] or Entry.Name or Entry.Label or '', Entry[2] or Entry.Value or '');
                    else
                        Queue('', Entry);
                    end
                end
            else
                local Keys = {};
                for Key in next, Info do table.insert(Keys, Key); end
                table.sort(Keys, function(A, B) return tostring(A) < tostring(B); end);
                for _, Key in ipairs(Keys) do Queue(Key, Info[Key]); end
            end
        end

        for Index, Entry in ipairs(Entries) do
            local Id = '__provider_' .. tostring(Index);
            if not table.find(HUD.ProviderLabelIds, Id) then table.insert(HUD.ProviderLabelIds, Id); end
            CreateLabelHandle(Id, Entry[1], Entry[2], true);
        end

        for Index = #HUD.ProviderLabelIds, #Entries + 1, -1 do
            local Id = HUD.ProviderLabelIds[Index];
            HUD:RemoveLabel(Id);
        end
        UpdateLayout();
    end

    function HUD:SetInfo(Info)
        HUD.StaticInfo = Info;
        ApplyProviderInfo(Info);
    end

    function HUD:SetInfoProvider(Provider)
        HUD.InfoProvider = type(Provider) == 'function' and Provider or nil;
        HUD:Refresh();
    end

    function HUD:SetMeter(Text)
        HUD.MeterText = Text;
        HUD:Refresh();
    end

    function HUD:SetMeterProvider(Provider)
        HUD.MeterProvider = type(Provider) == 'function' and Provider or nil;
        HUD:Refresh();
    end

    function HUD:SetAutoDistanceMeter(Enabled)
        HUD.AutoDistanceMeter = not not Enabled;
        HUD:Refresh();
    end

    function HUD:SetHealthProvider(Provider)
        HUD.HealthProvider = type(Provider) == 'function' and Provider or nil;
        HUD:Refresh();
    end

    function HUD:SetHealth(Current, Maximum, Instant)
        Current = tonumber(Current);
        Maximum = tonumber(Maximum);
        if not Current or not Maximum or Maximum <= 0 then
            HUD.HealthAvailable = false;
            HUD.HealthMax = 100;
            HUD.HealthTargetRatio = 0;
            Library:CancelMotion(HealthDriver, 'Value');
            HealthDriver.Value = 0;
            UpdateHealthVisual();
            return;
        end
        HUD.HealthAvailable = true;
        HUD.HealthMax = math.max(1, Maximum);
        local NewRatio = math.clamp(Current / HUD.HealthMax, 0, 1);
        local TargetChanged = math.abs(NewRatio - (HUD.HealthTargetRatio or -1)) > 0.0001;
        HUD.HealthTargetRatio = NewRatio;
        if Instant then
            Library:CancelMotion(HealthDriver, 'Value');
            HealthDriver.Value = NewRatio;
        elseif TargetChanged then
            Library:Animate(HealthDriver, { Value = NewRatio }, HealthSmoothTime, nil, 'Health');
        end
    end

    local function ResolveHealth(Target)
        if HUD.HealthProvider then
            local Success, Current, Maximum = pcall(HUD.HealthProvider, Target, HUD);
            if Success then return Current, Maximum; end
        end

        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            local Character = Target.Character;
            local Humanoid = Character and Character:FindFirstChildOfClass('Humanoid');
            if Humanoid then return Humanoid.Health, Humanoid.MaxHealth; end
        elseif type(Target) == 'table' then
            local Current = Target.Health or Target.CurrentHealth;
            local Maximum = Target.MaxHealth or Target.MaximumHealth;
            if Current ~= nil and Maximum ~= nil then return Current, Maximum; end
        end
        return nil, nil;
    end

    local function ResolveMeter(Target)
        if HUD.MeterText ~= nil then
            return tostring(HUD.MeterText);
        end

        if HUD.MeterProvider then
            local Success, Result = pcall(HUD.MeterProvider, Target, HUD);
            if Success and Result ~= nil then return tostring(Result); end
        end

        if type(Target) == 'table' then
            local Value = Target.MeterText or Target.Meter;
            if Value ~= nil then return tostring(Value); end
        end

        if HUD.AutoDistanceMeter and typeof(Target) == 'Instance' and Target:IsA('Player') then
            local Character = Target.Character;
            local Root = Character and Character:FindFirstChild('HumanoidRootPart');
            local LocalCharacter = LocalPlayer.Character;
            local LocalRoot = LocalCharacter and LocalCharacter:FindFirstChild('HumanoidRootPart');
            if Root and LocalRoot then
                return string.format('%d studs', math.floor((Root.Position - LocalRoot.Position).Magnitude + 0.5));
            end
        end

        return '';
    end

    local function PlayerFromPart(Part)
        local Current = Part;
        while Current and Current ~= workspace do
            if Current:IsA('Model') then
                local Player = Players:GetPlayerFromCharacter(Current);
                if Player and Player ~= LocalPlayer then
                    return Player;
                end
            end
            Current = Current.Parent;
        end
        return nil;
    end

    local function GetHoverTarget()
        return PlayerFromPart(Mouse.Target);
    end

    local function GetLookTarget()
        local Camera = workspace.CurrentCamera;
        if not Camera then return nil; end

        local Viewport = Camera.ViewportSize;
        local Ray = Camera:ViewportPointToRay(Viewport.X * 0.5, Viewport.Y * 0.5);
        local Params = RaycastParams.new();
        Params.FilterType = Enum.RaycastFilterType.Exclude;
        Params.FilterDescendantsInstances = LocalPlayer.Character and { LocalPlayer.Character } or {};
        Params.IgnoreWater = true;

        local Result = workspace:Raycast(Ray.Origin, Ray.Direction * HUD.AutoTargetMaxDistance, Params);
        return Result and PlayerFromPart(Result.Instance) or nil;
    end

    local function ResolveAutoTarget()
        if HUD.AutoTargetMode == 'Hover' then
            return GetHoverTarget();
        elseif HUD.AutoTargetMode == 'Look' then
            return GetLookTarget();
        elseif HUD.AutoTargetMode == 'LookOrHover' then
            return GetHoverTarget() or GetLookTarget();
        end
        return nil;
    end

    function HUD:SetAutoTargetMode(Mode)
        HUD.AutoTargetMode = NormalizeAutoTargetMode(Mode);
        HUD.AutoTargetCandidate = nil;
        return HUD.AutoTargetMode;
    end

    function HUD:GetAutoTargetMode()
        return HUD.AutoTargetMode;
    end

    function HUD:SetAutoTargetMaxDistance(Distance)
        HUD.AutoTargetMaxDistance = math.max(tonumber(Distance) or HUD.AutoTargetMaxDistance, 1);
    end

    function HUD:Refresh()
        local Target = HUD.Target;

        if not Target then
            Username.Text = 'No target';
            local Meter = HUD.MeterText and tostring(HUD.MeterText) or '';
            MeterLabel.Text = Meter;
            MeterLabel.Visible = Meter ~= '';
            HUD:SetHealth(nil, nil, true);

            if HUD.InfoProvider then
                local Success, Result = pcall(HUD.InfoProvider, Target, HUD);
                ApplyProviderInfo(Success and Result or HUD.StaticInfo);
            elseif HUD.StaticInfo ~= nil then
                ApplyProviderInfo(HUD.StaticInfo);
            else
                ClearProviderLabels();
            end

            for _, Id in ipairs(HUD.LabelOrder) do
                local Handle = HUD.Labels[Id];
                if Handle and not Handle.IsProvider then RenderLabelHandle(Handle); end
            end
            UpdateLayout();
            return;
        end

        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            Username.Text = '@' .. Target.Name;
        elseif type(Target) == 'table' then
            Username.Text = tostring(Target.Username or Target.Name or Target.DisplayName or 'Target');
        else
            Username.Text = tostring(Target);
        end

        local Meter = ResolveMeter(Target);
        MeterLabel.Text = Meter;
        MeterLabel.Visible = Meter ~= '';

        local Current, Maximum = ResolveHealth(Target);
        HUD:SetHealth(Current, Maximum, false);

        if HUD.InfoProvider then
            local Success, Result = pcall(HUD.InfoProvider, Target, HUD);
            ApplyProviderInfo(Success and Result or HUD.StaticInfo);
        elseif HUD.StaticInfo ~= nil then
            ApplyProviderInfo(HUD.StaticInfo);
        else
            ClearProviderLabels();
        end

        for _, Id in ipairs(HUD.LabelOrder) do
            local Handle = HUD.Labels[Id];
            if Handle and not Handle.IsProvider then RenderLabelHandle(Handle); end
        end
        UpdateLayout();
    end

    function HUD:SetTarget(Target, Info)
        if HUD.Target == Target and Info == nil then
            HUD:Refresh();
            return;
        end

        HUD.Target = Target;
        if Info ~= nil then
            HUD.StaticInfo = Info;
        end
        HUD:Refresh();

        local UserId;
        local DirectImage;
        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            UserId = Target.UserId;
        elseif type(Target) == 'table' then
            UserId = tonumber(Target.UserId);
            DirectImage = Target.Avatar or Target.Image;
        end

        if DirectImage then
            Avatar.Image = tostring(DirectImage);
        elseif UserId then
            local Expected = Target;
            task.spawn(function()
                local Success, Content = pcall(function()
                    return Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150);
                end);
                if Success and HUD.Target == Expected and Avatar.Parent then
                    Avatar.Image = Content;
                end
            end);
        else
            Avatar.Image = '';
        end
    end

    function HUD:SetVisible(Visible)
        Visible = not not Visible;
        if HUD.Visible == Visible then
            return;
        end

        HUD.Visible = Visible;
        HUD.AnimationId = HUD.AnimationId + 1;
        local CurrentId = HUD.AnimationId;
        local Duration = tonumber(Config.AnimationTime or Config.TweenTime) or 0.18;

        if Visible then
            if not Outer.Visible then
                Library:SetUnifiedFadeProgress(Outer, 0);
                HUDScale.Scale = 0.985;
                Outer.Visible = true;
            end
            Library:Animate(HUDScale, { Scale = 1; }, Duration, nil, 'HUD');
            Library:TweenUnifiedFade(Outer, 1, Duration, nil, 'HUD');
        elseif Outer.Visible then
            Library:Animate(HUDScale, { Scale = 0.985; }, Duration, nil, 'HUDExit');
            Library:TweenUnifiedFade(Outer, 0, Duration, function(State)
                if CurrentId == HUD.AnimationId and not HUD.Visible and State ~= Enum.PlaybackState.Cancelled and Outer.Parent then
                    Outer.Visible = false;
                end
            end, 'HUDExit');
        end
    end

    function HUD:Destroy()
        HUD.AnimationId = HUD.AnimationId + 1;
        HUD.Visible = false;
        if Outer then Outer:Destroy(); end
        if Library.TargetHUD == HUD then
            Library.TargetHUD = nil;
            Library.TargetHUDFrame = nil;
        end
    end

    local RefreshAccumulator = 0;
    local AutoTargetAccumulator = 0;
    Library:GiveSignal(RenderStepped:Connect(function(Delta)
        if not Outer.Parent then return; end

        if HUD.Target and Outer.Visible then
            RefreshAccumulator = RefreshAccumulator + Delta;
            if RefreshAccumulator >= 0.15 then
                RefreshAccumulator = 0;
                HUD:Refresh();
            end
        end

        if HUD.AutoTargetMode ~= 'Off' then
            AutoTargetAccumulator = AutoTargetAccumulator + Delta;
            if AutoTargetAccumulator >= 0.05 then
                AutoTargetAccumulator = 0;
                local Candidate = ResolveAutoTarget();
                if Candidate ~= HUD.AutoTargetCandidate then
                    HUD.AutoTargetCandidate = Candidate;
                    if Candidate then
                        HUD:SetTarget(Candidate);
                    end
                end

                if Candidate then
                    HUD:SetVisible(true);
                else
                    HUD:SetVisible(false);
                end
            end
        end
    end));

    HUD.Frame = Outer;
    HUD.Inner = Inner;
    HUD.ContentFrame = ContentFrame;
    HUD.ContentOutline = ContentOutline;
    HUD.AvatarOutline = AvatarOutline;
    HUD.HealthOutline = HealthOutline;
    HUD.Avatar = Avatar;
    HUD.UsernameLabel = Username;
    HUD.MeterLabel = MeterLabel;
    HUD.LabelsContainer = LabelsContainer;
    HUD.HealthTitleLabel = HealthTitleLabel;
    HUD.HealthValueLabel = HealthValueLabel;
    HUD.HealthBar = HealthOuter;
    HUD.HealthFill = HealthFill;
    HUD.HealthGradient = HealthGradient;
    HUD.HealthText = HealthValueLabel;
    HUD.InfoLabel = nil;
    Library.TargetHUD = HUD;
    Library.TargetHUDFrame = Outer;
    Library:MakeDraggable(Outer, 28);

    if type(Config.Labels) == 'table' then
        if #Config.Labels > 0 then
            for _, Entry in ipairs(Config.Labels) do
                if type(Entry) == 'table' then
                    HUD:AddLabel(Entry[1] or Entry.Name or Entry.Label or '', Entry[2] or Entry.Value, Entry.Id);
                else
                    HUD:AddLabel('', Entry);
                end
            end
        else
            local Keys = {};
            for Key in next, Config.Labels do table.insert(Keys, Key); end
            table.sort(Keys, function(A, B) return tostring(A) < tostring(B); end);
            for _, Key in ipairs(Keys) do HUD:AddLabel(Key, Config.Labels[Key]); end
        end
    end

    UpdateHealthVisual();
    UpdateLayout();
    if Config.Target then HUD:SetTarget(Config.Target, Config.Info); end
    if Config.Visible and HUD.AutoTargetMode == 'Off' then HUD:SetVisible(true); end
    return HUD;
end;

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

    YSize = YSize + 7

    local NotifyOuter = Library:Create('CanvasGroup', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        GroupTransparency = 1;
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

    Library:Animate(NotifyOuter, {
        Size = UDim2.new(0, XSize + 12, 0, YSize);
        GroupTransparency = 0;
    }, 0.16, nil, 'Notification');

    task.delay(Time or 5, function()
        if not NotifyOuter.Parent then return; end
        Library:Animate(NotifyOuter, {
            Size = UDim2.new(0, 0, 0, YSize);
            GroupTransparency = 1;
        }, 0.13, function(State)
            if State ~= Enum.PlaybackState.Cancelled and NotifyOuter.Parent then NotifyOuter:Destroy(); end
        end, 'NotificationExit');
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
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.18 end

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = {
        Tabs = {};
    };

    local Outer = Library:Create('CanvasGroup', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = Config.Size,
        GroupTransparency = 1;
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    local MenuScale = Library:Create('UIScale', {
        Scale = 0.985;
        Parent = Outer;
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

    Library:AddAccentGlow(Inner, 1);
    Library:AddAccentOutline(Inner, 1);

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

        local TabFrame = Library:Create('CanvasGroup', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            GroupTransparency = 1;
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

        function Tab:ShowTab()
            if Tab.Active then
                MainTabIndicator:MoveTo(TabButton, false);
                return;
            end;

            local PreviousTab = Window.ActiveTab;
            local Direction = 1;
            if PreviousTab and PreviousTab.Button then
                Direction = TabButton.AbsolutePosition.X >= PreviousTab.Button.AbsolutePosition.X and 1 or -1;
            end;

            for _, OtherTab in next, Window.Tabs do
                if OtherTab ~= Tab and OtherTab.Active then
                    OtherTab:HideTab(OtherTab ~= PreviousTab, -Direction);
                end;
            end;

            Tab.Active = true;
            Window.ActiveTab = Tab;
            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.10);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.10);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            MainTabIndicator:MoveTo(TabButton, not MainTabIndicator.Frame.Visible);

            if not TabFrame.Visible then
                Library:CancelMotion(TabFrame);
                TabFrame.Position = UDim2.new(0, Direction * 9, 0, 0);
                TabFrame.GroupTransparency = 1;
            end;
            TabFrame.Visible = true;
            Library:Animate(TabFrame, {
                Position = UDim2.new(0, 0, 0, 0);
            }, 0.17, nil, 'Tab');
            Library:Animate(TabFrame, {
                GroupTransparency = 0;
            }, 0.15, nil, 'Fade');
        end;

        function Tab:HideTab(Instant, Direction)
            if not Tab.Active and not TabFrame.Visible then
                return;
            end;

            Tab.Active = false;
            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
            local CurrentAnimation = Tab.ContentAnimationId;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.09);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.09);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';

            if Instant then
                Library:CancelMotion(TabFrame);
                TabFrame.GroupTransparency = 1;
                TabFrame.Visible = false;
                TabFrame.Position = UDim2.new(0, 0, 0, 0);
                return;
            end;

            local ExitDirection = tonumber(Direction) or 0;
            Library:Animate(TabFrame, {
                Position = UDim2.new(0, ExitDirection * 6, 0, -2);
            }, 0.135, nil, 'TabExit');
            local ExitTween = Library:Animate(TabFrame, {
                GroupTransparency = 1;
            }, 0.12, function(State)
                if State == Enum.PlaybackState.Cancelled then return; end
                if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                    TabFrame.Visible = false;
                    TabFrame.Position = UDim2.new(0, 0, 0, 0);
                end;
            end, 'Fade');

            if not ExitTween and not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                TabFrame.Visible = false;
                TabFrame.Position = UDim2.new(0, 0, 0, 0);
            end;
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

                local Container = Library:Create('CanvasGroup', {
                    BackgroundTransparency = 1;
                    GroupTransparency = 1;
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

                    local PreviousTab;
                    for _, ExistingTab in next, Tabbox.Tabs do
                        if ExistingTab.Active then
                            PreviousTab = ExistingTab;
                            break;
                        end;
                    end;
                    local Direction = 1;
                    if PreviousTab and PreviousTab.Button then
                        Direction = Button.AbsolutePosition.X >= PreviousTab.Button.AbsolutePosition.X and 1 or -1;
                    end;

                    for _, OtherTab in next, Tabbox.Tabs do
                        if OtherTab ~= Tab and OtherTab.Active then
                            OtherTab:Hide(OtherTab ~= PreviousTab, -Direction);
                        end;
                    end;

                    Tab.Active = true;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    if not Container.Visible then
                        Library:CancelMotion(Container);
                        Container.Position = UDim2.new(0, 4 + (Direction * 8), 0, 20);
                        Container.GroupTransparency = 1;
                    end;
                    Container.Visible = true;
                    Block.Visible = true;
                    TabboxIndicator:MoveTo(Button, not TabboxIndicator.Frame.Visible);

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.10);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.10);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
                    Library:Animate(Container, {
                        Position = UDim2.new(0, 4, 0, 20);
                    }, 0.16, nil, 'Tab');
                    Library:Animate(Container, {
                        GroupTransparency = 0;
                    }, 0.14, nil, 'Fade');

                    Tab:Resize();
                end;

                function Tab:Hide(Instant, Direction)
                    if not Tab.Active and not Container.Visible then
                        return;
                    end;

                    Tab.Active = false;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    local CurrentAnimation = Tab.ContentAnimationId;

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.10);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.09);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';

                    if Instant then
                        Library:CancelMotion(Container);
                        Container.GroupTransparency = 1;
                        Container.Visible = false;
                        Container.Position = UDim2.new(0, 4, 0, 20);
                        Block.Visible = false;
                        return;
                    end;

                    local ExitDirection = tonumber(Direction) or 0;
                    Library:Animate(Container, {
                        Position = UDim2.new(0, 4 + (ExitDirection * 5), 0, 18);
                    }, 0.125, nil, 'TabExit');
                    local ExitTween = Library:Animate(Container, {
                        GroupTransparency = 1;
                    }, 0.11, function(State)
                        if State == Enum.PlaybackState.Cancelled then return; end
                        if not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                            Container.Visible = false;
                            Container.Position = UDim2.new(0, 4, 0, 20);
                            Block.Visible = false;
                        end;
                    end, 'Fade');

                    if not ExitTween and not Tab.Active and CurrentAnimation == Tab.ContentAnimationId then
                        Container.Visible = false;
                        Container.Position = UDim2.new(0, 4, 0, 20);
                        Block.Visible = false;
                    end;
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

    local Toggled = false;
    local ToggleAnimationId = 0;
    local CursorAnimationId = 0;

    local function StartFormaCursor()
        CursorAnimationId = CursorAnimationId + 1;
        local CurrentCursorId = CursorAnimationId;
        task.spawn(function()
            local State = InputService.MouseIconEnabled;
            local CursorAssetPath = 'FormaAssets/cursor.png';
            local CursorAssetUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/cursor.png';
            local GetCustomAsset = getcustomasset or getsynasset;
            local Cursor;

            if GetCustomAsset and writefile and isfile then
                pcall(function()
                    if isfolder and makefolder and not isfolder('FormaAssets') then makefolder('FormaAssets'); end
                    if not isfile(CursorAssetPath) then writefile(CursorAssetPath, game:HttpGet(CursorAssetUrl)); end
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
                    Library:AddToRegistry(Cursor, { ImageColor3 = 'AccentColor'; });
                end);
            end

            if Cursor then
                while Toggled and CurrentCursorId == CursorAnimationId and ScreenGui.Parent do
                    InputService.MouseIconEnabled = false;
                    Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
                    RenderStepped:Wait();
                end
                Cursor:Destroy();
            end
            if CurrentCursorId == CursorAnimationId then
                InputService.MouseIconEnabled = State;
            end
        end);
    end

    function Library:Toggle()
        Toggled = not Toggled;
        ToggleAnimationId = ToggleAnimationId + 1;
        local CurrentId = ToggleAnimationId;
        ModalElement.Modal = Toggled;

        local FadeTime = Config.MenuFadeTime;

        if Toggled then
            if not Outer.Visible then
                Library:SetUnifiedFadeProgress(Outer, 0);
                MenuScale.Scale = 0.985;
                Outer.Visible = true;
            end

            Library:Animate(MenuScale, { Scale = 1; }, FadeTime, nil, 'Menu');
            Library:TweenUnifiedFade(Outer, 1, FadeTime, nil, 'Menu');
            StartFormaCursor();
        else
            CursorAnimationId = CursorAnimationId + 1;
            Library:Animate(MenuScale, { Scale = 0.985; }, FadeTime, nil, 'MenuExit');
            Library:TweenUnifiedFade(Outer, 0, FadeTime, function(State)
                if CurrentId ~= ToggleAnimationId or Toggled or State == Enum.PlaybackState.Cancelled then
                    return;
                end
                Outer.Visible = false;
            end, 'MenuExit');
        end
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                Library.Toggle()
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            Library.Toggle()
        end
    end))

    if Config.AutoShow then Library.Toggle() end

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
