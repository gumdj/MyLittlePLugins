#pragma semicolon 1
#pragma tabsize 0

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <l4d2lib>
#include <left4dhooks>
#include <colors>

public Plugin myinfo = 
{
	name 			= "gumdj",
	author 			= "gumdj",
	description 	= "none",
	version 		= "2022.10.14",
	url 			= "none"
}

new Handle:hCvarAutoAdjustInfected;
new Handle:hCvarAutoSpecialsCount;
new Handle:hCvarAddSpecialFromSurvivor;
new Handle:hCvarAutoSpecialsSpawnInterval;

ConVar g_hCvarInfSpawnDistanceMin;
ConVar g_hCvarL4dInfectedLimit;
ConVar g_hCvarVersusSpecialRespawnInterval;
ConVar g_hCvarZMegaMobSize;
ConVar g_hCvarZCommonLimit;

int oldInfSpawnDistanceMin;
int oldL4dInfectedLimit;
int oldVersusSpecialRespawnInterval;
// int oldZMegaMobSize;
// int oldZCommonLimit;

public OnAllPluginsLoaded() {

}

public OnPluginStart() {
	g_hCvarInfSpawnDistanceMin = FindConVar("inf_SpawnDistanceMin");
	g_hCvarL4dInfectedLimit = FindConVar("l4d_infected_limit");
	g_hCvarVersusSpecialRespawnInterval = FindConVar("versus_special_respawn_interval");
	g_hCvarZMegaMobSize = FindConVar("z_mega_mob_size");
	g_hCvarZCommonLimit = FindConVar("z_common_limit");
    HookEvent("player_spawn", event_playerSpawn);
	HookEvent("round_start", event_displaySpecialsInfo);
    hCvarAutoAdjustInfected = CreateConVar("auto_adjust_infected", "1");
	hCvarAutoSpecialsCount = CreateConVar("auto_specials_count", "3");
	hCvarAddSpecialFromSurvivor = CreateConVar("add_special_from_survivor", "1");
	hCvarAutoSpecialsSpawnInterval = CreateConVar("auto_specials_spawn_interval", "22");

}

public void event_playerSpawn(Event hEvent, const char[] sName, bool bDontBroadcast) {
	if (GetConVarInt(hCvarAutoAdjustInfected) == 1) {
		int client = GetClientOfUserId(hEvent.GetInt( "userid" ));
		if (!client || (IsClientConnected(client) && !IsClientInGame(client))) return;
		if (!IsFakeClient(client)) {
			CreateTimer(0.2, timer_delayCheckSpawn);
		}
	}
}

public Action timer_delayCheckSpawn(Handle hTimer, any UserID) {
	setMaxSpecialsCount(false);
	if (isChanged()) {
		displaySpecialsInfo();
	}
}

public void setMaxSpecialsCount(bool isClientPutInServer) {
	int realPlayer_count;
	int addSpecialFromSurvivor = GetConVarInt(hCvarAddSpecialFromSurvivor);	// 此处改每增加一个玩家可增加多少个特感;
	int specialsCount = GetConVarInt(hCvarAutoSpecialsCount);	// 此处改的内容为游戏中玩家数量小于等于2时特感的固定数量为多少
	int specialsSpawnInterval = GetConVarInt(hCvarAutoSpecialsSpawnInterval);
	int commonSize = 8;
	int commonLimitRange = 16;
    int spawnDistanceMin = 250;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsFakeClient(i))
			++realPlayer_count;
    // 控制特感刷新距离
    if (realPlayer_count <= 4) {
        // ServerCommand("sm_cvar inf_SpawnDistanceMin %i", spawnDistanceMin);
		setInfSpawnDistanceMin(spawnDistanceMin);
    } else if (realPlayer_count == 5) {
        spawnDistanceMin = 150;
        // ServerCommand("sm_cvar inf_SpawnDistanceMin %i", spawnDistanceMin);
		setInfSpawnDistanceMin(spawnDistanceMin);
    } else if (realPlayer_count == 6) {
        spawnDistanceMin = 50;
        // ServerCommand("sm_cvar inf_SpawnDistanceMin %i", spawnDistanceMin);
		setInfSpawnDistanceMin(spawnDistanceMin);
    } else {
        spawnDistanceMin = 0;
        // ServerCommand("sm_cvar inf_SpawnDistanceMin %i", spawnDistanceMin);
		setInfSpawnDistanceMin(spawnDistanceMin);
    }
    //
	if (realPlayer_count <= 2) {
		// ServerCommand("sm_cvar l4d_infected_limit %i", specialsCount);
		setL4dInfectedLimit(specialsCount);
		// ServerCommand("sm_cvar versus_special_respawn_interval %i", specialsSpawnInterval);
		setVersusSpecialRespawnInterval(specialsSpawnInterval);
		// ServerCommand("sm_cvar z_mega_mob_size %i", commonLimitRange);
		setZMegaMobSize(commonLimitRange);
		// ServerCommand("sm_cvar z_common_limit %i", commonSize);
		setZCommonLimit(commonSize);
	}
	else {
		specialsCount = addSpecialFromSurvivor * (realPlayer_count - 2) + specialsCount;
		commonLimitRange = 8 * (realPlayer_count - 2) + commonLimitRange;
		commonSize = 4 * (realPlayer_count - 2) + commonSize;
		if (realPlayer_count <= 4) {
			// ServerCommand("sm_cvar z_mega_mob_size %i", commonLimitRange);
			setZMegaMobSize(commonLimitRange);
			// ServerCommand("sm_cvar z_common_limit %i", commonSize);
			setZCommonLimit(commonSize);
            
		}
		if (realPlayer_count > 6) {
			// ServerCommand("sm_cvar versus_special_respawn_interval %i", specialsSpawnInterval - 2 * (realPlayer_count - 6));
			setVersusSpecialRespawnInterval(specialsSpawnInterval - 2 * (realPlayer_count - 6));
		}
		else {
			// ServerCommand("sm_cvar l4d_infected_limit %i", specialsCount);
			setL4dInfectedLimit(specialsCount);
			// ServerCommand("sm_cvar versus_special_respawn_interval %i", specialsSpawnInterval);
			setVersusSpecialRespawnInterval(specialsSpawnInterval);
		}
	}
}

public void event_displaySpecialsInfo(Event hEvent, const char[] sName, bool bDontBroadcast) {
	displaySpecialsInfo();
}

void displaySpecialsInfo() {
	PrintToChatAll(
		"\x03[\x04AutoInfectedControl\x03] \x03[\x04特感\x03]: \x01 %i \x03[\x04刷新时间\x03]: \x01 %i \x03[\x04刷新距离\x03]: \x01 %i"
		, g_hCvarL4dInfectedLimit.IntValue, g_hCvarVersusSpecialRespawnInterval.IntValue, g_hCvarInfSpawnDistanceMin.IntValue
	);
}

// setter
void setInfSpawnDistanceMin(int newDist) {
	oldInfSpawnDistanceMin = g_hCvarInfSpawnDistanceMin.IntValue;
	g_hCvarInfSpawnDistanceMin.IntValue = newDist;
}

void setL4dInfectedLimit(int newLimit) {
	oldL4dInfectedLimit = g_hCvarL4dInfectedLimit.IntValue;
	g_hCvarL4dInfectedLimit.IntValue = newLimit;
}

void setVersusSpecialRespawnInterval(int newInterval) {
	oldVersusSpecialRespawnInterval = g_hCvarVersusSpecialRespawnInterval.IntValue;
	g_hCvarVersusSpecialRespawnInterval.IntValue = newInterval;
}

void setZMegaMobSize(int newSize) {
	// oldZMegaMobSize = g_hCvarZMegaMobSize.IntValue;
	g_hCvarZMegaMobSize.IntValue = newSize;
}

void setZCommonLimit(int newLimit) {
	// oldZCommonLimit = g_hCvarZCommonLimit.IntValue;
	g_hCvarZCommonLimit.IntValue = newLimit;
}

bool isChanged() {
	if (oldInfSpawnDistanceMin == g_hCvarInfSpawnDistanceMin.IntValue
		&& oldL4dInfectedLimit == g_hCvarL4dInfectedLimit.IntValue
		&& oldVersusSpecialRespawnInterval == g_hCvarVersusSpecialRespawnInterval.IntValue) {
		return false;
	} 
	else {
		return true;
	}
}
