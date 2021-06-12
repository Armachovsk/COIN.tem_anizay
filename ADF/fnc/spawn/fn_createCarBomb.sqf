/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Car Bomb
Author: Whiztler
Script version: 1.20

File: fn_createCarBomb.sqf
**********************************************************************************
ABOUT
This function creates a vehicle (default is Fuel Track) in a predefined radus or at
a marker/trigger. The vehicle acts as a car bomb. The function aligns the vehicle
with the road and creates a trigger that will set off the bomb when a target is
near.

INSTRUCTIONS:
Execute from the server.

REQUIRED PARAMETERS:
0. Position:    Marker or Trigger name (eclipse/rectangle marker). The vehicle
                will be placed in the marker/trigger area on /next to a random
                road. If the marker is an icon (size 1 x 1  or smaller) then then
                vehicle will be created on that exact position.
                You may also pass a position array [X, Y, Z] for precise spawning.

OPTIONAL PARAMETERS:
1. Side:        Side that activates the trigger: west, east or independent
                Default: west
2. Integer:     Trigger area (radius) in meters. Default: 50
3. String:      Vehicle class. Default: "C_Van_01_fuel_F"

EXAMPLES USAGE IN SCRIPT:
["carBombMarker", west, 10, "C_Offroad_luxe_F"] call ADF_fnc_createCarBomb;

EXAMPLES USAGE IN EDEN:
[bombTrigger, west, 15] call ADF_fnc_createCarBomb; // Default vehicle is used.

DEFAULT/MINIMUM OPTIONS
["carBombMarker"] call ADF_fnc_createCarBomb;

RETURNS:
Object (vehicle)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createCarBomb"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]], 
	["_side", west, [east]], 
	["_radius", 50, [0]], 
	["_vehicleClass", "C_Van_01_fuel_F", [""]],
	["_direction", 0, [0]]
];

if (_position isEqualType "") then {
	if ((getMarkerSize _position # 0) > 1) then {
		private _searchRadius = (((getMarkerSize _position) # 0) + ((getMarkerSize _position) # 1)) / 2;
		
		// select a random position within the marker area
		_position = [getMarkerPos _position, _searchRadius, random 360] call ADF_fnc_randomPos;
		
		// Find a road position within the search results
		private _searchPosition = [_position, 100, 150] call ADF_fnc_randomPos_IED;
		_position = _searchPosition # 0;
		_direction = _searchPosition # 1;
		
		// create offset position
		private _position_X_offset = (_position # 0) + (4.5 * sin (_direction + 90));
		private _position_Y_offset = (_position # 1) + (4.5 * cos (_direction + 90));
		_position = [_position_X_offset, _position_Y_offset, 0];
	} else {
		_direction	= markerDir _position;
		_position = [_position] call ADF_fnc_checkPosition;
	};		
} else {
	if (_position isEqualType objNull) then {
		_direction = getDir _position;			
	} else {
		_direction = random 360
	};
	_position = [_position] call ADF_fnc_checkPosition;
};

// Create the vehicle
private _vehicle = createVehicle [_vehicleClass, _position, [], 0, "CAN_COLLIDE"];
_vehicle setDir _direction;
_vehicle lock 2;

// Create the trigger
private _trigger = createTrigger ["EmptyDetector", _position, false];
_trigger setTriggerActivation [str _side, "PRESENT", false];
_trigger setTriggerArea [_radius, _radius, 0, false];
_trigger setTriggerTimeout [0, 0, 0, false];
_trigger setTriggerStatements [
	"{vehicle _x in thisList && isPlayer _x && ((getPosATL _x) select 2) < 5} count allUnits > 0;", 
	"[thisTrigger] call ADF_fnc_carBombDetonate; [thisTrigger] call ADF_fnc_delete;", 
	""
];

// Debug
if ADF_debug then {
	_position = [_position] call ADF_fnc_checkPosition;
	private _marker = createMarker [format ["mCB%1", diag_tickTime], _position];
	_marker setMarkerSize [_radius, _radius];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerColor "ColorRED";
	_marker setMarkerType "empty";
};

// return the vehicle
_vehicle