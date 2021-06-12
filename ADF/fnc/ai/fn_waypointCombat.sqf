/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_waypointCombat
Author: Whiztler
Script version: 1.07

File: fn_waypointCombat.sqf
**********************************************************************************
ABOUT:
This function makes groups in vehicles switch to combat mode when attacked or when
they spot an enemy. The function is triggered when the groups combat mode changes
from safe/aware to combat. The group pauses their 'normal' patrol and enter a 
'search and destroy' mode for at least 3 minutes. After the SAD period the group
continues with their original patrol.

Note that this function is automatically spawned with the 
ADF_fnc_createVehiclePatrol function for any vehicle that has a turret.

INSTRUCTIONS
Execute (spawn) from the server or HC

REQUIRED PARAMETERS:
0. Group:       Group. Should be in a vehicle with a turret.

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[_grp] spawn ADF_fnc_waypointCombat;

EXAMPLES USAGE IN EDEN:
[group this] spawn ADF_fnc_waypointCombat;

DEFAULT/MINIMUM OPTIONS
[myGroup] spawn ADF_fnc_waypointCombat;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_waypointCombat"};

// Init
params [
	["_group", grpNull, [grpNull]]
];
private _leader = leader _group;
private _side = side _group;
private _vehicle = vehicle _leader;
private _behaviour = behaviour _leader;

// Check valid vars & valid application
if (_group == grpNull) exitWith {[format ["ADF_fnc_waypointCombat - Empty group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};	
if (_behaviour == "COMBAT") exitWith {if ADF_debug then {[format ["ADF_fnc_waypointCombat - group (%1) behavior is set at %2. Exiting.", _group, behaviour _leader]] call ADF_fnc_log}; false};
if (isNull objectParent _leader) exitWith {if ADF_debug then {[format ["ADF_fnc_waypointCombat - group (%1) leader is not in a vehicle. Exiting.", _group]] call ADF_fnc_log}; false};
if !(canFire _vehicle || {canMove _vehicle}) exitWith {if ADF_debug then {[format ["ADF_fnc_waypointCombat - The groups (%1) vehicle (%2) cannot move or fire. Exiting.", _group, _vehicle]] call ADF_fnc_log}; false};

if ADF_debug then {[format ["ADF_fnc_waypointCombat - monitoring combat behavior for group: %1 (current: %2)", _group, _behaviour]] call ADF_fnc_log};

// monitor behavior change. 3 seconds interval
waitUntil {
	sleep 3;
	((behaviour (leader _group)) == "COMBAT" || !alive (leader _group))
};
if (!alive (leader _group)) exitWith {if ADF_debug then {[format ["ADF_fnc_waypointCombat - Group (%1) seems no longer to be alive. Exiting", _group], true] call ADF_fnc_log;}; false};	

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_waypointCombat - group (%1) combat behavior changed to: %1", _behaviour]] call ADF_fnc_log};

// Create a dummy group and store the waypoints. The dummy units is created else ARMA or the cleanup script deletes the empty group.
private _dummy = createGroup _side;
private _unit = _dummy createUnit ["C_man_1", [0,0,0] ,[], 0, "CAN_COLLIDE"];
_unit allowDamage false;
[_unit] call ADF_fnc_objectSimulation;
_dummy copyWaypoints _group;

// Delete the waypoints and assign a SAD waypoint
[_group] call ADF_fnc_delWaypoint;
private _position = getPosWorld _vehicle;
private _waypoint = _group addWaypoint [_position, 0];
_waypoint setWaypointType "SAD";
{_x allowDamage true} forEach units _group; // hack ADF 2.22

// Let's override the default BIS timeout and set the SAD to at least 3 minutes.
private _time = time;
waitUntil {
	sleep 5;
	if (speed _vehicle == 0) then {
		[_group] call ADF_fnc_delWaypoint;
		private _waypoint = _group addWaypoint [_position, 0];
		_waypoint setWaypointType "SAD";
	};
	(time > (_time + (180 + (random 30))) || !alive (leader _group))
};

// monitor when the group change back to safe/aware mode
waitUntil {
	sleep 3;
	(!((behaviour (leader _group)) == "COMBAT") || !alive (leader _group))
};
if (!alive (leader _group)) exitWith {
	if ADF_debug then {[format ["ADF_fnc_waypointCombat - Group (%1) seems no longer to be alive. Exiting", _group], true] call ADF_fnc_log;};
	[_dummy] call ADF_fnc_delete;
	false
};	

// Debug reporting
if ADF_debug then {systemChat format ["ADF_fnc_waypointCombat - group (%1) combat behavior changed to: %1. Continue original patrol", _behaviour];};

// Return the original waypoints & combat behavior
[_group] call ADF_fnc_delWaypoint;
_group copyWaypoints _dummy;
[_dummy] call ADF_fnc_delete;
_group setBehaviour _behaviour;

// Repeat
if (alive (leader _group)) then {
	[_group] spawn ADF_fnc_waypointCombat;
	true
} else {
	if ADF_debug then {[format ["ADF_fnc_waypointCombat - Group (%1) seems no longer to be alive. Exiting", _group], true] call ADF_fnc_log;};
	false
};	
