/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_stripUnit
Author: Whiztler
Script version: 1.04

File: fn_stripUnit.sqf
Diag: 0.0865 ms
**********************************************************************************
ABOUT
Removes all items, all weapons, vest, backpack, headgear. There is an option to 
keep the uniform.

INSTRUCTIONS:
Execute (call) from any client where the unit is local. Server can delete on any
client.

REQUIRED PARAMETERS:
0. Object:      AI unit, player

OPTIONAL PARAMETERS:
1. Bool:        Remove the uniform:        
                - true - remove the uniform  (default)      
                - false - do not remove the uniform        

EXAMPLES USAGE IN SCRIPT:
[player, false] call ADF_fnc_stripUnit;

EXAMPLES USAGE IN EDEN:
player call ADF_fnc_stripUnit;

DEFAULT/MINIMUM OPTIONS
[_unit] call ADF_fnc_stripUnit;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_stripUnit"};

// Init
params [
	["_unit", objNull, [objNull]],
	["_removeUniform", true, [false]]
];

if !(_unit isKindOf "CAManBase") exitWith {[format ["ADF_fnc_stripUnit - Incorrect unit passed: '%1'. Exiting", _unit], true] call ADF_fnc_log; false};


// Only run on local machines
//if !(local _unit) exitWith {};

// Strip all items
removeAllWeapons _unit;
removeAllAssignedItems _unit;
removeAllItems _unit;
removeHeadgear _unit;
removeGoggles _unit;
removeVest _unit;
removeBackpack _unit;

// If the uniform needs to be deleted then do so
if (_removeUniform) then {removeUniform _unit};

true