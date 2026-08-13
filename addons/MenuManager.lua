local MenuManager = {} do
	MenuManager.Library = nil
	MenuManager.EasingStyle = 'Quint'
	MenuManager.EasingDirection = 'Out'
	MenuManager.TweenSpeed = 0.24

	MenuManager.EasingStyles = {
		'Linear', 'Sine', 'Quad', 'Cubic', 'Quart', 'Quint', 'Exponential', 'Circular', 'Back'
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
		return Enum.EasingStyle[self.EasingStyle] or Enum.EasingStyle.Quint
	end

	function MenuManager:GetEasingDirection()
		return Enum.EasingDirection[self.EasingDirection] or Enum.EasingDirection.Out
	end

	function MenuManager:GetTweenInfo(Duration)
		return TweenInfo.new(
			math.max(tonumber(Duration) or self.TweenSpeed or 0.24, 0.01),
			self:GetEasingStyle(),
			self:GetEasingDirection()
		)
	end

	function MenuManager:SetLibrary(Library)
		self.Library = Library
		Library.MenuManager = self
	end

	function MenuManager:SetEasingStyle(Value)
		if Enum.EasingStyle[Value] then
			self.EasingStyle = Value
		end
	end

	function MenuManager:SetEasingDirection(Value)
		if Enum.EasingDirection[Value] then
			self.EasingDirection = Value
		end
	end

	function MenuManager:SetTweenSpeed(Value)
		self.TweenSpeed = math.clamp(tonumber(Value) or 0.24, 0.05, 1)
	end

	function MenuManager:ResetMenuPositions()
		if self.Library and self.Library.ResetMenuPositions then
			self.Library:ResetMenuPositions(true)
		end
	end

	function MenuManager:CreateMenuManager(Groupbox)
		assert(self.Library, 'Must set MenuManager.Library')

		Groupbox:AddDropdown('MenuManager_EasingStyle', {
			Text = 'Easing style';
			Values = self.EasingStyles;
			Default = FindIndex(self.EasingStyles, self.EasingStyle);
		})

		Options.MenuManager_EasingStyle:OnChanged(function()
			self:SetEasingStyle(Options.MenuManager_EasingStyle.Value)
		end)

		Groupbox:AddDropdown('MenuManager_EasingDirection', {
			Text = 'Easing direction';
			Values = self.EasingDirections;
			Default = FindIndex(self.EasingDirections, self.EasingDirection);
		})

		Options.MenuManager_EasingDirection:OnChanged(function()
			self:SetEasingDirection(Options.MenuManager_EasingDirection.Value)
		end)

		Groupbox:AddSlider('MenuManager_TweenSpeed', {
			Text = 'Tween speed';
			Default = self.TweenSpeed;
			Min = 0.05;
			Max = 1;
			Rounding = 2;
			Step = 0.01;
			Suffix = 's';
		})

		Options.MenuManager_TweenSpeed:OnChanged(function()
			self:SetTweenSpeed(Options.MenuManager_TweenSpeed.Value)
		end)

		Groupbox:AddButton('Reset menu positions', function()
			self:ResetMenuPositions()
		end)
	end

	function MenuManager:BuildMenuSection(Tab)
		assert(self.Library, 'Must set MenuManager.Library')
		local Section = Tab:AddRightGroupbox('Menu manager')
		self:CreateMenuManager(Section)
		return Section
	end
end

return MenuManager
