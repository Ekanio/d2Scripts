local protobuf = require('protobuf')
local JSON = require('assets.JSON')
local ScreenWidth, ScreenHeight = Renderer.GetScreenSize()

local PlayersInQueue = {}
PlayersInQueue.optionEnable = Menu.AddOptionBool({"Utility", "Players in queue"}, "Enabled", false)
PlayersInQueue.alphaHover = Menu.AddOptionSlider({"Utility", "Players in queue"}, "Alpha when hovered", 0, 255, 190)
PlayersInQueue.xPos = Menu.AddOptionSlider({"Utility", "Players in queue"}, "X position", 0, ScreenWidth, 1575)
PlayersInQueue.yPos = Menu.AddOptionSlider({"Utility", "Players in queue"}, "Y position", 0, ScreenHeight, 70)

Menu.AddMenuIcon({"Utility", "Players in queue"}, '~/MenuIcons/radar_scan.png')
Menu.AddOptionIcon(PlayersInQueue.optionEnable, '~/MenuIcons/Enable/enable_check_round.png')

local font = Renderer.LoadFont("Consolas", 20, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.NORMAL)
local font2 = Renderer.LoadFont("Consolas", 13, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.BOLD)
local font3 = Renderer.LoadFont("Consolas", 16, Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.LIGHT)

local ServerIdDictionary = {
	[1] = "USWest",
	[2] = "USEast",
	[3] = "Europe",
	[4] = "Singapore",
	[5] = nil, -- closed
	[6] = "Brazil",
	[7] = "Argentina",
	[8] = "Stockholm",
	[9] = "Austria",
	[10] = "Australia",
	[11] = "South Africa",
	[12] = "PWTelecom",
	[13] = "PWUnicom",
	[14] = "Dubai",
	[15] = "Chile",
	[16] = "Peru",
	[17] = "India",
	[18] = "PWGuangzhou",
	[19] = "PWZhejiang",
	[20] = "Japan",
	[21] = "PWWuhan",
	[22] = nil, --closed
	[23] = nil, --closed
	[24] = nil, --closed
	[25] = nil, --closed
	[26] = "PWTianjin",
}

local timer = GameRules.GetGameTime();
local flag = false
local RegionsData = {}
local sorted = {}
local totalPlayers = 0
local lastUpdate = "never"
local count = 0

function PlayersInQueue.OnFrame()
	if not Menu.IsEnabled(PlayersInQueue.optionEnable) then return end
	if (GameRules.GetGameState() == 5 or Engine.IsInGame()) then return end
	if flag == false then
		local request = {}
		local encodedMessage = protobuf.encodeFromJSON("CMsgDOTAMatchmakingStatsRequest", JSON:encode(request))
		GC.SendMessage(encodedMessage.binary, 7197, encodedMessage.size)
		flag = true
	end
	local x, y = Menu.GetValue(PlayersInQueue.xPos), Menu.GetValue(PlayersInQueue.yPos)
	local alpha = 255
	if Input.IsCursorInRect(x, y, 329, 500) then
		alpha = Menu.GetValue(PlayersInQueue.alphaHover)
	end
	Renderer.SetDrawColor(21, 21, 21, alpha)
	Renderer.DrawFilledRoundedRect(x, y, 329, 500, 5) -- backgroundMain
	Renderer.SetDrawColor(28, 28, 28, alpha)
	Renderer.DrawFilledRoundedRect(x, y, 329, 35, 2) -- backgroundTop
	Renderer.SetDrawColor(153, 30, 51, alpha)
	Renderer.DrawFilledRect(x, y, 330, 2) -- topLine
	Renderer.SetDrawColor(255, 255, 255, alpha)
	Renderer.DrawText(font, x + 11, y + 9, "Current players: ") -- currentPlayers text
	local xSize, ySize = Renderer.GetTextSize(font, "Current players: ")
	Renderer.SetDrawColor(168, 168, 168, alpha)
	Renderer.DrawText(font, x + 7 + xSize, y + 9, totalPlayers .. " players") -- currentPlayers text
	Renderer.SetDrawColor(28, 28, 28, alpha)
	Renderer.DrawFilledRoundedRect(x + 10, y + 45, 120, 23, 4) -- serverStatusBG
	Renderer.SetDrawColor(216, 211, 211, alpha)
	if (RegionsData[1] == nil) then
		Renderer.DrawText(font2, x + 40, y + 51, "Server offline") -- currentPlayers text
		Renderer.SetDrawColor(45, 45, 45, alpha)
		Renderer.DrawFilledRoundedRect(x + 15, y + 49, 15, 15, 4) -- serverStatusBG
		Renderer.SetDrawColor(184, 34, 34, alpha)
		Renderer.DrawFilledRoundedRect(x + 18, y + 52, 9, 9, 3) -- serverStatusValue
	else
		Renderer.DrawText(font2, x + 40, y + 51, "Server online") -- currentPlayers text
		Renderer.SetDrawColor(45, 45, 45, alpha)
		Renderer.DrawFilledRoundedRect(x + 15, y + 49, 15, 15, 4) -- serverStatusCirlce(rect)
		Renderer.SetDrawColor(39, 174, 96, alpha)
		Renderer.DrawFilledRoundedRect(x + 18, y + 52, 9, 9, 3) -- serverStatusCirlce(rect)
	end
	Renderer.SetDrawColor(28, 28, 28, alpha)
	Renderer.DrawFilledRoundedRect(x + 140, y + 45, 180, 23, 4) -- lastUpdateBG
	Renderer.SetDrawColor(216, 211, 211, alpha)
	Renderer.DrawText(font2, x + 175, y + 51, "last update: " .. lastUpdate) -- lastUpdateText+Value
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 145, y + 49, 15, 15, 4) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(242, 153, 74, alpha)
	Renderer.DrawFilledRoundedRect(x + 148, y + 52, 9, 9, 3) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)	--REPEATED TO FIX ALPHA BUG
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	Renderer.SetDrawColor(45, 45, 45, alpha)
	Renderer.DrawFilledRoundedRect(x + 150, y + 54, 5, 5, 2) -- lastUpdateCirlce(rect)
	count = 0
	for srv, players in pairs(RegionsData) do
		if players > 0 then
			Renderer.SetDrawColor(255, 255, 255, alpha)
			Renderer.DrawText(font3, x + 11, y + 76 + (20 * count), ServerIdDictionary[srv]..": ") -- currentServerName text
			local xSize, ySize = Renderer.GetTextSize(font3, ServerIdDictionary[srv]..": ")
			Renderer.SetDrawColor(168, 168, 168, alpha)
			Renderer.DrawText(font3, x + 7 + xSize, y + 76 + (20 * count), players .. " players") -- currentServerPlayers text
			count = count + 1
		end
	end
end

function PlayersInQueue.OnGCMessage(msg)
    if msg.msg_type == 7198.0 then
		local data = JSON:decode(protobuf.decodeToJSON("CMsgDOTAMatchmakingStatsResponse", msg.binary_buffer_recv, msg.size))
		RegionsData = data.legacy_searching_players_by_group_source2
		totalPlayers = 0
		local time = os.time()
		lastUpdate = os.date('%X', time)
		for srv, players in pairs(RegionsData) do
			totalPlayers = totalPlayers + players
		end
	end
end

return PlayersInQueue
