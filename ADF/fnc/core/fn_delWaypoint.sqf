/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_delWaypoint
Author: Whiztler. Based on CBA fnc_clearWaypoints by SilentSpike
Script version: 1.02

File: fn_delWaypoint.sqf
**********************************************************************************
ABOUT
This function deletes all waypoints assigned to a group

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Group:       Existing group that has the waypoints assigned

OPTIONAL PARAMETERS:
None

EXAMPLE
[_group] call ADF_fnc_delWaypoint; 

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_delWaypoint"};

// init	
params [
	["_group", grpNull, [grpNull]]
];

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_delWaypoint - Empty or invalid group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_delWaypoint - group: %1", _group]] call ADF_fnc_log};

{deleteWaypoint [_group, 0]} forEach (waypoints _group);

// Create a last waypoint and delete on execution
private _last = _group addWaypoint [getPosATL (leader _group), 0];
_last setWaypointStatements ["true", "deleteWaypoint [group this, currentWaypoint (group this)]"];

true