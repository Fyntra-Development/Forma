local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local HttpService = game:GetService('HttpService');
local MarketplaceService = game:GetService('MarketplaceService');
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
    BlendShade = Color3.fromRGB(7, 21, 47);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    DisabledTextColor = Color3.fromRGB(143, 143, 143);
    Contrast = Color3.fromRGB(36, 36, 36);
    Inline = Color3.fromRGB(12, 12, 12);
    RiskColor = Color3.fromRGB(255, 50, 50),

    -- Black remains as a compatibility alias for existing controls. The theme
    -- manager keeps it synchronized with Inline so older registry entries also
    -- respond to the new theme field.
    Black = Color3.fromRGB(12, 12, 12);
    Font = Enum.Font.Code,
    FontName = 'Code',
    TextScale = 1;
    TextSize = 14;

    OpenedFrames = {};
    DependencyBoxes = {};

    Signals = {};
    ScreenGui = ScreenGui;
};

local function NormalizeGameName(Value)
    if Value == nil then return nil; end;
    local Name = tostring(Value):gsub('^%s+', ''):gsub('%s+$', '');
    local Normalized = Name:lower():gsub('[%s%p_]+', '');
    if Name == '' or Normalized == 'ugc' or Normalized == 'game'
        or Normalized == 'place' or Normalized == 'unknowngame' then
        return nil;
    end;
    return Name;
end;

function Library:DetectGameName()
    local Candidates = {};
    local UniverseId = tonumber(game.GameId) or 0;
    if UniverseId > 0 then
        local Success, Result = pcall(function()
            local Url = 'https://games.roblox.com/v1/games?universeIds=' .. tostring(UniverseId);
            local Response = game:HttpGet(Url);
            local Decoded = HttpService:JSONDecode(Response);
            return Decoded and Decoded.data and Decoded.data[1] and Decoded.data[1].name;
        end);
        if Success then table.insert(Candidates, Result); end;
    end;

    local PlaceId = tonumber(game.PlaceId) or 0;
    if PlaceId > 0 then
        local Success, Result = pcall(function()
            local Info = MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset);
            return Info and Info.Name;
        end);
        if Success then table.insert(Candidates, Result); end;
    end;

    table.insert(Candidates, game.Name);
    for _, Candidate in ipairs(Candidates) do
        local Name = NormalizeGameName(Candidate);
        if Name then
            Library.GameName = Name;
            return Name;
        end;
    end;

    Library.GameName = 'Unknown Game';
    return Library.GameName;
end;

Library.GameName = Library:DetectGameName();

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
Library.ResizeHitboxes = setmetatable({}, { __mode = 'k' });
Library.ScrollRevealStates = setmetatable({}, { __mode = 'k' });
Library.TypingControllers = setmetatable({}, { __mode = 'k' });

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
    return Library:TweenUnifiedFade(Root, Hidden and 0 or 1, Duration, nil, 'Fade');
end;

Library.UnifiedFadeControllers = setmetatable({}, { __mode = 'k' });
Library.FadeContributions = setmetatable({}, { __mode = 'k' });

local function ApplyCompositeFade(Instance, Baseline)
    local Contributions = Library.FadeContributions[Instance];
    local Composite = 1;
    if Contributions then
        for Controller, Progress in next, Contributions do
            if Controller.Driver and Controller.Driver.Parent then
                Composite = Composite * Progress;
            else
                Contributions[Controller] = nil;
            end;
        end;
    end;

    for Property, Value in next, Baseline do
        pcall(function()
            Instance[Property] = 1 + ((Value - 1) * Composite);
        end);
    end;
end

local function ApplyUnifiedFadeProgress(Controller, Progress)
    Progress = math.clamp(tonumber(Progress) or 0, 0, 1);
    Controller.Progress = Progress;

    for _, Entry in ipairs(Controller.Entries) do
        local Instance = Entry.Instance;
        if Instance and Instance.Parent then
            local Contributions = Library.FadeContributions[Instance];
            if not Contributions then
                Contributions = setmetatable({}, { __mode = 'k' });
                Library.FadeContributions[Instance] = Contributions;
            end;
            Contributions[Controller] = Progress;
            ApplyCompositeFade(Instance, Entry.Baseline);
        end
    end
end

local function GetUnifiedFadeController(Root)
    local Controller = Library.UnifiedFadeControllers[Root];
    if Controller then
        return Controller;
    end

    local InitialProgress = Root:IsA('CanvasGroup')
        and (1 - math.clamp(Root.GroupTransparency, 0, 1))
        or 1;
    local Driver = Instance.new('NumberValue');
    Driver.Name = 'FormaUnifiedFadeDriver';
    Driver.Value = InitialProgress;
    Driver.Parent = Root;

    Controller = {
        Driver = Driver;
        Progress = InitialProgress;
        Entries = {};
        EntryMap = {};
        Tween = nil;
    };
    Library.UnifiedFadeControllers[Root] = Controller;

    Driver:GetPropertyChangedSignal('Value'):Connect(function()
        ApplyUnifiedFadeProgress(Controller, Driver.Value);
    end);

    return Controller;
end

local function RefreshUnifiedFadeEntries(Root, Controller)
    Library:PrimeFadeTree(Root);

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        if Descendant ~= Controller.Driver then
            table.insert(Instances, Descendant);
        end
    end

    local Entries = {};
    local EntryMap = {};
    for _, Instance in ipairs(Instances) do
        local Baseline = Library.FadeBaselines[Instance];
        if Baseline then
            local VisibleBaseline = {};
            for Property, Value in next, Baseline do
                if type(Value) == 'number' and Value < 0.9999 then
                    VisibleBaseline[Property] = Value;
                end;
            end;

            if next(VisibleBaseline) then
                local Entry = {
                    Instance = Instance;
                    Baseline = VisibleBaseline;
                };
                table.insert(Entries, Entry);
                EntryMap[Instance] = Entry;
            end;
        end
    end

    for Instance, Entry in next, Controller.EntryMap do
        if not EntryMap[Instance] then
            local Contributions = Library.FadeContributions[Instance];
            if Contributions then Contributions[Controller] = nil; end
            if Instance and Instance.Parent then
                ApplyCompositeFade(Instance, Entry.Baseline);
            end;
        end;
    end;

    Controller.Entries = Entries;
    Controller.EntryMap = EntryMap;
    Controller.EntriesInitialized = true;
end

function Library:SetUnifiedFadeProgress(Root, Progress)
    if not Root then
        return;
    end

    local Value = math.clamp(tonumber(Progress) or 0, 0, 1);
    local Controller = GetUnifiedFadeController(Root);
    if Root:IsA('CanvasGroup') then
        Library:CancelMotion(Root, 'GroupTransparency');
        Root.GroupTransparency = 0;
    end

    if Controller.Tween then
        local PreviousTween = Controller.Tween;
        Controller.Tween = nil;
        pcall(function() PreviousTween:Cancel(); end);
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    ApplyUnifiedFadeProgress(Controller, Value);
    Controller.Driver.Value = Controller.Progress;
end

function Library:SetCachedUnifiedFadeProgress(Root, Progress)
    if not Root then
        return;
    end

    local Value = math.clamp(tonumber(Progress) or 0, 0, 1);
    local Controller = GetUnifiedFadeController(Root);
    if not Controller.EntriesInitialized then
        Library:SetUnifiedFadeProgress(Root, Value);
        return;
    end

    if Controller.Tween then
        local PreviousTween = Controller.Tween;
        Controller.Tween = nil;
        pcall(function() PreviousTween:Cancel(); end);
    end

    if Controller.Driver.Value ~= Value then
        Controller.Driver.Value = Value;
    end
end

function Library:TweenUnifiedFade(Root, Target, Duration, Completed, Context)
    if not Root then
        return nil;
    end

    local TargetProgress = math.clamp(tonumber(Target) or 0, 0, 1);
    local Controller = GetUnifiedFadeController(Root);
    if Root:IsA('CanvasGroup') then
        Library:CancelMotion(Root, 'GroupTransparency');
        Root.GroupTransparency = 0;
    end

    if Controller.Tween then
        local PreviousTween = Controller.Tween;
        Controller.Tween = nil;
        pcall(function() PreviousTween:Cancel(); end);
    end

    RefreshUnifiedFadeEntries(Root, Controller);
    ApplyUnifiedFadeProgress(Controller, Controller.Progress);
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

function Library:BindScrollReveal(ScrollingFrame, Config)
    if not ScrollingFrame or not ScrollingFrame:IsA('ScrollingFrame') then
        return nil;
    end

    Config = Config or {};
    local Existing = Library.ScrollRevealStates[ScrollingFrame];
    if Existing then return Existing; end

    local State = {
        ScrollingFrame = ScrollingFrame;
        VisibilityRoot = Config.VisibilityRoot;
        Filter = Config.Filter;
        TargetResolver = Config.TargetResolver;
        EdgeFade = math.max(tonumber(Config.EdgeFade) or 0, 0);
        Shown = setmetatable({}, { __mode = 'k' });
        Tracked = setmetatable({}, { __mode = 'k' });
        Queued = false;
    };
    Library.ScrollRevealStates[ScrollingFrame] = State;

    local function IsAvailable()
        local Root = State.VisibilityRoot;
        return ScrollingFrame.Parent ~= nil and (not Root or Root.Visible);
    end

    function State:Refresh()
        self.Queued = false;
        if not IsAvailable() then return; end

        local ViewTop = ScrollingFrame.AbsolutePosition.Y + 2;
        local ViewBottom = ScrollingFrame.AbsolutePosition.Y + ScrollingFrame.AbsoluteSize.Y - 2;

        for _, Child in ipairs(ScrollingFrame:GetChildren()) do
            local IsGui = Child:IsA('GuiObject');
            local Allowed = IsGui and (not self.Filter or self.Filter(Child));
            if Allowed then
                local Target = self.TargetResolver and self.TargetResolver(Child) or Child;
                if Target and Target.Parent then
                    local Height = Child.AbsoluteSize.Y;
                    local Top = Child.AbsolutePosition.Y;
                    local Bottom = Top + Height;
                    local Visible = Height > 1 and Bottom > ViewTop and Top < ViewBottom;
                    local FadeProgress = 1;
                    if Visible and self.EdgeFade > 0 then
                        local TopProgress = math.clamp((Bottom - ViewTop) / self.EdgeFade, 0, 1);
                        local BottomProgress = math.clamp((ViewBottom - Top) / self.EdgeFade, 0, 1);
                        FadeProgress = math.min(TopProgress, BottomProgress);
                    end;
                    local Previous = self.Shown[Target];

                    if Previous == nil then
                        self.Shown[Target] = Visible;
                        Library:SetUnifiedFadeProgress(Target, 0);
                        if Visible then
                            Library:TweenUnifiedFade(Target, FadeProgress, 0.22, nil, 'ScrollReveal');
                        end
                    elseif Previous ~= Visible then
                        self.Shown[Target] = Visible;
                        Library:TweenUnifiedFade(
                            Target,
                            Visible and FadeProgress or 0,
                            Visible and 0.22 or 0.13,
                            nil,
                            'ScrollReveal'
                        );
                    elseif Visible and self.EdgeFade > 0 then
                        -- Scroll positions can update every rendered frame. Apply the
                        -- clipped-edge fade directly so rows follow both viewport
                        -- boundaries without queuing a tween for every scroll step.
                        Library:SetCachedUnifiedFadeProgress(Target, FadeProgress);
                    end
                end
            end
        end
    end

    function State:QueueRefresh()
        if self.Queued then return; end
        self.Queued = true;
        task.defer(function()
            if ScrollingFrame.Parent then self:Refresh(); end
        end);
    end

    function State:TrackChild(Child)
        if not Child:IsA('GuiObject') or self.Tracked[Child] then return; end
        self.Tracked[Child] = true;

        -- Layout changes (dependency boxes, searchable rows, and window
        -- resizing) can move content without changing CanvasPosition. Follow
        -- the rendered geometry so reveal fades start at the actual viewport
        -- edge instead of waiting for the next scroll input.
        Library:GiveSignal(Child:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            self:QueueRefresh();
        end));
        Library:GiveSignal(Child:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            self:QueueRefresh();
        end));
        Library:GiveSignal(Child:GetPropertyChangedSignal('Visible'):Connect(function()
            self:QueueRefresh();
        end));
    end

    Library:GiveSignal(ScrollingFrame:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
        State:QueueRefresh();
    end));
    Library:GiveSignal(ScrollingFrame:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        State:QueueRefresh();
    end));
    Library:GiveSignal(ScrollingFrame.ChildAdded:Connect(function(Child)
        State:TrackChild(Child);
        State:QueueRefresh();
    end));
    Library:GiveSignal(ScrollingFrame.ChildRemoved:Connect(function()
        State:QueueRefresh();
    end));

    if State.VisibilityRoot then
        Library:GiveSignal(State.VisibilityRoot:GetPropertyChangedSignal('Visible'):Connect(function()
            State:QueueRefresh();
        end));
    end


    for _, Child in ipairs(ScrollingFrame:GetChildren()) do
        State:TrackChild(Child);
    end

    State:QueueRefresh();
    return State;
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
    task.defer(function()
        for _, Controller in next, Library.TypingControllers do
            if Controller.Refresh then Controller.Refresh(); end
        end
        if Library.UpdateWatermarkText and Library.WatermarkText then
            Library.UpdateWatermarkText(Library.WatermarkText.Text);
        end
    end);
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

    task.defer(function()
        for _, Controller in next, Library.TypingControllers do
            if Controller.Refresh then Controller.Refresh(); end
        end
        if Library.UpdateWatermarkText and Library.WatermarkText then
            Library.UpdateWatermarkText(Library.WatermarkText.Text);
        end
    end);

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

    Library:SetUnifiedFadeProgress(Root, Hidden and 0 or 1);
end;

function Library:TweenFadeTree(Root, Hidden, Duration)
    if not Root then
        return;
    end;

    return Library:TweenUnifiedFade(Root, Hidden and 0 or 1, Duration or 0.14, nil, 'Fade');
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

function Library:GetMovingAccentGradientColor()
    local Accent = Library.AccentColor;
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Accent));
        ColorSequenceKeypoint.new(0.34, Accent);
        ColorSequenceKeypoint.new(0.5, Accent:Lerp(Color3.new(1, 1, 1), 0.38));
        ColorSequenceKeypoint.new(0.66, Accent);
        ColorSequenceKeypoint.new(1, Library:GetDarkerColor(Accent));
    });
end;

function Library:GetBlendShadeTransparency(Strength)
    Strength = math.clamp(tonumber(Strength) or 0.48, 0, 0.82);
    return NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1 - Strength);
        NumberSequenceKeypoint.new(0.58, 0.88);
        NumberSequenceKeypoint.new(1, 1);
    });
end;

function Library:GetNeutralBlendShade()
    local Shade = Library.BlendShade or Color3.fromRGB(24, 24, 24);
    local Luminance = (Shade.R * 0.2126) + (Shade.G * 0.7152) + (Shade.B * 0.0722);
    return Color3.new(Luminance, Luminance, Luminance);
end;

function Library:AddMovingAccentGradient(Parent, Duration)
    if not Parent then return nil; end;

    local Existing = Parent:FindFirstChild('FormaMovingAccentGradient');
    if Existing and Existing:IsA('UIGradient') then return Existing; end;

    local Gradient = Library:Create('UIGradient', {
        Name = 'FormaMovingAccentGradient';
        Color = Library:GetMovingAccentGradientColor();
        Offset = Vector2.new(-1, 0);
        Rotation = 0;
        Parent = Parent;
    });
    Library:AddToRegistry(Gradient, {
        Color = function()
            return Library:GetMovingAccentGradientColor();
        end;
    });

    TweenService:Create(
        Gradient,
        TweenInfo.new(tonumber(Duration) or 2.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1, 0); }
    ):Play();
    return Gradient;
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
    Library:AddMovingAccentGradient(Stroke, 2.4);
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
    local Controller = {
        ActiveButton = nil;
        TargetPosition = nil;
        TargetSize = nil;
        FollowConnection = nil;
    };

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

    local function ResolveTarget(Button)
        if not Button or not Button.Parent or Button.AbsoluteSize.X <= 0 then
            return nil, nil;
        end;

        return UDim2.fromOffset(
            Button.AbsolutePosition.X - Layer.AbsolutePosition.X,
            Button.AbsolutePosition.Y - Layer.AbsolutePosition.Y
        ), UDim2.fromOffset(Button.AbsoluteSize.X, Height or 21);
    end;

    local function GeometryChanged(Current, Target)
        return not Current
            or math.abs(Current.X.Offset - Target.X.Offset) > 0.01
            or math.abs(Current.Y.Offset - Target.Y.Offset) > 0.01;
    end;

    Controller.FollowConnection = RenderStepped:Connect(function()
        if not Layer.Parent then
            Controller.FollowConnection:Disconnect();
            Controller.FollowConnection = nil;
            return;
        end;

        local Button = Controller.ActiveButton;
        local TargetPosition, TargetSize = ResolveTarget(Button);
        if not TargetPosition then return; end;

        if GeometryChanged(Controller.TargetPosition, TargetPosition)
            or GeometryChanged(Controller.TargetSize, TargetSize) then
            Controller.TargetPosition = TargetPosition;
            Controller.TargetSize = TargetSize;
            Library:CancelMotion(Indicator);
            Indicator.Position = TargetPosition;
            Indicator.Size = TargetSize;
        end;
    end);
    Library:GiveSignal(Controller.FollowConnection);

    function Controller:MoveTo(Button, Instant)
        local TargetPosition, TargetSize = ResolveTarget(Button);
        if not TargetPosition then return; end;

        local NewLeft = TargetPosition.X.Offset;
        local WasVisible = Indicator.Visible;
        self.ActiveButton = Button;
        self.TargetPosition = TargetPosition;
        self.TargetSize = TargetSize;

        if Instant or not Indicator.Visible or Indicator.AbsoluteSize.X <= 0 then
            Library:CancelMotion(Indicator);
            Indicator.Position = TargetPosition;
            Indicator.Size = TargetSize;
            Indicator.Visible = true;
            if not WasVisible then
                Stroke.Transparency = 1;
                Library:Animate(Stroke, { Transparency = 0; }, 0.18, nil, 'Fade');
            end;
            return;
        end;

        Indicator.Visible = true;
        local Travel = math.abs(NewLeft - Indicator.Position.X.Offset)
            + (math.abs(TargetSize.X.Offset - Indicator.Size.X.Offset) * 0.35);
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

function Library:IsPointOverResizeHandle(Point)
    for Hitbox, Owner in next, Library.ResizeHitboxes do
        if Hitbox and Hitbox.Parent and Hitbox.Visible and Owner and Owner.Visible then
            local Position = Hitbox.AbsolutePosition;
            local Size = Hitbox.AbsoluteSize;
            if Point.X >= Position.X and Point.X <= Position.X + Size.X
                and Point.Y >= Position.Y and Point.Y <= Position.Y + Size.Y then
                return true;
            end
        end
    end
    return false;
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
        DragConnection = nil;
        InputConnection = nil;
        Input = nil;
        ObjectOffset = nil;
        Anchor = nil;
        VisualAnchor = nil;
        TargetAnchor = nil;
        DragResponse = 120;
        MaxDragLag = 2.5;
    };
    Library.DraggableStates[Instance] = State;

    local function Disconnect(ConnectionName)
        local Connection = State[ConnectionName];
        if Connection then
            Connection:Disconnect();
            State[ConnectionName] = nil;
        end
    end;

    local function GetPointer(Input)
        if Input and Input.UserInputType == Enum.UserInputType.Touch then
            return Vector2.new(Input.Position.X, Input.Position.Y);
        end
        return Vector2.new(Mouse.X, Mouse.Y);
    end

    local function FinishDrag()
        if not State.Dragging then return; end

        -- Resolve the exact final pointer location before disconnecting. The
        -- live filter is intentionally limited to a couple of pixels, and the
        -- release always lands exactly under the pointer without a settle tween.
        if State.Input and State.ObjectOffset and State.Anchor then
            local Pointer = GetPointer(State.Input);
            State.TargetAnchor = Vector2.new(
                Pointer.X - State.ObjectOffset.X + (Instance.AbsoluteSize.X * State.Anchor.X),
                Pointer.Y - State.ObjectOffset.Y + (Instance.AbsoluteSize.Y * State.Anchor.Y)
            );
            if Instance.Parent then
                Instance.Position = UDim2.fromOffset(State.TargetAnchor.X, State.TargetAnchor.Y);
            end;
        end

        State.Dragging = false;
        Disconnect('DragConnection');
        Disconnect('InputConnection');
        State.Input = nil;
        State.ObjectOffset = nil;
        State.Anchor = nil;

    end

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return;
        end

        local Pointer = GetPointer(Input);
        if Library:IsPointOverResizeHandle(Pointer) then
            return;
        end
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
        State.DragResponse = 120;
        local Manager = Library.MenuManager;
        if Manager and Manager.GetDragResponse then
            local Success, Response = pcall(Manager.GetDragResponse, Manager);
            if Success and type(Response) == 'number' then
                State.DragResponse = math.clamp(Response, 90, 180);
            end;
        end;

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

            -- A very fast exponential micro-filter removes pointer stair-steps,
            -- while the maximum error clamp prevents the floaty lag produced by
            -- the previous unrestricted smoothing pass.
            local SafeDelta = math.min(tonumber(Delta) or (1 / 60), 1 / 20);
            local FollowAlpha = 1 - math.exp(-(State.DragResponse or 120) * SafeDelta);
            State.VisualAnchor = State.VisualAnchor:Lerp(State.TargetAnchor, FollowAlpha);
            local Remaining = State.TargetAnchor - State.VisualAnchor;
            local MaxLag = State.MaxDragLag or 2.5;
            if Remaining.Magnitude > MaxLag then
                State.VisualAnchor = State.TargetAnchor - Remaining.Unit * MaxLag;
            end;
            Instance.Position = UDim2.fromOffset(State.VisualAnchor.X, State.VisualAnchor.Y);
        end);

        State.InputConnection = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then FinishDrag(); end
        end);
    end);

    return State;
end;

function Library:MakeResizable(Instance, Config)
    if not Instance then return nil; end
    Config = Config or {};

    local function ResolveVector(Value, Fallback)
        if typeof(Value) == 'Vector2' then return Value; end
        if typeof(Value) == 'UDim2' then return Vector2.new(Value.X.Offset, Value.Y.Offset); end
        return Fallback;
    end

    local MinSize = ResolveVector(Config.MinSize, Vector2.new(420, 320));
    local MaxSize = ResolveVector(Config.MaxSize, Vector2.new(math.huge, math.huge));
    local Response = math.clamp(tonumber(Config.Response) or 30, 18, 60);
    local State = {
        InitialSize = Instance.Size;
        Resizing = false;
        ActiveHandle = nil;
        RenderConnection = nil;
        InputConnection = nil;
        Handles = {};
    };

    local function GetPointer(Input)
        if Input and Input.UserInputType == Enum.UserInputType.Touch then
            return Vector2.new(Input.Position.X, Input.Position.Y);
        end
        return Vector2.new(Mouse.X, Mouse.Y);
    end

    local function Disconnect(Name)
        if State[Name] then
            State[Name]:Disconnect();
            State[Name] = nil;
        end
    end

    local function SetHandleVisible(Handle, Visible)
        if not Handle or not Handle.Visual then return; end
        Library:Animate(
            Handle.Visual,
            { BackgroundTransparency = Visible and 0.06 or 1 },
            Visible and 0.15 or 0.20,
            nil,
            'Fade'
        );
    end

    local function CalculateTarget(Handle, Pointer)
        Pointer = Pointer - (State.PointerOffset or Vector2.zero);
        local Left = State.StartPosition.X;
        local Top = State.StartPosition.Y;
        local Right = Left + State.StartSize.X;
        local Bottom = Top + State.StartSize.Y;
        local Camera = workspace.CurrentCamera;
        local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080);
        local Maximum = Vector2.new(
            math.min(MaxSize.X, math.max(Viewport.X - 16, MinSize.X)),
            math.min(MaxSize.Y, math.max(Viewport.Y - 16, MinSize.Y))
        );

        if Handle.Horizontal < 0 then
            Left = math.clamp(Pointer.X, Right - Maximum.X, Right - MinSize.X);
        else
            Right = math.clamp(Pointer.X, Left + MinSize.X, Left + Maximum.X);
        end

        if Handle.Vertical < 0 then
            Top = math.clamp(Pointer.Y, Bottom - Maximum.Y, Bottom - MinSize.Y);
        else
            Bottom = math.clamp(Pointer.Y, Top + MinSize.Y, Top + Maximum.Y);
        end

        local Size = Vector2.new(Right - Left, Bottom - Top);
        local Anchor = Instance.AnchorPoint;
        local Position = Vector2.new(Left + (Size.X * Anchor.X), Top + (Size.Y * Anchor.Y));
        State.TargetSize = Size;
        State.TargetPosition = Position;
    end

    local function FinishResize()
        if not State.Resizing then return; end
        local Handle = State.ActiveHandle;
        if State.Input then CalculateTarget(Handle, GetPointer(State.Input)); end

        State.Resizing = false;
        State.ActiveHandle = nil;
        State.Input = nil;
        State.PointerOffset = nil;
        Disconnect('RenderConnection');
        Disconnect('InputConnection');
        SetHandleVisible(Handle, Handle and Handle.Hovering);

        if not Instance.Parent or not State.TargetPosition or not State.TargetSize then return; end
        Library:Animate(Instance, {
            Position = UDim2.fromOffset(State.TargetPosition.X, State.TargetPosition.Y);
            Size = UDim2.fromOffset(State.TargetSize.X, State.TargetSize.Y);
        }, 0.13, nil, 'Resize');
    end

    local Corners = {
        { Name = 'TopLeft'; Anchor = Vector2.new(0, 0); Position = UDim2.fromScale(0, 0); Horizontal = -1; Vertical = -1; };
        { Name = 'TopRight'; Anchor = Vector2.new(1, 0); Position = UDim2.fromScale(1, 0); Horizontal = 1; Vertical = -1; };
        { Name = 'BottomLeft'; Anchor = Vector2.new(0, 1); Position = UDim2.fromScale(0, 1); Horizontal = -1; Vertical = 1; };
        { Name = 'BottomRight'; Anchor = Vector2.new(1, 1); Position = UDim2.fromScale(1, 1); Horizontal = 1; Vertical = 1; };
    };

    for _, Corner in ipairs(Corners) do
        local Hitbox = Library:Create('Frame', {
            Name = 'FormaResize' .. Corner.Name;
            Active = true;
            AnchorPoint = Corner.Anchor;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = Corner.Position;
            Size = UDim2.fromOffset(14, 14);
            ZIndex = 250;
            Parent = Instance;
        });

        local Visual = Library:Create('Frame', {
            AnchorPoint = Corner.Anchor;
            BackgroundColor3 = Library.AccentColor;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = Corner.Position;
            Size = UDim2.fromOffset(6, 6);
            ZIndex = 251;
            Parent = Hitbox;
        });
        Library:AddToRegistry(Visual, { BackgroundColor3 = 'AccentColor'; });

        local Handle = {
            Hitbox = Hitbox;
            Visual = Visual;
            Horizontal = Corner.Horizontal;
            Vertical = Corner.Vertical;
            Hovering = false;
        };
        State.Handles[Corner.Name] = Handle;
        Library.ResizeHitboxes[Hitbox] = Instance;

        Hitbox.MouseEnter:Connect(function()
            Handle.Hovering = true;
            SetHandleVisible(Handle, true);
        end);
        Hitbox.MouseLeave:Connect(function()
            Handle.Hovering = false;
            if State.ActiveHandle ~= Handle then SetHandleVisible(Handle, false); end
        end);

        Hitbox.InputBegan:Connect(function(Input)
            if State.Resizing or (Input.UserInputType ~= Enum.UserInputType.MouseButton1
                and Input.UserInputType ~= Enum.UserInputType.Touch) then
                return;
            end

            Library:CancelMotion(Instance, 'Position');
            Library:CancelMotion(Instance, 'Size');
            State.Resizing = true;
            State.ActiveHandle = Handle;
            State.Input = Input;
            State.StartPosition = Instance.AbsolutePosition;
            State.StartSize = Instance.AbsoluteSize;
            local Pointer = GetPointer(Input);
            local Edge = Vector2.new(
                State.StartPosition.X + (Handle.Horizontal > 0 and State.StartSize.X or 0),
                State.StartPosition.Y + (Handle.Vertical > 0 and State.StartSize.Y or 0)
            );
            State.PointerOffset = Pointer - Edge;
            State.VisualPosition = Vector2.new(
                State.StartPosition.X + (State.StartSize.X * Instance.AnchorPoint.X),
                State.StartPosition.Y + (State.StartSize.Y * Instance.AnchorPoint.Y)
            );
            State.VisualSize = State.StartSize;
            CalculateTarget(Handle, Pointer);
            SetHandleVisible(Handle, true);

            State.RenderConnection = RenderStepped:Connect(function(Delta)
                if not State.Resizing or not Instance.Parent then
                    FinishResize();
                    return;
                end

                CalculateTarget(Handle, GetPointer(Input));
                local SafeDelta = math.min(tonumber(Delta) or (1 / 60), 1 / 20);
                local Alpha = 1 - math.exp(-Response * SafeDelta);
                State.VisualPosition = State.VisualPosition:Lerp(State.TargetPosition, Alpha);
                State.VisualSize = State.VisualSize:Lerp(State.TargetSize, Alpha);
                Instance.Position = UDim2.fromOffset(State.VisualPosition.X, State.VisualPosition.Y);
                Instance.Size = UDim2.fromOffset(State.VisualSize.X, State.VisualSize.Y);
            end);

            State.InputConnection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then FinishResize(); end
            end);
        end);
    end

    State.Finish = FinishResize;
    return State;
end;

-- Keep animated input text in one shaped label. Rendering each codepoint in a
-- separate TextLabel loses the font shaping/side bearings used by the measured
-- complete string, which can make proportional/custom-font glyphs overlap.
function Library:EnableTypingAnimation(TextBox)
    if not TextBox or not TextBox:IsA('TextBox') then
        return nil;
    end
    if TextBox:GetAttribute('FormaTypingAnimation') then
        return Library.TypingControllers[TextBox];
    end
    TextBox:SetAttribute('FormaTypingAnimation', true);

    local Parent = TextBox.Parent;
    if not Parent then return nil; end
    local BaseSize = Library.BaseTextSizes[TextBox] or 14;
    local OriginalTextTransparency = TextBox.TextTransparency;
    local OriginalStrokeTransparency = TextBox.TextStrokeTransparency;

    local function GetTextColorKey()
        return TextBox:IsFocused() and 'AccentColor' or 'FontColor';
    end;

    local function SyncTextColor()
        local ColorKey = GetTextColorKey();
        TextBox.TextColor3 = Library[ColorKey];
        local RegistryEntry = Library.RegistryMap[TextBox];
        if RegistryEntry then RegistryEntry.Properties.TextColor3 = ColorKey; end;
        return ColorKey;
    end;

    local Layer = Library:Create('Frame', {
        Name = 'FormaTypingLayer';
        Active = false;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = TextBox.Position;
        Size = TextBox.Size;
        ZIndex = TextBox.ZIndex + 1;
        Parent = Parent;
    });

    local Placeholder = Library:CreateLabel({
        Active = false;
        Position = UDim2.fromScale(0, 0);
        Size = UDim2.fromScale(1, 1);
        Text = TextBox.PlaceholderText;
        TextColor3 = Library.DisabledTextColor;
        TextSize = BaseSize;
        TextTransparency = 0.14;
        TextXAlignment = TextBox.TextXAlignment;
        TextYAlignment = TextBox.TextYAlignment;
        ZIndex = Layer.ZIndex + 1;
        Parent = Layer;
    });
    Library.RegistryMap[Placeholder].Properties.TextColor3 = 'DisabledTextColor';

    local RenderedText = Library:CreateLabel({
        Active = false;
        BackgroundTransparency = 1;
        Position = UDim2.fromScale(0, 0);
        Size = UDim2.fromScale(1, 1);
        Text = TextBox.Text or '';
        TextColor3 = Library.FontColor;
        TextSize = BaseSize;
        TextXAlignment = TextBox.TextXAlignment;
        TextYAlignment = TextBox.TextYAlignment;
        TextWrapped = false;
        ZIndex = Layer.ZIndex + 2;
        Parent = Layer;
    });

    local Indicator = Library:Create('Frame', {
        Name = 'FormaTypingIndicator';
        AnchorPoint = Vector2.new(0, 0.5);
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 0.04;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0.5, 0);
        Size = UDim2.fromOffset(1, math.max(TextBox.TextSize - 2, 7));
        ZIndex = Layer.ZIndex + 3;
        Parent = Layer;
    });
    Library:AddToRegistry(Indicator, { BackgroundColor3 = 'AccentColor'; });
    Library:SetUnifiedFadeProgress(Indicator, 0);

    local Cache = Library.FadeBaselines[TextBox] or {};
    Cache.TextTransparency = 1;
    Cache.TextStrokeTransparency = 1;
    Library.FadeBaselines[TextBox] = Cache;
    TextBox.TextTransparency = 1;
    TextBox.TextStrokeTransparency = 1;

    local function Measure(Text)
        if Text == '' then return 0; end
        local Width = Library:GetTextBounds(Text, Library.Font, BaseSize, Vector2.new(100000, 100000));
        return tonumber(Width) or 0;
    end;

    local function GetTextOrigin(TextWidth)
        local Available = math.max(TextBox.AbsoluteSize.X, 0);
        if TextBox.TextXAlignment == Enum.TextXAlignment.Center then
            return (Available - TextWidth) * 0.5;
        elseif TextBox.TextXAlignment == Enum.TextXAlignment.Right then
            return Available - TextWidth;
        end
        return 0;
    end;

    local function UpdateIndicator(Instant)
        local Cursor = TextBox.CursorPosition;
        local BeforeCursor = TextBox.Text or '';
        if Cursor and Cursor >= 1 then BeforeCursor = BeforeCursor:sub(1, Cursor - 1); end
        local X = GetTextOrigin(Measure(TextBox.Text or '')) + Measure(BeforeCursor);
        local Target = UDim2.new(0, X, 0.5, 0);
        Indicator.Size = UDim2.fromOffset(1, math.max(TextBox.TextSize - 2, 7));
        if Instant then
            Library:CancelMotion(Indicator, 'Position');
            Indicator.Position = Target;
        else
            Library:Animate(Indicator, { Position = Target }, 0.11, nil, 'TypingIndicator');
        end
    end;

    local function Rebuild()
        local Text = TextBox.Text or '';
        local TextColorKey = SyncTextColor();
        RenderedText.Text = Text;
        RenderedText.TextColor3 = Library[TextColorKey];
        RenderedText.TextXAlignment = TextBox.TextXAlignment;
        RenderedText.TextYAlignment = TextBox.TextYAlignment;
        RenderedText.TextSize = TextBox.TextSize;
        local RegistryEntry = Library.RegistryMap[RenderedText];
        if RegistryEntry then RegistryEntry.Properties.TextColor3 = TextColorKey; end;
        Placeholder.Visible = Text == '';
        UpdateIndicator(true);
    end;

    local function SyncLayer()
        Layer.Position = TextBox.Position;
        Layer.Size = TextBox.Size;
        Layer.Visible = TextBox.Visible;
        Placeholder.Text = TextBox.PlaceholderText;
        Placeholder.TextXAlignment = TextBox.TextXAlignment;
        Placeholder.TextYAlignment = TextBox.TextYAlignment;
        RenderedText.TextXAlignment = TextBox.TextXAlignment;
        RenderedText.TextYAlignment = TextBox.TextYAlignment;
    end;

    TextBox:GetPropertyChangedSignal('Text'):Connect(Rebuild);
    TextBox:GetPropertyChangedSignal('CursorPosition'):Connect(function()
        UpdateIndicator(false);
    end);
    TextBox:GetPropertyChangedSignal('Position'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('Size'):Connect(function()
        SyncLayer();
        Rebuild();
    end);
    TextBox:GetPropertyChangedSignal('Visible'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('TextXAlignment'):Connect(function()
        SyncLayer();
        Rebuild();
    end);
    TextBox:GetPropertyChangedSignal('TextYAlignment'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('TextSize'):Connect(Rebuild);
    TextBox:GetPropertyChangedSignal('PlaceholderText'):Connect(SyncLayer);
    TextBox.Focused:Connect(function()
        Rebuild();
        UpdateIndicator(true);
        Library:TweenUnifiedFade(Indicator, 1, 0.16, nil, 'Fade');
    end);
    TextBox.FocusLost:Connect(function()
        Rebuild();
        Library:TweenUnifiedFade(Indicator, 0, 0.18, nil, 'Fade');
    end);

    SyncLayer();
    Rebuild();

    local Controller = {
        Layer = Layer;
        Text = RenderedText;
        Indicator = Indicator;
        Refresh = Rebuild;
        OriginalTextTransparency = OriginalTextTransparency;
        OriginalStrokeTransparency = OriginalStrokeTransparency;
    };
    Library.TypingControllers[TextBox] = Controller;
    return Controller;
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
    local VisualPosition
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
        VisualPosition = Target
        Tooltip.Position = UDim2.fromOffset(Target.X, Target.Y)

        FollowConnection = RunService.RenderStepped:Connect(function(Delta)
            if not Tooltip.Visible then
                return
            end
            local Goal = GetTargetPosition()
            local SafeDelta = math.min(tonumber(Delta) or (1 / 60), 1 / 20)
            local FollowAlpha = 1 - math.exp(-28 * SafeDelta)
            VisualPosition = (VisualPosition or Goal):Lerp(Goal, FollowAlpha)
            Tooltip.Position = UDim2.fromOffset(VisualPosition.X, VisualPosition.Y)
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
            Content.Position = UDim2.fromOffset(0, 5)
            Library:SetUnifiedFadeProgress(Content, 0)
        end

        StartFollowing()
        Library:Animate(Content, { Position = UDim2.fromOffset(0, 0), }, 0.24, nil, 'Tooltip')
        Library:TweenUnifiedFade(Content, 1, 0.22, nil, 'Fade')
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
            Library:SetUnifiedFadeProgress(Content, 0)
            Content.Position = UDim2.fromOffset(0, 5)
            VisualPosition = nil
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

        Library:Animate(Content, { Position = UDim2.fromOffset(0, -3), }, 0.17, nil, 'PopupExit')
        local FadeTween = Library:TweenUnifiedFade(Content, 0, 0.18, function(State)
            if State == Enum.PlaybackState.Cancelled then return end
            if CurrentId ~= AnimationId or IsHovering then
                return
            end

            Tooltip.Visible = false
            VisualPosition = nil
            if Library.ActiveTooltipHide == Hide then
                Library.ActiveTooltipHide = nil
            end

            if FollowConnection then
                FollowConnection:Disconnect()
                FollowConnection = nil
            end

        end, 'Fade')
        if not FadeTween and CurrentId == AnimationId and not IsHovering then
            Tooltip.Visible = false
        end
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

        local SettingsInfo = type(Info.Settings) == 'table' and Info.Settings or {};
        local SettingsEnabled = Info.Settings == true or type(Info.Settings) == 'table' or Info.EnableSettings == true;
        local function Setting(Name, Fallback)
            local Value = SettingsInfo[Name];
            if Value == nil then Value = Info[Name]; end;
            return Value == nil and Fallback or Value;
        end;

        local InitialMode = tostring(Setting('Mode', 'Solid'));
        if InitialMode ~= 'Solid' and InitialMode ~= 'Fade' and InitialMode ~= 'Rainbow' then InitialMode = 'Solid'; end;
        if not SettingsEnabled then InitialMode = 'Solid'; end;
        local H, S, V = Color3.toHSV(Info.Default);
        local DefaultColor2 = Color3.fromHSV((H + 0.5) % 1, S, V);
        local InitialColor1 = Setting('Color1', Info.Default);
        local InitialColor2 = Setting('Color2', DefaultColor2);
        if typeof(InitialColor1) ~= 'Color3' then InitialColor1 = Info.Default; end;
        if typeof(InitialColor2) ~= 'Color3' then InitialColor2 = DefaultColor2; end;

        local ColorPicker = {
            Value = Info.Default;
            SolidColor = Info.Default;
            Color1 = InitialColor1;
            Color2 = InitialColor2;
            Transparency = Info.Transparency or 0;
            Mode = InitialMode;
            Speed = math.clamp(tonumber(Setting('Speed', 1)) or 1, 0.25, 4);
            SettingsEnabled = SettingsEnabled;
            EditingTarget = 'Solid';
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
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        Library:AddToRegistry(DisplayFrame, { BorderColor3 = 'OutlineColor'; });

        local DisplayShade = Library:Create('Frame', {
            BackgroundColor3 = Library:GetNeutralBlendShade();
            BackgroundTransparency = ColorPicker.Transparency;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 7;
            Parent = DisplayFrame;
        });
        Library:AddToRegistry(DisplayShade, {
            BackgroundColor3 = function()
                return Library:GetNeutralBlendShade();
            end;
        });
        Library:Create('UIGradient', {
            Rotation = -135;
            Transparency = Library:GetBlendShadeTransparency(0.42);
            Parent = DisplayShade;
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
            PlaceholderColor3 = Library.DisabledTextColor;
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
        Library:AddToRegistry(HueBox, {
            TextColor3 = 'FontColor';
            PlaceholderColor3 = 'DisabledTextColor';
        });

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
        Library:AddToRegistry(RgbBox, {
            TextColor3 = 'FontColor';
            PlaceholderColor3 = 'DisabledTextColor';
        });
        Library:EnableTypingAnimation(HueBox);
        Library:EnableTypingAnimation(RgbBox);

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

        local ColorControls = { SatVibMapOuter, HueSelectorOuter, HueBoxOuter, RgbBoxBase };
        if TransparencyBoxOuter then table.insert(ColorControls, TransparencyBoxOuter); end;
        local ActiveTab = 'Color';
        local AnimationElapsed = 0;
        local RainbowHueOffset = ColorPicker.Hue;
        local ModeButtons = {};
        local SettingsContent, FadeDependency, Color1Preview, Color2Preview;
        local SpeedSection, SpeedFill, SpeedCursor, SpeedValueLabel;
        local SelectTab, SetEditorFromColor, RefreshSettingsVisuals, PrepareManualEdit, ApplyOutputColor, ComputeAnimatedColor;

        local TabBar = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(4, 3);
            Size = UDim2.new(1, -8, 0, 18);
            ZIndex = 22;
            Parent = PickerFrameInner;
        });
        local ColorTab = Library:CreateLabel({
            Active = true;
            Size = SettingsEnabled and UDim2.new(0.5, -2, 1, -1) or UDim2.new(1, 0, 1, -1);
            Text = 'Color';
            TextSize = 13;
            TextColor3 = Library.AccentColor;
            ZIndex = 23;
            Parent = TabBar;
        });
        Library.RegistryMap[ColorTab].Properties.TextColor3 = 'AccentColor';
        local SettingsTab;
        if SettingsEnabled then
            SettingsTab = Library:CreateLabel({
                Active = true;
                Position = UDim2.new(0.5, 2, 0, 0);
                Size = UDim2.new(0.5, -2, 1, -1);
                Text = 'Settings';
                TextSize = 13;
                ZIndex = 23;
                Parent = TabBar;
            });
        end;
        local TabIndicator = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, -1);
            Size = SettingsEnabled and UDim2.new(0.5, -2, 0, 1) or UDim2.new(1, 0, 0, 1);
            ZIndex = 24;
            Parent = TabBar;
        });
        Library:AddToRegistry(TabIndicator, { BackgroundColor3 = 'AccentColor'; });

        if SettingsEnabled then
            SettingsContent = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(0, 24);
                Size = UDim2.new(1, 0, 1, -24);
                Visible = false;
                ZIndex = 18;
                Parent = PickerFrameInner;
            });
            Library:CreateLabel({
                Position = UDim2.fromOffset(8, 3);
                Size = UDim2.new(1, -16, 0, 16);
                Text = 'Mode';
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 19;
                Parent = SettingsContent;
            });
            local ModeRow = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 22);
                Size = UDim2.new(1, -14, 0, 22);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            for Index, Mode in ipairs({ 'Solid', 'Fade', 'Rainbow' }) do
                local Outer = Library:Create('Frame', {
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    BorderColor3 = Color3.new(0, 0, 0);
                    Position = UDim2.new((Index - 1) / 3, Index == 1 and 0 or 2, 0, 0);
                    Size = UDim2.new(1 / 3, -3, 1, 0);
                    ZIndex = 19;
                    Parent = ModeRow;
                });
                local Inner = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 20;
                    Parent = Outer;
                });
                local Label = Library:CreateLabel({
                    Active = true;
                    Size = UDim2.fromScale(1, 1);
                    Text = Mode;
                    TextSize = 12;
                    ZIndex = 21;
                    Parent = Inner;
                });
                Library:AddToRegistry(Inner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
                ModeButtons[Mode] = { Inner = Inner; Label = Label; };
                Outer.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        ColorPicker:SetMode(Mode);
                        Library:AttemptSave();
                    end;
                end);
            end;

            FadeDependency = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 53);
                Size = UDim2.new(1, -14, 0, 58);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            local function MakeFadeRow(Text, Y, Index)
                Library:CreateLabel({
                    Position = UDim2.fromOffset(1, Y);
                    Size = UDim2.new(1, -42, 0, 22);
                    Text = Text;
                    TextSize = 13;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 20;
                    Parent = FadeDependency;
                });
                local Outer = Library:Create('Frame', {
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    Position = UDim2.new(1, -34, 0, Y + 3);
                    Size = UDim2.fromOffset(30, 16);
                    ZIndex = 20;
                    Parent = FadeDependency;
                });
                local Preview = Library:Create('Frame', {
                    BackgroundColor3 = Index == 1 and ColorPicker.Color1 or ColorPicker.Color2;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 21;
                    Parent = Outer;
                });
                Library:AddToRegistry(Preview, { BorderColor3 = 'OutlineColor'; });
                Outer.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
                    ColorPicker.EditingTarget = Index == 1 and 'Color1' or 'Color2';
                    SetEditorFromColor(Index == 1 and ColorPicker.Color1 or ColorPicker.Color2);
                    SelectTab('Color', true);
                end);
                return Preview;
            end;
            Color1Preview = MakeFadeRow('Color 1', 0, 1);
            Color2Preview = MakeFadeRow('Color 2', 29, 2);

            SpeedSection = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(7, 119);
                Size = UDim2.new(1, -14, 0, 45);
                ZIndex = 19;
                Parent = SettingsContent;
            });
            SpeedValueLabel = Library:CreateLabel({
                Position = UDim2.fromOffset(1, 0);
                Size = UDim2.new(1, -2, 0, 16);
                Text = 'Speed';
                TextSize = 13;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 20;
                Parent = SpeedSection;
            });
            local Track = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.fromOffset(1, 22);
                Size = UDim2.new(1, -2, 0, 8);
                ZIndex = 20;
                Parent = SpeedSection;
            });
            Library:AddToRegistry(Track, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            SpeedFill = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(0, 0, 1, 0);
                ZIndex = 21;
                Parent = Track;
            });
            Library:AddToRegistry(SpeedFill, { BackgroundColor3 = 'AccentColor'; });
            SpeedCursor = Library:Create('Frame', {
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromScale(0, 0.5);
                Size = UDim2.fromOffset(3, 12);
                ZIndex = 22;
                Parent = Track;
            });
            Track.InputBegan:Connect(function(Input)
                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return; end;
                repeat
                    local MinX, MaxX = Track.AbsolutePosition.X, Track.AbsolutePosition.X + Track.AbsoluteSize.X;
                    local Alpha = (math.clamp(Mouse.X, MinX, MaxX) - MinX) / math.max(MaxX - MinX, 1);
                    ColorPicker:SetSpeed(0.25 + Alpha * 3.75);
                    RenderStepped:Wait();
                until not InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1);
                Library:AttemptSave();
            end);
        end;

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('CanvasGroup', {
                BorderColor3 = Color3.new(),
                GroupTransparency = 1,
                ZIndex = 14,

                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.AnimationId = 0;

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
                self.AnimationId = self.AnimationId + 1
                if not self.Container.Visible then
                    Library:SetUnifiedFadeProgress(self.Container, 0)
                    self.Container.Visible = true
                end
                Library:TweenUnifiedFade(self.Container, 1, 0.19, nil, 'Fade')
            end

            function ContextMenu:Hide()
                if not self.Container.Visible then return end
                self.AnimationId = self.AnimationId + 1
                local CurrentId = self.AnimationId
                Library:TweenUnifiedFade(self.Container, 0, 0.16, function(State)
                    if CurrentId == self.AnimationId and State ~= Enum.PlaybackState.Cancelled then
                        self.Container.Visible = false
                    end
                end, 'Fade')
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

        local function SetTabLabel(Label, Active)
            if not Label then return; end;
            Label.TextColor3 = Active and Library.AccentColor or Library.FontColor;
            local Data = Library.RegistryMap[Label];
            if Data then Data.Properties.TextColor3 = Active and 'AccentColor' or 'FontColor'; end;
        end;

        local function SetColorControlsVisible(Visible)
            for _, Control in ipairs(ColorControls) do Control.Visible = Visible; end;
        end;

        local function UpdateOutputVisuals(Color)
            DisplayFrame.BackgroundColor3 = Color;
            DisplayFrame.BackgroundTransparency = ColorPicker.Transparency;
            DisplayShade.BackgroundColor3 = Library:GetNeutralBlendShade();
            DisplayShade.BackgroundTransparency = ColorPicker.Transparency;
            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = Color;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;
        end;

        local function RefreshEditorVisuals()
            local EditorColor = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);
            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);
            local Hex = '#' .. EditorColor:ToHex();
            local Rgb = table.concat({ math.floor(EditorColor.R * 255), math.floor(EditorColor.G * 255), math.floor(EditorColor.B * 255) }, ', ');
            if not HueBox:IsFocused() and HueBox.Text ~= Hex then HueBox.Text = Hex; end;
            if not RgbBox:IsFocused() and RgbBox.Text ~= Rgb then RgbBox.Text = Rgb; end;
        end;

        SetEditorFromColor = function(Color)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker:SetHSVFromRGB(Color);
            RefreshEditorVisuals();
        end;

        local function FireCallbacks()
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        ApplyOutputColor = function(Color, Fire, SyncEditor)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker.Value = Color;
            UpdateOutputVisuals(Color);
            if SyncEditor then SetEditorFromColor(Color); end;
            if Fire then FireCallbacks(); end;
        end;

        ComputeAnimatedColor = function()
            if ColorPicker.Mode == 'Rainbow' then
                return Color3.fromHSV((RainbowHueOffset + AnimationElapsed * ColorPicker.Speed / 6) % 1, 1, 1);
            elseif ColorPicker.Mode == 'Fade' then
                local Phase = (AnimationElapsed * ColorPicker.Speed / 4) % 1;
                local Alpha = 0.5 - 0.5 * math.cos(Phase * math.pi * 2);
                return ColorPicker.Color1:Lerp(ColorPicker.Color2, Alpha);
            end;
            return ColorPicker.SolidColor;
        end;

        RefreshSettingsVisuals = function()
            if not SettingsEnabled then return; end;
            for Mode, Button in pairs(ModeButtons) do
                local Active = Mode == ColorPicker.Mode;
                Button.Inner.BackgroundColor3 = Active and Library.AccentColor:Lerp(Library.MainColor, 0.72) or Library.MainColor;
                SetTabLabel(Button.Label, Active);
            end;
            FadeDependency.Visible = ColorPicker.Mode == 'Fade';
            Color1Preview.BackgroundColor3 = ColorPicker.Color1;
            Color2Preview.BackgroundColor3 = ColorPicker.Color2;
            SpeedSection.Visible = ColorPicker.Mode ~= 'Solid';
            SpeedSection.Position = UDim2.fromOffset(7, ColorPicker.Mode == 'Fade' and 119 or 53);
            SpeedValueLabel.Text = string.format('Speed  %.2fx', ColorPicker.Speed);
            local Alpha = math.clamp((ColorPicker.Speed - 0.25) / 3.75, 0, 1);
            SpeedFill.Size = UDim2.new(Alpha, 0, 1, 0);
            SpeedCursor.Position = UDim2.new(Alpha, 0, 0.5, 0);
        end;

        SelectTab = function(Name, PreserveTarget)
            if Name == 'Settings' and not SettingsEnabled then Name = 'Color'; end;
            ActiveTab = Name;
            SetColorControlsVisible(Name == 'Color');
            if SettingsContent then SettingsContent.Visible = Name == 'Settings'; end;
            SetTabLabel(ColorTab, Name == 'Color');
            SetTabLabel(SettingsTab, Name == 'Settings');
            if SettingsEnabled then
                Library:Animate(TabIndicator, {
                    Position = Name == 'Settings' and UDim2.new(0.5, 2, 1, -1) or UDim2.new(0, 0, 1, -1)
                }, 0.14, nil, 'TabIndicator');
            end;
            if Name == 'Color' and not PreserveTarget then
                if ColorPicker.Mode == 'Solid' then
                    ColorPicker.EditingTarget = 'Solid';
                    SetEditorFromColor(ColorPicker.SolidColor);
                else
                    ColorPicker.EditingTarget = 'Live';
                    SetEditorFromColor(ColorPicker.Value);
                end;
            end;
            if Name == 'Settings' then RefreshSettingsVisuals(); end;
        end;

        PrepareManualEdit = function()
            if ColorPicker.EditingTarget == 'Live' then
                ColorPicker.SolidColor = ColorPicker.Value;
                ColorPicker.EditingTarget = 'Solid';
                ColorPicker:SetMode('Solid', true);
                SetEditorFromColor(ColorPicker.SolidColor);
            end;
        end;

        function ColorPicker:SetMode(Mode, Internal)
            Mode = tostring(Mode or 'Solid');
            if not SettingsEnabled or (Mode ~= 'Solid' and Mode ~= 'Fade' and Mode ~= 'Rainbow') then Mode = 'Solid'; end;
            ColorPicker.Mode = Mode;
            AnimationElapsed = 0;
            if Mode == 'Solid' then
                ColorPicker.EditingTarget = 'Solid';
                ApplyOutputColor(ColorPicker.SolidColor, true, ActiveTab == 'Color');
            else
                ColorPicker.EditingTarget = 'Live';
                if Mode == 'Rainbow' then RainbowHueOffset = select(1, Color3.toHSV(ColorPicker.Value)); end;
                ApplyOutputColor(ComputeAnimatedColor(), true, ActiveTab == 'Color');
            end;
            RefreshSettingsVisuals();
            if not Internal then Library:SafeCallback(ColorPicker.ModeChanged, ColorPicker.Mode); end;
        end;

        function ColorPicker:SetSpeed(Speed)
            ColorPicker.Speed = math.clamp(tonumber(Speed) or ColorPicker.Speed or 1, 0.25, 4);
            RefreshSettingsVisuals();
            Library:SafeCallback(ColorPicker.SpeedChanged, ColorPicker.Speed);
        end;

        function ColorPicker:SetFadeColor(Index, Color)
            if typeof(Color) ~= 'Color3' then return; end;
            if tonumber(Index) == 1 then ColorPicker.Color1 = Color else ColorPicker.Color2 = Color end;
            RefreshSettingsVisuals();
            if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live'); end;
        end;

        function ColorPicker:GetAnimationSettings()
            return { Mode = ColorPicker.Mode; Speed = ColorPicker.Speed; Color1 = ColorPicker.Color1; Color2 = ColorPicker.Color2; SolidColor = ColorPicker.SolidColor; };
        end;

        function ColorPicker:SetAnimationSettings(Data)
            if type(Data) ~= 'table' then return; end;
            if typeof(Data.SolidColor) == 'Color3' then ColorPicker.SolidColor = Data.SolidColor; end;
            if typeof(Data.Color1) == 'Color3' then ColorPicker.Color1 = Data.Color1; end;
            if typeof(Data.Color2) == 'Color3' then ColorPicker.Color2 = Data.Color2; end;
            if Data.Speed ~= nil then ColorPicker.Speed = math.clamp(tonumber(Data.Speed) or ColorPicker.Speed, 0.25, 4); end;
            ColorPicker:SetMode(Data.Mode or ColorPicker.Mode, true);
        end;

        function ColorPicker:OnModeChanged(Func)
            ColorPicker.ModeChanged = Func;
            Func(ColorPicker.Mode);
        end;

        function ColorPicker:OnSpeedChanged(Func)
            ColorPicker.SpeedChanged = Func;
            Func(ColorPicker.Speed);
        end;

        ColorTab.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then SelectTab('Color', false); end;
        end);
        if SettingsTab then
            SettingsTab.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then SelectTab('Settings', false); end;
            end);
        end;

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    PrepareManualEdit();
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    PrepareManualEdit();
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            local Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            if ColorPicker.EditingTarget == 'Color1' then
                ColorPicker.Color1 = Color;
                if Color1Preview then Color1Preview.BackgroundColor3 = Color; end;
                if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, false); end;
            elseif ColorPicker.EditingTarget == 'Color2' then
                ColorPicker.Color2 = Color;
                if Color2Preview then Color2Preview.BackgroundColor3 = Color; end;
                if ColorPicker.Mode == 'Fade' then ApplyOutputColor(ComputeAnimatedColor(), true, false); end;
            else
                ColorPicker.SolidColor = Color;
                ColorPicker.EditingTarget = 'Solid';
                ApplyOutputColor(Color, true, false);
            end;
            RefreshEditorVisuals();
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
            Library:CancelMotion(PickerFrameOuter);
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
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 10);
                Library:SetUnifiedFadeProgress(PickerFrameOuter, 0);
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            PlayPickerTween(PickerFrameOuter, Library:GetMenuTweenInfo(0.21, 'Picker'), {
                Position = TargetPosition;
            });
            Library:TweenUnifiedFade(PickerFrameOuter, 1, 0.23, nil, 'Fade');
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
            local Finished = false;
            local function FinishHide(State)
                if Finished or CurrentId ~= PickerAnimationId or State == Enum.PlaybackState.Cancelled then
                    return;
                end;
                Finished = true;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                table.clear(PickerTweens);
            end
            PlayPickerTween(PickerFrameOuter, Library:GetMenuTweenInfo(0.16, 'PopupExit'), {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 7);
            });
            Library:TweenUnifiedFade(PickerFrameOuter, 0, 0.18, FinishHide, 'Fade');
        end;

        function ColorPicker:SetValue(HSV, Transparency, PreserveMode)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker.SolidColor = Color;
            if not PreserveMode then ColorPicker:SetMode('Solid', true);
            elseif ColorPicker.Mode == 'Solid' then ApplyOutputColor(Color, true, ActiveTab == 'Color'); end;
            if ColorPicker.Mode == 'Solid' then SetEditorFromColor(Color); end;
        end;

        function ColorPicker:SetValueRGB(Color, Transparency, PreserveMode)
            if typeof(Color) ~= 'Color3' then return; end;
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker.SolidColor = Color;
            if not PreserveMode then ColorPicker:SetMode('Solid', true);
            elseif ColorPicker.Mode == 'Solid' then ApplyOutputColor(Color, true, ActiveTab == 'Color'); end;
            if ColorPicker.Mode == 'Solid' then SetEditorFromColor(Color); end;
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                PrepareManualEdit();
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
                PrepareManualEdit();
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
                        UpdateOutputVisuals(ColorPicker.Value);
                        FireCallbacks();
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

        if SettingsEnabled then
            Library:GiveSignal(RenderStepped:Connect(function(Delta)
                if ColorPicker.Mode == 'Solid' then return; end;
                AnimationElapsed = AnimationElapsed + math.min(tonumber(Delta) or 0, 0.1);
                local SyncEditor = PickerFrameOuter.Visible and ActiveTab == 'Color' and ColorPicker.EditingTarget == 'Live';
                ApplyOutputColor(ComputeAnimatedColor(), true, SyncEditor);
            end));
        end;

        RefreshSettingsVisuals();
        SelectTab('Color', true);
        ColorPicker:SetMode(InitialMode, true);
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local Modes = Info.Modes;
        if type(Modes) ~= 'table' or #Modes == 0 then
            Modes = { 'Always', 'Toggle', 'Hold' };
        end

        local InitialMode = Info.Mode or 'Toggle';
        if not table.find(Modes, InitialMode) then
            InitialMode = Modes[1];
        end

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Held = false;
            Mode = InitialMode;
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

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

        local ModeSelectOuter = Library:Create('CanvasGroup', {
            BorderColor3 = Color3.new(0, 0, 0);
            GroupTransparency = 1;
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60, 0, (#Modes * 15) + 2);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        });

        local ModeAnimationId = 0;
        local function ShowModeSelect()
            ModeAnimationId = ModeAnimationId + 1;
            if not ModeSelectOuter.Visible then
                Library:SetUnifiedFadeProgress(ModeSelectOuter, 0);
                ModeSelectOuter.Visible = true;
            end
            Library:TweenUnifiedFade(ModeSelectOuter, 1, 0.19, nil, 'Fade');
        end

        local function HideModeSelect()
            if not ModeSelectOuter.Visible then return; end
            ModeAnimationId = ModeAnimationId + 1;
            local CurrentId = ModeAnimationId;
            Library:TweenUnifiedFade(ModeSelectOuter, 0, 0.16, function(State)
                if CurrentId == ModeAnimationId and State ~= Enum.PlaybackState.Cancelled then
                    ModeSelectOuter.Visible = false;
                end
            end, 'Fade');
        end

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
                KeyPicker.Held = false;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                HideModeSelect();
            end;

            function ModeButton:Deselect()
                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select();
                    if KeyPicker.DoClick then KeyPicker:DoClick(); end
                    if KeyPicker.Update then KeyPicker:Update(); end
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
                return KeyPicker.Held;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            SetKeyDisplay(Key);
            KeyPicker.Value = Key;
            local Button = ModeButtons[Mode] or ModeButtons[KeyPicker.Mode] or ModeButtons[Modes[1]];
            if Button then Button:Select(); end
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
                ParentObj:SetValue(KeyPicker:GetState())
            end

            local State = KeyPicker:GetState();
            Library:SafeCallback(KeyPicker.Callback, State)
            Library:SafeCallback(KeyPicker.Clicked, State)
        end

        local function MatchesInput(Input)
            local Key = KeyPicker.Value;
            if not Key or Key == 'None' then return false; end
            if Key == 'MB1' then return Input.UserInputType == Enum.UserInputType.MouseButton1; end
            if Key == 'MB2' then return Input.UserInputType == Enum.UserInputType.MouseButton2; end
            return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key;
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
                ShowModeSelect();
            end;
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' and MatchesInput(Input) then
                    KeyPicker.Toggled = not KeyPicker.Toggled;
                    KeyPicker:DoClick();
                elseif KeyPicker.Mode == 'Hold' and MatchesInput(Input) then
                    KeyPicker.Held = true;
                    KeyPicker:DoClick();
                end;

                KeyPicker:Update();
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    HideModeSelect();
                end;
            end;
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Hold' and MatchesInput(Input) then
                    KeyPicker.Held = false;
                    KeyPicker:DoClick();
                end;
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
                Obj.DoubleClick = Props.DoubleClick or Props.Warning or Props.Confirm
                Obj.ConfirmDuration = math.clamp(tonumber(
                    Props.ConfirmDuration or Props.WarningDuration or Props.Timer
                ) or 3, 0.5, 10)
                Obj.Tooltip = Props.Tooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
                Obj.ConfirmDuration = 3
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
            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then
                    return false
                end

                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                    return false
                end

                return true
            end

            local function SetLabelColor(ColorKey)
                Library:RemoveFromRegistry(Button.Label)
                Library:AddToRegistry(Button.Label, { TextColor3 = ColorKey })
                Button.Label.TextColor3 = Library[ColorKey]
            end

            local function ReleasePress()
                if Button.Locked then return; end
                Library:Animate(Button.Inner, {
                    BackgroundColor3 = Library.MainColor;
                }, 0.12, nil, 'Color');
            end

            local function BeginWarningConfirmation()
                Button.ConfirmSequence = (Button.ConfirmSequence or 0) + 1;
                local Sequence = Button.ConfirmSequence;
                local Duration = Button.ConfirmDuration or 3;
                local StartedAt = os.clock();
                local Deadline = StartedAt + Duration;
                local Confirmed = false;

                Button.Locked = true;
                SetLabelColor('FontColor');
                Library:Animate(Button.Label, {
                    TextColor3 = Library.AccentColor;
                }, 0.12, nil, 'WarningFlash');
                Library:Animate(Button.Inner, {
                    BackgroundColor3 = Library.AccentColor:Lerp(Library.MainColor, 0.52);
                }, 0.12, nil, 'WarningFlash');
                task.delay(0.24, function()
                    if Button.ConfirmSequence ~= Sequence or not Button.Inner.Parent then return; end;
                    Library:Animate(Button.Label, {
                        TextColor3 = Library.FontColor;
                    }, 0.16, nil, 'WarningFlash');
                    Library:Animate(Button.Inner, {
                        BackgroundColor3 = Library.MainColor;
                    }, 0.16, nil, 'WarningFlash');
                end);

                if Button.ConfirmConnection then Button.ConfirmConnection:Disconnect(); end;
                Button.ConfirmConnection = Button.Outer.InputBegan:Connect(function(Input)
                    if os.clock() - StartedAt > 0.08 and ValidateClick(Input) then
                        Confirmed = true;
                    end;
                end);

                task.spawn(function()
                    while Button.ConfirmSequence == Sequence and Button.Outer.Parent and not Confirmed do
                        local Now = os.clock();
                        local Remaining = Deadline - Now;
                        if Remaining <= 0 then break; end;

                        Button.Label.Text = string.format('Are you sure? (%.1fs)', Remaining);
                        task.wait(0.05);
                    end;

                    if Button.ConfirmSequence ~= Sequence then return; end;
                    if Button.ConfirmConnection then
                        Button.ConfirmConnection:Disconnect();
                        Button.ConfirmConnection = nil;
                    end;

                    if Button.Inner.Parent then
                        Library:CancelMotion(Button.Inner, 'BackgroundColor3');
                        Library:Animate(Button.Inner, {
                            BackgroundColor3 = Library.MainColor;
                        }, 0.12, nil, 'Color');
                    end;
                    if Button.Label.Parent then
                        Library:CancelMotion(Button.Label, 'TextColor3');
                        SetLabelColor('FontColor');
                        Button.Label.Text = Button.Text;
                    end;
                    Button.Locked = false;

                    if Confirmed then Library:SafeCallback(Button.Func); end;
                end);
            end;

            Button.Outer.MouseLeave:Connect(ReleasePress)

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                Library:Animate(Button.Inner, {
                    BackgroundColor3 = Library:GetDarkerColor(Library.MainColor);
                }, 0.08, nil, 'Color');

                local ReleaseConnection;
                ReleaseConnection = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        ReleaseConnection:Disconnect();
                        ReleasePress();
                    end
                end)

                if Button.DoubleClick then
                    BeginWarningConfirmation();
                    return;
                end

                Library:SafeCallback(Button.Func);
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        Button.RowRoot = Button;
        Button.RowButtons = { Button };

        local function LayoutButtonRow(Root)
            local Buttons = Root.RowButtons;
            local Count = #Buttons;
            local Gap = 3;
            local WidthOffset = -(4 + (Gap * (Count - 1))) / Count;
            Root.Outer.Size = UDim2.new(1 / Count, WidthOffset, 0, 20);

            for Index = 2, Count do
                local Entry = Buttons[Index];
                Entry.Outer.Position = UDim2.new(Index - 1, Gap * (Index - 1), 0, 0);
                Entry.Outer.Size = UDim2.new(1, 0, 1, 0);
            end;
        end;

        local AttachButtonMethods;
        AttachButtonMethods = function(Control)
            function Control:AddTooltip(tooltip)
                if type(tooltip) == 'string' or type(tooltip) == 'table' then
                    Library:AddToolTip(tooltip, self.Outer)
                end
                return self
            end

            function Control:AddButton(...)
                local Root = self.RowRoot or self;
                assert(#Root.RowButtons < 3, 'AddButton: a button row supports at most three buttons.');

                local Sibling = {};
                local Class = #Root.RowButtons == 1 and 'SubButton' or 'TertiaryButton';
                ProcessButtonParams(Class, Sibling, ...);
                Sibling.RowRoot = Root;
                Sibling.Outer, Sibling.Inner, Sibling.Label = CreateBaseButton(Sibling);
                Sibling.Outer.Parent = Root.Outer;
                table.insert(Root.RowButtons, Sibling);

                InitEvents(Sibling);
                AttachButtonMethods(Sibling);
                LayoutButtonRow(Root);

                if type(Sibling.Tooltip) == 'string' or type(Sibling.Tooltip) == 'table' then
                    Sibling:AddTooltip(Sibling.Tooltip);
                end;
                return Sibling;
            end;

            function Control:AddTertiaryButton(...)
                local Root = self.RowRoot or self;
                assert(#Root.RowButtons == 2, 'AddTertiaryButton: add a secondary button first.');
                return self:AddButton(...);
            end;
        end;

        AttachButtonMethods(Button);
        LayoutButtonRow(Button);

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

            PlaceholderColor3 = Library.DisabledTextColor;
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
        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
            PlaceholderColor3 = 'DisabledTextColor';
        });

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

        local BoxTargetX = Box.Position.X.Offset;
        local function MoveInput(TargetX, Instant)
            BoxTargetX = TargetX;
            local Target = UDim2.fromOffset(TargetX, 0);
            if Instant then
                Library:CancelMotion(Box, 'Position');
                Box.Position = Target;
            else
                Library:Animate(Box, { Position = Target }, 0.12, nil, 'TypingScroll');
            end
        end

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                MoveInput(PADDING, not Box:IsFocused())
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = Library:GetTextBounds(
                        subtext,
                        Library.Font,
                        Library.BaseTextSizes[Box] or 14,
                        Vector2.new(100000, 100000)
                    )

                    local currentCursorPos = BoxTargetX + width

                    if currentCursorPos < PADDING then
                        MoveInput(PADDING - width, false)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        MoveInput(reveal - width - PADDING - 1, false)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Textbox.TypingAnimation = Library:EnableTypingAnimation(Box);

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

        local ToggleFill = Library:Create('CanvasGroup', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            GroupTransparency = 1;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 7;
            Parent = ToggleInner;
        });
        Library:AddCorner(ToggleFill, 3);
        Library:AddToRegistry(ToggleFill, { BackgroundColor3 = 'AccentColor'; });

        local ToggleShade = Library:Create('Frame', {
            BackgroundColor3 = Library.BlendShade;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 8;
            Parent = ToggleFill;
        });
        Library:AddToRegistry(ToggleShade, { BackgroundColor3 = 'BlendShade'; });
        Library:Create('UIGradient', {
            Rotation = -90;
            Transparency = Library:GetBlendShadeTransparency(0.50);
            Parent = ToggleShade;
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
            local BorderKey = Toggle.Value and 'BlendShade' or 'OutlineColor';
            local TextColorKey = Toggle.Risky and 'RiskColor'
                or (Toggle.Value and 'FontColor' or 'DisabledTextColor');

            ToggleShade.Visible = Toggle.Value;
            Library:TweenProperty(ToggleInner, 'BackgroundColor3', Library.MainColor, 0.11);
            Library:TweenProperty(ToggleInner, 'BorderColor3', Library[BorderKey], 0.11);
            Library:TweenProperty(ToggleFill, 'GroupTransparency', Toggle.Value and 0 or 1, 0.11);
            Library:TweenProperty(ToggleLabel, 'TextColor3', Library[TextColorKey], 0.11);

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = BorderKey;
            Library.RegistryMap[ToggleLabel].Properties.TextColor3 = TextColorKey;

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
            BorderColor3 = Library.BlendShade;
            ClipsDescendants = true;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        Library:AddCorner(Fill, 3);
        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'BlendShade';
        });
        local FillShade = Library:Create('Frame', {
            BackgroundColor3 = Library.BlendShade;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 8;
            Parent = Fill;
        });
        Library:AddToRegistry(FillShade, { BackgroundColor3 = 'BlendShade'; });
        Library:Create('UIGradient', {
            Rotation = -90;
            Transparency = Library:GetBlendShadeTransparency(0.48);
            Parent = FillShade;
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
            BorderColor3 = Library.BlendShade;
            ClipsDescendants = true;
            Position = UDim2.new(0, 20, 0.5, 0);
            Size = UDim2.fromOffset(7, 13);
            ZIndex = 10;
            Parent = SliderRow;
        });

        Library:AddCorner(Thumb, 3);
        Library:AddToRegistry(Thumb, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'BlendShade';
        });
        local ThumbShade = Library:Create('Frame', {
            BackgroundColor3 = Library.BlendShade;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 11;
            Parent = Thumb;
        });
        Library:AddToRegistry(ThumbShade, { BackgroundColor3 = 'BlendShade'; });
        Library:Create('UIGradient', {
            Rotation = -90;
            Transparency = Library:GetBlendShadeTransparency(0.48);
            Parent = ThumbShade;
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
        Library:EnableTypingAnimation(ValueEditor);

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, SliderRow);
        end

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.BlendShade;
            FillShade.BackgroundColor3 = Library.BlendShade;
            Thumb.BackgroundColor3 = Library.AccentColor;
            Thumb.BorderColor3 = Library.BlendShade;
            ThumbShade.BackgroundColor3 = Library.BlendShade;
        end;

        local IsDragging = false;
        local FillTargetSize;
        local ThumbTargetPosition;
        local BadgeTargetPosition;

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

            FillTargetSize = FillSize;
            ThumbTargetPosition = ThumbPosition;
            BadgeTargetPosition = BadgePosition;

            if Instant then
                StopVisualAnimation();
                Fill.Size = FillSize;
                Thumb.Position = ThumbPosition;
                ValueBadge.Position = BadgePosition;
            elseif IsDragging then
                -- Dragging updates the logical value immediately while the visuals
                -- follow the pointer through a frame-rate-independent micro-filter.
            else
                Library:Animate(Fill, { Size = FillSize }, 0.17, nil, 'Slider');
                Library:Animate(Thumb, { Position = ThumbPosition }, 0.17, nil, 'Slider');
                Library:Animate(ValueBadge, { Position = BadgePosition }, 0.18, nil, 'Badge');
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

        local DragRenderConnection;
        local DragEndedConnection;

        local function StopSliderDrag()
            if not IsDragging then return; end
            IsDragging = false;
            if DragRenderConnection then DragRenderConnection:Disconnect(); DragRenderConnection = nil; end
            if DragEndedConnection then DragEndedConnection:Disconnect(); DragEndedConnection = nil; end
            Slider:Display(false);
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
            StopVisualAnimation();

            local function UpdateFromX(PointerX)
                local Width = TrackWidth();
                local nX = math.clamp(PointerX - SliderInner.AbsolutePosition.X, 0, Width);
                local nValue = Slider:GetValueFromXOffset(nX);

                if nValue ~= Slider.Value then
                    Slider:SetValue(nValue);
                end;

                -- Keep pointer tracking continuous even when the slider value is rounded.
                local FillSize, ThumbPosition, BadgePosition = GetSliderVisuals(nX);
                FillTargetSize = FillSize;
                ThumbTargetPosition = ThumbPosition;
                BadgeTargetPosition = BadgePosition;
            end;

            UpdateFromX(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.X or Mouse.X);
            DragRenderConnection = RenderStepped:Connect(function(Delta)
                if not IsDragging then return; end
                if Input.UserInputType == Enum.UserInputType.Touch then
                    UpdateFromX(Input.Position.X);
                else
                    UpdateFromX(Mouse.X);
                end

                local Dt = math.min(math.max(Delta, 0), 1 / 20);
                local TrackAlpha = 1 - math.exp(-34 * Dt);
                local BadgeAlpha = 1 - math.exp(-26 * Dt);
                if FillTargetSize then
                    Fill.Size = Fill.Size:Lerp(FillTargetSize, TrackAlpha);
                end
                if ThumbTargetPosition then
                    Thumb.Position = Thumb.Position:Lerp(ThumbTargetPosition, TrackAlpha);
                end
                if BadgeTargetPosition then
                    ValueBadge.Position = ValueBadge.Position:Lerp(BadgeTargetPosition, BadgeAlpha);
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
            BackgroundColor3 = Library.Inline;
            BorderColor3 = Library.Inline;
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.Contrast;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddCorner(DropdownOuter, 3);
        Library:AddCorner(DropdownInner, 3);
        Library:AddToRegistry(DropdownOuter, {
            BackgroundColor3 = 'Inline';
            BorderColor3 = 'Inline';
        });
        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'Contrast';
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
            TextYAlignment = Enum.TextYAlignment.Center;
            TextWrapped = false;
            TextTruncate = Enum.TextTruncate.AtEnd;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Inline' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS = tonumber(Info.MaxVisibleItems) or 8;
        local POPUP_GAP = 5;
        local SEARCH_HEIGHT = 20;
        local VALUES_PADDING = 5;
        local ROW_HEIGHT = 20;
        local LIST_BOTTOM_GUARD = 2;
        local ListRowsHeight = ROW_HEIGHT;
        local ListTargetPosition = UDim2.fromOffset(0, 0);
        local SearchTargetPosition = UDim2.fromOffset(0, 0);
        local SearchOuter;
        local SearchBox;

        local ListOuter = Library:Create('CanvasGroup', {
            BackgroundColor3 = Library.Contrast;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            ClipsDescendants = true;
            GroupTransparency = 1;
            Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), ROW_HEIGHT + (VALUES_PADDING * 2) + LIST_BOTTOM_GUARD);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        Library:AddCorner(ListOuter, 3);
        Library:AddToRegistry(ListOuter, {
            BackgroundColor3 = 'Contrast';
            BorderColor3 = 'OutlineColor';
        });

        local ListInner = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClipsDescendants = true;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 21;
            Parent = ListOuter;
        });

        local DropdownGradient = DropdownInner:FindFirstChildOfClass('UIGradient');
        if DropdownGradient then
            DropdownGradient:Clone().Parent = ListOuter;
        end

        if Searchable then
            SearchOuter = Library:Create('CanvasGroup', {
                BackgroundColor3 = Library.Inline;
                BorderColor3 = Library.Inline;
                Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), SEARCH_HEIGHT);
                GroupTransparency = 1;
                ZIndex = 26;
                Visible = false;
                Parent = ScreenGui;
            });

            local SearchInner = Library:Create('Frame', {
                BackgroundColor3 = Library.Contrast;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 27;
                Parent = SearchOuter;
            });

            Library:AddCorner(SearchOuter, 3);
            Library:AddCorner(SearchInner, 3);
            Library:AddToRegistry(SearchOuter, {
                BackgroundColor3 = 'Inline';
                BorderColor3 = 'Inline';
            });
            Library:AddToRegistry(SearchInner, {
                BackgroundColor3 = 'Contrast';
                BorderColor3 = 'OutlineColor';
            });

            SearchBox = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ClearTextOnFocus = false;
                PlaceholderColor3 = Library.DisabledTextColor;
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
            Library:AddToRegistry(SearchBox, {
                TextColor3 = 'FontColor';
                PlaceholderColor3 = 'DisabledTextColor';
            });
            Library:EnableTypingAnimation(SearchBox);
        end

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClipsDescendants = true;
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
            ListOuter.Size = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2) + LIST_BOTTOM_GUARD);
        end;

        local function RecalculateListSize(RowHeight, Animated)
            ListRowsHeight = math.clamp(tonumber(RowHeight) or ROW_HEIGHT, ROW_HEIGHT, MAX_DROPDOWN_ITEMS * ROW_HEIGHT);
            local Width = math.max(DropdownOuter.AbsoluteSize.X, 1);
            local OuterSize = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2) + LIST_BOTTOM_GUARD);
            local ScrollSize = UDim2.new(1, -(VALUES_PADDING * 2), 0, ListRowsHeight);
            local TrackSize = UDim2.new(0, 3, 0, math.max(ListRowsHeight - 8, 1));

            if Animated and Dropdown.Opened then
                Library:Animate(ListOuter, { Size = OuterSize }, 0.19, nil, 'DropdownSearch');
                Library:Animate(Scrolling, { Size = ScrollSize }, 0.19, nil, 'DropdownSearch');
                Library:Animate(ScrollTrack, { Size = TrackSize }, 0.19, nil, 'DropdownSearch');
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
            local TextColorKey = Str == '' and 'DisabledTextColor' or 'FontColor';
            ItemList.TextColor3 = Library[TextColorKey];
            Library.RegistryMap[ItemList].Properties.TextColor3 = TextColorKey;
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
        local DropdownScrollReveal;

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
                    TextYAlignment = Enum.TextYAlignment.Center;
                    TextWrapped = false;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    ZIndex = 25;
                    Parent = Button;
                });

                Row.Button = Button;
                Row.Label = ButtonLabel;
                Row.Value = Value;

                function Row:UpdateButton()
                    local Selected = Info.Multi and Dropdown.Value[Value] or Dropdown.Value == Value;
                    local TextColorKey = Selected and 'AccentColor' or 'DisabledTextColor';
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
                    Library:UpdateDependencyBoxes();
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
                RecalculateListSize(Rows * ROW_HEIGHT, false);
            end
            if DropdownScrollReveal then DropdownScrollReveal:QueueRefresh(); end
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
            Library:UpdateDependencyBoxes();
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then Dropdown.Values = NewValues; end
            Dropdown:BuildDropdownList();
            Library:UpdateDependencyBoxes();
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
                    Library:Animate(Row.Button, { Size = UDim2.new(1, -5, 0, Matches and ROW_HEIGHT or 0) }, 0.18, nil, 'DropdownSearch');
                    Library:TweenFadeTree(Row.Button, not Matches, Matches and 0.16 or 0.14);
                end
            end

            local Rows = math.max(1, math.min(VisibleCount, MAX_DROPDOWN_ITEMS));
            RecalculateListSize(Rows * ROW_HEIGHT, not Instant);
            Scrolling.CanvasPosition = Vector2.new(0, 0);
            task.defer(UpdateDropdownScrollVisuals);
            if DropdownScrollReveal then DropdownScrollReveal:QueueRefresh(); end
        end;

        local SearchUpdateId = 0;
        if SearchBox then
            SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
                SearchUpdateId = SearchUpdateId + 1;
                local CurrentUpdate = SearchUpdateId;
                task.defer(function()
                    if CurrentUpdate == SearchUpdateId then
                        ApplyDropdownSearch(false);
                    end
                end);
            end);
        end

        DropdownScrollReveal = Library:BindScrollReveal(Scrolling, {
            VisibilityRoot = ListOuter;
            EdgeFade = ROW_HEIGHT - 2;
            Filter = function(Child)
                return Buttons[Child] ~= nil and Child.Active;
            end;
            TargetResolver = function(Child)
                local Row = Buttons[Child];
                return Row and Row.Label or nil;
            end;
        });

        local DropdownTweens = {};
        local DropdownAnimationId = 0;
        local DropdownScrollConnection;

        local function CancelDropdownTweens()
            for _, Tween in next, DropdownTweens do
                pcall(function() Tween:Cancel(); end);
            end
            table.clear(DropdownTweens);
            Library:CancelMotion(ListOuter);
            if SearchOuter then Library:CancelMotion(SearchOuter); end
        end

        local function PlayDropdownTween(Instance, Duration, Properties, Context)
            local Tween = Library:Animate(Instance, Properties, Duration, nil, Context or 'Dropdown');
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
                if not SearchOuter.Visible then
                    SearchOuter.Position = SearchTargetPosition + UDim2.fromOffset(0, -4);
                    Library:SetUnifiedFadeProgress(SearchOuter, 0);
                end
                SearchOuter.Visible = true;
                Library.OpenedFrames[SearchOuter] = true;
                PlayDropdownTween(SearchOuter, 0.23, { Position = SearchTargetPosition });
                Library:TweenUnifiedFade(SearchOuter, 1, 0.23, nil, 'Fade');
            end

            if not ListOuter.Visible then
                ListOuter.Position = ListTargetPosition + UDim2.fromOffset(0, -4);
                Library:SetUnifiedFadeProgress(ListOuter, 0);
            end
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            PlayDropdownTween(ListOuter, 0.24, { Position = ListTargetPosition });
            Library:TweenUnifiedFade(ListOuter, 1, 0.23, nil, 'Fade');
            if DropdownScrollReveal then DropdownScrollReveal:QueueRefresh(); end
            PlayDropdownTween(DropdownArrow, 0.17, { Rotation = 180 });
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

            local Finished = false;
            local function FinishClose(State)
                if Finished or CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then return; end
                Finished = true;
                ListOuter.Visible = false;
                ListOuter.Position = ListTargetPosition;
                if SearchOuter then
                    SearchOuter.Visible = false;
                    SearchOuter.Position = SearchTargetPosition;
                end
                table.clear(DropdownTweens);
            end

            PlayDropdownTween(ListOuter, 0.18, {
                Position = ListTargetPosition + UDim2.fromOffset(0, 2)
            }, 'PopupExit');
            Library:TweenUnifiedFade(ListOuter, 0, 0.19, FinishClose, 'Fade');

            if SearchOuter and SearchOuter.Visible then
                PlayDropdownTween(SearchOuter, 0.18, {
                    Position = SearchTargetPosition + UDim2.fromOffset(0, 2)
                }, 'PopupExit');
                Library:TweenUnifiedFade(SearchOuter, 0, 0.18, nil, 'Fade');
            end

            PlayDropdownTween(DropdownArrow, 0.15, { Rotation = 0 }, 'PopupExit');
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
        Library:UpdateDependencyBoxes();
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
                local Mode = Dependency[3];
                local Matches = Elem.Value == Value;

                if Elem.Type == 'Dropdown' then
                    if Elem.Multi then
                        if type(Value) == 'table' then
                            local MatchAll = Mode == 'All';
                            Matches = MatchAll;

                            for Key, Item in next, Value do
                                local Expected = type(Key) == 'number' and Item or Key;
                                local Selected = Elem.Value[Expected] == true;

                                if MatchAll then
                                    if not Selected then
                                        Matches = false;
                                        break;
                                    end
                                elseif Selected then
                                    Matches = true;
                                    break;
                                end
                            end
                        else
                            Matches = Elem.Value[Value] == true;
                        end
                    elseif type(Value) == 'table' then
                        Matches = table.find(Value, Elem.Value) ~= nil;
                    else
                        Matches = Elem.Value == Value;
                    end
                end

                if not Matches then
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
            SlideX = -48;
            SlideTarget = 0;
            SlideVelocity = 0;
            RevealScale = 0.68;
            RevealTarget = 1;
            RevealVelocity = 0;
            Exiting = false;
        };

        table.insert(Library.NotificationEntries, Entry);
        Library:ReflowNotifications();
        Entry.VisualY = Entry.TargetY + 10;
        Outer.Position = UDim2.fromOffset(8, Entry.VisualY);
        Inner.Position = UDim2.fromOffset(Entry.SlideX, 0);
        Inner.Size = UDim2.new(Entry.RevealScale, 0, 1, 0);
        return Entry;
    end

    function Library:BeginNotificationExit(Entry)
        if not Entry or Entry.Exiting then return; end
        Entry.Exiting = true;
        Entry.SlideTarget = -48;
        Entry.RevealTarget = 0.82;
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

                if Entry.ProgressBar and Entry.ProgressBar.Parent and not Entry.Exiting then
                    local Progress = math.clamp((os.clock() - Entry.Started) / Entry.Duration, 0, 1);
                    Entry.ProgressBar.Size = UDim2.new(Progress, 0, 1, 0);
                end
            end
        end
        if Dirty then Library:ReflowNotifications(); end
    end));

    local WatermarkOuter = Library:Create('CanvasGroup', {
        BackgroundColor3 = Library.Inline;
        BorderColor3 = Color3.new(0, 0, 0);
        GroupTransparency = 1;
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 230, 0, 26);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });
    Library:AddToRegistry(WatermarkOuter, { BackgroundColor3 = 'Inline'; });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(1, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

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

    local AccentBar = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(0, 0);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 206;
        Parent = WatermarkInner;
    });
    Library:AddToRegistry(AccentBar, { BackgroundColor3 = 'AccentColor'; });

    Library:AddMovingAccentGradient(AccentBar, 2.4);

    Library.WatermarkInfo = Library.WatermarkInfo or {
        GameName = tostring(Library.GameName or 'Unknown Game');
        Username = tostring(LocalPlayer and LocalPlayer.Name or 'Unknown');
        UserId = tostring(LocalPlayer and LocalPlayer.UserId or 0);
    };

    local WatermarkTitle = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 1);
        Size = UDim2.new(0, 0, 1, -2);
        Text = '';
        TextColor3 = Library.AccentColor;
        TextSize = 15;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 207;
        Parent = InnerFrame;
    });
    Library.RegistryMap[WatermarkTitle].Properties.TextColor3 = 'AccentColor';

    local WatermarkStats = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 1);
        Size = UDim2.new(0, 0, 1, -2);
        Text = '';
        TextColor3 = Library.FontColor;
        TextSize = 15;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 207;
        Parent = InnerFrame;
    });

    local WatermarkDetails = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 19);
        Size = UDim2.new(0, 0, 0, 15);
        Text = '';
        TextColor3 = Library.FontColor;
        TextSize = 13;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 207;
        Parent = InnerFrame;
    });

    local LegacyWatermarkText = Library:CreateLabel({
        Text = '';
        TextTransparency = 1;
        Visible = false;
        Parent = InnerFrame;
    });

    local function UpdateWatermarkText(Text)
        Text = tostring(Text or '');
        local Title, Stats = Text:match('^(.-)(%s+%-%s+.+)$');
        if not Title then Title, Stats = Text, ''; end

        local Info = Library.WatermarkInfo or {};
        local Details = {};
        if Info.ShowGameName ~= false then
            table.insert(Details, 'Game: ' .. tostring(Info.GameName or Library.GameName or 'Unknown Game'));
        end;
        if Info.ShowUsername ~= false then
            table.insert(Details, 'Username: ' .. tostring(Info.Username or (LocalPlayer and LocalPlayer.Name) or 'Unknown'));
        end;
        if Info.ShowUserId ~= false then
            table.insert(Details, 'User ID: ' .. tostring(Info.UserId or (LocalPlayer and LocalPlayer.UserId) or 0));
        end;
        if Info.ShowDate ~= false then
            table.insert(Details, 'Date: ' .. tostring(Info.Date or os.date('%Y-%m-%d')));
        end;
        local DetailsText = table.concat(Details, '  |  ');

        local TitleWidth, TitleHeight = Library:GetTextBounds(Title, Library.Font, 15);
        local StatsWidth, StatsHeight = Library:GetTextBounds(Stats, Library.Font, 15);
        local DetailsWidth, DetailsHeight = Library:GetTextBounds(DetailsText, Library.Font, 13);
        local TopHeight = math.max(TitleHeight, StatsHeight, 16) + 2;
        local DetailsY = TopHeight + 1;
        local OuterHeight = math.max(DetailsY + DetailsHeight + 6, 40);
        local StatsX = 8 + TitleWidth;
        WatermarkTitle.Text = Title;
        WatermarkTitle.Position = UDim2.fromOffset(8, 1);
        WatermarkTitle.Size = UDim2.fromOffset(TitleWidth, TopHeight);
        WatermarkStats.Text = Stats;
        WatermarkStats.Position = UDim2.fromOffset(StatsX, 1);
        WatermarkStats.Size = UDim2.fromOffset(StatsWidth, TopHeight);
        WatermarkDetails.Text = DetailsText;
        WatermarkDetails.Position = UDim2.fromOffset(8, DetailsY);
        WatermarkDetails.Size = UDim2.fromOffset(DetailsWidth, math.max(DetailsHeight, 14));
        WatermarkOuter.Size = UDim2.fromOffset(
            math.max(StatsX + StatsWidth + 9, DetailsWidth + 17, 230),
            OuterHeight
        );
    end
    LegacyWatermarkText:GetPropertyChangedSignal('Text'):Connect(function()
        UpdateWatermarkText(LegacyWatermarkText.Text);
    end);

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = LegacyWatermarkText;
    Library.WatermarkTitle = WatermarkTitle;
    Library.WatermarkStats = WatermarkStats;
    Library.WatermarkDetails = WatermarkDetails;
    Library.UpdateWatermarkText = UpdateWatermarkText;
    Library.WatermarkAnimationId = 0;
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
    Bool = not not Bool;
    local Watermark = Library.Watermark;
    if not Watermark then return; end

    Library.WatermarkAnimationId = (Library.WatermarkAnimationId or 0) + 1;
    local CurrentId = Library.WatermarkAnimationId;

    if Bool then
        if not Watermark.Visible then
            Library:SetUnifiedFadeProgress(Watermark, 0);
            Watermark.Visible = true;
        end
        Library:TweenUnifiedFade(Watermark, 1, 0.20, nil, 'Fade');
    elseif Watermark.Visible then
        Library:TweenUnifiedFade(Watermark, 0, 0.17, function(State)
            if CurrentId == Library.WatermarkAnimationId and State ~= Enum.PlaybackState.Cancelled then
                Watermark.Visible = false;
            end
        end, 'Fade');
    end
end;

function Library:SetWatermarkInfo(Info)
    if type(Info) ~= 'table' then return; end;
    Library.WatermarkInfo = Library.WatermarkInfo or {};
    for Key, Value in next, Info do
        if Key == 'GameName' then
            Value = NormalizeGameName(Value) or Library.GameName or 'Unknown Game';
        end;
        Library.WatermarkInfo[Key] = Value;
    end;
    if Library.UpdateWatermarkText and Library.WatermarkText then
        Library.UpdateWatermarkText(Library.WatermarkText.Text);
    end;
end;

function Library:SetWatermark(Text, Info)
    Text = tostring(Text or '');
    if type(Info) == 'table' then Library:SetWatermarkInfo(Info); end;
    Library.WatermarkText.Text = Text;
    if Library.UpdateWatermarkText then Library.UpdateWatermarkText(Text); end
    Library:SetWatermarkVisibility(true);
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
    local HealthVelocity = 0;
    local HealthSmoothTime = math.clamp(tonumber(Config.HealthSmoothTime or Config.HealthTweenTime) or 0.18, 0.06, 0.6);

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

    local function StepHealthVisual(Delta)
        if not HUD.HealthAvailable then return; end
        local Target = math.clamp(HUD.HealthTargetRatio or 0, 0, 1);
        local Current = math.clamp(HealthDriver.Value, 0, 1);
        local Dt = math.min(math.max(Delta, 0), 0.05);
        local Omega = 2 / math.max(HealthSmoothTime, 0.001);
        local X = Omega * Dt;
        local Exp = 1 / (1 + X + (0.48 * X * X) + (0.235 * X * X * X));
        local Change = Current - Target;
        local Temp = (HealthVelocity + (Omega * Change)) * Dt;
        HealthVelocity = (HealthVelocity - (Omega * Temp)) * Exp;
        local Next = Target + ((Change + Temp) * Exp);

        if math.abs(Target - Next) < 0.00005 and math.abs(HealthVelocity) < 0.00005 then
            Next = Target;
            HealthVelocity = 0;
        end

        HealthDriver.Value = math.clamp(Next, 0, 1);
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
            HealthVelocity = 0;
            HealthDriver.Value = 0;
            UpdateHealthVisual();
            return;
        end
        HUD.HealthAvailable = true;
        HUD.HealthMax = math.max(1, Maximum);
        local NewRatio = math.clamp(Current / HUD.HealthMax, 0, 1);
        HUD.HealthTargetRatio = NewRatio;
        if Instant then
            HealthVelocity = 0;
            HealthDriver.Value = NewRatio;
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
        local Duration = tonumber(Config.AnimationTime or Config.TweenTime) or 0.22;

        if Visible then
            if not Outer.Visible then
                Library:SetUnifiedFadeProgress(Outer, 0);
                Inner.Position = UDim2.fromOffset(1, 10);
                Outer.Visible = true;
            end
            Library:Animate(Inner, { Position = UDim2.fromOffset(1, 1); }, Duration, nil, 'HUD');
            Library:TweenUnifiedFade(Outer, 1, math.max(Duration - 0.03, 0.12), nil, 'Fade');
        elseif Outer.Visible then
            Library:Animate(Inner, { Position = UDim2.fromOffset(1, 7); }, Duration, nil, 'HUDExit');
            Library:TweenUnifiedFade(Outer, 0, math.max(Duration - 0.04, 0.12), function(State)
                if CurrentId == HUD.AnimationId and not HUD.Visible and State ~= Enum.PlaybackState.Cancelled and Outer.Parent then
                    Outer.Visible = false;
                end
            end, 'Fade');
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

        StepHealthVisual(Delta);

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

function Library:Notify(Text, Time, Title)
    if type(Text) == 'table' then
        local Info = Text;
        Title = Info.Title;
        Time = Info.Duration or Info.Time or Time;
        Text = Info.Text or Info.Message or Info.Description or '';
    end;

    Text = tostring(Text or '');
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
        ClipsDescendants = true;
        Position = UDim2.fromOffset(-48, 0);
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

    if HasTitle then
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

    local LeftColor = Library:Create('Frame', {
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
    return NotifyOuter;
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
    local ExplicitGameName = Config.GameName or Config.Game or Config.Subtitle;
    local GameName = NormalizeGameName(ExplicitGameName) or Library.GameName or 'Unknown Game';
    GameName = tostring(GameName)
    if Config.GameName or Config.Game or Config.Subtitle then
        Library:SetWatermarkInfo({ GameName = GameName; });
    end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.24 end

    if typeof(Config.AnchorPoint) ~= 'Vector2' then Config.AnchorPoint = Vector2.zero end
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

    Window.DragState = Library:MakeDraggable(Outer, 25);
    if Config.Resizable ~= false then
        Window.ResizeState = Library:MakeResizable(Outer, {
            MinSize = Config.MinSize or Vector2.new(420, 320);
            MaxSize = Config.MaxSize;
            Response = Config.ResizeResponse or 30;
        });
    end

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
        TextColor3 = Library.AccentColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 1;
        Parent = Inner;
    });
    Library.RegistryMap[WindowLabel].Properties.TextColor3 = 'AccentColor';

    local WindowSubtitle = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(1, -14, 0, 25);
        Text = 'for ' .. GameName;
        TextColor3 = Library.FontColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextTruncate = Enum.TextTruncate.AtEnd;
        ZIndex = 1;
        Parent = Inner;
    });

    local function UpdateWindowHeaderLayout()
        local TitleWidth = math.max(WindowLabel.TextBounds.X, 1);
        local SubtitleX = 7 + TitleWidth + 5;
        WindowLabel.Size = UDim2.fromOffset(TitleWidth, 25);
        WindowSubtitle.Position = UDim2.fromOffset(SubtitleX, 0);
        WindowSubtitle.Size = UDim2.new(1, -(SubtitleX + 7), 0, 25);
    end
    WindowLabel:GetPropertyChangedSignal('TextBounds'):Connect(UpdateWindowHeaderLayout);
    task.defer(UpdateWindowHeaderLayout);

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
        WindowLabel.Text = tostring(Title or '');
        task.defer(UpdateWindowHeaderLayout);
    end;

    function Window:SetWindowSubtitle(NewGameName)
        GameName = tostring(NormalizeGameName(NewGameName) or Library.GameName or 'Unknown Game');
        WindowSubtitle.Text = 'for ' .. GameName;
        task.defer(UpdateWindowHeaderLayout);
    end;

    function Window:SetWindowSize(Size, Animated)
        if typeof(Size) == 'Vector2' then Size = UDim2.fromOffset(Size.X, Size.Y); end
        if typeof(Size) ~= 'UDim2' then return; end
        if Animated == false then
            Library:CancelMotion(Outer, 'Size');
            Outer.Size = Size;
        else
            Library:Animate(Outer, { Size = Size }, 0.18, nil, 'Resize');
        end
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
            Size = UDim2.new(0.5, -12 + 2, 1, -14);
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
            Size = UDim2.new(0.5, -12 + 2, 1, -14);
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

        Tab.ScrollRevealStates = {
            Library:BindScrollReveal(LeftSide, { VisibilityRoot = TabFrame; });
            Library:BindScrollReveal(RightSide, { VisibilityRoot = TabFrame; });
        };

        function Tab:ShowTab()
            if Tab.Active then
                MainTabIndicator:MoveTo(TabButton, false);
                return;
            end;

            local PreviousTab = Window.ActiveTab;

            for _, OtherTab in next, Window.Tabs do
                if OtherTab ~= Tab and OtherTab.Active then
                    OtherTab:HideTab(OtherTab ~= PreviousTab);
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
                TabFrame.Position = UDim2.new(0, 0, 0, 6);
                Library:SetUnifiedFadeProgress(TabFrame, 0);
            end;
            TabFrame.Visible = true;
            Library:Animate(TabFrame, {
                Position = UDim2.new(0, 0, 0, 0);
            }, 0.30, nil, 'Tab');
            Library:TweenUnifiedFade(TabFrame, 1, 0.27, nil, 'Fade');
            for _, RevealState in ipairs(Tab.ScrollRevealStates) do
                if RevealState then RevealState:QueueRefresh(); end
            end
        end;

        function Tab:HideTab(Instant)
            if not Tab.Active and not TabFrame.Visible then
                return;
            end;

            Tab.Active = false;
            Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
            local CurrentAnimation = Tab.ContentAnimationId;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.09);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.12);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';

            if Instant then
                Library:CancelMotion(TabFrame);
                Library:SetUnifiedFadeProgress(TabFrame, 0);
                TabFrame.Visible = false;
                TabFrame.Position = UDim2.new(0, 0, 0, 0);
                return;
            end;

            Library:Animate(TabFrame, {
                Position = UDim2.new(0, 0, 0, -2);
            }, 0.21, nil, 'TabExit');
            local ExitTween = Library:TweenUnifiedFade(TabFrame, 0, 0.21, function(State)
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
                    if Element:IsA('GuiObject') and Element.Visible then
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
                    for _, OtherTab in next, Tabbox.Tabs do
                        if OtherTab ~= Tab and OtherTab.Active then
                            OtherTab:Hide(OtherTab ~= PreviousTab);
                        end;
                    end;

                    Tab.Active = true;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    if not Container.Visible then
                        Library:CancelMotion(Container);
                        Container.Position = UDim2.new(0, 4, 0, 26);
                        Library:SetUnifiedFadeProgress(Container, 0);
                    end;
                    Container.Visible = true;
                    Block.Visible = true;
                    TabboxIndicator:MoveTo(Button, not TabboxIndicator.Frame.Visible);

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.12);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.10);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
                    Library:Animate(Container, {
                        Position = UDim2.new(0, 4, 0, 20);
                    }, 0.28, nil, 'Tab');
                    Library:TweenUnifiedFade(Container, 1, 0.26, nil, 'Fade');

                    Tab:Resize();
                end;

                function Tab:Hide(Instant)
                    if not Tab.Active and not Container.Visible then
                        return;
                    end;

                    Tab.Active = false;
                    Tab.ContentAnimationId = Tab.ContentAnimationId + 1;
                    local CurrentAnimation = Tab.ContentAnimationId;

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.12);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.09);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';

                    if Instant then
                        Library:CancelMotion(Container);
                        Library:SetUnifiedFadeProgress(Container, 0);
                        Container.Visible = false;
                        Container.Position = UDim2.new(0, 4, 0, 20);
                        Block.Visible = false;
                        return;
                    end;

                    Library:Animate(Container, {
                        Position = UDim2.new(0, 4, 0, 18);
                    }, 0.20, nil, 'TabExit');
                    local ExitTween = Library:TweenUnifiedFade(Container, 0, 0.20, function(State)
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
                        if Child:IsA('GuiObject') then
                            TabCount = TabCount + 1;
                        end;
                    end;

                    if TabCount <= 0 then
                        return;
                    end;

                    for _, TabButtonObject in next, TabboxButtons:GetChildren() do
                        if TabButtonObject:IsA('GuiObject') then
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
                        if Element:IsA('GuiObject') and Element.Visible then
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
                Inner.Position = UDim2.fromOffset(1, 11);
                Outer.Visible = true;
            end

            Library:Animate(Inner, { Position = UDim2.fromOffset(1, 1); }, FadeTime, nil, 'Menu');
            Library:TweenUnifiedFade(Outer, 1, math.max(FadeTime - 0.04, 0.14), nil, 'Fade');
            StartFormaCursor();
        else
            CursorAnimationId = CursorAnimationId + 1;
            Library:Animate(Inner, { Position = UDim2.fromOffset(1, 8); }, FadeTime, nil, 'MenuExit');
            Library:TweenUnifiedFade(Outer, 0, math.max(FadeTime - 0.05, 0.13), function(State)
                if CurrentId ~= ToggleAnimationId or Toggled or State == Enum.PlaybackState.Cancelled then
                    return;
                end
                Outer.Visible = false;
            end, 'Fade');
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
