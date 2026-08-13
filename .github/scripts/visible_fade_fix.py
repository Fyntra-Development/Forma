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


def replace_between(text, start_token, end_token, replacement, label):
    start = text.find(start_token)
    if start == -1:
        raise SystemExit(f'{label}: start token not found')
    end = text.find(end_token, start)
    if end == -1:
        raise SystemExit(f'{label}: end token not found')
    return text[:start] + replacement + text[end:]


# Marin: raise the visible artwork just enough that it rests on the top border instead of entering the title bar.
theme = replace_once(
    theme,
    "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.83);",
    "\t\t\tVisibleAnchor = Vector2.new(0.08, 0.855);",
    'Marin visual anchor',
)

# Per-descendant fade cache. This does not depend on CanvasGroup rendering support.
library = replace_once(
    library,
    "Library.BaseTextSizes = setmetatable({}, { __mode = 'k' });\n",
    "Library.BaseTextSizes = setmetatable({}, { __mode = 'k' });\nLibrary.FadeBaselines = setmetatable({}, { __mode = 'k' });\n",
    'fade baseline table',
)

fade_helpers = r'''function Library:GetFadePropertyNames(Instance)
    local Properties = {};

    if Instance:IsA('GuiObject') then
        table.insert(Properties, 'BackgroundTransparency');
    end;

    if Instance:IsA('TextLabel') or Instance:IsA('TextBox') or Instance:IsA('TextButton') then
        table.insert(Properties, 'TextTransparency');
        table.insert(Properties, 'TextStrokeTransparency');
    end;

    if Instance:IsA('ImageLabel') or Instance:IsA('ImageButton') then
        table.insert(Properties, 'ImageTransparency');
    end;

    if Instance:IsA('ScrollingFrame') then
        table.insert(Properties, 'ScrollBarImageTransparency');
    end;

    if Instance:IsA('UIStroke') then
        table.insert(Properties, 'Transparency');
    end;

    return Properties;
end;

function Library:PrimeFadeTree(Root)
    if not Root then
        return;
    end;

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Properties = Library:GetFadePropertyNames(Instance);
        if #Properties > 0 then
            local Cache = Library.FadeBaselines[Instance];
            if not Cache then
                Cache = {};
                Library.FadeBaselines[Instance] = Cache;
            end;

            for _, Property in ipairs(Properties) do
                if Cache[Property] == nil then
                    local Success, Value = pcall(function()
                        return Instance[Property];
                    end);

                    if Success then
                        Cache[Property] = Value;
                    end;
                end;
            end;
        end;
    end;
end;

function Library:SetFadeTree(Root, Hidden)
    if not Root then
        return;
    end;

    Library:PrimeFadeTree(Root);

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            for Property, Baseline in next, Cache do
                pcall(function()
                    Instance[Property] = Hidden and 1 or Baseline;
                end);
            end;
        end;
    end;
end;

function Library:TweenFadeTree(Root, Hidden, Duration)
    if not Root then
        return;
    end;

    Library:PrimeFadeTree(Root);
    Duration = Duration or 0.2;

    local Instances = { Root };
    for _, Descendant in ipairs(Root:GetDescendants()) do
        table.insert(Instances, Descendant);
    end;

    for _, Instance in ipairs(Instances) do
        local Cache = Library.FadeBaselines[Instance];
        if Cache then
            for Property, Baseline in next, Cache do
                Library:TweenProperty(Instance, Property, Hidden and 1 or Baseline, Duration);
            end;
        end;
    end;
end;

'''
library = replace_once(
    library,
    "function Library:SafeCallback(f, ...)\n",
    fade_helpers + "function Library:SafeCallback(f, ...)\n",
    'fade helpers',
)

# Remove CanvasGroup from all transition surfaces. Explicit fades below now do the visual work.
canvas_count = library.count("Library:Create('CanvasGroup'")
if canvas_count != 6:
    raise SystemExit(f'expected 6 CanvasGroup transition surfaces, got {canvas_count}')
library = library.replace("Library:Create('CanvasGroup'", "Library:Create('Frame'")

# Remove the creation-time GroupTransparency fields from those former CanvasGroups.
for old in [
    "            GroupTransparency = 1;\n",
    "                GroupTransparency = 1;\n",
    "                GroupTransparency = Tab.Active and 0 or 1;\n",
    "                    GroupTransparency = 1;\n",
]:
    library = library.replace(old, '')

# Main tabs: fade the real visual tree, including groupbox/tabbox shells and their descendants.
main_tab_fade = r'''        local function SetTabVisualGroups(Target, Duration, Stagger)
            local Hidden = Target >= 0.5;

            if not Duration or Duration <= 0 then
                Library:SetFadeTree(TabFrame, Hidden);
            else
                Library:TweenFadeTree(TabFrame, Hidden, Duration);
            end;
        end;

'''
library = replace_between(
    library,
    "        local function SetTabVisualGroups(Target, Duration, Stagger)\n",
    "        function Tab:ShowTab()\n",
    main_tab_fade,
    'main tab fade helper',
)

# Tabbox contents: explicit fade instead of GroupTransparency.
library = replace_once(
    library,
    "                    Library:TweenProperty(Container, 'GroupTransparency', 0, 0.2);",
    "                    Library:SetFadeTree(Container, true);\n                    Library:TweenFadeTree(Container, false, 0.22);",
    'tabbox show fade',
)
library = replace_once(
    library,
    "                    Library:TweenProperty(Container, 'GroupTransparency', 1, 0.14);",
    "                    Library:TweenFadeTree(Container, true, 0.16);",
    'tabbox hide fade',
)
library = library.replace("                            Container.GroupTransparency = 1;\n", '')

# Color picker: fade every visible primitive directly, while the transparent shell only handles motion.
color_picker_functions = r'''        function ColorPicker:Show()
            for Frame in next, Library.OpenedFrames do
                if Frame.Name == 'Color' and Frame ~= PickerFrameOuter then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerAnimationId = PickerAnimationId + 1;
            CancelPickerTweens();

            local TargetPosition = GetPickerTargetPosition();
            if not PickerFrameOuter.Visible then
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 28);
                Library:SetFadeTree(PickerFrameOuter, true);
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = TargetPosition;
            });
            Library:TweenFadeTree(PickerFrameOuter, false, 0.26);
        end;

        function ColorPicker:Hide()
            if not PickerFrameOuter.Visible then
                Library.OpenedFrames[PickerFrameOuter] = nil;
                return;
            end;

            PickerAnimationId = PickerAnimationId + 1;
            local CurrentId = PickerAnimationId;
            CancelPickerTweens();
            Library.OpenedFrames[PickerFrameOuter] = nil;

            local TargetPosition = GetPickerTargetPosition();
            Library:TweenFadeTree(PickerFrameOuter, true, 0.20);
            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 12);
            });

            ExitTween.Completed:Connect(function(State)
                if CurrentId ~= PickerAnimationId or State == Enum.PlaybackState.Cancelled then
                    return;
                end;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                Library:SetFadeTree(PickerFrameOuter, false);
                table.clear(PickerTweens);
            end);
        end;

'''
library = replace_between(
    library,
    "        function ColorPicker:Show()\n",
    "        function ColorPicker:SetValue(HSV, Transparency)\n",
    color_picker_functions,
    'color picker show/hide',
)

# Dropdown positioning/sizing: always remain a compact detached popup.
library = replace_once(
    library,
    """        local function RecalculateListSize(YSize)\n            ListHeight = YSize or (MAX_DROPDOWN_ITEMS * 20 + 2);\n            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight);\n        end;""",
    """        local function RecalculateListSize(YSize)\n            local RequestedHeight = tonumber(YSize) or (MAX_DROPDOWN_ITEMS * 20 + 2);\n            ListHeight = math.clamp(RequestedHeight, 1, MAX_DROPDOWN_ITEMS * 20 + 2);\n            ListOuter.Size = UDim2.fromOffset(math.max(DropdownOuter.AbsoluteSize.X, 1), ListHeight);\n        end;""",
    'dropdown fixed popup size',
)

dropdown_functions = r'''        function Dropdown:OpenDropdown()
            if Dropdown.Opened then
                return;
            end;

            Dropdown.Opened = true;
            DropdownAnimationId = DropdownAnimationId + 1;
            CancelDropdownTweens();
            RecalculateListPosition();
            RecalculateListSize(ListHeight);

            ListOuter.Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 6);
            Library:SetFadeTree(ListOuter, true);
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;

            PlayDropdownTween(ListOuter, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = ListTargetPosition;
            });
            Library:TweenFadeTree(ListOuter, false, 0.24);
            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = 180;
            });

            StartDropdownAutoScroll();
        end;

        function Dropdown:CloseDropdown()
            if not Dropdown.Opened and not ListOuter.Visible then
                return;
            end;

            Dropdown.Opened = false;
            DropdownAnimationId = DropdownAnimationId + 1;
            local CurrentId = DropdownAnimationId;
            CancelDropdownTweens();
            StopDropdownAutoScroll();
            Library.OpenedFrames[ListOuter] = nil;

            Library:TweenFadeTree(ListOuter, true, 0.19);
            local ExitTween = PlayDropdownTween(ListOuter, TweenInfo.new(0.21, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(ListTargetPosition.X.Offset, ListTargetPosition.Y.Offset - 4);
            });
            PlayDropdownTween(DropdownArrow, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = 0;
            });

            ExitTween.Completed:Connect(function(State)
                if CurrentId ~= DropdownAnimationId or Dropdown.Opened or State == Enum.PlaybackState.Cancelled then
                    return;
                end;

                ListOuter.Visible = false;
                ListOuter.Position = ListTargetPosition;
                Library:SetFadeTree(ListOuter, false);
                table.clear(DropdownTweens);
            end);
        end;

'''
library = replace_between(
    library,
    "        function Dropdown:OpenDropdown()\n",
    "        DropdownOuter.InputBegan:Connect(function(Input)\n",
    dropdown_functions,
    'dropdown show/hide',
)

# Dependency boxes: keep the height reveal, but explicitly fade their actual controls and shells.
dependency_function = r'''        local function SetDependencyVisible(Visible, Instant)
            DependencyAnimationId = DependencyAnimationId + 1;
            local CurrentId = DependencyAnimationId;
            CancelDependencyTweens();

            local Height = Layout.AbsoluteContentSize.Y;
            DependencyVisible = Visible;

            if Visible then
                Holder.Visible = true;

                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, Height);
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                Library:SetFadeTree(Holder, true);
                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, Height)
                });
                Library:TweenFadeTree(Holder, false, 0.20);
                DependencySizeTween:Play();
            else
                if not Holder.Visible then
                    Holder.Size = UDim2.new(1, 0, 0, 0);
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                if Instant then
                    Holder.Size = UDim2.new(1, 0, 0, 0);
                    Holder.Visible = false;
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                    return;
                end;

                Library:TweenFadeTree(Holder, true, 0.16);
                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(1, 0, 0, 0)
                });

                DependencySizeTween.Completed:Connect(function(State)
                    if CurrentId ~= DependencyAnimationId or DependencyVisible or State == Enum.PlaybackState.Cancelled then
                        return;
                    end;

                    Holder.Visible = false;
                    Library:SetFadeTree(Holder, false);
                    Groupbox:Resize();
                end);

                DependencySizeTween:Play();
            end;
        end;

'''
library = replace_between(
    library,
    "        local function SetDependencyVisible(Visible, Instant)\n",
    "        function Depbox:Resize(Instant)\n",
    dependency_function,
    'dependency animation',
)

# Any surviving GroupTransparency usage would now be an invalid property on a Frame and is therefore a hard failure.
if 'GroupTransparency' in library:
    occurrences = [line.strip() for line in library.splitlines() if 'GroupTransparency' in line]
    raise SystemExit('surviving GroupTransparency references: ' + ' | '.join(occurrences[:20]))

# Sanity tokens.
for token in [
    "function Library:TweenFadeTree(Root, Hidden, Duration)",
    "Library:TweenFadeTree(PickerFrameOuter, false, 0.26)",
    "Library:TweenFadeTree(ListOuter, false, 0.24)",
    "Library:TweenFadeTree(TabFrame, Hidden, Duration)",
    "Library:TweenFadeTree(Container, false, 0.22)",
    "Library:TweenFadeTree(Holder, false, 0.20)",
    "ListHeight = math.clamp(RequestedHeight, 1, MAX_DROPDOWN_ITEMS * 20 + 2)",
]:
    if token not in library:
        raise SystemExit(f'missing expected runtime token: {token}')

library_path.write_text(library)
theme_path.write_text(theme)
