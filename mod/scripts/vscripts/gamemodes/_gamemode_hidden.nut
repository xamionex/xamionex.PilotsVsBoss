untyped
global function GamemodeHidden_Init


void function GamemodeHidden_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	SetRespawnsEnabled( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	//Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( BossInitPlayer )
	AddCallback_OnPlayerKilled( BossOnPlayerKilled )
	AddCallback_GameStateEnter( eGameState.Playing, SelectFirstBoss )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckSurvivors )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
}

void function BossInitPlayer( entity player )
{
	SetTeam( player, TEAM_MILITIA )
}

void function SelectFirstBoss()
{
	thread SelectFirstBossDelayed()
}

void function SelectAmpedPlayer()
{
	array<entity> milplayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
	if ( milplayers.len() < 1 )
		return
	entity ampd = milplayers[ RandomInt( milplayers.len() ) ]
	if (ampd != null || IsAlive(ampd))
		MakePlayerAmped( ampd )
	foreach ( entity otherPlayer in GetPlayerArray() )
		if ( ampd != otherPlayer )
			SendHudMessage( otherPlayer, "The Amped Is " + ampd.GetPlayerName(), -1, 0.2, 255, 255, 255, 0, 0.15, 8, 1 )
}

void function SelectFirstBossDelayed()
{
	wait 10.0 + RandomFloat( 5.0 )

	array<entity> players = GetPlayerArray()
	entity boss = players[ RandomInt( players.len() ) ]

	if (boss != null || IsAlive(boss))
		MakePlayerBoss( boss )

	foreach( entity otherPlayer in GetPlayerArray() )
		if ( boss != otherPlayer )
			Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnounceHidden", boss.GetEncodedEHandle() )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )
}

void function MakePlayerBoss(entity player)
{
	if (player == null)
		return;

	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnBoss( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouAreHidden" )
}

void function MakePlayerAmped(entity player)
{
	if (player == null)
		return;

	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnAmped( player )
	SendHudMessage( player, "You are the Amped", -1, 0.2, 255, 255, 255, 0, 0.15, 8, 1 )
}

void function RespawnBoss(entity player)
{
	player.Die()
	RespawnAsTitan( player, false )
	SetTeam( player, TEAM_IMC )
	player.SetMaxHealth(15000 * GetPlayerArray().len())
	player.SetHealth(15000 * GetPlayerArray().len())
	player.SetTitanDisembarkEnabled(false)
	thread SelectAmpedPlayer()
}

void function RespawnAmped(entity player)
{
	//if ( GetPlayerArray().len() > 8 )
	//	SetTeam( player, TEAM_IMC )
	//if ( GetPlayerArray().len() > 14 )
	//	player.Die()
	//	wait 2.0
	//	RespawnAsTitan( player, false )
	//	wait 1.0
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )
	player.GiveWeapon("mp_weapon_arena3")
	player.SetMaxHealth(500)
	player.SetHealth(500)
}

void function BossOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( attacker.IsPlayer() )
	{
		// increase kills by 1
		attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}
}

int function TimeoutCheckSurvivors()
{
	if ( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() > 0 )
		return TEAM_IMC

	return TEAM_MILITIA
}
