/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_storeLoadout
Author: Whiztler
Script version: 1.03

File: fn_storeLoadout.sqf
**********************************************************************************
ABOUT
Stores the loadout during the game session. This is not a multi-session solution.

INSTRUCTIONS:
Execute (call) from client

REQUIRED PARAMETERS:
0. Object:      Player

OPTIONAL PARAMETERS:
1. String:      Options:
                - "save" Store the loadout (default)
                - "load" Load a saved loadout
        
EXAMPLES USAGE IN SCRIPT:
[player, "load"] call ADF_fnc_storeLoadout;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[player] call ADF_fnc_storeLoadout;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_storeLoadout"};

params [
	["_unit", objNull, [objNull]],
	["_mode", "save", [""]]
];

// Check valid vars
if !(_unit isKindOf "CAManBase" || isPlayer _unit) exitWith {[format ["ADF_fnc_storeLoadout - passed object does not seem to be a playable unit: '%1' (%2). Exiting", _unit, typeOf _unit], true] call ADF_fnc_log; false};
if (	(_mode != "load") && (_mode != "save")) then {_mode = "save"; if ADF_debug then {[format ["ADF_fnc_storeLoadout - incorrect storage param (%1) passed for player: %2. Defaulted to 'novice'.",_mode, _unit]] call ADF_fnc_log;}};

// Only run on local machines

if (_mode == "SAVE") exitWith {
	// Containers
	ADF_StoreLoadout_uniform = uniform _unit;
	ADF_StoreLoadout_vest = vest _unit;
	ADF_StoreLoadout_backpack = backpack _unit;
	ADF_StoreLoadout_headgear = headgear _unit;	
	ADF_StoreLoadout_goggles = goggles _unit;	
	// Weapons (also binos, gps etc)
	ADF_StoreLoadout_weapons = weapons _unit;	
	ADF_StoreLoadout_magazines = magazines _unit;
	// Weapon attachments etc
	ADF_StoreLoadout_primaryWeaponItems = primaryWeaponItems _unit;
	ADF_StoreLoadout_secondaryWeaponItems = secondaryWeaponItems _unit;	
	ADF_StoreLoadout_sideWeaponItems = handgunItems _unit;
	// items
	ADF_StoreLoadout_items = items _unit;
	ADF_StoreLoadout_assignedItems = assignedItems _unit;
	
	true
};

if (_mode == "LOAD") exitWith {
	[_unit, true] call ADF_fnc_stripUnit;

	// Containers
	_unit addUniform ADF_StoreLoadout_uniform;
	_unit addVest ADF_StoreLoadout_vest;
	_unit addBackpack ADF_StoreLoadout_backpack;
	_unit addHeadgear ADF_StoreLoadout_headgear;
	_unit addGoggles ADF_StoreLoadout_goggles;
	// Weapons/Magazines
	{_unit addMagazine _x} forEach ADF_StoreLoadout_magazines;
	{_unit addWeapon _x} forEach ADF_StoreLoadout_weapons;
	// Weapon attachments etc
	{_unit addPrimaryWeaponItem _x} forEach ADF_StoreLoadout_primaryWeaponItems;
	{_unit addSecondaryWeaponItem _x} forEach ADF_StoreLoadout_secondaryWeaponItems;
	{_unit addHandgunItem _x} forEach ADF_StoreLoadout_sideWeaponItems;
	// Items
	{_unit addItem _x} forEach ADF_StoreLoadout_items;
	{_unit assignItem _x} forEach ADF_StoreLoadout_assignedItems;
	
	true
};

if (!(_mode == "LOAD") && !(_mode == "SAVE")) exitWith {
	// Debug reporting
	if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF Debug: ADF_fnc_storeLoadout - ERROR, incorrect parameter passed. Should be either 'LOAD' or 'SAVE'. Exiting."};
	
	false
};