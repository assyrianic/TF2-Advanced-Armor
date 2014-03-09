#include <sourcemod>  
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <updater>
#include <morecolors>

#define PLUGIN_VERSION "1.7.4"
#define UPDATE_URL "https://bitbucket.org/assyrian/tf2-advanced-armor-plugin/raw/default/updater.txt"

new armor[MAXPLAYERS+1];
new MaxArmor[MAXPLAYERS+1];
new ArmorType[MAXPLAYERS+1];
new Float:ArmorHUDParams[MAXPLAYERS+1][2];
new ArmorHUDColor[MAXPLAYERS+1][3];
new ArmorRegenerate[MAXPLAYERS+1];
new Float:DamageResistance[MAXPLAYERS+1];
new bool:ArmorOverheal[MAXPLAYERS+1] = false;

new Handle:hHudText;

new Handle:plugin_enable = INVALID_HANDLE;
new Handle:armor_ammo_allow = INVALID_HANDLE;
new Handle:armor_from_engie = INVALID_HANDLE;
new Handle:allow_self_hurt = INVALID_HANDLE;
new Handle:allow_uber_damage = INVALID_HANDLE;
new Handle:allow_crit_pierce = INVALID_HANDLE;
new Handle:armorregen = INVALID_HANDLE;
new Handle:show_hud_armor = INVALID_HANDLE;

new Handle:armor_from_spencer = INVALID_HANDLE;
new Handle:spencer_time = INVALID_HANDLE;
new Handle:allow_hud_change = INVALID_HANDLE;
new Handle:allow_hud_color = INVALID_HANDLE;

new Handle:maxarmor_scout = INVALID_HANDLE;
new Handle:maxarmor_soldier = INVALID_HANDLE;
new Handle:maxarmor_pyro = INVALID_HANDLE;
new Handle:maxarmor_demo = INVALID_HANDLE;
new Handle:maxarmor_heavy = INVALID_HANDLE;
new Handle:maxarmor_engie = INVALID_HANDLE;
new Handle:maxarmor_med = INVALID_HANDLE;
new Handle:maxarmor_sniper = INVALID_HANDLE;
new Handle:maxarmor_spy = INVALID_HANDLE;

new Handle:armor_from_metal = INVALID_HANDLE;
new Handle:armor_from_metal_mult = INVALID_HANDLE;
new Handle:spencer_to_armor = INVALID_HANDLE;
new Handle:armor_from_smallammo = INVALID_HANDLE;
new Handle:armor_from_medammo = INVALID_HANDLE;
new Handle:armor_from_fullammo = INVALID_HANDLE;
//new Handle:armor_from_widowmaker = INVALID_HANDLE;

new Handle:damage_resistance_type1 = INVALID_HANDLE;
new Handle:damage_resistance_type2 = INVALID_HANDLE;
new Handle:damage_resistance_type3 = INVALID_HANDLE;
new Handle:damage_resistance_custom = INVALID_HANDLE;

new Handle:armortype_scout = INVALID_HANDLE;
new Handle:armortype_soldier = INVALID_HANDLE;
new Handle:armortype_pyro = INVALID_HANDLE;
new Handle:armortype_demo = INVALID_HANDLE;
new Handle:armortype_heavy = INVALID_HANDLE;
new Handle:armortype_engie = INVALID_HANDLE;
new Handle:armortype_med = INVALID_HANDLE;
new Handle:armortype_sniper = INVALID_HANDLE;
new Handle:armortype_spy = INVALID_HANDLE;

new Handle:armorregen_scout = INVALID_HANDLE;
new Handle:armorregen_soldier = INVALID_HANDLE;
new Handle:armorregen_pyro = INVALID_HANDLE;
new Handle:armorregen_demo = INVALID_HANDLE;
new Handle:armorregen_heavy = INVALID_HANDLE;
new Handle:armorregen_engie = INVALID_HANDLE;
new Handle:armorregen_med = INVALID_HANDLE;
new Handle:armorregen_sniper = INVALID_HANDLE;
new Handle:armorregen_spy = INVALID_HANDLE;

//need moar handles lulz

new Handle:clienttimer[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:clientarmorregen[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:lazycoding[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:armorspawn = INVALID_HANDLE;
new Handle:setarmormax = INVALID_HANDLE;

new Handle:cvBlu = INVALID_HANDLE;
new Handle:cvRed = INVALID_HANDLE;

new Handle:HUDCookie;
new Handle:HUDParamsCookieX;
new Handle:HUDParamsCookieY;

new Handle:RedCookie;
new Handle:GreenCookie;
new Handle:BlueCookie;

new Handle:timer_bitch_convar = INVALID_HANDLE;

new bool:g_bAutoUpdate;

//new Handle:g_hSdkEquipWearable; // handles viewmodels and world models; props to Friagram
//new bool:g_bEwSdkStarted;

//new g_shield[MAXPLAYERS+1];
//new g_shieldref[MAXPLAYERS+1];

//#define SOUND_REGENERATE	"items/spawn_item.wav"

#define ARMOR_NONE	(1 << 0)
#define ARMOR_HAS	(1 << 1)
#define ARMOR_RED	(1 << 2)
#define ARMOR_YELLOW	(1 << 3)
#define ARMOR_GREEN	(1 << 4)

public Plugin:myinfo =
{
	name = "[TF2] Advanced Armor",
	author = "Assyrian/Nergal",
	description = "a plugin that gives armor for TF2",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"  
};

public OnPluginStart()
{
	new Handle:conVar = CreateConVar("sm_adarmor_autoupdate", "1", "Is auto-update enabled?");
	g_bAutoUpdate = GetConVarBool(conVar);
	HookConVarChange(conVar, OnAutoUpdateChange);

	hHudText = CreateHudSynchronizer();

	RegAdminCmd("sm_setarmor", Command_SetPlayerArmor, ADMFLAG_KICK);
	RegConsoleCmd("sm_armorhud", Command_SetPlayerHUD, "Let's a player set his/her Armor hud style");
	RegConsoleCmd("sm_armorhudparams", Command_SetHudParams, "Let's a player set his/her Armor hud params");
	RegConsoleCmd("sm_armorhelp", ArmorHelp, "help menu for players");
	RegConsoleCmd("sm_armorhudcolor", Command_SetHudColor, "let's players change their armor hud color");

	HUDCookie = RegClientCookie("adarmor_hudstyle", "player's selected hud style", CookieAccess_Public);
	HUDParamsCookieX = RegClientCookie("adarmor_hudparamsx", "player's selected hud params x coordinate", CookieAccess_Public);
	HUDParamsCookieY = RegClientCookie("adarmor_hudparamsy", "player's selected hud params y coordinate", CookieAccess_Public);
	RedCookie = RegClientCookie("adarmor_hudred", "player's selected hud params red", CookieAccess_Public);
	GreenCookie = RegClientCookie("adarmor_hudgreen", "player's selected hud params green", CookieAccess_Public);
	BlueCookie = RegClientCookie("adarmor_hudblue", "player's selected hud params blue", CookieAccess_Public);

	plugin_enable = CreateConVar("sm_adarmor_enabled", "1", "Enable Advanced Armor plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	armor_ammo_allow = CreateConVar("sm_adarmor_fromammo", "1", "Enable getting armor from ammo", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	armor_from_engie = CreateConVar("sm_adarmor_armor_from_engie", "1", "Enable getting armor from engineer's metal", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	show_hud_armor = CreateConVar("sm_adarmor_show_hud_armor", "1", "Enable HUD", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	allow_self_hurt = CreateConVar("sm_adarmor_allow_self_hurt", "1", "Let's players destroy their own armor by damaging themselves", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	allow_uber_damage = CreateConVar("sm_adarmor_allow_uber_dmg", "0", "allows players to destroy ubered or bonked player's armor while invulnerable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	allow_crit_pierce = CreateConVar("sm_adarmor_allow_crit_dmg", "0", "allows crit damage to ignore armor", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	allow_hud_change = CreateConVar("sm_adarmor_allow_hud_change", "1", "Let's players change their HUD parameters with sm_armorhudparams", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	allow_hud_color = CreateConVar("sm_adarmor_allow_hud_color", "1", "Let's players change their HUD color with sm_armorhudcolor", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	armorspawn = CreateConVar("sm_adarmor_armoronspawn", "1", "Enable players to spawn with armor, 1 = full armor, 2 = half, 0 = none", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armorregen = CreateConVar("sm_adarmor_armorregen", "0", "Enables armor regen", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	armor_from_spencer = CreateConVar("sm_adarmor_armor_from_spencer", "1", "Enables armor from dispensers", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	cvBlu = CreateConVar("sm_adarmor_blue", "1", "Enables armor for BLU team", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvRed = CreateConVar("sm_adarmor_red", "1", "Enables armor for RED team", FCVAR_PLUGIN, true, 0.0, true, 1.0);

        CreateConVar("sm_adarmor_version", PLUGIN_VERSION, "Advanced Armor version", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);

	maxarmor_scout = CreateConVar("sm_adarmor_scout_maxarmor", "50", "sets how much max armor scout will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_soldier = CreateConVar("sm_adarmor_soldier_maxarmor", "200", "sets how much max armor soldier will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_pyro = CreateConVar("sm_adarmor_pyro_maxarmor", "150", "sets how much max armor pyro will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_demo = CreateConVar("sm_adarmor_demoman_maxarmor", "120", "sets how much max armor demoman will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_heavy = CreateConVar("sm_adarmor_heavy_maxarmor", "300", "sets how much max armor heavy will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_engie = CreateConVar("sm_adarmor_engineer_maxarmor", "60", "sets how much max armor engineer will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_med = CreateConVar("sm_adarmor_medic_maxarmor", "100", "sets how much max armor medic will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_sniper = CreateConVar("sm_adarmor_sniper_maxarmor", "50", "sets how much max armor sniper will have", FCVAR_PLUGIN|FCVAR_NOTIFY);
	maxarmor_spy = CreateConVar("sm_adarmor_spy_maxarmor", "100", "sets how much max armor spy will have", FCVAR_PLUGIN|FCVAR_NOTIFY);



	armorregen_scout = CreateConVar("sm_adarmor_scout_armoregen", "6", "armor regen per second for scout", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_soldier = CreateConVar("sm_adarmor_soldier_armoregen", "8", "armor regen per second for soldier", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_pyro = CreateConVar("sm_adarmor_pyro_armoregen", "8", "armor regen per second for pyro", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_demo = CreateConVar("sm_adarmor_demoman_armoregen", "7", "armor regen per second for demoman", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_heavy = CreateConVar("sm_adarmor_heavy_armoregen", "10", "armor regen per second for heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_engie = CreateConVar("sm_adarmor_engineer_armoregen", "6", "armor regen per second for engineer", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_med = CreateConVar("sm_adarmor_medic_armoregen", "7", "armor regen per second for medic", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_sniper = CreateConVar("sm_adarmor_sniper_armoregen", "6", "armor regen per second for sniper", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armorregen_spy = CreateConVar("sm_adarmor_spy_armoregen", "7", "armor regen per second for spy", FCVAR_PLUGIN|FCVAR_NOTIFY);


	armor_from_metal = CreateConVar("sm_adarmor_metaltoarmor", "10", "converts metal, from engineer, to armor for teammates", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armor_from_metal_mult = CreateConVar("sm_adarmor_metaltoarmor_mult", "5", "multiplies with sm_metaltoarmor to reduce metal cost to repair teammates armor, use in conjuction with sm_metaltoarmor", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armor_from_smallammo = CreateConVar("sm_adarmor_smallammoarmor", "0.25", "give armor from small ammo packs by multiplying it with the players max armor they can get", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armor_from_medammo = CreateConVar("sm_adarmor_medammoarmor", "0.50", "give armor from med ammo packs by multiplying it with the players max armor they can get", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armor_from_fullammo = CreateConVar("sm_adarmor_fullammoarmor", "1.0", "give armor from full ammo packs by multiplying it with the players max armor they can get", FCVAR_PLUGIN|FCVAR_NOTIFY);

	spencer_to_armor = CreateConVar("sm_adarmor_dispenser_to_armor", "1", "gives x amount of armor from dispensers", FCVAR_PLUGIN|FCVAR_NOTIFY);

	spencer_time = CreateConVar("sm_adarmor_dispenser_time", "0.2", "amount of rate/time dispensers will give armor", FCVAR_PLUGIN|FCVAR_NOTIFY);

	//armor_from_widowmaker = CreateConVar("sm_armor_from_widowmaker", "1", "converts widowmaker dmg to armor", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	setarmormax = CreateConVar("sm_adarmor_setarmor_max", "999", "highest armor that admins can give armor to players", FCVAR_PLUGIN|FCVAR_NOTIFY);

	damage_resistance_type1 = CreateConVar("sm_adarmor_damage_resistance_light", "0.3", "how much damage should Light Armor absorb", FCVAR_PLUGIN|FCVAR_NOTIFY);
	damage_resistance_type2 = CreateConVar("sm_adarmor_damage_resistance_med", "0.6", "how much damage should Medium Armor absorb", FCVAR_PLUGIN|FCVAR_NOTIFY);
	damage_resistance_type3 = CreateConVar("sm_adarmor_damage_resistance_heavy", "0.8", "how much damage should Heavy Armor absorb", FCVAR_PLUGIN|FCVAR_NOTIFY);
	damage_resistance_custom = CreateConVar("sm_adarmor_damage_resistance_custom", "0", "how much damage should Custom Armor absorb", FCVAR_PLUGIN|FCVAR_NOTIFY);

	armortype_scout = CreateConVar("sm_adarmor_armortype_scout", "1", "what armor type scout should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_soldier = CreateConVar("sm_adarmor_armortype_soldier", "3", "what armor type soldier should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_pyro = CreateConVar("sm_adarmor_armortype_pyro", "2", "what armor type pyro should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_demo = CreateConVar("sm_adarmor_armortype_demo", "2", "what armor type demoman should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_heavy = CreateConVar("sm_adarmor_armortype_heavy", "3", "what armor type heavy should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_engie = CreateConVar("sm_adarmor_armortype_engie", "2", "what armor type engineer should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_med = CreateConVar("sm_adarmor_armortype_med", "2", "what armor type medic should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_sniper = CreateConVar("sm_adarmor_armortype_sniper", "1", "what armor type sniper should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);
	armortype_spy = CreateConVar("sm_adarmor_armortype_spy", "2", "what armor type spy should get, 1 = light armor, 2 = medium, 3 = heavy", FCVAR_PLUGIN|FCVAR_NOTIFY);

	timer_bitch_convar = CreateConVar("sm_adarmor_advert_bitch", "60.0", "how many times the advert will bitch at players per second", FCVAR_PLUGIN|FCVAR_NOTIFY);

	//g_bEwSdkStarted = TF2_EwSdkStartup();

	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
        HookEvent("player_changeclass", event_changeclass);
	HookEvent("player_spawn", event_player_spawn);
	//HookEvent("player_healed", event_player_healed);
	HookEntityOutput("item_ammopack_full", "OnPlayerTouch", EntityOutput_OnPlayerTouch);
	HookEntityOutput("item_ammopack_medium", "OnPlayerTouch", EntityOutput_OnPlayerTouch);
	HookEntityOutput("item_ammopack_small", "OnPlayerTouch", EntityOutput_OnPlayerTouch);
	AutoExecConfig(true, "Advanced_Armor");

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsValidClient(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(i, SDKHook_TraceAttack, TraceAttack);
		}
	}
}
public OnConfigsExecuted()
{
	CreateTimer(GetConVarFloat(timer_bitch_convar), Timer_Announce, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public OnClientDisconnect(client)
{
	MaxArmor[client] = 0;
	ArmorType[client] = 0;
	ClearTimer(clienttimer[client]);
	ClearTimer(clientarmorregen[client]);
	ClearTimer(lazycoding[client]);
}
public OnClientPutInServer(client)
{
	if (IsValidClient(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_TraceAttack, TraceAttack);
		if (clienttimer[client] == INVALID_HANDLE)
			clienttimer[client] = CreateTimer(0.2, DrawHud, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		if (clientarmorregen[client] == INVALID_HANDLE)
			clientarmorregen[client] = CreateTimer(1.0, ArmorRegen, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		if (lazycoding[client] == INVALID_HANDLE)
			lazycoding[client] = CreateTimer(GetConVarFloat(spencer_time), DispenserCheck, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (GetConVarBool(plugin_enable))
		{
			if (GetHUDColorR(client) <= 0 && GetHUDColorG(client) <= 0 && GetHUDColorB(client) <= 0)
			{
				SetHUDColorR(client, 255);
				SetHUDColorG(client, 30);
				SetHUDColorB(client, 90);
			}
			armor[client] = 0;
		}
	}
}
GetHUDSetting(client)
{
	if (!IsValidClient(client)) return 0;
	if (IsFakeClient(client)) return 0;
	if (!AreClientCookiesCached(client)) return 0;
	decl String:hudpick[32];
	GetClientCookie(client, HUDCookie, hudpick, sizeof(hudpick));
	return StringToInt(hudpick);
}
SetHUDSetting(client, option)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:hudpick[32];
	IntToString(option, hudpick, sizeof(hudpick));
	SetClientCookie(client, HUDCookie, hudpick);
}
Float:GetHUDXParams(client)
{
	if (!IsValidClient(client)) return 0.0;
	if (IsFakeClient(client)) return 0.0;
	if (!AreClientCookiesCached(client)) return 0.0;
	decl String:hudparamsx[32];
	decl Float:hudx;
	GetClientCookie(client, HUDParamsCookieX, hudparamsx, sizeof(hudparamsx));
	StringToFloatEx(hudparamsx, hudx);
	return hudx;
}
Float:GetHUDYParams(client)
{
	if (!IsValidClient(client)) return 0.0;
	if (IsFakeClient(client)) return 0.0;
	if (!AreClientCookiesCached(client)) return 0.0;
	decl String:hudparamsy[32];
	decl Float:hudy;
	GetClientCookie(client, HUDParamsCookieY, hudparamsy, sizeof(hudparamsy));
	StringToFloatEx(hudparamsy, hudy);
	return hudy;
}
SetHUDXParams(client, Float:x)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:stringx[32];
	FloatToString(x, stringx, sizeof(stringx));
	SetClientCookie(client, HUDParamsCookieX, stringx);
}
SetHUDYParams(client, Float:y)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:stringy[32];
	FloatToString(y, stringy, sizeof(stringy));
	SetClientCookie(client, HUDParamsCookieY, stringy);
}
GetHUDColorR(client)
{
	if (!IsValidClient(client)) return 0;
	if (IsFakeClient(client)) return 0;
	if (!AreClientCookiesCached(client)) return 0;
	decl String:getred[32];
	GetClientCookie(client, RedCookie, getred, sizeof(getred));
	return StringToInt(getred);
}
GetHUDColorG(client)
{
	if (!IsValidClient(client)) return 0;
	if (IsFakeClient(client)) return 0;
	if (!AreClientCookiesCached(client)) return 0;
	decl String:getgreen[32];
	GetClientCookie(client, GreenCookie, getgreen, sizeof(getgreen));
	return StringToInt(getgreen);
}
GetHUDColorB(client)
{
	if (!IsValidClient(client)) return 0;
	if (IsFakeClient(client)) return 0;
	if (!AreClientCookiesCached(client)) return 0;
	decl String:getblu[32];
	GetClientCookie(client, BlueCookie, getblu, sizeof(getblu));
	return StringToInt(getblu);
}
SetHUDColorR(client, r)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:redhue[32];
	IntToString(r, redhue, sizeof(redhue));
	SetClientCookie(client, RedCookie, redhue);
}
SetHUDColorG(client, g)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:greenhue[32];
	IntToString(g, greenhue, sizeof(greenhue));
	SetClientCookie(client, GreenCookie, greenhue);
}
SetHUDColorB(client, b)
{
	if (!IsValidClient(client)) return;
	if (IsFakeClient(client)) return;
	if (!AreClientCookiesCached(client)) return;
	decl String:bluhue[32];
	IntToString(b, bluhue, sizeof(bluhue));
	SetClientCookie(client, BlueCookie, bluhue);
}
public Action:event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client, false))
		return Plugin_Continue;

	if (GetConVarBool(plugin_enable))
	{
		if (!GetConVarBool(cvBlu) && GetClientTeam(client) == 3)
			return Plugin_Continue;

		if (!GetConVarBool(cvRed) && GetClientTeam(client) == 2)
			return Plugin_Continue;

		armor[client] = 0;
		GetArmorClass(client);

		new spawn = GetConVarInt(armorspawn);

		if (spawn == 1 && !IsFakeClient(client))
			armor[client] = MaxArmor[client];

		if (spawn == 2 && !IsFakeClient(client))
			armor[client] = MaxArmor[client]/2;
	}
	return Plugin_Continue;
}
/*public Action:event_player_healed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "patient"));
	if (!IsValidClient(client, false))
		return Plugin_Continue;

	if (GetConVarBool(plugin_enable) && GetConVarBool(armor_from_spencer))
	{
		if (!GetConVarBool(cvBlu) && GetClientTeam(client) == 3)
			return Plugin_Continue;

		if (!GetConVarBool(cvRed) && GetClientTeam(client) == 2)
			return Plugin_Continue;

		decl String:clsname[32];
		new spencerrepair = GetConVarInt(spencer_to_armor);
		new dispenser = -1;
		while ((dispenser = FindEntityByClassname2(dispenser, "obj_dispenser")) != -1)
		{
			if (IsValidEntity(dispenser)) GetEdictClassname(dispenser, clsname, sizeof(clsname));
			if (IsValidClient(client) && TF2_IsPlayerInCondition(client, TFCond_Healing) && strcmp(clsname, "obj_dispenser", false) == 0)
			{
				GetArmorClass(client);
				if (MaxArmor[client] - armor[client] < spencerrepair)
					spencerrepair = MaxArmor[client] - armor[client];

				if (armor[client] < MaxArmor[client])
					armor[client] += spencerrepair;

				if (armor[client] > MaxArmor[client] && ArmorOverheal[client] == false)
					armor[client] = MaxArmor[client];
			}
		}
	}
	return Plugin_Continue;
}*/
public Action:event_changeclass(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetConVarBool(plugin_enable))
	{
		armor[client] = 0;
		ArmorOverheal[client] = false;
	}
	return Plugin_Continue;
}
public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(plugin_enable))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new deathflags = GetEventInt(event, "death_flags");
		if (IsValidClient(client) && IsClientInGame(client) && !IsFakeClient(client) && !(deathflags & TF_DEATHFLAG_DEADRINGER))
		{
			ArmorOverheal[client] = false;
			armor[client] = 0;
			MaxArmor[client] = 0;
			ArmorType[client] = 0;
		}
	}
	return Plugin_Continue;
}
public Action:DrawHud(Handle:timer, any:client)
{
	new setting = GetHUDSetting(client);
	if (IsValidClient(client) && IsClientInGame(client) && !IsFakeClient(client) && GetConVarBool(plugin_enable))
	{
		if (!GetConVarBool(cvBlu) && GetClientTeam(client) == 3)
			return Plugin_Handled;

		if (!GetConVarBool(cvRed) && GetClientTeam(client) == 2)
			return Plugin_Handled;

		if (GetConVarBool(show_hud_armor))
		{
			ArmorHUDParams[client][0] = GetHUDXParams(client);
			ArmorHUDParams[client][1] = GetHUDYParams(client);
			ArmorHUDColor[client][0] = GetHUDColorR(client);
			ArmorHUDColor[client][1] = GetHUDColorG(client);
			ArmorHUDColor[client][2] = GetHUDColorB(client);

			if (!IsClientObserver(client))
			{
				if (setting == 1 || setting == 0) //Generic style
				{
					SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
					ShowSyncHudText(client, hHudText, "Armor: %i/Max Armor: %i", armor[client], MaxArmor[client]);
				}

				if (setting == 2) //DOOM Style
				{
					SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
					ShowSyncHudText(client, hHudText, "Armor: %i/%i", armor[client], MaxArmor[client]);
				}

				if (setting == 3) //TFC/Quake Style
				{
					SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
					ShowSyncHudText(client, hHudText, "Armor: %i", armor[client]);
				}
			}
			if (IsClientObserver(client) || !IsPlayerAlive(client))
			{
				new spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
				if (IsValidClient(spec) && IsPlayerAlive(spec) && spec != client)
				{
					if (setting == 1 || setting == 0) //Generic style
					{
						SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
						ShowSyncHudText(client, hHudText, "Armor: %i/Max Armor: %i", armor[spec], MaxArmor[spec]);
					}

					if (setting == 2) //DOOM Style
					{
						SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
						ShowSyncHudText(client, hHudText, "Armor: %i/%i", armor[spec], MaxArmor[spec]);
					}

					if (setting == 3) //TFC/Quake Style
					{
						SetHudTextParams(ArmorHUDParams[client][0], ArmorHUDParams[client][1], 1.0, ArmorHUDColor[client][0], ArmorHUDColor[client][1], ArmorHUDColor[client][2], 255);
						ShowSyncHudText(client, hHudText, "Armor: %i", armor[spec]);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action:ArmorRegen(Handle:timer, any:client) 
{
	if (IsValidClient(client) && IsClientInGame(client) && !IsFakeClient(client) && GetConVarBool(plugin_enable) && GetConVarBool(armorregen) && IsPlayerAlive(client) && !IsClientObserver(client))
	{
		if (!GetConVarBool(cvBlu) && GetClientTeam(client) == 3)
			return Plugin_Handled;

		if (!GetConVarBool(cvRed) && GetClientTeam(client) == 2)
			return Plugin_Handled;

		GetArmorClass(client);
		if (MaxArmor[client] - armor[client] < ArmorRegenerate[client])
			ArmorRegenerate[client] = MaxArmor[client] - armor[client];

		if (armor[client] < MaxArmor[client])
			armor[client] += ArmorRegenerate[client];

		if (armor[client] > MaxArmor[client] && ArmorOverheal[client] == false)
			armor[client] = MaxArmor[client];
	}
	return Plugin_Continue;
}
public Action:DispenserCheck(Handle:timer, any:client)
{
	if (GetConVarBool(plugin_enable) && GetConVarBool(armor_from_spencer))
	{
		if (!GetConVarBool(cvBlu) && GetClientTeam(client) == 3)
			return Plugin_Handled;

		if (!GetConVarBool(cvRed) && GetClientTeam(client) == 2)
			return Plugin_Handled;

		decl String:clsname[32];
		new spencerrepair = GetConVarInt(spencer_to_armor);
		new dispenser = -1;
		while ((dispenser = FindEntityByClassname2(dispenser, "obj_dispenser")) != -1)
		{
			if (IsValidEntity(dispenser)) GetEdictClassname(dispenser, clsname, sizeof(clsname));
			if (IsValidEntity(client) && TF2_IsPlayerInCondition(client, TFCond_Healing) && strcmp(clsname, "obj_dispenser", false) == 0 && !IsInHeal(client))
			{
				GetArmorClass(client);
				if (MaxArmor[client] - armor[client] < spencerrepair)
					spencerrepair = MaxArmor[client] - armor[client];

				if (armor[client] < MaxArmor[client])
					armor[client] += spencerrepair;

				if (armor[client] > MaxArmor[client] && ArmorOverheal[client] == false)
					armor[client] = MaxArmor[client];
			}
		}
	}
	return Plugin_Continue;
}
public Action:Command_SetPlayerHUD(client, args)
{
	if (IsValidClient(client) && IsClientInGame(client) && !IsFakeClient(client) && GetConVarBool(plugin_enable))
	{
		new Handle:HUDMenu = CreateMenu(MenuHandler_SetHud);

		SetMenuTitle(HUDMenu, "Advanced Armor - Current Armor HUD: %i", GetHUDSetting(client));
		AddMenuItem(HUDMenu, "gnric", "Generic FPS Style - Example: 'Armor:#/MaxArmor:#'");
		AddMenuItem(HUDMenu, "doom", "DOOM Style - Example: 'Armor:#/#'");
		AddMenuItem(HUDMenu, "tfc", "TFC/Quake Style - Example: 'Armor:#'");
	       
		DisplayMenu(HUDMenu, client, MENU_TIME_FOREVER);
	}
}
public MenuHandler_SetHud(Handle:menu, MenuAction:action, client, param2)
{
	decl String:hudslct[64];
	GetMenuItem(menu, param2, hudslct, sizeof(hudslct));
	if (action == MenuAction_Select)
        {
                param2++;
		if (param2 == 1)
                {
			SetHUDSetting(client, 1);
                }
		else if (param2 == 2)
                {
			SetHUDSetting(client, 2);
                }
		else if (param2 == 3)
                {
			SetHUDSetting(client, 3);
                }
	}
	else if (action == MenuAction_End)
        {
                CloseHandle(menu);
        }
}
public Action:Command_SetPlayerArmor(client, args) //THIS INTENTIONALLY OVERRIDES TEAM RESTRICTIONS ON ARMOR
{
	if (GetConVarBool(plugin_enable))
	{
		if (args != 2)
		{
			ReplyToCommand(client, "[Ad-Armor] Usage: sm_setarmor <target> <0-%i>", GetConVarInt(setarmormax));
			return Plugin_Handled;
		}
		decl String:targetname[PLATFORM_MAX_PATH];
		decl String:number[32];
		GetCmdArg(1, targetname, sizeof(targetname));
		GetCmdArg(2, number, sizeof(number));
		new armorsize = StringToInt(number);
		if (armorsize < 0 || armorsize > GetConVarInt(setarmormax))
		{
			ReplyToCommand(client, "[Ad-Armor] Usage: sm_setarmor <target> <0-%i>", GetConVarInt(setarmormax));
			return Plugin_Handled;
		}
		new String:target_name[MAX_TARGET_LENGTH];
		new target_list[MAXPLAYERS+1], target_count;
		new bool:tn_is_ml;
		if ((target_count = ProcessTargetString(
				targetname,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			/* This function replies to the admin with a failure message */
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		for (new i = 0; i < target_count; i++)
		{
			if ((armorsize >= 0) && (armorsize <= GetConVarInt(setarmormax)) && IsPlayerAlive(target_list[i]))
			{
				GetArmorClass(target_list[i]);
				armor[target_list[i]] = armorsize;
				ArmorOverheal[target_list[i]] = true;
				CPrintToChat(target_list[i], "{red}[Ad-Armor]{default} You've been given %i Armor", armorsize);
			}
		}
	}
	return Plugin_Continue;
}
public Action:Command_SetHudParams(client, args)
{
	if (GetConVarBool(plugin_enable) && GetConVarBool(allow_hud_change))
	{
		if (args != 2)
		{
			ReplyToCommand(client, "[Ad-Armor] Usage: sm_armorhudparams <x> <y>", GetConVarInt(setarmormax));
			return Plugin_Handled;
		}
		decl String:numberx[10];
		decl String:numbery[10];
		GetCmdArg(1, numberx, sizeof(numberx));
		GetCmdArg(2, numbery, sizeof(numbery));
		decl Float:params[2];
		params[0] = StringToFloat(numberx);
		params[1] = StringToFloat(numbery);
		{
			ArmorHUDParams[client][0] = params[0];
			ArmorHUDParams[client][1] = params[1];
			SetHUDXParams(client, ArmorHUDParams[client][0]);
			SetHUDYParams(client, ArmorHUDParams[client][1]);
			PrintToChat(client, "[Ad-Armor] You've changed your Armor HUD Parameters");
		}
	}
	return Plugin_Continue;
}
public Action:Command_SetHudColor(client, args)
{
	if (GetConVarBool(plugin_enable) && GetConVarBool(allow_hud_color))
	{
		if (args != 3)
		{
			ReplyToCommand(client, "[Ad-Armor] Usage: sm_armorhudcolor <red: 0-255> <green: 0-255> <blue: 0-255>", GetConVarInt(setarmormax));
			return Plugin_Handled;
		}
		decl String:red[10];
		decl String:green[10];
		decl String:blue[10];
		GetCmdArg(1, red, sizeof(red));
		GetCmdArg(2, green, sizeof(green));
		GetCmdArg(3, blue, sizeof(blue));
		decl params[3];
		params[0] = StringToInt(red);
		params[1] = StringToInt(green);
		params[2] = StringToInt(blue);
		{
			ArmorHUDColor[client][0] = params[0];
			ArmorHUDColor[client][1] = params[1];
			ArmorHUDColor[client][2] = params[2];
			SetHUDColorR(client, ArmorHUDColor[client][0]);
			SetHUDColorG(client, ArmorHUDColor[client][1]);
			SetHUDColorB(client, ArmorHUDColor[client][2]);
			PrintToChat(client, "[Ad-Armor] You've changed your Armor HUD Color");
		}
	}
	return Plugin_Continue;
}
public EntityOutput_OnPlayerTouch(const String:output[], caller, activator, Float:delay)
{
	if (GetConVarBool(plugin_enable) && GetConVarBool(armor_ammo_allow))
	{
		if (IsValidEntity(caller))
		{
			new String:classname[128];
			GetEdictClassname(caller, classname, sizeof(classname));

			if (StrEqual(classname, "item_ammopack_full"))
			{
				if (IsValidEntity(activator))
				{
					GetArmorClass(activator);
					new fullpack = RoundFloat(MaxArmor[activator]*GetConVarFloat(armor_from_fullammo));

					if (MaxArmor[activator] - armor[activator] < fullpack)
						fullpack = MaxArmor[activator] - armor[activator];

					if (armor[activator] < MaxArmor[activator])
						armor[activator] += fullpack;

					if (armor[activator] > MaxArmor[activator] && ArmorOverheal[activator] == false)
						armor[activator] = MaxArmor[activator];

					if (!GetConVarBool(cvBlu) && GetClientTeam(activator) == 3)
						armor[activator] = 0;

					if (!GetConVarBool(cvRed) && GetClientTeam(activator) == 2)
						armor[activator] = 0;
				}
			}
			else if (StrEqual(classname, "item_ammopack_medium"))
			{
				if (IsValidEntity(activator))
				{
					GetArmorClass(activator);
					new mediumpack = RoundFloat(MaxArmor[activator]*GetConVarFloat(armor_from_medammo));

					if (MaxArmor[activator] - armor[activator] < mediumpack)
						mediumpack = MaxArmor[activator] - armor[activator];

					if (armor[activator] < MaxArmor[activator])
						armor[activator] += mediumpack;

					if (armor[activator] > MaxArmor[activator] && ArmorOverheal[activator] == false)
						armor[activator] = MaxArmor[activator];

					if (!GetConVarBool(cvBlu) && GetClientTeam(activator) == 3)
						armor[activator] = 0;

					if (!GetConVarBool(cvRed) && GetClientTeam(activator) == 2)
						armor[activator] = 0;
				}
			}
			else if (StrEqual(classname, "item_ammopack_small"))
			{
				if (IsValidEntity(activator))
				{
					GetArmorClass(activator);
					new smallpack = RoundFloat(MaxArmor[activator]*GetConVarFloat(armor_from_smallammo));

					if (MaxArmor[activator] - armor[activator] < smallpack)
						smallpack = MaxArmor[activator] - armor[activator];

					if (armor[activator] < MaxArmor[activator])
						armor[activator] += smallpack;

					if (armor[activator] > MaxArmor[activator] && ArmorOverheal[activator] == false)
						armor[activator] = MaxArmor[activator];

					if (!GetConVarBool(cvBlu) && GetClientTeam(activator) == 3)
						armor[activator] = 0;

					if (!GetConVarBool(cvRed) && GetClientTeam(activator) == 2)
						armor[activator] = 0;
				}
			}
		}
	}
}
public Action:TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	if (GetConVarBool(plugin_enable) && IsValidClient(attacker) && IsClientInGame(attacker) && IsPlayerAlive(attacker) && IsValidClient(victim) && IsClientInGame(victim) && IsPlayerAlive(victim))
	{
		if (GetClientTeam(attacker) == GetClientTeam(victim))
		{
			if (TF2_GetPlayerClass(attacker) == TFClass_Engineer && GetConVarBool(armor_from_engie)) //props to robin walker for engie armor fix code
			{
				if (!GetConVarBool(cvBlu) && GetClientTeam(victim) == 3)
					return Plugin_Handled;

				if (!GetConVarBool(cvRed) && GetClientTeam(victim) == 2)
					return Plugin_Handled;

				GetArmorClass(victim);
				new iCurrentMetal = GetEntProp(attacker, Prop_Data, "m_iAmmo", 4, 3);
				new repairamount = GetConVarInt(armor_from_metal); //default 10
				new mult = GetConVarInt(armor_from_metal_mult); //default 5

				new hClientWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
				//new wepindex = (IsValidEntity(hClientWeapon) && GetEntProp(hClientWeapon, Prop_Send, "m_iItemDefinitionIndex"));
				new String:classname[64];
				if (IsValidEdict(hClientWeapon)) GetEdictClassname(hClientWeapon, classname, sizeof(classname));
				
				if (StrEqual(classname, "tf_weapon_wrench", false) || StrEqual(classname, "tf_weapon_robot_arm", false))
				{
					if (armor[victim] >= 0 && armor[victim] < MaxArmor[victim])
					{
						if (iCurrentMetal < repairamount)
							repairamount = iCurrentMetal;

						if (MaxArmor[victim] - armor[victim] < repairamount*mult)/*becomes 50 by default*/
							repairamount = RoundToCeil(float((MaxArmor[victim] - armor[victim])/mult));

						armor[victim] += repairamount*mult;

						if (armor[victim] > MaxArmor[victim])
							armor[victim] = MaxArmor[victim];

						new iNewMetal = iCurrentMetal - repairamount;
						SetEntProp(attacker, Prop_Data, "m_iAmmo", iNewMetal, 4, 3);
					}
				}
				/*if (StrEqual(classname, "tf_weapon_shotgun_primary", false) && wepindex == 527 && GetConVarBool(armor_from_widowmaker))
				{
					new repairshot = RoundFloat(damage);
					if (armor[victim] >= 0 && armor[victim] < MaxArmor[victim])
					{
						if (MaxArmor[victim] - armor[victim] < repairshot)
							repairshot = MaxArmor[victim] - armor[victim];

						armor[victim] += repairshot;
						if (armor[victim] > MaxArmor[victim])
						{
							armor[victim] = MaxArmor[victim];
						}
					}
				}*/
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) 
{
	if (GetConVarBool(plugin_enable) && IsValidClient(attacker) && IsClientInGame(attacker) && IsValidClient(victim) && IsClientInGame(victim))
	{
		if ((victim == attacker && !GetConVarBool(allow_self_hurt)) || (GetConVarBool(allow_crit_pierce) && (damagetype & DMG_CRIT)))
		{
			return Plugin_Continue; //prevents soldiers/demos from destroying their own armor but also allows crits to pierce through armor.
		}
		if (!GetConVarBool(allow_uber_damage) && (TF2_IsPlayerInCondition(victim, TFCond_Ubercharged) || TF2_IsPlayerInCondition(victim, TFCond_Bonked)))
		{
			return Plugin_Continue; //prevent ubered players from losing armor
		}
		if (armor[victim] >= 1 && ArmorType[victim] != 0 && GetClientTeam(attacker) != GetClientTeam(victim))
		{
			new dmgresist = ArmorType[victim];
			switch (dmgresist)
			{
				case 1: DamageResistance[victim] = GetConVarFloat(damage_resistance_type1); //default 0.3
				case 2: DamageResistance[victim] = GetConVarFloat(damage_resistance_type2); //default 0.6
				case 3: DamageResistance[victim] = GetConVarFloat(damage_resistance_type3); //default 0.8
				//case 4: insert code here
			}

			new Float:intdamage = DamageResistance[victim]*damage;
			armor[victim] -= RoundFloat(intdamage); //subtract armor
			if (armor[victim] < 1) //if armor goes under 1, transfer rest of unabsorbed damage to health.
			{
				intdamage += armor[victim];
				armor[victim] = 0;
			}
			damage -= intdamage;
			//CPrintToChat(attacker, "{green}[Ad-Armor-Test]{cyan} final damage is %f", damage);
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}
public GetArmorClass(client)
{
	new TFClassType:armoron = TF2_GetPlayerClass(client);
	switch (armoron)
	{
		case TFClass_Scout:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_scout);
			ArmorType[client] = GetConVarInt(armortype_scout);
			ArmorRegenerate[client] = GetConVarInt(armorregen_scout);
		}
		case TFClass_Soldier:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_soldier);
			ArmorType[client] = GetConVarInt(armortype_soldier);
			ArmorRegenerate[client] = GetConVarInt(armorregen_soldier);
		}
		case TFClass_Pyro:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_pyro);
			ArmorType[client] = GetConVarInt(armortype_pyro);
			ArmorRegenerate[client] = GetConVarInt(armorregen_pyro);
		}
		case TFClass_DemoMan:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_demo);
			ArmorType[client] = GetConVarInt(armortype_demo);
			ArmorRegenerate[client] = GetConVarInt(armorregen_demo);
		}
		case TFClass_Heavy:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_heavy);
			ArmorType[client] = GetConVarInt(armortype_heavy);
			ArmorRegenerate[client] = GetConVarInt(armorregen_heavy);
		}
		case TFClass_Engineer:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_engie);
			ArmorType[client] = GetConVarInt(armortype_engie);
			ArmorRegenerate[client] = GetConVarInt(armorregen_engie);
		}
		case TFClass_Medic:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_med);
			ArmorType[client] = GetConVarInt(armortype_med);
			ArmorRegenerate[client] = GetConVarInt(armorregen_med);
		}
		case TFClass_Sniper:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_sniper);
			ArmorType[client] = GetConVarInt(armortype_sniper);
			ArmorRegenerate[client] = GetConVarInt(armorregen_sniper);
		}
		case TFClass_Spy:
		{
			MaxArmor[client] = GetConVarInt(maxarmor_spy);
			ArmorType[client] = GetConVarInt(armortype_spy);
			ArmorRegenerate[client] = GetConVarInt(armorregen_spy);
		}
	}
}
public Action:ArmorHelp(client, args)
{
	if (!GetConVarBool(plugin_enable))
	{
		ReplyToCommand(client, "[Ad-Armor]{green} Advanced Armor is turned off");
		return Plugin_Handled;
	}
        if (client && IsClientInGame(client) && !IsFakeClient(client))
        {
		new Handle:armorhalp = CreateMenu(MenuHandler_armorhalp);
 
		SetMenuTitle(armorhalp, "Armor Help - Main Menu:");
		AddMenuItem(armorhalp, "armrtype", "What's my Armor type?");
		AddMenuItem(armorhalp, "cmds", "What are the available Commands?");
		//AddMenuItem(armorhalp, "non", "None");
		//SetMenuExitBackButton(armorhalp, true);
		DisplayMenu(armorhalp, client, MENU_TIME_FOREVER);
        }
        return Plugin_Handled;
}
public MenuHandler_armorhalp(Handle:menu, MenuAction:action, client, param2)
{
	decl String:armar[32];
	decl String:arg[32];
	new name;
	GetMenuItem(menu, param2, arg, sizeof(arg));
	if (action == MenuAction_Select)
        {
		//SetBossCookie(client, VSHSpecial_None);
		param2++;
		if (param2 == 1)
                {
			name = ArmorType[client];
			switch (name)
			{
				case 0: armar = "None";
				case 1: armar = "Light Armor";
				case 2: armar = "Medium Armor";
				case 3: armar = "Heavy Armor";
			}
			CPrintToChat(client, "{red}[Ad-Armor]{default} Your Armor Type is {cyan}%s{default}, with damage resistance of {cyan}%f{default}", armar, DamageResistance[client]);
                }
		else if (param2 == 2)
                {
			CPrintToChat(client, "{red}[Ad-Armor]{default} The Available Commands are {green}'sm_armorhud'{default}, {green}'sm_armorhudparams'{default}, {green}'sm_setarmor' for admins{default}, and {green}'sm_armorhudcolor'");
                }
	}
	else if (action == MenuAction_End)
        {
                CloseHandle(menu);
        }
}
public Action:Timer_Announce(Handle:hTimer)
{
	if (GetConVarBool(plugin_enable))
	{
		CPrintToChatAll("{red}[Ad-Armor]{default} for help/info about Armor, type !armorhelp");
	}
}



public OnAllPluginsLoaded() 
{
	new Handle:convar;
	if (LibraryExists("updater")) 
	{
		Updater_AddPlugin(UPDATE_URL);
		decl String:newVersion[10];
		FormatEx(newVersion, sizeof(newVersion), "%sA", PLUGIN_VERSION);
		convar = CreateConVar("sm_adarmor_version", newVersion, "Plugin Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_CHEAT);
	}
	else 
	{
		convar = CreateConVar("sm_adarmor_version", PLUGIN_VERSION, "Plugin Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_CHEAT);	
	}
	HookConVarChange(convar, Callback_VersionConVarChanged);
}
public OnAutoUpdateChange(Handle:conVar, const String:oldVal[], const String:newVal[])
{
	g_bAutoUpdate = bool:StringToInt(newVal);
}
public Callback_VersionConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	ResetConVar(convar);
}
public OnLibraryAdded(const String:name[])
{
	if (!strcmp(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public Action:Updater_OnPluginDownloading()
{
	if (!g_bAutoUpdate)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Updater_OnPluginUpdated() 
{
	ReloadPlugin();
}
////////////////////stocks///////////////////
stock ClearTimer(&Handle:Timer)
{
	if (Timer != INVALID_HANDLE)
	{
		CloseHandle(Timer);
		Timer = INVALID_HANDLE;
	}
}
stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}
stock bool:IsValidClient(iClient, bool:bReplay = true)
{
	if(iClient <= 0 || iClient > MaxClients)
		return false;
	if(!IsClientInGame(iClient))
		return false;
	if(bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
		return false;
	return true;
}
stock GetHealingTarget(client)
{
	new String:s[64];
	new medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (medigun <= MaxClients || !IsValidEdict(medigun))
		return -1;
	GetEdictClassname(medigun, s, sizeof(s));
	if (strcmp(s, "tf_weapon_medigun", false) == 0)
	{
		if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
			return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}
stock bool:IsInHeal(client)
{
	new bool:beinghealed;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
		{
			beinghealed = true;
			break;
		}
		else
			beinghealed = false;
	}
	return beinghealed;
}
/*stock bool:TF2_EwSdkStartup()
{
	new Handle:hGameConf = LoadGameConfigFile("tf2items.randomizer");
	if (hGameConf == INVALID_HANDLE)
	{
		LogError("Couldn't load SDK functions (GiveWeapon). Make sure tf2items.randomizer.txt is in your gamedata folder! Restart server if you want wearable weapons.");
		return false;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hSdkEquipWearable = EndPrepSDKCall()) == INVALID_HANDLE)
	{
		LogError("Couldn't load SDK functions (CTFPlayer::EquipWearable). SDK call failed.");
		return false;
	}
	CloseHandle(hGameConf);
	return true;
}*/
//////////////////natives/forwards////////////////////
