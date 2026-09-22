local httpService = game:GetService('HttpService')
local tweenService = game:GetService('TweenService')
local contentProvider = game:GetService('ContentProvider')
local ThemeManager = {} do
	ThemeManager.Version = '1.9.0+build.1'
	ThemeManager.Folder = 'LinoriaLibSettings'
	-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

	ThemeManager.Library = nil
	ThemeManager.OverlayBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/idfk/'
	ThemeManager.MenuManagerUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/addons/MenuManager.lua'
	ThemeManager.MenuManager = nil
	ThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki', 'Marin Kitagawa', 'Alya' }
	ThemeManager.OverlayVisualInset = Vector2.new(10, 2)
	ThemeManager.OverlayAssets = {
		['EDP445'] = {
			File = 'edp445.png';
			Size = UDim2.fromOffset(300, 303);
			VisibleAnchor = Vector2.new(20 / 280, 162 / 283);
		};
		['Jane Doe'] = {
			File = 'janedoe.png';
			Size = UDim2.fromOffset(300, 300);
			VisibleAnchor = Vector2.new(22 / 280, 192 / 280);
		};
		['Ibuki'] = {
			File = 'ibuki.png';
			Size = UDim2.fromOffset(300, 300);
			VisibleAnchor = Vector2.new(3 / 280, 193 / 280);
		};
		['Marin Kitagawa'] = {
			File = 'marin-kitagawa.png';
			Size = UDim2.fromOffset(300, 300);
			VisibleAnchor = Vector2.new(0.08, 0.842);
		};
		['Alya'] = {
			File = 'alya.png';
			Size = UDim2.fromOffset(300, 300);
			VisibleAnchor = Vector2.new(0.08, 0.82);
		};
	}
	ThemeManager.OverlayEnabled = false
	ThemeManager.OverlaySelection = 'Jane Doe'
	ThemeManager.OverlayImage = nil
	ThemeManager.OverlayBuffer = nil
	ThemeManager.OverlayTween = nil
	ThemeManager.OverlayTweens = {}
	ThemeManager.OverlayAnimationId = 0
	ThemeManager.OverlaySessionId = httpService:GenerateGUID(false)
	ThemeManager.OverlayAssetCache = {}
	ThemeManager.OverlayCachePrepared = false
	ThemeManager.OverlayCacheVersion = 2
	ThemeManager.OverlayWarmupStarted = false
	ThemeManager.PreferencesFileName = 'forma-ui-preferences.json'
	ThemeManager.PreferenceSaveId = 0
	ThemeManager.ThemeFields = {
		{ Key = 'BackgroundColor'; Label = 'Background color' };
		{ Key = 'MainColor'; Label = 'Main color' };
		{ Key = 'AccentColor'; Label = 'Accent color' };
		{ Key = 'BlendShade'; Label = 'Blend Shade' };
		{ Key = 'OutlineColor'; Label = 'Outline color' };
		{ Key = 'FontColor'; Label = 'Font color' };
		{ Key = 'DisabledTextColor'; Label = 'Inactive Text Color' };
		{ Key = 'Contrast'; Label = 'Contrast' };
		{ Key = 'Inline'; Label = 'Inline' };
	}
	ThemeManager.BuiltInThemes = {
		['Default'] = { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"0055ff","BlendShade":"07152f","BackgroundColor":"141414","OutlineColor":"323232","DisabledTextColor":"8f8f8f","Contrast":"242424","Inline":"0c0c0c"}') },
		['BBot'] = { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BlendShade":"21182a","BackgroundColor":"232323","OutlineColor":"141414","DisabledTextColor":"929292","Contrast":"2b2b2b","Inline":"111111"}') },
		['Fatality'] = { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BlendShade":"280d19","BackgroundColor":"191335","OutlineColor":"3c355d","DisabledTextColor":"9a91b8","Contrast":"28214f","Inline":"100c24"}') },
		['Jester'] = { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BlendShade":"2b1119","BackgroundColor":"1c1c1c","OutlineColor":"373737","DisabledTextColor":"989898","Contrast":"2d2d2d","Inline":"111111"}') },
		['Mint'] = { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BlendShade":"0f2a20","BackgroundColor":"1c1c1c","OutlineColor":"373737","DisabledTextColor":"989898","Contrast":"2d2d2d","Inline":"111111"}') },
		['Tokyo Night'] = { 6, httpService:JSONDecode('{"FontColor":"c0caf5","MainColor":"1a1b26","AccentColor":"7aa2f7","BlendShade":"17233d","BackgroundColor":"16161e","OutlineColor":"3b4261","DisabledTextColor":"737aa2","Contrast":"24283b","Inline":"101014"}') },
		['Ubuntu'] = { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BlendShade":"2d160d","BackgroundColor":"323232","OutlineColor":"191919","DisabledTextColor":"a0a0a0","Contrast":"494949","Inline":"222222"}') },
		['Quartz'] = { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BlendShade":"111c22","BackgroundColor":"1d1b26","OutlineColor":"27232f","DisabledTextColor":"9692a6","Contrast":"2b2938","Inline":"121018"}') },
		['Obsidian'] = { 9, httpService:JSONDecode('{"FontColor":"e8ebf2","MainColor":"15171c","AccentColor":"5b8cff","BlendShade":"10192c","BackgroundColor":"0e0f12","OutlineColor":"2a2e36","DisabledTextColor":"858b98","Contrast":"1c1f26","Inline":"090a0c"}') },
		['Nord'] = { 10, httpService:JSONDecode('{"FontColor":"eceff4","MainColor":"3b4252","AccentColor":"88c0d0","BlendShade":"22323a","BackgroundColor":"2e3440","OutlineColor":"4c566a","DisabledTextColor":"a3abb8","Contrast":"434c5e","Inline":"242933"}') },
		['Dracula'] = { 11, httpService:JSONDecode('{"FontColor":"f8f8f2","MainColor":"21222c","AccentColor":"bd93f9","BlendShade":"2a1f38","BackgroundColor":"191a21","OutlineColor":"44475a","DisabledTextColor":"8d91a6","Contrast":"282a36","Inline":"121318"}') },
		['Gruvbox Dark'] = { 12, httpService:JSONDecode('{"FontColor":"ebdbb2","MainColor":"282828","AccentColor":"fe8019","BlendShade":"332313","BackgroundColor":"1d2021","OutlineColor":"504945","DisabledTextColor":"a89984","Contrast":"3c3836","Inline":"141617"}') },
		['Catppuccin Mocha'] = { 13, httpService:JSONDecode('{"FontColor":"cdd6f4","MainColor":"181825","AccentColor":"cba6f7","BlendShade":"2b2038","BackgroundColor":"11111b","OutlineColor":"45475a","DisabledTextColor":"7f849c","Contrast":"1e1e2e","Inline":"0b0b12"}') },
		['Rose Pine'] = { 14, httpService:JSONDecode('{"FontColor":"e0def4","MainColor":"1f1d2e","AccentColor":"c4a7e7","BlendShade":"30243c","BackgroundColor":"191724","OutlineColor":"403d52","DisabledTextColor":"908caa","Contrast":"26233a","Inline":"12101a"}') },
		['Everforest'] = { 15, httpService:JSONDecode('{"FontColor":"d3c6aa","MainColor":"2d353b","AccentColor":"a7c080","BlendShade":"26352a","BackgroundColor":"272e33","OutlineColor":"4f5b58","DisabledTextColor":"859289","Contrast":"343f44","Inline":"1e2326"}') },
		['Cyberpunk'] = { 16, httpService:JSONDecode('{"FontColor":"f2f7ff","MainColor":"11151e","AccentColor":"00f0ff","BlendShade":"082e35","BackgroundColor":"090b10","OutlineColor":"30384a","DisabledTextColor":"8590a3","Contrast":"18202c","Inline":"05070a"}') },
		['Blood Moon'] = { 17, httpService:JSONDecode('{"FontColor":"f6e8e9","MainColor":"1c0f12","AccentColor":"d84a55","BlendShade":"321015","BackgroundColor":"12090b","OutlineColor":"4a252a","DisabledTextColor":"a27a7e","Contrast":"271318","Inline":"0a0506"}') },
		['Emerald'] = { 18, httpService:JSONDecode('{"FontColor":"e7f5ef","MainColor":"14201c","AccentColor":"42d392","BlendShade":"103526","BackgroundColor":"0c1412","OutlineColor":"2d4a40","DisabledTextColor":"7f9f92","Contrast":"1a2a25","Inline":"070c0a"}') },
		['Royal'] = { 19, httpService:JSONDecode('{"FontColor":"f0f3ff","MainColor":"161c30","AccentColor":"6f8cff","BlendShade":"18264a","BackgroundColor":"0e1220","OutlineColor":"354264","DisabledTextColor":"8d97b3","Contrast":"1e2740","Inline":"080b14"}') },
		['Arctic'] = { 20, httpService:JSONDecode('{"FontColor":"eaf6f8","MainColor":"172126","AccentColor":"9adbe8","BlendShade":"183037","BackgroundColor":"10171b","OutlineColor":"32434a","DisabledTextColor":"8ba2a8","Contrast":"1e2b31","Inline":"0a0f12"}') },
		['Midnight'] = { 21, httpService:JSONDecode('{"FontColor":"e8ebff","MainColor":"0f1320","AccentColor":"637dff","BlendShade":"111b3d","BackgroundColor":"080a12","OutlineColor":"29304a","DisabledTextColor":"7d86a5","Contrast":"151a2b","Inline":"05060c"}') },
		['Ash'] = { 22, httpService:JSONDecode('{"FontColor":"f0f0f0","MainColor":"1a1a1a","AccentColor":"a8a8a8","BlendShade":"252525","BackgroundColor":"121212","OutlineColor":"3a3a3a","DisabledTextColor":"8a8a8a","Contrast":"222222","Inline":"0a0a0a"}') },
		['Terminal'] = { 23, httpService:JSONDecode('{"FontColor":"c7ffd3","MainColor":"0a100b","AccentColor":"55ff7a","BlendShade":"0b2a13","BackgroundColor":"050805","OutlineColor":"1f3b27","DisabledTextColor":"65916e","Contrast":"0e1a11","Inline":"020402"}') },
		['AMOLED'] = { 24, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"050505","AccentColor":"4f8cff","BlendShade":"07172c","BackgroundColor":"000000","OutlineColor":"222222","DisabledTextColor":"808080","Contrast":"0d0d0d","Inline":"000000"}') },
		['Synthwave 84'] = { 25, httpService:JSONDecode('{"FontColor":"f8e9ff","MainColor":"1b1530","AccentColor":"ff4ecd","BlendShade":"35112f","BackgroundColor":"100b1f","OutlineColor":"514060","DisabledTextColor":"a887b0","Contrast":"241942","Inline":"090613"}') },
		['Solar Flare'] = { 26, httpService:JSONDecode('{"FontColor":"fff4d6","MainColor":"211a10","AccentColor":"ffb627","BlendShade":"3b2608","BackgroundColor":"120e08","OutlineColor":"51422a","DisabledTextColor":"a49375","Contrast":"2b2113","Inline":"090704"}') },
		['Deep Ocean'] = { 27, httpService:JSONDecode('{"FontColor":"dffcff","MainColor":"10242b","AccentColor":"28c7d8","BlendShade":"0a3138","BackgroundColor":"081419","OutlineColor":"28505a","DisabledTextColor":"749aa1","Contrast":"16323a","Inline":"040b0e"}') },
		['Void Pulse'] = { 28, httpService:JSONDecode('{"FontColor":"f1ebff","MainColor":"151022","AccentColor":"9b5cff","BlendShade":"231044","BackgroundColor":"09070f","OutlineColor":"3c3154","DisabledTextColor":"87799e","Contrast":"1d162d","Inline":"050308"}') },
		['Sakura Neon'] = { 29, httpService:JSONDecode('{"FontColor":"ffeaf4","MainColor":"25131e","AccentColor":"ff6fae","BlendShade":"42152b","BackgroundColor":"140a10","OutlineColor":"563245","DisabledTextColor":"ad8294","Contrast":"311a27","Inline":"0b0508"}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		local scheme = data[2]
		local colors = customThemeData or scheme
		for idx, col in next, colors do
			self.Library[idx] = Color3.fromHex(col)

			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		-- Older custom themes predate Blend Shade. Derive a dark companion from
		-- their accent instead of leaking the shade from whichever theme ran last.
		if colors.AccentColor and not colors.BlendShade then
			local blendShade = Color3.fromHex(colors.AccentColor):Lerp(Color3.new(0, 0, 0), 0.72)
			self.Library.BlendShade = blendShade
			if Options.BlendShade then Options.BlendShade:SetValueRGB(blendShade) end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		for _, entry in ipairs(self.ThemeFields) do
			local field = entry.Key
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.Black = self.Library.Inline
		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
			theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:GetPreferencesPath()
		return self.Folder .. '/settings/' .. self.PreferencesFileName
	end

	function ThemeManager:LoadPreferences()
		local path = self:GetPreferencesPath()
		if not isfile or not readfile or not isfile(path) then return {} end

		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(path))
		end)
		if not success or type(data) ~= 'table' then return {} end
		return data
	end

	function ThemeManager:SavePreferences()
		if not writefile then return false end
		local data = {
			Font = Options and Options.ThemeManager_Font and Options.ThemeManager_Font.Value or self.Library.FontName;
			TextSize = Options and Options.ThemeManager_TextSize and Options.ThemeManager_TextSize.Value or self.Library.TextSize;
			OverlayEnabled = Toggles and Toggles.ThemeManager_OverlayEnabled and Toggles.ThemeManager_OverlayEnabled.Value or self.OverlayEnabled;
			OverlayImage = Options and Options.ThemeManager_OverlayImage and Options.ThemeManager_OverlayImage.Value or self.OverlaySelection;
			Cursor = Options and Options.ThemeManager_Cursor and Options.ThemeManager_Cursor.Value or self.Library.CursorStyle;
		}

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then return false end
		return pcall(writefile, self:GetPreferencesPath(), encoded)
	end

	function ThemeManager:QueueSavePreferences()
		self.PreferenceSaveId = self.PreferenceSaveId + 1
		local SaveId = self.PreferenceSaveId
		task.delay(0.12, function()
			if SaveId == self.PreferenceSaveId then
				self:SavePreferences()
			end
		end)
	end


	function ThemeManager:PrepareOverlayCache()
		if self.OverlayCachePrepared then
			return
		end

		self.OverlayCachePrepared = true

		if not listfiles or not delfile then
			return
		end

		local ok, files = pcall(listfiles, 'FormaAssets/idfk')
		if not ok or type(files) ~= 'table' then
			return
		end

		local currentPrefix = 'forma-overlay-v' .. tostring(self.OverlayCacheVersion) .. '-'
		for _, file in next, files do
			if type(file) == 'string'
				and file:find('forma-overlay-', 1, true)
				and not file:find(currentPrefix, 1, true) then
				pcall(delfile, file)
			end
		end
	end

	function ThemeManager:IsValidOverlayPng(data)
		return type(data) == 'string'
			and #data >= 24
			and data:sub(1, 8) == '\137PNG\r\n\26\n'
			and data:sub(13, 16) == 'IHDR'
	end

	function ThemeManager:GetPngSize(data)
		if not self:IsValidOverlayPng(data) then
			return nil
		end

		local function ReadUInt32BE(index)
			local a, b, c, d = string.byte(data, index, index + 3)
			if not a or not b or not c or not d then
				return nil
			end
			return ((a * 256 + b) * 256 + c) * 256 + d
		end

		local width = ReadUInt32BE(17)
		local height = ReadUInt32BE(21)
		if not width or not height or width <= 0 or height <= 0 then
			return nil
		end

		return Vector2.new(width, height)
	end

	function ThemeManager:GetOverlayAsset(name)
		local info = self.OverlayAssets[name]
		local getCustomAsset = getcustomasset or getsynasset

		if not info or not getCustomAsset or not writefile then
			return nil
		end

		if self.OverlayAssetCache[name] then
			return self.OverlayAssetCache[name]
		end

		if makefolder then
			if not isfolder or not isfolder('FormaAssets') then
				pcall(makefolder, 'FormaAssets')
			end

			if not isfolder or not isfolder('FormaAssets/idfk') then
				pcall(makefolder, 'FormaAssets/idfk')
			end
		end

		self:PrepareOverlayCache()

		local safeFile = info.File:gsub('[^%w%._%-]', '_')
		local localPath = 'FormaAssets/idfk/forma-overlay-v'
			.. tostring(self.OverlayCacheVersion)
			.. '-'
			.. safeFile

		local data
		if isfile and readfile and isfile(localPath) then
			local readOk, cachedData = pcall(readfile, localPath)
			if readOk and self:IsValidOverlayPng(cachedData) then
				data = cachedData
			end
		end

		if not data then
			local url = self.OverlayBaseUrl
				.. info.File
				.. '?v='
				.. tostring(self.OverlayCacheVersion)
				.. '&session='
				.. self.OverlaySessionId
			local ok, downloaded = pcall(function()
				return game:HttpGet(url)
			end)

			if not ok or not self:IsValidOverlayPng(downloaded) then
				return nil
			end

			data = downloaded
			local wrote = pcall(writefile, localPath, data)
			if not wrote then
				return nil
			end
		end

		info.SourceSize = self:GetPngSize(data)

		local assetOk, asset = pcall(getCustomAsset, localPath)
		if not assetOk or not asset then
			return nil
		end

		self.OverlayAssetCache[name] = asset
		return asset
	end

	function ThemeManager:CreateOverlayLabel(holder, name)
		local overlay = self.Library:Create('ImageLabel', {
			Name = name;
			Active = false;
			AnchorPoint = Vector2.new(0, 0);
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = '';
			ImageTransparency = 1;
			ScaleType = Enum.ScaleType.Fit;
			Visible = false;
			ZIndex = 500;
			Parent = holder;
		})

		pcall(function()
			overlay.ResampleMode = Enum.ResamplerMode.Default
		end)

		return overlay
	end

	function ThemeManager:EnsureOverlay()
		local holder = self.Library and self.Library.WindowHolder

		if not holder then
			return nil
		end

		if self.OverlayImage and self.OverlayImage.Parent ~= holder then
			self.OverlayImage:Destroy()
			self.OverlayImage = nil
		end
		if self.OverlayBuffer and self.OverlayBuffer.Parent ~= holder then
			self.OverlayBuffer:Destroy()
			self.OverlayBuffer = nil
		end

		if not self.OverlayImage then
			self.OverlayImage = self:CreateOverlayLabel(holder, 'FormaThemeOverlayA')
		end
		if not self.OverlayBuffer then
			self.OverlayBuffer = self:CreateOverlayLabel(holder, 'FormaThemeOverlayB')
		end

		return self.OverlayImage, self.OverlayBuffer
	end

	function ThemeManager:CancelOverlayTweens()
		for _, tween in ipairs(self.OverlayTweens or {}) do
			pcall(function()
				tween:Cancel()
			end)
		end
		table.clear(self.OverlayTweens)
		self.OverlayTween = nil
	end

	function ThemeManager:GetOverlayPosition(info)
		if info.Position then
			return info.Position
		end

		return UDim2.fromOffset(
			self.OverlayVisualInset.X - (info.Size.X.Offset * info.VisibleAnchor.X),
			self.OverlayVisualInset.Y - (info.Size.Y.Offset * info.VisibleAnchor.Y)
		)
	end

	function ThemeManager:ApplyOverlayLayout(overlay, info)
		overlay.Size = info.Size
		overlay.Position = self:GetOverlayPosition(info)
		overlay.AnchorPoint = Vector2.new(0, 0)
		overlay.ScaleType = Enum.ScaleType.Fit
	end

	function ThemeManager:PreloadOverlay(overlay)
		if not overlay then
			return
		end

		pcall(function()
			contentProvider:PreloadAsync({ overlay })
		end)
	end

	function ThemeManager:TweenOverlayTransparency(target)
		local overlay = self.OverlayImage
		if not overlay then
			return
		end

		self:CancelOverlayTweens()

		local tween = tweenService:Create(
			overlay,
			TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ImageTransparency = target }
		)

		self.OverlayTween = tween
		table.insert(self.OverlayTweens, tween)
		tween:Play()
	end

	function ThemeManager:WarmOverlayAssets()
		if self.OverlayWarmupStarted then
			return
		end

		self.OverlayWarmupStarted = true
		task.spawn(function()
			local preferred = self.OverlaySelection
			if preferred and self.OverlayAssets[preferred] then
				pcall(self.GetOverlayAsset, self, preferred)
			end

			for _, name in ipairs(self.OverlayOrder) do
				if name ~= preferred then
					pcall(self.GetOverlayAsset, self, name)
					task.wait()
				end
			end
		end)
	end

	function ThemeManager:SetOverlayImage(name)
		local info = self.OverlayAssets[name]
		if not info then
			return
		end

		self.OverlaySelection = name
		self.OverlayAnimationId = self.OverlayAnimationId + 1
		local animationId = self.OverlayAnimationId

		local front, buffer = self:EnsureOverlay()
		if not front or not buffer or not self.OverlayEnabled then
			return
		end

		task.spawn(function()
			local asset = self:GetOverlayAsset(name)
			if animationId ~= self.OverlayAnimationId
				or not self.OverlayEnabled
				or not asset then
				return
			end

			front, buffer = self:EnsureOverlay()
			if not front or not buffer then
				return
			end

			self:ApplyOverlayLayout(buffer, info)
			buffer.Image = asset
			buffer.ImageTransparency = 1
			buffer.Visible = true
			self:PreloadOverlay(buffer)

			if animationId ~= self.OverlayAnimationId or not self.OverlayEnabled then
				buffer.Visible = false
				return
			end

			self:CancelOverlayTweens()

			local fadeIn = tweenService:Create(
				buffer,
				TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ImageTransparency = 0 }
			)
			table.insert(self.OverlayTweens, fadeIn)

			local hadFront = front.Visible and front.Image ~= ''
			local fadeOut
			if hadFront then
				fadeOut = tweenService:Create(
					front,
					TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				)
				table.insert(self.OverlayTweens, fadeOut)
				fadeOut:Play()
			end

			fadeIn:Play()
			fadeIn.Completed:Connect(function()
				if animationId ~= self.OverlayAnimationId or not self.OverlayEnabled then
					return
				end

				front.Visible = false
				front.ImageTransparency = 1
				self.OverlayImage = buffer
				self.OverlayBuffer = front
				self.OverlayImage.ImageTransparency = 0
				self.OverlayImage.Visible = true
				self.OverlayTween = nil
				table.clear(self.OverlayTweens)
			end)
		end)
	end

	function ThemeManager:SetOverlayEnabled(enabled)
		self.OverlayEnabled = not not enabled

		if self.OverlayEnabled then
			self:SetOverlayImage(self.OverlaySelection)
			return
		end

		self.OverlayAnimationId = self.OverlayAnimationId + 1
		local animationId = self.OverlayAnimationId
		local front, buffer = self:EnsureOverlay()
		self:CancelOverlayTweens()

		for _, overlay in ipairs({ front, buffer }) do
			if overlay and overlay.Visible then
				local tween = tweenService:Create(
					overlay,
					TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				)
				table.insert(self.OverlayTweens, tween)
				tween:Play()
			end
		end

		task.delay(0.13, function()
			if animationId ~= self.OverlayAnimationId or self.OverlayEnabled then
				return
			end
			for _, overlay in ipairs({ front, buffer }) do
				if overlay then
					overlay.Visible = false
					overlay.ImageTransparency = 1
				end
			end
			table.clear(self.OverlayTweens)
		end)
	end

	function ThemeManager:EnsureMenuManager()
		if not self.Library then
			return nil
		end

		if self.Library.MenuManager then
			self.MenuManager = self.Library.MenuManager
			return self.MenuManager
		end

		if self.MenuManager then
			if self.MenuManager.SetLibrary then
				self.MenuManager:SetLibrary(self.Library)
			end
			return self.MenuManager
		end

		if type(loadstring) ~= 'function' then
			return nil
		end

		local success, manager = pcall(function()
			local env = getgenv and getgenv() or _G
			local updater = env and env.FormaUpdater
			if updater and type(updater.LoadAddon) == 'function' then
				return updater:LoadAddon('MenuManager')
			end

			local source = game:HttpGet(self.MenuManagerUrl)
			local chunk, compileError = loadstring(source)
			if not chunk then
				error(compileError)
			end
			return chunk()
		end)

		if not success or type(manager) ~= 'table' then
			return nil
		end

		self.MenuManager = manager
		if manager.SetLibrary then
			manager:SetLibrary(self.Library)
		else
			self.Library.MenuManager = manager
		end

		return manager
	end

	function ThemeManager:CreateThemeManager(groupbox)
		local SavedPreferences = self:LoadPreferences()
		local PreferredFont = type(SavedPreferences.Font) == 'string' and SavedPreferences.Font or self.Library.FontName
		local PreferredCursor = type(SavedPreferences.Cursor) == 'string' and SavedPreferences.Cursor or self.Library.CursorStyle
		if tonumber(SavedPreferences.TextSize) then
			self.Library:SetTextSize(SavedPreferences.TextSize)
		end
		if type(SavedPreferences.OverlayImage) == 'string' and self.OverlayAssets[SavedPreferences.OverlayImage] then
			self.OverlaySelection = SavedPreferences.OverlayImage
		end
		if type(SavedPreferences.OverlayEnabled) == 'boolean' then
			self.OverlayEnabled = SavedPreferences.OverlayEnabled
		end
		if self.Library.SetCursorStyle then
			self.Library:SetCursorStyle(PreferredCursor)
		end
		self:WarmOverlayAssets()

		for _, entry in ipairs(self.ThemeFields) do
			groupbox:AddLabel(entry.Label):AddColorPicker(entry.Key, { Default = self.Library[entry.Key] });
		end

		local FontNames = self.Library:GetFontNames()
		if not table.find(FontNames, PreferredFont) then PreferredFont = self.Library.FontName end
		self.Library:SetFont(PreferredFont)
		local DefaultFontIndex = table.find(FontNames, PreferredFont) or 1
		groupbox:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = FontNames, Default = DefaultFontIndex, Searchable = true, RequireSelection = true })
		Options.ThemeManager_Font:OnChanged(function()
			self.Library:SetFont(Options.ThemeManager_Font.Value)
			self:QueueSavePreferences()
		end)

		local CursorStyles = self.Library.GetCursorStyles and self.Library:GetCursorStyles() or { 'Arrow', 'Dot', 'System' }
		if not table.find(CursorStyles, PreferredCursor) then PreferredCursor = self.Library.CursorStyle or 'Arrow' end
		groupbox:AddDropdown('ThemeManager_Cursor', {
			Text = 'Cursor';
			Values = CursorStyles;
			Default = table.find(CursorStyles, PreferredCursor) or 1;
			RequireSelection = true;
		})
		Options.ThemeManager_Cursor:OnChanged(function()
			if self.Library.SetCursorStyle then
				self.Library:SetCursorStyle(Options.ThemeManager_Cursor.Value)
			end
			self:QueueSavePreferences()
		end)

		groupbox:AddSlider('ThemeManager_TextSize', {
			Text = 'Text size';
			Default = self.Library.TextSize;
			Min = 9;
			Max = 24;
			Rounding = 0;
			Step = 1;
		})
		Options.ThemeManager_TextSize:OnChanged(function()
			self.Library:SetTextSize(Options.ThemeManager_TextSize.Value)
			self:QueueSavePreferences()
		end)

		groupbox:AddToggle('ThemeManager_OverlayEnabled', { Text = 'UI overlay', Default = self.OverlayEnabled })
		groupbox:AddDropdown('ThemeManager_OverlayImage', {
			Text = 'Overlay image';
			Values = self.OverlayOrder;
			Default = table.find(self.OverlayOrder, self.OverlaySelection) or 2;
			RequireSelection = true;
		})

		Options.ThemeManager_OverlayImage:OnChanged(function()
			self:SetOverlayImage(Options.ThemeManager_OverlayImage.Value)
			self:QueueSavePreferences()
		end)

		Toggles.ThemeManager_OverlayEnabled:OnChanged(function()
			self:SetOverlayEnabled(Toggles.ThemeManager_OverlayEnabled.Value)
			self:QueueSavePreferences()
		end)

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1, Searchable = true, RequireSelection = true })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1, Searchable = true })
		groupbox:AddDivider()

		groupbox:AddButton('Save theme', function()
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function()
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value)
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		for _, entry in ipairs(self.ThemeFields) do
			Options[entry.Key]:OnChanged(UpdateTheme)
		end
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)

		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}

		for _, entry in ipairs(self.ThemeFields) do
			local field = entry.Key
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
		lib.ThemeManager = self
		if lib.RegisterUpdatable then
			lib:RegisterUpdatable('ThemeManager', self.Version, 'addons/ThemeManager.lua')
		end
		task.defer(function()
			if lib.CheckForUpdates then lib:CheckForUpdates('ThemeManager') end
		end)
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		if self.Library.CheckForUpdates then self.Library:CheckForUpdates('ThemeManager') end
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)

		local menuManager = self:EnsureMenuManager()
		if menuManager and menuManager.BuildMenuSection and not Options.MenuManager_EasingStyle then
			menuManager:BuildMenuSection(tab)
		end
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		if self.Library.CheckForUpdates then self.Library:CheckForUpdates('ThemeManager') end
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
