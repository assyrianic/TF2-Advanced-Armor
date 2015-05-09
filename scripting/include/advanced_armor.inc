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
native int GetArmorType(int client);

/**
 * Sets the Armor Type of a client.
 *
 * @param client	Client index.
 *
 * @param type		armor type.
 */
native void SetArmorType(int client, int type);

/**
 * Returns the Maximum armor a client can hold.
 *
 * @param client	Client index.
 *
 * @return	Max Armor.
 */
native int GetMaxArmor(int client);

/**
 * Sets the Maximum armor a client can hold.
 *
 * @param client	Client index.
 * 
 * @param maxarmor	Max Armor Amount.
 */
native void SetMaxArmor(int client, int maxarmor);

/**
 * Returns the current armor of a client.
 *
 * @param client	Client index.
 *
 * @return	Current Armor.
 */
native int GetCurrentArmor(int client);

/**
 * Set the current armor of a client.
 *
 * @param client	Client index.
 * @param armount	Armor Amount
 */
native void SetCurrentArmor(int client, int armount);

/**
 * Returns the damage resistance of a clients armor.
 *
 * @param client	Client index.
 *
 * @return	damage resistance float.
 */
native float GetArmorDamageResistance(int client);

/**
 * Sets the damage resistance of a clients (for use with armor).
 *
 * @param client	Client index.
 * @param Float:dmgfloat	number that will be multiplied with damage and subtracted to armor.
 *
 * Good example of usage would be SetArmorDamageResistance(client, 0.99);
 * 99% would mean that only 1% of the damage will go to player's health while the 99% goes to armor.
 */
native void SetArmorDamageResistance(int client, float dmgfloat);

/**
 * Returns if a client is near a dispencer/being healed by dispenser.
 *
 * @param client	Client index.
 * @return	true if near a dispenser.
 */
native bool IsNearDispenser(int client);

/**
 * reads a player's armor and gives an auditory sound
 *
 * @param client	Client index.
 * @return		audio of armor amount
 */
native void ReadClientArmor(int client);
