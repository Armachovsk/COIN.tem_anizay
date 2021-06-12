/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_calcTravelTime
Author: Whiztler
Script version: 1.05

File: fn_calcTravelTime.sqf
Diag: 0.0407 ms
**********************************************************************************
ABOUT
Calculates travel time between two positions. Travel time calculation is based
on Km/hour.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Position:    Start position. Marker, object, trigger or position array [x,y,z]
1. Position:    End position. Marker, object, trigger or position array [x,y,z]
2. Number:      Estimated travel speed in Km/hr

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
[_veh, "destinationMarker", 275] call ADF_fnc_calcTravelTime;

EXAMPLES USAGE IN EDEN:
[myHelicopter, this, 60] call ADF_fnc_calcTravelTime;

DEFAULT/MINIMUM OPTIONS
[myHelicopter, this, 60] call ADF_fnc_calcTravelTime;

RETURNS:
Array:          0. hours
                1. minutes
                2. seconds
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_calcTravelTime"};

params [
	["_position_1", "", ["", [], objNull, grpNull, locationNull]],
	["_position_2", "", ["", [], objNull, grpNull, locationNull]],
	["_velocity", 50, [0]]
];

if !(_position_1 isEqualType []) then {_position_1 = [_position_1] call ADF_fnc_checkPosition};
if !(_position_2 isEqualType []) then {_position_2 = [_position_2] call ADF_fnc_checkPosition};

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_calcTravelTime: Distance = %1 Meters", round (_position_1 distance2D _position_2)]] call ADF_fnc_log};

// Distance calculate in meters per seconds. Based on meters and Km/hr.
private _seconds = (_position_1 distance2D _position_2) / (_velocity * 0.277777);

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_calcTravelTime: Seconds per meter: %1", _seconds]] call ADF_fnc_log};

// Convert seconds into 24-hour time format.
private _hours = floor (_seconds / 3600);
_seconds	= _seconds mod 3600;
private _minutes = floor (_seconds / 60);
_seconds	= _seconds mod 60;
_seconds	= floor _seconds;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_calcTravelTime: Hour(s): %1 -- Minute(s): %2 -- Second(s): %3", _hours, _minutes, _seconds]] call ADF_fnc_log};

// Return travel time
[_hours, _minutes, _seconds]