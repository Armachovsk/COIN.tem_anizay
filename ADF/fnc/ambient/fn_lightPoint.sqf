/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_lightPoint
Author: Whiztler
Script version: 1.07

File: fn_lightPoint.sqf
**********************************************************************************
ABOUT
Creates a single lightpoint to light up objects (inside/outside). The function
defaults are ideal for adding lights to ARMA 2 watchtowers (Military Cargo Post)

INSTRUCTIONS:
Place an object or game logic on the map and put the following in the init:
[this, 0.2, 1] call ADF_fnc_lightPoint;

The function runs on every connected client and creates the objects locally.

REQUIRED PARAMETERS:
0. Object:      the object that requires the light source

OPTIONAL PARAMETERS:
1. Number:      Light brightness. 0.2 for dim light and 1.0 for very bright light
				Default: 0.3
2. Number:      Altitude light position offset from the object (in meters).
				Default: 2
3. Number:      X-axe offset in meters from the center position of the object.
				Default: 0
4. Number:      y-axe offset in meters from the center position of the object.
				Default: 0
				
EXAMPLES USAGE IN SCRIPT:
[_tower, 0.5, 1] call ADF_fnc_lightPoint;

EXAMPLES USAGE IN EDEN:
[this, 0.4, 1] call ADF_fnc_lightPoint;

DEFAULT/MINIMUM OPTIONS
[_obj] call ADF_fnc_lightPoint;

RETURNS:
Object (light srouce)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_lightPoint"};

if !hasInterface exitWith {};

// Init
params [
	["_object", objNull, [objNull]],
	["_brightness", 0.3, [0]],
	["_altitude_offset", 2, [0]],
	["_x_offset", 0, [0]],
	["_y_offset", 0, [0]]
];
private _anchorPoint = [_x_offset, _y_offset, _altitude_offset];

// Check valid vars
if (_brightness > 1) then {_brightness = 1;};
if (_altitude_offset > 99) then {_altitude_offset = 100;};

// Create the light source
private _lamp = "#lightpoint" createVehicleLocal [0,0,0];
_lamp setPos (getPosATL _object);

// Set the light source params
_lamp setLightBrightness _brightness;
_lamp setLightAmbient [1.0, 1.0, 0.5];
_lamp setLightColor [1.0, 1.0, 1.0];
_lamp setLightUseFlare true;

// Attache the light source to the object
_lamp lightAttachObject [_object, _anchorPoint];
if (_x_offset == 0 && _y_offset == 0) then {
	_lamp setPos [getPos _lamp # 0, getPos _lamp # 1, _altitude_offset];
};

// Return the light source
_lamp