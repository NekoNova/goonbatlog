-----------------------------------------------------------------------------------------------
-- Goonbatlog by jbaconcheese@mikros (getting white boy wasted)
-----------------------------------------------------------------------------------------------
 
require "Window"
require "GameLib"
require "Unit"
require "Spell"
  
-----------------------------------------------------------------------------------------------
-- GoonbatLog Module Definition
-----------------------------------------------------------------------------------------------

-- instantiate our program
local GoonbatLog = {}

-- containers for sum
local tinSum = {}
local toutSum = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

-- TODO:
-- 1. Finish combatlog logic
-- 2. add timer that fires every .5 seconds that sums and updates
-- 3. raep curse
 
-----------------------------------------------------------------------------------------------
-- Init
-----------------------------------------------------------------------------------------------

-- define init functionality
function GoonbatLog:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	-- init variables
	return o
end

function GoonbatLog:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- GoonbatLog Instance
-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- GoonbatLogForm Functions
---------------------------------------------------------------------------------------------------


local GoonbatLogInst = GoonbatLog:new()
GoonbatLogInst:Init()

 
-----------------------------------------------------------------------------------------------
-- GoonbatLog OnLoad
-----------------------------------------------------------------------------------------------

function GoonbatLog:OnLoad()
    
	-- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("GoonbatLog.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	self.settings = self.GUtils.CopyTable(self.gSettings)
end

 
-----------------------------------------------------------------------------------------------
-- GoonbatLog OnDocLoaded
-----------------------------------------------------------------------------------------------

function GoonbatLog:OnDocLoaded()
	
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "GoonbatLogForm", "FixedHudStratum", self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
		-- apparently, you're supposed to nil the xmldoc when you're done, lol, k bro, dat gc
		
		Apollo.RegisterSlashCommand("gbl", "OnSlashGoonbatLog", self)
		
		-- Event Handlers
		Apollo.RegisterEventHandler("CombatLogDamage", "OnCombatLogDamage", self)
		Apollo.RegisterEventHandler("CombatLogHeal", "OnCombatLogHeal", self)
		Apollo.RegisterEventHandler("AttackMissed", "OnAttackMiss", self)
		Apollo.RegisterEventHandler("CombatLogCCState", "OnCC", self)
		Apollo.RegisterEventHandler("QuestFloater", "OnQuestFloater", self)
		
		-- timer handlers
		Apollo.RegisterTimerHandler("OOCTimer", "OnOOCTimer", self)
		Apollo.RegisterTimerHandler("IncomingTimer", "OnIncomingTimer", self)
		Apollo.RegisterTimerHandler("OutgoingTimer", "OnOutgoingTimer", self)
		Apollo.RegisterTimerHandler("InNotificationTimer", "OnInNotificationTimer", self)
		Apollo.RegisterTimerHandler("OutNotificationTimer", "OnOutNotificationTimer", self)
		
		-- show the main window!
		self.wndMain:Show(true)
		
		-- get offsets for cellHeight
--		local l, t, r, b = Apollo.LoadForm(self.xmlDoc, "Cell", self.wndMain, self):GetAnchorOffsets()
		
--		self.settings.CellHeight = b - t
		
--		local l, t, r, b = nil, nil, nil, nil
		
		-- setup the containers
		self.questFrame = {}
		
		self.containers = 
		{
			["Incoming"]		 = self.wndMain:FindChild("IncomingContainer"),
			["Outgoing"]		 = self.wndMain:FindChild("OutgoingContainer"),
			["InNotification"]   = self.wndMain:FindChild("InNotificationContainer"),
			["OutNotification"]  = self.wndMain:FindChild("OutNotificationContainer")		
		}
		
		-- setup the frame containers
		self.frameContainers = 
		{
			["Incoming"]		 = {},
			["Outgoing"]		 = {},
			["InNotification"]   = {},
			["OutNotification"]  = {}		
		}
		
		self.totalChildren = 
		{
			["Incoming"]		 = 0,
			["Outgoing"] 		 = 0,
			["InNotification"]   = 0,
			["OutNotification"]  = 0
		}
		
		-- this is just an indicator so we dont have to use global indexes
		self.hasNewData =
		{
			["Incoming"]		 = {},
			["Outgoing"]		 = {},
			["InNotification"]   = {},
			["OutNotification"]  = {}		
		}
		
		self.CellHeight = 
		{
			["Incoming"]		 = "",
			["Outgoing"] 		 = "",
			["InNotification"]   = "",
			["OutNotification"]  = ""
		}
		
		if self.settings.Fonts == nil then
			
			self.settings.Fonts =
			{
				["Incoming"]		 = "CRB_Interface16_O",
				["Outgoing"] 		 = "CRB_Interface16_O",
				["InNotification"]   = "CRB_Interface16_O",
				["OutNotification"]  = "CRB_Interface16_O"
			}
			
		end
		
		if self.settings.flip == nil then
			
			self.settings.flip =
			{
				["Incoming"]		 = false,
				["Outgoing"] 		 = false,
				["InNotification"]   = false,
				["OutNotification"]  = false
			}
			
		end
			
		self.fontContainer = {}
		
		self.fontParent = self.wndMain:FindChild("FontContainer")
		
		if self.settings.floodControl == nil then
		
			self.settings.floodControl = 
			{
				["heal"] = 400,
				["damage"] = 400,
			}
		end
				
		self.dFonts = false
		
		self.ScrollingFrame     	= 
		{
			["frameContainer"]  	=
			{
				["Incoming"]		= 
				{
					["IDs"]			= {},
					["EndPos"]		= {l = 0, t = 0, r = 0, b = 0},
					["Height"]		= 0,
					["Width"]		= 0,
					["2Timer"]		= 0.0,
				},
				["Outgoing"]		= 
				{
					["IDs"]			= {},
					["EndPos"]		= {l = 0, t = 0, r = 0, b = 0},
					["Height"]		= 0,
					["Width"]		= 0,
					["2Timer"]		= 0.0,
				},				
				["InNotification"] 	= 
				{
					["IDs"]			= {},
					["EndPos"]		= {l = 0, t = 0, r = 0, b = 0},
					["Height"]		= 0,
					["Width"]		= 0,
					["2Timer"]		= 0.0,
				},
				["OutNotification"]	= 
				{
					["IDs"]			= {},
					["EndPos"]		= {l = 0, t = 0, r = 0, b = 0},
					["Height"]		= 0,
					["Width"]		= 0,
					["2Timer"]		= 0.0,
				},			
			},
		}
		
		-- some logic to determine if there was a save point for the main window
		if self.settings.left ~= nil then
			
			self.wndMain:SetAnchorOffsets(self.settings.left, self.settings.top, self.settings.right, self.settings.bottom)
			
			if self.settings.icAl ~= nil then
				
				self.wndMain:FindChild("IncomingContainer"):SetAnchorOffsets(self.settings.icAl, self.settings.icAt, self.settings.icAr, self.settings.icAb)
				self.wndMain:FindChild("OutgoingContainer"):SetAnchorOffsets(self.settings.ocAl, self.settings.ocAt, self.settings.ocAr, self.settings.ocAb)
				
				if self.settings.incAl ~= nil then
					
					self.wndMain:FindChild("InNotificationContainer"):SetAnchorOffsets(self.settings.incAl, self.settings.incAt, self.settings.incAr, self.settings.incAb)
					self.wndMain:FindChild("OutNotificationContainer"):SetAnchorOffsets(self.settings.oncAl, self.settings.oncAt, self.settings.oncAr, self.settings.oncAb)
				end
			end
		else
			--copy base settings (initialize the values)
			self.settings = self.GUtils.CopyTable(self.gSettings)
		end
		
		-- apply the settings to set the initial values OR put in saved position
		self:ApplySettings()
		
		--self.OOCTimer = ApolloTimer.Create(2, false, "OnOOCTimer", self)
		--self.MoveTimer = ApolloTimer.Create(.1, true, "OnMoveTimer", self)
	end
end
	
-----------------------------------------------------------------------------------------------
-- GoonbatLog Functions
-----------------------------------------------------------------------------------------------

-- apply the settigns
function GoonbatLog:ApplySettings()

	----Event_FireGenericEvent("SendVarToRover", "self", self, 0)
	
	-- if locked, lock!
	if self.settings.lock then
	
		self.wndMain:RemoveStyle("Moveable")
		self.wndMain:RemoveStyle("Sizeable")
		self.wndMain:RemoveStyle("Picture")
		self.wndMain:SetText("")
		
		for key, frame in pairs(self.containers) do
		
			frame:RemoveStyle("Moveable")
			frame:RemoveStyle("Sizable")			
			frame:SetText("")
			
			if self.settings.showbg ~= nil and self.settings.showbg == true then
			
				frame:AddStyle("Picture")
				
			else
			
				frame:RemoveStyle("Picture")
				
			end
			
			
			if string.find(key, "Notification") ~= nil then
			
				if self.settings.hiden == true then
				
					frame:Show(false)
				else 
					
					frame:Show(true)
				end
			end
		end
		
--		self.wndMain:FindChild("IncomingContainer"):RemoveStyle("Moveable")
--		self.wndMain:FindChild("IncomingContainer"):RemoveStyle("Sizeable")
--		self.wndMain:FindChild("IncomingContainer"):RemoveStyle("Picture")
--		self.wndMain:FindChild("IncomingContainer"):SetText("")
--		
--		self.wndMain:FindChild("OutgoingContainer"):RemoveStyle("Moveable")
--		self.wndMain:FindChild("OutgoingContainer"):RemoveStyle("Sizeable")
--		self.wndMain:FindChild("OutgoingContainer"):RemoveStyle("Picture")
--		self.wndMain:FindChild("OutgoingContainer"):SetText("")
--		
--		self.wndMain:FindChild("InNotificationContainer"):RemoveStyle("Moveable")
--		self.wndMain:FindChild("InNotificationContainer"):RemoveStyle("Sizeable")
--		self.wndMain:FindChild("InNotificationContainer"):RemoveStyle("Picture")
--		self.wndMain:FindChild("InNotificationContainer"):SetText("")
--		
--		self.wndMain:FindChild("OutNotificationContainer"):RemoveStyle("Moveable")
--		self.wndMain:FindChild("OutNotificationContainer"):RemoveStyle("Sizeable")
--		self.wndMain:FindChild("OutNotificationContainer"):RemoveStyle("Picture")
--		self.wndMain:FindChild("OutNotificationContainer"):SetText("")
		
	else
	
		self.wndMain:AddStyle("Moveable")
		self.wndMain:AddStyle("Sizeable")
		self.wndMain:AddStyle("Picture")
		
		for key, frame in pairs(self.containers) do
		
			frame:AddStyle("Moveable")
			frame:AddStyle("Sizable")
			frame:AddStyle("Picture")
			frame:SetText(key)
			
			if string.find(key, "Notification") ~= nil then
			
				if self.settings.hiden == true then
				
					frame:Show(false)
				else 
					
					frame:Show(true)
				end
			end
		end
		
--		self.wndMain:FindChild("IncomingContainer"):AddStyle("Moveable")
--		self.wndMain:FindChild("IncomingContainer"):AddStyle("Sizeable")
--		self.wndMain:FindChild("IncomingContainer"):AddStyle("Picture")
--		self.wndMain:FindChild("IncomingContainer"):SetText("Incoming")
		
--		self.wndMain:FindChild("OutgoingContainer"):AddStyle("Moveable")
--		self.wndMain:FindChild("OutgoingContainer"):AddStyle("Sizeable")
--		self.wndMain:FindChild("OutgoingContainer"):AddStyle("Picture")
--		self.wndMain:FindChild("OutgoingContainer"):SetText("Outgoing")
		
--		self.wndMain:FindChild("InNotificationContainer"):AddStyle("Moveable")
--		self.wndMain:FindChild("InNotificationContainer"):AddStyle("Sizeable")
--		self.wndMain:FindChild("InNotificationContainer"):AddStyle("Picture")
--		self.wndMain:FindChild("InNotificationContainer"):SetText("Incoming Notification")
		
--		self.wndMain:FindChild("OutNotificationContainer"):AddStyle("Moveable")
--		self.wndMain:FindChild("OutNotificationContainer"):AddStyle("Sizeable")
--		self.wndMain:FindChild("OutNotificationContainer"):AddStyle("Picture")
--		self.wndMain:FindChild("OutNotificationContainer"):SetText("Outgoing Notification")
	end
	
	if self.settings.hiden == true then
	
		self.wndMain:FindChild("OutNotificationContainer"):Show(false)
		self.wndMain:FindChild("InNotificationContainer"):Show(false)
	elseif self.settings.hiden == false then
	
		self.wndMain:FindChild("OutNotificationContainer"):Show(true)
		self.wndMain:FindChild("InNotificationContainer"):Show(true)
	end
	
--	-- if scroll, enable them!
--	if self.settings.isScroll then
--	
--		self.IncomingContainer:AddStyle("VScroll")
--		self.OutgoingContainer:AddStyle("VScroll")
--	else
--	
--		self.IncomingContainer:AddStyle("VScroll")
--		self.OutgoingContainer:AddStyle("VScroll")
--	end
	
	-- call refit to refit container
	self:Refit()	
end

-- refit the container and redraw if needed
function GoonbatLog:Refit()
	
	-- now we need to calculate the total number of children
	-- since we grabbed the offsets on entry or reset them, we can calculate the bottom and top of the container
	-- well use incoming, remember notification bar is 25 and there is a 5 px bevel around the outside
	-- we floor because we dont want to create half a container
	
	-- REMAKE USING KV PAIRS AND CONTAINER TABLE, SET CONDITIONAL AT SAME TIME
	
	local tA =
	{
		l = 0,
		t = 0,
		r = 0,
		b = 0
	}
	
	Event_FireGenericEvent("SendVarToRover", "rself", self, 0)

	if self.settings.isSct == true then
	
		--Event_FireGenericEvent("SendVarToRover", "riself", self, 0)
	
		for key, frameTable in pairs(self.ScrollingFrame.frameContainer) do
		
			Event_FireGenericEvent("SendVarToRover", "key", key, 0)
			Event_FireGenericEvent("SendVarToRover", "ft", frameTable, 0)
				
			local l, t, r, b = self.containers[key]:GetAnchorOffsets()
			local endpos = frameTable.EndPos
			
			endpos.l, endpos.t, endpos.r, endpos.b = l, t, r, b
			
			frameTable.Height = self.containers[key]:GetHeight()
			frameTable.Width = self.containers[key]:GetWidth()
			
			--frameTable.2Timer = .083
		end
		
		self.settings.refit = false
		
	elseif self.settings.isSct == false or self.settings.isSct == nil then
	
		for k, v in pairs(self.containers) do
		
			-- grab anchors
			tA.l, tA.t, tA.r, tA.b = v:GetAnchorOffsets()
			
			-- find height
			local height = math.floor(tA.b - tA.t)
			
			-- fix for odd error
			if self.CellHeight[k] == "" then
		
				local w = Apollo.LoadForm(self.xmlDoc, "Cell", v, self)
				local l, t, r, b = w:GetAnchorOffsets()
			
				self.CellHeight[k] = b - t
				
				--Event_FireGenericEvent("SendVarToRover", "cellh", self, 0)
				
				w:Destroy()
			end
			
			--Event_FireGenericEvent("SendVarToRover", "cellh", self, 0)
			
				-- find number of children
			local tChildren = math.floor(height / self.CellHeight[k])
			
			--Event_FireGenericEvent("SendVarToRover", "k", k, 0)
			----Event_FireGenericEvent("SendVarToRover", "tkids", tChildren, 0)
			
			if tChildren ~= self.totalChildren[k] or self.settings.refit or self.settings.reload then
			
				self.totalChildren[k] = tChildren
				
				-- --Event_FireGenericEvent("SendVarToRover", "self", self, 0)
				
				self:Redraw(k)		
			end
		end
	end
		
	if self.settings.refit == true then
				
		self.settings.refit = false
	end
			
	if self.settings.reload == true then
			
		self.settings.reload = false
	end
end

-- Redraw the frames, generally
function GoonbatLog:Redraw( tFrameContainer )

	if self.containers[tFrameContainer] == nil then
		return
	end
	
	-- kill old children
	self.containers[tFrameContainer]:DestroyChildren()
	
	-- kill old values of hasNewData
	self.hasNewData[tFrameContainer] = {}
	
	Event_FireGenericEvent("SendVarToRover", "self", self, 0)
	----Event_FireGenericEvent("SendVarToRover", "tFrameContainer", tFrameContainer, 0)
	
	-- iterate over the number of children and remake them
	for i = 1, self.totalChildren[tFrameContainer] do

		local wnd = ""
		
		-- create child frame	
		-- flip conditional
		if self.settings.flip[tFrameContainer] == true then
		
			
			wnd = Apollo.LoadForm(self.xmlDoc, "CellR", self.containers[tFrameContainer], self)
			
		else		
		
			wnd = Apollo.LoadForm(self.xmlDoc, "Cell", self.containers[tFrameContainer], self)		
			
		end
		
	--	local wnd = Apollo.LoadForm(self.xmlDoc, "Cell", self.containers[tFrameContainer], self)
		
		-- set font here
		if self.settings.Fonts[tFrameContainer] ~= nil then
			wnd:FindChild("SpellText"):SetFont(self.settings.Fonts[tFrameContainer])
		end
		
		if self.settings.frametest == true then
			wnd:FindChild("SpellText"):SetText(tFrameContainer.." "..i)
		end
		
		-- add child to the frame container
		if self.frameContainers[tFrameContainer][i] ~= nil then
		
			self.frameContainers[tFrameContainer][i] = wnd		
		else
			
			table.insert(self.frameContainers[tFrameContainer], wnd)
			
		end
		
		-- we've also got to insert a value for the true/false is new data state
		local isNew = false
		
		if self.hasNewData[tFrameContainer][i] ~= nil then
			
			self.hasNewData[tFrameContainer][i] = isNew
		else
			table.insert(self.hasNewData[tFrameContainer], isNew)
		end
	end
	
	-- make sure they're always top down	
	if self.settings.direction == nil then
	
		self:SortKids("topdown", self.containers[tFrameContainer]:GetChildren(), tFrameContainer)
	else
	
		self:SortKids(self.settings.direction, self.containers[tFrameContainer]:GetChildren(), tFrameContainer)
	end
end

-- this function determines direction of children
-- strDirection -> "topdown" goes top to bottom
--				   "downtop" goes bottom to top
--				   "centerout" first frame is at center then goes up down for consecutive
--				   "outcenter" first frame on top, then bottom then in till center
function GoonbatLog:SortKids( strDirection, tFrameContainer, parent )

	-- TODO: 
	-- Grab the children in the container
	-- get parent offsets (we need the top to go top down, bottom for bottom up)
	-- do modulus to determine even or odd number of frames
	
	--Event_FireGenericEvent("SendVarToRover", "tframe", tFrameContainer, 0)
	
	-- if passed a nil return
	if tFrameContainer == nil then
		
		return
	end
	
	-- get parent offsets
	local tFrame = tFrameContainer[1]:GetParent()
	
	--Event_FireGenericEvent("SendVarToRover", "tframep", self.totalChildren[parent], 0)
	
	-- for some reason, passing an _ as a variable container we dont care about irritates wsLua
	-- only care about top and bottom here
	local tLeft, tTop, tRight, tBottom = tFrame:GetAnchorOffsets()
	
	-- create our table containers
	local nA = {l = 0, t = 0, r = 0, b = 0}
	local oA = {l = 0, t = 0, r = 0, b = 0}
		
	-- for each frame in container
	-- we need to
	-- find out if first index
	-- if so, set offsets as parents
	-- if not, attach correct offsets to children
	-- remember a 0 offset is tied to the point, positive down, negative up, ln, rp
	for idx, frame in pairs(tFrameContainer) do
		
		-- init our anchor points
		nA.l, nA.t, nA.r, nA.b = 0, 0, 0, 0
		oA.l, oA.t, oA.r, oA.b = frame:GetAnchorOffsets()
		
		-- now we have if chain to determine how these are set
		-- remember, bottom of text frame only cares about top anchor point so
		-- need to be aware of the size of the frames
		if strDirection == "topdown" then
		
			-- multiply by idx to get bottom, then reassign top
			nA.b = oA.b * idx
			
		elseif strDirection == "downtop" then
		
			-- same as above except we're building from bottom so use old child to make new child
			if idx == 1 then

				-- new bottom is simply the max number of frames			
				nA.b = oA.b * (#tFrameContainer)
				
			else
			
				-- we just grab the previous values and set the new ones
				oA.l, oA.t, oA.r, oA.b = tFrameContainer[idx - 1]:GetAnchorOffsets()
				
				-- new bottom is simply child height above oA.t
				nA.b = oA.t

			end		
		
		elseif strDirection == "centerout" or strDirection == "outcenter" then
		
			-- this is a bit more tricky since we are essentially decrementing the top or incrementing the bottom
			-- of the parent window offsets
			-- we hold number of children in self.settings.totalChildren so
			-- we just figure out parity by using a modulo, 0 result means even, 1 result means odd
			
			if strDirection == "centerout" then
				
				-- we have to figure out first
				if idx == 1 then
				
					-- find middle (floor in case odd)
					local mid = math.ceil(self.totalChildren[parent] / 2)
					
					nA.b = oA.b * mid			
					
				-- and second, because we're looking back 2 units
				elseif idx == 2 then
				
					-- attach bottom to below first frame
					oA.l, oA.t, oA.r, oA.b = tFrameContainer[idx - 1]:GetAnchorOffsets()
					
					-- new bottom
					nA.b = oA.b + (oA.b - oA.t) 
				else
				
					-- now we need to alternate so, if odd and if even idx
					local parity = idx % 2
					
					-- in either case we need the old frames' offsets
					oA.l, oA.t, oA.r, oA.b = tFrameContainer[idx - 2]:GetAnchorOffsets()
					
					if parity == 0 then
					
						-- if even then we're attaching downwards
						nA.b = oA.b + (oA.b - oA.t)
						
					elseif parity == 1 then
					
						-- if odd we're going up so top of old = bottom of new
						nA.b = oA.t
					end
				end
				
			elseif strDirection == "outcenter" then
			
				-- need to define first two because we backtrack two
				if idx == 1 then
				
				-- new frame sits at top so, pass 
					nA.b = oA.b * idx
					
				elseif idx == 2 then
				
					-- this sits at bottom so we must base off container bottom
					nA.b = oA.b * (#tFrameContainer)
				else
								
					-- need parity bit
					local parity = idx % 2
					
					-- backtrack two
					oA.l, oA.t, oA.r, oA.b = tFrameContainer[idx - 2]:GetAnchorOffsets()
					
					if parity == 0 then
					
						-- we're even so attach bottom up
						nA.b = oA.t
						
					elseif parity == 1 then
					
						-- we're odd so attach top
						nA.b = oA.b + (oA.b - oA.t)
					end
				end	
				----Event_FireGenericEvent("SendVarToRover", "frame", frame, 0)
				----Event_FireGenericEvent("SendVarToRover", "dir", strDirection, 0)
				----Event_FireGenericEvent("SendVarToRover", "idx", idx, 0)
				----Event_FireGenericEvent("SendVarToRover", "nA", nA, 0)
				----Event_FireGenericEvent("SendVarToRover", "oA", oA, 0)			
			end
		end
		
		----Event_FireGenericEvent("SendVarToRover", "frame", frame, 0)
		----Event_FireGenericEvent("SendVarToRover", "dir", strDirection, 0)
		----Event_FireGenericEvent("SendVarToRover", "idx", idx, 0)
		----Event_FireGenericEvent("SendVarToRover", "nA", nA, 0)
		----Event_FireGenericEvent("SendVarToRover", "oA", oA, 0)
		
		-- have to add -childframeheight to bttom to set new top offset
		nA.t = nA.b - (oA.b - oA.t)
				
		-- now set new anchor points
		frame:SetAnchorOffsets(oA.l, nA.t, oA.r, nA.b)
	end
end

-- this is our big loop
-- this is what we're going to call to delineate what happens to each child window
-- gets passed 4 args
-- : tChild is the child container (table) the bucket falls into
-- : sText is a string that is the text to display
-- : sIconPath is a string for setting the sprite path
-- : bIsHeal is a boolean that determines heal or not
-- : bIsOut is a boolean that determines direction

function GoonbatLog:UpdateItem( tFrameContainer, sText, sIconPath, color)
	
	-- tChild is the member of then self.frameContainer class
	
	-- gotta refit if refit
	if self.settings.refit == true and self.settings.isSct == false then
		
		self:Refit()
		
		-- reset
		self.settings.refit = false
	end
	
	-- now iterate over elements of tChild
	-- first false entry insert unit
	-- set hasNewData for idx true if false
	-- if idx == #hasNewData then, after setting text, set all to false
	
	if self.settings.isSct == true then
	
		-- need to make a frame
		-- color it, set the text
		-- append it to the self.ScrollingFrame.frameContainer[tFrameContainer].IDs
		-- then start the Move Timer, and OOCTimer
		
		Event_FireGenericEvent("SendVarToRover", "UPself", self, 0)
		Event_FireGenericEvent("SendVarToRover", "UPtFrame", tFrameContainer, 0)
		
	--	local w = ""
		
		-- create the frame
	--	if self.settings.flip[tFrameContainer] == true then
		
	--		local w = Apollo.LoadForm(self.xmlDoc, "CellR", self.containers[tFrameContainer], self)
			
		--elseif self.settings.flip[tFrameContainer] == false or self.settings.flip[tFrameContainer] == nil then
		
		local w = Apollo.LoadForm(self.xmlDoc, "Cell", self.containers[tFrameContainer], self)
			
		--end
		
		-- set color
		w:FindChild("SpellText"):SetTextColor(CColor.new(color.r, color.g, color.b, color.o))
		
		-- set font
		w:FindChild("SpellText"):SetFont(self.settings.Fonts[tFrameContainer])
		
		-- set text
		w:FindChild("SpellText"):SetText(sText)
		
		-- set icon path
		w:FindChild("SpellIcon"):SetSprite(sIconPath)	
		
		-- insert into frame container
		table.insert(self.ScrollingFrame.frameContainer[tFrameContainer].IDs, w)
		
		-- call move
		local _ = self:MoveHelper(tFrameContainer)
		
		-- start move timer
		Apollo.CreateTimer(tFrameContainer.."Timer", 1, false)
		
		if self.settings.isFade == true then
--				self:CellFade()
			Apollo.CreateTimer("OOCTimer", 2, false)
		end	
		
			
	elseif self.settings.isSct == false or self.settings.isSct == nil then
	
		for idx, frame in pairs(self.frameContainers[tFrameContainer]) do
		
			--Event_FireGenericEvent("SendVarToRover", "frame", frame, 0)
			--Event_FireGenericEvent("SendVarToRover", "self", self, 0)
		
			if self.hasNewData[tFrameContainer][idx] ~= true then
				
				-- set text and color
				frame:FindChild("SpellText"):SetTextColor(CColor.new(color.r, color.g, color.b, color.o))
				frame:FindChild("SpellText"):SetText(sText)
				
				-- set icon path
				frame:FindChild("SpellIcon"):SetSprite(sIconPath)
				
				-- set opacity so we can see it
				frame:SetOpacity(1)
				
				-- bounding frames
				if idx == #self.hasNewData[tFrameContainer] then
					
					--Event_FireGenericEvent("SendVarToRover", "idx", idx, 0)
					
					-- set all units to false if reached end of index
					for i = 1, #self.hasNewData[tFrameContainer] do
					
						self.hasNewData[tFrameContainer][i] = false
					end
				else
					
					self.hasNewData[tFrameContainer][idx] = true
				end
				
						-- block for isfade
				if self.settings.isFade == true then
	--				self:CellFade()
					Apollo.CreateTimer("OOCTimer", 2, false)
				end
				
				return
			end
		end
	end
end

-- function reduces alpha on the child frames
-- iterates over whole stack, so fyi
function GoonbatLog:CellFade(tFrameContainer)	

	local bIsOOC = true

	-- need to iterate over all the windows and fade each by out fade value!
	for index, frameContainer in pairs(tFrameContainer) do
		
		if type(frameContainer) == "userdata" then
		
			bIsOOC = self:CellFadeHelper(frameContainer, bIsOOC)
			
		elseif type(frameContainer) == "table" then	
			
			for idx, frame in pairs(frameContainer) do
			
				bIsOOC = self:CellFadeHelper(frame, bIsOOC)
			end
			
		end 
	end
	
	return bIsOOC, tFrameContainer
end

function GoonbatLog:CellFadeHelper(frame, bIsOOC, fadeTime)

	if frame:GetOpacity() == 1 then
		frame:SetOpacity(0, fadeTime)
		
		bIsOOC = false
	end
	
	return bIsOOC
end

-- OnSave function (when you reloadui or log off)
function GoonbatLog:OnSave(eType)

	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	local tSaveData = self.settings
	
	tSaveData.left, tSaveData.top, tSaveData.right, tSaveData.bottom = self.wndMain:GetAnchorOffsets()
	tSaveData.icAl, tSaveData.icAt, tSaveData.icAr, tSaveData.icAb = self.wndMain:FindChild("IncomingContainer"):GetAnchorOffsets()
	tSaveData.ocAl, tSaveData.ocAt, tSaveData.ocAr, tSaveData.ocAb = self.wndMain:FindChild("OutgoingContainer"):GetAnchorOffsets()
	tSaveData.incAl, tSaveData.incAt, tSaveData.incAr, tSaveData.incAb = self.wndMain:FindChild("InNotificationContainer"):GetAnchorOffsets()
	tSaveData.oncAl, tSaveData.oncAt, tSaveData.oncAr, tSaveData.oncAb = self.wndMain:FindChild("OutNotificationContainer"):GetAnchorOffsets()
	
	return self.settings
end

-- OnRestore command, i think it fires whenever you load into the world from a save state? who knows! it's W*!
function GoonbatLog:OnRestore(eType, tData)

	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	if tData ~= nil then
		self.settings = tData
	end
	
	self.settings.reload = true
end

-- pops on all combat #getshrekd
function GoonbatLog:OnCombatLogDamage( tEventArgs )

	-- tEventArgs pipes a number and a table, since we only gave it 1 argument, we get the first result
	-- bPeriodic - boolean periodic
	-- bTargetKilled -- boolean death ack
	-- bTargetVulnerable -- boolean MoO
	-- eCombatResult -- enum combatresult, use liek eCombatResult == GameLib.CodeEnumCombatResult.critical e.g.
	-- eEffectType -- zero fucking clue
	-- nAbsorption -- integer returning absorb amount?
	-- nDamageAmount -- integer after mitigation damage
	-- nOverkill -- integer amount over health threashold
	-- nRawDamage -- integer of the raw damage result
	-- nShield -- integer amount of shield damage target took
	-- splCallingSpell -- method to get various data about spell
	-- -- can be used to get icon --> local sIconPath = splCallingSpl:GetIcon(), if nil pass else draw it
	-- unitCaster -- userdata return of caster use like if tEventArgs.unitCaster == GameLib.GetControlledUnit() then etc
	-- unitCasterOwner -- userdata return of caster owner, use in conjunction with unitcaster to get and filter damage sources
	-- unitTarget -- userdata return of target
	
	if tEventArgs["unitCaster"] == nil or tEventArgs["unitTarget"] == nil then
		return
	end
	
	if tEventArgs["nDamageAmount"] < self.settings.floodControl["damage"] then
		return
	else
		-- fuck pets
		if tEventArgs["unitTarget"] == GameLib.IsControlledUnit(tEventArgs["unitTarget"]:GetUnitOwner()) then
	 		return
		end
		
		-- grab spell icon path
		-- works great, because when nil, doesn't error out!
		local sIconPath = tEventArgs["splCallingSpell"]:GetIcon()
		
		-- never a heal
		local bIsHeal = false
		
		-- setup local for output
		local bIsOut = false
		
		-- setup container for string output
		local sText = tEventArgs["nDamageAmount"]
		
		-- setup color container
		local fColor = {}
		
		local tTime = GameLib.GetLocalTime()
		
		-- determine direction (i.e. is towards me? or did I do it?)
		if GameLib.IsControlledUnit(tEventArgs["unitTarget"]) or tEventArgs["unitTarget"] == GameLib.GetPlayerMountUnit() or GameLib.IsControlledUnit(tEventArgs["unitTarget"]:GetUnitOwner()) then
			
			-- if im the target, INCOMING!
			bIsOut = false
			fColor = self.settings.textColors["id"]
		elseif GameLib.IsControlledUnit(tEventArgs["unitCaster"]) or tEventArgs["unitCaster"] == GameLib.GetPlayerMountUnit() then
		
			-- if im the caster, OUTGOING!
			if self.settings.isTank == true then
				return
			end
			bIsOut = true
			fColor = self.settings.textColors["od"]
		else
			
			-- if im neither, return to main loop
			return
		end
		
		-- setup string parse
		-- we can change what we want displayed here by modifying the characters each represent
		-- self.settings.crit and self.settings.moo, remember to put them on both sides
		
		-- check for string size, ensure consistant target / time placement
		local sTlen = tostring(sText)
			sTlen = 6 - string.len(sTlen)
			
			for i = 1, sTlen do
				sText = sText.." "
		end
		
		-- check for both first, if it is, it should leave the if statement, god willing
		if tEventArgs["eCombatResult"] == GameLib.CodeEnumCombatResult.Critical and tEventArgs["bTargetVulnerable"] then
			fColor = self.settings.textColors["mcrit"]
		
		-- check if crit
		elseif tEventArgs["eCombatResult"] == GameLib.CodeEnumCombatResult.Critical then
			fColor = self.settings.textColors["crit"]
			
		-- check if vuln
		elseif tEventArgs["bTargetVulnerable"] then
			fColor = self.settings.textColors["moo"]
			
		-- check for both
		end 
	
		if bIsOut then
		
			if tEventArgs["unitTarget"] ~= nil and self.settings.isTarget == true then
			
				if self.settings.isTargetFull == true then
				
					sText = sText.." ("..tEventArgs["unitTarget"]:GetName()..")"
				
				else
				
					sText = sText.." ("..string.sub(tEventArgs["unitTarget"]:GetName(), 1, 4)..")"			
				
				end
			end
			
			if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
			end

			self:UpdateItem("Outgoing", sText, sIconPath, fColor)
		else
		
			if	tEventArgs["unitCaster"] ~= nil and self.settings.isTarget then
			
				if self.settings.isTargetFull == true then
					
					sText = sText.." ("..tEventArgs["unitCaster"]:GetName()..")"
				
				else
				
					sText = sText.." ("..string.sub(tEventArgs["unitCaster"]:GetName(), 1, 4)..")"
					
				end
				
			end
			
			if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
			end
			
			if self.settings.isTank == true then
				self:UpdateItem("Outgoing", sText, sIconPath, fColor)			
				return
			end
			self:UpdateItem("Incoming", sText, sIconPath, fColor)			
		end
	end
end

-- pops on all combat #fionabalogna
function GoonbatLog:OnCombatLogHeal( tEventArgs )
	
	-- tEventArgs pipes a number of stuff to 1 argument since we only gave it 1 container
	-- eCombatResult -- enum combatresult, use to find oddball results like crits, see damage listing
	-- nHealAmount -- total amount healed
	-- nOverheal -- amount of overheal
	-- splCallingSpell -- see damage listing
	-- unitCaster -- see damage listing
	-- unitTarget -- see damage listing
	
	if tEventArgs["unitCaster"] == nil or tEventArgs["unitTarget"] == nil then
		return
	end
	
	if tEventArgs["nHealAmount"] < self.settings.floodControl["heal"] then
		return
	else
		-- we dont give a shit about our pets
		if tEventArgs["unitCaster"] ~= nil then
			if tEventArgs["unitCaster"] == GameLib.IsControlledUnit(tEventArgs["unitCaster"]:GetUnitOwner()) or tEventArgs["unitTarget"] == GameLib.IsControlledUnit(tEventArgs["unitTarget"]:GetUnitOwner()) then
				return
			end
		end
		
		-- grab icon path
		local sIconPath = tEventArgs["splCallingSpell"]:GetIcon()
	
		-- always true in the heal
		local bIsHeal = true
		
		-- setup local for output
		local bIsOut = false
		
		-- setup container for string output
		local sText = tEventArgs["nHealAmount"]
		
		-- setup color container
		local fColor = {}
		
		local tTime = GameLib.GetLocalTime()
		
		-- we could lose data here, but honestly? doesn't really matter much, since it will be such a low occurance
		-- and most of the time you wont care anyway
		if self.settings.prevHeal == tEventArgs["nHealAmount"] and self.settings.prevTarg == tEventArgs["unitTarget"]:GetName() then
			return
		else
			self.settings.prevHeal = tEventArgs["nHealAmount"]
			self.settings.prevTarg = tEventArgs["unitTarget"]:GetName() 
		end
		
		-- determine direction (i.e. is towards me? or did I do it?)
		if GameLib.IsControlledUnit(tEventArgs["unitTarget"]) or tEventArgs["unitTarget"] == GameLib.GetPlayerMountUnit() then
			
			-- if im the target, INCOMING!
			bIsOut = false
			fColor = self.settings.textColors["ih"]
		elseif GameLib.IsControlledUnit(tEventArgs["unitCaster"]) or tEventArgs["unitCaster"] == GameLib.GetPlayerMountUnit() then
		
			-- if im the caster, OUTGOING!
			if self.settings.isTank == true then
				return
			end
			bIsOut = true
			fColor = self.settings.textColors["oh"]
		else
			
			-- if im neither, return to main loop
			return
		end
		
		local sTlen = tostring(sText)
			sTlen = 6 - string.len(sTlen)
			
			for i = 1, sTlen do
				sText = sText.." "
		end		
		
		-- check if crit
		if tEventArgs["eCombatResult"] == GameLib.CodeEnumCombatResult.Critical then
			fColor = self.settings.textColors["crit"]
		end
		
		if bIsOut then
		
			if tEventArgs["unitTarget"] ~= nil and self.settings.isTarget == true then
			
				if self.settings.isTargetFull == true then
				
					sText = sText.." ("..tEventArgs["unitTarget"]:GetName()..")"
				
				else
				
					sText = sText.." ("..string.sub(tEventArgs["unitTarget"]:GetName(), 1, 4)..")"			
				
				end
			end
			
			if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
			end
		else
			if	tEventArgs["unitCaster"] ~= nil and self.settings.isTarget then
			
				if self.settings.isTargetFull == true then
					
					sText = sText.." ("..tEventArgs["unitCaster"]:GetName()..")"
				
				else
				
					sText = sText.." ("..string.sub(tEventArgs["unitCaster"]:GetName(), 1, 4)..")"
					
				end
				
			end
			
			if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
			end
		end
		
		-- we will use () to denote overhealing
	--	if tEventArgs["nOverheal"] > 0 and tEventArgs["nOverheal"] ~= nil then
	--		sText = sText.." ("..tEventArgs["nOverheal"]..")"
	--	end
		
		if bIsOut then
			if tEventArgs["unitTarget"]:GetName() ~= tEventArgs["unitCaster"]:GetName() then
					self:UpdateItem("Outgoing", sText, sIconPath, fColor)
				end		
		else
			self:UpdateItem("Incoming", sText, sIconPath, fColor)
		end

	end
end

-- attack missed handler
function GoonbatLog:OnAttackMiss( unitCaster, unitTarget, eMissType )
	
	-- tEventArgs listing
	-- unitCaster -- must use [1]
	-- unitTarget -- must use [2]
	-- eMissType -- GameLib.CodeEnumMissType etc
	-- -- hey, this ENUM has ONE FUCKING ENTRY
	-- -- ITS ONLY DODGE, "DODGE", why name it deflect? flavor? jesus christ
	-- -- there is a listing for a block, but im reasonably sure it's been removed since there isn't a 
	-- -- enum reference inside FloatText
	-- SpellName? -- gotta reference using tEventArgs[4]
	-- some integer, who knows
	
		
	-- never a heal
	local bIsHeal = false
	
	-- setup local for output
	local bIsOut = false
	
	-- setup container for string output
	local sText = ""
	
	-- setup color container
	local fColor = self.settings.textColors["n"]
	
	local tTime = GameLib.GetLocalTime()
	
	-- determine direction (i.e. is towards me? or did I do it?)
	if GameLib.IsControlledUnit(unitTarget) or unitTarget == GameLib.GetPlayerMountUnit() or GameLib.IsControlledUnit(unitTarget:GetUnitOwner()) then
		
		-- if im the target, INCOMING!
		bIsOut = false
	elseif GameLib.IsControlledUnit(unitCaster) or unitCaster == GameLib.GetPlayerMountUnit() then
	
		-- if im the caster, OUTGOING!
		bIsOut = true
	else
			
		-- if im neither, return to main loop
		return
	end
	
	-- set string value
	sText = "Deflect!"
	
	-- parse output
	if bIsOut then
		
		if unitTarget ~= nil and self.settings.isTarget then
			sText = sText.." ("..string.sub(unitTarget:GetName(), 1, 4)..")"
		end
		
		if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
		end
		
		self:UpdateItem("Outgoing", sText, sIconPath, fColor)
	else
	
		if	unitCaster ~= nil and self.settings.isTarget then
			sText = sText.." ("..string.sub(unitCaster:GetName(), 1, 4)..")"
		end
		
		if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
		end
			
		self:UpdateItem("Incoming", sText, sIconPath, fColor)			
	end
	
	-- self.wndMain:FindChild("Notification"):SetText(tEventArgs["unitTarget"]:GetName())
end

-- CC handler, holy shit
function GoonbatLog:OnCC( tEventArgs )

	-- bRemoved -- returns true when cc effect is over (i.e. ive subdued you, false, you're no longer subdued, true)
	-- eCombatResult -- look in the stupid combatfloaterCCenum for this horseshit
	-- eResult -- same as above, 0 = ok, 5 = armor removed, you can read the lsiting in rover
	-- nInteruptArmorHit -- amount removed by spell
	-- splCallingSpell -- same usage as above
	-- strState -- string of state of target
	-- strTriggerCapCategory -- parent category of above i guess
	-- unitCaster
	-- unitTarget
	
	-- if either are nil, return
	if tEventArgs["unitCaster"] == nil or tEventArgs["unitTarget"] == nil then
		
		-- leave
		return
	end
	
	-- grab spell icon path
	-- works great, because when nil, doesn't error out!
	local sIconPath = tEventArgs["splCallingSpell"]:GetIcon()
	
	-- never a heal
	local bIsHeal = false
	
	-- setup local for output
	local bIsOut = false
	
	-- setup container for string output
	local sText = ""
	
	-- setup color container
	local fColor = self.settings.textColors["n"]
	
	local tTime = GameLib.GetLocalTime()
	
	-- determine direction (i.e. is towards me? or did I do it?)
	if GameLib.IsControlledUnit(tEventArgs["unitTarget"]) or tEventArgs["unitTarget"] == GameLib.GetPlayerMountUnit() or GameLib.IsControlledUnit(tEventArgs["unitTarget"]:GetUnitOwner()) then
		
		-- if im the target, INCOMING!
		bIsOut = false
	elseif GameLib.IsControlledUnit(tEventArgs["unitCaster"]) or tEventArgs["unitCaster"] == GameLib.GetPlayerMountUnit() then
	
		-- if im the caster, OUTGOING!
		bIsOut = true
	else
			
		-- if im neither, return to main loop
		return
	end
	
	-- wade through the shitshow that is this horseshit implementation
	-- ripped from the CombatFloater addon because none of this shit makes logical sense
	-- like
	-- literally zero
	-- it's a step backward for critical thinking skills everywhere
	-- put the cc table in self.settings.ccTable[""] where the str is the cc
	
	-- check if cc applied
	if tEventArgs["eResult"] == CombatFloater.CodeEnumCCStateApplyRulesResult.Ok then
		
		-- check to see if it's one we want to see, if so do it
		if self.settings.ccTable[tEventArgs["eState"]] ~= nil then
			sText = sText..""..self.settings.ccTable[tEventArgs["eState"]]
		else
			return
		end
	-- else target is immune?
	elseif tEventArgs["eResult"] == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_Immune then
		
		-- target immune
		sText = sText.."Immune"
		
	-- else infinite armor?
	elseif tEventArgs["eResult"] == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InfiniteInterruptArmor then
	
		-- infinite interrupt armor, you're either too quick or too slow
		sText = sText.."Infinite Armor"
		
	-- else reduced armor
	elseif tEventArgs["eResult"] == CombatFloater.CodeEnumCCStateApplyRulesResult.Target_InterruptArmorReduced then
	
		-- reduced armor but didn't interrupt
		sText = sText.."Reduced armor by (-"..tEventArgs["nInterruptArmorHit"]..")"
		
	-- else chaining cc triggers DR?
	elseif tEventArgs["eResult"] == CombatFloater.CodeEnumCCStateApplyRulesResult.DiminishingReturns_TriggerCap and tEventArgs.strTriggerCapCategory ~= nil then
	
		-- hit with cc but triggered DR cap
		sText = sText..tEventArgs["strState"].." "..tEventArgs["strTriggerCapCategory"]
	elseif tEventArgs["bRemoved"] == true then
		
		sText = sText..string.lower(tEventArgs["strState"]).." fades"
	else
		-- if none of these, return
		return
	end
	
	sText = sText.."!"
	
	----Event_FireGenericEvent("SendVarToRover", "sText", sText, 0)
	
	-- now call appropriate container
	if bIsOut then
		
		if tEventArgs["unitTarget"] ~= nil and self.settings.isTarget == true then
			
			if self.settings.isTargetFull == true then
			
				sText = sText.." ("..tEventArgs["unitTarget"]:GetName()..")"
			
			else
			
				sText = sText.." ("..string.sub(tEventArgs["unitTarget"]:GetName(), 1, 4)..")"			
			
			end
		end
		
		if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
		end
		
		self:UpdateItem("OutNotification", sText, sIconPath, fColor)
	else
	
		if	tEventArgs["unitCaster"] ~= nil and self.settings.isTarget then
			
			if self.settings.isTargetFull == true then
				
				sText = sText.." ("..tEventArgs["unitCaster"]:GetName()..")"
			
			else
			
				sText = sText.." ("..string.sub(tEventArgs["unitCaster"]:GetName(), 1, 4)..")"
				
			end
			
		end
		
		if self.settings.isTime == true then
					sText = sText.." | "..tTime.nHour..":"..tTime.nMinute..":"..tTime.nSecond.." | "
		end
		
		self:UpdateItem("InNotification", sText, sIconPath, fColor)			
	end
	
	-- self.wndMain:FindChild("Notification"):SetText(tEventArgs["unitTarget"]:GetName())
end

-- TIMER CALLBACK
function GoonbatLog:OnOOCTimer()

	local bIsOOC = false
	
	--Event_FireGenericEvent("SendVarToRover", "OOCself", self, 0)
	--Event_FireGenericEvent("SendVarToRover", "ScrollFOutgoing", self.ScrollingFrame.frameContainer.Outgoing.IDs, 0)
	--Event_FireGenericEvent("SendVarToRover", "numOutgoingIds", #self.ScrollingFrame.frameContainer.Outgoing.IDs, 0)
	
	if self.settings.isSct == true then
	
		bIsOOC = {}
		
	--	Event_FireGenericEvent("SendVarToRover", "OOCself", self, 0)
		
		-- key is Incoming, Outgoing, InNotification, OutNotification
		-- container is a table with {IDs, EndPos}
		for key, container in pairs(self.ScrollingFrame.frameContainer) do
		
				--Event_FireGenericEvent("SendVarToRover", "OOCcontainer", container, 0)
				--Event_FireGenericEvent("SendVarToRover", "OOCkey", key, 0)
				
				bIsOOC[key], container.IDs = self:CellFade(container.IDs, false, .05)			
		end
		
		--Event_FireGenericEvent("SendVarToRover", "OOCb", bIsOOC, 0)
		
		local tb = true
		
		for key, value in pairs(bIsOOC) do
		
			if value == false then
			
				tb = false
			end
		end
		
		bIsOOC = tb
		
	elseif self.settings.isSct == false or self.settings.isSct == nil then
	
		bIsOOC, self.frameContainers = self:CellFade(self.frameContainers, bIsOOC, self.settings.timeToFade)
	end
	
	if bIsOOC == true then
	
		Apollo.CreateTimer("OOCTimer", 2, false)
	
	end
end

-- hook into window size changing
-- call refit constantly
function GoonbatLog:OnWindowSizeChanged( wndHandler, wndControl )
	-- show that window has moved and on next update needs to be refit
	self.settings.refit = true
	
	local sText = wndControl:GetName()
	
	-- Event_FireGenericEvent("SendVarToRover", "sText", sText, 0)
	
	if sText == "InNotificationContainer" or sText =="GoonbatLogForm" or sText == "IncomingContainer" or sText == "OutNotificationContainer" or sText == "OutgoingContainer" then
	
		--Event_FireGenericEvent("SendVarToRover", "sTexti", sText, 0)
		
		sText = "|\n".."|\n".."|\n".."|\n".."|\n".."|\n"..sText.."\n"
	
		local l, t, r, b = wndControl:GetAnchorOffsets()
				
		sText = sText.."left = "..l.."\n"
		sText = sText.."------------------------ top = "..t.."------------------------\n"
		sText = sText.."right = "..r.."\n"
		sText = sText.."bottom = "..b.."\n"
		sText = sText.."|\n".."|\n".."|\n".."|\n".."|\n".."|\n"
		
		wndControl:SetText(sText)
	end
end

-- Slash command handler
function GoonbatLog:OnSlashGoonbatLog(sCmd, sInput)
	 
	-- grab secondary arguemnt to switch
	local s = string.lower(sInput)
	
	--if chain to determine behavior
	if s == nil or s == "" then
		
		self.GUtils.CPrint("(g)oon(b)at(l)og (gbl)")
		self.GUtils.CPrint("/gbl on")
		self.GUtils.CPrint(" -- enable and show window -- use again to turn off")
		self.GUtils.CPrint("/gbl lock")
		self.GUtils.CPrint(" -- locks window, shows bg -- use again to unlock")
		self.GUtils.CPrint("/gbl hiden")
		self.GUtils.CPrint(" -- hides notification bar -- use again to show")
		self.GUtils.CPrint("/gbl direction")
		self.GUtils.CPrint(" -- top down -- frames start at top then go down")
		self.GUtils.CPrint(" -- down top -- frames start at bottom then go up")
		self.GUtils.CPrint(" -- center out -- frames start radiating outward from middle")
		self.GUtils.CPrint(" -- out center -- frames start radiating inwards from ends")
		self.GUtils.CPrint("/gbl mode")
		self.GUtils.CPrint(" -- cycles through modes (tank, normal, SCT)")
		self.GUtils.CPrint("/gbl showtime")
		self.GUtils.CPrint(" -- sets flag to show time on combat text")
		self.GUtils.CPrint("/gbl showtarget")
		self.GUtils.CPrint(" -- sets flag to show target on combat text")
		self.GUtils.CPrint("/gbl showtargetfull")
		self.GUtils.CPrint(" -- sets flag to show target on combat text")	
		self.GUtils.CPrint("/gbl showbg")
		self.GUtils.CPrint(" -- sets flag to show bg of event frames")
		self.GUtils.CPrint("/gbl flood type #")
		self.GUtils.CPrint(" -- sets flood control (minimum value before event is seen")
		self.GUtils.CPrint(" -- type is either Heal or Damage")
		self.GUtils.CPrint(" -- # is the minimum value to see things")
		self.GUtils.CPrint(" -- e.g. (/gbl flood heal 200) wouldn't show values below 200")
		self.GUtils.CPrint("/gbl flip *frame")
		self.GUtils.CPrint(" -- flips display of *frame, where *frame is either: incoming, outgoing, innotification or outnotification")
		self.GUtils.CPrint("/gbl quest")
		self.GUtils.CPrint(" -- sets flag to enable / disable the display of the quest completion dialog")
		self.GUtils.CPrint("/gbl dfonts")
		self.GUtils.CPrint(" -- displays fonts in font on gbl form (the big window you move things around in), type again to hide")
		self.GUtils.CPrint("/gbl setfont #")
		self.GUtils.CPrint(" -- use /gbl dfonts to see which number coresponds to which font, then put that number in this command")
		self.GUtils.CPrint("/gbl frametest")
		self.GUtils.CPrint(" -- populates then fades the frames")
		self.GUtils.CPrint("/gbl reset")
		self.GUtils.CPrint(" -- resets settings")
		self.GUtils.CPrint(" -- if you change settings via houston / text editors you need to:")
		self.GUtils.CPrint(" -- /reloadui (to update), /gbl reset (to update), /reloadui (to save)")
		
	elseif s == "on" then
		
		if self.settings.isShown == true then
		
			self.GUtils.CPrint("Goobatlog disengaged.")
			self.wndMain:Show(false)
			
			self.settings.isShown = false
		elseif self.settings.isShown == false then
		
			self.GUtils.CPrint("Goonbatlog engaged.")
			self.wndMain:Show(true)
			
			self.settings.isShown = true
		end

	
	elseif s == "lock" then
		
		if self.settings.lock == false then
		
			self.GUtils.CPrint("Goonbatlog locked")
			self.settings.lock = true
			
		elseif self.settings.lock == true then
		
			self.GUtils.CPrint("Goonbatlog unlocked")
			self.settings.lock = false
		end
		
		-- force reload
		self.settings.reload = true
		self:ApplySettings()
		
	elseif s == "hiden" then
	
		if self.settings.hiden == false then
		
			self.GUtils.CPrint("notification bar hidden")
			self.settings.hiden = true
			
		elseif self.settings.hiden == true then
		
			self.GUtils.CPrint("notification bar shown")
			self.settings.hiden = false
			
		elseif self.settings.hiden == nil then
		
			self.settings.hiden = false	
			self.GUtils.CPrint("setting not initialized, please retype command")		
		end
		
		-- force reload
		self.settings.reload = true
		
		
		self:ApplySettings()

	elseif s == "direction" then
	
		-- switch on current value
		if self.settings.direction == "topdown" then
		
			self.GUtils.CPrint("direction -> downtop")
			self.settings.direction = "downtop"
			
		elseif self.settings.direction == "downtop" then

			self.GUtils.CPrint("direction -> centerout")
			self.settings.direction = "centerout"
			
		elseif self.settings.direction == "centerout" then

			self.GUtils.CPrint("direction -> outcenter")
			self.settings.direction = "outcenter"
			
		elseif self.settings.direction == "outcenter" then
		
			self.GUtils.CPrint("direction -> topdown")
			self.settings.direction = "topdown"
			
		end
		
		-- force reload
		self.settings.reload = true
		
		-- redraw
		self:ApplySettings()
		
	elseif s == "mode" then
	
		if self.settings.isTank == true and self.settings.isSct == false then
			
			self.GUtils.CPrint("resuming normal mode -- fading")
			self.settings.isTank = false
			self.settings.isFade = true
			
		elseif self.settings.isTank == false and self.settings.isSct == false then  
			
			self.GUtils.CPrint("engaging Sctmode -- frames scroll and fade")
			self.settings.isTank = false
			self.settings.isSct = true
			self.settings.isFade = true
			
		elseif self.settings.isTank == false and self.settings.isSct == true then
		
			self.GUtils.CPrint("engaging tankmode -- outgoing = inc damage, inc = inc heal")
			self.settings.isTank = true
			self.settings.isSct = false
			self.settings.isFade = false
			
		elseif self.settings.isTank == nil or self.settings.isSCT == nil then
		
			self:Reset()
		end
		
		-- force reload
		self.settings.reload = true
		
		-- redraw
		self:ApplySettings()
		
	elseif s == "showtime" then
	
		if	self.settings.isTime == true then
			
			self.GUtils.CPrint("hiding time from display")
			self.settings.isTime = false
		
		elseif self.settings.isTime == false then
		
			self.GUtils.CPrint("showing time on display")
			self.settings.isTime = true
			
		elseif self.settings.isTime == nil then
			
			self:Reset()
			self.GUtils.CPrint("setting not initialized, please retype command")
			self.settings.isTime = false
			
		end
		
		-- force reload
		self.settings.reload = true
		
		-- redraw
		self:ApplySettings()
		
	elseif s == "showtarget" then
	
		if	self.settings.isTarget == true then
			
			self.GUtils.CPrint("hiding target from display")
			self.settings.isTarget = false
		
		elseif self.settings.isTarget == false then
		
			self.GUtils.CPrint("showing target on display")
			self.settings.isTarget = true
			
		elseif self.settings.isTarget == nil then
			
			self:Reset()
			self.GUtils.CPrint("setting not initialized, please retype command")
			self.settings.isTarget = true
		end
		
		-- force reload
		self.settings.reload = true
		
		-- redraw
		self:ApplySettings()
		
	elseif s == "showtargetfull" then
	
		if	self.settings.isTargetFull == true then
			
			self.GUtils.CPrint("hiding target from display")
			self.settings.isTargetFull = false
		
		elseif self.settings.isTargetFull == false then
		
			self.GUtils.CPrint("showing target on display")
			self.settings.isTargetFull = true
			
		elseif self.settings.isTargetFull == nil then
			
			self:Reset()
			self.GUtils.CPrint("setting initialized to true, please retype command to turn false")
			self.settings.isTargetFull = true
		end
		
		-- force reload
		self.settings.reload = true
		
		-- redraw
		self:ApplySettings()
	
	elseif s == "showbg" then
		
		if self.settings.showbg == nil then
			
			self.settings.showbg = false	
			self.GUtils.CPrint("setting not initialized, please retype command")
		
		elseif self.settings.showbg == true then
			
			self.GUtils.CPrint("hiding frame bg")
			self.settings.showbg = false
			
		elseif self.settings.showbg == false then
		
			self.GUtils.CPrint("showing frame bg")
			self.settings.showbg = true
			
		end
			
		-- force reload
		self.settings.reload = true
		
		self:ApplySettings()		
		
	elseif string.find(s, "flip") ~= nil then
		
		
		-- parse string to figure out which container
		if string.match(s, "incoming") ~= nil then
		
			self:FlipHelper("Incoming")
		
		elseif string.match(s, "outgoing") ~= nil then
		
			self:FlipHelper("Outgoing")
			
		elseif string.match(s, "innotification") ~= nil then
		
			self:FlipHelper("InNotification")
			
		elseif string.match(s, "outnotification") ~= nil then
		
			self:FlipHelper("OutNotification")
			
		else
		
			self.GUtils.CPrint("frame not recognized")
			self.GUtils.CPrint("you typed (: "..s)
			self.GUtils.CPrint("options are: incoming, outgoing, innotification or outnotification")
			
		end
			
		-- force reload
		self.settings.reload = true
		
		self:ApplySettings()	
		
	elseif s == "quest" then
		
		if self.settings.quest == nil then
			
			self.settings.quest = true
			self.GUtils.CPrint("setting not initialized, please retype command")
		
		elseif self.settings.quest == true then
			
			self.GUtils.CPrint("hiding quests")
			self.settings.quest = false
			
		elseif self.settings.quest == false then
		
			self.GUtils.CPrint("showing quests")
			self.settings.quest = true
			
		end
			
		-- force reload
		self.settings.reload = true
		
		self:ApplySettings()
		
	elseif s == "frametest" then
		
		if self.settings.frametest == nil then
			
			self.settings.frametest = false	
			self.GUtils.CPrint("setting not initialized, please retype command")
		
		elseif self.settings.frametest == true then
			
			self.GUtils.CPrint("hiding frametest dialog")
			self.settings.frametest = false
			
		elseif self.settings.frametest == false then
		
			self.GUtils.CPrint("pushing text to frames")
			self.settings.frametest = true
			
		end
		
		if self.settings.isSct == true then
		
			self:FrameTestHelper()
		else	
			-- force reload
			self.settings.reload = true
			
			self:ApplySettings()
		end
	
	elseif s == "dfonts" then -- flag is self.dFonts
	
		if self.dFonts == true then
		
		self.dFonts = false
		self.GUtils.CPrint("destroying font frames")

		elseif self.dFonts == false then
		
		self.dFonts = true
		self.GUtils.CPrint("showing fonts on frames")
		
		end
		--Event_FireGenericEvent("SendVarToRover", "self", self, 0)
		self:DisplayFonts( self.fontContainer )
	
	elseif string.find(s, "setfont") ~= nil then
	
		local fontTable = Apollo.GetGameFonts()
		
		if string.match(s, '%d+') ~= nil and tonumber(string.match(s, '%d+')) > 0 and tonumber(string.match(s, '%d+')) <= #fontTable then
		
			-- Event_FireGenericEvent("SendVarToRover", "s", s, 0)
			
			for k, v in pairs(self.settings.Fonts) do
	
				self.settings.Fonts[k] = fontTable[tonumber(string.match(s, '%d+'))]["name"]

			end
			
			-- Event_FireGenericEvent("SendVarToRover", "self", self, 0)
			
			self.GUtils.CPrint("Setting font to: "..fontTable[tonumber(string.match(s, '%d+'))]["name"])
			
			self.settings.reload = true
		
			self:ApplySettings()
			
		else
		
			self.GUtils.CPrint("did not pick a number within bounds OR something went wrong")
			
		end				
	
	elseif string.find(s, "flood") ~= nil then
	
		if string.find(s, "heal") ~= nil or string.find(s, "damage") ~= nil then
			
			local sTmp = string.match(s, '%d+')
			
			if sTmp ~= nil then
			
				sTmp = tonumber(sTmp)
								
				if sTmp < 100000 and sTmp > 0 then
				
					if string.find(s, "damage") ~= nil then
					
						self.settings.floodControl["damage"] = sTmp
						
					elseif string.find(s, "heal") ~= nil then
					
						self.settings.floodControl["heal"] = sTmp
						
					end
					
				end
			end
		end		
		
	elseif s == "reset" then
	
		self.GUtils.CPrint("Reseting")
		self.settings = self.GUtils.CopyTable(self.gSettings)
		self:ApplySettings()
				
	else
		
		self.GUtils.CPrint("please use /gbl to see correct inputs")	
	end
end

function GoonbatLog:Reset()

	self.GUtils.CPrint("Reseting")
	self.GUtils.CPrint("-- if you see this after using a slash command")
	self.GUtils.CPrint("-- retype the slash command please")
	self.settings = self.GUtils.CopyTable(self.gSettings)
	self:ApplySettings()
end

function GoonbatLog:DisplayFonts(tFrameContainer)

	local fontTable = Apollo.GetGameFonts()
	
	if self.fontContainer[1] ~= nil then
	
		self.fontParent:DestroyChildren()
		
		-- not sure if this will work in the long term but....
		self.fontContainer = {}

		self.wndMain:FindChild("FontContainer"):Show(false)		
	else
	
		self.wndMain:FindChild("FontContainer"):Show(true)
	
		for key, strFont in pairs(fontTable) do
		
			if strFont["size"] < 20 then
			
				local w = Apollo.LoadForm(self.xmlDoc, "CellFont", self.fontParent, self)
				
				w:SetFont(strFont["name"])
				w:SetText(key.." "..strFont["name"])

				table.insert(self.fontContainer, w)
			end
		end
		
		self:SortKids("topdown", self.fontParent:GetChildren(), self.fontContainer)
		
		self.fontParent:AddStyle("VScroll")

	end	
end

-- gets called by MoveTimer, helps move the frames
-- returns false if frames still need to be moved (i.e. they are within endpos
function GoonbatLog:MoveHelper(subContainer)

	local bIsDone = {}
	local tb = true
	local killTable = {}
	
--	Event_FireGenericEvent("SendVarToRover", "ScrollFOutgoing", self.ScrollingFrame.frameContainer.Outgoing.IDs, 0)
--	Event_FireGenericEvent("SendVarToRover", "numOutgoingIds", #self.ScrollingFrame.frameContainer.Outgoing.IDs, 0)
	
	-- escape if bad (returns nil)
	if subContainer == nil then
	
		return
	end
	
	local compareTable = self.ScrollingFrame.frameContainer[subContainer]
	
--	Event_FireGenericEvent("SendVarToRover", "MoveHelperSubContainer", subContainer, 0)
	-- subContainer.IDs = {idx = ID (userdata),}
	-- need to move them
	-- check if exceed endPos
	-- - if so, append idx to killTable
	-- self.ScrollingFrame.frameContainer[subContainer].IDs
	for idx, ID in pairs(self.ScrollingFrame.frameContainer[subContainer].IDs) do
	
		local wl, wt, wr, wb = ID:GetAnchorOffsets()
		
		--Event_FireGenericEvent("SendVarToRover", "MoveHelperCellTop", wt, 0)
		--Event_FireGenericEvent("SendVarToRover", "MoveHelperContainerBot", ID, 0)		
		
		if wt + ID:GetHeight() <= compareTable.Height then
	
			ID:Move(wl, math.ceil((wt + ID:GetHeight())), ID:GetWidth(), ID:GetHeight())
			
		elseif wt + ID:GetHeight() > compareTable.Height or ID:GetOpacity() == 0 then
	
			ID:Destroy()
			table.insert(killTable, idx)
		end
	end
	
	-- go through kill table and kill the frames that are out of shot
	-- killTable = {idx, frameIdx}
	for i, frame in pairs(killTable) do
	
		self.ScrollingFrame.frameContainer[subContainer].IDs[frame] = nil
	end		
	
	-- reset kill table
	killTable = {}
	
	if #self.containers[subContainer]:GetChildren() == 0 then
	
		table.insert(bIsDone, true)
		
	else
	
		table.insert(bIsDone, false)
		
	end
	
--	Event_FireGenericEvent("SendVarToRover", "MoveHelperbIsDone", bIsDone, 0)
--	Event_FireGenericEvent("SendVarToRover", "MoveHelperSelf", self, 0)
	
	-- iterate over bIsDone to figure out if we're all done
	for key, value in pairs(bIsDone) do
	
		if value == false then
			
			tb = false
		end
	end
	
	bIsDone = tb
	
	return bIsDone
end

function GoonbatLog:OnIncomingTimer()

	local sw = self:MoveHelper("Incoming")
	
	if sw == false then
		
		Apollo.CreateTimer("IncomingTimer", .08, false)

	end	
end

function GoonbatLog:OnOutgoingTimer()

	local sw = self:MoveHelper("Outgoing")
	
	if sw == false then
		
		Apollo.CreateTimer("OutgoingTimer", .08, false)

	end	
end

function GoonbatLog:OnInNotificationTimer()

	local sw = self:MoveHelper("InNotification")
	
	if sw == false then
		
		Apollo.CreateTimer("InNotificationTimer", .09, false)

	end	
end

function GoonbatLog:OnOutNotificationTimer()

	local sw = self:MoveHelper("OutNotification")
	
	if sw == false then
		
		Apollo.CreateTimer("OutNotificationTimer", .09, false)

	end	
end

function GoonbatLog:FlipHelper(tFrameContainer)

	-- hook the container and flip w/e it's value it is, then push that data to the client
	if self.settings.flip[tFrameContainer] == true then
	
		self.GUtils.CPrint("flipping "..tFrameContainer.." left")
		self.settings.flip[tFrameContainer] = false
		
	elseif self.settings.flip[tFrameContainer] == false then
	
		self.GUtils.CPrint("flipping "..tFrameContainer.." left")
		self.settings.flip[tFrameContainer] = true
		
	end
end

function GoonbatLog:FrameTestHelper()

	-- creates 50 frames and passes them to the frames (only gets called in SCTmode)
	
	Apollo.RegisterTimerHandler("FrameTimer", "OnFrameTimer", self)
	
	for i = 1, 40 do
	
		for key, value in pairs(self.containers) do
		
			local w = Apollo.LoadForm(self.xmlDoc, "Cell", value, self)
			
			self:UpdateItem(key, "See Me!", "", self.settings.textColors["n"])
		end
	end
	
--	Apollo.CreateTimer("FrameTimer", 1, false)
end


function GoonbatLog:OnFrameTimer()
end


-- this gets called whenever a quest is updated (float text)
function GoonbatLog:OnQuestFloater( unitCaster, strUpdate, tQuest, someNumber )

	-- tEventArgs
	-- 1: unitCaster (you)
	-- 2: string of what was completed
	-- 3: actual quest listing
	-- 3 1: self reference to quest
	-- 3 2: some number
	-- 3 3: bIsComplete?
	-- 3 4: some number index
	-- 4: some number index (same index as [3][4])
	
	if unitCaster == nil or strUpdate == nil or GameLib.IsControlledUnit(unitCaster) ~= true then
	
		return
	end
	
	if self.settings.quest == false then
	
		return
	end
	
	local fColor = self.settings.textColors["n"]
	
	local sText = string.gsub(strUpdate, "<(.-)>", "") --String_GetWeaselString(Apollo.GetString("GoonbatLog_QuestFloater"), strUpdate)
	
	--Event_FireGenericEvent("SendVarToRover", "string", sText, 0)
	
	local sIconPath = ""
	
	if self.questFrame[1] ~= nil then
	
		self.questFrame[1]:Destroy()
		
		self.questFrame = {}
	end
	
	local wnd = Apollo.LoadForm(self.xmlDoc, "Cell", self.wndMain, self)
		
	wnd:FindChild("SpellText"):SetTextColor(CColor.new(fColor.r, fColor.g, fColor.b, fColor.o))
		
	table.insert(self.questFrame, wnd)
	
	self.questFrame[1]:SetText(sText)
	
	self.questFrame[1]:SetOpacity(0, .5)
end
