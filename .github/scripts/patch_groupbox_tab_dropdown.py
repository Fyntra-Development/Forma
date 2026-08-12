from pathlib import Path

path = Path('Library.lua')
source = path.read_text()

start = source.index('function Library:AddTopCorners')
end = source.index('function Library:ApplyTextStroke', start)
source = source[:start] + r'''function Library:AddTopCorners(Instance, Radius)
    if not Instance then
        return nil;
    end;

    Radius = Radius or 3;
    Library:AddCorner(Instance, Radius);

    local BottomSquare = Library:Create('Frame', {
        BackgroundColor3 = Instance.BackgroundColor3;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 1, -Radius);
        Size = UDim2.new(1, 0, 0, Radius);
        ZIndex = Instance.ZIndex + 1;
        Parent = Instance;
    });

    local LeftEdge = Library:Create('Frame', {
        BackgroundColor3 = Instance.BorderColor3;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(0, 1, 1, 0);
        ZIndex = BottomSquare.ZIndex;
        Parent = BottomSquare;
    });

    local RightEdge = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0);
        BackgroundColor3 = Instance.BorderColor3;
        BorderSizePixel = 0;
        Position = UDim2.new(1, 0, 0, 0);
        Size = UDim2.new(0, 1, 1, 0);
        ZIndex = BottomSquare.ZIndex;
        Parent = BottomSquare;
    });

    local function SyncTopCornerColors()
        BottomSquare.BackgroundColor3 = Instance.BackgroundColor3;
        LeftEdge.BackgroundColor3 = Instance.BorderColor3;
        RightEdge.BackgroundColor3 = Instance.BorderColor3;
    end;

    Instance:GetPropertyChangedSignal('BackgroundColor3'):Connect(SyncTopCornerColors);
    Instance:GetPropertyChangedSignal('BorderColor3'):Connect(SyncTopCornerColors);

    return BottomSquare;
end;

function Library:AddTabAccentCap(Instance)
    local Clip = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Size = UDim2.new(1, 0, 0.72, 0);
        ZIndex = Instance.ZIndex + 5;
        Parent = Instance;
    });

    local Outline = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, math.max(Instance.AbsoluteSize.Y, 1));
        ZIndex = Clip.ZIndex;
        Parent = Clip;
    });

    Library:AddCorner(Outline, 3);

    local Stroke = Library:Create('UIStroke', {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Color = Library.AccentColor;
        LineJoinMode = Enum.LineJoinMode.Round;
        Thickness = 1;
        Transparency = 1;
        Parent = Outline;
    });

    Library:AddToRegistry(Stroke, {
        Color = 'AccentColor';
    });

    local function CreateFadeMask(XScale, AnchorX)
        local Mask = Library:Create('Frame', {
            AnchorPoint = Vector2.new(AnchorX, 0);
            BackgroundColor3 = Instance.BackgroundColor3;
            BorderSizePixel = 0;
            Position = UDim2.new(XScale, 0, 0.42, 0);
            Size = UDim2.new(0, 2, 0.58, 0);
            ZIndex = Clip.ZIndex + 1;
            Parent = Clip;
        });

        Library:Create('UIGradient', {
            Rotation = 90;
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            });
            Parent = Mask;
        });

        return Mask;
    end;

    local LeftMask = CreateFadeMask(0, 0);
    local RightMask = CreateFadeMask(1, 1);

    local function SyncAccentGeometry()
        Outline.Size = UDim2.new(1, 0, 0, math.max(Instance.AbsoluteSize.Y, 1));
        LeftMask.BackgroundColor3 = Instance.BackgroundColor3;
        RightMask.BackgroundColor3 = Instance.BackgroundColor3;
    end;

    Instance:GetPropertyChangedSignal('AbsoluteSize'):Connect(SyncAccentGeometry);
    Instance:GetPropertyChangedSignal('BackgroundColor3'):Connect(SyncAccentGeometry);

    local function SetActive(Active)
        Library:TweenProperty(Stroke, 'Transparency', Active and 0 or 1, 0.18);
    end;

    SetActive(false);
    return SetActive;
end;

''' + source[end:]

legend_old = r'''            local GroupboxLabelWidth = Library:GetTextBounds(Info.Name, Library.Font, 14);
            local GroupboxLabel = Library:CreateLabel({
                BackgroundColor3 = Library.BackgroundColor;
                BackgroundTransparency = 0;
                Size = UDim2.fromOffset(GroupboxLabelWidth + 8, 16);
                Position = UDim2.new(0, 6, 0, -7);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';
            Highlight.Position = UDim2.fromOffset(GroupboxLabelWidth + 18, 0);
            Highlight.Size = UDim2.new(1, -(GroupboxLabelWidth + 18), 0, 2);
'''
legend_new = r'''            local GroupboxLabelWidth = Library:GetTextBounds(Info.Name, Library.Font, 14);
            local GroupboxLabel = Library:CreateLabel({
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = UDim2.fromOffset(GroupboxLabelWidth + 6, 16);
                Position = UDim2.new(0, 6, 0, 0);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Center;
                ZIndex = 6;
                Parent = BoxInner;
            });

            Highlight.Position = UDim2.fromOffset(GroupboxLabelWidth + 16, 7);
            Highlight.Size = UDim2.new(1, -(GroupboxLabelWidth + 16), 0, 2);
'''
if source.count(legend_old) != 1:
    raise SystemExit(f'groupbox legend block count: {source.count(legend_old)}')
source = source.replace(legend_old, legend_new, 1)

picker_outer = source.index("local PickerFrameOuter = Library:Create('Frame'")
picker_onchanged = source.index('function ColorPicker:OnChanged', picker_outer)
picker_prefix = source[picker_outer:picker_onchanged]
old_inner = "local PickerFrameInner = Library:Create('Frame', {"
if picker_prefix.count(old_inner) != 1:
    raise SystemExit('color picker inner frame not found exactly once')
picker_prefix = picker_prefix.replace(old_inner, "local PickerFrameInner = Library:Create('CanvasGroup', {", 1)
source = source[:picker_outer] + picker_prefix + source[picker_onchanged:]

anim_start = source.index('        local PickerOpenSize = PickerFrameOuter.Size;', picker_outer)
anim_end = source.index('        function ColorPicker:SetValue(HSV, Transparency)', anim_start)
new_picker_anim = r'''        local PickerOpenSize = PickerFrameOuter.Size;
        local PickerOuterTransparency = PickerFrameOuter.BackgroundTransparency;
        local PickerAnimationId = 0;
        local PickerTweens = {};

        local function GetPickerTargetPosition()
            return UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end;

        local function CancelPickerTweens()
            for _, Tween in next, PickerTweens do
                pcall(function() Tween:Cancel(); end);
            end;
            table.clear(PickerTweens);
        end;

        local function PlayPickerTween(Instance, InfoValue, Properties)
            local Tween = TweenService:Create(Instance, InfoValue, Properties);
            table.insert(PickerTweens, Tween);
            Tween:Play();
            return Tween;
        end;

        function ColorPicker:Show()
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
                PickerFrameOuter.Size = PickerOpenSize;
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 9);
                PickerFrameOuter.BackgroundTransparency = 1;
                PickerFrameInner.GroupTransparency = 1;
            end;

            PickerFrameOuter.ClipsDescendants = false;
            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            local MoveInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);
            local FadeInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

            PlayPickerTween(PickerFrameOuter, MoveInfo, {
                Position = TargetPosition;
                BackgroundTransparency = PickerOuterTransparency;
            });
            PlayPickerTween(PickerFrameInner, FadeInfo, {
                GroupTransparency = 0;
            });
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
            local MoveInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);
            local FadeInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);

            local MoveTween = PlayPickerTween(PickerFrameOuter, MoveInfo, {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 5);
                BackgroundTransparency = 1;
            });
            PlayPickerTween(PickerFrameInner, FadeInfo, {
                GroupTransparency = 1;
            });

            MoveTween.Completed:Connect(function()
                if CurrentId ~= PickerAnimationId then
                    return;
                end;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                PickerFrameOuter.Size = PickerOpenSize;
                PickerFrameOuter.BackgroundTransparency = PickerOuterTransparency;
                PickerFrameInner.GroupTransparency = 0;
            end);
        end;

'''
source = source[:anim_start] + new_picker_anim + source[anim_end:]

drop_start = source.index('    function Funcs:AddDropdown(Idx, Info)')
drop_end = source.index('    function Funcs:AddDependencyBox()', drop_start)
drop = source[drop_start:drop_end]

scroll_old = r'''            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
'''
scroll_new = r'''            ScrollBarThickness = 0,
            ScrollBarImageTransparency = 0,
            ScrollBarImageColor3 = Library.AccentColor,
'''
if drop.count(scroll_old) != 1:
    raise SystemExit('dropdown native scrollbar block missing')
drop = drop.replace(scroll_old, scroll_new, 1)

list_registry = r'''        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

'''
list_registry_new = list_registry + r'''        local DropdownGradient = DropdownInner:FindFirstChildOfClass('UIGradient');
        if DropdownGradient then
            DropdownGradient:Clone().Parent = ListInner;
        end;

'''
if drop.count(list_registry) != 1:
    raise SystemExit('dropdown list registry missing')
drop = drop.replace(list_registry, list_registry_new, 1)

scroll_registry = r'''        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor'
        })

'''
scroll_visuals = scroll_registry + r'''        local ScrollTrack = Library:Create('Frame', {
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(1, -1, 0, 4);
            Size = UDim2.new(0, 3, 1, -8);
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
        Library:AddToRegistry(ScrollThumb, {
            BackgroundColor3 = 'AccentColor';
        });

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

        local function UpdateDropdownScrollVisuals(Instant)
            local ViewportHeight = Scrolling.AbsoluteSize.Y;
            local ContentHeight = Scrolling.AbsoluteCanvasSize.Y;

            if ViewportHeight <= 0 then
                ScrollTrack.Visible = false;
                return;
            end;

            local Scrollable = ContentHeight > ViewportHeight + 1;
            ScrollTrack.Visible = Scrollable;

            if Scrollable then
                local TrackHeight = math.max(ScrollTrack.AbsoluteSize.Y, 1);
                local ThumbHeight = math.clamp(TrackHeight * (ViewportHeight / ContentHeight), 18, TrackHeight);
                local MaxTravel = math.max(TrackHeight - ThumbHeight, 0);
                local MaxCanvas = math.max(ContentHeight - ViewportHeight, 1);
                local ThumbY = MaxTravel * math.clamp(Scrolling.CanvasPosition.Y / MaxCanvas, 0, 1);

                ScrollThumb.Size = UDim2.new(0, 2, 0, ThumbHeight);
                ScrollThumb.Position = UDim2.new(0.5, 0, 0, ThumbY);
            end;

            local ViewTop = Scrolling.AbsolutePosition.Y;
            local ViewBottom = ViewTop + ViewportHeight;

            for _, Row in next, Scrolling:GetChildren() do
                if Row:IsA('CanvasGroup') and Row.Name == 'DropdownRow' then
                    local RowTop = Row.AbsolutePosition.Y;
                    local RowBottom = RowTop + Row.AbsoluteSize.Y;
                    local EdgeAmount = math.min(RowBottom - ViewTop, ViewBottom - RowTop);
                    local Reveal = math.clamp(EdgeAmount / 12, 0, 1);
                    local TargetTransparency = 1 - Reveal;

                    if Instant then
                        Row.GroupTransparency = TargetTransparency;
                    elseif math.abs(Row.GroupTransparency - TargetTransparency) > 0.015 then
                        Library:TweenProperty(Row, 'GroupTransparency', TargetTransparency, 0.12);
                    end;
                end;
            end;
        end;

        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
            UpdateDropdownScrollVisuals(false);
        end);
        Scrolling:GetPropertyChangedSignal('AbsoluteCanvasSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(false); end);
        end);
        Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(true); end);
        end);
        ListOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            task.defer(function() UpdateDropdownScrollVisuals(false); end);
        end);

'''
if drop.count(scroll_registry) != 1:
    raise SystemExit('scrolling registry missing')
drop = drop.replace(scroll_registry, scroll_visuals, 1)

row_old = r'''                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });
'''
row_new = r'''                local Button = Library:Create('CanvasGroup', {
                    Name = 'DropdownRow';
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    GroupTransparency = 1;
                    Size = UDim2.new(1, -5, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });
'''
if drop.count(row_old) != 1:
    raise SystemExit('dropdown row block missing')
drop = drop.replace(row_old, row_new, 1)

hover_old = r'''                Library:OnHighlight(Button, Button,
                    { BorderColor3 = 'AccentColor', ZIndex = 24 },
                    { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                );

'''
if drop.count(hover_old) != 1:
    raise SystemExit('dropdown row hover block missing')
drop = drop.replace(hover_old, '', 1)

source = source[:drop_start] + drop + source[drop_end:]

main_tab_start = source.index('    function Window:AddTab(Name)')
main_tab_end = source.index('        function Tab:AddGroupbox(Info)', main_tab_start)
main_tab = source[main_tab_start:main_tab_end]

main_block_old = r'''        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Parent = TabButton;
        });
'''
main_block_new = r'''        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 1, -1);
            Size = UDim2.new(1, -2, 0, 3);
            BackgroundTransparency = 1;
            ZIndex = 4;
            Parent = TabButton;
        });
'''
if main_tab.count(main_block_old) != 1:
    raise SystemExit('main tab blocker block missing')
main_tab = main_tab.replace(main_block_old, main_block_new, 1)

main_registry = r'''        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        });

'''
main_registry_new = main_registry + "        local SetTabAccentActive = Library:AddTabAccentCap(TabButton);\n\n"
if main_tab.count(main_registry) != 1:
    raise SystemExit('main blocker registry missing')
main_tab = main_tab.replace(main_registry, main_registry_new, 1)

main_show_old = r'''            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
'''
main_show_new = r'''            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            SetTabAccentActive(true);
            TabFrame.Visible = true;
'''
if main_tab.count(main_show_old) != 1:
    raise SystemExit('main tab show block missing')
main_tab = main_tab.replace(main_show_old, main_show_new, 1)

main_hide_old = r'''            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
'''
main_hide_new = r'''            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            SetTabAccentActive(false);
            TabFrame.Visible = false;
'''
if main_tab.count(main_hide_old) != 1:
    raise SystemExit('main tab hide block missing')
main_tab = main_tab.replace(main_hide_old, main_hide_new, 1)
source = source[:main_tab_start] + main_tab + source[main_tab_end:]

box_start = source.index('            function Tabbox:AddTab(Name)')
box_end = source.index('            Tab.Tabboxes[Info.Name or', box_start)
box = source[box_start:box_end]

box_block_old = r'''                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });
'''
box_block_new = r'''                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 1, 1, -1);
                    Size = UDim2.new(1, -2, 0, 3);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });
'''
if box.count(box_block_old) != 1:
    raise SystemExit('tabbox blocker block missing')
box = box.replace(box_block_old, box_block_new, 1)

box_registry = r'''                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

'''
box_registry_new = box_registry + "                local SetTabboxAccentActive = Library:AddTabAccentCap(Button);\n\n"
if box.count(box_registry) != 1:
    raise SystemExit('tabbox blocker registry missing')
box = box.replace(box_registry, box_registry_new, 1)

box_show_old = r'''                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
'''
box_show_new = r'''                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
                    SetTabboxAccentActive(true);

                    Tab:Resize();
'''
if box.count(box_show_old) != 1:
    raise SystemExit('tabbox show block missing')
box = box.replace(box_show_old, box_show_new, 1)

box_hide_old = r'''                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';

                    task.delay(0.14, function()
'''
box_hide_new = r'''                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                    SetTabboxAccentActive(false);

                    task.delay(0.14, function()
'''
if box.count(box_hide_old) != 1:
    raise SystemExit('tabbox hide block missing')
box = box.replace(box_hide_old, box_hide_new, 1)
source = source[:box_start] + box + source[box_end:]

checks = [
    "BorderSizePixel = 0;\n                Size = UDim2.fromOffset(GroupboxLabelWidth + 6, 16);",
    "Highlight.Position = UDim2.fromOffset(GroupboxLabelWidth + 16, 7);",
    "PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 9);",
    "PickerFrameInner.GroupTransparency = 1;",
    "Name = 'DropdownRow';",
    "local ScrollThumb = Library:Create('Frame'",
    "SetTabAccentActive(true);",
    "SetTabboxAccentActive(true);",
]
for token in checks:
    if token not in source:
        raise SystemExit('missing expected token: ' + token)

if 'local BottomEdge = Library:Create' in source[source.index('function Library:AddTopCorners'):source.index('function Library:ApplyTextStroke')]:
    raise SystemExit('bottom edge still present in top-corner helper')

path.write_text(source)
print('patched Library.lua')