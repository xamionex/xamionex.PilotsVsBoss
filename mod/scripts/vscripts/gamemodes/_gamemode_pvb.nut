untyped
global function GamemodePVB_Init

void function GamemodePVB_Init()
{
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
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

void function SelectFirstBossDelayed()
{
	wait 5.0 + RandomFloat( 5.0 )

	array<entity> players = GetPlayerArray()
	entity boss = players[ RandomInt( players.len() ) ]

	if (boss != null || IsAlive(boss))
		MakePlayerBoss( boss )

	foreach ( entity otherPlayer in GetPlayerArray() )
			if ( boss != otherPlayer )
				Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnounceBoss", boss.GetEncodedEHandle() )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )
}

void function MakePlayerBoss(entity player)
{
	if (player == null)
		return;

	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	RespawnBoss( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouAreBoss" )
}

void function RespawnBoss(entity player)
{
	player.Die()
	wait 2.0
	RespawnAsTitan( player, false )
	wait 1.0
	SetTeam( player, TEAM_IMC )
	player.SetMaxHealth(25000 * GetPlayerArray().len())
	player.SetHealth(25000 * GetPlayerArray().len())
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