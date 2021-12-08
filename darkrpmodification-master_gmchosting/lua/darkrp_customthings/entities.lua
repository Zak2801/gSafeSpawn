--[[---------------------------------------------------------------------------
DarkRP custom entities
-----------------------------------------------------------------------------]]


local function UnGhostEntity( ent, rad, oldCol )
	local id = ent:GetCreationID()
    if !IsValid(ent) then return end
	timer.Create( "zk_ghost_ent_safe_spawn_"..id, 0.5, 0, function()
		player_in_radius = false
		for k, v in pairs( ents.FindInSphere( ent:GetPos(), rad * 0.6 ) ) do
			if ( v:IsPlayer() ) then
				if ( ent.AITEAM == nil ) then
					player_in_radius = true
				else
					if ( ent:GetDriver() ~= v ) then
						player_in_radius = true
					end
				end
			end
		end

		if not player_in_radius then
			ent:SetCollisionGroup( oldCol )
			ent:SetTrigger(true)
            ent:SetMaterial("")
			timer.Remove( "zk_ghost_ent_safe_spawn_"..id )
		end
	end)
end

local function ZaktaksCustomSpawn( ply, trace, info_table, zmult )
	zmult = zmult or 0.2
    local customSpawnEntity = ents.Create( info_table.ent )
    customSpawnEntity:SetModel( info_table.model )

	local normalVector = trace.Normal
	normalVector[1] = normalVector[1] * 300
	normalVector[2] = normalVector[2] * 300
	local targetPos = ply:GetPos() + normalVector

	local boundsRadius = customSpawnEntity:BoundingRadius()
    customSpawnEntity:SetPos( targetPos + Vector( 0, 0, boundsRadius * zmult ) )

	local oldCollision = customSpawnEntity:GetCollisionGroup()

	customSpawnEntity:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
    customSpawnEntity:SetMaterial("models/props_combine/tprings_globe")
	customSpawnEntity:SetTrigger(false)
    
	UnGhostEntity( customSpawnEntity, boundsRadius, oldCollision )

    customSpawnEntity:Spawn()


    undo.Create( info_table.name )
    undo.AddEntity( customSpawnEntity )
    undo.SetPlayer( ply )
    undo.Finish()

    return customSpawnEntity
end


--[[ Example of usage:
DarkRP.createEntity("AT-RT", {
    ent = "lunasflightschool_niksacokica_at-rt",
    model = "models/kingpommes/starwars/atrt/main.mdl",
    price = 0,
    max = 1,
    cmd = "buyatrt",
    category = "Vehicles",
    allowed = {TEAM_501NCO, TEAM_501COM, TEAM_501EXO, TEAM_501CMDR},
    spawn = function( ply, tr, tbl ) ZaktaksCustomSpawn( ply, tr, tbl ) end,
})
--]]