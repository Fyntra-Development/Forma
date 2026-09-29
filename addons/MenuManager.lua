local TweenService = game:GetService('TweenService')

local MenuManager = {} do
	MenuManager.Version = '1.7.0+build.1'
	MenuManager.Library = nil
	MenuManager.EasingStyle = 'Sine'
	MenuManager.EasingDirection = 'Out'
	MenuManager.TweenSpeed = 0.18
	MenuManager.DefaultTweenSpeed = 0.18
	MenuManager.Fluidity = 1.00

	-- Keybind reveal motion is a physical follower, not a restartable tween.
	MenuManager.KeybindRowSmoothTime = 0.105
	MenuManager.KeybindFadeSmoothTime = 0.082
	MenuManager.KeybindRowTravel = 14
	MenuManager.KeybindRowStagger = 0.028

	-- Direct-manipulation motion is intentionally physical rather than tweened.
	-- These values are critically-damped response times in seconds. They feed
	-- Library:MakeDraggable and Library:MakeResizable every rendered frame.
	MenuManager.DragSmoothTime = 0.055
	MenuManager.ResizeSmoothTime = 0.065
	MenuManager.DragCatchupDistance = 30
	MenuManager.ResizeCatchupDistance = 34

	-- Magnetic screen anchors, evaluated while the pointer is moving.
	-- Independent X/Y snapping makes edges, center lines and all nine anchor
	-- combinations available without changing a window's AnchorPoint.
	MenuManager.AnchorSnapEnabled = true
	MenuManager.AnchorSnapDistance = 18
	MenuManager.AnchorSnapMargin = 10
	MenuManager.AnchorSnapGuides = true
	MenuManager.AnchorSnapWindows = true
	MenuManager.AnchorSnapGlow = true

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
		Tab = { Style = 'Sine'; Direction = 'InOut'; Scale = 1.08; Min = 0.24; Max = 0.38; };
		TabExit = { Style = 'Sine'; Direction = 'InOut'; Scale = 1.02; Min = 0.18; Max = 0.28; };
		TabIndicator = { Style = 'Sine'; Direction = 'InOut'; Scale = 1.04; Min = 0.18; Max = 0.32; };
		Picker = { Style = 'Quart'; Direction = 'Out'; Scale = 1.00; Min = 0.17; Max = 0.30; };
		Dropdown = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.00; Min = 0.16; Max = 0.28; };
		DropdownSearch = { Style = 'Cubic'; Direction = 'Out'; Scale = 1.00; Min = 0.15; Max = 0.25; };
		ScrollReveal = { Style = 'Sine'; Direction = 'Out'; Scale = 1.00; Min = 0.15; Max = 0.27; };
		Typing = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.96; Min = 0.13; Max = 0.22; };
		TypingIndicator = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.76; Min = 0.08; Max = 0.15; };
		TypingScroll = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.82; Min = 0.09; Max = 0.17; };
		Resize = { Style = 'Cubic'; Direction = 'Out'; Scale = 0.86; Min = 0.10; Max = 0.20; };
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
			Fluidity = math.clamp(
				tonumber(ContextProfile.Fluidity)
					or tonumber(self.Fluidity)
					or 1,
				0,
				1
			);
		}
	end

	local function SmootherStep(Value)
		local T = math.clamp(tonumber(Value) or 0, 0, 1)
		return T * T * T * (T * ((T * 6) - 15) + 10)
	end

	function MenuManager:GetEasedAlpha(Alpha, Context)
		local T = math.clamp(tonumber(Alpha) or 0, 0, 1)
		if T <= 0 then return 0 end
		if T >= 1 then return 1 end

		local Profile = self:GetMotionProfile(Context)

		-- Pre-warp time through a C2-continuous smootherstep before applying
		-- the selected easing style. This gives every UI animation genuinely
		-- soft velocity/acceleration at both ends instead of relying on native
		-- easing presets that can start or stop abruptly.
		local SoftT = SmootherStep(T)
		local WarpedT = T + ((SoftT - T) * Profile.Fluidity)

		local Success, Raw = pcall(
			TweenService.GetValue,
			TweenService,
			WarpedT,
			Profile.Style,
			Profile.Direction
		)
		if not Success or type(Raw) ~= 'number' then return SoftT end
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

	function MenuManager:GetKeybindMotionProfile()
		local GlobalScale = math.clamp(
			(tonumber(self.TweenSpeed) or self.DefaultTweenSpeed)
				/ self.DefaultTweenSpeed,
			0.60,
			1.75
		)

		return {
			SmoothTime = math.clamp(
				self.KeybindRowSmoothTime * GlobalScale,
				0.055,
				0.18
			);
			FadeSmoothTime = math.clamp(
				self.KeybindFadeSmoothTime * GlobalScale,
				0.045,
				0.15
			);
			Travel = math.clamp(
				tonumber(self.KeybindRowTravel) or 14,
				8,
				24
			);
			Stagger = math.clamp(
				(tonumber(self.KeybindRowStagger) or 0.028) * GlobalScale,
				0.012,
				0.055
			);
		}
	end

	function MenuManager:GetAnchorSnapProfile()
		local Distance = math.clamp(tonumber(self.AnchorSnapDistance) or 18, 6, 40)
		return {
			Enabled = self.AnchorSnapEnabled == true;
			Distance = Distance;
			-- A larger exit radius prevents flicker when the pointer sits at the
			-- boundary of a magnetic anchor.
			ReleaseDistance = math.max(Distance + 10, Distance * 1.65);
			Margin = math.clamp(tonumber(self.AnchorSnapMargin) or 10, 0, 32);
			ShowGuides = self.AnchorSnapGuides == true;
			SnapToWindows = self.AnchorSnapWindows == true;
			GlowGuides = self.AnchorSnapGlow == true;
		}
	end

	-- The moving window uses absolute screen coordinates; the same applies to
	-- peer.Position. Candidates are rebuilt from visible windows on every
	-- drag frame so moving or resized utilities stay valid snap targets.
	-- X and Y hold their own match identities, allowing e.g. X alignment with
	-- one utility and Y alignment with a different utility simultaneously.
	function MenuManager:ResolveAnchorSnap(Position, Size, Viewport, Previous, Origin, Peers)
		local Profile = self:GetAnchorSnapProfile()
		if not Profile.Enabled then return Position, nil end
		if typeof(Position) ~= 'Vector2'
			or typeof(Size) ~= 'Vector2'
			or typeof(Viewport) ~= 'Vector2' then
			return Position, nil
		end

		Origin = typeof(Origin) == 'Vector2' and Origin or Vector2.zero
		Previous = type(Previous) == 'table' and Previous or {}
		local Margin = Profile.Margin
		local XCandidates, YCandidates = {}, {}

		local function Add(Targets, Offset, Line, Kind, Reference, Match)
			table.insert(Targets, {
				Target = Offset;
				Line = Line;
				Kind = Kind;
				Reference = Reference;
				Match = Match;
			})
		end

		local CenterX = Origin.X + (Viewport.X * 0.5)
		local CenterY = Origin.Y + (Viewport.Y * 0.5)
		Add(XCandidates, CenterX - Size.X * 0.5, CenterX, 'Screen', nil, 'Center')
		Add(YCandidates, CenterY - Size.Y * 0.5, CenterY, 'Screen', nil, 'Center')
		if Viewport.X >= Size.X + Margin * 2 then
			Add(XCandidates, Origin.X + Margin, Origin.X + Margin, 'Screen', nil, 'Left')
			Add(XCandidates, Origin.X + Viewport.X - Size.X - Margin,
				Origin.X + Viewport.X - Margin, 'Screen', nil, 'Right')
		end
		if Viewport.Y >= Size.Y + Margin * 2 then
			Add(YCandidates, Origin.Y + Margin, Origin.Y + Margin, 'Screen', nil, 'Top')
			Add(YCandidates, Origin.Y + Viewport.Y - Size.Y - Margin,
				Origin.Y + Viewport.Y - Margin, 'Screen', nil, 'Bottom')
		end

		if Profile.SnapToWindows and type(Peers) == 'table' then
			for _, Peer in ipairs(Peers) do
				local Rect = Peer.Position
				local OtherSize = Peer.Size
				local Reference = Peer.Instance
				if Reference and Reference.Parent
					and typeof(Rect) == 'Vector2'
					and typeof(OtherSize) == 'Vector2'
					and OtherSize.X > 0 and OtherSize.Y > 0 then
					local L, R = Rect.X, Rect.X + OtherSize.X
					local T, B = Rect.Y, Rect.Y + OtherSize.Y
					local CX, CY = (L + R) * 0.5, (T + B) * 0.5
					-- Matching edges and midlines.
					Add(XCandidates, L, L, 'Window', Reference, 'LeftLeft')
					Add(XCandidates, CX - Size.X * 0.5, CX, 'Window', Reference, 'CenterCenter')
					Add(XCandidates, R - Size.X, R, 'Window', Reference, 'RightRight')
					Add(YCandidates, T, T, 'Window', Reference, 'TopTop')
					Add(YCandidates, CY - Size.Y * 0.5, CY, 'Window', Reference, 'CenterCenter')
					Add(YCandidates, B - Size.Y, B, 'Window', Reference, 'BottomBottom')
					-- Side-by-side docking with the configured inset as the gap.
					Add(XCandidates, R + Margin, R, 'Window', Reference, 'LeftAfterRight')
					Add(XCandidates, L - Margin - Size.X, L, 'Window', Reference, 'RightBeforeLeft')
					Add(YCandidates, B + Margin, B, 'Window', Reference, 'TopAfterBottom')
					Add(YCandidates, T - Margin - Size.Y, T, 'Window', Reference, 'BottomBeforeTop')
				end
			end
		end

		local function Choose(Raw, Held, Candidates)
			-- Hysteresis requires both the same reference instance and the same
			-- anchor relation; otherwise jumping between nearby peers flickers.
			if Held then
				for _, Candidate in ipairs(Candidates) do
					if Candidate.Kind == Held.Kind
						and Candidate.Reference == Held.Reference
						and Candidate.Match == Held.Match
						and math.abs(Raw - Candidate.Target) <= Profile.ReleaseDistance then
						return Candidate.Target, Candidate
					end
				end
			end

			local Best, Error = nil, Profile.Distance
			for _, Candidate in ipairs(Candidates) do
				local Distance = math.abs(Raw - Candidate.Target)
				if Distance <= Error then
					Best, Error = Candidate, Distance
				end
			end
			return Best and Best.Target or Raw, Best
		end

		local X, XAnchor = Choose(Position.X, Previous.X, XCandidates)
		local Y, YAnchor = Choose(Position.Y, Previous.Y, YCandidates)
		if not XAnchor and not YAnchor then return Position, nil end
		return Vector2.new(X, Y), { X = XAnchor; Y = YAnchor; }
	end

	function MenuManager:SetAnchorSnapEnabled(Value)
		self.AnchorSnapEnabled = Value == true
	end

	function MenuManager:SetAnchorSnapDistance(Value)
		self.AnchorSnapDistance = math.clamp(tonumber(Value) or 18, 6, 40)
	end

	function MenuManager:SetAnchorSnapMargin(Value)
		self.AnchorSnapMargin = math.clamp(tonumber(Value) or 10, 0, 32)
	end

	function MenuManager:SetAnchorSnapGuides(Value)
		self.AnchorSnapGuides = Value == true
	end

	function MenuManager:SetAnchorSnapWindows(Value)
		self.AnchorSnapWindows = Value == true
	end

	function MenuManager:SetAnchorSnapGlow(Value)
		self.AnchorSnapGlow = Value == true
	end

	function MenuManager:GetDirectManipulationProfile(Context)
		local IsResize = tostring(Context or 'Drag') == 'Resize'
		local BaseSmoothTime = IsResize
			and self.ResizeSmoothTime
			or self.DragSmoothTime
		local CatchupDistance = IsResize
			and self.ResizeCatchupDistance
			or self.DragCatchupDistance

		-- Keep direct manipulation linked to the MenuManager's global animation
		-- response without feeding it arbitrary easing curves. A critically
		-- damped follower needs a physical time constant, not a TweenInfo.
		local GlobalScale = math.clamp(
			(tonumber(self.TweenSpeed) or self.DefaultTweenSpeed)
				/ self.DefaultTweenSpeed,
			0.55,
			1.85
		)

		return {
			SmoothTime = math.clamp(
				(tonumber(BaseSmoothTime) or 0.06) * GlobalScale,
				0.022,
				0.18
			);
			CatchupDistance = math.clamp(
				tonumber(CatchupDistance) or 32,
				18,
				64
			);
			CatchupStrength = IsResize and 0.52 or 0.58;
			SettlePositionEpsilon = 0.035;
			SettleVelocityEpsilon = 0.12;
		}
	end

	function MenuManager:GetDragResponse()
		-- Compatibility for older integrations. The new library consumes the
		-- direct-manipulation profile above rather than a first-order response.
		local Profile = self:GetDirectManipulationProfile('Drag')
		return 2 / math.max(Profile.SmoothTime, 0.001)
	end

	function MenuManager:GetResizeResponse()
		local Profile = self:GetDirectManipulationProfile('Resize')
		return 2 / math.max(Profile.SmoothTime, 0.001)
	end

	function MenuManager:SetDragSmoothTime(Value)
		self.DragSmoothTime = math.clamp(
			tonumber(Value) or 0.055,
			0.025,
			0.14
		)
	end

	function MenuManager:SetResizeSmoothTime(Value)
		self.ResizeSmoothTime = math.clamp(
			tonumber(Value) or 0.065,
			0.03,
			0.16
		)
	end

	function MenuManager:GetReleaseDuration(Distance)
		local Travel = math.clamp(tonumber(Distance) or 0, 0, 48)
		return self:GetDuration(0.055 + (Travel / 1600), 'DragRelease')
	end

	function MenuManager:SetLibrary(Library)
		self.Library = Library
		Library.MenuManager = self
		if Library.RegisterUpdatable then
			Library:RegisterUpdatable('MenuManager', self.Version, 'addons/MenuManager.lua')
		end
		task.defer(function()
			if Library.CheckForUpdates then Library:CheckForUpdates('MenuManager') end
		end)
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

	function MenuManager:SetFluidity(Value)
		self.Fluidity = math.clamp(tonumber(Value) or 1, 0, 1)
	end

	function MenuManager:ResetMenuPositions()
		if self.Library and self.Library.ResetMenuPositions then self.Library:ResetMenuPositions(true) end
	end

	function MenuManager:CreateMenuManager(Groupbox)
		assert(self.Library, 'Must set MenuManager.Library')
		Groupbox:AddDropdown('MenuManager_EasingStyle', { Text = 'Easing style'; Values = self.EasingStyles; Default = FindIndex(self.EasingStyles, self.EasingStyle); RequireSelection = true; })
		Options.MenuManager_EasingStyle:OnChanged(function() self:SetEasingStyle(Options.MenuManager_EasingStyle.Value) end)
		Groupbox:AddDropdown('MenuManager_EasingDirection', { Text = 'Easing direction'; Values = self.EasingDirections; Default = FindIndex(self.EasingDirections, self.EasingDirection); RequireSelection = true; })
		Options.MenuManager_EasingDirection:OnChanged(function() self:SetEasingDirection(Options.MenuManager_EasingDirection.Value) end)
		Groupbox:AddSlider('MenuManager_TweenSpeed', { Text = 'Animation response'; Default = self.TweenSpeed; Min = 0.08; Max = 0.45; Rounding = 2; Step = 0.01; Suffix = 's'; })
		Options.MenuManager_TweenSpeed:OnChanged(function() self:SetTweenSpeed(Options.MenuManager_TweenSpeed.Value) end)

		Groupbox:AddSlider('MenuManager_Fluidity', {
			Text = 'Easing smoothness';
			Default = self.Fluidity;
			Min = 0;
			Max = 1;
			Rounding = 2;
			Step = 0.05;
		})
		Options.MenuManager_Fluidity:OnChanged(function()
			self:SetFluidity(Options.MenuManager_Fluidity.Value)
		end)

		Groupbox:AddSlider('MenuManager_DragSmoothTime', {
			Text = 'Drag smoothing';
			Default = self.DragSmoothTime;
			Min = 0.025;
			Max = 0.14;
			Rounding = 3;
			Step = 0.005;
			Suffix = 's';
		})
		Options.MenuManager_DragSmoothTime:OnChanged(function()
			self:SetDragSmoothTime(Options.MenuManager_DragSmoothTime.Value)
		end)

		Groupbox:AddSlider('MenuManager_ResizeSmoothTime', {
			Text = 'Resize smoothing';
			Default = self.ResizeSmoothTime;
			Min = 0.03;
			Max = 0.16;
			Rounding = 3;
			Step = 0.005;
			Suffix = 's';
		})
		Options.MenuManager_ResizeSmoothTime:OnChanged(function()
			self:SetResizeSmoothTime(Options.MenuManager_ResizeSmoothTime.Value)
		end)

		Groupbox:AddToggle('MenuManager_AnchorSnap', {
			Text = 'Real-time anchor snapping';
			Default = self.AnchorSnapEnabled;
		})
		Toggles.MenuManager_AnchorSnap:OnChanged(function()
			self:SetAnchorSnapEnabled(Toggles.MenuManager_AnchorSnap.Value)
		end)

		Groupbox:AddSlider('MenuManager_AnchorSnapDistance', {
			Text = 'Snap distance';
			Default = self.AnchorSnapDistance;
			Min = 6;
			Max = 40;
			Rounding = 0;
			Step = 1;
			Suffix = ' px';
		})
		Options.MenuManager_AnchorSnapDistance:OnChanged(function()
			self:SetAnchorSnapDistance(Options.MenuManager_AnchorSnapDistance.Value)
		end)

		Groupbox:AddSlider('MenuManager_AnchorSnapMargin', {
			Text = 'Anchor inset';
			Default = self.AnchorSnapMargin;
			Min = 0;
			Max = 32;
			Rounding = 0;
			Step = 1;
			Suffix = ' px';
		})
		Options.MenuManager_AnchorSnapMargin:OnChanged(function()
			self:SetAnchorSnapMargin(Options.MenuManager_AnchorSnapMargin.Value)
		end)

		Groupbox:AddToggle('MenuManager_AnchorSnapGuides', {
			Text = 'Show anchor guides';
			Default = self.AnchorSnapGuides;
		})
		Toggles.MenuManager_AnchorSnapGuides:OnChanged(function()
			self:SetAnchorSnapGuides(Toggles.MenuManager_AnchorSnapGuides.Value)
		end)


		Groupbox:AddToggle('MenuManager_AnchorSnapWindows', {
			Text = 'Snap to other windows';
			Default = self.AnchorSnapWindows;
		})
		Toggles.MenuManager_AnchorSnapWindows:OnChanged(function()
			self:SetAnchorSnapWindows(Toggles.MenuManager_AnchorSnapWindows.Value)
		end)

		Groupbox:AddToggle('MenuManager_AnchorSnapGlow', {
			Text = 'Glowing anchor guides';
			Default = self.AnchorSnapGlow;
		})
		Toggles.MenuManager_AnchorSnapGlow:OnChanged(function()
			self:SetAnchorSnapGlow(Toggles.MenuManager_AnchorSnapGlow.Value)
		end)

		Groupbox:AddButton('Reset menu positions', function() self:ResetMenuPositions() end)
	end

	function MenuManager:BuildMenuSection(Tab)
		assert(self.Library, 'Must set MenuManager.Library')
		if self.Library.CheckForUpdates then self.Library:CheckForUpdates('MenuManager') end
		local Section = Tab:AddRightGroupbox('Menu manager')
		self:CreateMenuManager(Section)
		return Section
	end
end

return MenuManager
