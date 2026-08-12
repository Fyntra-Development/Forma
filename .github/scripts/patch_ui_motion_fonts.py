from pathlib import Path
import re

path = Path('Library.lua')
source = path.read_text()


def sub_once(text, pattern, replacement, label, flags=re.S):
    updated, count = re.subn(pattern, replacement, text, count=1, flags=flags)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 replacement, got {count}')
    return updated


def replace_once(text, old, new, label):
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected 1 occurrence, got {count}')
    return text.replace(old, new, 1)


fonts_block = '''local Fonts = {
    ["Rubik Light"] = {
        Ttf = "Rubik-Light.ttf",
        RepoPath = "fonts/Rubik-Light.ttf",
        Url = RepoFontBaseUrl .. "fonts/Rubik-Light.ttf",
        FaceName = "Light",
        Weight = Enum.FontWeight.Light,
        WeightValue = 300,
    },
    Miracode = {
        Ttf = "Miracode.ttf",
        RepoPath = "fonts/Miracode.ttf",
        Url = RepoFontBaseUrl .. "fonts/Miracode.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    Monocraft = {
        Ttf = "Monocraft.ttf",
        RepoPath = "fonts/Monocraft.ttf",
        Url = RepoFontBaseUrl .. "fonts/Monocraft.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ProggyClean = {
        Ttf = "ProggyClean.ttf",
        RepoPath = "fonts/ProggyClean.ttf",
        Url = RepoFontBaseUrl .. "fonts/ProggyClean.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ProggyTiny = {
        Ttf = "ProggyTiny.ttf",
        RepoPath = "fonts/ProggyTiny.ttf",
        Url = RepoFontBaseUrl .. "fonts/ProggyTiny.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
    ["XP Tahoma"] = {
        Ttf = "XP-Tahoma.ttf",
        RepoPath = "fonts/XP-Tahoma.ttf",
        Url = RepoFontBaseUrl .. "fonts/XP-Tahoma.ttf",
        FaceName = "Bold",
        Weight = Enum.FontWeight.Bold,
        WeightValue = 700,
    },
    ["Smallest Pixel"] = {
        Ttf = "Smallest-Pixel.ttf",
        RepoPath = "fonts/Smallest-Pixel.ttf",
        Url = RepoFontBaseUrl .. "fonts/Smallest-Pixel.ttf",
        FaceName = "Regular",
        Weight = Enum.FontWeight.Regular,
        WeightValue = 400,
    },
};

local FontOrder = {
    "Rubik Light",
    "Miracode",
    "Monocraft",
    "ProggyClean",
    "ProggyTiny",
    "XP Tahoma",
    "Smallest Pixel",
};'''
source = sub_once(source, r'local Fonts = \{.*?\n\};\n\nlocal FontOrder = \{.*?\n\};', fonts_block, 'font table')

corner_anchor = '''    Corner.CornerRadius = UDim.new(0, Radius or 3);\n    return Corner;\nend;\n\nfunction Library:ApplyTextStroke'''
corner_helper = '''    Corner.CornerRadius = UDim.new(0, Radius or 3);\n    return Corner;\nend;\n\nfunction Library:AddTopCorners(Instance, Radius)\n    if not Instance then\n        return nil;\n    end;\n\n    Radius = Radius or 3;\n    Library:AddCorner(Instance, Radius);\n\n    local BottomSquare = Library:Create('Frame', {\n        BackgroundColor3 = Instance.BackgroundColor3;\n        BorderSizePixel = 0;\n        Position = UDim2.new(0, 0, 1, -Radius);\n        Size = UDim2.new(1, 0, 0, Radius);\n        ZIndex = Instance.ZIndex;\n        Parent = Instance;\n    });\n\n    local LeftEdge = Library:Create('Frame', {\n        BackgroundColor3 = Instance.BorderColor3;\n        BorderSizePixel = 0;\n        Position = UDim2.new(0, 0, 0, 0);\n        Size = UDim2.new(0, 1, 1, 0);\n        ZIndex = Instance.ZIndex;\n        Parent = BottomSquare;\n    });\n\n    local RightEdge = Library:Create('Frame', {\n        AnchorPoint = Vector2.new(1, 0);\n        BackgroundColor3 = Instance.BorderColor3;\n        BorderSizePixel = 0;\n        Position = UDim2.new(1, 0, 0, 0);\n        Size = UDim2.new(0, 1, 1, 0);\n        ZIndex = Instance.ZIndex;\n        Parent = BottomSquare;\n    });\n\n    local BottomEdge = Library:Create('Frame', {\n        AnchorPoint = Vector2.new(0, 1);\n        BackgroundColor3 = Instance.BorderColor3;\n        BorderSizePixel = 0;\n        Position = UDim2.new(0, 0, 1, 0);\n        Size = UDim2.new(1, 0, 0, 1);\n        ZIndex = Instance.ZIndex;\n        Parent = BottomSquare;\n    });\n\n    local function SyncTopCornerColors()\n        BottomSquare.BackgroundColor3 = Instance.BackgroundColor3;\n        LeftEdge.BackgroundColor3 = Instance.BorderColor3;\n        RightEdge.BackgroundColor3 = Instance.BorderColor3;\n        BottomEdge.BackgroundColor3 = Instance.BorderColor3;\n    end;\n\n    Instance:GetPropertyChangedSignal('BackgroundColor3'):Connect(SyncTopCornerColors);\n    Instance:GetPropertyChangedSignal('BorderColor3'):Connect(SyncTopCornerColors);\n\n    return BottomSquare;\nend;\n\nfunction Library:ApplyTextStroke'''
if 'function Library:AddTopCorners' not in source:
    source = replace_once(source, corner_anchor, corner_helper, 'top corner helper')

tooltip_start = source.index('function Library:AddToolTip')
tooltip_end = source.index('function Library:', tooltip_start + len('function Library:AddToolTip'))
tooltip = source[tooltip_start:tooltip_end]
tooltip = replace_once(tooltip, '''        Parent = Tooltip,\n    })\n\n    local Stroke = Library:Create('UIStroke', {''', '''        Parent = Tooltip,\n    })\n\n    Library:AddCorner(Content, 3);\n\n    local Stroke = Library:Create('UIStroke', {''', 'tooltip corner')
tooltip = replace_once(tooltip, 'LineJoinMode = Enum.LineJoinMode.Miter,', 'LineJoinMode = Enum.LineJoinMode.Round,', 'tooltip stroke join')
source = source[:tooltip_start] + tooltip + source[tooltip_end:]

slider_start = source.index('    function Funcs:AddSlider(Idx, Info)')
slider_end = source.index('    function Funcs:AddDropdown(Idx, Info)', slider_start)
slider = source[slider_start:slider_end]
slider = replace_once(slider, '''        local VisualConnection;\n        local IsDragging = false;''', '''        local VisualConnection;\n        local IsDragging = false;\n        local BadgeVisualX;\n        local BadgeTargetX = 0;''', 'slider badge state')
slider = sub_once(slider, r'''        local function RenderSliderVisual\(\).*?\n        end;\n\n        local function StopVisualAnimation''', '''        local function RenderSliderVisual(Delta, Instant)\n            local Width = TrackWidth();\n            VisualX = math.clamp(VisualX, 0, Width);\n            Fill.Size = UDim2.new(0, VisualX, 1, 0);\n\n            local ThumbX = SliderOuter.Position.X.Offset + VisualX;\n            Thumb.Position = UDim2.new(0, ThumbX, 0.5, 0);\n\n            local BadgeWidth = ValueBadge.Size.X.Offset;\n            local RowWidth = SliderRow.AbsoluteSize.X;\n            local PutRight = (ThumbX + 7 + BadgeWidth) <= RowWidth;\n            BadgeTargetX = PutRight and (ThumbX + 7) or (ThumbX - 7 - BadgeWidth);\n\n            if Instant or BadgeVisualX == nil then\n                BadgeVisualX = BadgeTargetX;\n            else\n                local BadgeAlpha = 1 - math.exp(-(Delta or (1 / 60)) * 22);\n                BadgeVisualX = BadgeVisualX + ((BadgeTargetX - BadgeVisualX) * BadgeAlpha);\n\n                if math.abs(BadgeTargetX - BadgeVisualX) <= 0.05 then\n                    BadgeVisualX = BadgeTargetX;\n                end;\n            end;\n\n            ValueBadge.AnchorPoint = Vector2.new(0, 0.5);\n            ValueBadge.Position = UDim2.new(0, BadgeVisualX, 0.5, 0);\n        end;\n\n        local function StopVisualAnimation''', 'slider render function')
slider = replace_once(slider, '''                RenderSliderVisual();\n\n                if not IsDragging and VisualX == TargetX then\n                    StopVisualAnimation();\n                end;''', '''                RenderSliderVisual(Delta, false);\n\n                local BadgeSettled = BadgeVisualX == nil or math.abs(BadgeTargetX - BadgeVisualX) <= 0.05;\n                if not IsDragging and VisualX == TargetX and BadgeSettled then\n                    StopVisualAnimation();\n                end;''', 'slider render loop')
slider = replace_once(slider, '''                VisualX = TargetX;\n                RenderSliderVisual();\n            else''', '''                VisualX = TargetX;\n                RenderSliderVisual(0, true);\n            else''', 'slider instant render')
slider = sub_once(slider, r'''        DecreaseOuter\.InputBegan:Connect\(function\(Input\).*?        IncreaseOuter\.InputBegan:Connect\(function\(Input\).*?        end\);\n\n        local function BeginDrag''', '''        local NudgeHoldSequence = 0;\n\n        local function BindNudgeButton(Button, Direction)\n            Button.InputBegan:Connect(function(Input)\n                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Library:MouseIsOverOpenedFrame() then\n                    return;\n                end;\n\n                NudgeHoldSequence = NudgeHoldSequence + 1;\n                local Sequence = NudgeHoldSequence;\n                Nudge(Direction);\n\n                task.spawn(function()\n                    local Started = os.clock();\n\n                    while Sequence == NudgeHoldSequence and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do\n                        local Elapsed = os.clock() - Started;\n\n                        if Elapsed < 0.35 then\n                            task.wait(0.025);\n                        else\n                            local Interval = math.max(0.035, 0.105 - math.min(Elapsed - 0.35, 2.4) * 0.028);\n                            task.wait(Interval);\n\n                            if Sequence == NudgeHoldSequence and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then\n                                Nudge(Direction);\n                            end;\n                        end;\n                    end;\n                end);\n            end);\n        end;\n\n        BindNudgeButton(DecreaseOuter, -1);\n        BindNudgeButton(IncreaseOuter, 1);\n\n        local function BeginDrag''', 'slider hold nudge')
slider = replace_once(slider, '''        SliderInner:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()\n            Slider:Display(true);\n        end);''', '''        SliderInner:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()\n            Slider:Display(false);\n        end);''', 'slider resize animation')
source = source[:slider_start] + slider + source[slider_end:]

drop_start = source.index('    function Funcs:AddDropdown(Idx, Info)')
drop_end = source.index('    function Funcs:AddDependencyBox()', drop_start)
drop = source[drop_start:drop_end]
drop = replace_once(drop, '''        local ListOuter = Library:Create('Frame', {\n            BackgroundColor3 = Color3.new(0, 0, 0);\n            BorderColor3 = Color3.new(0, 0, 0);\n            ClipsDescendants = true;''', '''        local ListOuter = Library:Create('Frame', {\n            BackgroundColor3 = Library.MainColor;\n            BorderColor3 = Library.OutlineColor;\n            BorderMode = Enum.BorderMode.Inset;\n            ClipsDescendants = true;''', 'dropdown outer colors')
drop = replace_once(drop, '''            Parent = ScreenGui;\n        });\n\n        local ListHeight = MAX_DROPDOWN_ITEMS * 20 + 2''', '''            Parent = ScreenGui;\n        });\n\n        Library:AddCorner(ListOuter, 3);\n        Library:AddToRegistry(ListOuter, {\n            BackgroundColor3 = 'MainColor';\n            BorderColor3 = 'OutlineColor';\n        });\n\n        local ListHeight = MAX_DROPDOWN_ITEMS * 20 + 2''', 'dropdown outer registry')
drop = replace_once(drop, 'DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1', 'DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset - 1', 'dropdown attached position')
drop = replace_once(drop, '''            Parent = ListOuter;\n        });\n\n        Library:AddToRegistry(ListInner, {''', '''            Parent = ListOuter;\n        });\n\n        Library:AddCorner(ListInner, 3);\n\n        Library:AddToRegistry(ListInner, {''', 'dropdown inner corner')
source = source[:drop_start] + drop + source[drop_end:]

color_start = source.index('    function Funcs:AddColorPicker')
color_end = source.index('    function Funcs:AddKeyPicker', color_start)
color = source[color_start:color_end]
color = replace_once(color, '''            Parent = PickerFrameOuter;\n        });\n\n        local Highlight = Library:Create('Frame', {''', '''            Parent = PickerFrameOuter;\n        });\n\n        Library:AddCorner(PickerFrameOuter, 3);\n        Library:AddCorner(PickerFrameInner, 3);\n\n        local Highlight = Library:Create('Frame', {''', 'color picker corners')
show_anchor = '        function ColorPicker:Show()'
if show_anchor not in color:
    raise SystemExit('color picker show anchor missing')
color_anim_helpers = '''        local PickerOpenSize = PickerFrameOuter.Size;\n        local PickerOuterTransparency = PickerFrameOuter.BackgroundTransparency;\n        local PickerInnerTransparency = PickerFrameInner.BackgroundTransparency;\n        local PickerAnimationId = 0;\n        local PickerTweens = {};\n\n        local function CancelPickerTweens()\n            for _, Tween in next, PickerTweens do\n                pcall(function() Tween:Cancel(); end);\n            end;\n            table.clear(PickerTweens);\n        end;\n\n        local function PlayPickerTween(Instance, InfoValue, Properties)\n            local Tween = TweenService:Create(Instance, InfoValue, Properties);\n            table.insert(PickerTweens, Tween);\n            Tween:Play();\n            return Tween;\n        end;\n\n'''
color = color.replace(show_anchor, color_anim_helpers + show_anchor, 1)
color = sub_once(color, r'''        function ColorPicker:Show\(\).*?        function ColorPicker:SetValue\(HSV, Transparency\)''', '''        function ColorPicker:Show()\n            for Frame in next, Library.OpenedFrames do\n                if Frame.Name == 'Color' and Frame ~= PickerFrameOuter then\n                    Frame.Visible = false;\n                    Library.OpenedFrames[Frame] = nil;\n                end;\n            end;\n\n            PickerAnimationId = PickerAnimationId + 1;\n            CancelPickerTweens();\n\n            if not PickerFrameOuter.Visible then\n                PickerFrameOuter.Size = UDim2.fromOffset(PickerOpenSize.X.Offset, 0);\n                PickerFrameOuter.BackgroundTransparency = 1;\n                PickerFrameInner.BackgroundTransparency = 1;\n            end;\n\n            PickerFrameOuter.ClipsDescendants = true;\n            PickerFrameOuter.Visible = true;\n            Library.OpenedFrames[PickerFrameOuter] = true;\n\n            local ExpandInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out);\n            local FadeInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);\n\n            PlayPickerTween(PickerFrameOuter, ExpandInfo, {\n                Size = PickerOpenSize;\n                BackgroundTransparency = PickerOuterTransparency;\n            });\n            PlayPickerTween(PickerFrameInner, FadeInfo, {\n                BackgroundTransparency = PickerInnerTransparency;\n            });\n        end;\n\n        function ColorPicker:Hide()\n            if not PickerFrameOuter.Visible then\n                Library.OpenedFrames[PickerFrameOuter] = nil;\n                return;\n            end;\n\n            PickerAnimationId = PickerAnimationId + 1;\n            local CurrentId = PickerAnimationId;\n            CancelPickerTweens();\n            Library.OpenedFrames[PickerFrameOuter] = nil;\n\n            local CollapseInfo = TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut);\n            local FadeInfo = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);\n\n            local CollapseTween = PlayPickerTween(PickerFrameOuter, CollapseInfo, {\n                Size = UDim2.fromOffset(PickerOpenSize.X.Offset, 0);\n                BackgroundTransparency = 1;\n            });\n            PlayPickerTween(PickerFrameInner, FadeInfo, {\n                BackgroundTransparency = 1;\n            });\n\n            CollapseTween.Completed:Connect(function()\n                if CurrentId ~= PickerAnimationId then\n                    return;\n                end;\n\n                PickerFrameOuter.Visible = false;\n                PickerFrameOuter.Size = PickerOpenSize;\n                PickerFrameOuter.BackgroundTransparency = PickerOuterTransparency;\n                PickerFrameInner.BackgroundTransparency = PickerInnerTransparency;\n            end);\n        end;\n\n        function ColorPicker:SetValue(HSV, Transparency)''', 'color picker show hide')
source = source[:color_start] + color + source[color_end:]

dep_start = source.index('    function Funcs:AddDependencyBox()')
dep_tail_match = re.search(r'''    function Funcs:AddDependencyBox\(\).*?\n        return Depbox;\n    end;''', source[dep_start:], flags=re.S)
if not dep_tail_match:
    raise SystemExit('dependency box scope missing')
dep_end = dep_start + dep_tail_match.end()
dep = source[dep_start:dep_end]
dep = replace_once(dep, '''        local Holder = Library:Create('Frame', {\n            BackgroundTransparency = 1;\n            Size = UDim2.new(1, 0, 0, 0);\n            Visible = false;\n            Parent = Container;\n        });''', '''        local Holder = Library:Create('CanvasGroup', {\n            BackgroundTransparency = 1;\n            ClipsDescendants = true;\n            GroupTransparency = 1;\n            Size = UDim2.new(1, 0, 0, 0);\n            Visible = false;\n            Parent = Container;\n        });''', 'dependency canvas group')
dep = sub_once(dep, r'''        function Depbox:Resize\(\).*?        function Depbox:SetupDependencies\(Dependencies\)''', '''        local DependencyAnimationId = 0;\n        local DependencySizeTween;\n        local DependencyFadeTween;\n        local DependencyVisible = false;\n\n        local function CancelDependencyTweens()\n            if DependencySizeTween then\n                pcall(function() DependencySizeTween:Cancel(); end);\n                DependencySizeTween = nil;\n            end;\n\n            if DependencyFadeTween then\n                pcall(function() DependencyFadeTween:Cancel(); end);\n                DependencyFadeTween = nil;\n            end;\n        end;\n\n        local function SetDependencyVisible(Visible, Instant)\n            DependencyAnimationId = DependencyAnimationId + 1;\n            local CurrentId = DependencyAnimationId;\n            CancelDependencyTweens();\n\n            local Height = Layout.AbsoluteContentSize.Y;\n            DependencyVisible = Visible;\n\n            if Visible then\n                if not Holder.Visible then\n                    Holder.Visible = true;\n                    Holder.Size = UDim2.new(1, 0, 0, 0);\n                    Holder.GroupTransparency = 1;\n                end;\n\n                if Instant then\n                    Holder.Size = UDim2.new(1, 0, 0, Height);\n                    Holder.GroupTransparency = 0;\n                    Groupbox:Resize();\n                    return;\n                end;\n\n                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, Height) });\n                DependencyFadeTween = TweenService:Create(Holder, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 });\n                DependencySizeTween:Play();\n                DependencyFadeTween:Play();\n            else\n                if not Holder.Visible then\n                    Holder.Size = UDim2.new(1, 0, 0, 0);\n                    Holder.GroupTransparency = 1;\n                    Groupbox:Resize();\n                    return;\n                end;\n\n                if Instant then\n                    Holder.Size = UDim2.new(1, 0, 0, 0);\n                    Holder.GroupTransparency = 1;\n                    Holder.Visible = false;\n                    Groupbox:Resize();\n                    return;\n                end;\n\n                DependencySizeTween = TweenService:Create(Holder, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Size = UDim2.new(1, 0, 0, 0) });\n                DependencyFadeTween = TweenService:Create(Holder, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 });\n\n                DependencySizeTween.Completed:Connect(function()\n                    if CurrentId ~= DependencyAnimationId or DependencyVisible then\n                        return;\n                    end;\n                    Holder.Visible = false;\n                    Groupbox:Resize();\n                end);\n\n                DependencySizeTween:Play();\n                DependencyFadeTween:Play();\n            end;\n        end;\n\n        function Depbox:Resize(Instant)\n            local Height = Layout.AbsoluteContentSize.Y;\n            if DependencyVisible and Holder.Visible then\n                if Instant then\n                    Holder.Size = UDim2.new(1, 0, 0, Height);\n                else\n                    Library:TweenProperty(Holder, 'Size', UDim2.new(1, 0, 0, Height), 0.18);\n                end;\n            end;\n            Groupbox:Resize();\n        end;\n\n        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()\n            Depbox:Resize(false);\n        end);\n\n        Holder:GetPropertyChangedSignal('Size'):Connect(function()\n            Groupbox:Resize();\n        end);\n\n        function Depbox:Update()\n            local ShouldShow = true;\n            for _, Dependency in next, Depbox.Dependencies do\n                local Elem = Dependency[1];\n                local Value = Dependency[2];\n                if Elem.Type == 'Toggle' and Elem.Value ~= Value then\n                    ShouldShow = false;\n                    break;\n                end;\n            end;\n            SetDependencyVisible(ShouldShow, false);\n        end;\n\n        function Depbox:SetupDependencies(Dependencies)''', 'dependency animation block')
source = source[:dep_start] + dep + source[dep_end:]

source = sub_once(source, r'''(        local TabButton = Library:Create\('Frame', \{.*?            Parent = TabArea;\n        \}\);)''', r'''\1\n\n        Library:AddTopCorners(TabButton, 3);''', 'main tab top corners')
source = sub_once(source, r'''(                local Button = Library:Create\('Frame', \{\n                    BackgroundColor3 = Library.MainColor;\n                    BorderColor3 = Color3.new\(0, 0, 0\);\n                    Size = UDim2.new\(0.5, 0, 1, 0\);\n                    ZIndex = 6;\n                    Parent = TabboxButtons;\n                \}\);)''', r'''\1\n\n                Library:AddTopCorners(Button, 3);''', 'tabbox top corners')

group_start = source.index('        function Tab:AddGroupbox(Info)')
group_end = source.index('        function Tab:AddLeftGroupbox', group_start)
group = source[group_start:group_end]
group = replace_once(group, '''            local GroupboxLabel = Library:CreateLabel({\n                Size = UDim2.new(1, 0, 0, 18);\n                Position = UDim2.new(0, 4, 0, 2);''', '''            local GroupboxLabelWidth = Library:GetTextBounds(Info.Name, Library.Font, 14);\n            local GroupboxLabel = Library:CreateLabel({\n                BackgroundColor3 = Library.BackgroundColor;\n                BackgroundTransparency = 0;\n                Size = UDim2.fromOffset(GroupboxLabelWidth + 8, 16);\n                Position = UDim2.new(0, 6, 0, -7);''', 'groupbox inline label')
group = replace_once(group, '''                Parent = BoxInner;\n            });\n\n            local Container = Library:Create('Frame', {''', '''                Parent = BoxInner;\n            });\n\n            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';\n            Highlight.Position = UDim2.fromOffset(GroupboxLabelWidth + 18, 0);\n            Highlight.Size = UDim2.new(1, -(GroupboxLabelWidth + 18), 0, 2);\n\n            local Container = Library:Create('Frame', {''', 'groupbox legend line')
source = source[:group_start] + group + source[group_end:]

required = ["Library:LoadFont('Rubik Light')", 'local BadgeVisualX;', 'BindNudgeButton(DecreaseOuter, -1);', "Library:AddCorner(Content, 3);", "Library:Create('CanvasGroup'", 'SetDependencyVisible(ShouldShow, false);', 'Library:AddTopCorners(TabButton, 3);', 'Library:AddTopCorners(Button, 3);', 'GroupboxLabelWidth', 'fonts/ProggyClean.ttf', 'fonts/ProggyTiny.ttf', 'fonts/XP-Tahoma.ttf', 'fonts/Smallest-Pixel.ttf']
for token in required:
    if token not in source:
        raise SystemExit(f'missing required token after patch: {token}')

if source.count('function Library:AddTopCorners') != 1:
    raise SystemExit('AddTopCorners helper count invalid')
if source.count('function Funcs:AddSlider(Idx, Info)') != 1:
    raise SystemExit('slider function count invalid')
if source.count('function ColorPicker:Show()') < 1 or source.count('function ColorPicker:Hide()') < 1:
    raise SystemExit('color picker animation functions missing')

path.write_text(source)
