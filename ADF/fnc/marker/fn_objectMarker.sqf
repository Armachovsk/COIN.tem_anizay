/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_objectMarkerArray
Author: Whiztler
Script version: 1.19

File: fn_objectMarkerArray.sqf
Diag: 0.164015 ms
**********************************************************************************
ABOUT
Creates gray bounding box box markers for editor placed or scripted objects. They
then appear as map objects.

INSTRUCTIONS:
The function changes the marker layer. If you have custom marker (e.g.) text
markers, you can re-apply them with the reMarker function (ADF_fnc_reMarker)
Call from script on the server.

REQUIRED PARAMETERS:
0. Object:  Editor placed or scripted object that requires the map marker.

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
[myBunker] call ADF_fnc_objectMarker;

EXAMPLES USAGE IN EDEN:
[this] call ADF_fnc_objectMarker;

DEFAULT/MINIMUM OPTIONS
[myBunker] call ADF_fnc_objectMarker;

RETURNS:
Marker
*********************************************************************************/

if !isServer exitWith {};

if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_objectMarker"};


// Init
private _diag_time = diag_tickTime;
params [
	["_object", objNull, [objNull]],
	["_simpleObject", false, [true]]
];	

// Check valid vars
if (_object isKindOf "CAManBase") exitWith {[format ["ADF_fnc_objectMarker - '%1' seems to be a player or AI (%2). Exiting", _object, typeOf _object], true] call ADF_fnc_log; false};

// Get the object position and box model size
private _position = getPosATL _object;
private _box = (0 boundingBoxReal _object) # 1; 
_box resize 2;

// Create the marker
private _marker = createMarker [format ["mObj%1%2", floor(random 9999), floor(_position # 0)], _position];
_marker setMarkerShape "RECTANGLE";
_marker setMarkerSize _box;
_marker setMarkerBrush "SolidFull";
_marker setMarkerColor "ColorGrey";
_marker setMarkerDir (getDir _object);

// Convert the object to a "simple object"?
if (_simpleObject) then {
	[_x] call BIS_fnc_replaceWithSimpleObject;
	if ADF_debug then {
		[format ["ADF_fnc_objectMarkerArray - Applying marker for object: %1 and converting to a simple object.", _x]] call ADF_fnc_log;
		[format ["ADF_fnc_objectMarker - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log;
	};
} else {
	if ADF_debug then {
		[format ["ADF_fnc_objectMarkerArray - Applying marker for object: %1", _x]] call ADF_fnc_log;
		[format ["ADF_fnc_objectMarker - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log;
	};
};

_marker