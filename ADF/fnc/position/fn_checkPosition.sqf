/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_checkPosition
Author: Whiztler
Script version: 1.12

File: fn_checkPosition.sqf
Diag: 0.0133 ms
**********************************************************************************
ABOUT
This function is used by scripts and other functions to determine the type of 
position. Locations such as a marker, an object, a vehicle, a group, a unit or
player or simply a position array [X, Y, Z] can be passed
The function returns the position as an array [X, Y, Z].

INSTRUCTIONS:
n/a

REQUIRED PARAMETERS:
0. Position     Marker, object, trigger or position array [x, y, z]

OPTIONAL PARAMETERS:
n/a

EXAMPLE
_position = [group player] call ADF_fnc_checkPosition;

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_checkPosition"};

// init
params [
	 ["_position", [0, 0, 0], ["", objNull, grpNull, locationNull, [], true, {}, 0]], // [] and 0 to handle position
	 ["_result", [], [[]]]
];

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_checkPosition - pre-check position: %1", _position]] call ADF_fnc_log};

// Check the location type and produce a position array
switch (typeName _position) do {
	
	case "STRING":	{
		if (_position in allMapMarkers) then {
			_result = getMarkerPos _position;
		} else {
			[format ["ADF_fnc_checkPosition - ERROR! Position %1 (string) is not a valid marker.", _position], true] call ADF_fnc_log};
		};
	
	case "OBJECT":	{_result = getPosATL _position};
	
	case "ARRAY":	{
		if (_position isEqualTypeAll 0) then {
			switch (count _position) do {
				case 2: {_result = [(_position # 0), (_position # 1), 0]};
				case 3: {_result =+ _position};
				default {[format ["ADF_fnc_checkPosition - ERROR! Position %1 (array) is not a valid position array.", _position], true] call ADF_fnc_log};
			};
		} else {
			_result = [0, 0, 0];
			[format ["ADF_fnc_checkPosition - ERROR! Position %1 (array) is not a valid position array.", _position], true] call ADF_fnc_log;
		};
	};
	
	case "GROUP":	{_result = getPosATL (leader _position)};
	
	case "LOCATION":	{_result = position _position};
	
	case "SCALAR";
	case "BOOL";
	case "CODE";
	default			{
		_result = [0, 0, 0];
		[format ["ADF_fnc_checkPosition - ERROR! Incorrect position passed (%1) Defaulting to [0, 0, 0] (lower edge of the map).", _position]] call ADF_fnc_log;
	};
};

// Return the checked position: array [X, Y, Z]
_result