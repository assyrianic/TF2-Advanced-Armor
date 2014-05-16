/**
 * Syntax = SourcePawn
 * File: armor.inc
 * Description: Natives/Forwards for Advanced Armor plugin.
 * Author(s): Assyrian/Nergal
 */
 
#if defined _advanced_armor_included_
 #endinput
#endif
#define _advanced_armor_included_

/**
 * Returns the Armor Type of a client.
 *
 * @param client	Client index.
 *
 * @return	armortype.
 */
native GetArmorType(client);

/**
 * Sets the Armor Type of a client.
 *
 * @param client	Client index.
 *
 * @param type		armor type.
 */
native SetArmorType(client, type);

/**
 * Returns the Maximum armor a client can hold.
 *
 * @param client	Client index.
 *
 * @return	Max Armor.
 */
native GetMaxArmor(client);

/**
 * Sets the Maximum armor a client can hold.
 *
 * @param client	Client index.
 * 
 * @param maxarmor	Max Armor Amount.
 */
native SetMaxArmor(client, maxarmor);

/**
 * Returns the current armor of a client.
 *
 * @param client	Client index.
 *
 * @return	Current Armor.
 */
native GetCurrentArmor(client);

/**
 * Set the current armor of a client.
 *
 * @param client	Client index.
 * @param armount	Armor Amount
 */
native SetCurrentArmor(client, armount);

/**
 * Returns the damage resistance of a clients armor.
 *
 * @param client	Client index.
 *
 * @return	damage resistance float.
 */
native Float:GetArmorDamageResistance(client);

/**
 * Sets the damage resistance of a clients (for use with armor).
 *
 * @param client	Client index.
 * @param Float:dmgfloat	number that will be multiplied with damage and subtracted to armor.
 *
 * Good example of usage would be SetArmorDamageResistance(client, 0.99);
 * 99% would mean that only 1% of the damage will go to player's health while the 99% goes to armor.
 */
native SetArmorDamageResistance(client, Float:dmgfloat);

/**
 * Returns if a client is near a dispencer/being healed by dispenser.
 *
 * @param client	Client index.
 * @return	true if near a dispenser.
 */
native bool:IsNearDispenser(client);

public SharedPlugin:__pl_advanced_armor = 
{
	name = "advanced_armor",
	file = "advanced_armor.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
