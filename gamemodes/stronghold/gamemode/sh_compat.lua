--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

-- These are some things that could be replaced with newer code, but really isn't that much less efficient

FORCE_STRING, FORCE_NUMBER, FORCE_BOOL, FORCE_ENTITY = 1, 2, 3, 4
FORCE_VECTOR, FORCE_ANGLE = 5, 6

local funcTypes = {
	[FORCE_STRING] = "String",
	[FORCE_NUMBER] = "Int",
	[FORCE_BOOL] = "Bool",
	[FORCE_ENTITY] = "Entity",
	[FORCE_VECTOR] = "Vector",
	[FORCE_ANGLE] = "Angle",
}
--function AccessorFuncNW( meta, varname, name, varDefault, iForce )
--    local getName, setName = "GetNW".. funcTypes[iForce], "SetNW".. funcTypes[iForce]
--
--    meta["Get"..name] = function( ent ) return ent[getName]( varname, varDefault ) end
--
--    if iForce == FORCE_STRING then
--        meta[ "Set"..name ] = function( ent, v ) ent[setName]( varname, tostring(v) ) end
--    elseif iForce == FORCE_NUMBER then
--        meta[ "Set"..name ] = function( ent, v ) ent[setName]( varname, tonumber(v) ) end
--    elseif iForce == FORCE_BOOL then
--        meta[ "Set"..name ] = function( ent, v ) ent[setName]( varname, tobool(v) ) end
--    else
--        meta[ "Set"..name ] = function( ent, v ) ent[setName]( varname, v ) end
--    end
--end

function AccessorFuncNW( meta, strVarName, strID, varDefault, intType )
	local getName, setName = "GetNW".. funcTypes[intType], "SetNW".. funcTypes[intType]

	meta["Get"..strID] = function( ent ) return ent[getName]( ent, strVarName, varDefault ) end
	meta["Set"..strID] = function( ent, v ) ent[setName]( ent, strVarName, v ) end
end