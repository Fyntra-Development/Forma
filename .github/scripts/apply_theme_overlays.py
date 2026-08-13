from pathlib import Path
import base64
import hashlib
import struct

ROOT = Path('.')

assets = {
    'edp445.png': {
        'chunks': [ROOT / '.github/tmp/idfk320/edp445.png.b64'],
        'sha256': '1bcd41916c71568a41472bc62c4371db5a0043872af531205b448d143a2772fb',
        'size': (280, 283),
    },
    'janedoe.png': {
        'chunks': [ROOT / '.github/tmp/idfk320/janedoe.png.b64'],
        'sha256': '79d37fc236beb884ff96f275b1859645350e88ca09db27dc65245b110005449e',
        'size': (280, 280),
    },
    'ibuki.png': {
        'chunks': [
            ROOT / '.github/tmp/idfk320/ibuki.png.b64.001',
            ROOT / '.github/tmp/idfk320/ibuki.png.b64.002',
        ],
        'sha256': 'f2eed0a2f02cb5d0f65a788541a5471b23836586d4e3b4f8ebafbdc7c2956f75',
        'size': (280, 280),
    },
}

asset_dir = ROOT / 'assets/idfk'
asset_dir.mkdir(parents=True, exist_ok=True)

for name, info in assets.items():
    encoded = ''.join(path.read_text().strip() for path in info['chunks'])
    data = base64.b64decode(encoded, validate=True)
    assert data[:8] == b'\x89PNG\r\n\x1a\n', f'{name}: not a PNG'
    digest = hashlib.sha256(data).hexdigest()
    assert digest == info['sha256'], f'{name}: sha mismatch {digest}'
    width, height = struct.unpack('>II', data[16:24])
    assert (width, height) == info['size'], f'{name}: unexpected size {(width, height)}'
    (asset_dir / name).write_bytes(data)

library_path = ROOT / 'Library.lua'
library = library_path.read_text()
old_holder = "    Window.Holder = Outer;\n\n    return Window;"
new_holder = "    Window.Holder = Outer;\n    Library.WindowHolder = Outer;\n\n    return Window;"
assert library.count(old_holder) == 1, 'Library window holder marker changed'
library = library.replace(old_holder, new_holder, 1)
library_path.write_text(library)

theme_path = ROOT / 'addons/ThemeManager.lua'
theme = theme_path.read_text()

service_marker = "local httpService = game:GetService('HttpService')\n"
assert theme.count(service_marker) == 1, 'HttpService marker changed'
theme = theme.replace(
    service_marker,
    service_marker + "local tweenService = game:GetService('TweenService')\n",
    1,
)

library_marker = "\tThemeManager.Library = nil\n"
assert theme.count(library_marker) == 1, 'ThemeManager.Library marker changed'
overlay_fields = """\tThemeManager.Library = nil
\tThemeManager.OverlayBaseUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/idfk/'
\tThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki' }
\tThemeManager.OverlayAssets = {
\t\t['EDP445'] = {
\t\t\tFile = 'edp445.png';
\t\t\tSize = UDim2.fromOffset(300, 303);
\t\t\tPosition = UDim2.fromOffset(10, -160);
\t\t};
\t\t['Jane Doe'] = {
\t\t\tFile = 'janedoe.png';
\t\t\tSize = UDim2.fromOffset(300, 300);
\t\t\tPosition = UDim2.fromOffset(0, -190);
\t\t};
\t\t['Ibuki'] = {
\t\t\tFile = 'ibuki.png';
\t\t\tSize = UDim2.fromOffset(300, 300);
\t\t\tPosition = UDim2.fromOffset(0, -190);
\t\t};
\t}
\tThemeManager.OverlayEnabled = false
\tThemeManager.OverlaySelection = 'Jane Doe'
\tThemeManager.OverlayImage = nil
\tThemeManager.OverlayTween = nil
\tThemeManager.OverlayAnimationId = 0
"""
theme = theme.replace(library_marker, overlay_fields, 1)

create_marker = "\tfunction ThemeManager:CreateThemeManager(groupbox)\n"
assert theme.count(create_marker) == 1, 'CreateThemeManager marker changed'
methods = r"""
	function ThemeManager:GetOverlayAsset(name)
		local info = self.OverlayAssets[name]
		local getCustomAsset = getcustomasset or getsynasset

		if not info or not getCustomAsset or not writefile then
			return nil
		end

		if makefolder then
			if not isfolder or not isfolder('FormaAssets') then
				pcall(makefolder, 'FormaAssets')
			end

			if not isfolder or not isfolder('FormaAssets/idfk') then
				pcall(makefolder, 'FormaAssets/idfk')
			end
		end

		local localPath = 'FormaAssets/idfk/' .. info.File
		local needsDownload = true

		if isfile then
			local ok, exists = pcall(isfile, localPath)
			needsDownload = not (ok and exists)
		end

		if needsDownload then
			local ok, data = pcall(function()
				return game:HttpGet(self.OverlayBaseUrl .. info.File)
			end)

			if not ok or type(data) ~= 'string' or #data == 0 then
				return nil
			end

			local wrote = pcall(writefile, localPath, data)
			if not wrote then
				return nil
			end
		end

		local ok, asset = pcall(getCustomAsset, localPath)
		return ok and asset or nil
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
				BackgroundTransparency = 1;
				BorderSizePixel = 0;
				Image = '';
				ImageTransparency = 1;
				ScaleType = Enum.ScaleType.Fit;
				Visible = false;
				ZIndex = 500;
				Parent = holder;
			})
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
		end

		local tween = tweenService:Create(
			overlay,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ImageTransparency = target }
		)

		self.OverlayTween = tween
		tween:Play()

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
		overlay.Position = info.Position

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

"""
theme = theme.replace(create_marker, methods + create_marker, 1)

font_marker = """\t\tOptions.ThemeManager_Font:OnChanged(function()
\t\t\tself.Library:SetFont(Options.ThemeManager_Font.Value)
\t\tend)

"""
assert theme.count(font_marker) == 1, 'font callback marker changed'
overlay_controls = font_marker + """\t\tgroupbox:AddToggle('ThemeManager_OverlayEnabled', { Text = 'UI overlay', Default = false })
\t\tgroupbox:AddDropdown('ThemeManager_OverlayImage', { Text = 'Overlay image', Values = self.OverlayOrder, Default = 2 })

\t\tOptions.ThemeManager_OverlayImage:OnChanged(function()
\t\t\tself:SetOverlayImage(Options.ThemeManager_OverlayImage.Value)
\t\tend)

\t\tToggles.ThemeManager_OverlayEnabled:OnChanged(function()
\t\t\tself:SetOverlayEnabled(Toggles.ThemeManager_OverlayEnabled.Value)
\t\tend)

"""
theme = theme.replace(font_marker, overlay_controls, 1)

theme_path.write_text(theme)

assert "Library.WindowHolder = Outer;" in library_path.read_text()
final_theme = theme_path.read_text()
for token in [
    "ThemeManager.OverlayOrder = { 'EDP445', 'Jane Doe', 'Ibuki' }",
    "function ThemeManager:SetOverlayEnabled(enabled)",
    "function ThemeManager:SetOverlayImage(name)",
    "Name = 'FormaThemeOverlay';",
    "Default = false",
    "Text = 'Overlay image'",
]:
    assert token in final_theme, token

print('overlay patch verified')
