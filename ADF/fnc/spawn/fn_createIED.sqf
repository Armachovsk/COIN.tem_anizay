/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create IED('s)
Author: Whiztler
Script version: 1.24

File: fn_createIED.sqf
**********************************************************************************
ABOUT:
This function creates IED's. There are three way's of creating IED's:

1.  Create a single IED at a marker position (icon marker, no radius)
2.  Create multiple IED's from an array with markers. E.g.:
    ["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"]
3.  Create random IED's in a rectangular or eclipse sized maker.

INSTRUCTIONS:
Place marker(s) on the map (editor or scripted).
Execute from the server.

REQUIRED PARAMETERS:
0. Position:     This can be:
                 - Marker icon for direct placed. The IED is created within the
                   given radius position
                 - Array of markers.
                 - Marker name (string) of a eclipse/rectangle marker. The IED will
                   be created in the marker area randomly.
				 - true - when entere true, the function will create given number
				   of IED's from the map center across the map.

OPTIONAL PARAMETERS:
1. Side:         Side that activates the IED trigger: west, east or independent
                 Default: west
2. Integer:      Number of IED's. Only change when using in combination with a
                 eclipse/rectangle marker. Default: 1
3. Integer:      Random position placement radius in meters. Default: 100
4. Integer:      Radius to search for suitable road position. Default: 250
5. Integer:      Road offset in meters. The is the width of the road. Default: 4.5
6. Bool:		 VBED:
                 - true, create vehicle for VBED
                 - false (default)
7. String/Array: VBED vehicle class. Either as string or as array of strings.
                 Default: "C_Van_01_fuel_F" // Small fuel truck

EXAMPLES:

EXAMPLES USAGE IN SCRIPT:
* Icon marker on the map, 1 IED on marker position:
["IEDposition"] call ADF_fnc_createIED;

* Array of marker positions, triggered by independent:
[["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"], independent] call ADF_fnc_createIED;

* Full map
[true, west, 15] call ADF_fnc_createIED;

* Full map VBED's
[true, west, 10, 100, 250, 4.5, true, "C_Van_01_box_F"] call ADF_fnc_createIED;

EXAMPLES USAGE IN EDEN:
* Icon marker on the map, 1 IED on marker position:
["IEDposition"] call ADF_fnc_createIED;

* Array of marker positions, triggered by independent:
[["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"], independent] call ADF_fnc_createIED;

* Eclipse marker on the map, 10 IED's randomly within the marker area:
["IEDposition", west, 10] call ADF_fnc_createIED;

* Icon marker on the map, 1 IED on marker position triggered by East
["IEDposition", east] call ADF_fnc_createIED;

DEFAULT/MINIMUM OPTIONS
["IedPos"] call ADF_fnc_createIED;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createIED"};

private _diag_time = diag_tickTime;

private _createIED = {
	// init
	params ["_position", "_activationSide", "_numberOfIED", "_radius", "_roadRadius", "_roadPosOffset", "_vbed", "_vbedClass"];
	#define MAX_TRIES 3000
	
	// Check the location position
	_position = [_position] call ADF_fnc_checkPosition;
	
	private _iedObjectClass	= selectRandom ["Land_PlasticBucket_01_closed_F", "Land_GasTank_01_yellow_F", "Land_GasTank_01_khaki_F", "Land_GasTank_01_blue_F", "FlexibleTank_01_sand_F", "Land_Wreck_Car3_F", "Land_GarbagePallet_F", "Land_CanisterPlastic_F", "Land_Sack_F", "Land_JunkPile_F", "Land_BarrelTrash_F", "Land_GarbageBarrel_01_F"];
	//private _iedObjectClass = selectRandom ["IEDLandBig_F", "IEDUrbanBig_F", "IEDLandSmall_F", "IEDUrbanSmall_F"];
	// private _iedObjectClass = "Land_PlasticBucket_01_closed_F"; // debug
	private _resultPosition = [];
	private _roadPosition	= [];
	private _roadDirection = 0;
	private _objectDirection = (random 360);

	// Search for IED locations within the search radius.
	for "_i" from 1 to MAX_TRIES do { 
		_resultPosition = [_position, _radius, _roadRadius] call ADF_fnc_randomPos_IED;
		_roadPosition = _resultPosition # 0;
		_roadDirection = _resultPosition # 1;
		// Exit when a suitable position has been found
		if !(_roadPosition isEqualTo [0,0,0]) exitWith {
			if ADF_debug then {[format ["ADF_fnc_createIED - position on road: %1", _roadPosition]] call ADF_fnc_log};
			true
		};
	};
	
	// Debug position found
	if ADF_debug then {private _dummy = createVehicle ["Sign_Arrow_Direction_Green_F", _roadPosition, [], 0, "CAN_COLLIDE"]; _dummy setDir _roadDirection;};
	
	// Create offset position
	private	_offset_roadDirection = _roadDirection + 90;
	private _offset_roadPos_x = (_roadPosition # 0) + (_roadPosOffset * sin (_roadDirection + 90));
	private _offset_roadPos_y = (_roadPosition # 1) + (_roadPosOffset * cos (_roadDirection + 90));	
	
	// VBED
	if _vbed then {
		if (_vbedClass isEqualType []) then {
			_iedObjectClass = selectRandom _vbedClass;
		} else {
			_iedObjectClass = _vbedClass;
		}; 
		_objectDirection = _offset_roadDirection - 90;
	};	
		
	// Create the IED (random object)
	private _iedObject = createVehicle [_iedObjectClass, [_offset_roadPos_x, _offset_roadPos_y, 0], [], 0, "CAN_COLLIDE"];
	
	// Debug information
	if (ADF_debug || {ADF_debug_IED}) then {
		[format ["ADF_fnc_createIED - IED object created: %1", _iedObject]] call ADF_fnc_log;

		private _dummy = createVehicle ["Sign_Arrow_Cyan_F", [_offset_roadPos_x, _offset_roadPos_y, 1], [], 0, "CAN_COLLIDE"];
		_dummy enableSimulationGlobal false;

		private _m = createMarker [format ["IEDclass_%1", round (random 9999)], [_offset_roadPos_x, _offset_roadPos_y, 0]];
		_m setMarkerSize [0, 0];
		_m setMarkerShape "ICON";
		_m setMarkerType "mil_dot";
		_m setMarkerColor "ColorBlack";
		_m setMarkerText format ["%1", _iedObjectClass];
	};
	
	// Disguise the IED
	_iedObject setDir _objectDirection;
	if !_vbed then {_iedObject enableSimulationGlobal false};	
	private _disguiseOffset = switch _iedObjectClass do {
		case "Land_Wreck_Car3_F" : {[[0.1, 0, 0], -.30]};
		case "Land_CanisterPlastic_F" : {[[0.08, 0, 0], -.05]};
		case "Land_Sack_F" : {[[0, 0.1, 0.01], -.05]};
		case "Land_JunkPile_F";
		case "Land_GarbagePallet_F" : {[[0, 0, 0], -.20]};
		case "Land_GarbageBarrel_01_F" : {[[0.1, 0, 0], -.10]};
		case "FlexibleTank_01_sand_F";
		case "Land_BarrelTrash_F" : {[[0.1, 0, 0], -.08]};
		case "Land_GasTank_01_khaki_F";
		case "Land_GasTank_01_blue_F";
		case "Land_GasTank_01_yellow_F" : {[[0.1, 0, 0], -.025]};
		case "Land_PlasticBucket_01_closed_F" : {[[0.1, 0, 0], -.01]};
		default {[[0, 0, 0], -.05]}
	};
	if !_vbed then {
		_iedObject setVectorUp _disguiseOffset # 0;
		_iedObject setPosATL [getPosATL _iedObject select 0, getPosATL _iedObject select 1, _disguiseOffset # 1];
	};
	
	// Create the trigger
	private _trigger = createTrigger ["EmptyDetector", _roadPosition];
	_trigger setTriggerActivation [_activationSide, "PRESENT", false];
	_trigger setTriggerArea [4, 3, _offset_roadDirection, true];
	_trigger setTriggerTimeout [0, 0, 0, false];
	_trigger setTriggerStatements [
		"{vehicle _x in thisList && isPlayer _x && ((getPosATL _x) select 2) < 5} count allUnits > 0;", 
		"[format ['ADF_fnc_createIED - IED ACTIVATED by: %2 (Trigger: %1)', thisTrigger, name vehicle _x]] call ADF_fnc_log; [thisTrigger] call ADF_fnc_iedDetonate; deleteVehicle thisTrigger;", 
		""
	];	
	
	// Create a debug marker if debug is enabled
	if (ADF_debug || {ADF_debug_IED}) then {		
		[format ["ADF_fnc_createIED - Trigger created: %1 (Activated by: %2)", _trigger, _activationSide]] call ADF_fnc_log;
		private _m = createMarker [format ["trig%1", round (random 9999)], _roadPosition];
		_m setMarkerSize [4, 3];
		_m setMarkerShape "RECTANGLE";
		_m setMarkerColor "ColorRED";
		_m setMarkerDir _offset_roadDirection;
		_m setMarkerType "empty";
		_m setMarkerText format ["trig:%1", _trigger];
	};	
	
	// return the IED object
	_iedObject	
};

// Init
params [
	["_position", "", ["", [], true]], 
	["_activationSide", west, [east]], 
	["_numberOfIED", 1, [0]], 
	["_radius", 100, [0]], 
	["_roadRadius", 260, [0]], 
	["_roadPosOffset", 4.5, [0]],
	["_vbed", false, [true]],
	["_vbedClass", "C_Van_01_fuel_F", [[], ""]]
];

// Check if the passed location is a position array or marker
if (_position isEqualType []) then {
	{
		[_x, str _activationSide, _numberOfIED, _radius, _roadRadius, _roadPosOffset, _vbed, _vbedClass] call _createIED;
	} forEach _position;
} else {
	if (_position isEqualType true) then {
		// Entire map. Use map center + map size as area.
		private _wordSize = worldSize;
			
		for "_i" from 1 to _numberOfIED do {
			private _radius = selectRandom [_worldSize, _worldSize * 0.8, _worldSize * 0.4];	
			private _position = [[_worldSize / 2, _worldSize / 2, 0], _radius] call ADF_fnc_randomPos;
			[_position, str _activationSide, _numberOfIED, _radius, _roadRadius, _roadPosOffset, _vbed, _vbedClass] call _createIED;
		};
	} else {	
		if ((getMarkerSize _position # 0) > 0 && {_numberOfIED > 1}) then {
			private "_i";
			private _searchRadius = (((getMarkerSize _position) # 0) + ((getMarkerSize _position) # 1)) / 1.25;
			
			for "_i" from 1 to _numberOfIED do {		
				private _px = [getMarkerPos _position, _searchRadius, random 360] call ADF_fnc_randomPos;
				[_px, str _activationSide, _numberOfIED, _radius, _roadRadius, _roadPosOffset, _vbed, _vbedClass] call _createIED;
			};
		} else {
			[_position, str _activationSide, _numberOfIED, _radius, _roadRadius, _roadPosOffset, _vbed, _vbedClass] call _createIED;
		};
	};
};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createIED - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log};

// Return bool
true