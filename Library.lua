-- Forma public entrypoint.
--
-- Keep the implementation in LibraryCore.lua so text-rendering compatibility
-- fixes can be applied without duplicating the full library source here.
-- The immutable commit fallback keeps this branch runnable before the PR is
-- merged and LibraryCore.lua becomes available on main.

local CORE_URL = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/main/LibraryCore.lua';
local FALLBACK_URL = 'https://raw.githubusercontent.com/Fyntra-Development/Forma/a77bc83df9e1f45c19fb3fb6bba8a491d60df615/Library.lua';

local function LoadCore()
    local Source;
    local Success = pcall(function()
        Source = game:HttpGet(CORE_URL);
    end);

    if not Success or type(Source) ~= 'string' or Source == '' then
        Source = game:HttpGet(FALLBACK_URL);
    end;

    local Chunk, Error = loadstring(Source);
    assert(Chunk, 'Forma: failed to compile library core: ' .. tostring(Error));
    return Chunk();
end;

local Library = LoadCore();

-- TextBox text used to be rebuilt as one TextLabel per codepoint so individual
-- characters could fade/slide as they were typed. Prefix measurements include
-- the font's shaping/kerning, while each standalone glyph is rendered without
-- that same context. Proportional/custom fonts can therefore draw outside the
-- advance width assigned to an isolated character, producing visible overlaps.
--
-- Render the whole string in one label instead. Roblox then shapes the exact
-- string it displays, while Forma keeps its animated caret, focus color, font,
-- alignment, placeholder, and horizontal scrolling behavior.
function Library:EnableTypingAnimation(TextBox)
    if not TextBox or not TextBox:IsA('TextBox') then
        return nil;
    end

    if TextBox:GetAttribute('FormaTypingAnimation') then
        return Library.TypingControllers[TextBox];
    end
    TextBox:SetAttribute('FormaTypingAnimation', true);

    local Parent = TextBox.Parent;
    if not Parent then return nil; end

    local BaseSize = Library.BaseTextSizes[TextBox] or 14;
    local OriginalTextTransparency = TextBox.TextTransparency;
    local OriginalStrokeTransparency = TextBox.TextStrokeTransparency;

    local function GetTextColorKey()
        return TextBox:IsFocused() and 'AccentColor' or 'FontColor';
    end;

    local function SyncTextColor()
        local ColorKey = GetTextColorKey();
        TextBox.TextColor3 = Library[ColorKey];

        local TextBoxRegistryEntry = Library.RegistryMap[TextBox];
        if TextBoxRegistryEntry then
            TextBoxRegistryEntry.Properties.TextColor3 = ColorKey;
        end

        return ColorKey;
    end;

    local Layer = Library:Create('Frame', {
        Name = 'FormaTypingLayer';
        Active = false;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        ClipsDescendants = true;
        Position = TextBox.Position;
        Size = TextBox.Size;
        ZIndex = TextBox.ZIndex + 1;
        Parent = Parent;
    });

    local Placeholder = Library:CreateLabel({
        Active = false;
        Position = UDim2.fromScale(0, 0);
        Size = UDim2.fromScale(1, 1);
        Text = TextBox.PlaceholderText;
        TextColor3 = Library.DisabledTextColor;
        TextSize = BaseSize;
        TextTransparency = 0.14;
        TextXAlignment = TextBox.TextXAlignment;
        TextYAlignment = TextBox.TextYAlignment;
        ZIndex = Layer.ZIndex + 1;
        Parent = Layer;
    });
    Library.RegistryMap[Placeholder].Properties.TextColor3 = 'DisabledTextColor';

    local RenderedText = Library:CreateLabel({
        Active = false;
        BackgroundTransparency = 1;
        Position = UDim2.fromScale(0, 0);
        Size = UDim2.fromScale(1, 1);
        Text = TextBox.Text or '';
        TextColor3 = Library.FontColor;
        TextSize = BaseSize;
        TextXAlignment = TextBox.TextXAlignment;
        TextYAlignment = TextBox.TextYAlignment;
        TextWrapped = false;
        ZIndex = Layer.ZIndex + 2;
        Parent = Layer;
    });

    local Indicator = Library:Create('Frame', {
        Name = 'FormaTypingIndicator';
        AnchorPoint = Vector2.new(0, 0.5);
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 0.04;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, 0.5, 0);
        Size = UDim2.fromOffset(1, math.max(TextBox.TextSize - 2, 7));
        ZIndex = Layer.ZIndex + 3;
        Parent = Layer;
    });
    Library:AddToRegistry(Indicator, { BackgroundColor3 = 'AccentColor'; });
    Library:SetUnifiedFadeProgress(Indicator, 0);

    local Cache = Library.FadeBaselines[TextBox] or {};
    Cache.TextTransparency = 1;
    Cache.TextStrokeTransparency = 1;
    Library.FadeBaselines[TextBox] = Cache;
    TextBox.TextTransparency = 1;
    TextBox.TextStrokeTransparency = 1;

    local function Measure(Text)
        if Text == '' then return 0; end
        local Width = Library:GetTextBounds(
            Text,
            Library.Font,
            BaseSize,
            Vector2.new(100000, 100000)
        );
        return tonumber(Width) or 0;
    end;

    local function GetTextOrigin(TextWidth)
        local Available = math.max(TextBox.AbsoluteSize.X, 0);
        if TextBox.TextXAlignment == Enum.TextXAlignment.Center then
            return (Available - TextWidth) * 0.5;
        elseif TextBox.TextXAlignment == Enum.TextXAlignment.Right then
            return Available - TextWidth;
        end
        return 0;
    end;

    local function UpdateIndicator(Instant)
        local Cursor = TextBox.CursorPosition;
        local BeforeCursor = TextBox.Text or '';
        if Cursor and Cursor >= 1 then
            BeforeCursor = BeforeCursor:sub(1, Cursor - 1);
        end

        local X = GetTextOrigin(Measure(TextBox.Text or '')) + Measure(BeforeCursor);
        local Target = UDim2.new(0, X, 0.5, 0);
        Indicator.Size = UDim2.fromOffset(1, math.max(TextBox.TextSize - 2, 7));

        if Instant then
            Library:CancelMotion(Indicator, 'Position');
            Indicator.Position = Target;
        else
            Library:Animate(Indicator, { Position = Target }, 0.11, nil, 'TypingIndicator');
        end
    end;

    local function Rebuild()
        local Text = TextBox.Text or '';
        local TextColorKey = SyncTextColor();

        RenderedText.Text = Text;
        RenderedText.TextColor3 = Library[TextColorKey];
        RenderedText.TextXAlignment = TextBox.TextXAlignment;
        RenderedText.TextYAlignment = TextBox.TextYAlignment;
        RenderedText.TextSize = TextBox.TextSize;

        local RegistryEntry = Library.RegistryMap[RenderedText];
        if RegistryEntry then
            RegistryEntry.Properties.TextColor3 = TextColorKey;
        end

        Placeholder.Visible = Text == '';
        UpdateIndicator(true);
    end;

    local function SyncLayer()
        Layer.Position = TextBox.Position;
        Layer.Size = TextBox.Size;
        Layer.Visible = TextBox.Visible;
        Placeholder.Text = TextBox.PlaceholderText;
        Placeholder.TextXAlignment = TextBox.TextXAlignment;
        Placeholder.TextYAlignment = TextBox.TextYAlignment;
        RenderedText.TextXAlignment = TextBox.TextXAlignment;
        RenderedText.TextYAlignment = TextBox.TextYAlignment;
    end;

    TextBox:GetPropertyChangedSignal('Text'):Connect(Rebuild);
    TextBox:GetPropertyChangedSignal('CursorPosition'):Connect(function()
        UpdateIndicator(false);
    end);
    TextBox:GetPropertyChangedSignal('Position'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('Size'):Connect(function()
        SyncLayer();
        Rebuild();
    end);
    TextBox:GetPropertyChangedSignal('Visible'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('TextXAlignment'):Connect(function()
        SyncLayer();
        Rebuild();
    end);
    TextBox:GetPropertyChangedSignal('TextYAlignment'):Connect(SyncLayer);
    TextBox:GetPropertyChangedSignal('TextSize'):Connect(Rebuild);
    TextBox:GetPropertyChangedSignal('PlaceholderText'):Connect(SyncLayer);

    TextBox.Focused:Connect(function()
        Rebuild();
        UpdateIndicator(true);
        Library:TweenUnifiedFade(Indicator, 1, 0.16, nil, 'Fade');
    end);

    TextBox.FocusLost:Connect(function()
        Rebuild();
        Library:TweenUnifiedFade(Indicator, 0, 0.18, nil, 'Fade');
    end);

    SyncLayer();
    Rebuild();

    local Controller = {
        Layer = Layer;
        Text = RenderedText;
        Indicator = Indicator;
        Refresh = Rebuild;
        OriginalTextTransparency = OriginalTextTransparency;
        OriginalStrokeTransparency = OriginalStrokeTransparency;
    };
    Library.TypingControllers[TextBox] = Controller;
    return Controller;
end;

getgenv().Library = Library;
return Library;
