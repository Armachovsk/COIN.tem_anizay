/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Para drop script
Author: Whiztler
Script version: 1.22

File: fn_paraDrop.sqf
**********************************************************************************
ABOUT
AI para function that is executed om AI units individually. The function creates,
assigns and attaches a parachute to a unit and removes the parachute once the unit
is touching the ground. Leaders are dropped with a smoke grenade attached.

The functions works for units in an aircraft or units on the ground that are
positioned at a specific altitue and then paradrop.

You can optionally pass the unit's backpack + backpack items to reapply them once
the unit has landed.

INSTRUCTIONS:
Execute from the server.

REQUIRED PARAMETERS:
0: Object     The AI unit

OPTIONAL PARAMETERS:
1. position:    Para drop position. Marker, object, trigger or position
                array [x,y,z].
2. Number:      Para drop altitu.
                Default: 0 (position altitude will be used)

EXAMPLES USAGE IN SCRIPT:
[_unit] call ADF_fnc_paraDrop;
[_unit, _heli] call ADF_fnc_paraDrop;
[_unit, "paraPosMarker", 250] call ADF_fnc_paraDrop; // move the _units to the paraposmarker and para drop them from a 175 meter altitude.

EXAMPLES USAGE IN EDEN:
[group this, "MarkerPos", 200] call ADF_fnc_paraDrop;

DEFAULT/MINIMUM OPTIONS
[_unit] call ADF_fnc_paraDrop;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_paraDrop"};

// Init
params [
	["_unit", objNull, [objNull]],
	["_dropPos", "", ["", [], objNull, grpNull, locationNull, false]], // optional
	["_dropPosAlt", 0, [0]], // optional
	["_position", [], [[]]],
	["_smoke", objNull, [objNull]]
];
private _chuteClass = "Steerable_parachute_F";
private _group = group _unit;
private _hasBackpack = (_unit getVariable ["paraUnitItems", [false, "", []]]) # 0;

/*
diag_log format [
	"unit: %1 -- _hasBackpack: %2 -- backpack: %3 -- items: %4",
	_unit,
	(_unit getVariable ["paraUnitItems", [false, "", []]]) # 0,
	(_unit getVariable ["paraUnitItems", [false, "", []]]) # 1,
	(_unit getVariable ["paraUnitItems", [false, "", []]]) # 2
]; // debug
*/

if !(assignedVehicle _unit == objNull) then {
	_position = getPosASL (vehicle _unit);
	// Order the unit in cargo to jump out of the aircraft
	unassignVehicle _unit;
	_unit action ["EJECT", vehicle _unit];
	
	// Position the unit 2.5 meters below the aircraft to avoid collision
	_unit setPosASL [_position # 0, _position # 1, (_position # 2) - 2.5];
} else {
	// Manual para drop. No jumping out of an aircraft but move the unit to the specified position and altitude.
	_position = getPosASL _dropPos;
	private _setAlt = (_position # 2) - 2.5;
	if (_setAlt < 125) then {_setAlt = 175};
	if (_dropPosAlt > 125) then {_setAlt = _dropPosAlt};
	
	_unit setPosASL [_position # 0, _position # 1, _setAlt];
};

// Create the parachute and move in the unit into the parachute
private _chute = createVehicle [_chuteClass, _position, [], 0, 'FLY'];
_unit assignAsDriver _chute;
_unit moveInDriver _chute;

// Leaders get a smoke granade attached
if (_unit == leader _group) then {
	_smoke	= createVehicle [(selectRandom ["SmokeShellRed", "SmokeShellPurple"]), getPos _chute, [], 0, "FLY"];
	_smoke attachTo [_chute, [0.8, 0, 0]];
};

sleep 3;	
_unit allowDamage true;

// When to unit is close to the ground switch off damage allowance in case he hits an object close to the ground.
waitUntil {sleep .5; getPosATL _unit # 2 < 5 || isNull _unit || !alive _unit};
if (alive _unit) then {
	_unit allowDamage false;

	// On touch down, detach the smoke from the leader, give back the backpack and set the HC transfer and cache vars
	waitUntil {sleep 1; isTouchingGround _unit || isNull _unit};
	if (_unit == leader _group) then {detach _smoke};
	_unit allowDamage true;
};
if (_hasBackpack) then {
	private _items = _unit getVariable ["paraUnitItems", [true, "B_TacticalPack_blk", []]];
	private _sbi = _items # 2;
	_unit addBackpack _items # 1;
	{_unit addItemToBackpack _x} forEach _sbi;
};
//_group setVariable ["ADF_noHC_transfer", false];
//_group setVariable ["zbe_cacheDisabled", false];
sleep 5;
// delete the chute and smoke nade
[_chute] call ADF_fnc_delete;
if (_unit == leader _group && (!isNull _smoke)) then {[_smoke] call ADF_fnc_delete};

true