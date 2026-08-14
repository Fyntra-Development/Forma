local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

	ThemeManager.Library = nil
	ThemeManager.OverlayBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/idfk/'
	ThemeManager.MenuManagerUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/addons/MenuManager.lua'
	ThemeManager.MenuManager = nil
	ThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki', 'Marin Kitagawa' }
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
	}
	ThemeManager.OverlayEnabled = false
	ThemeManager.OverlaySelection = 'Jane Doe'
	ThemeManager.OverlayImage = nil
	ThemeManager.OverlayTween = nil
	ThemeManager.OverlayAnimationId = 0
	ThemeManager.OverlaySessionId = httpService:GenerateGUID(false)
	ThemeManager.OverlayAssetCache = {}
	ThemeManager.OverlayCachePrepared = false
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"d6d8d5","MainColor":"111312","AccentColor":"5d5d93","BackgroundColor":"0c0f0e","OutlineColor":"242726"}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		-- Secondary surfaces are deliberately derived instead of adding more theme
		-- controls, so old custom themes inherit the compact reference hierarchy.
		self.Library.HeaderColor = self.Library.MainColor:Lerp(self.Library.FontColor, 0.006)
		self.Library.SurfaceColor = self.Library.MainColor:Lerp(self.Library.FontColor, 0.015)
		self.Library.MutedFontColor = self.Library.FontColor:Lerp(self.Library.BackgroundColor, 0.45)
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

		for _, file in next, files do
			if type(file) == 'string' and file:find('forma-overlay-', 1, true) then
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

		local url = self.OverlayBaseUrl .. info.File .. '?v=' .. self.OverlaySessionId
		local ok, data = pcall(function()
			return game:HttpGet(url)
		end)

		if not ok or not self:IsValidOverlayPng(data) then
			return nil
		end

		info.SourceSize = self:GetPngSize(data)

		local safeFile = info.File:gsub('[^%w%._%-]', '_')
		local localPath = 'FormaAssets/idfk/forma-overlay-' .. self.OverlaySessionId .. '-' .. safeFile
		local wrote = pcall(writefile, localPath, data)
		if not wrote then
			return nil
		end

		local assetOk, asset = pcall(getCustomAsset, localPath)
		if not assetOk or not asset then
			return nil
		end

		self.OverlayAssetCache[name] = asset
		return asset
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

		if not self.OverlayImage then
			self.OverlayImage = self.Library:Create('ImageLabel', {
				Name = 'FormaThemeOverlay';
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
				self.OverlayImage.ResampleMode = Enum.ResamplerMode.Default
			end)
		end

		return self.OverlayImage
	end

	function ThemeManager:TweenOverlayTransparency(target)
		local overlay = self.OverlayImage
		if not overlay then
			return
		end

		self.OverlayAnimationId = self.OverlayAnimationId + 1
		local animationId = self.OverlayAnimationId

		if self.OverlayTween then
			pcall(function()
				self.OverlayTween:Cancel()
			end)
			self.OverlayTween = nil
		end

		local tween = self.Library:Animate(
			overlay,
			{ ImageTransparency = target },
			0.14,
			nil,
			'ThemeOverlay'
		)
		if not tween then
			overlay.ImageTransparency = target
			if target >= 1 and not self.OverlayEnabled then overlay.Visible = false end
			return
		end

		self.OverlayTween = tween

		tween.Completed:Connect(function()
			if animationId ~= self.OverlayAnimationId then
				return
			end

			if target >= 1 and not self.OverlayEnabled then
				overlay.Visible = false
			end

			if self.OverlayTween == tween then
				self.OverlayTween = nil
			end
		end)
	end

	function ThemeManager:GetOverlayPosition(info)
		return UDim2.fromOffset(
			self.OverlayVisualInset.X - (info.Size.X.Offset * info.VisibleAnchor.X),
			self.OverlayVisualInset.Y - (info.Size.Y.Offset * info.VisibleAnchor.Y)
		)
	end

	function ThemeManager:SetOverlayImage(name)
		local info = self.OverlayAssets[name]
		if not info then
			return
		end

		self.OverlaySelection = name

		local overlay = self:EnsureOverlay()
		if not overlay then
			return
		end

		overlay.Size = info.Size
		overlay.Position = self:GetOverlayPosition(info)

		if not self.OverlayEnabled then
			overlay.Visible = false
			return
		end

		local asset = self:GetOverlayAsset(name)
		if not asset then
			overlay.Visible = false
			return
		end

		overlay.Image = asset
		overlay.ImageTransparency = 1
		overlay.Visible = true
		self:TweenOverlayTransparency(0)
	end

	function ThemeManager:SetOverlayEnabled(enabled)
		self.OverlayEnabled = not not enabled

		local overlay = self:EnsureOverlay()
		if not overlay then
			return
		end

		if self.OverlayEnabled then
			self:SetOverlayImage(self.OverlaySelection)
		elseif overlay.Visible then
			self:TweenOverlayTransparency(1)
		else
			overlay.Visible = false
		end
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
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });


		local FontNames = self.Library:GetFontNames()
		local DefaultFontIndex = table.find(FontNames, self.Library.FontName) or 1
		groupbox:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = FontNames, Default = DefaultFontIndex, Searchable = true })
		Options.ThemeManager_Font:OnChanged(function()
			self.Library:SetFont(Options.ThemeManager_Font.Value)
		end)

		groupbox:AddSlider('ThemeManager_TextSize', {
			Text = 'Text size';
			Default = self.Library.TextSize or 13;
			Min = 9;
			Max = 24;
			Rounding = 0;
			Step = 1;
		})
		Options.ThemeManager_TextSize:OnChanged(function()
			self.Library:SetTextSize(Options.ThemeManager_TextSize.Value)
		end)

		groupbox:AddToggle('ThemeManager_OverlayEnabled', { Text = 'UI overlay', Default = false })
		groupbox:AddDropdown('ThemeManager_OverlayImage', { Text = 'Overlay image', Values = self.OverlayOrder, Default = 2 })

		Options.ThemeManager_OverlayImage:OnChanged(function()
			self:SetOverlayImage(Options.ThemeManager_OverlayImage.Value)
		end)

		Toggles.ThemeManager_OverlayEnabled:OnChanged(function()
			self:SetOverlayEnabled(Toggles.ThemeManager_OverlayEnabled.Value)
		end)

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1, Searchable = true })

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

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
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
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
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
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)

		local menuManager = self:EnsureMenuManager()
		if menuManager and menuManager.BuildMenuSection and not Options.MenuManager_EasingStyle then
			menuManager:BuildMenuSection(tab)
		end
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
