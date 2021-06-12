/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_buildingPositions
Author: Whiztler
Script version: 1.25

File: fn_buildingPositions.sqf
Diag: 0.037 ms
**********************************************************************************
ABOUT
The buildingPostions function creates and populates an array of buildings within
the given radius. The buildings are checked for being enter-able and having
garrison positions.
The building positions (array) are stored in: ADF_garrPos via setVariable

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0: position:    Marker, object, trigger or position array [x, y, z]

OPTIONAL PARAMETERS:
1: number:      radius in meters. Default: 100
2: number:      Maximum number of positions in the building
                Default: -1 (no maximum)

EXAMPLES USAGE IN SCRIPT:
_buildings = [_garrisonPos, 150, 4] call ADF_fnc_buildingPositions;

EXAMPLES USAGE IN EDEN:
_buildings = ["myMarker", 75, 2] call ADF_fnc_buildingPositions;

DEFAULT/MINIMUM OPTIONS
_buildings = ["my_AO"] call ADF_fnc_buildingPositions;

RETURNS:
Array (Enter-able buildings with building positions)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_buildingPositions"};

// init	
params [
	["_position", [], ["", [], objNull, grpNull]], 
	["_radius", 100, [0]], 
	["_maxBuildingPositions", -1, [0]]
];

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Create the building array
private _allBuildings = nearestObjects [_position, ["Building", "House"], _radius];
if (_allBuildings isEqualTo []) exitWith {if ADF_debug then {[format ["ADF_fnc_buildingPositions - ERROR! No buildings found with the %1 radius from the %2 position. Exiting.", _radius , _position], true] call ADF_fnc_log}; []};

// Debug marker for each building found (with and without available positions)
if ADF_debug then {
	{
		private _marker = createMarker [format ["p_%1%2", _x, random 999], getPos _x];
		_marker setMarkerSize [1, 1];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "hd_dot";
		_marker setMarkerColor "ColorWhite";
		_marker setMarkerText "B";
	} forEach _allBuildings;
};	

// Check if building can be entered. Then check if the building has garrison positions. If no position available, remove the building from the array
{
	if (isObjectHidden _x || {!(_x getVariable ["ADF_garrPosAvail", true])})  then {
		_allBuildings = _allBuildings - [_x];
	} else {
		if ((count (_x getVariable ["ADF_garrPos", []])) == 0) then {
			_x setVariable ["ADF_garrPos", []];
			
			private _isAccessible = [_x] call BIS_fnc_isBuildingEnterable;
			private _buildingPositions = [_x, _maxBuildingPositions] call BIS_fnc_buildingPositions;				
			
			if (!_isAccessible || {(_buildingPositions isEqualTo [])}) then {
				_allBuildings = _allBuildings - [_x]
			} else {
			
			// If debug mode is enabled then create debug markers 
			if (ADF_debug || {ADF_debug_bPos}) then {
				[format ["ADF_fnc_buildingPositions - Positions gathered (max: %1) for building '%2' via BIS_fnc_buildingPositions: %3", _maxBuildingPositions, _x, count _buildingPositions]] call ADF_fnc_log;
				if (ADF_debug_bPos) then {
					{
						_v = createVehicle ["Sign_Sphere100cm_F", [_x # 0, _x # 1, (_x # 2) + 1], [], 0, "NONE"];
						private _marker = createMarker [format ["p_%1%2", _x # 0, random 999 ], _x];
						_marker setMarkerSize [.5, .5];
						_marker setMarkerShape "ICON";
						_marker setMarkerType "hd_dot";
						_marker setMarkerColor "ColorYellow";
					} forEach _buildingPositions;
				};
			};				
			
			_x setVariable ["ADF_garrPos", _buildingPositions];
			_x setVariable ["ADF_garrPosAvail", true];
			
			};
		};		
	};
	
} forEach _allBuildings;

// return the building array
_allBuildings