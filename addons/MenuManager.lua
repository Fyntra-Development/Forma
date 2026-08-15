local TweenService = game:GetService('TweenService')

local MenuManager = {} do
	MenuManager.Library = nil
	MenuManager.EasingStyle = 'Sine'
	MenuManager.EasingDirection = 'Out'
	MenuManager.TweenSpeed = 0.18
	MenuManager.DefaultTweenSpeed = 0.18

	MenuManager.EasingStyles = {
		'Linear', 'Sine', 'Quad', 'Cubic', 'Quart', 'Quint', 'Exponential', 'Circular', 'Back', 'Elastic', 'Bounce'
	}
	MenuManager.EasingDirections = { 'In', 'Out', 'InOut' }

	-- Each native easing curve needs a slightly different amount of time to
	-- read cleanly. In particular, Elastic and Bounce need room to settle while
	-- Linear needs to finish quickly so that it does not feel heavy.
	MenuManager.StyleProfiles = {
		Linear = { Scale = 0.72; Min = 0.07; Max = 0.26; Overshoot = 0; };
		Sine = { Scale = 0.94; Min = 0.08; Max = 0.34; Overshoot = 0; };
		Quad = { Scale = 0.90; Min = 0.08; Max = 0.34; Overshoot = 0; };
		Cubic = { Scale = 0.88; Min = 0.08; Max = 0.34; Overshoot = 0; };
		Quart = { Scale = 0.86; Min = 0.08; Max = 0.34; Overshoot = 0; };
		Quint = { Scale = 0.84; Min = 0.08; Max = 0.34; Overshoot = 0; };
		Exponential = { Scale = 0.82; Min = 0.08; Max = 0.36; Overshoot = 0; };
		Circular = { Scale = 0.92; Min = 0.09; Max = 0.38; Overshoot = 0; };
		Back = { Scale = 1.04; Min = 0.12; Max = 0.42; Overshoot = 0.12; };
		Elastic = { Scale = 1.42; Min = 0.22; Max = 0.52; Overshoot = 0.16; };
		Bounce = { Scale = 1.24; Min = 0.18; Max = 0.46; Overshoot = 0; };
	}

	-- Transparency, colors, continuous values, and direct manipulation must not
	-- overshoot. Spatial motion still uses the selected style, so every easing
	-- option remains visible without making fades plateau at their clamped ends.
	MenuManager.ContextProfiles = {
		Fade = { Style = 'Sine'; Direction = 'Out'; Scale = 1; Min = 0.10; Max = 0.34; };
		Color = { Style = 'Sine'; Direction = 'Out'; Scale = 0.72; Min = 0.07; Max = 0.22; };
		Layout = { Style = 'Quart'; Direction = 'Out'; Scale = 0.92; Min = 0.09; Max = 0.30; };
		Slider = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.68; Min = 0.07; Max = 0.18; };
		Health = { Style = 'Sine'; Direction = 'Out'; Scale = 0.96; Min = 0.10; Max = 0.30; };
		DragRelease = { Style = 'Sine'; Direction = 'Out'; Scale = 0.62; Min = 0.045; Max = 0.10; };
		Tab = { Style = 'Quint'; Direction = 'Out'; Scale = 1; Min = 0.16; Max = 0.32; };
		TabExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.92; Min = 0.12; Max = 0.24; };
		TabIndicator = { Style = 'Quart'; Direction = 'Out'; Scale = 0.94; Min = 0.12; Max = 0.28; };
		Picker = { Style = 'Quart'; Direction = 'Out'; Scale = 1; Min = 0.14; Max = 0.34; };
		Dropdown = { Style = 'Quart'; Direction = 'Out'; Scale = 1; Min = 0.14; Max = 0.34; };
		Popup = { Style = 'Quart'; Direction = 'Out'; Scale = 1; Min = 0.14; Max = 0.34; };
		PopupExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.9; Min = 0.11; Max = 0.24; };
		Tooltip = { Style = 'Quart'; Direction = 'Out'; Scale = 0.94; Min = 0.11; Max = 0.22; };
		Notification = { Style = 'Quint'; Direction = 'Out'; Scale = 1; Min = 0.16; Max = 0.32; };
		NotificationExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.13; Max = 0.26; };
		Menu = { Style = 'Quint'; Direction = 'Out'; Scale = 1; Min = 0.18; Max = 0.36; };
		MenuExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.14; Max = 0.28; };
		HUD = { Style = 'Quart'; Direction = 'Out'; Scale = 1; Min = 0.17; Max = 0.34; };
		HUDExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.13; Max = 0.26; };
		Press = { Style = 'Quad'; Direction = 'Out'; Scale = 0.72; Min = 0.055; Max = 0.12; };
		Release = { Style = 'Back'; Direction = 'Out'; Scale = 0.82; Min = 0.10; Max = 0.20; };
		Toggle = { Style = 'Back'; Direction = 'Out'; Scale = 0.82; Min = 0.12; Max = 0.22; };
	}

	MenuManager.DirectionScales = {
		In = 0.82;
		Out = 1;
		InOut = 1.06;
	}

	local function FindIndex(List, Value)
		for Index, Item in ipairs(List) do
			if Item == Value then
				return Index
			end
		end
		return 1
	end

	function MenuManager:GetEasingStyle()
		return Enum.EasingStyle[self.EasingStyle] or Enum.EasingStyle.Sine
	end

	function MenuManager:GetEasingDirection()
		return Enum.EasingDirection[self.EasingDirection] or Enum.EasingDirection.Out
	end

	function MenuManager:GetMotionProfile(Context)
		local ContextProfile = self.ContextProfiles[Context] or {}
		local StyleName = ContextProfile.Style or self.EasingStyle
		local DirectionName = ContextProfile.Direction or self.EasingDirection
		local StyleProfile = self.StyleProfiles[StyleName] or self.StyleProfiles.Sine

		return {
			StyleName = StyleName;
			DirectionName = DirectionName;
			Style = Enum.EasingStyle[StyleName] or Enum.EasingStyle.Sine;
			Direction = Enum.EasingDirection[DirectionName] or Enum.EasingDirection.Out;
			Scale = (StyleProfile.Scale or 1) * (ContextProfile.Scale or 1) * (self.DirectionScales[DirectionName] or 1);
			Min = ContextProfile.Min or StyleProfile.Min or 0.06;
			Max = ContextProfile.Max or StyleProfile.Max or 0.45;
			Overshoot = StyleProfile.Overshoot or 0;
		}
	end

	function MenuManager:GetEasedAlpha(Alpha, Context)
		local T = math.clamp(tonumber(Alpha) or 0, 0, 1)
		if T <= 0 then return 0 end
		if T >= 1 then return 1 end
		local Profile = self:GetMotionProfile(Context)

		local Success, Raw = pcall(
			TweenService.GetValue,
			TweenService,
			T,
			Profile.Style,
			Profile.Direction
		)
		if not Success or type(Raw) ~= 'number' then return T end
		return math.clamp(Raw, -Profile.Overshoot, 1 + Profile.Overshoot)
	end

	function MenuManager:GetDuration(Duration, Context)
		local Base = math.clamp(tonumber(self.TweenSpeed) or self.DefaultTweenSpeed, 0.08, 0.45)
		local Requested = tonumber(Duration)
		local Profile = self:GetMotionProfile(Context)
		local GlobalScale = Base / self.DefaultTweenSpeed
		local Effective = (Requested or self.DefaultTweenSpeed) * GlobalScale * Profile.Scale
		return math.clamp(Effective, Profile.Min, Profile.Max)
	end

	function MenuManager:GetTweenInfo(Duration, Context)
		local Profile = self:GetMotionProfile(Context)
		return TweenInfo.new(self:GetDuration(Duration, Context), Profile.Style, Profile.Direction)
	end

	function MenuManager:GetDragResponse()
		-- Kept for backwards compatibility. Dragging itself is now direct and only
		-- the final sub-frame correction is eased.
		return 1
	end

	function MenuManager:GetReleaseDuration(Distance)
		local Travel = math.clamp(tonumber(Distance) or 0, 0, 48)
		return self:GetDuration(0.055 + (Travel / 1600), 'DragRelease')
	end

	function MenuManager:SetLibrary(Library)
		self.Library = Library
		Library.MenuManager = self
	end

	function MenuManager:SetEasingStyle(Value)
		if Enum.EasingStyle[Value] then self.EasingStyle = Value end
	end

	function MenuManager:SetEasingDirection(Value)
		if Enum.EasingDirection[Value] then self.EasingDirection = Value end
	end

	function MenuManager:SetTweenSpeed(Value)
		self.TweenSpeed = math.clamp(tonumber(Value) or self.DefaultTweenSpeed, 0.08, 0.45)
	end

	function MenuManager:ResetMenuPositions()
		if self.Library and self.Library.ResetMenuPositions then self.Library:ResetMenuPositions(true) end
	end

	function MenuManager:CreateMenuManager(Groupbox)
		assert(self.Library, 'Must set MenuManager.Library')
		Groupbox:AddDropdown('MenuManager_EasingStyle', { Text = 'Easing style'; Values = self.EasingStyles; Default = FindIndex(self.EasingStyles, self.EasingStyle); })
		Options.MenuManager_EasingStyle:OnChanged(function() self:SetEasingStyle(Options.MenuManager_EasingStyle.Value) end)
		Groupbox:AddDropdown('MenuManager_EasingDirection', { Text = 'Easing direction'; Values = self.EasingDirections; Default = FindIndex(self.EasingDirections, self.EasingDirection); })
		Options.MenuManager_EasingDirection:OnChanged(function() self:SetEasingDirection(Options.MenuManager_EasingDirection.Value) end)
		Groupbox:AddSlider('MenuManager_TweenSpeed', { Text = 'Animation response'; Default = self.TweenSpeed; Min = 0.08; Max = 0.45; Rounding = 2; Step = 0.01; Suffix = 's'; })
		Options.MenuManager_TweenSpeed:OnChanged(function() self:SetTweenSpeed(Options.MenuManager_TweenSpeed.Value) end)
		Groupbox:AddButton('Reset menu positions', function() self:ResetMenuPositions() end)
	end

	function MenuManager:BuildMenuSection(Tab)
		assert(self.Library, 'Must set MenuManager.Library')
		local Section = Tab:AddRightGroupbox('Menu manager')
		self:CreateMenuManager(Section)
		return Section
	end
end

return MenuManager
