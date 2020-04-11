--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
-- Required locals from _G
local debug = debug
local ErrorNoHalt = ErrorNoHalt
local file = file
local ipairs = ipairs
local os = os
local pairs = pairs
local PrintTable = PrintTable
local IsValid = IsValid
local sql = sql
local string = string
local table = table
local type = type
local tonumber = tonumber
local tostring = tostring

if !file.Exists( "sqlx_log", "DATA" ) then
	file.CreateDir( "sqlx_log" )
end

-- Global key types for using sqlx
SQLX_KEYTYPE_STEAMID = "steamid"
SQLX_KEYTYPE_UNIQUEID = "uniqueid"
SQLX_KEYTYPE_NAME = "name" -- NOT UNIQUE!!

-- Not sure how redundant this is (Is the above considered local and global?
local SQLX_KEYTYPE_STEAMID = SQLX_KEYTYPE_STEAMID
local SQLX_KEYTYPE_UNIQUEID = SQLX_KEYTYPE_UNIQUEID
local SQLX_KEYTYPE_NAME = SQLX_KEYTYPE_NAME

module( "sqlx" )

-- Handles SQL errors
-- Depending on the settings just below here this function is able to:
--   Save sql errors to ./data/sqlx_log/mm_dd_yyyy.txt
--   <SAME AS ABOVE> with the query that trigger the error
local SAVE_SQL_ERRORS = true
local SAVE_SQL_ERRORS_WITH_QUERY = true
local function SqlError( str, query )
	str = str or "<SQL ERROR>"

	if SAVE_SQL_ERRORS then
		local datestamp = os.date( "%m_%d_%y" )
		local timestamp = os.date( "(%H:%M:%S)" )
		
		local path = "sqlx_log/"..datestamp..".txt"
		local line = timestamp.." "..str
		if SAVE_SQL_ERRORS_WITH_QUERY then
			line = line.." ["..(query or "<QUERY>").."]\n"
		else
			line = line.."\n"
		end
		
		if file.Exists( path, "DATA" ) then
			local data = file.Read( path )
			file.Write( path, data..line )
		else
			file.Write( path, timestamp..line )
		end
	end
	
	ErrorNoHalt( "sqlx error: "..str.."\n" )
end

-- Creates a table with CREATE TABLE IF NOT EXISTS
-- Tables that already exist are not overwriten
-- Syntax; <NAME>, <COLUMN>, <COLUMN>, ...
function InitTable( tbl_name, column, ... )
	local query = "CREATE TABLE IF NOT EXISTS "..tbl_name.." ("..column
	for _, v in ipairs({...}) do
		query = query..", "..v
	end
	query = query..")"
	local result = sql.Query( query )
	if result == false then
		SqlError( sql.LastError(), query )
	end
end

-- sqlx.PlayerDataExists( string tbl_name, Player ply, [table conditions,] [SQLX_KEYTYPE_*] )
-- Checks if a player's data exists in the given table (Count > 0)
-- Conditions can be added besides the automatic ID check
-- conditions = {column = {"<OPERATOR>",<VALUE>}, ... }
-- SQL Operators: =, <>, >, <, >=, <=, BETWEEN, LIKE, IN
function PlayerDataExists( tbl_name, ply, conditions, key_type )
	key_type = key_type or SQLX_KEYTYPE_STEAMID
	conditions = conditions or {}
	if IsValid( ply ) then
		local key = nil
		if key_type == SQLX_KEYTYPE_STEAMID then
			key = ply:SteamID()
		elseif key_type == SQLX_KEYTYPE_UNIQUEID then
			key = ply:UniqueID()
		elseif key_type == SQLX_KEYTYPE_NAME then
			key = string.Left( ply:GetName(), 32 )
		end
		if key == nil then return false end
		
		local conditionals = ""
		for k, v in pairs(conditions) do
			if #v == 2 then
				local condition, value
				condition = v[1]
				
				if type(v[2]) == "string" then
					value = sql.SQLStr(tostring(v[2]))
				else
					value = tostring(v[2])
				end
				
				conditionals = conditionals.." AND "..k.." "..condition.." "..value
			end
		end
		
		local query = "SELECT COUNT("..key_type..") FROM "..tbl_name.." WHERE "..key_type.." = "..sql.SQLStr(key)..conditionals
		local val = sql.QueryRow( query )
		if val == false then
			SqlError( sql.LastError(), query )
		else
			return tonumber( val["COUNT("..key_type..")"] ) > 0
		end
	end
	return false
end

-- sqlx.GetPlayerData( string tbl_name, Player ply, [table conditions,] [bool always_multi,] [SQLX_KEYTYPE_*] )
-- Gets a player's data in the given table
-- Conditions can be added besides the automatic ID check
-- conditions = {column = {"<OPERATOR>",<VALUE>}, ... }
-- SQL Operators: =, <>, >, <, >=, <=, BETWEEN, LIKE, IN
function GetPlayerData( tbl_name, ply, conditions, always_multi, key_type )
	key_type = key_type or SQLX_KEYTYPE_STEAMID
	conditions = conditions or {}
	if IsValid( ply ) then
		local key = nil
		if key_type == SQLX_KEYTYPE_STEAMID then
			key = ply:SteamID()
		elseif key_type == SQLX_KEYTYPE_UNIQUEID then
			key = ply:UniqueID()
		elseif key_type == SQLX_KEYTYPE_NAME then
			key = string.Left( ply:GetName(), 32 )
		end
		if key == nil then return {} end
		
		local conditionals = ""
		for k, v in pairs(conditions) do
			if #v == 2 then
				local condition, value
				condition = v[1]
				
				if type(v[2]) == "string" then
					value = sql.SQLStr(tostring(v[2]))
				else
					value = tostring(v[2])
				end
				
				conditionals = conditionals.." AND "..k.." "..condition.." "..value
			end
		end
		
		local query = "SELECT * FROM "..tbl_name.." WHERE "..key_type.." = "..sql.SQLStr(key)..conditionals
		local result = sql.Query( query )
		if result == false then
			SqlError( sql.LastError(), query )
		else
			return (#result == 1 and !always_multi) and result[1] or result
		end
	end
end

-- sqlx.UpdatePlayerData( string tbl_name, Player ply, table entries, [table conditions,] [SQLX_KEYTYPE_*] )
-- Updates a player's data in the given table
-- entries MUST contain at least ONE entry
-- Conditions can be added besides the automatic ID check
-- conditions = {column = {"<OPERATOR>",<VALUE>}, ... }
-- SQL Operators: =, <>, >, <, >=, <=, BETWEEN, LIKE, IN
function UpdatePlayerData( tbl_name, ply, entries, conditions, key_type )
	key_type = key_type or SQLX_KEYTYPE_STEAMID
	conditions = conditions or {}
	if IsValid( ply ) then
		local key = nil
		if key_type == SQLX_KEYTYPE_STEAMID then
			key = ply:SteamID()
		elseif key_type == SQLX_KEYTYPE_UNIQUEID then
			key = ply:UniqueID()
		elseif key_type == SQLX_KEYTYPE_NAME then
			key = string.Left( ply:GetName(), 32 )
		end
		if key == nil then return {} end
		
		if entries == nil or table.Count(entries) == 0 then return end
		
		local i = 1
		local values = ""
		for k, v in pairs(entries) do
			if i == 1 then
				if type(v) == "string" then
					values = values..k.."="..sql.SQLStr(tostring(v))
				else
					values = values..k.."="..tostring(v)
				end
			else
				if type(v) == "string" then
					values = values..", "..k.."="..sql.SQLStr(tostring(v))
				else
					values = values..", "..k.."="..tostring(v)
				end
			end
			i = i + 1
		end
		
		local conditionals = ""
		for k, v in pairs(conditions) do
			if #v == 2 then
				local condition, value
				condition = v[1]
				
				if type(v[2]) == "string" then
					value = sql.SQLStr(tostring(v[2]))
				else
					value = tostring(v[2])
				end
				
				conditionals = conditionals.." AND "..k.." "..condition.." "..value
			end
		end
		
		local query = "UPDATE "..tbl_name.." SET "..values.." WHERE "..key_type.." = "..sql.SQLStr(key)..conditionals
		local result = sql.Query( query )
		if result == false then
			SqlError( sql.LastError(), query )
		else
			return result
		end
	end
end

-- sqlx.CreatePlayerData( string tbl_name, Player ply, [table entries,] [SQLX_KEYTYPE_*] )
-- Creates a player's data in the given table
-- entries MUST contain at least ONE entry
function CreatePlayerData( tbl_name, ply, entries, key_type )
	entries = entries or {}
	key_type = key_type or SQLX_KEYTYPE_STEAMID
	if IsValid( ply ) then
		local key = nil
		if key_type == SQLX_KEYTYPE_STEAMID then
			key = ply:SteamID()
		elseif key_type == SQLX_KEYTYPE_UNIQUEID then
			key = ply:UniqueID()
		elseif key_type == SQLX_KEYTYPE_NAME then
			key = string.Left( ply:GetName(), 32 )
		end
		if key == nil then return {} end
		
		if entries == nil or table.Count(entries) == 0 then return end
		
		local keys = key_type
		local values = sql.SQLStr(key)
		for k, v in pairs(entries) do
			keys = keys..", "..k
			if type(v) == "string" then
				values = values..", "..sql.SQLStr(tostring(v))
			else
				values = values..", "..tostring(v)
			end
		end
		
		local result = sql.Query( "INSERT INTO "..tbl_name.."("..keys..") VALUES ("..values..")" )
		if result == false then
			SqlError( sql.LastError() )
		else
			return result
		end
	end
end

-- sqlx.DeletePlayerData( string tbl_name, Player ply, [table conditions,] [SQLX_KEYTYPE_*] )
-- BE CAREFUL WITH THIS! IT WILL DELETE EVERYTHING THAT MEETS THE CONDITIONS! (key and conditions)
-- Conditions can be added besides the automatic ID check
-- conditions = {column = {"<OPERATOR>",<VALUE>}, ... }
-- SQL Operators: =, <>, >, <, >=, <=, BETWEEN, LIKE, IN
function DeletePlayerData( tbl_name, ply, conditions, key_type )
	key_type = key_type or SQLX_KEYTYPE_STEAMID
	conditions = conditions or {}
	if IsValid( ply ) then
		local key = nil
		if key_type == SQLX_KEYTYPE_STEAMID then
			key = ply:SteamID()
		elseif key_type == SQLX_KEYTYPE_UNIQUEID then
			key = ply:UniqueID()
		elseif key_type == SQLX_KEYTYPE_NAME then
			key = string.Left( ply:GetName(), 32 )
		end
		if key == nil then return {} end
		
		local conditionals = ""
		for k, v in pairs(conditions) do
			if #v == 2 then
				local condition, value
				condition = v[1]
				
				if type(v[2]) == "string" then
					value = sql.SQLStr(tostring(v[2]))
				else
					value = tostring(v[2])
				end
				
				conditionals = conditionals.." AND "..k.." "..condition.." "..value
			end
		end
		
		local query = "DELETE FROM "..tbl_name.." WHERE "..key_type.." = "..sql.SQLStr(key)..conditionals
		local result = sql.Query( query )
		if result == false then
			SqlError( sql.LastError(), query )
			return false
		end
	end
	return true
end