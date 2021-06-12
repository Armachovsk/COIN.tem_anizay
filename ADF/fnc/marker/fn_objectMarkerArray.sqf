/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_objectMarkerArray
Author: Whiztler
Script version: 1.17

File: fn_objectMarkerArray.sqf
Diag: 4.40789 ms (23 objects)
**********************************************************************************
ABOUT
Creates gray bounding box box markers for editor placed or scripted objects. They
then appear as map objects.

INSTRUCTIONS:
The function changes the marker layer. If you have custom marker (e.g.) text
markers, you can re-apply them with the reMarker function (ADF_fnc_reMarker)
Call from script on the server.

REQUIRED PARAMETERS:
0. Array:       Array of classnames that need a bounding box marker on the map.
1. Position:    Center position, object, marker or trigger

OPTIONAL PARAMETERS:
2. Number:      Radius in meters to scan for objects to mark. Default: 100
                Maximum is 1500.
3. Bool:        Does the object need to be converted to a 'simple object':
                - true - the object needs to be converted to a simple object.
                - false - No need for simple object conversion. (Default).

EXAMPLES USAGE IN SCRIPT:
_array = ["ClassName", "ClassName", "ClassName"]; // Array of classnames of objects to mark on the map
[_array, "MyMarker", 150, true] call ADF_fnc_objectMarkerArray;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[_array, "MyMarker"] call ADF_fnc_objectMarkerArray;

RETURNS:
Bool
*********************************************************************************/

if !isServer exitWith {};

// Reporting
if (ADF_debug || ADF_extRpt || time < 10) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_objectMarkerArray"};


// init
private _diag_time = diag_tickTime;
params [
	["_objectsArray", [], [[]]],
	["_position", "", ["", [], objNull, grpNull, locationNull]],
	["_radius", 100, [0]],
	["_simpleObject", false, [true]]
];

// Check valid vars
if (_radius > 1500) then {_radius = 1500};

// populate objects array
private _allObjects = nearestObjects [[_position] call ADF_fnc_checkPosition, _objectsArray, _radius, true];
if ADF_debug then {
	[format ["ADF_fnc_objectMarkerArray - Classnames to mark: %1", _objectsArray]] call ADF_fnc_log;
	[format ["ADF_fnc_objectMarkerArray - Array of nearest objects found: %1", _allObjects]] call ADF_fnc_log
};

// create the bounding box markers
{[_x, _simpleObject] call ADF_fnc_objectMarker} forEach _allObjects;

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_objectMarkerArray - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log};

true