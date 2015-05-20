-- hook goonbatlog so we can load inside our addon
local GoonbatLog = Apollo.GetAddon("GoonbatLog")

GoonbatLog.gSettings = 
{
	-- mode operatives
	isFade = true,
	isTank = false,
	isSct = false,
	isScroll = false,
	isShown = true,
	isSplit = false,
	isTime = false,
	isTarget = true,
	
	-- double count party fix
	prevHeal = 0,
	prevTarg = "",
	
	-- window position settings
	top = 0,
	left = 0,
	right = 600,
	bottom = 500,
	
	-- window opacity settings
	baseOpacity = 1.0,
	timeToFade = 0.2, -- implies 20 calls to reduce to zero, modify to extend/reduce
	-- healFlood = 400, -- cutsoff heals below ticks of 400
	-- dmgFlood = 400, -- cutsoff damage below ticks of 400
	direction = "topdown", -- direction container
	
	-- window text colors (you can put whatever hex color your heart desires in this}
	-- im r/g colorblind so get #rekt normies, as long as only 1 is "green" or "red" then okay
	textColors = 
	{
		ih = {r = 0, g = 1, b = 0, o = 1}, -- green
		id = {r = 1, g = .5, b = 0, o = 1}, -- orange
		oh = {r = 0, g = 1, b = 0, o = 1}, -- green
		od = {r = 0, g = 1, b = 1, o = 1}, -- light blue
		crit = {r = 1, g = 1, b = 0, o = 1}, -- yellow
		moo = {r = .7, g = 0, b = 1, o = 1}, -- purple?
		mcrit = {r = 1, g = 1, b = 1, o = 1}, -- yellow + purple? is white
		n = {r = 1, g = 1, b = 1, o = 1}, -- white 
	},
	--textColorIndex = {"ih", "id", "oh", "od", "n"),
	
	--obj.wndhandler:SetTextColor(ihTextColor} ex
	
	-- TypeFace bullshit (depreciated)
	-- use like Wnd:SetFont("CRB_Header12_O"}
	-- FontFace = "CRB_Interface16_O",
	
	-- window state
	lock = false,	
	show = false,
	
	-- cc state
	ccTable =  --Removing an entry from this table means no floater is shown for that state.
	{
		[Unit.CodeEnumCCState.Stun] 			= "stun", -- stun
		[Unit.CodeEnumCCState.Sleep] 			= "sleep", -- sleep
		[Unit.CodeEnumCCState.Root] 			= "root", -- root
		[Unit.CodeEnumCCState.Disarm] 			= "disarm", -- disarm
		[Unit.CodeEnumCCState.Silence] 			= "silence", -- silence
		[Unit.CodeEnumCCState.Polymorph] 		= "poly", -- polymorph
		[Unit.CodeEnumCCState.Fear] 			= "fear", -- fear
		[Unit.CodeEnumCCState.Hold] 			= "hold", -- hold
		[Unit.CodeEnumCCState.Knockdown] 		= "knockdown", -- knockdown
		[Unit.CodeEnumCCState.Disorient] 		= "disorient",
		[Unit.CodeEnumCCState.Disable] 			= "disable",
		[Unit.CodeEnumCCState.Taunt] 			= "taunt",
		[Unit.CodeEnumCCState.DeTaunt] 			= "teTaunt",
		[Unit.CodeEnumCCState.Blind] 			= "blind",
		[Unit.CodeEnumCCState.Knockback] 		= "knockback",
		[Unit.CodeEnumCCState.Pushback ] 		= "push",
		[Unit.CodeEnumCCState.Pull] 			= "pull",
		[Unit.CodeEnumCCState.PositionSwitch] 	= "PSwitch",
		[Unit.CodeEnumCCState.Tether] 			= "tether",
		[Unit.CodeEnumCCState.Snare] 			= "snare",
		[Unit.CodeEnumCCState.Interrupt] 		= "Interrupt",
		[Unit.CodeEnumCCState.Daze] 			= "Daze",
		[Unit.CodeEnumCCState.Subdue] 			= "subdue",
	}
}
