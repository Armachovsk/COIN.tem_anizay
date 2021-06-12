/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_onPlayerKilled
Author: Whiztler
Script version: 4.01

File: fn_onPlayerKilled.sqf
**********************************************************************************
ABOUT
This function is automatically called when a player dies. All functionality is
configured in the mission settings/mission information.

Custom scripts can be added via: mission\events\ADF_mission_playerKilled.sqf

PARAMETERS
The following parameters are passed
_unit - the player
_killer - the unit that killed the player
_instigator - Object/Person who pulled the trigger
_useEffects - Boolean - same as useEffects in setDamage alt syntax

RETURNS:
Nothing
*********************************************************************************/

diag_log "ADF rpt: Init - executing: ADF_fnc_onPlayerKilled.sqf";

// Init
params ["_unit", "_killer", "_instigator", "_useEffects"];

// If the player died in a vehicle then remove the body from the vehicle
if  !(isNull objectParent player) then {
    unassignVehicle _unit;
    _unit action ["eject", vehicle _unit];
    _unit setPosATL [(getPosATL vehicle _unit # 0) + 5, (getPosATL vehicle _unit # 1) + 2, 0];
};


// No respawn (0) or Bird respawn (1)
if ((getNumber (missionConfigFile >> "respawn")) < 2) exitWith {
	call {
		if ADF_mod_TFAR exitWith {[player, true] call TFAR_fnc_forceSpectator};
		if ADF_mod_ACRE exitWith {[true] call acre_api_fnc_setSpectator};
		["Initialize", [player]] call BIS_fnc_EGSpectator;
	};
};

// Check if respawn-tickets are enabled and check if there are no more tickets left. If true evoke spectator.
if (ADF_Tickets && (((side player == west) && (([west] call BIS_fnc_respawnTickets) < 1)) || ((side player == east) && (([east] call BIS_fnc_respawnTickets) < 1)))) exitWith {
	if ADF_mod_ACE3 then {
		player setVariable ["ACE_Medical_hasPain", false];
		player setVariable ["ACE_Medical_isBleeding", false];
		player setVariable ["ACE_isUnconscious", false];
		[false] call ACE_Common_fnc_disableUserInput;
		ace_hearing_disableVolumeUpdate = true;
	};
	"chromAberration" ppEffectEnable false;	
	["Initialize", [player]] call BIS_fnc_EGSpectator; // force into spectator - ADF 2.16
};

// Save the player loadout when ACE3 SameGearRespawn is NOT enabled
if (ADF_sameGearRespawn && {!ADF_mod_ACE3}) then {[player, "SAVE"] call ADF_fnc_storeLoadout};

// call custom mission onPlayerKilled:
[_unit, _killer, _instigator, _useEffects] call ADF_mission_onPlayerKilled;

