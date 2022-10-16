#pragma semicolon 1
// #pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <colors>

public Plugin myinfo = {
    name 			= "gumdj",
	author 			= "gumdj",
	description 	= "none",
	version 		= "2022.10.14",
	url 			= "none"
}

public OnPluginStart() {
    RegConsoleCmd("sm_team", changeTeam);
}

Action changeTeam(int client, int args) {
    int currTeam = GetClientTeam(client);
    if (currTeam == 1) {
        CPrintToChat(client, "{green}[TeamChange] {white}观察者 {olive}爬一边去");
        return Plugin_Continue;
    }
    if (IsPlayerAlive(client) && currTeam == 2) {
        CPrintToChat(client, "{green}[TeamChange]{olive}活着还想玩特感? 没有团队精神的东西!");
        return Plugin_Continue;
    }
    int realPlayerInSurvivor = 0;
    int realPlayer = 0;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            if (GetClientTeam(i) == 2) {
                realPlayerInSurvivor++;
            }
            realPlayer++;
        }
    }
    if (realPlayerInSurvivor - 1 < realPlayer - realPlayerInSurvivor + 1 && currTeam != 3) {
        CPrintToChat(client, "{green}[TeamChange]{olive}队伍不平衡，不能执行该操作");
        return Plugin_Continue;
    }
    int jgTeam = currTeam == 2 ? 3 : 2;
    if (jgTeam == 2) {
        ChangeClientTeam(client, jgTeam);
        CPrintToChat(client, "{green}[TeamChange]{olive}已加入{blue} 生还者 ");
        ForcePlayerSuicide(client);a
    } else {
        ChangeClientTeam(client, jgTeam);
        CPrintToChat(client, "{green}[TeamChange]{olive}已加入{red} 感染者 ");
    }
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2) {
            StripWeapons(i);
            KickClient(i);
        }
    }
    return Plugin_Continue;
}

void StripWeapons(int client)
{
	int itemIdx;
	for (int x = 0; x <= 4; x++)
	{
		if((itemIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{  
			RemovePlayerItem(client, itemIdx);
			RemoveEdict(itemIdx);
		}
	}
}
