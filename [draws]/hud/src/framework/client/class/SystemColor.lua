local super = Class("SystemColor", Color).getSuperclass()

SystemColor.DESKTOP = 1
SystemColor.ACTIVE_CAPTION = 2
SystemColor.ACTIVE_CAPTION_TEXT = 3
SystemColor.ACTIVE_CAPTION_BORDER = 4
SystemColor.INACTIVE_CAPTION = 5
SystemColor.INACTIVE_CAPTION_TEXT = 6
SystemColor.INACTIVE_CAPTION_BORDER = 7
SystemColor.WINDOW = 8
SystemColor.WINDOW_BORDER = 9
SystemColor.WINDOW_TEXT = 10
SystemColor.MENU = 11
SystemColor.MENU_TEXT = 12
SystemColor.TEXT = 13
SystemColor.TEXT_TEXT = 14
SystemColor.TEXT_HIGHLIGHT = 15
SystemColor.TEXT_HIGHLIGHT_TEXT = 16
SystemColor.TEXT_INACTIVE_TEXT = 17
SystemColor.CONTROL = 18
SystemColor.CONTROL_TEXT = 19
SystemColor.CONTROL_HIGHLIGHT = 20
SystemColor.CONTROL_LT_HIGHLIGHT = 21
SystemColor.CONTROL_SHADOW = 22
SystemColor.CONTROL_DK_SHADOW = 23
SystemColor.SCROLLBAR = 24
SystemColor.INFO = 25
SystemColor.INFO_TEXT = 26
SystemColor.NUM_COLORS = 26

SystemColor.systemColors = {
	Color(0,92,92),  -- desktop
	Color(0,0,128),  -- activeCaption
	Color.white,  -- activeCaptionText
	Color.lightGray,  -- activeCaptionBorder
	Color.gray,  -- inactiveCaption
	Color.lightGray,  -- inactiveCaptionText
	Color.lightGray,  -- inactiveCaptionBorder
	Color.white,  -- window
	Color.black,  -- windowBorder 
	Color.black,  -- windowText
	Color.lightGray,  -- menu
	Color.black,  -- menuText
	Color.lightGray,  -- text
	Color.black,  -- textText
	Color(0,0,128),  -- textHighlight
	Color.white,  -- textHighlightText
	Color.gray,  -- textInactiveText = 
	Color.lightGray,  -- control
	Color.black,  -- controlText
	Color.white,  -- controlHighlight
	Color(224,224,224),  -- controlLtHighlight
	Color.gray,  -- controlShadow
	Color.black,  -- controlDkShadow
	Color(224,224,224),  -- scrollbar
	Color(224,224,0),  -- info
	Color.black,  -- infoText
}

function SystemColor:init(index)
	super.init(self, SystemColor.systemColors[index] or 0)
	return self
end

SystemColor.desktop = SystemColor(SystemColor.DESKTOP)
SystemColor.activeCaption = SystemColor(SystemColor.ACTIVE_CAPTION)
SystemColor.activeCaptionText = SystemColor(SystemColor.ACTIVE_CAPTION_TEXT)
SystemColor.activeCaptionBorder = SystemColor(SystemColor.ACTIVE_CAPTION_BORDER)
SystemColor.inactiveCaption = SystemColor(SystemColor.INACTIVE_CAPTION)
SystemColor.inactiveCaptionText = SystemColor(SystemColor.INACTIVE_CAPTION_TEXT)
SystemColor.inactiveCaptionBorder = SystemColor(SystemColor.INACTIVE_CAPTION_BORDER)
SystemColor.window = SystemColor(SystemColor.WINDOW)
SystemColor.windowBorder = SystemColor(SystemColor.WINDOW_BORDER)
SystemColor.windowText = SystemColor(SystemColor.WINDOW_TEXT)
SystemColor.menu = SystemColor(SystemColor.MENU)
SystemColor.menuText = SystemColor(SystemColor.MENU_TEXT)
SystemColor.text = SystemColor(SystemColor.TEXT)
SystemColor.textText = SystemColor(SystemColor.TEXT_TEXT)
SystemColor.textHighlight = SystemColor(SystemColor.TEXT_HIGHLIGHT)
SystemColor.textHighlightText = SystemColor(SystemColor.TEXT_HIGHLIGHT_TEXT)
SystemColor.textInactiveText = SystemColor(SystemColor.TEXT_INACTIVE_TEXT)
SystemColor.control = SystemColor(SystemColor.CONTROL)
SystemColor.controlText = SystemColor(SystemColor.CONTROL_TEXT)
SystemColor.controlHighlight = SystemColor(SystemColor.CONTROL_HIGHLIGHT)
SystemColor.controlLtHighlight = SystemColor(SystemColor.CONTROL_LT_HIGHLIGHT)
SystemColor.controlShadow = SystemColor(SystemColor.CONTROL_SHADOW)
SystemColor.controlDkShadow = SystemColor(SystemColor.CONTROL_DK_SHADOW)
SystemColor.scrollbar = SystemColor(SystemColor.SCROLLBAR)
SystemColor.info = SystemColor(SystemColor.INFO)
SystemColor.infoText = SystemColor(SystemColor.INFO_TEXT)


