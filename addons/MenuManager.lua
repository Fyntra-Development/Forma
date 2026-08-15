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

	-- Normalize the native curves so each option completes cleanly instead of
	-- being squeezed into the same duration. Curves with a settling phase get
	-- enough time to finish; direct curves stay short and responsive.
	MenuManager.StyleProfiles = {
		Linear = { Scale = 0.78; Min = 0.09; Max = 0.30; Overshoot = 0; };
		Sine = { Scale = 1.00; Min = 0.10; Max = 0.38; Overshoot = 0; };
		Quad = { Scale = 0.96; Min = 0.10; Max = 0.38; Overshoot = 0; };
		Cubic = { Scale = 0.94; Min = 0.10; Max = 0.38; Overshoot = 0; };
		Quart = { Scale = 0.92; Min = 0.10; Max = 0.38; Overshoot = 0; };
		Quint = { Scale = 0.90; Min = 0.10; Max = 0.38; Overshoot = 0; };
		Exponential = { Scale = 0.90; Min = 0.11; Max = 0.42; Overshoot = 0; };
		Circular = { Scale = 0.98; Min = 0.12; Max = 0.44; Overshoot = 0; };
		Back = { Scale = 1.08; Min = 0.16; Max = 0.48; Overshoot = 0.10; };
		Elastic = { Scale = 1.70; Min = 0.42; Max = 0.85; Overshoot = 0.18; };
		Bounce = { Scale = 1.42; Min = 0.32; Max = 0.68; Overshoot = 0; };
	}

	-- Transparency, colors, continuous values, and direct manipulation must not
	-- overshoot. Spatial motion still uses the selected style, so every easing
	-- option remains visible without making fades plateau at their clamped ends.
	MenuManager.ContextProfiles = {
		Fade = { Style = 'Sine'; Direction = 'Out'; Scale = 1.00; Min = 0.14; Max = 0.34; };
		Color = { Style = 'Sine'; Direction = 'Out'; Scale = 0.72; Min = 0.08; Max = 0.18; };
		Layout = { Style = 'Quart'; Direction = 'Out'; Scale = 0.94; Min = 0.11; Max = 0.30; };
		Dependency = { Style = 'Quart'; Direction = 'Out'; Scale = 0.90; Min = 0.11; Max = 0.24; };
		Slider = { Style = 'Quart'; Direction = 'Out'; Scale = 0.72; Min = 0.09; Max = 0.18; };
		Badge = { Style = 'Quart'; Direction = 'Out'; Scale = 0.88; Min = 0.10; Max = 0.22; };
		Health = { Style = 'Sine'; Direction = 'Out'; Scale = 0.96; Min = 0.11; Max = 0.30; };
		DragRelease = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.78; Min = 0.07; Max = 0.14; };
		Tab = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.04; Min = 0.21; Max = 0.34; };
		TabExit = { Style = 'Sine'; Direction = 'InOut'; Scale = 0.98; Min = 0.16; Max = 0.25; };
		TabIndicator = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.98; Min = 0.13; Max = 0.27; };
		Picker = { Style = 'Quart'; Direction = 'Out'; Scale = 1.00; Min = 0.17; Max = 0.30; };
		Dropdown = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.00; Min = 0.16; Max = 0.28; };
		DropdownSearch = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.00; Min = 0.15; Max = 0.25; };
		PopupExit = { Style = 'Sine'; Direction = 'InOut'; Scale = 0.96; Min = 0.15; Max = 0.24; };
		Tooltip = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.00; Min = 0.17; Max = 0.28; };
		Notification = { Style = 'Quint'; Direction = 'Out'; Scale = 1.00; Min = 0.17; Max = 0.30; };
		NotificationExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.13; Max = 0.24; };
		Menu = { Style = 'Quint'; Direction = 'Out'; Scale = 1.00; Min = 0.19; Max = 0.34; };
		MenuExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.14; Max = 0.26; };
		HUD = { Style = 'Quart'; Direction = 'Out'; Scale = 1.00; Min = 0.18; Max = 0.32; };
		HUDExit = { Style = 'Cubic'; Direction = 'InOut'; Scale = 0.94; Min = 0.13; Max = 0.24; };
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
		-- Exponential response (per second) used by direct-manipulation surfaces.
		-- 34 is responsive at high refresh rates while filtering cursor stair-steps.
		return 34
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
