local HttpService = game:GetService('HttpService')
local UserInputService = game:GetService('UserInputService')
local CoreGui = game:GetService('CoreGui')

local Updater = {}
Updater.Version = '1.5.2+build.1'
Updater.Release = 'HF'
Updater.Build = 1
Updater.RepoBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/'
Updater.ApiBaseUrl = 'https://api.github.com/repos/Fyntra-Development/Forma/contents/'
Updater.LoaderUrl = Updater.RepoBaseUrl .. 'Loader.lua'
Updater.ManifestUrl = Updater.RepoBaseUrl .. 'versions.json'
Updater.ManifestSources = {
    Updater.ManifestUrl,
    'https://raw.githubusercontent.com/Fyntra-Development/Forma/refs/heads/main/versions.json',
    'https://github.com/Fyntra-Development/Forma/raw/refs/heads/main/versions.json',
}
Updater.ManifestApiUrl = 'https://api.github.com/repos/Fyntra-Development/Forma/contents/versions.json?ref=main'
Updater.CacheRoot = 'FormaCache'
Updater.ManifestPath = Updater.CacheRoot .. '/installed.json'
Updater.Persistent = type(isfile) == 'function'
    and type(readfile) == 'function'
    and type(writefile) == 'function'
    and type(makefolder) == 'function'

local function CacheBust(Url)
    local Separator = tostring(Url):find('?', 1, true) and '&' or '?'
    return tostring(Url) .. Separator .. 'forma_loader=' .. tostring(math.floor(os.clock() * 100000))
end

local function Fetch(PathOrUrl, ExtraHeaders)
    local Url = tostring(PathOrUrl)
    if not Url:match('^https?://') then
        Url = Updater.RepoBaseUrl .. Url
    end

    local Request = request or http_request or (syn and syn.request)
    if type(Request) == 'function' then
        local Headers = {
            ['Cache-Control'] = 'no-cache, no-store, max-age=0',
            ['Pragma'] = 'no-cache',
            ['Expires'] = '0',
            ['User-Agent'] = 'Forma-Updater',
        }
        if type(ExtraHeaders) == 'table' then
            for Key, Value in next, ExtraHeaders do
                Headers[Key] = Value
            end
        end

        local Success, Response = pcall(Request, {
            Url = CacheBust(Url),
            Method = 'GET',
            Headers = Headers,
        })
        if Success and type(Response) == 'table' then
            local Body = Response.Body or Response.body
            local Status = tonumber(Response.StatusCode or Response.Status or Response.status_code) or 200
            if Status >= 200 and Status < 300 and type(Body) == 'string' and Body ~= '' then
                return Body
            end
        end
    end

    if ExtraHeaders and next(ExtraHeaders) then
        return nil, 'header-capable request unavailable'
    end

    local Success, Body = pcall(function()
        return game:HttpGet(CacheBust(Url))
    end)

    if not Success or type(Body) ~= 'string' or Body == '' then
        return nil, tostring(Body or 'HTTP request failed')
    end
    return Body
end

local function DecodeJson(Body)
    local Success, Data = pcall(HttpService.JSONDecode, HttpService, Body)
    if not Success or type(Data) ~= 'table' then
        return nil
    end
    return Data
end

local function EncodeRepoPath(Path)
    local Parts = {}
    for Part in tostring(Path):gmatch('[^/\\]+') do
        table.insert(Parts, HttpService:UrlEncode(Part))
    end
    return table.concat(Parts, '/')
end

local function FetchRepoFile(Path)
    local CleanPath = tostring(Path):gsub('^/+', ''):gsub('\\', '/')
    local ApiUrl = Updater.ApiBaseUrl .. EncodeRepoPath(CleanPath) .. '?ref=main'
    local Body = Fetch(ApiUrl, {
        ['Accept'] = 'application/vnd.github.raw+json',
        ['X-GitHub-Api-Version'] = '2022-11-28',
    })
    if type(Body) == 'string' and Body ~= '' then
        return Body
    end

    local Sources = {
        'https://raw.githubusercontent.com/Fyntra-Development/Forma/refs/heads/main/' .. CleanPath,
        'https://github.com/Fyntra-Development/Forma/raw/refs/heads/main/' .. CleanPath,
        Updater.RepoBaseUrl .. CleanPath,
    }

    local LastError
    for _, Url in ipairs(Sources) do
        local Source, Error = Fetch(Url)
        if type(Source) == 'string' and Source ~= '' then
            return Source
        end
        LastError = Error or LastError
    end

    return nil, tostring(LastError or ('failed to fetch ' .. CleanPath))
end

local function GetSourceVersion(Name, Source)
    if type(Source) ~= 'string' then return nil end

    if Name == 'Library' then
        local Start = Source:find('local Library = {', 1, true)
        if Start then
            local Tail = Source:sub(Start)
            return Tail:match("Version%s*=%s*['\"]([^'\"]+)['\"]")
        end
    elseif Name == 'Loader' then
        return Source:match("Updater%.Version%s*=%s*['\"]([^'\"]+)['\"]")
    else
        return Source:match(tostring(Name) .. "%.Version%s*=%s*['\"]([^'\"]+)['\"]")
    end

    return nil
end

local function ValidateComponentSource(Name, Info, Source)
    if type(Source) ~= 'string' or Source == '' then
        return false, 'empty source'
    end

    local Path = type(Info) == 'table' and (Info.path or Info.Path) or nil
    if type(Path) == 'string' and Path:lower():sub(-4) == '.lua' and type(loadstring) == 'function' then
        local Chunk, CompileError = loadstring(Source)
        if not Chunk then
            return false, tostring(CompileError or 'compile failed')
        end
    end

    local Expected = type(Info) == 'table' and tostring(Info.version or Info.Version or '') or ''
    if Expected ~= '' then
        local Actual = GetSourceVersion(Name, Source)
        if Actual and Actual ~= Expected then
            return false, string.format('version mismatch: expected %s, got %s', Expected, Actual)
        end
        if (Name == 'Library' or Name == 'Loader') and not Actual then
            return false, 'version marker missing'
        end
    end

    return true
end

local function EnsureFolder(Path)
    if not Updater.Persistent then return false end
    local Current = ''
    for Part in tostring(Path):gmatch('[^/\\]+') do
        Current = Current == '' and Part or (Current .. '/' .. Part)
        if not isfolder(Current) then
            local Success = pcall(makefolder, Current)
            if not Success and not isfolder(Current) then return false end
        end
    end
    return true
end

local function ParentFolder(Path)
    return tostring(Path):match('^(.*)[/\\][^/\\]+$')
end

local function LocalPath(RemotePath)
    return Updater.CacheRoot .. '/' .. tostring(RemotePath):gsub('\\', '/')
end

function Updater:FetchManifest()
    local ApiBody = Fetch(self.ManifestApiUrl, {
        ['Accept'] = 'application/vnd.github.raw+json',
        ['X-GitHub-Api-Version'] = '2022-11-28',
    })
    local ApiManifest = DecodeJson(ApiBody)
    local ApiComponents = ApiManifest and (ApiManifest.Components or ApiManifest.components)
    if type(ApiComponents) == 'table' and type(ApiComponents.Library) == 'table' then
        return ApiManifest
    end

    for _, Url in ipairs(self.ManifestSources or { self.ManifestUrl }) do
        local Body, Error = Fetch(Url)
        if Body then
            local Manifest = DecodeJson(Body)
            local Components = Manifest and (Manifest.Components or Manifest.components)
            if type(Components) == 'table' and type(Components.Library) == 'table' then
                return Manifest
            end
        elseif Error then
            self.LastManifestError = Error
        end
    end

    return nil, self.LastManifestError or 'invalid versions.json'
end

function Updater:ReadInstalledManifest()
    if not self.Persistent or not isfile(self.ManifestPath) then return nil end
    local Success, Body = pcall(readfile, self.ManifestPath)
    if not Success or type(Body) ~= 'string' then return nil end
    return DecodeJson(Body)
end

function Updater:WriteInstalledManifest(Manifest)
    if not self.Persistent then return false, 'filesystem unavailable' end
    EnsureFolder(self.CacheRoot)
    local Success, Encoded = pcall(HttpService.JSONEncode, HttpService, Manifest)
    if not Success then return false, 'failed to encode installed manifest' end
    local Wrote, Error = pcall(writefile, self.ManifestPath, Encoded)
    return Wrote, Error
end

function Updater:InstallManifest(Manifest, Progress)
    if not self.Persistent then
        return false, 'persistent filesystem APIs are unavailable'
    end

    local function Report(Text, Value)
        if type(Progress) == 'function' then
            pcall(Progress, Text, math.clamp(tonumber(Value) or 0, 0, 1))
        end
    end

    local Components = Manifest and (Manifest.Components or Manifest.components)
    if type(Components) ~= 'table' then
        return false, 'update manifest has no components'
    end

    local Entries = {}
    for Name, Info in next, Components do
        if type(Info) == 'table' and type(Info.path or Info.Path) == 'string' then
            table.insert(Entries, {
                Name = tostring(Name);
                Path = Info.path or Info.Path;
                Info = Info;
            })
        end
    end
    table.sort(Entries, function(A, B) return A.Name < B.Name end)

    Report('Preparing update...', 0.08)

    local Staged = {}
    local Count = math.max(#Entries, 1)
    for Index, Entry in ipairs(Entries) do
        Report('Downloading ' .. Entry.Name .. '...', 0.12 + ((Index - 1) / Count) * 0.48)

        local Source
        local Error

        for Attempt = 1, 3 do
            Source, Error = FetchRepoFile(Entry.Path)
            if Source then
                local Valid, ValidationError = ValidateComponentSource(Entry.Name, Entry.Info, Source)
                if Valid then
                    break
                end
                Error = ValidationError
                Source = nil
            end
            if Attempt < 3 then task.wait(0.12 * Attempt) end
        end

        if not Source then
            return false, string.format('failed to download %s: %s', Entry.Name, tostring(Error))
        end

        Staged[Entry.Path] = Source
        Report('Verified ' .. Entry.Name, 0.12 + (Index / Count) * 0.48)
    end

    Report('Installing files...', 0.66)
    for Index, Entry in ipairs(Entries) do
        local Source = Staged[Entry.Path]
        local Destination = LocalPath(Entry.Path)
        local Parent = ParentFolder(Destination)
        if Parent and not EnsureFolder(Parent) then
            return false, 'failed to prepare updater cache'
        end

        local Success, Error = pcall(writefile, Destination, Source)
        if not Success then
            return false, tostring(Error or ('failed to write ' .. Destination))
        end

        Report('Installing ' .. Entry.Name .. '...', 0.66 + (Index / Count) * 0.24)
    end

    Report('Finalizing update...', 0.94)
    local Success, Error = self:WriteInstalledManifest(Manifest)
    if not Success then return false, tostring(Error) end

    self.InstalledManifest = Manifest
    Report('Update ready.', 0.98)
    return true
end

function Updater:EnsureInstalled()
    if not self.Persistent then
        local Manifest, Error = self:FetchManifest()
        if not Manifest then return false, Error end
        self.InstalledManifest = Manifest
        self.RemoteOnly = true
        return true
    end

    EnsureFolder(self.CacheRoot)
    local Installed = self:ReadInstalledManifest()

    if Installed then
        local Components = Installed.Components or Installed.components
        local CacheValid = type(Components) == 'table'

        if CacheValid then
            for Name, Info in next, Components do
                if type(Info) == 'table' and type(Info.path or Info.Path) == 'string' then
                    local Path = LocalPath(Info.path or Info.Path)
                    if not isfile(Path) then
                        CacheValid = false
                        break
                    end

                    local ReadSuccess, Source = pcall(readfile, Path)
                    if not ReadSuccess then
                        CacheValid = false
                        break
                    end

                    local Valid = ValidateComponentSource(tostring(Name), Info, Source)
                    if not Valid then
                        CacheValid = false
                        break
                    end
                end
            end
        end

        if CacheValid then
            self.InstalledManifest = Installed
            return true
        end
    end

    local Manifest, Error = self:FetchManifest()
    if not Manifest then return false, Error end
    return self:InstallManifest(Manifest)
end

function Updater:GetComponentInfo(Name)
    local Manifest = self.InstalledManifest or self:ReadInstalledManifest()
    local Components = Manifest and (Manifest.Components or Manifest.components)
    return type(Components) == 'table' and Components[Name] or nil
end

function Updater:GetSource(NameOrPath)
    local Info = self:GetComponentInfo(NameOrPath)
    local RemotePath = Info and (Info.path or Info.Path) or tostring(NameOrPath)
    local Name = Info and tostring(NameOrPath) or tostring(NameOrPath)

    if self.Persistent then
        local Path = LocalPath(RemotePath)
        if isfile(Path) then
            local Success, Source = pcall(readfile, Path)
            if Success and type(Source) == 'string' and Source ~= '' then
                if not Info then
                    return Source
                end

                local Valid = ValidateComponentSource(Name, Info, Source)
                if Valid then
                    return Source
                end
            end
        end
    end

    local Source, Error = FetchRepoFile(RemotePath)
    if not Source then return nil, Error end

    if Info then
        local Valid, ValidationError = ValidateComponentSource(Name, Info, Source)
        if not Valid then
            return nil, ValidationError
        end
    end

    if self.Persistent and Info then
        local Destination = LocalPath(RemotePath)
        local Parent = ParentFolder(Destination)
        if Parent then EnsureFolder(Parent) end
        pcall(writefile, Destination, Source)
    end

    return Source
end

function Updater:LoadAddon(Name)
    local Source, Error = self:GetSource(Name)
    if not Source then
        error(string.format('Forma loader could not load %s: %s', tostring(Name), tostring(Error)))
    end

    local Chunk, CompileError = loadstring(Source)
    if not Chunk then error(CompileError) end
    return Chunk()
end

function Updater:InstallUpdate(ComponentName, RemoteInfo, Progress)
    if type(Progress) == 'function' then
        pcall(Progress, 'Checking latest release...', 0.03)
    end

    local Manifest, Error = self:FetchManifest()
    if not Manifest then return false, Error end

    return self:InstallManifest(Manifest, Progress)
end

local Ready, Error = Updater:EnsureInstalled()
if not Ready then
    error('Forma updater failed to initialize: ' .. tostring(Error))
end

local Environment = getgenv and getgenv() or _G

local function CleanupExistingForma()
    local Existing = Environment.FormaLibrary or Environment.Library
    if type(Existing) == 'table' and type(Existing.Unload) == 'function' then
        pcall(Existing.Unload, Existing)
    end

    local Parents = {}
    local Seen = {}
    local function AddParent(Parent)
        if typeof(Parent) == 'Instance' and not Seen[Parent] then
            Seen[Parent] = true
            table.insert(Parents, Parent)
        end
    end

    pcall(function()
        if gethui then AddParent(gethui()) end
    end)
    AddParent(CoreGui)

    for _, Parent in ipairs(Parents) do
        for _, Child in ipairs(Parent:GetChildren()) do
            if Child.Name == 'FormaGui' or Child.Name:sub(1, 13) == 'FormaUtility_' then
                pcall(function() Child:Destroy() end)
            end
        end
    end

    pcall(function()
        UserInputService.MouseIconEnabled = true
    end)
end

CleanupExistingForma()
Environment.FormaUpdater = Updater

local LibrarySource, LibraryError = Updater:GetSource('Library')
if not LibrarySource then
    error('Forma loader could not load Library: ' .. tostring(LibraryError))
end

local LibraryChunk, CompileError = loadstring(LibrarySource)
if not LibraryChunk then error(CompileError) end

Environment.__FormaLoaderBooting = true
local LibrarySuccess, LibraryResult = pcall(LibraryChunk)
Environment.__FormaLoaderBooting = nil
if not LibrarySuccess then error(LibraryResult) end

Updater.Library = LibraryResult
Updater.Library:SetUpdateRestartSource(Updater.LoaderUrl)

local Library = Updater.Library

local function FindUpdateParts(Outer)
    local Parts = {
        Outer = Outer;
        Buttons = {};
    }
    if not Outer or not Outer.Parent then return Parts end

    for _, Descendant in ipairs(Outer:GetDescendants()) do
        if Descendant:IsA('TextButton') then
            table.insert(Parts.Buttons, Descendant)
            if Descendant.Text == 'Yes' then Parts.Yes = Descendant end
            if Descendant.Text == 'No' then Parts.No = Descendant end
            if Descendant.Text == '×' then Parts.Close = Descendant end
        elseif Descendant:IsA('TextLabel') then
            if Descendant.Name == 'FormaUpdateTitle' then
                Parts.Title = Descendant
            elseif Descendant.Name == 'FormaUpdateBody' then
                Parts.Body = Descendant
            end
        end
    end
    return Parts
end

function Updater:StyleUpdatePrompt(Outer, Info, BodyText)
    if not Outer or not Outer.Parent then return end

    local TitleLabel, BodyLabel
    for _, Descendant in ipairs(Outer:GetDescendants()) do
        if Descendant:IsA('TextLabel') then
            if Descendant.Text == 'Forma update available' or Descendant.Text == 'Update available' then
                TitleLabel = Descendant
            elseif Descendant.Text == BodyText then
                BodyLabel = Descendant
            end
        end
    end

    if TitleLabel then
        TitleLabel.Name = 'FormaUpdateTitle'
        TitleLabel.Text = 'Update available'
        TitleLabel.TextColor3 = Library.FontColor
        TitleLabel.TextStrokeTransparency = 1
        local Entry = Library.RegistryMap and Library.RegistryMap[TitleLabel]
        if Entry and Entry.Properties then Entry.Properties.TextColor3 = 'FontColor' end
    end

    if BodyLabel then
        BodyLabel.Name = 'FormaUpdateBody'
        BodyLabel.TextStrokeTransparency = 1
    end

    local Parts = FindUpdateParts(Outer)
    if Parts.Yes then
        Parts.Yes.AnchorPoint = Vector2.new(1, 0)
        Parts.Yes.Position = UDim2.new(1, -82, 0, 0)
        Parts.Yes.Size = UDim2.fromOffset(76, 25)
        Parts.Yes.BackgroundColor3 = Library.Contrast
        Parts.Yes.TextColor3 = Library.FontColor

        local Stroke = Instance.new('UIStroke')
        Stroke.Name = 'FormaUpdateButtonStroke'
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Stroke.Color = Library.AccentColor
        Stroke.Transparency = 0.18
        Stroke.Thickness = 1
        Stroke.Parent = Parts.Yes

        if Library.AddToRegistry then
            Library:AddToRegistry(Stroke, { Color = 'AccentColor'; }, true)
        end
    end
    if Parts.No then
        Parts.No.AnchorPoint = Vector2.new(1, 0)
        Parts.No.Position = UDim2.new(1, 0, 0, 0)
        Parts.No.Size = UDim2.fromOffset(76, 25)
        Parts.No.BackgroundColor3 = Library.Contrast
        Parts.No.TextColor3 = Library.DisabledTextColor
    end
end

function Updater:BeginUpdateAnimation(Outer, Info)
    local Parts = FindUpdateParts(Outer)
    if not Outer or not Outer.Parent then
        return function() end, function() end
    end

    for _, Button in ipairs(Parts.Buttons) do
        Button.Visible = false
    end

    if Parts.Title then
        Parts.Title.Text = 'Updating Forma'
        Parts.Title.TextColor3 = Library.FontColor
    end
    if Parts.Body then
        Parts.Body.Text = 'Preparing update...'
        Parts.Body.TextColor3 = Library.DisabledTextColor
    end

    local Track = Instance.new('Frame')
    Track.Name = 'FormaUpdateProgressTrack'
    Track.BackgroundColor3 = Library.OutlineColor
    Track.BorderSizePixel = 0
    Track.Position = UDim2.new(0, 14, 1, -12)
    Track.Size = UDim2.new(1, -28, 0, 3)
    Track.ZIndex = 120
    Track.Parent = Outer

    local TrackCorner = Instance.new('UICorner')
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new('Frame')
    Fill.Name = 'FormaUpdateProgressFill'
    Fill.BackgroundColor3 = Library.AccentColor
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.fromScale(0.02, 1)
    Fill.ZIndex = 121
    Fill.Parent = Track

    local FillCorner = Instance.new('UICorner')
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Gradient = Instance.new('UIGradient')
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.AccentColor));
        ColorSequenceKeypoint.new(0.5, Library.AccentColor);
        ColorSequenceKeypoint.new(1, Library:GetDarkerColor(Library.AccentColor));
    })
    Gradient.Parent = Fill

    task.spawn(function()
        while Outer.Parent and Fill.Parent do
            local T = os.clock() * 1.4
            Gradient.Offset = Vector2.new((T % 2) - 1, 0)
            task.wait()
        end
    end)

    local LastProgress = 0.02
    local function Update(Status, Progress)
        if not Outer.Parent then return end
        if Parts.Body and Parts.Body.Parent and Status then
            Parts.Body.Text = tostring(Status)
        end

        Progress = math.clamp(tonumber(Progress) or LastProgress, LastProgress, 1)
        LastProgress = Progress

        if Library.Animate and Fill.Parent then
            Library:Animate(Fill, { Size = UDim2.fromScale(Progress, 1); }, 0.18, nil, 'Layout')
        elseif Fill.Parent then
            Fill.Size = UDim2.fromScale(Progress, 1)
        end
    end

    local function Fail(Message)
        if not Outer.Parent then return end
        if Parts.Title and Parts.Title.Parent then Parts.Title.Text = 'Update failed' end
        if Parts.Body and Parts.Body.Parent then
            Parts.Body.Text = tostring(Message or 'The update could not be installed.')
            Parts.Body.TextColor3 = Library.RiskColor or Library.FontColor
        end
        Fill.BackgroundColor3 = Library.RiskColor or Library.AccentColor
        if Parts.Close and Parts.Close.Parent then Parts.Close.Visible = true end
    end

    return Update, Fail
end

function Library:PerformUpdateRestart(ComponentName, RemoteInfo)
    local Progress = Library.__FormaUpdateProgress
    local function Report(Text, Value)
        if type(Progress) == 'function' then pcall(Progress, Text, Value) end
    end

    local Handler = Library.UpdateRestartHandler
    if not Handler and type(Environment.FormaRestart) == 'function' then
        Handler = Environment.FormaRestart
    end

    if Handler then
        Report('Handing off update...', 0.92)
        local Success, Error = pcall(Handler, ComponentName, RemoteInfo, Library)
        if not Success then return false, tostring(Error) end
        return true
    end

    local InstallSuccess, InstallError = Updater:InstallUpdate(ComponentName, RemoteInfo, Report)
    if not InstallSuccess then
        return false, tostring(InstallError or 'failed to install update')
    end

    local RestartSource = Library.UpdateRestartSource
    local Source
    local FetchError

    Report('Preparing restart...', 0.985)

    if not RestartSource or RestartSource == '' or RestartSource == Updater.LoaderUrl then
        Source, FetchError = Updater:GetSource('Loader')
        if not Source then
            Source, FetchError = FetchRepoFile('Loader.lua')
        end
    else
        Source, FetchError = Fetch(RestartSource)
    end

    if not Source then
        return false, tostring(FetchError or 'failed to download restart source')
    end

    local Chunk, RestartCompileError = loadstring(Source)
    if not Chunk then
        return false, 'updated UI failed to compile: ' .. tostring(RestartCompileError)
    end

    Report('Restarting UI...', 1)
    task.wait(0.22)

    Library:Unload()
    pcall(function() UserInputService.MouseIconEnabled = true end)

    task.defer(function()
        local Success, Result = pcall(Chunk)
        if Success then
            if type(Result) == 'table' and type(Result.Library) == 'table' then
                Environment.Library = Result.Library
                Environment.FormaLibrary = Result.Library
            elseif type(Result) == 'table' and Result.ScreenGui then
                Environment.Library = Result
                Environment.FormaLibrary = Result
            end
        else
            warn('[Forma updater] Restart failed: ' .. tostring(Result))
            pcall(function() UserInputService.MouseIconEnabled = true end)
        end
    end)

    return true
end

function Library:PromptForUpdate(Info)
    if type(Info) ~= 'table' then return nil end

    local PromptKey = tostring(Info.Name) .. '@' .. tostring(Info.Version)
    Library.UpdatePrompted = Library.UpdatePrompted or {}
    if Library.UpdatePrompted[PromptKey] then return nil end
    Library.UpdatePrompted[PromptKey] = true

    local BodyText = string.format(
        '%s  v%s  ->  v%s\n\nUpdate and restart the UI now?',
        tostring(Info.Name),
        tostring(Info.CurrentVersion),
        tostring(Info.Version)
    )

    local YesButton = {
        Text = 'Yes';
        Primary = false;
        KeepOpen = true;
    }

    YesButton.Callback = function(NotifyOuter, ButtonInfo)
        ButtonInfo.KeepOpen = true
        local UpdateProgress, Fail = Updater:BeginUpdateAnimation(NotifyOuter, Info)
        Library.__FormaUpdateProgress = UpdateProgress

        task.spawn(function()
            task.wait(0.08)
            local Success, Error = Library:PerformUpdateRestart(Info.Name, Info)
            Library.__FormaUpdateProgress = nil
            if not Success then
                Fail(Error)
            end
        end)
    end

    local Outer = Library:Notify({
        Type = 'Update';
        Title = 'Forma update available';
        Text = BodyText;
        Persistent = true;
        CloseButton = true;
        Width = 390;
        Button = YesButton;
        SubButton = {
            Text = 'No';
            Primary = false;
            Callback = function() end;
        };
    })

    Updater:StyleUpdatePrompt(Outer, Info, BodyText)
    return Outer
end

return Updater
