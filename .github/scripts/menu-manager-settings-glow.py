from pathlib import Path

library_path = Path('Library.lua')
theme_path = Path('addons/ThemeManager.lua')

library = library_path.read_text()
theme = theme_path.read_text()

start = library.index('function Library:AddAccentGlow(Instance, Scale)')
end = library.index('function Library:AddTopCorners(Instance, Radius)', start)
new_glow = r'''function Library:AddAccentGlow(Instance, Scale)
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

    local BaseCornerRadius = 3;
    local InstanceCorner = Instance:FindFirstChildOfClass('UICorner');
    if InstanceCorner and InstanceCorner.CornerRadius.Scale == 0 then
        BaseCornerRadius = math.max(InstanceCorner.CornerRadius.Offset, 0);
    end

    local Layers = {
        { 0.4,  2.2, 0.890 },
        { 1.1,  2.4, 0.902 },
        { 1.9,  2.6, 0.916 },
        { 2.8,  2.8, 0.930 },
        { 3.8,  3.0, 0.942 },
        { 4.9,  3.2, 0.952 },
        { 6.1,  3.4, 0.961 },
        { 7.4,  3.6, 0.969 },
        { 8.8,  3.8, 0.976 },
        { 10.3, 4.0, 0.982 },
        { 11.9, 4.2, 0.987 },
        { 13.6, 4.4, 0.991 },
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

        Library:AddCorner(Layer, BaseCornerRadius + Spread);

        local Stroke = Library:Create('UIStroke', {
            Name = 'GlowStroke';
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            Color = Library.AccentColor;
            LineJoinMode = Enum.LineJoinMode.Round;
            Thickness = Thickness;
            Transparency = Info[3];
            Parent = Layer;
        });

        Library:AddToRegistry(Stroke, {
            Color = 'AccentColor';
        });
    end;
end;

'''
library = library[:start] + new_glow + library[end:]

if "ThemeManager.MenuManagerUrl" not in theme:
    marker = "\tThemeManager.OverlayBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/idfk/'\n"
    replacement = marker + "\tThemeManager.MenuManagerUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/addons/MenuManager.lua'\n\tThemeManager.MenuManager = nil\n"
    if marker not in theme:
        raise SystemExit('ThemeManager overlay URL marker missing')
    theme = theme.replace(marker, replacement, 1)

if 'function ThemeManager:EnsureMenuManager()' not in theme:
    marker = "\tfunction ThemeManager:CreateThemeManager(groupbox)\n"
    ensure = r'''	function ThemeManager:EnsureMenuManager()
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

'''
    if marker not in theme:
        raise SystemExit('CreateThemeManager marker missing')
    theme = theme.replace(marker, ensure + marker, 1)

controls_marker = "\t\tToggles.ThemeManager_OverlayEnabled:OnChanged(function()\n\t\t\tself:SetOverlayEnabled(Toggles.ThemeManager_OverlayEnabled.Value)\n\t\tend)\n\n"
controls = controls_marker + r'''		local menuManager = self:EnsureMenuManager()
		if menuManager and menuManager.CreateMenuManager and not Options.MenuManager_EasingStyle then
			groupbox:AddDivider()
			groupbox:AddLabel('Menu manager')
			menuManager:CreateMenuManager(groupbox)
		end

'''
if "groupbox:AddLabel('Menu manager')" not in theme:
    if controls_marker not in theme:
        raise SystemExit('overlay callback marker missing')
    theme = theme.replace(controls_marker, controls, 1)

library_path.write_text(library)
theme_path.write_text(theme)
