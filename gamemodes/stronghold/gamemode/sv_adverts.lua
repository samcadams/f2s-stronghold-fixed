GM.Adverts = {}

local PATH_HINTS = "stronghold/hint_adverts.txt"
local URL_HINTS = "http://roaringcow.com/PDT/hint_adverts.txt"

local PATH_CHATVERTS = "stronghold/chat_adverts.txt"
local URL_CHATVERTS = "http://roaringcow.com/PDT/chat_adverts.txt"

GM.Adverts.KeyReplacements = {}
GM.Adverts.KeyReplacements["{HOSTNAME}"] = function() return GetHostName() end
GM.Adverts.KeyReplacements["{TIMELIMIT}"] = function() local t = (GetConVarNumber( "mp_timelimit" )*60) return Format("%01d:%02d",math.floor(t/60),math.floor(t%60)) end
GM.Adverts.KeyReplacements["{TIMELEFT}"] = function() local t = (GetConVarNumber( "mp_timelimit" )*60) - (CurTime()-(GAMEMODE.LastGameReset or 0)) return Format("%01d:%02d",math.floor(t/60),math.floor(t%60)) end
GM.Adverts.KeyReplacements["{FRAGLIMIT}"] = function() return GetConVarNumber( "mp_fraglimit" ) end
GM.Adverts.KeyReplacements["{SERVERTIME}"] = function() return os.date("%H:%M:%S %z") end
GM.Adverts.KeyReplacements["{CURRENTMAP}"] = function() return game.GetMap() end
GM.Adverts.KeyReplacements["{NEXTMAP}"] = function() return game.GetMapNext() end

GM.Adverts.Hints = {}
GM.Adverts.HintsTime = 30
GM.Adverts.CurrentHint = 1
GM.Adverts.LastSentHint = { color=1, text="" }

GM.Adverts.Chatverts = {}
GM.Adverts.ChatvertsTime = 30
GM.Adverts.CurrentChatvert = 1
GM.Adverts.LastSentChatvert = { color=1, text="" }

local function AddAdvertsToTableFromString( str_src, tbl_dest )
	local lines = string.Explode( "\n", str_src )
	for _, line in ipairs(lines) do
		-- Trim spaces at the left
		line = string.TrimLeft( line, " " )
		line = string.TrimLeft( line, "\t" )
		
		-- Split line to get color and string
		local sep = string.find( line, ";" )
		if sep and string.Left( line, 2 ) != "//" then
			table.insert( tbl_dest, {
				color = tonumber( string.Left(line,sep-1) ),
				text = string.sub( line, sep+1 )
			} )
		end
	end
end

function GM:LoadAdverts( ply )
	if IsValid( ply ) and !ply:IsAdmin() then return end
	
	GAMEMODE.Adverts.Hints = {}
	GAMEMODE.Adverts.Chatverts = {}

	-- Load file if it exists otherwise create it
	if file.Exists( PATH_HINTS, "DATA" ) then
		local data = file.Read( PATH_HINTS, "DATA" )
		AddAdvertsToTableFromString( data, GAMEMODE.Adverts.Hints )
	else
		file.Write( PATH_HINTS, GAMEMODE.Adverts.HintsFileDefault ) -- Default file is at the bottom of the file
		GAMEMODE:LoadAdverts()
		return
	end
	
	-- Now that the file loaded, load the website list of hints
	http.Fetch( URL_HINTS, function(body,_,_,code) if code ~= 200 then return end AddAdvertsToTableFromString(body,GAMEMODE.Adverts.Hints) end )
	
	-- Load optional chatverts file
	if file.Exists( PATH_CHATVERTS, "DATA" ) then
		local data = file.Read( PATH_CHATVERTS, "DATA" )
		AddAdvertsToTableFromString( data, GAMEMODE.Adverts.Chatverts )
	end
	
	-- Load the website list of chatverts
	http.Fetch( URL_CHATVERTS, function(body,_,_,code) if code ~= 200 then return end AddAdvertsToTableFromString(body,GAMEMODE.Adverts.Chatverts) end )
end
concommand.Add( "sh_reloadadverts", function() GAMEMODE:LoadAdverts() end )

local function HintsTimer()
	local GAMEMODE = GAMEMODE or GM

	if #GAMEMODE.Adverts.Hints == 0 then return end

	if GAMEMODE.Adverts.CurrentHint > #GAMEMODE.Adverts.Hints then GAMEMODE.Adverts.CurrentHint = 1 end
	
	local type = "hint"
	local list = GAMEMODE.Adverts.Hints
	local current = GAMEMODE.Adverts.CurrentHint
	GAMEMODE.Adverts.CurrentHint = GAMEMODE.Adverts.CurrentHint + 1
	
	-- CODE BELOW THIS POINT IN THIS FUNCTION IS PLUG-AND-PLAY WITH OTHER TIMER (It uses the locals above)
	
	-- Get advert color and string
	local col = list[current] and list[current].color or 1
	local str = list[current] and list[current].text or ""
	
	-- Replace keys in string
	for k, v in pairs(GAMEMODE.Adverts.KeyReplacements) do
		str = string.gsub( str, k, tostring(v()) )
	end
	
	-- Replace convars
	str = string.gsub( str, "{(.+)}", GetConVarString )
	
	-- Send it to everyone
	for _, ply in ipairs(player.GetHumans()) do
		if IsValid( ply ) then
			GAMEMODE.Net:SendAdvert( ply, type, col, str )
		end
	end
	
	GAMEMODE.Adverts.LastSentHint = { color=col, text=str }
end HintsTimer()
timer.Create( "SH_Adverts_Hints", GM.Adverts.HintsTime, 0, HintsTimer )

local function ChatvertsTimer()
	if #GAMEMODE.Adverts.Chatverts == 0 then return end

	if GAMEMODE.Adverts.CurrentChatvert > #GAMEMODE.Adverts.Hints then GAMEMODE.Adverts.CurrentChatvert = 1 end
	
	local type = "chatvert"
	local list = GAMEMODE.Adverts.Chatverts
	local current = GAMEMODE.Adverts.CurrentChatvert
	GAMEMODE.Adverts.CurrentChatvert = GAMEMODE.Adverts.CurrentChatvert + 1
	
	-- CODE BELOW THIS POINT IN THIS FUNCTION IS PLUG-AND-PLAY WITH OTHER TIMER (It uses the locals above)
	
	-- Get advert color and string
	local col = list[current] and list[current].color or 1
	local str = list[current] and list[current].text or ""
	
	-- Replace keys in string
	for k, v in pairs(GAMEMODE.Adverts.KeyReplacements) do
		str = string.gsub( str, k, tostring(v()) )
	end
	
	-- Replace convars
	str = string.gsub( str, "{(.+)}", GetConVarString )
	
	-- Send it to everyone
	for _, ply in ipairs(player.GetHumans()) do
		if IsValid( ply ) then
			GAMEMODE.Net:SendAdvert( ply, type, col, str )
		end
	end
	
	GAMEMODE.Adverts.LastSentChatvert = { color=col, text=str }
end
timer.Create( "SH_Adverts_Chatvert", GM.Adverts.ChatvertsTime, 0, ChatvertsTimer )

GM.Adverts.HintsFileDefault = [[// Keys:
//   {HOSTNAME}
//   {TIMELIMIT}
//   {TIMELEFT}
//   {FRAGLIMIT}
//   {SERVERTIME}
//   {CURRENTMAP}
//   {NEXTMAP}
//   {<convar>}
//
// Colors:
//   1  = White
//   2  = Grey
//   3  = Red
//   4  = Green
//   5  = Blue
//   6  = Yellow
//   7  = Orange
//   8  = Teal
//   9  = Aqua
//   10 = Violet
//
// Console Command 'sh_reloadadverts' reloads this file into the advert system.

1;If you experience performance issues, try turning off effects in the options menu.
4;Hold right click with the toolgun and move your mouse to switch tool modes.
7;It's a good idea to create more than one spawnpoint.
9;Spawn protection will protect you for {sh_immunetime} seconds.
3;Money farming is considered cheating.]]
