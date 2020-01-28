#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <store>

#define PLUGIN_NEV	"Scoreboard Custom Levels"
#define PLUGIN_LERIAS	"(9_9)"
#define PLUGIN_AUTHOR	"Nexd"
#define PLUGIN_VERSION	"1.1"
#define PLUGIN_URL	"https://github.com/KillStr3aK"
#pragma tabsize 0

enum LevelIcon
{
	IconIndex,
	iSlot
}

int g_eLevelIcons[STORE_MAX_ITEMS][LevelIcon];
int g_iLevelIcons = 0;

int m_iOffset = -1;
int m_iLevel[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = PLUGIN_NEV,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_LERIAS,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("ScoreboardCustomLevels");
	CreateNative("SCL_GetLevel", Native_GetLevel);
	
	return APLRes_Success;
}

public Native_GetLevel(Handle plugin, int params)
{
	return m_iLevel[GetNativeCell(1)];
}

public void OnPluginStart()
{
	Store_RegisterHandler("LevelIcon", "iconindex", LevelIconMapStart, LevelIconReset, LevelIconConfig, LevelIconEquip, LevelIconUnEquip, true);
	m_iOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
}

public void OnClientPostAdminCheck(int client)
{
	m_iLevel[client] = -1;
}

public void LevelIconMapStart() 
{
	char sBuffer[PLATFORM_MAX_PATH];

    for(int i = 0; i < g_iLevelIcons; ++i)
	{
		FormatEx(sBuffer, sizeof(sBuffer), "materials/panorama/images/icons/xp/level%i.png", g_eLevelIcons[i][IconIndex]);
    	AddFileToDownloadsTable(sBuffer);
	}
}

public void LevelIconReset() 
{ 
	g_iLevelIcons = 0;
}

public int LevelIconConfig(Handle &kv, int itemid)
{
	Store_SetDataIndex(itemid, g_iLevelIcons);
	g_eLevelIcons[g_iLevelIcons][IconIndex] = KvGetNum(kv, "iconindex");
	g_eLevelIcons[g_iLevelIcons][iSlot] = KvGetNum(kv, "slot");

	g_iLevelIcons++;
	return true;
}

public int LevelIconEquip(int client, int id)
{
	m_iLevel[client] = g_eLevelIcons[Store_GetDataIndex(id)][IconIndex];
	return g_eLevelIcons[Store_GetDataIndex(id)][iSlot];
}

public int LevelIconUnEquip(int client, int id)
{
	m_iLevel[client] = -1;
	return g_eLevelIcons[Store_GetDataIndex(id)][iSlot];
}

public void OnMapStart()
{
	SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}

public void OnThinkPost(int m_iEntity)
{
	int m_iLevelTemp[MAXPLAYERS+1] = 0;
	GetEntDataArray(m_iEntity, m_iOffset, m_iLevelTemp, MAXPLAYERS+1);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(m_iLevel[i] > 40)
		{
			if(m_iLevel[i] != m_iLevelTemp[i]) SetEntData(m_iEntity, m_iOffset + (i * 4), m_iLevel[i]);
		}
	}
}