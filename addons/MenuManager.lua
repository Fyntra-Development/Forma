local TweenService = game:GetService('TweenService')

local MenuManager = {} do
	MenuManager.Library = nil
	MenuManager.EasingStyle = 'Cubic'
	MenuManager.EasingDirection = 'Out'
	MenuManager.TweenSpeed = 0.16
	MenuManager.DefaultTweenSpeed = 0.16

	MenuManager.EasingStyles = {
		'Linear', 'Sine', 'Quad', 'Cubic', 'Quart', 'Quint', 'Exponential', 'Circular', 'Back', 'Elastic', 'Bounce'
	}
	MenuManager.EasingDirections = { 'In', 'Out', 'InOut' }

	local function FindIndex(List, Value)
		for Index, Item in ipairs(List) do
			if Item == Value then
				return Index
			end
		end
		return 1
	end

	function MenuManager:GetEasingStyle()
		return Enum.EasingStyle[self.EasingStyle] or Enum.EasingStyle.Cubic
	end

	function MenuManager:GetEasingDirection()
		return Enum.EasingDirection[self.EasingDirection] or Enum.EasingDirection.Out
	end

	function MenuManager:GetEasedAlpha(Alpha, Context)
		local T = math.clamp(tonumber(Alpha) or 0, 0, 1)
		if T <= 0 then return 0 end
		if T >= 1 then return 1 end

		local Success, Raw = pcall(
			TweenService.GetValue,
			TweenService,
			T,
			self:GetEasingStyle(),
			self:GetEasingDirection()
		)
		return Success and type(Raw) == 'number' and math.clamp(Raw, -0.2, 1.2) or T
	end

	function MenuManager:GetDuration(Duration)
		local Base = math.clamp(tonumber(self.TweenSpeed) or self.DefaultTweenSpeed, 0.05, 0.6)
		local Requested = tonumber(Duration)
		if not Requested then return Base end

		-- TweenSpeed is a global response control. Explicit component timings keep
		-- their proportions while the whole interface speeds up or slows down.
		local Scale = Base / self.DefaultTweenSpeed
		return math.clamp(Requested * Scale, 0.035, 1.2)
	end

	function MenuManager:GetTweenInfo(Duration, Context)
		return TweenInfo.new(self:GetDuration(Duration), self:GetEasingStyle(), self:GetEasingDirection())
	end

	function MenuManager:GetDragResponse()
		local Scale = self:GetDuration(self.DefaultTweenSpeed) / self.DefaultTweenSpeed
		return math.clamp(44 / math.max(Scale, 0.2), 24, 72)
	end

	function MenuManager:GetReleaseDuration(Distance)
		local Travel = math.clamp(tonumber(Distance) or 0, 0, 120)
		return self:GetDuration(0.09 + (Travel / 1200))
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
		self.TweenSpeed = math.clamp(tonumber(Value) or self.DefaultTweenSpeed, 0.05, 0.6)
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
		Groupbox:AddSlider('MenuManager_TweenSpeed', { Text = 'Animation response'; Default = self.TweenSpeed; Min = 0.05; Max = 0.6; Rounding = 2; Step = 0.01; Suffix = 's'; })
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
