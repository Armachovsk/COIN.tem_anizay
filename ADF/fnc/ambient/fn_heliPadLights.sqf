/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_heliPadLights
Author: Whiztler
Script version: 1.07

File: fn_heliPadLights.sqf
Diag: 0.263366 ms
**********************************************************************************
ABOUT
Creates (runway) lights around a helipad. Works for both square and circular heli
pads (auto detect). Medivac helipads get red lights and the letter 'H' will be lit
up. 

INSTRUCTIONS:
Place a helipad on the map. in the init put:
[this] call ADF_fnc_heliPadLights;

REQUIRED PARAMETERS:
0. Object:      The helipad object

OPTIONAL PARAMETERS:
1. String:      Helipad light color options:
                - "blue"
                - "red"
                - "yellow"
                - "white"
                - "green" (default)

EXAMPLES USAGE IN SCRIPT:
[_hPad, "white"] call ADF_fnc_heliPadLights;

EXAMPLES USAGE IN EDEN:
[this] call ADF_fnc_heliPadLights;

DEFAULT/MINIMUM OPTIONS
[_obj] call ADF_fnc_heliPadLights;

RETURNS:
Bool
*********************************************************************************/

if !isServer exitWith {};

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_heliPadLights"};

// init
params [
	["_helipad", objNull, [objNull]], 
	["_colour", "green", [""]], 
	["_lightClass", "", [""]]
];
private _position = getPosATL _helipad;
private _helipadClass = typeOf _helipad;

// Check vars
if !(_helipad isKindOf "HeliH") exitWith {[format ["ADF_fnc_heliPadLights - Incorrect helipad object passed: '%1'. Position: %2. Exiting", typeOf _helipad, getPosASL _helipad], true] call ADF_fnc_log; false};
if !(_colour in ["blue",  "red", "yellow", "white", "green"]) then {_colour = "green"; [format ["ADF_fnc_heliPadLights - incorrect color (%1) passed for helipad: %2. Defaulted to 'green'.", _colour, _helipad]] call ADF_fnc_log;};

switch _colour do {
	case "blue": {_lightClass = "Land_runway_edgelight_blue_f"};
	case "red": {_lightClass = "Land_Flush_Light_red_F"};
	case "yellow": {_lightClass = "Land_Flush_Light_yellow_F"};
	case "white": {_lightClass = "Land_runway_edgelight"};
	case "green";
	default	{_lightClass = "Land_Flush_Light_green_F"};
};

// Square helipad
if (_helipadClass in ["Land_HelipadRescue_F", "Land_HelipadSquare_F", "HeliHRescue", "Heli_H_Rescue"]) then {	
	private _lightDistance = 5.6;
	private _direction = getDir _helipad;
	if !(_helipadClass == "Land_HelipadSquare_F") then {
		_lightDistance = 5.5;
		_lightClass = "Land_Flush_Light_red_F";
	};
	
	private _createLight = {
		// In case the azimuth is larger than 0, ajust the helipadlights according to the helipad anchor position.
		// Inspriration taken from Shuko's moveObjects script
		params ["_position", "_lightPos", "_direction", "_lightClass"];
		
		if !(_direction == 0) then {
			private _distance = _position distance2D _lightPos;
			private _lightDir = ((_lightPos select 0) - (_position select 0)) atan2 ((_lightPos select 1) - (_position select 1));
			_lightDir = _lightDir + _direction;
			_lightPos = [(_position select 0) + (_distance * sin _lightDir), (_position select 1) + (_distance * cos _lightDir), 0];
		};
		
		private _light = createVehicle [_lightClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
		_light setPosATL _lightPos;
		_light modelToWorld _lightPos;	
		_light setVectorUp surfaceNormal position _light;
	};
	
	for "_i" from 0 to (_lightDistance * 2) step _lightDistance do {
		
		private _lightPos = [(((_position # 0) - _lightDistance) + _i), ((_position # 1) + _lightDistance), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
		
		private _lightPos = [(((_position # 0) - _lightDistance) + _i), ((_position # 1) - _lightDistance), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
		
		private _lightPos = [((_position # 0) - _lightDistance), (((_position # 1) - _lightDistance) + _i), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
		
		private _lightPos = [((_position # 0) + _lightDistance), (((_position # 1) - _lightDistance) + _i), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
	};
	
	if !(_helipadClass == "Land_HelipadSquare_F") then {	
		
		// MediVac helipad, Create lights for letter 'H'
		private _lightDistance = 0.7;
		
		for "_i" from 0 to (_lightDistance * 2) step (_lightDistance / 2) do {
			private _lightPos = [(_position # 0) + _lightDistance, ((_position # 1) - (_lightDistance * 1.5)) + (_i * 1.5), _position # 2];
			[_position, _lightPos, _direction, _lightClass] call _createLight;
			
			private _lightPos = [(_position # 0) - _lightDistance, ((_position # 1) - (_lightDistance * 1.5)) + (_i * 1.5), _position # 2];
			[_position, _lightPos, _direction, _lightClass] call _createLight;
		};
		
		private _lightPos = [(_position # 0) - (_lightDistance / 3), (_position # 1), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
		
		private _lightPos = [(_position # 0) + (_lightDistance / 3), (_position # 1), _position # 2];
		[_position, _lightPos, _direction, _lightClass] call _createLight;
	};
	
// Circular heli pad
} else {	
	private _lightDistance = 5.5;
	if (_helipadClass in ["Land_HelipadCircle_F", "HeliH"]) then {_lightDistance = 5.75;}; 
	for "_i" from 1 to 360 step 45 do {
		private _lightPos = [(_position # 0) + (sin (_i) * _lightDistance), (_position # 1) + (cos (_i) * _lightDistance), _position # 2];
		private _light = createVehicle [_lightClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
		_light setPosATL _lightPos;
		_light modelToWorld _lightPos;
		_light setVectorUp surfaceNormal position _light;
	};
};

true