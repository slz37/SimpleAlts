---@alias Color table<string, number>
---@alias FontFlag string

---@class simpleAlts
---@field defaultFont string
---@field defaultTexture string
---@field colors table<string, Color>
---@field fonts table<string, FontObject>
---@field unitEventData table<string, any>
---@field unitFramePool table<string, any>
---@field OptionsFrame Frame
---@field ColParent Frame
---@field ToggleMinimapButton fun()
---@field ToggleOptions fun()
---@field RegisterEventHandler fun(event: string, func: fun(...))
---@field UnregisterEventHandler fun(event: string, func: fun(...))
---@field EnsureDB fun()
---@field CreateFlatBackdrop fun(Frame: Frame, bgAlpha: number?, borderAlpha: number?)
---@field CreateResizeButton fun(Parent: Frame): Button
---@field CreateXButton fun(size: number, Parent: Frame, anchorPoint: string, AnchorFrame: Frame, relativePoint: string, xOffset: number, yOffset: number, tooltipText: string?, onClick: fun()?): Button
---@field CreateArrowButton fun(size: number, Parent: Frame, anchorPoint: string, AnchorFrame: Frame, relativePoint: string, xOffset: number, yOffset: number, rotation: string, tooltipText: string): Button
---@field CreateCheckTexture fun(Parent: Frame, size: number, anchorPoint: string, AnchorFrame: Frame|FontString, relativePoint: string, xOffset: number, yOffset: number): Texture
---@field StyleScrollBar fun(ScrollFrame: Frame|Slider, orientation: string?): Slider|Frame
---@field CreateScrollbar fun()
---@field CreateHorizontalScrollBar fun(name: string, Parent: Frame, Scroll: ScrollFrame, ScrollChild: Frame): HorizontalScrollBar
---@field AcquireCol fun(name: string, data: CharacterData): CharacterCol
---@field LayoutCols fun()
---@field GetCol fun(name: string): CharacterCol?
---@field RefreshCol fun(name: string, field: string)
---@field RefreshAll fun()
---@field PlaceColumn fun(Col: Frame, previous: Frame)
---@field GetLayoutSize fun(numCols: number): number, number
---@field LayoutLabelColumn fun(Parent: Frame): Frame
---@field LayoutTotalGold fun(Parent: Frame, FirstCol: Frame)
---@field ApplyRaidLayout fun()

---@class EventFrame : Frame
---@field handlers table<string, any>

---@class Frame
---@field BG Texture
---@field BorderTop Texture
---@field BorderLeft Texture
---@field BorderRight Texture
---@field BorderBottom Texture
---@field sections table<string, Frame>?
---@field SetBackdropColor fun(self: Frame, r: number, g: number, b: number, a: number)
---@field SetBackdropBorderColor fun(self: Frame, r: number, g: number, b: number, a: number)

---@class FontString
---@field Check Texture

---@class CharacterData
---@field name string?
---@field index number
---@field ilvl number
---@field gold number
---@field equip table<number, string>
---@field warn table<number, boolean>?
---@field track table<number, string>?
---@field vault table<string, any>
---@field raids table<string, any>?
---@field ilvls table<string, any>

---@class GearIcon : Button
---@field link string?
---@field Texture Texture
---@field Name FontString

---@class CharacterCol : Frame
---@field name string
---@field data CharacterData
---@field initialized boolean?
---@field sections table<string, Frame>
---@field Name FontString
---@field LeftArrow Button
---@field RightArrow Button
---@field ILvl FontString
---@field Gold FontString
---@field vaultCells table<string, any>
---@field icons table<number, GearIcon>
---@field boxes table<number, table<number, Texture[]>>?
---@field Init fun(self: CharacterCol)

---@class HorizontalScrollBar : Slider
---@field updateScrollBar fun(self: HorizontalScrollBar)

---@class NineSlicePanel : Frame
---@field SetBorderColor fun(self: NineSlicePanel, r: number, g: number, b: number, a: number?)

---@class GameTooltip
---@field NineSlice NineSlicePanel?