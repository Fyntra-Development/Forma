export type ThemeColors = {
    FontColor: Color3,
    MainColor: Color3,
    BackgroundColor: Color3,
    AccentColor: Color3,
    BlendShade: Color3,
    UpperGradient: Color3,
    LowerGradient: Color3,
    OutlineColor: Color3,
    DisabledTextColor: Color3,
    Contrast: Color3,
    Inline: Color3,
    RiskColor: Color3,
}

export type KeybindMode = "Always" | "Toggle" | "Hold"

export type WindowOptions = {
    Title: string?,
    GameName: string?,
    Game: string?,
    Subtitle: string?,
    Center: boolean?,
    AutoShow: boolean?,
    Position: UDim2?,
    Size: UDim2?,
    AnchorPoint: Vector2?,
    Resizable: boolean?,
    MinSize: Vector2?,
    MaxSize: Vector2?,
    MenuFadeTime: number?,
    TabPadding: number?,
}

export type UtilityOptions = {
    Title: string?,
    Id: string?,
    Visible: boolean?,
    Width: number?,
    Height: number?,
    Position: UDim2?,
    CloseButton: boolean?,
    Resizable: boolean?,
    MinSize: Vector2?,
    MaxSize: Vector2?,
    TitleAccent: boolean?,
}

export type ToggleOptions = {
    Text: string,
    Default: boolean?,
    Tooltip: string?,
    Risky: boolean?,
    Callback: ((boolean) -> ())?,
}

export type SliderOptions = {
    Text: string,
    Default: number,
    Min: number,
    Max: number,
    Rounding: number,
    Step: number?,
    Increment: number?,
    Suffix: string?,
    Compact: boolean?,
    Tooltip: string?,
    Callback: ((number) -> ())?,
}

export type RangeSliderOptions = {
    Text: string,
    Default: number | { Min: number?, Max: number?, [number]: number },
    Min: number,
    Max: number,
    Rounding: number,
    Step: number?,
    Tooltip: string?,
    Callback: ((any) -> ())?,
}

export type DropdownOptions = {
    Text: string?,
    Values: { string },
    Default: string | number | { [string]: boolean }?,
    Multi: boolean?,
    AllowNull: boolean?,
    AllowDeselect: boolean?,
    RequireSelection: boolean?,
    Searchable: boolean?,
    Compact: boolean?,
    SpecialType: ("Player" | "Team")?,
    Tooltip: string?,
    Callback: ((any) -> ())?,
}

export type InputOptions = {
    Text: string,
    Default: string | number?,
    Numeric: boolean?,
    Finished: boolean?,
    Placeholder: string?,
    Tooltip: string?,
    Callback: ((any) -> ())?,
}

export type ButtonOptions = {
    Text: string,
    Func: ((...any) -> ())?,
    DoubleClick: boolean?,
    Warning: boolean?,
    ConfirmDuration: number?,
    Tooltip: string?,
}

export type KeyPickerOptions = {
    Default: string,
    Text: string?,
    Mode: KeybindMode?,
    Modes: { KeybindMode }?,
    NoUI: boolean?,
    SyncToggleState: boolean?,
    Callback: ((boolean) -> ())?,
    ChangedCallback: ((string) -> ())?,
}

export type ColorPickerSettings = {
    Mode: ("Solid" | "Fade" | "Rainbow")?,
    Speed: number?,
    Color1: Color3?,
    Color2: Color3?,
}

export type ColorPickerOptions = {
    Default: Color3,
    Transparency: number?,
    Settings: boolean | ColorPickerSettings?,
    EnableSettings: boolean?,
    Callback: ((Color3) -> ())?,
}

export type NotificationOptions = {
    Title: string?,
    Text: string?,
    Message: string?,
    Duration: number?,
    Persistent: boolean?,
    CloseButton: boolean?,
    Type: string?,
}

export type DialogButton = {
    Text: string,
    Value: any?,
    Accent: boolean?,
    Close: boolean?,
    Callback: ((any) -> any)?,
}

export type DialogOptions = {
    Title: string?,
    Text: string?,
    Width: number?,
    DismissOnBackdrop: boolean?,
    CloseOnEscape: boolean?,
    Buttons: { DialogButton }?,
    OnClose: ((string) -> ())?,
}

export type ValueControl<T> = {
    Value: T,
    SetValue: (self: any, value: T) -> (),
    OnChanged: (self: any, callback: (T) -> ()) -> (),
}

export type KeyPicker = ValueControl<string> & {
    Mode: KeybindMode,
    SetValue: (self: any, data: { any }) -> (),
}

export type Groupbox = {
    AddToggle: (self: any, id: string, options: ToggleOptions) -> ValueControl<boolean>,
    AddSlider: (self: any, id: string, options: SliderOptions) -> ValueControl<number>,
    AddRangeSlider: (self: any, id: string, options: RangeSliderOptions) -> any,
    AddDropdown: (self: any, id: string, options: DropdownOptions) -> any,
    AddInput: (self: any, id: string, options: InputOptions) -> any,
    AddLabel: (self: any, text: string, wrap: boolean?) -> any,
    AddDivider: (self: any) -> (),
    AddButton: (self: any, info: ButtonOptions | string, callback: ((...any) -> ())?) -> any,
    AddDependencyBox: (self: any) -> any,
}

export type Tab = {
    AddLeftGroupbox: (self: any, title: string) -> Groupbox,
    AddRightGroupbox: (self: any, title: string) -> Groupbox,
    AddFullGroupbox: (self: any, title: string) -> Groupbox,
    AddLeftTabbox: (self: any, title: string) -> any,
    AddRightTabbox: (self: any, title: string) -> any,
}

export type Window = {
    Tabs: { [string]: Tab },
    AddTab: (self: any, name: string, icon: any?, options: any?) -> Tab,
    Holder: Frame,
}

export type UtilityWindow = {
    Frame: Frame,
    Visible: boolean,
    SetVisible: (self: any, visible: boolean, instant: boolean?) -> (),
    Toggle: (self: any) -> (),
    SetPosition: (self: any, position: UDim2, animate: boolean?) -> (),
    SetSize: (self: any, width: number | Vector2, height: number?) -> (),
    Destroy: (self: any) -> (),
}

export type AnchorSnapProfile = {
    Enabled: boolean,
    Distance: number,
    ReleaseDistance: number,
    Margin: number,
    ShowGuides: boolean,
    SnapToWindows: boolean,
    GlowGuides: boolean,
}

export type Library = ThemeColors & {
    Version: string,
    Release: string,
    CreateWindow: (self: any, options: WindowOptions) -> Window,
    CreateUtilityWindow: (self: any, options: UtilityOptions) -> UtilityWindow,
    CreateConsole: (self: any, options: UtilityOptions?) -> UtilityWindow,
    CreateTable: (self: any, options: UtilityOptions?) -> UtilityWindow,
    CreateDataTable: (self: any, options: UtilityOptions?) -> UtilityWindow,
    CreateChat: (self: any, options: UtilityOptions?) -> UtilityWindow,
    CreateCardGrid: (self: any, options: UtilityOptions?) -> UtilityWindow,
    CreateTargetHUD: (self: any, options: any?) -> any,
    SetKeybindVisibility: (self: any, visible: boolean, instant: boolean?) -> (),
    IsKeybindVisible: (self: any) -> boolean,
    SetWatermarkVisibility: (self: any, visible: boolean) -> (),
    Notify: (self: any, info: string | NotificationOptions, duration: number?, title: string?) -> any,
    Dialog: (self: any, info: string | DialogOptions) -> any,
    UpdateColorsUsingRegistry: (self: any) -> (),
    Unload: (self: any) -> (),
}

export type Loader = {
    Library: Library,
    LoadAddon: (self: any, name: string) -> any,
}

return {}
