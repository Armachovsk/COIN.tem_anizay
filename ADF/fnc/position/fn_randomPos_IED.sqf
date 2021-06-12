/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_randomPos_IED
Author: Whiztler
Script version: 1.06

File: fn_randomPos_IED.sqf
**********************************************************************************
ABOUT
Returns a random (IED) position on (next to) a road within a given radius. The
function is used by the createIED module.

INSTRUCTIONS:
Call from script on the server. 

REQUIRED PARAMETERS:
0. Position:    Array position [X, Y, Z]

OPTIONAL PARAMETERS:
1. Integer:     Search radius in meters around the position. Default: 250
2. Integer:     Road search radius in meters within the search radius results (1)
                Default: 25

EXAMPLES USAGE IN SCRIPT:
private _pos = [[1000,1000,0], 500, 100] call ADF_fnc_randomPos_IED;

EXAMPLES USAGE IN EDEN:
myIED_AO = [getMarkerPos "centerMarker", 500, 100] call ADF_fnc_randomPos_IED;

DEFAULT/MINIMUM OPTIONS
_pos = [[worldSize/2, WorldSize/2, 0]] call ADF_fnc_randomPos_IED;

RETURNS:
Array:    0.  position X
          1.  position y
          2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_randomPos_IED"};

// Init
params [
	["_position", [], [[]], [3]], 
	["_radius", 250, [0]], 
	["_roadRadius", 25, [0]],
	["_roadPosition", [], [[]]],
	["_roadDirection", 0, [0]]
];

// Search position
_position = [(_position # 0) + (_radius * sin (random 360)), (_position # 1) + (_radius * cos (random 360)), 0];

// Check nearby raods from new position
private _allRoads = _position nearRoads _roadRadius;

// if road position found, use it else return [0,0,0]
if (count _allRoads > 0) then {		
	private _road = selectRandom _allRoads;
	_roadPosition	= getPos _road;		
	_connectedRoads	= roadsConnectedTo _road;
	if (count _connectedRoads > 0) then {
		_connectedRoad	= _connectedRoads # 0;
		_roadDirection = _road getDir _connectedRoad;
	};
} else {
	_roadPosition = [0,0,0];
	_roadDirection = 0;
};

// return the position + direction
[_roadPosition, _roadDirection]