/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_ambientFlare
Author: Whiztler
Script version: 1.05

File: fn_ambientFlare.sqf
**********************************************************************************
ABOUT:
Fires x number of flares within a given radius at a specified location. 

INSTRUCTIONS
Execute (spawn) from the server or HC

REQUIRED PARAMETERS:
0. Position     Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Number       Radius in meters from center position. Will spawn a flare at a
                random location within the specified radius. Default: 150
2. String       Color of the flare:
                "white" (default)
                "green"
                "red"
                "yellow"
3. Number       Number of flares to create. Default: 3. Maximum: 10

EXAMPLES USAGE IN SCRIPT:
["BaseMarker", 200, "Green", 5] spawn ADF_fnc_ambientFlare;

EXAMPLES USAGE IN EDEN:
[position this, 50, "red", 2] spawn ADF_fnc_ambientFlare;

DEFAULT/MINIMUM OPTIONS
[thisTrigger] spawn ADF_fnc_ambientFlare;

RETURNS:
a lightshow
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_ambientFlare"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 150, [0]],
	["_colour", "white", [""]],
	["_flaresNumber", 3, [0]]
];

// Check valid vars
if (_radius > 1000) then {_radius = 1000;};
if (_flaresNumber > 10) then {_flaresNumber = 10;};
if ((_colour != "white") && {(_colour != "green")} && {(_colour != "red")} && {(_colour != "yellow")}) then {_colour = "white"; if ADF_debug then {[format ["ADF_fnc_ambientFlare - incorrect color (%1) passed. Defaulted to 'white'.", _colour]] call ADF_fnc_log;}};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

private _flareClass = switch (toUpperANSI _colour) do {	
	case "WHITE": {"F_40mm_White"};
	case "GREEN": {"F_40mm_Green"};
	case "RED": {"F_40mm_red"};
	case "YELLOW": {"F_40mm_Yellow"};
	default	{"F_40mm_White"};
};

for "_i" from 1 to _flaresNumber do {
	_position set [2, 165 + (random 45)];	
	private _flare = createVehicle [_flareClass, _position, [], _radius, "CAN_COLLIDE"];
	playSound3D [format ["a3\missions_f_beta\data\sounds\Showcase_Night\%1",(selectRandom ["flaregun_1.wss","flaregun_2.wss","flaregun_3.wss","flaregun_4.wss"])], _flare];
	_flare setVelocity [0,0,-0.175];
	sleep (1 + random 2);
};