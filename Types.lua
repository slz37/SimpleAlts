---@alias Color table<string, number>
---@alias FontFlag string
---@alias CheckboxGetter fun(...): boolean
---@alias CheckboxSetter fun(...)
---@alias DropdownGetter fun(...): string
---@alias DropdownSetter fun(...)

---@class simpleAlts
---@field defaultFont string
---@field defaultTexture string
---@field colors table<string, Color>
---@field fonts table<string, FontObject>
---@field unitEventData table<string, any>
---@field unitFramePool table<string, any>
---@field OptionsFrame Frame
---@field ToggleMinimapButton fun()
---@field ToggleOptions fun()
---@field RegisterEventHandler fun(event: string, func: fun(...))
---@field UnregisterEventHandler fun(event: string, func: fun(...))
---@field EnsureDB fun()
---@field CreateFlatBackdrop fun(Frame: Frame, bgAlpha: number?, borderAlpha: number?)
---@field CreateResizeButton fun(Parent: Frame): Button
---@field CreateXButton fun(size: number, Parent: Frame, anchorPoint: string, AnchorFrame: Frame, relativePoint: string, xOffset: number, yOffset: number, tooltipText: string?, onClick: fun()?): Button
---@field AcquireRow fun(name: string, data: table<string, any>): CharacterRow
---@field DeleteRow fun(name: string)
---@field CreateArrowButton fun(size: number, Parent: Frame, anchorPoint: string, AnchorFrame: Frame, relativePoint: string, xOffset: number, yOffset: number, pointsUp: boolean, tooltipText: string): Button
---@field StyleScrollBar fun(ScrollFrame: Frame|Slider, orientation: string?): Slider
---@field CreateScrollbar fun()
---@field CreateHorizontalScrollBar fun(name: string, Parent: Frame, Scroll: ScrollFrame, ScrollChild: Frame): HorizontalScrollBar

---@class EventFrame : Frame
---@field handlers table<string, any>

---@class Frame
---@field BG Texture
---@field BorderTop Texture
---@field BorderLeft Texture
---@field BorderRight Texture
---@field BorderBottom Texture
---@field SetBackdropColor fun(self: Frame, r: number, g: number, b: number, a: number)
---@field SetBackdropBorderColor fun(self: Frame, r: number, g: number, b: number, a: number)

---@class CharacterRow : Frame
---@field name string
---@field data table<string, any>

---@class HorizontalScrollBar : Slider
---@field updateScrollBar fun(self: HorizontalScrollBar)