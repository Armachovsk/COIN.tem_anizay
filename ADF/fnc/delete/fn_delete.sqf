/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_delete
Author: Whiztler. Based on the delete function of CBA by Rommel.
Script version: 1.05

File: fn_delete.sqf
Diag: 0.0133 ms
**********************************************************************************
ABOUT
Deletes vehicles, AI units, objects, groups, triggers, arrays of objects, markers,
etc.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Anything:		Group, array, marker, object. Anything else returns false

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[[veh1, veh2, veh3]] call ADF_fnc_delete;
[[group1, veh1, trigger]] call ADF_fnc_delete;

EXAMPLES USAGE IN EDEN:
[["marker1", vehicle1]] call ADF_fnc_delete;

DEFAULT/MINIMUM OPTIONS
[myObject] call ADF_fnc_delete;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_delete"};

// Init
params [
	["_deleteMe", objNull, ["", objNull, grpNull, locationNull, [], true, {}, 0]]
];

switch (typeName _deleteMe) do {

	case "STRING" :		{
	
		if (_deleteMe in allMapMarkers) then {
			deleteMarker _deleteMe;
			true
		} else {
			[format ["ADF_fnc_delete - ERROR! Passed %1 (string) is not a valid marker.", _deleteMe],true] call ADF_fnc_log;
			false
		};		
	};
	
	case "OBJECT" :		{
		if (vehicle _deleteMe != _deleteMe) then {
			unassignVehicle _deleteMe;			
		} else {
			if ({_x != _deleteMe} count (crew _deleteMe) > 0) then {
				(group _deleteMe) call ADF_fnc_delete;
			};
		};
		deleteVehicle _deleteMe;
		true
	};
	
	case "GROUP" :		{
		if (count (units _deleteMe) > 0 ) exitWith {
			(units _deleteMe) call ADF_fnc_delete;
			_deleteMe call ADF_fnc_delete;
			true
		};		
		{deleteWaypoint _x} forEach (wayPoints _deleteMe);
		deleteGroup _deleteMe;
		true
	};
	
	case "LOCATION" :	{
		deleteLocation _deleteMe;
		true
	};
	
	case "ARRAY" :		{
		{_x call ADF_fnc_delete} forEach _deleteMe;
		true
	};
	
	case "SCALAR"; 
	case "BOOL"; 
	case "CODE"; 	
	default {false};
};