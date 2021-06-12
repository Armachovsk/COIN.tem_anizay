/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_vehicleCrewAI
Author: Whiztler
Script version: 1.04

File: fn_vehicleCrewAI.sqf
Diag: 0.0666 ms
**********************************************************************************
ABOUT:
ARMA 3 vanilla settings make crew abandon their vehicle when it has been damaged
slightly. This function  adds a more realistic scenario that make crews stay
inside their vehicle and continue fighting. The crew abandons he vehicle once the
vehicle damage has gone critical (> 0.75). This only applies to vehicles with
combat facilities.

ADF_fnc_vehicleCrewAI is automatically applied from within the 
ADF_fnc_createCrewedVehicle function.

INSTRUCTIONS
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      The vehicle that occupies a vehicle crew.

OPTIONAL PARAMETERS:
1. String:      Skill set of the vehicle crew. Default: "novice"   
                "untrained" - unskilled, slow to react 
                "recruit"   - semi skilled
                "novice"    - Skilled, trained. Vanilla+ setting
                "veteran"   - Very skilled, Well trained
                "expert"    - Special forces quality
2. Bool         Set Skill?
                true (default)
                false

EXAMPLES USAGE IN SCRIPT:
[_veh, "veteran"] call ADF_fnc_vehicleCrewAI;

EXAMPLES USAGE IN EDEN:
[this, "recruit"] call ADF_fnc_vehicleCrewAI;

DEFAULT/MINIMUM OPTIONS
[myTank] call ADF_fnc_vehicleCrewAI;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_vehicleCrewAI"};

// Init
params [
	["_vehicle", objNull, [objNull]],
	["_skill", "NOVICE", [""]],
	["_setSkill", false, [true]]
];

// Check valid vars
if !(_vehicle isKindOf "AllVehicles") exitWith {[format ["ADF_fnc_vehicleCrewAI - Incorrect vehicle passed: '%1'. Exiting", _vehicle], true] call ADF_fnc_log; false};
//if ((_skill != "untrained") && {(_skill != "recruit") && {(_skill != "novice") && {(_skill != "veteran") && {(_skill != "expert")}}}}) then {_skill = "novice"; if ADF_debug then {[format ["ADF_fnc_createSAD - incorrect skill (%1) passed for group: %2. Defaulted to 'novice'.",_skill, _g]] call ADF_fnc_log;}};

// Apply crew courage to crewed combat vehicles.
if (canFire _vehicle && (count (crew _vehicle) > 0)) then {
	_vehicle allowCrewInImmobile true;
	//if _setSkill then {[group ((crew _vehicle) # 0), _skill] call ADF_fnc_groupSetSkill};
	_vehicle addEventHandler [ "HIT", {
		// Init
		params["_vehicle"];
		// Check if the vehicle is still able to perform combat duties. If not, order the crew to abandon the vehicle.
		if !((canFire _vehicle) || {(damage _vehicle) < 0.75}) then {
			_vehicle allowCrewInImmobile false;
			{_x action ["EJECT", _vehicle]} forEach crew _vehicle;
			_vehicle removeEventHandler ["HIT", 0];
		};
	}];	

	// Alter the AGM cook off settings randomly. 
	if (ADF_mod_ACE3 && {(random 1 > 0.75)}) then {_vehicle setVariable ["ace_cookoff_enable", false]};
	
	true
} else {
	false
};