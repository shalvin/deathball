if DeathballGameMode == nil then
	DeathballGameMode = class({})
end

-- Initialise
function DeathballGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	GameRules:SetTimeOfDay( 0.75 )
	--GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 10.0 )
	GameRules:SetPreGameTime( 5.0 )
	GameRules:SetPostGameTime( 60.0 )
	--GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetHeroMinimapIconSize( 400 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )

	-- Event Listeners
	ListenToGameEvent( 'npc_spawned', Dynamic_Wrap(DeathballGameMode, OnNPCSpawned), nil )

	-- Scoreboard
	self.nRadiantScore = 0
	self.nDireScore = 0



end

-- Evaluate the state of the game
function DeathballGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "Deathball script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function DeathballGameMode:OnNPCSpawned( keys )
	-- Set all hero's movement speed to 522. 
	--		TODO: change to read from keyvalue file
	local spawnedUnit = EntIndexToHScript( keys.entindex )
	
	if spawnedUnit:IsHero() then
		spawnedUnit:SetBaseMoveSpeed( 522 )
	end
end

function DeathballGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- if no keyvalues file

	-- Add properties to read & set in here like:
	-- 	self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
end

function DeathballGameMode:Goal( team )
	if team == 'good' then
		self.nRadiantScore = self.nRadiantScore + 1
	elseif team == 'bad' then
		self.nDireScore = self.nDireScore + 1
	end

	GameMode:SetTopBarTeamValue( DOTA_TEAM_BADGUYS, self.nDireScore )
	GameMode:SetTopBarTeamValue( DOTA_TEAM_GOODGUYS, self.nRadiantScore )
end
