--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
if SERVER then
	local function LimitReachedProcess( ply, str )
		local max = GetConVarNumber( "sbox_max"..str, 0 )
		
		--[[if str == "props" then
			if ply:IsGold() then
				max = max + 10
			elseif ply:IsPlatinum() or ply:IsAdmin() then
				max = max + 20
			end
		end]]
		
		if ply:GetCount( str ) < max or max < 0 then return true end 

		ply:LimitHit( str ) 
		return false
	end

	function GM:PlayerSpawnProp( ply, model )
		return table.HasValue( self.SpawnLists["All"], string.lower(model) ) and LimitReachedProcess( ply, "props" )
	end

	function GM:PlayerSpawnEffect( ply, model )
		return table.HasValue( self.SpawnLists["All"], string.lower(model) ) and LimitReachedProcess( ply, "effects" )
	end
	
	local function SwitchToToolGun( ply )
		local wep = ply:GetWeapon( "weapon_sh_tool" )
		if wep.SetFireMode then wep:SetFireMode( 0 ) end
		ply:SelectWeapon( "weapon_sh_tool" )
	end
	concommand.Add( "gmod_tool", SwitchToToolGun )
end

function GM:PlayerSpawnObject( ply )
	return true
end

function GM:PlayerSpawnedProp( ply, model, ent )
	self:GetDefaultHealth( ent )

	ply:AddCount( "props", ent )
	ent:SetOwnerEnt( ply )
	ent:SetOwnerUID( ply:UniqueID() )
	
	self:SetEntHealth( ent )
	
	local physobj = ent:GetPhysicsObject()
	if physobj:IsValid() then physobj:SetMass( 10000 ) end
	
	ply:AddStatistic( "propsplaced", 1 )
end

function FixInvalidPhysicsObject( Prop )
	local PhysObj = Prop:GetPhysicsObject()
	if !PhysObj then return end

	local min, max = PhysObj:GetAABB()
	if !min or !max then return end
	
	local PhysSize = (min - max):Length()
	if PhysSize > 5 then return end
	
	local min = Prop:OBBMins()	
	local max = Prop:OBBMaxs()
	if !min or !max then return end
	
	local ModelSize = (min - max):Length()
	local Difference = math.abs( ModelSize - PhysSize )
	if Difference < 10 then return end

	Prop:PhysicsInitBox( min, max )
	Prop:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	local PhysObj = Prop:GetPhysicsObject()
	if !PhysObj then return end

	PhysObj:SetMass( 100 )
	PhysObj:Wake()
end

local noteam = { "remover" }
local blockedweapons = { "remover", "doormod" }
function GM:CanTool( ply, trace, mode )
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "tree_light" then
		return false
	end

	local owner, owneruid = trace.Entity:GetOwnerEnt(), trace.Entity:GetOwnerUID()
	if IsValid( owner ) then
		local owner_team = owner:Team()
		if table.HasValue( blockedweapons, mode ) and ( (IsValid( trace.Entity:GetOwnerEnt() ) and trace.Entity:GetOwnerEnt() != ply) or trace.Entity:GetOwnerUID() != ply:UniqueID() ) then
			if owner_team > 50 and owner_team < 1000 and owner_team == ply:Team() then
				if table.HasValue( noteam, mode ) then return false end
			else
				return false
			end
		end
	end

	if trace.Entity.m_tblToolsAllowed then
		local vFound = false	
		for k, v in pairs(trace.Entity.m_tblToolsAllowed) do
			if mode == v then vFound = true end
		end
		if !vFound then return false end
	end

	if trace.Entity.CanTool then
		return trace.Entity:CanTool( ply, trace, mode )
	end
	
	return true
end

function GM:PlayerSpawnSENT( ply, name )
	return true
end

function GM:PlayerSpawnedSENT( ply, ent )
	self:GetDefaultHealth( ent )

	ply:AddCount( "sents", ent )
	ent:SetOwnerEnt( ply )
	ent:SetOwnerUID( ply:UniqueID() )
end

GM.SpawnLists = {}

GM.SpawnLists["All"] = {
	"models/props_c17/concrete_barrier001a.mdl",
	"models/props_wasteland/kitchen_counter001b.mdl",
	"models/props_wasteland/kitchen_counter001d.mdl",
	"models/props_c17/lockers001a.mdl",
	"models/props_interiors/vendingmachinesoda01a.mdl",
	"models/props_interiors/vendingmachinesoda01a_door.mdl",
	"models/props_lab/lockerdoorleft.mdl",
	"models/props_borealis/borealis_door001a.mdl",
	"models/props_junk/trashdumpster02b.mdl",
	"models/props_c17/signpole001.mdl",
	"models/props_junk/ibeam01a.mdl",
	"models/props_docks/dock01_pole01a_128.mdl",
	"models/props_docks/dock03_pole01a_256.mdl",
	"models/props_c17/fence01a.mdl",
	"models/props_c17/fence01b.mdl",
	"models/props_c17/fence03a.mdl",
	"models/props_wasteland/interior_fence001a.mdl",
	"models/props_wasteland/interior_fence001b.mdl",
	"models/props_wasteland/interior_fence001c.mdl",
	"models/props_wasteland/interior_fence001d.mdl",
	"models/props_wasteland/interior_fence001g.mdl",
	"models/props_wasteland/interior_fence002a.mdl",
	"models/props_wasteland/interior_fence002b.mdl",
	"models/props_wasteland/interior_fence002c.mdl",
	"models/props_wasteland/interior_fence002d.mdl",
	"models/props_wasteland/interior_fence002f.mdl",
	"models/hunter/plates/plate1x1.mdl",
	"models/hunter/plates/plate1x2.mdl",
	"models/hunter/plates/plate1x4.mdl",
	"models/hunter/plates/plate2x2.mdl",
	"models/hunter/plates/plate2x3.mdl",
	"models/hunter/plates/plate3x3.mdl",
	"models/hunter/plates/plate3x4.mdl",
	"models/hunter/blocks/cube025x2x025.mdl",
	"models/hunter/blocks/cube025x4x025.mdl",
	"models/hunter/blocks/cube1x1x1.mdl",
	"models/hunter/tubes/tube2x2x1.mdl",
	"models/hunter/tubes/tube2x2x1b.mdl",
	"models/hunter/tubes/tube2x2x1c.mdl",
	"models/hunter/tubes/tube2x2x1d.mdl",
	"models/balloons/balloon_classicheart.mdl"
}

GM.SpawnLists["Doors"] = {
	"models/props_interiors/vendingmachinesoda01a_door.mdl",
	"models/props_lab/lockerdoorleft.mdl",
	"models/props_borealis/borealis_door001a.mdl",
	"models/props_junk/trashdumpster02b.mdl"
}

GM.SpawnLists["Fences"] = {
	"models/props_c17/fence01a.mdl",
	"models/props_c17/fence01b.mdl",
	"models/props_c17/fence03a.mdl",
	"models/props_wasteland/interior_fence001a.mdl",
	"models/props_wasteland/interior_fence001b.mdl",
	"models/props_wasteland/interior_fence001c.mdl",
	"models/props_wasteland/interior_fence001d.mdl",
	"models/props_wasteland/interior_fence001g.mdl",
	"models/props_wasteland/interior_fence002a.mdl",
	"models/props_wasteland/interior_fence002b.mdl",
	"models/props_wasteland/interior_fence002c.mdl",
	"models/props_wasteland/interior_fence002d.mdl",
	"models/props_wasteland/interior_fence002f.mdl"
}

GM.SpawnLists["Misc"] = {
	"models/props_c17/concrete_barrier001a.mdl",
	"models/props_wasteland/kitchen_counter001b.mdl",
	"models/props_wasteland/kitchen_counter001d.mdl",
	"models/props_c17/lockers001a.mdl",
	"models/props_interiors/vendingmachinesoda01a.mdl"
}

GM.SpawnLists["PHX"] = {
	"models/hunter/plates/plate1x1.mdl",
	"models/hunter/plates/plate1x2.mdl",
	"models/hunter/plates/plate1x4.mdl",
	"models/hunter/plates/plate2x2.mdl",
	"models/hunter/plates/plate2x3.mdl",
	"models/hunter/plates/plate3x3.mdl",
	"models/hunter/plates/plate3x4.mdl",
	"models/hunter/blocks/cube025x2x025.mdl",
	"models/hunter/blocks/cube025x4x025.mdl",
	"models/hunter/blocks/cube1x1x1.mdl",
	"models/hunter/tubes/tube2x2x1.mdl",
	"models/hunter/tubes/tube2x2x1b.mdl",
	"models/hunter/tubes/tube2x2x1c.mdl",
	"models/hunter/tubes/tube2x2x1d.mdl"
}

GM.SpawnLists["Poles"] = {
	"models/props_c17/signpole001.mdl",
	"models/props_junk/ibeam01a.mdl",
	"models/props_docks/dock01_pole01a_128.mdl",
	"models/props_docks/dock03_pole01a_256.mdl"
}

GM.SpawnAngleOffset = {
	["models/hunter/plates/plate1x1.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate1x2.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate1x4.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate2x2.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate2x3.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate3x3.mdl"] = Angle( -90, 0, 0 ),
	["models/hunter/plates/plate3x4.mdl"] = Angle( -90, 0, 0 )
}

GM.SpawnPositionOffset = {
	["models/hunter/plates/plate1x1.mdl"] = 24,
	["models/hunter/plates/plate1x2.mdl"] = 24,
	["models/hunter/plates/plate1x4.mdl"] = 24,
	["models/hunter/plates/plate2x2.mdl"] = 48,
	["models/hunter/plates/plate2x3.mdl"] = 48,
	["models/hunter/plates/plate3x3.mdl"] = 72,
	["models/hunter/plates/plate3x4.mdl"] = 72
}

--[[GM.SpawnLists["All"] = {
	"models/combine_helicopter/helicopter_bomb01.mdl",
	"models/props_borealis/mooring_cleat01.mdl",
	--"models/props_borealis/door_wheel001a.mdl",
	"models/props_borealis/borealis_door001a.mdl",
	"models/props_borealis/bluebarrel001.mdl",
	--"models/props_building_details/storefront_template001a_bars.mdl",
	"models/props_c17/canister01a.mdl",
	"models/props_c17/canister02a.mdl",
	"models/props_c17/canister_propane01a.mdl",
	"models/props_c17/bench01a.mdl",
	"models/props_c17/chair02a.mdl",
	"models/props_c17/concrete_barrier001a.mdl",
	"models/props_c17/display_cooler01a.mdl",
	"models/props_c17/door01_left.mdl",
	"models/props_c17/door02_double.mdl",
	"models/props_c17/fence01a.mdl",
	"models/props_c17/fence01b.mdl",
	"models/props_c17/fence02a.mdl",
	"models/props_c17/fence02b.mdl",
	"models/props_c17/fence03a.mdl",
	"models/props_c17/fence04a.mdl",
	"models/props_c17/furniturebathtub001a.mdl",
	"models/props_c17/furniturebed001a.mdl",
	"models/props_c17/furnitureboiler001a.mdl",
	"models/props_c17/furniturechair001a.mdl",
	"models/props_c17/furniturecouch001a.mdl",
	"models/props_c17/furniturecouch002a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_c17/furnituredrawer002a.mdl",
	"models/props_c17/furnituredrawer003a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_c17/furniturefireplace001a.mdl",
	"models/props_c17/furniturefridge001a.mdl",
	"models/props_c17/furnituremattress001a.mdl",
	--"models/props_c17/furnitureradiator001a.mdl",
	"models/props_c17/furnitureshelf001a.mdl",
	"models/props_c17/furnitureshelf001b.mdl",
	"models/props_c17/furnitureshelf002a.mdl",
	"models/props_c17/furnituresink001a.mdl",
	"models/props_c17/furniturestove001a.mdl",
	"models/props_c17/furnituretable001a.mdl",
	"models/props_c17/furnituretable002a.mdl",
	"models/props_c17/furnituretable003a.mdl",
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_c17/gate_door01a.mdl",
	"models/props_c17/gate_door02a.mdl",
	"models/props_c17/lampshade001a.mdl",
	"models/props_c17/lockers001a.mdl",
	"models/props_c17/metalladder001.mdl",
	"models/props_c17/metalladder002.mdl",
	"models/props_c17/oildrum001.mdl",
	--"models/props_c17/pulleywheels_small01.mdl",
	--"models/props_c17/pulleywheels_large01.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_c17/signpole001.mdl",
	"models/props_c17/trappropeller_blade.mdl",
	"models/props_canal/canal_cap001.mdl",
	--"models/props_citizen_tech/windmill_blade004a.mdl",
	"models/props_combine/breenchair.mdl",
	"models/props_combine/breendesk.mdl",
	--"models/props_combine/breenglobe.mdl",
	--"models/props_combine/combine_barricade_short01a.mdl",
	--"models/props_combine/combine_barricade_short02a.mdl",
	--"models/props_combine/combine_barricade_short03a.mdl",
	--"models/props_combine/combine_bridge_b.mdl",
	--"models/props_combine/combine_fence01a.mdl",
	--"models/props_combine/combine_fence01b.mdl",
	--"models/props_combine/combine_window001.mdl",
	"models/props_combine/headcrabcannister01a.mdl",
	--"models/props_combine/weaponstripper.mdl",
	"models/props_debris/metal_panel01a.mdl",
	"models/props_debris/metal_panel02a.mdl",
	"models/props_docks/channelmarker_gib01.mdl",
	"models/props_docks/channelmarker_gib02.mdl",
	"models/props_docks/channelmarker_gib03.mdl",
	"models/props_docks/channelmarker_gib04.mdl",
	"models/props_docks/dock01_cleat01a.mdl",
	"models/props_docks/dock01_pole01a_128.mdl",
	"models/props_docks/dock01_pole01a_256.mdl",
	"models/props_docks/dock02_pole02a.mdl",
	"models/props_docks/dock02_pole02a_256.mdl",
	"models/props_docks/dock03_pole01a.mdl",
	"models/props_docks/dock03_pole01a_256.mdl",
	"models/props_doors/door03_slotted_left.mdl",
	"models/props_interiors/bathtub01a.mdl",
	--"models/props_interiors/elevatorshaft_door01a.mdl",
	"models/props_interiors/furniture_chair01a.mdl",
	"models/props_interiors/furniture_chair03a.mdl",
	"models/props_interiors/furniture_couch01a.mdl",
	"models/props_interiors/furniture_couch02a.mdl",
	"models/props_interiors/furniture_desk01a.mdl",
	"models/props_interiors/furniture_lamp01a.mdl",
	"models/props_interiors/furniture_shelf01a.mdl",
	"models/props_interiors/furniture_vanity01a.mdl",
	"models/props_interiors/pot01a.mdl",
	"models/props_interiors/pot02a.mdl",
	--"models/props_interiors/radiator01a.mdl",
	"models/props_interiors/refrigerator01a.mdl",
	"models/props_interiors/refrigeratordoor01a.mdl",
	"models/props_interiors/refrigeratordoor02a.mdl",
	"models/props_interiors/sinkkitchen01a.mdl",
	"models/props_interiors/vendingmachinesoda01a.mdl",
	"models/props_interiors/vendingmachinesoda01a_door.mdl",
	--"models/props_junk/cinderblock01a.mdl",
	--"models/props_junk/harpoon002a.mdl",
	"models/props_junk/ibeam01a_cluster01.mdl",
	"models/props_junk/ibeam01a.mdl",
	--"models/props_junk/meathook001a.mdl",
	--"models/props_junk/metal_paintcan001a.mdl",
	"models/props_junk/metalbucket01a.mdl",
	"models/props_junk/metalbucket02a.mdl",
	"models/props_junk/metalgascan.mdl",
	--"models/props_junk/plasticbucket001a.mdl",
	"models/props_junk/plasticcrate01a.mdl",
	"models/props_junk/popcan01a.mdl",
	"models/props_junk/propanecanister001a.mdl",
	"models/props_junk/pushcart01a.mdl",
	"models/props_junk/ravenholmsign.mdl",
	"models/props_junk/sawblade001a.mdl",
	"models/props_junk/trashbin01a.mdl",
	"models/props_junk/trafficcone001a.mdl",
	"models/props_junk/trashdumpster02b.mdl",
	"models/props_junk/trashdumpster01a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_lab/blastdoor001a.mdl",
	"models/props_lab/blastdoor001b.mdl",
	"models/props_lab/blastdoor001c.mdl",
	"models/props_lab/filecabinet02.mdl",
	"models/props_lab/kennel_physics.mdl",
	"models/props_lab/lockerdoorleft.mdl",
	"models/props_trainstation/benchoutdoor01a.mdl",
	"models/props_trainstation/bench_indoor001a.mdl",
	"models/props_trainstation/clock01.mdl",
	"models/props_trainstation/mount_connection001a.mdl",
	"models/props_trainstation/pole_448connection001a.mdl",
	"models/props_trainstation/pole_448connection002b.mdl",
	"models/props_trainstation/tracksign01.mdl",
	"models/props_trainstation/tracksign02.mdl",
	"models/props_trainstation/tracksign03.mdl",
	"models/props_trainstation/tracksign07.mdl",
	"models/props_trainstation/tracksign08.mdl",
	"models/props_trainstation/tracksign09.mdl",
	"models/props_trainstation/tracksign10.mdl",
	"models/props_trainstation/traincar_rack001.mdl",
	"models/props_trainstation/trainstation_arch001.mdl",
	"models/props_trainstation/trainstation_clock001.mdl",
	"models/props_trainstation/trainstation_column001.mdl",
	"models/props_trainstation/trainstation_ornament001.mdl",
	"models/props_trainstation/trainstation_ornament002.mdl",
	"models/props_trainstation/trainstation_post001.mdl",
	"models/props_trainstation/trashcan_indoor001a.mdl",
	"models/props_trainstation/trashcan_indoor001b.mdl",
	--"models/props_vehicles/tire001a_tractor.mdl",
	--"models/props_vehicles/tire001b_truck.mdl",
	--"models/props_vehicles/tire001c_car.mdl",
	--"models/props_vehicles/apc_tire001.mdl",
	"models/props_wasteland/barricade001a.mdl",
	"models/props_wasteland/barricade002a.mdl",
	"models/props_wasteland/buoy01.mdl",
	"models/props_wasteland/cafeteria_bench001a.mdl",
	"models/props_wasteland/cafeteria_table001a.mdl",
	"models/props_wasteland/controlroom_desk001a.mdl",
	"models/props_wasteland/controlroom_filecabinet001a.mdl",
	"models/props_wasteland/controlroom_chair001a.mdl",
	"models/props_wasteland/controlroom_desk001b.mdl",
	"models/props_wasteland/controlroom_filecabinet002a.mdl",
	"models/props_wasteland/controlroom_storagecloset001a.mdl",
	"models/props_wasteland/controlroom_storagecloset001b.mdl",
	--"models/props_wasteland/cranemagnet01a.mdl",
	"models/props_wasteland/dockplank01a.mdl",
	"models/props_wasteland/dockplank01b.mdl",
	--"models/props_wasteland/gaspump001a.mdl",
	"models/props_wasteland/interior_fence001g.mdl",
	"models/props_wasteland/interior_fence002d.mdl",
	"models/props_wasteland/interior_fence002e.mdl",
	"models/props_wasteland/interior_fence001a.mdl",
	"models/props_wasteland/interior_fence001b.mdl",
	"models/props_wasteland/interior_fence001c.mdl",
	"models/props_wasteland/interior_fence001d.mdl",
	"models/props_wasteland/interior_fence001e.mdl",
	"models/props_wasteland/interior_fence002a.mdl",
	"models/props_wasteland/interior_fence002b.mdl",
	"models/props_wasteland/interior_fence002c.mdl",
	"models/props_wasteland/interior_fence002f.mdl",
	"models/props_wasteland/kitchen_counter001b.mdl",
	"models/props_wasteland/kitchen_counter001d.mdl",
	"models/props_wasteland/kitchen_shelf002a.mdl",
	"models/props_wasteland/kitchen_shelf001a.mdl",
	"models/props_wasteland/kitchen_fridge001a.mdl",
	"models/props_wasteland/kitchen_counter001c.mdl",
	"models/props_wasteland/kitchen_counter001a.mdl",
	"models/props_wasteland/kitchen_stove002a.mdl",
	"models/props_wasteland/laundry_basket001.mdl",
	"models/props_wasteland/laundry_cart001.mdl",
	"models/props_wasteland/laundry_cart002.mdl",
	"models/props_wasteland/laundry_dryer001.mdl",
	"models/props_wasteland/laundry_dryer002.mdl",
	"models/props_wasteland/laundry_washer001a.mdl",
	"models/props_wasteland/laundry_washer003.mdl",
	--"models/props_wasteland/light_spotlight01_lamp.mdl",
	"models/props_wasteland/medbridge_post01.mdl",
	--"models/props_wasteland/panel_leverhandle001a.mdl",
	"models/props_wasteland/prison_bedframe001b.mdl",
	"models/props_wasteland/prison_celldoor001b.mdl",
	--"models/props_wasteland/prison_heater001a.mdl",
	--"models/props_wasteland/prison_lamp001c.mdl",
	"models/props_wasteland/prison_shelf002a.mdl",
	--"models/props_wasteland/wheel01.mdl",
	--"models/props_wasteland/wheel01a.mdl",
	"models/hunter/plates/plate1x1.mdl",
	"models/hunter/plates/plate1x2.mdl",
	"models/hunter/plates/plate1x4.mdl",
	"models/hunter/plates/plate2x2.mdl",
	"models/hunter/plates/plate2x3.mdl",
	"models/hunter/plates/plate3x3.mdl",
	"models/hunter/plates/plate3x4.mdl",
	"models/hunter/blocks/cube025x2x025.mdl",
	"models/hunter/blocks/cube025x4x025.mdl",
	"models/hunter/blocks/cube1x1x1.mdl",
	"models/hunter/tubes/tube2x2x1.mdl",
	"models/hunter/tubes/tube2x2x1b.mdl",
	"models/hunter/tubes/tube2x2x1c.mdl",
	"models/hunter/tubes/tube2x2x1d.mdl"
}

GM.SpawnLists["Storage"] = {
	"models/props_wasteland/kitchen_counter001b.mdl",
	"models/props_wasteland/kitchen_shelf001a.mdl",
	"models/props_wasteland/kitchen_counter001c.mdl",
	"models/props_junk/trashdumpster01a.mdl",
	"models/props_wasteland/controlroom_storagecloset001b.mdl",
	"models/props_wasteland/kitchen_counter001d.mdl",
	"models/props_wasteland/kitchen_shelf002a.mdl",
	"models/props_wasteland/laundry_cart001.mdl",
	"models/props_c17/lockers001a.mdl",
	"models/props_c17/display_cooler01a.mdl",
	"models/props_wasteland/kitchen_counter001a.mdl",
	"models/props_lab/filecabinet02.mdl",
	"models/props_wasteland/controlroom_filecabinet001a.mdl",
	"models/props_wasteland/controlroom_storagecloset001a.mdl",
	"models/props_wasteland/controlroom_filecabinet002a.mdl",
	"models/props_wasteland/laundry_cart002.mdl"
}

GM.SpawnLists["Misc - Small"] = {
	"models/props_borealis/mooring_cleat01.mdl",
	"models/props_trainstation/tracksign02.mdl",
	"models/props_junk/propanecanister001a.mdl",
	--"models/props_wasteland/panel_leverhandle001a.mdl",
	"models/props_docks/dock01_cleat01a.mdl",
	--"models/props_junk/meathook001a.mdl",
	"models/props_junk/trafficcone001a.mdl",
	"models/props_trainstation/trainstation_ornament002.mdl",
	"models/props_interiors/pot02a.mdl",
	"models/props_junk/metalbucket01a.mdl",
	"models/props_interiors/pot01a.mdl",
	"models/props_wasteland/prison_shelf002a.mdl",
	"models/props_junk/sawblade001a.mdl",
	"models/props_junk/popcan01a.mdl"
}

GM.SpawnLists["Misc - Medium"] = {
	--"models/props_wasteland/gaspump001a.mdl",
	"models/props_trainstation/tracksign01.mdl",
	"models/props_c17/trappropeller_blade.mdl",
	"models/props_junk/metalbucket02a.mdl",
	"models/props_lab/kennel_physics.mdl",
	"models/combine_helicopter/helicopter_bomb01.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_wasteland/barricade001a.mdl",
	"models/props_wasteland/barricade002a.mdl",
	"models/props_trainstation/mount_connection001a.mdl"
}

GM.SpawnLists["Misc - Large"] = {
	"models/props_trainstation/trainstation_ornament001.mdl",
	"models/props_trainstation/trainstation_arch001.mdl",
	"models/props_wasteland/buoy01.mdl",
	"models/props_junk/pushcart01a.mdl",
	"models/props_combine/headcrabcannister01a.mdl",
	"models/props_canal/canal_cap001.mdl",
	--"models/props_wasteland/cranemagnet01a.mdl",
	--"models/props_citizen_tech/windmill_blade004a.mdl"
}

GM.SpawnLists["Long"] = {
	"models/props_docks/dock02_pole02a.mdl",
	"models/props_trainstation/pole_448connection001a.mdl",
	"models/props_docks/dock02_pole02a_256.mdl",
	"models/props_trainstation/pole_448connection002b.mdl",
	"models/props_junk/ibeam01a.mdl",
	"models/props_trainstation/clock01.mdl",
	"models/props_docks/dock03_pole01a.mdl",
	"models/props_junk/ibeam01a_cluster01.mdl",
	"models/props_docks/dock01_pole01a_256.mdl",
	"models/props_docks/dock03_pole01a_256.mdl",
	"models/props_trainstation/trainstation_post001.mdl",
	"models/props_c17/signpole001.mdl",
	"models/props_c17/canister02a.mdl",
	"models/props_c17/metalladder002.mdl",
	"models/props_c17/canister01a.mdl",
	"models/props_c17/metalladder001.mdl",
	"models/props_trainstation/tracksign03.mdl",
	"models/props_docks/channelmarker_gib03.mdl",
	"models/props_docks/dock01_pole01a_128.mdl",
	"models/props_docks/channelmarker_gib02.mdl",
	"models/props_docks/channelmarker_gib04.mdl",
	"models/props_wasteland/dockplank01a.mdl",
	"models/props_wasteland/dockplank01b.mdl",
	"models/props_trainstation/trainstation_column001.mdl",
	--"models/props_junk/harpoon002a.mdl",
	"models/props_docks/channelmarker_gib01.mdl",
	"models/props_wasteland/medbridge_post01.mdl"
}

GM.SpawnLists["Furniture"] = {
	"models/props_wasteland/cafeteria_bench001a.mdl",
	"models/props_interiors/furniture_desk01a.mdl",
	"models/props_c17/bench01a.mdl",
	"models/props_wasteland/prison_bedframe001b.mdl",
	"models/props_interiors/furniture_couch01a.mdl",
	"models/props_combine/breenchair.mdl",
	"models/props_wasteland/cafeteria_table001a.mdl",
	"models/props_combine/breendesk.mdl",
	"models/props_trainstation/benchoutdoor01a.mdl",
	"models/props_wasteland/controlroom_desk001b.mdl",
	"models/props_wasteland/controlroom_desk001a.mdl",
	"models/props_c17/furniturecouch001a.mdl",
	"models/props_trainstation/bench_indoor001a.mdl",
	"models/props_c17/furniturechair001a.mdl",
	"models/props_interiors/furniture_chair03a.mdl",
	"models/props_c17/lampshade001a.mdl",
	"models/props_interiors/furniture_chair01a.mdl",
	"models/props_c17/chair02a.mdl",
	"models/props_wasteland/controlroom_chair001a.mdl",
	"models/props_c17/furniturebed001a.mdl",
	"models/props_c17/furnitureshelf002a.mdl",
	"models/props_interiors/furniture_couch02a.mdl",
	"models/props_interiors/furniture_lamp01a.mdl",
	"models/props_c17/furniturecouch002a.mdl",
	"models/props_c17/furnituredrawer001a.mdl",
	"models/props_c17/furnitureshelf001a.mdl",
	"models/props_c17/furnituremattress001a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"models/props_c17/furnituredrawer003a.mdl",
	"models/props_c17/furnituredrawer002a.mdl",
	"models/props_c17/furnituretable001a.mdl",
	"models/props_c17/furnituretable002a.mdl",
	"models/props_c17/furnituretable003a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_interiors/furniture_shelf01a.mdl",
	"models/props_interiors/furniture_vanity01a.mdl"
}

GM.SpawnLists["Flat"] = {
	"models/props_debris/metal_panel01a.mdl",
	"models/props_c17/door02_double.mdl",
	"models/props_doors/door03_slotted_left.mdl",
	"models/props_interiors/vendingmachinesoda01a_door.mdl",
	"models/props_debris/metal_panel02a.mdl",
	"models/props_trainstation/tracksign07.mdl",
	"models/props_trainstation/tracksign08.mdl",
	"models/props_trainstation/tracksign09.mdl",
	"models/props_trainstation/tracksign10.mdl",
	--"models/props_building_details/storefront_template001a_bars.mdl",
	"models/props_c17/door01_left.mdl",
	"models/props_borealis/borealis_door001a.mdl",
	"models/props_trainstation/trainstation_clock001.mdl",
	"models/props_lab/blastdoor001c.mdl",
	"models/props_lab/blastdoor001b.mdl",
	"models/props_lab/blastdoor001a.mdl",
	"models/props_junk/ravenholmsign.mdl",
	"models/props_c17/concrete_barrier001a.mdl",
	"models/props_trainstation/traincar_rack001.mdl",
	"models/props_junk/trashdumpster02b.mdl",
	"models/props_c17/furnitureshelf001b.mdl",
	"models/props_lab/lockerdoorleft.mdl"
}

GM.SpawnLists["Fences"] = {
	"models/props_wasteland/interior_fence002d.mdl",
	--"models/props_interiors/elevatorshaft_door01a.mdl",
	"models/props_c17/gate_door01a.mdl",
	"models/props_c17/fence04a.mdl",
	"models/props_c17/gate_door02a.mdl",
	"models/props_c17/fence01b.mdl",
	"models/props_wasteland/prison_celldoor001b.mdl",
	"models/props_wasteland/interior_fence001g.mdl",
	"models/props_wasteland/interior_fence002e.mdl",
	"models/props_wasteland/interior_fence001a.mdl",
	"models/props_wasteland/interior_fence001b.mdl",
	"models/props_wasteland/interior_fence001c.mdl",
	"models/props_wasteland/interior_fence001d.mdl",
	"models/props_wasteland/interior_fence001e.mdl",
	"models/props_wasteland/interior_fence002a.mdl",
	"models/props_wasteland/interior_fence002b.mdl",
	"models/props_wasteland/interior_fence002c.mdl",
	"models/props_wasteland/interior_fence002f.mdl",
	"models/props_c17/fence01a.mdl",
	"models/props_c17/fence02a.mdl",
	"models/props_c17/fence02b.mdl",
	"models/props_c17/fence03a.mdl"
}

GM.SpawnLists["Containers"] = {
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/trashbin01a.mdl",
	"models/props_c17/canister_propane01a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_trainstation/trashcan_indoor001a.mdl",
	"models/props_borealis/bluebarrel001.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/oildrum001.mdl",
	"models/props_junk/metalgascan.mdl",
	"models/props_trainstation/trashcan_indoor001b.mdl"
}

GM.SpawnLists["Appliances"] = {
	"models/props_wasteland/kitchen_fridge001a.mdl",
	"models/props_wasteland/laundry_dryer002.mdl",
	"models/props_wasteland/laundry_washer003.mdl",
	"models/props_interiors/refrigerator01a.mdl",
	"models/props_wasteland/laundry_washer001a.mdl",
	"models/props_wasteland/laundry_dryer001.mdl",
	"models/props_wasteland/kitchen_stove002a.mdl",
	"models/props_c17/furniturestove001a.mdl",
	"models/props_interiors/refrigeratordoor01a.mdl",
	"models/props_interiors/refrigeratordoor02a.mdl",
	--"models/props_c17/furnitureradiator001a.mdl",
	--"models/props_wasteland/prison_heater001a.mdl",
	"models/props_interiors/sinkkitchen01a.mdl",
	"models/props_c17/furniturebathtub001a.mdl",
	"models/props_c17/furniturefireplace001a.mdl",
	"models/props_interiors/bathtub01a.mdl",
	"models/props_c17/furniturefridge001a.mdl",
	"models/props_c17/furnitureboiler001a.mdl",
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_c17/furnituresink001a.mdl",
	"models/props_wasteland/laundry_basket001.mdl",
	--"models/props_interiors/radiator01a.mdl",
	"models/props_interiors/vendingmachinesoda01a.mdl"
}

GM.SpawnLists["PHX"] = {
	"models/hunter/plates/plate1x1.mdl",
	"models/hunter/plates/plate1x2.mdl",
	"models/hunter/plates/plate1x4.mdl",
	"models/hunter/plates/plate2x2.mdl",
	"models/hunter/plates/plate2x3.mdl",
	"models/hunter/plates/plate3x3.mdl",
	"models/hunter/plates/plate3x4.mdl",
	"models/hunter/blocks/cube025x2x025.mdl",
	"models/hunter/blocks/cube025x4x025.mdl",
	"models/hunter/blocks/cube1x1x1.mdl",
	"models/hunter/tubes/tube2x2x1.mdl",
	"models/hunter/tubes/tube2x2x1b.mdl",
	"models/hunter/tubes/tube2x2x1c.mdl",
	"models/hunter/tubes/tube2x2x1d.mdl"
}]]