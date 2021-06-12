/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_sensor
Author: Whiztler
Script version: 1.06

File: fn_sensor.sqf
**********************************************************************************
ABOUT
This is an alternative for triggers for conditions that do NOT need to be checked
every frame or every 0.5 seconds.

INSTRUCTIONS:
The function checks distance players to an object/marker/vehicle.  You'll need to
define the array of units/players/vehicles it needs to check against.
Execute (call) from the server

REQUIRED PARAMETERS:
0: Array:       Array to check against. E.g. allPlayers
1: Position:    Marker, object, trigger or position array [x,y,z] to check distance
                to the units/vehicles provided in the 0: Array.
            
OPTIONAL PARAMETERS:
2. Number:      Sensor radius in meters. Default: 500
3. Number:      Check interval in seconds. Default: 2
4. Bool:        Persistent:
                - true: is persistent (Default)
                - false: not persistent (run once)
5. String:      Code to execute (spawn) when the conditions are met (true).
                E.g. "hint 'The sensor is active';"
                Default = "". 
6. String:      Code to execute (spawn) when the conditions are not met (false).
                E.g. "hint 'The sensor is deactivated';"
                Default = "". 

EXAMPLES USAGE IN SCRIPT:
[{alive _x} count AllUnits, myObject, 500, 5] call ADF_fnc_sensor;

EXAMPLES USAGE IN EDEN:
[allUnits, "AOmarker", 1000, 5] call ADF_fnc_sensor;

DEFAULT/MINIMUM OPTIONS
[allUnits, "AOmarker"] call ADF_fnc_sensor;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_sensor"};

if !isServer exitWith {};

// Init
params [
	["_array", [], [[]]],
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 500, [0]],
	["_pause", 2, [0]],
	["_persistent", true, [false]],
	["_code_activation", "", [""]],
	["_code_deactivation", "", [""]]
];

// Check distance loop
waitUntil {
	private _distance = [_array, _position, _radius] call ADF_fnc_checkClosest;
	private _exit = false;	
	
	if (_distance < _radius) then {		
		if (_code_activation != "") then {[] spawn (call compile format ["%1", _code_activation])};			
		if !(_persistent) then {
			_exit = true;
			_pause = 0;
		} else {
			waitUntil {
				sleep (_pause + random 1);
				_distance = [_array, _position, _radius] call ADF_fnc_checkClosest;
				_distance > _radius
			};
			if (_code_deactivation != "") then {[] spawn (call compile format ["%1", _code_deactivation])};
		};			
	};		
	
	sleep (_pause + random 1);
	_exit
};

// Debug reporting
if (ADF_debug || ADF_extRpt)  then {[format ["ADF_fnc_sensor: sensor %1 deactivated", _p]] call ADF_fnc_log};