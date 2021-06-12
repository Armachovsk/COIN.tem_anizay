/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_surrender
Author: Whiztler
Script version: 1.04

File: fn_surrender.sqf
**********************************************************************************
ABOUT
Forces unit(s) (side, group, array) to surrender. If in a vehicle surrendered units
will disembark their vehicle. Surrendered units will drop their weapon and mags 
and raise their arms as in a surrender position/animation.

INSTRUCTIONS:
Execute (call) from the server

REQUIRED PARAMETERS:
0. Group:      The group that will surrender

OPTIONAL PARAMETERS:
1. Bool:       Switch surrendered unit to civilian side?
               - true (default)
               - false

EXAMPLES USAGE IN SCRIPT:
[myGroup] call ADF_fnc_surrender;

EXAMPLES USAGE IN EDEN:
[group this, false] call ADF_fnc_surrender;

DEFAULT/MINIMUM OPTIONS
[_group] call ADF_fnc_surrender;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_surrender"};

// Init
params [
	["_group", grpNull, [objNull, grpNull, []]],
	["_captive", true, [false]]
];

// Check valid vars
if (_group isEqualType objNull) exitWith {[group _x] call ADF_fnc_surrender; false};
if (_group isEqualType []) exitWith {{_x call ADF_fnc_surrender} forEach _group; false};
if ((count units _group) isEqualTo 0) exitWith {false};

private _units = units _group;
private _leader = leader _group;

[_group] call ADF_fnc_delWaypoint; 
_group setBehaviour "CARELESS";
_group setCombatMode "BLUE";
_group allowFleeing 0;

// Check if in a vehicle
if !(isNull objectParent _leader) then {
	
	private _vehicle = objectParent _leader;
	private _vehiclePosition = getPosATL _vehicle;		
	
	// Check if airborne
	if ((_vehiclePosition select 3) > 5) exitWith {};
	
	// Check if in a boat
	if (surfaceIsWater _vehiclePosition) then {
		private _newPosition = [];
		private _foundLandPosition = false;

		// Increase distance 100 m increments up to 5 km search radius
		For "_i" from 0 to 5000 step 100 do {
			// Look in 60 degrees direction increments
			For "_j" from 0 to 360 step 60 do {
				private _position = [(_vehiclePosition select 0) + (sin _j) * _i, (_vehiclePosition  select 1) + (cos _j) * _i, 0];
				If !(surfaceIsWater _position) exitWith {
					_foundLandPosition = true;
					_newPosition = _position;
				};
			};
			if _foundLandPosition exitWith {};
		};

		driver _vehicle doMove _newPosition;
		waitUntil {
			sleep 1;
			unitReady driver _vehicle
		};
	};
	
	{
		moveOut _x;
		unassignVehicle _x;
	} forEach _units;
};

_units orderGetIn false;
_units allowGetIn false;
doStop _units;

{
	// Appear to drop weapon and magazines
	private _unit = _x;
	private _mags = magazinesAmmoFull _unit;
	private _weapons = weapons _unit;
	
	private _temp = createVehicle ["GroundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];
	_temp setPos [((getPosATL _unit) # 0) + (.3 + random 1), ((getPosATL _unit) # 1) + (.3 + random 1), (getPosATL _unit) # 2];
	
	removeAllWeapons _unit;
	{_unit removeMagazine _x} count _mags;	
	{_temp addWeaponCargo [_x, 1]} count _weapons; 
	{_temp addMagazineCargo [_x # 0, 1]} count _mags; 

	// Surrender animation
	_x setUnitPos "UP";
	if isMultiplayer then {
		[_x, "AmovPercMstpSsurWnonDnon"] remoteExec ["playMove"];
	} else {
		_x playMove "AmovPercMstpSsurWnonDnon";
	};

	// Set unit captive
	if _captive then {
		_x disableAI "ANIM";
		_x disableAI "FSM";
		_x setCaptive true;
	};
} forEach _units;

true