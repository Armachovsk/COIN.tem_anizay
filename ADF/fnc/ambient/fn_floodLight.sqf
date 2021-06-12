/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_floodLight
Author: Whiztler
Script version: 1.07

File: fn_floodLight.sqf
Diag: 0.299312 ms
**********************************************************************************
ABOUT
Creates a floodlight attached to a position or an object. Adds additional light
source to the floodlight for ambient effect.

Templates:
[Tower, 0.2, 2.25, 0, 0] call ADF_fnc_floodLight; // cargo Tower first floor
[Tower, 0.2, 4.8, 0, 0] call ADF_fnc_floodLight; // cargo Tower Second floor
[Tower, 0.2, 7.4, 0, 0] call ADF_fnc_floodLight; // cargo Tower Third floor

[hq, 0.2, -1, 0, 1] call ADF_fnc_floodLight; // cargo HQ 
[hq, 0.2, -1, 3, -3] call ADF_fnc_floodLight; // cargo HQ  

INSTRUCTIONS:
Place an object or game logic on the map and put the following in the init:
[this, 0.2, 1] call ADF_fnc_floodLight;
The function runs on every connected client and creates the objects locally.

REQUIRED PARAMETERS:
0. Object:      The object that the floodlight is attached to.

OPTIONAL PARAMETERS:
1. Number:      Light brightness. 0.2 for dim light and 1.0 for very bright
				light. Default: 0.3 
2. Number:      Altitude light position offset from the object. In meters.
				Default: 1
3. Number:      X-axe offset (meters) from the center position of the object
				Default: 0
4. Number:      Y-axe offset (meters) from the center position of the object
				Default: 0
				
EXAMPLES USAGE IN SCRIPT:
[this, 0.1, 2.2, -1, 1.5] call ADF_fnc_floodLight; // CargoHouse

EXAMPLES USAGE IN EDEN:
[this, 0.7, 1] call ADF_fnc_floodLight;

DEFAULT/MINIMUM OPTIONS
[_tower] call ADF_fnc_floodLight;

RETURNS:
Object (floodlight object)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_floodLight"};

if !hasInterface exitWith {};

// Init
params [
	["_object", objNull, [objNull]],
	["_brightness", 0.2, [0]],
	["_altitudeOffset", 1, [0]],
	["_x_offset", 0, [0]],
	["_y_offset", 0, [0]]
];

// Check valid vars
if (_brightness > 1) then {_brightness = 1;};
if (_altitudeOffset > 1) then {_altitudeOffset = 1;};

// Create the physical light source
private _lamp = "Land_floodLight_F" createVehicleLocal [0,0,0];
_lamp setPos (getPosASL _object);
_lamp attachTo [_object, [_x_offset, _y_offset, _altitudeOffset]];
_lamp setVectorDirAndUp [[1, 0, 0],[0, -0.9, 0]];

if ADF_debug then {
	private _dummy = "Sign_Sphere100cm_F" createVehicleLocal (getPosASL _lamp);
	private _marker = createMarker [format ["L_%1%2", _lamp, random 999], getPos _lamp];
	_marker setMarkerSize [1, 1];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_dot";
	_marker setMarkerColor "ColorWhite";
	_marker setMarkerText "L";
};	

// Create the simulated light source
private _light = "#lightpoint" createVehicleLocal [0,0,0];
_light setPos (getPosASL _lamp);
_light setLightBrightness _brightness;
_light setLightAmbient [1.0, 1.0, 0.5];
_light setLightColor [1.0, 1.0, 1.0];
_light lightAttachObject [_lamp, [0,0,-.1]];

// Return the light object
_lamp