from pathlib import Path
import re

path = Path('Library.lua')
source = path.read_text()


def replace_once(old, new, label):
    global source
    count = source.count(old)
    assert count == 1, f'{label}: expected 1 match, found {count}'
    source = source.replace(old, new, 1)


# Replace the tab corner helper and active accent cap with geometry that cannot
# produce bottom ticks or depend on AbsoluteSize being initialized at creation.
start = source.index('function Library:AddTopCorners(Instance, Radius)')
end = source.index('function Library:ApplyTextStroke(Inst)', start)
source = source[:start] + '''function Library:AddTopCorners(Instance, Radius)
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
        ZIndex = Instance.ZIndex;
        Parent = Instance;
    });

    Instance:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
        BottomSquare.BackgroundColor3 = Instance.BackgroundColor3;
    end);

    return BottomSquare;
end;

function Library:AddTabAccentCap(Instance)
    local Cap = Library:Create('Frame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(1, 1);
        ZIndex = Instance.ZIndex + 5;
        Parent = Instance;
    });

    local Top = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 2, 0, 0);
        Size = UDim2.new(1, -4, 0, 1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    local Left = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0, 1);
        Size = UDim2.new(0, 1, 0.62, -1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    local Right = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0);
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(1, 0, 0, 1);
        Size = UDim2.new(0, 1, 0.62, -1);
        ZIndex = Cap.ZIndex;
        Parent = Cap;
    });

    for _, Side in ipairs({ Left, Right }) do
        Library:Create('UIGradient', {
            Rotation = 90;
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0.25),
                NumberSequenceKeypoint.new(1, 1),
            });
            Parent = Side;
        });
    end;

    for _, Element in ipairs({ Top, Left, Right }) do
        Library:AddToRegistry(Element, {
            BackgroundColor3 = 'AccentColor';
        });
    end;

    local function SetActive(Active)
        local Transparency = Active and 0 or 1;
        for _, Element in ipairs({ Top, Left, Right }) do
            Library:TweenProperty(Element, 'BackgroundTransparency', Transparency, 0.18);
        end;
    end;

    SetActive(false);
    return SetActive;
end;

''' + source[end:]

# Make the entire color picker one CanvasGroup and keep the inner visual frame
# normal. This makes GroupTransparency affect the popup as a whole.
replace_once("local PickerFrameOuter = Library:Create('Frame', {", "local PickerFrameOuter = Library:Create('CanvasGroup', {", 'picker outer canvas group')
replace_once("local PickerFrameInner = Library:Create('CanvasGroup', {", "local PickerFrameInner = Library:Create('Frame', {", 'picker inner frame')

picker_start = source.index('        local PickerOpenSize = PickerFrameOuter.Size;')
picker_end = source.index('        function ColorPicker:SetValue(HSV, Transparency)', picker_start)
source = source[:picker_start] + '''        local PickerAnimationId = 0;
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
                PickerFrameOuter.Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 8);
                PickerFrameOuter.GroupTransparency = 1;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;

            PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = TargetPosition;
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
            local ExitTween = PlayPickerTween(PickerFrameOuter, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(TargetPosition.X.Offset, TargetPosition.Y.Offset - 5);
                GroupTransparency = 1;
            });

            ExitTween.Completed:Connect(function()
                if CurrentId ~= PickerAnimationId then
                    return;
                end;

                PickerFrameOuter.Visible = false;
                PickerFrameOuter.Position = TargetPosition;
                PickerFrameOuter.GroupTransparency = 0;
                table.clear(PickerTweens);
            end);
        end;

''' + source[picker_end:]

# Slider value badge: make the hit target explicit and add a numeric editor.
replace_once("        local ValueBadge = Library:Create('Frame', {\n            AnchorPoint = Vector2.new(0, 0.5);", "        local ValueBadge = Library:Create('Frame', {\n            Active = true;\n            AnchorPoint = Vector2.new(0, 0.5);", 'slider badge active')

value_label_marker = '''        local ValueLabel = Library:CreateLabel({
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(1, 1);
            Text = tostring(Slider.Value);
            TextSize = 13;
            ZIndex = 12;
            Parent = ValueBadge;
        });
'''
assert value_label_marker in source, 'slider value label marker missing'
source = source.replace(value_label_marker, value_label_marker + '''
        local ValueEditHitbox = Library:Create('TextButton', {
            AutoButtonColor = false;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1, 1);
            Text = '';
            ZIndex = 13;
            Parent = ValueBadge;
        });

        local ValueEditor = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ClearTextOnFocus = false;
            Size = UDim2.fromScale(1, 1);
            Text = tostring(Slider.Value);
            TextColor3 = Library.FontColor;
            TextSize = 13;
            TextStrokeTransparency = 0;
            Visible = false;
            ZIndex = 14;
            Parent = ValueBadge;
        });

        Library:ApplyFont(ValueEditor);
        Library:ApplyTextStroke(ValueEditor);
        Library:AddToRegistry(ValueEditor, {
            TextColor3 = 'FontColor';
        });
''', 1)

nudge_marker = '''        local function Nudge(Direction)
            Slider:SetValue(Slider.Value + (Slider.Step * Direction));
            Library:AttemptSave();
        end;
'''
assert nudge_marker in source, 'slider nudge marker missing'
source = source.replace(nudge_marker, '''        local LastValueBadgeClick = 0;

        local function BeginValueEdit()
            ValueEditor.Text = tostring(Slider.Value);
            ValueEditor.Visible = true;
            ValueLabel.Visible = false;

            task.defer(function()
                if not ValueEditor.Visible then
                    return;
                end;

                ValueEditor:CaptureFocus();
                ValueEditor.CursorPosition = #ValueEditor.Text + 1;
                ValueEditor.SelectionStart = 1;
            end);
        end;

        ValueEditHitbox.MouseButton1Click:Connect(function()
            local Now = os.clock();

            if Now - LastValueBadgeClick <= 0.3 then
                LastValueBadgeClick = 0;
                BeginValueEdit();
            else
                LastValueBadgeClick = Now;
            end;
        end);

        ValueEditor.FocusLost:Connect(function()
            local TypedValue = tonumber(ValueEditor.Text);

            if TypedValue then
                Slider:SetValue(TypedValue);
                Library:AttemptSave();
            end;

            ValueEditor.Visible = false;
            ValueLabel.Visible = true;
            ValueEditor.Text = tostring(Slider.Value);
        end);

''' + nudge_marker, 1)

# Dropdown: use a single container fade and remove per-row edge fades.
replace_once("        local ListInner = Library:Create('Frame', {\n            BackgroundColor3 = Library.MainColor;\n            BackgroundTransparency = 1;", "        local ListInner = Library:Create('CanvasGroup', {\n            BackgroundColor3 = Library.MainColor;\n            BackgroundTransparency = 1;\n            GroupTransparency = 1;", 'dropdown list canvas group')
replace_once('            DropdownGradient:Clone().Parent = ListInner;', '            DropdownGradient:Clone().Parent = ListOuter;', 'dropdown gradient surface')

scroll_start = source.index('        local function UpdateDropdownScrollVisuals(Instant)')
scroll_end = source.index("        Scrolling:GetPropertyChangedSignal('CanvasPosition'):Connect(function()", scroll_start)
source = source[:scroll_start] + '''        local function UpdateDropdownScrollVisuals()
            local ViewportHeight = Scrolling.AbsoluteSize.Y;
            local ContentHeight = Scrolling.AbsoluteCanvasSize.Y;

            if ViewportHeight <= 0 then
                ScrollTrack.Visible = false;
                return;
            end;

            local Scrollable = ContentHeight > ViewportHeight + 1;
            ScrollTrack.Visible = Scrollable;

            if not Scrollable then
                return;
            end;

            local TrackHeight = math.max(ScrollTrack.AbsoluteSize.Y, 1);
            local ThumbHeight = math.clamp(TrackHeight * (ViewportHeight / ContentHeight), 18, TrackHeight);
            local MaxTravel = math.max(TrackHeight - ThumbHeight, 0);
            local MaxCanvas = math.max(ContentHeight - ViewportHeight, 1);
            local ThumbY = MaxTravel * math.clamp(Scrolling.CanvasPosition.Y / MaxCanvas, 0, 1);

            ScrollThumb.Size = UDim2.new(0, 2, 0, ThumbHeight);
            ScrollThumb.Position = UDim2.new(0.5, 0, 0, ThumbY);
        end;

''' + source[scroll_end:]

old_row = '''                local Button = Library:Create('CanvasGroup', {
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
new_row = '''                local Button = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, -5, 0, 20);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });
'''
replace_once(old_row, new_row, 'dropdown row frame')
replace_once("            PlayDropdownTween(ListInner, FadeInfo, {\n                BackgroundTransparency = 0,\n            })", "            PlayDropdownTween(ListInner, FadeInfo, {\n                GroupTransparency = 0,\n            })", 'dropdown open group fade')
replace_once("            PlayDropdownTween(ListInner, FadeInfo, {\n                BackgroundTransparency = 1,\n            })", "            PlayDropdownTween(ListInner, FadeInfo, {\n                GroupTransparency = 1,\n            })", 'dropdown close group fade')

# Main tabs: no per-tab border/ticks; active tab bridge fully erases the content
# top border beneath it. The active accent cap is handled separately above.
main_tab_marker = '''        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 1;
            Parent = TabArea;
        });
'''
main_tab_new = '''        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 3;
            Parent = TabArea;
        });
'''
replace_once(main_tab_marker, main_tab_new, 'main tab surface')
replace_once("            ZIndex = 1;\n            Parent = TabButton;\n        });\n\n        local Blocker", "            ZIndex = 4;\n            Parent = TabButton;\n        });\n\n        local Blocker", 'main tab label layer')

main_blocker = '''        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 1, -1);
            Size = UDim2.new(1, -2, 0, 3);
            BackgroundTransparency = 1;
            ZIndex = 4;
            Parent = TabButton;
        });
'''
main_blocker_new = '''        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, -1, 1, -1);
            Size = UDim2.new(1, 2, 0, 4);
            BackgroundTransparency = 1;
            ZIndex = 8;
            Parent = TabButton;
        });
'''
replace_once(main_blocker, main_blocker_new, 'main tab bridge')

# Tabbox tabs get the same no-tick geometry.
tabbox_button = '''                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });
'''
tabbox_button_new = '''                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });
'''
replace_once(tabbox_button, tabbox_button_new, 'tabbox surface')

tabbox_block = '''                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 1, 1, -1);
                    Size = UDim2.new(1, -2, 0, 3);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });
'''
tabbox_block_new = '''                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, -1, 1, -1);
                    Size = UDim2.new(1, 2, 0, 4);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });
'''
replace_once(tabbox_block, tabbox_block_new, 'tabbox bridge')

# Groupboxes: remove the accent rule and use a centered inline legend that masks
# the top border behind the title.
group_start = source.index('        function Tab:AddGroupbox(Info)')
group_end = source.index('        function Tab:AddLeftGroupbox(Name)', group_start)
group = source[group_start:group_end]
legend_start = group.index("            local Highlight = Library:Create('Frame', {")
container_start = group.index("            local Container = Library:Create('Frame', {", legend_start)
legend = '''            local GroupboxLabelWidth = Library:GetTextBounds(Info.Name, Library.Font, 14);
            local GroupboxLabel = Library:CreateLabel({
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Library.BackgroundColor;
                BackgroundTransparency = 0;
                BorderSizePixel = 0;
                Size = UDim2.fromOffset(GroupboxLabelWidth + 12, 16);
                Position = UDim2.new(0.5, 0, 0, 0);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Center;
                ZIndex = 6;
                Parent = BoxInner;
            });

            Library.RegistryMap[GroupboxLabel].Properties.BackgroundColor3 = 'BackgroundColor';

'''
group = group[:legend_start] + legend + group[container_start:]
source = source[:group_start] + group + source[group_end:]

path.write_text(source)
print('patched Library.lua')
