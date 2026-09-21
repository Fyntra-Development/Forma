-- Forma persistent loader
-- Loads the installed/cached Forma release first, then lets Library.lua compare
-- that installed version against versions.json before the user chooses to update.

local HttpService = game:GetService('HttpService')

local Updater = {}
Updater.RepoBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/'
Updater.LoaderUrl = Updater.RepoBaseUrl .. 'Loader.lua'
Updater.ManifestUrl = Updater.RepoBaseUrl .. 'versions.json'
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

local function Fetch(PathOrUrl)
    local Url = tostring(PathOrUrl)
    if not Url:match('^https?://') then
        Url = Updater.RepoBaseUrl .. Url
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
    local Body, Error = Fetch(self.ManifestUrl)
    if not Body then return nil, Error end
    local Manifest = DecodeJson(Body)
    if not Manifest then return nil, 'invalid versions.json' end
    return Manifest
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

function Updater:InstallManifest(Manifest)
    if not self.Persistent then
        return false, 'persistent filesystem APIs are unavailable'
    end

    local Components = Manifest and (Manifest.Components or Manifest.components)
    if type(Components) ~= 'table' then
        return false, 'update manifest has no components'
    end

    -- Download and compile-check every Lua component before replacing any
    -- installed file, preventing a partial update if one request fails.
    local Staged = {}
    for Name, Info in next, Components do
        if type(Info) == 'table' and type(Info.path or Info.Path) == 'string' then
            local RemotePath = Info.path or Info.Path
            local Source, Error = Fetch(RemotePath)
            if not Source then
                return false, string.format('failed to download %s: %s', tostring(Name), tostring(Error))
            end

            if RemotePath:lower():sub(-4) == '.lua' and type(loadstring) == 'function' then
                local Chunk, CompileError = loadstring(Source)
                if not Chunk then
                    return false, string.format('%s failed to compile: %s', tostring(Name), tostring(CompileError))
                end
            end

            Staged[RemotePath] = Source
        end
    end

    for RemotePath, Source in next, Staged do
        local Destination = LocalPath(RemotePath)
        local Parent = ParentFolder(Destination)
        if Parent and not EnsureFolder(Parent) then
            return false, 'failed to prepare updater cache'
        end

        local Success, Error = pcall(writefile, Destination, Source)
        if not Success then
            return false, tostring(Error or ('failed to write ' .. Destination))
        end
    end

    local Success, Error = self:WriteInstalledManifest(Manifest)
    if not Success then return false, tostring(Error) end

    self.InstalledManifest = Manifest
    return true
end

function Updater:EnsureInstalled()
    if not self.Persistent then
        self.RemoteOnly = true
        return true
    end

    EnsureFolder(self.CacheRoot)
    local Installed = self:ReadInstalledManifest()
    local LibraryPath = LocalPath('Library.lua')

    if Installed and isfile(LibraryPath) then
        self.InstalledManifest = Installed
        return true
    end

    -- First run seeds the current release. From the next release onward this
    -- cached copy remains installed until the player presses Yes.
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

    if self.Persistent then
        local Path = LocalPath(RemotePath)
        if isfile(Path) then
            local Success, Source = pcall(readfile, Path)
            if Success and type(Source) == 'string' and Source ~= '' then
                return Source
            end
        end
    end

    return Fetch(RemotePath)
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

function Updater:InstallUpdate(ComponentName, RemoteInfo)
    local Manifest, Error = self:FetchManifest()
    if not Manifest then return false, Error end

    -- Forma releases are installed atomically as one set so Library and all
    -- managers can never end up on mismatched versions after a restart.
    return self:InstallManifest(Manifest)
end

local Ready, Error = Updater:EnsureInstalled()
if not Ready then
    error('Forma updater failed to initialize: ' .. tostring(Error))
end

getgenv().FormaUpdater = Updater

local LibrarySource, LibraryError = Updater:GetSource('Library')
if not LibrarySource then
    error('Forma loader could not load Library: ' .. tostring(LibraryError))
end

local LibraryChunk, CompileError = loadstring(LibrarySource)
if not LibraryChunk then error(CompileError) end

Updater.Library = LibraryChunk()
Updater.Library:SetUpdateRestartSource(Updater.LoaderUrl)

return Updater
