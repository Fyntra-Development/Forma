from pathlib import Path

library_path = Path('Library.lua')
theme_path = Path('addons/ThemeManager.lua')
library = library_path.read_text()
theme = theme_path.read_text()


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 match, got {count}')
    return text.replace(old, new, 1)


def replace_between(text, start_marker, end_marker, replacement, label):
    start = text.find(start_marker)
    if start < 0:
        raise SystemExit(f'{label}: start marker missing')
    end = text.find(end_marker, start)
    if end < 0:
        raise SystemExit(f'{label}: end marker missing')
    return text[:start] + replacement + text[end:]


# Theme overlay alignment and opt-in searchable manager dropdowns.
theme = replace_once(theme, "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.832);", "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.842);", 'Marin alignment')
theme = replace_once(theme, "groupbox:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = FontNames, Default = DefaultFontIndex })", "groupbox:AddDropdown('ThemeManager_Font', { Text = 'Font', Values = FontNames, Default = DefaultFontIndex, Searchable = true })", 'font searchable')
theme = replace_once(theme, "groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })", "groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1, Searchable = true })", 'theme searchable')
theme = replace_once(theme, "groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })", "groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1, Searchable = true })", 'custom theme searchable')

# Menu animation helpers are deliberately runtime-driven so MenuManager can be loaded later.
menu_helpers = r'''
Library.DraggableStates = setmetatable({}, { __mode = 'k' });

function Library:GetMenuTweenInfo(Duration)
    local Manager = Library.MenuManager;
    if Manager and Manager.GetTweenInfo then
        local Success, Info = pcall(Manager.GetTweenInfo, Manager, Duration);
        if Success and typeof(Info) == 'TweenInfo' then
            return Info;
        end
    end

    return TweenInfo.new(
        math.max(tonumber(Duration) or 0.24, 0.01),
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    );
end;

function Library:TweenMenuProperty(Instance, Property, Value, Duration)
    if not Instance then
        return nil;
    end

    local InstanceTweens = Library.PropertyTweens[Instance];
    if not InstanceTweens then
        InstanceTweens = {};
        Library.PropertyTweens[Instance] = InstanceTweens;
    end

    local Previous = InstanceTweens[Property];
    if Previous then
        pcall(function() Previous:Cancel(); end);
    end

    local Tween;
    local Success = pcall(function()
        Tween = TweenService:Create(Instance, Library:GetMenuTweenInfo(Duration), { [Property] = Value });
    end);

    if not Success or not Tween then
        pcall(function() Instance[Property] = Value; end);
        return nil;
    end

    InstanceTweens[Property] = Tween;
    Tween:Play();
    Tween.Completed:Connect(function()
        if InstanceTweens[Property] == Tween then
            InstanceTweens[Property] = nil;
        end
    end);
    return Tween;
end;

function Library:TweenMenuFadeTree(Root, Hidden, Duration)
    if not Root then
        return;
    end

    Library:PrimeFadeTree(Root);
    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            for Property, Baseline in next, Cache do
                Library:TweenMenuProperty(Instance, Property, Hidden and 1 or Baseline, Duration);
            end
        end
    end
end;

function Library:ResetMenuPositions(Animated)
    for Instance, State in next, Library.DraggableStates do
        if Instance and Instance.Parent and State.InitialPosition then
            if Animated then
                Library:TweenMenuProperty(Instance, 'Position', State.InitialPosition, nil);
            else
                Instance.Position = State.InitialPosition;
            end
        end
    end
end;

'''
needle = "Library.FadeBaselines = setmetatable({}, { __mode = 'k' });\n\n"
library = replace_once(library, needle, needle + menu_helpers, 'menu helpers')

# Smooth draggable routing controlled by MenuManager settings.
new_drag = r'''function Library:MakeDraggable(Instance, Cutoff)
    if not Instance then
        return nil;
    end

    local Existing = Library.DraggableStates[Instance];
    if Existing then
        return Existing;
    end

    Instance.Active = true;
    local State = {
        InitialPosition = Instance.Position;
        Dragging = false;
        Tween = nil;
    };
    Library.DraggableStates[Instance] = State;

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return;
        end

        local ObjPos = Vector2.new(
            Mouse.X - Instance.AbsolutePosition.X,
            Mouse.Y - Instance.AbsolutePosition.Y
        );

        if ObjPos.Y > (Cutoff or 40) then
            return;
        end

        State.Dragging = true;
        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Instance.Parent do
            local Target = UDim2.new(
                0,
                Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                0,
                Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
            );

            local Speed = Library.MenuManager and Library.MenuManager.TweenSpeed or 0.18;
            Library:TweenMenuProperty(Instance, 'Position', Target, math.clamp(Speed * 0.55, 0.035, 0.22));
            RenderStepped:Wait();
        end
        State.Dragging = false;
    end);

    return State;
end;

'''
library = replace_between(library, 'function Library:MakeDraggable(Instance, Cutoff)', 'function Library:AddToolTip(Info, HoverInstance)', new_drag, 'smooth draggable')

# Stronger but still compact multi-layer glow.
old_layers = """    local Layers = {\n        { 0.70, 0.42 },\n        { 0.92, 0.54 },\n        { 1.14, 0.66 },\n        { 1.38, 0.76 },\n        { 1.64, 0.84 },\n        { 1.90, 0.90 },\n        { 2.18, 0.95 },\n    };"""
new_layers = """    local Layers = {\n        { 0.78, 0.18 },\n        { 1.08, 0.30 },\n        { 1.42, 0.42 },\n        { 1.82, 0.54 },\n        { 2.30, 0.64 },\n        { 2.86, 0.73 },\n        { 3.48, 0.81 },\n        { 4.14, 0.87 },\n        { 4.82, 0.92 },\n        { 5.45, 0.96 },\n    };"""
library = replace_once(library, old_layers, new_layers, 'accent glow')

# Completely replace dropdown implementation so search is opt-in and the search surface is detached.
new_dropdown = r'''    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if not Info.Text then
            Info.Compact = true;
        end;

        local Searchable = Info.Searchable == true;
        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Searchable = Searchable;
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });
            Groupbox:AddBlank(3);
        end

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddCorner(DropdownOuter, 3);
        Library:AddCorner(DropdownInner, 3);
        Library:AddToRegistry(DropdownOuter, { BorderColor3 = 'Black'; });
        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -22, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' or type(Info.Tooltip) == 'table' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS = tonumber(Info.MaxVisibleItems) or 8;
        local POPUP_GAP = 5;
        local SEARCH_HEIGHT = 20;
        local VALUES_PADDING = 5;
        local ROW_HEIGHT = 20;
        local ListRowsHeight = ROW_HEIGHT;
        local ListTargetPosition = UDim2.fromOffset(0, 0);
        local SearchTargetPosition = UDim2.fromOffset(0, 0);
        local SearchOuter;
        local SearchBox;

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            ClipsDescendants = true;
            Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), ROW_HEIGHT + (VALUES_PADDING * 2));
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        Library:AddCorner(ListOuter, 3);
        Library:AddToRegistry(ListOuter, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ListInner = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 21;
            Parent = ListOuter;
        });

        local DropdownGradient = DropdownInner:FindFirstChildOfClass('UIGradient');
        if DropdownGradient then
            DropdownGradient:Clone().Parent = ListOuter;
        end;

        if Searchable then
            SearchOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), SEARCH_HEIGHT);
                ZIndex = 26;
                Visible = false;
                Parent = ScreenGui;
            });

            local SearchInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 27;
                Parent = SearchOuter;
            });

            Library:AddCorner(SearchOuter, 3);
            Library:AddCorner(SearchInner, 3);
            Library:AddToRegistry(SearchOuter, { BorderColor3 = 'Black'; });
            Library:AddToRegistry(SearchInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            SearchBox = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ClearTextOnFocus = false;
                PlaceholderColor3 = Color3.fromRGB(155, 155, 155);
                PlaceholderText = Info.SearchPlaceholder or 'Search...';
                Position = UDim2.fromOffset(6, 0);
                Size = UDim2.new(1, -12, 1, 0);
                Text = '';
                TextColor3 = Library.FontColor;
                TextSize = 13;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 28;
                Parent = SearchInner;
            });
            Library:ApplyFont(SearchBox);
            Library:ApplyTextStroke(SearchBox);
            Library:AddToRegistry(SearchBox, { TextColor3 = 'FontColor'; });
        end

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.fromOffset(0, 0);
            Position = UDim2.fromOffset(VALUES_PADDING, VALUES_PADDING);
            Size = UDim2.new(1, -(VALUES_PADDING * 2), 0, ListRowsHeight);
            ScrollBarThickness = 0;
            ScrollBarImageTransparency = 0;
            ScrollBarImageColor3 = Library.AccentColor;
            ZIndex = 21;
            Parent = ListInner;
        });
        Library:AddToRegistry(Scrolling, { ScrollBarImageColor3 = 'AccentColor'; });

        local ScrollTrack = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(1, -2, 0, VALUES_PADDING + 4);
            Size = UDim2.new(0, 3, 0, math.max(ListRowsHeight - 8, 1));
            ZIndex = 24;
            Parent = ListInner;
        });

        local ScrollThumb = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0);
            BackgroundColor3 = Library.AccentColor;
            BackgroundTransparency = 0;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 0, 0, 0);
            Size = UDim2.new(0, 2, 0, 18);
            ZIndex = 25;
            Parent = ScrollTrack;
        });
        Library:AddCorner(ScrollThumb, 1);
        Library:AddToRegistry(ScrollThumb, { BackgroundColor3 = 'AccentColor'; });
        Library:Create('UIGradient', {
            Rotation = 90;
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.62),
                NumberSequenceKeypoint.new(0.16, 0),
                NumberSequenceKeypoint.new(0.84, 0),
                NumberSequenceKeypoint.new(1, 0.62),
            });
            Parent = ScrollThumb;
        });

        local ListLayout = Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        local function RecalculateListPosition()
            local Width = math.max(DropdownOuter.AbsoluteSize.X, 1);
            local BaseX = DropdownOuter.AbsolutePosition.X;
            local BaseY = DropdownOuter.AbsolutePosition.Y + DropdownOuter.AbsoluteSize.Y + POPUP_GAP;

            if Searchable then
                SearchTargetPosition = UDim2.fromOffset(BaseX, BaseY);
                ListTargetPosition = UDim2.fromOffset(BaseX, BaseY + SEARCH_HEIGHT + POPUP_GAP);
                SearchOuter.Size = UDim2.fromOffset(Width, SEARCH_HEIGHT);
                if not Dropdown.Opened then
                    SearchOuter.Position = SearchTargetPosition;
                end
            else
                ListTargetPosition = UDim2.fromOffset(BaseX, BaseY);
            end

            if not Dropdown.Opened then
                ListOuter.Position = ListTargetPosition;
            end
            ListOuter.Size = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2));
        end;

        local function RecalculateListSize(RowHeight, Animated)
            ListRowsHeight = math.clamp(tonumber(RowHeight) or ROW_HEIGHT, ROW_HEIGHT, (MAX_DROPDOWN_ITEMS * ROW_HEIGHT) + 1);
            local Width = math.max(DropdownOuter.AbsoluteSize.X, 1);
            local OuterSize = UDim2.fromOffset(Width, ListRowsHeight + (VALUES_PADDING * 2));
            local ScrollSize = UDim2.new(1, -(VALUES_PADDING * 2), 0, ListRowsHeight);
            local TrackSize = UDim2.new(0, 3, 0, math.max(ListRowsHeight - 8, 1));

            if Animated and Dropdown.Opened then
                Library:TweenMenuProperty(ListOuter, 'Size', OuterSize, 0.22);
                Library:TweenMenuProperty(Scrolling, 'Size', ScrollSize, 0.22);
                Library:TweenMenuProperty(ScrollTrack, 'Size', TrackSize, 0.22);
            else
                ListOuter.Size = OuterSize;
                Scrolling.Size = ScrollSize;
                ScrollTrack.Size = TrackSize;
            end
        end;

        local function UpdateDropdownScrollVisuals()
            local ViewportHeight = math.max(Scrolling.AbsoluteSize.Y, 0);
            local ContentHeight = math.max(Scrolling.AbsoluteCanvasSize.Y, ListLayout.AbsoluteContentSize.Y, 0);
            if ViewportHeight <= 0 or ContentHeight <= ViewportHeight + 1 then
                ScrollTrack.Visible = false;
                return;
            end

            ScrollTrack.Visible = true;
            local TrackHeight = math.max(ScrollTrack.AbsoluteSize.Y, 1);
            local MinThumbHeight = math.min(18, TrackHeight);
            local ThumbHeight = math.clamp(TrackHeight * (ViewportHeight / math.max(ContentHeight, 1)), MinThumbHeight, TrackHeight);
            local MaxTravel = math.max(TrackHeight - ThumbHeight, 0);
            local MaxCanvas = math.max(ContentHeight - ViewportHeight, 1);
            local ThumbY = MaxTravel * math.clamp(Scrolling.CanvasPosition.Y / MaxCanvas, 0, 1);

            ScrollThumb.Size = UDim2.new(0, 2, 0, ThumbHeight);
            ScrollThumb.Position = UDim2.new(0.5, 0, 0, ThumbY);
        end;

        ListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Scrolling.CanvasSize = UDim2.fromOffset(0, math.max(ListLayout.AbsoluteContentSize.Y, 1));
            task.defer(UpdateDropdownScrollVisuals);
        end);
        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(UpdateDropdownScrollVisuals);
        Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() task.defer(UpdateDropdownScrollVisuals); end);
        ListOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() task.defer(UpdateDropdownScrollVisuals); end);
        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);
        DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(RecalculateListPosition);

        function Dropdown:Display()
            local Str = '';
            if Info.Multi then
                for _, Value in next, Dropdown.Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. tostring(Value) .. ', ';
                    end
                end
                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end
            ItemList.Text = (Str == '' and '--' or tostring(Str));
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};
                for Value, Bool in next, Dropdown.Value do
                    if Bool then table.insert(T, Value); end
                end
                return T;
            end
            return Dropdown.Value and 1 or 0;
        end;

        local Buttons = {};
        local ButtonOrder = {};
        local ApplyDropdownSearch;

        function Dropdown:BuildDropdownList()
            table.clear(Buttons);
            table.clear(ButtonOrder);

            for _, Element in next, Scrolling:GetChildren() do
                if Element ~= ListLayout then
                    Element:Destroy();
                end
            end

            for Index, Value in ipairs(Dropdown.Values) do
                local Row = {};
                local Button = Library:Create('Frame', {
                    Active = true;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    ClipsDescendants = true;
                    LayoutOrder = Index;
                    Size = UDim2.new(1, -5, 0, ROW_HEIGHT);
                    ZIndex = 23;
                    Parent = Scrolling;
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Position = UDim2.new(0, 6, 0, 0);
                    Size = UDim2.new(1, -8, 0, ROW_HEIGHT);
                    TextSize = 14;
                    Text = tostring(Value);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Row.Button = Button;
                Row.Label = ButtonLabel;
                Row.Value = Value;

                function Row:UpdateButton()
                    local Selected = Info.Multi and Dropdown.Value[Value] or Dropdown.Value == Value;
                    local TextColorKey = Selected and 'AccentColor' or 'FontColor';
                    Library:TweenProperty(ButtonLabel, 'TextColor3', Library[TextColorKey], 0.16);
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = TextColorKey;
                end;

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or not Button.Active then
                        return;
                    end

                    local Selected = Info.Multi and Dropdown.Value[Value] or Dropdown.Value == Value;
                    local Try = not Selected;
                    if Dropdown:GetActiveValues() == 1 and not Try and not Info.AllowNull then
                        return;
                    end

                    if Info.Multi then
                        if Try then Dropdown.Value[Value] = true else Dropdown.Value[Value] = nil end
                    else
                        Dropdown.Value = Try and Value or nil;
                    end

                    for _, Other in ipairs(ButtonOrder) do Other:UpdateButton(); end
                    Dropdown:Display();
                    Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                    Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
                    Library:AttemptSave();
                end);

                Library:PrimeFadeTree(Button);
                Row:UpdateButton();
                Buttons[Button] = Row;
                table.insert(ButtonOrder, Row);
            end

            Dropdown:Display();
            if ApplyDropdownSearch then
                ApplyDropdownSearch(true);
            else
                local Rows = math.max(1, math.min(#ButtonOrder, MAX_DROPDOWN_ITEMS));
                RecalculateListSize((Rows * ROW_HEIGHT) + 1, false);
            end
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValue(NewValue)
            if Info.Multi then
                local NewSelection = {};
                if type(NewValue) == 'table' then
                    for Key, Value in next, NewValue do
                        if type(Key) == 'number' then
                            NewSelection[Value] = true;
                        elseif Value then
                            NewSelection[Key] = true;
                        end
                    end
                end
                Dropdown.Value = NewSelection;
            else
                if NewValue == nil and not Info.AllowNull then return; end
                if NewValue ~= nil and not table.find(Dropdown.Values, NewValue) then return; end
                Dropdown.Value = NewValue;
            end

            for _, Row in ipairs(ButtonOrder) do Row:UpdateButton(); end
            Dropdown:Display();
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then Dropdown.Values = NewValues; end
            Dropdown:BuildDropdownList();
        end;

        ApplyDropdownSearch = function(Instant)
            local Query = SearchBox and string.lower(SearchBox.Text or '') or '';
            local VisibleCount = 0;

            for _, Row in ipairs(ButtonOrder) do
                local Matches = Query == '' or string.find(string.lower(tostring(Row.Value)), Query, 1, true) ~= nil;
                if Matches then VisibleCount = VisibleCount + 1; end
                Row.Button.Active = Matches;

                if Instant then
                    Row.Button.Size = UDim2.new(1, -5, 0, Matches and ROW_HEIGHT or 0);
                    Library:SetFadeTree(Row.Button, not Matches);
                else
                    Library:TweenProperty(Row.Button, 'Size', UDim2.new(1, -5, 0, Matches and ROW_HEIGHT or 0), 0.22);
                    Library:TweenFadeTree(Row.Button, not Matches, Matches and 0.22 or 0.16);
                end
            end

            local Rows = math.max(1, math.min(VisibleCount, MAX_DROPDOWN_ITEMS));
            RecalculateListSize((Rows * ROW_HEIGHT) + 1, not Instant);
            Scrolling.CanvasPosition = Vector2.new(0, 0);
            task.defer(UpdateDropdownScrollVisuals);
        end;

        if SearchBox then
            SearchBox:GetPropertyChangedSignal('Text'):Connect(function()
                ApplyDropdownSearch(false);
            end);
        end

        local DropdownTweens = {};
        local DropdownAnimationId = 0;
        local DropdownScrollConnection;

        local function CancelDropdownTweens()
            for _, Tween in next, DropdownTweens do
                pcall(function() Tween:Cancel(); end);
            end
            table.clear(DropdownTweens);
        end

        local function PlayDropdownTween(Instance, InfoValue, Properties)
            local Tween = TweenService:Create(Instance, InfoValue, Properties);
            table.insert(DropdownTweens, Tween);
            Tween:Play();
            return Tween;
        end

        local function StopDropdownAutoScroll()
            if DropdownScrollConnection then
                DropdownScrollConnection:Disconnect();
                DropdownScrollConnection = nil;
            end
        end

        local function StartDropdownAutoScroll()
            StopDropdownAutoScroll();
            DropdownScrollConnection = RenderStepped:Connect(function(Delta)
                if not Dropdown.Opened or not ListOuter.Visible then
                    StopDropdownAutoScroll();
                    return;
                end

                local Position = ListOuter.AbsolutePosition;
                local Size = ListOuter.AbsoluteSize;
                if Mouse.X < Position.X or Mouse.X > Position.X + Size.X then return; end

                local Edge = math.min(24, math.max(Size.Y * 0.24, 12));
                local Direction = 0;
                local Strength = 0;
                if Mouse.Y >= Position.Y + Size.Y - Edge and Mouse.Y <= Position.Y + Size.Y + 5 then
                    Direction = 1;
                    Strength = math.clamp((Mouse.Y - (Position.Y + Size.Y - Edge)) / Edge, 0, 1);
                elseif Mouse.Y <= Position.Y + Edge and Mouse.Y >= Position.Y - 5 then
                    Direction = -1;
                    Strength = math.clamp(((Position.Y + Edge) - Mouse.Y) / Edge, 0, 1);
                end

                if Direction ~= 0 then
                    local MaxCanvas = math.max(Scrolling.AbsoluteCanvasSize.Y - Scrolling.AbsoluteSize.Y, 0);
                    if MaxCanvas > 0 then
                        local NewY = math.clamp(Scrolling.CanvasPosition.Y + Direction * (90 + 220 * Strength) * Delta, 0, MaxCanvas);
                        Scrolling.CanvasPosition = Vector2.new(0, NewY);
                    end
                end
            end);
        end

        local function PointInside(Frame)
            if not Frame or not Frame.Visible then return false; end
            local P, S = Frame.AbsolutePosition, Frame.AbsoluteSize;
            return Mouse.X >= P.X and Mouse.X <= P.X + S.X and Mouse.Y >= P.Y and Mouse.Y <= P.Y + S.Y;
        end

        function Dropdown:OpenDropdown()
            if Dropdown.Opened then return; end
            Dropdown.Opened = true;
            DropdownAnimationId = DropdownAnimationId + 1;
            CancelDropdownTweens();

            if SearchBox and SearchBox.Text ~= '' then SearchBox.Text = ''; end
            ApplyDropdownSearch(true);
            RecalculateListPosition();

            if SearchOuter then
                SearchOuter.Position = UDim2.fromOffset(SearchTargetPosition.X.Offset, SearchTargetPosition.Y.Offset - 5);
                Library:SetFadeTree(SearchOuter, true);
                SearchOuter.Visible = true;
                Library.OpenedFrames[SearchOuter] = true;
                PlayDropdownTween(SearchOuter, Library:GetMenuTweenInfo(0.24), { Position = SearchTargetPosition });
                Library:TweenMenuFadeTree(SearchOuter, false, 0.22);
            end

            ListOuter.Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 5);
            Library:SetFadeTree(ListOuter, true);
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            PlayDropdownTween(ListOuter, Library:GetMenuTweenInfo(0.27), { Position = ListTargetPosition });
            Library:TweenMenuFadeTree(ListOuter, false, 0.24);
            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = 180 });
            StartDropdownAutoScroll();
        end;

        function Dropdown:CloseDropdown()
            if not Dropdown.Opened and not ListOuter.Visible then return; end
            Dropdown.Opened = false;
            DropdownAnimationId = DropdownAnimationId + 1;
            local CurrentId = DropdownAnimationId;
            CancelDropdownTweens();
            StopDropdownAutoScroll();
            Library.OpenedFrames[ListOuter] = nil;
            if SearchOuter then Library.OpenedFrames[SearchOuter] = nil; end

            Library:TweenMenuFadeTree(ListOuter, true, 0.20);
            local ExitTween = PlayDropdownTween(ListOuter, Library:GetMenuTweenInfo(0.22), {
                Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 4)
            });

            if SearchOuter and SearchOuter.Visible then
                Library:TweenMenuFadeTree(SearchOuter, true, 0.18);
                PlayDropdownTween(SearchOuter, Library:GetMenuTweenInfo(0.20), {
                    Position = UDim2.fromOffset(SearchTargetPosition.X.Offset, SearchTargetPosition.Y.Offset - 4)
                });
            end

            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Rotation = 0 });
            ExitTween.Completed:Connect(function(State)
                if CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then return; end
                ListOuter.Visible = false;
                ListOuter.Position = ListTargetPosition;
                Library:SetFadeTree(ListOuter, false);
                if SearchOuter then
                    SearchOuter.Visible = false;
                    SearchOuter.Position = SearchTargetPosition;
                    Library:SetFadeTree(SearchOuter, false);
                end
                table.clear(DropdownTweens);
            end);
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if Dropdown.Opened then Dropdown:CloseDropdown() else Dropdown:OpenDropdown() end
            end
        end);

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Opened then
                if not PointInside(ListOuter) and not PointInside(SearchOuter) and not PointInside(DropdownOuter) then
                    Dropdown:CloseDropdown();
                end
            end
        end));

        Dropdown:BuildDropdownList();

        local Defaults = {};
        if type(Info.Default) == 'string' then
            local Index = table.find(Dropdown.Values, Info.Default);
            if Index then table.insert(Defaults, Index); end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Index = table.find(Dropdown.Values, Value);
                if Index then table.insert(Defaults, Index); end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default);
        end

        if next(Defaults) then
            for _, Index in ipairs(Defaults) do
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true;
                else
                    Dropdown.Value = Dropdown.Values[Index];
                    break;
                end
            end
            for _, Row in ipairs(ButtonOrder) do Row:UpdateButton(); end
            Dropdown:Display();
        end

        RecalculateListPosition();
        ApplyDropdownSearch(true);
        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Dropdown.SearchBox = SearchBox;
        Dropdown.SearchFrame = SearchOuter;
        Dropdown.ListFrame = ListOuter;
        Options[Idx] = Dropdown;
        return Dropdown;
    end;

'''
library = replace_between(library, '    function Funcs:AddDropdown(Idx, Info)', '    function Funcs:AddDependencyBox()', new_dropdown, 'dropdown implementation')

# Target HUD component.
target_hud = r'''
function Library:CreateTargetHUD(Config)
    Config = Config or {};

    if Library.TargetHUD and Library.TargetHUD.Destroy then
        Library.TargetHUD:Destroy();
    end

    local HUD = {
        Target = nil;
        StaticInfo = nil;
        InfoProvider = Config.InfoProvider or Config.GetInfo;
        AnimationId = 0;
    };

    local Outer = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = Config.Position or UDim2.new(0.5, 285, 0.5, 120);
        Size = Config.Size or UDim2.fromOffset(270, 88);
        Visible = false;
        ZIndex = 250;
        Parent = ScreenGui;
    });

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 251;
        Parent = Outer;
    });

    Library:AddCorner(Outer, 3);
    Library:AddCorner(Inner, 3);
    Library:AddAccentGlow(Inner, 0.95);
    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    }, true);

    local AvatarOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.fromOffset(8, 9);
        Size = UDim2.fromOffset(68, 68);
        ZIndex = 252;
        Parent = Inner;
    });
    Library:AddCorner(AvatarOuter, 3);
    Library:AddToRegistry(AvatarOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local Avatar = Library:Create('ImageLabel', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.fromOffset(2, 2);
        Size = UDim2.new(1, -4, 1, -4);
        Image = '';
        ZIndex = 253;
        Parent = AvatarOuter;
    });
    Library:AddCorner(Avatar, 3);

    local Username = Library:CreateLabel({
        Position = UDim2.fromOffset(84, 8);
        Size = UDim2.new(1, -92, 0, 18);
        Text = 'No target';
        TextColor3 = Library.AccentColor;
        TextSize = 15;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 253;
        Parent = Inner;
    });
    Library.RegistryMap[Username].Properties.TextColor3 = 'AccentColor';

    local InfoLabel = Library:CreateLabel({
        Position = UDim2.fromOffset(84, 27);
        Size = UDim2.new(1, -92, 1, -34);
        Text = 'Waiting for target';
        TextSize = 13;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        ZIndex = 253;
        Parent = Inner;
    });

    local function FormatInfo(Value)
        if type(Value) == 'string' then
            return Value;
        end
        if type(Value) ~= 'table' then
            return '';
        end

        local Lines = {};
        if #Value > 0 then
            for _, Entry in ipairs(Value) do
                if type(Entry) == 'table' then
                    local Key = Entry[1] or Entry.Name or Entry.Label;
                    local Val = Entry[2] or Entry.Value;
                    table.insert(Lines, Key and (tostring(Key) .. ': ' .. tostring(Val or '')) or tostring(Val or ''));
                else
                    table.insert(Lines, tostring(Entry));
                end
            end
        else
            for Key, Val in next, Value do
                table.insert(Lines, tostring(Key) .. ': ' .. tostring(Val));
            end
            table.sort(Lines);
        end
        return table.concat(Lines, '\n');
    end

    function HUD:GetDefaultInfo(Target)
        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            local Lines = {};
            if Target.DisplayName and Target.DisplayName ~= Target.Name then
                table.insert(Lines, 'Display: ' .. Target.DisplayName);
            end

            local Character = Target.Character;
            local Humanoid = Character and Character:FindFirstChildOfClass('Humanoid');
            if Humanoid then
                table.insert(Lines, string.format('Health: %d/%d', math.floor(Humanoid.Health + 0.5), math.floor(Humanoid.MaxHealth + 0.5)));
            end

            local Root = Character and Character:FindFirstChild('HumanoidRootPart');
            local LocalCharacter = LocalPlayer.Character;
            local LocalRoot = LocalCharacter and LocalCharacter:FindFirstChild('HumanoidRootPart');
            if Root and LocalRoot then
                table.insert(Lines, string.format('Distance: %d studs', math.floor((Root.Position - LocalRoot.Position).Magnitude + 0.5)));
            end

            return Lines;
        end

        if type(Target) == 'table' then
            return Target.Info or Target.Details or {};
        end
        return {};
    end

    function HUD:SetInfo(Info)
        HUD.StaticInfo = Info;
        InfoLabel.Text = FormatInfo(Info);
    end

    function HUD:SetInfoProvider(Provider)
        HUD.InfoProvider = type(Provider) == 'function' and Provider or nil;
        HUD:Refresh();
    end

    function HUD:Refresh()
        local Target = HUD.Target;
        if not Target then
            Username.Text = 'No target';
            InfoLabel.Text = HUD.StaticInfo and FormatInfo(HUD.StaticInfo) or 'Waiting for target';
            return;
        end

        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            Username.Text = '@' .. Target.Name;
        elseif type(Target) == 'table' then
            Username.Text = tostring(Target.Username or Target.Name or Target.DisplayName or 'Target');
        else
            Username.Text = tostring(Target);
        end

        local Info = HUD.StaticInfo;
        if HUD.InfoProvider then
            local Success, Result = pcall(HUD.InfoProvider, Target, HUD);
            if Success and Result ~= nil then Info = Result; end
        end
        if Info == nil then Info = HUD:GetDefaultInfo(Target); end
        InfoLabel.Text = FormatInfo(Info);
    end

    function HUD:SetTarget(Target, Info)
        HUD.Target = Target;
        HUD.StaticInfo = Info;
        HUD:Refresh();

        local UserId;
        local DirectImage;
        if typeof(Target) == 'Instance' and Target:IsA('Player') then
            UserId = Target.UserId;
        elseif type(Target) == 'table' then
            UserId = tonumber(Target.UserId);
            DirectImage = Target.Avatar or Target.Image;
        end

        if DirectImage then
            Avatar.Image = tostring(DirectImage);
        elseif UserId then
            local Expected = Target;
            task.spawn(function()
                local Success, Content = pcall(function()
                    return Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100);
                end);
                if Success and HUD.Target == Expected and Avatar.Parent then
                    Avatar.Image = Content;
                end
            end);
        else
            Avatar.Image = '';
        end
    end

    function HUD:SetVisible(Visible)
        Visible = not not Visible;
        HUD.AnimationId = HUD.AnimationId + 1;
        local CurrentId = HUD.AnimationId;
        local Duration = Library.MenuManager and Library.MenuManager.TweenSpeed or 0.24;

        if Visible then
            if not Outer.Visible then
                Library:SetFadeTree(Outer, true);
                Outer.Visible = true;
            end
            Library:TweenMenuFadeTree(Outer, false, Duration);
        elseif Outer.Visible then
            Library:TweenMenuFadeTree(Outer, true, Duration);
            task.delay(Duration, function()
                if CurrentId == HUD.AnimationId and not Visible and Outer.Parent then
                    Outer.Visible = false;
                    Library:SetFadeTree(Outer, false);
                end
            end);
        end
    end

    function HUD:Destroy()
        HUD.AnimationId = HUD.AnimationId + 1;
        if Outer then Outer:Destroy(); end
        if Library.TargetHUD == HUD then
            Library.TargetHUD = nil;
            Library.TargetHUDFrame = nil;
        end
    end

    local RefreshAccumulator = 0;
    Library:GiveSignal(RenderStepped:Connect(function(Delta)
        if HUD.Target and Outer.Parent and Outer.Visible then
            RefreshAccumulator = RefreshAccumulator + Delta;
            if RefreshAccumulator >= 0.15 then
                RefreshAccumulator = 0;
                HUD:Refresh();
            end
        end
    end));

    HUD.Frame = Outer;
    HUD.Inner = Inner;
    HUD.Avatar = Avatar;
    HUD.UsernameLabel = Username;
    HUD.InfoLabel = InfoLabel;
    Library.TargetHUD = HUD;
    Library.TargetHUDFrame = Outer;
    Library:MakeDraggable(Outer, 28);

    if Config.Target then HUD:SetTarget(Config.Target, Config.Info); end
    if Config.Visible then HUD:SetVisible(true); end
    return HUD;
end;

'''
insert_marker = "function Library:Notify(Text, Time)"
insert_at = library.find(insert_marker)
if insert_at < 0:
    raise SystemExit('target HUD insertion marker missing')
library = library[:insert_at] + target_hud + library[insert_at:]

# Replace menu toggle fade with explicit whole-tree fade + subtle scale using MenuManager easing.
new_toggle = r'''    local Toggled = false;
    local Fading = false;
    local ToggleAnimationId = 0;
    local MenuScale = Library:Create('UIScale', {
        Name = 'FormaMenuScale';
        Scale = 1;
        Parent = Outer;
    });

    local function StartFormaCursor()
        task.spawn(function()
            local State = InputService.MouseIconEnabled;
            local CursorAssetPath = 'FormaAssets/cursor.png';
            local CursorAssetUrl = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/assets/cursor.png';
            local GetCustomAsset = getcustomasset or getsynasset;
            local Cursor;

            if GetCustomAsset and writefile and isfile then
                pcall(function()
                    if isfolder and makefolder and not isfolder('FormaAssets') then makefolder('FormaAssets'); end
                    if not isfile(CursorAssetPath) then writefile(CursorAssetPath, game:HttpGet(CursorAssetUrl)); end
                    Cursor = Library:Create('ImageLabel', {
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        Image = GetCustomAsset(CursorAssetPath);
                        ImageColor3 = Library.AccentColor;
                        Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
                        Size = UDim2.fromOffset(13, 16);
                        ZIndex = 1000;
                        Visible = true;
                        Parent = ScreenGui;
                    });
                    Library:AddToRegistry(Cursor, { ImageColor3 = 'AccentColor'; });
                end);
            end

            if Cursor then
                while Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = false;
                    Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y);
                    RenderStepped:Wait();
                end
                Cursor:Destroy();
            end
            InputService.MouseIconEnabled = State;
        end);
    end

    function Library:Toggle()
        if Fading then return; end

        Fading = true;
        Toggled = not Toggled;
        ToggleAnimationId = ToggleAnimationId + 1;
        local CurrentId = ToggleAnimationId;
        ModalElement.Modal = Toggled;
        local FadeTime = Library.MenuManager and Library.MenuManager.TweenSpeed or Config.MenuFadeTime;
        FadeTime = math.clamp(tonumber(FadeTime) or 0.24, 0.08, 1);

        if Toggled then
            Library:PrimeFadeTree(Outer);
            Library:SetFadeTree(Outer, true);
            MenuScale.Scale = 0.982;
            Outer.Visible = true;
            Library:TweenMenuFadeTree(Outer, false, FadeTime);
            Library:TweenMenuProperty(MenuScale, 'Scale', 1, FadeTime);
            StartFormaCursor();
        else
            Library:TweenMenuFadeTree(Outer, true, FadeTime);
            Library:TweenMenuProperty(MenuScale, 'Scale', 0.982, FadeTime);
        end

        task.delay(FadeTime, function()
            if CurrentId ~= ToggleAnimationId then return; end
            if not Toggled then
                Outer.Visible = false;
                Library:SetFadeTree(Outer, false);
                MenuScale.Scale = 1;
            end
            Fading = false;
        end);
    end

'''
library = replace_between(library, '    local TransparencyCache = {};', "    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)", new_toggle, 'menu toggle')

library_path.write_text(library)
theme_path.write_text(theme)
