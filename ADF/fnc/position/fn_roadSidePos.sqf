/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_roadSidePos
Author: Whiztler
Script version: 1.00

File: fn_roadSidePos.sqf
**********************************************************************************
ABOUT
Returns a random parking positing next to a road within a given radius. 

INSTRUCTIONS:
Call from script on the server. 

REQUIRED PARAMETERS:
0. Position:    Array position [X, Y, Z]. Initial search center position

OPTIONAL PARAMETERS:
1. Number:        Search radius in meters around the position. Default: 250
2. Number:        Road search radius in meters within the search radius results (1)
                  Default: 25 (meters)
3. Bool:          Clear the area (houses, fences, roacks, tree's etc)
                  - true (Default)
				  - false
4. Number/String: Radius to whichto clear the area
                  - 10 (meters, default)
				  - "AUTO" (needs a vehicle object or classname in 5.)
5. Object/String: The vehicle or object that will occupy the roadside position
                  - Object (default)
				  - "Classname" (vehicle classname)

EXAMPLES USAGE IN SCRIPT:
_parkingPos = [[2000,2000,0], 500, 100] call ADF_fnc_roadSidePos;
_pos = [getMarkerPos "parking", worldSize/2, 50, true, "AUTO", "RHS_AH64D"] call ADF_fnc_roadSidePos;

EXAMPLES USAGE IN EDEN:
[getMarkerPos "centerMarker", 500, 100] call ADF_fnc_roadSidePos;

DEFAULT/MINIMUM OPTIONS
_pos = [[worldSize/2,worldSize/2,0]] call ADF_fnc_roadSidePos;

RETURNS:
Array:  0.  position [X,Y,Z] (alongside the road)
        1.  direction (alongside the road)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_roadSidePos"};

// Init
params [
	["_position", [0,0,0], [[]], [3]], 
	["_radius", 250, [0]], 
	["_roadRadius", 25, [0]],
	["_clearArea", true, [false]],
	["_clearAreaRadius", 10, [0, ""]],
	["_clearAreaObject", objNull, [objNull, ""]],
	["_exit", false, [true]],
	["_roadPosition", [], [[]]],
	["_roadDirection", 0, [0]]
];

// Check nearby roads from new position
for "_i" from 0 to 300 do {
	private _searchPos = [(_position # 0) + (random _radius * sin (random 360)), (_position # 1) + (random _radius * cos (random 360)), 0];
	private _allRoads = _searchPos nearRoads _roadRadius;
	if (count _allRoads > 0) exitWith {
		private _road = selectRandom _allRoads;
		_roadPosition	= getPos _road;		
		_connectedRoads	= roadsConnectedTo _road;
		if (count _connectedRoads > 0) then {
			_connectedRoad	= _connectedRoads # 0;
			_roadDirection = _road getDir _connectedRoad;
		};
	};
	_roadRadius = _roadRadius + 15;
	if (_i isEqualTo 299) then {_exit = true;};
};

if _exit exitWith {[[0,0,0], 0]};

// Determine roadside position 6.5m is the sweet spot
private _roadSidePos = [(_roadPosition # 0) + (6.5 * sin (_roadDirection + 90)), (_roadPosition # 1) + (6.5 * cos (_roadDirection + 90)), 0];

// Clear the area of rocks, fences, houses, etc?
if _clearArea then {
	if (_clearAreaRadius isEqualType "") then {
		if (_clearAreaObject isEqualType "") then {
			_dummyObj = _clearAreaObject createVehicle [0,0,0];
			_dummyObj allowDamage false;
			_clearAreaRadius = ((0 boundingBox _dummyObj) # 2) + 2;
			[_dummyObj] call ADF_fnc_delete;
		} else {
			_clearAreaRadius = ((0 boundingBox _clearAreaObject) # 2) + 2;
		};
		
		if (_clearAreaRadius isEqualTo 0) then {_clearAreaRadius = 10};
	};
	{_x hideObjectGlobal true;} forEach nearestTerrainObjects [_roadSidePos, ["HOUSE", "CHURCH", "BUNKER", "RUIN", "FENCE", "WALL", "TREE", "SMALL TREE", "BUSH", "ROCK", "ROCKS", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "POWER LINES"], _clearAreaRadius, false];
};

// Return the result
[_roadSidePos, _roadDirection]