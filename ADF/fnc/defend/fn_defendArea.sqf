/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_defendArea
Author: Whiztler
Script version: 1.27

File: fn_defendArea.sqf
**********************************************************************************
ABOUT
This is a defend/garrison/militarize script based on CBA_fnc_taskDefend by Rommel.
The script garrisons units in empty buildings, static weapons and vehicle turrets.
Units that have not been garrisoned will go on patrol in the assigned area.

INSTRUCTIONS:
Execute (spawn) from the server or HC
If you do not wish to populate static turrets and vehicle turrent then make sure
to lock them in the editor or via script: lock 2

REQUIRED PARAMETERS:
0: Group:       An existing group to populate building positions and turrets
1. Position:    Marker / Trigger / Object / Array position [X, Y, Z]

OPTIONAL PARAMETERS:
2. Number:      Radius in meters to search for buildings/turrets to populate
                with units (default is 50 meters).
3. Number:      Max number of positions within a building to be occupied.
                Default: -1 (all positions, no maximum)
4. Bool:        Ungarrisoned units will go on patrol. Do they need to search
                buildings?
                - true: search buildings
                - false: do not search buildings (default)
5. Bool:        Roof top and top floor positions get prioritized for garrison?
                - true (default)
                - false

EXAMPLES USAGE IN SCRIPT:
[_grp, "GarrisonMarker", 500, 5, true] call ADF_fnc_defendArea;

EXAMPLES USAGE IN EDEN:
[group this, position this, 100] call ADF_fnc_defendArea;

DEFAULT/MINIMUM OPTIONS
[_grp, MyObject] call ADF_fnc_defendArea;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_defendArea"};

// init
private _diag_time = diag_tickTime;
params [
	["_group", grpNull, [grpNull]], 
	["_position", "", ["", [], objNull, grpNull]], 
	["_radius", 50, [0]], 
	["_maxOccupyPositions", -1, [0]], 
	["_searchBuildings", false, [true]], 
	["_rooftopPositions", true, [false]],
	["_garrisonArray", [], [[]]],
	["_index", 0, [0]],
	["_cycleCount", 0, [0]]	
];
private _units = units _group;
private _unitsCount = count _units;

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_defendArea - Empty group passed: %1. Exiting", _group]] call ADF_fnc_log; grpNull};
if (_radius < 5) then {_radius = 5;};
if (_radius > 1000) then {_radius = 1000;};
if (_maxOccupyPositions == 0) then {_maxOccupyPositions = 1;};

// Check the position (marker, array, etc.)
_position = [_position] call ADF_fnc_checkPosition;

// Populate an array with suitable garrison buildings
private _allBuildings	= [_position, _radius, _maxOccupyPositions] call ADF_fnc_buildingPositions;

// Populate an array with turret positions (statics and empty vehicles)
private _allTurrents = [_position, _radius] call ADF_fnc_getTurrets;

if ADF_debug then {
	[format ["ADF_fnc_defendArea - Group: %1 | # units: %2", _group, _unitsCount]] call ADF_fnc_log;
	[format ["ADF_fnc_defendArea - Building positions found: %1", (count _allBuildings)]] call ADF_fnc_log;
	[format ["ADF_fnc_defendArea - Turrets found: %1", (count _allTurrents)]] call ADF_fnc_log;
};

_group enableAttack false;

// Modified CBA_fnc_taskDefend by Rommel et all	
{		
	// INIT	
	// Turret count - deduct 1 on each cycle
	private _turretCount = if (_allTurrents isEqualTo []) then {-1} else {(count _allTurrents) - 1};
	// Cycle counter
	_cycleCount = _cycleCount + 1;
	// Set the garrison var to FALSE
	_x setVariable ["ADF_garrSet", false];
	
	// Populate static weapons and vehicles with turrets first
	if (_turretCount > -1)  then {
		// Movve unit into the turret and remove the turret from the array
		_x assignAsGunner (_allTurrents # _turretCount);
		_x moveInGunner (_allTurrents # _turretCount);
		[_x] call ADF_fnc_setTurretGunner;
		_allTurrents resize _turretCount;
		
		// Set the the garrison var to TRUE
		_x setVariable ["ADF_garrSet", true];
		// Increase the success counter
		_index = _index + 1;
		
	// All turrets populated, populate building positions
	} else {
		if (count _allBuildings > 0) then {
			// Init building position array
			private _buildingPosition = [];
			
			// Select a random building from the building array
			private _building = selectRandom _allBuildings;
			private _garrisonPosition = _building getVariable ["ADF_garrPos", []];
			
			// Create a spread when the nr of buildings > number of units
			if ((count _allBuildings) >= _unitsCount) then {_allBuildings = _allBuildings - [_building]};
			
			if ((count _garrisonPosition) > 0) then {
			
				// In case there are multiple building positions within the building, check for high altitude positions for rooftop placement
				if ((count _garrisonPosition) > 1) then {
					// 60 percent chance for rooftops / toop floor else select a random free position
					if (_rooftopPositions && {(random 1) > 0.4}) then {
						private _ap = [_garrisonPosition, ADF_fnc_altitudeDescending] call ADF_fnc_positionArraySort;
						_buildingPosition	= _ap # 0;							
					} else {
						_buildingPosition = selectRandom _garrisonPosition;
					};
				} else {
					_buildingPosition = _garrisonPosition # 0;
				};

				// Remove the populated position from the array
				_garrisonPosition	= _garrisonPosition - [_buildingPosition];				
				
				// Check if there are positions left within the building else remove the building from the buildings array. Set the building varaibles accordingly.
				if (_garrisonPosition isEqualTo []) then {
					_allBuildings = _allBuildings - [_building];
					_building setVariable ["ADF_garrPos", []];
					_building setVariable ["ADF_garrPosAvail", false];
				} else {
					_building setVariable ["ADF_garrPos", _garrisonPosition];
				};
				
				// Unit now has a random position within a random building. Pass it the the setGarrison function so thsat the unit will move into the selected position.
				[_x, _buildingPosition, _building] spawn ADF_fnc_setGarrison;
				
				// Set the ADF_garrSet for the unit and add his position to an array that is used for headless client management.
				_x setVariable ["ADF_garrSet", true];
				_garrisonArray append [[_x, _buildingPosition]];
				// Debug reporting
				if ADF_debug then {[format ["ADF_fnc_defendArea - Unit garrisson array: %1", _garrisonArray]] call ADF_fnc_log};
				// Increase the success counter
				_index = _index + 1;
			
			} else {if ADF_debug then {[format ["ADF_fnc_defendArea - No positions found for unit %1 (nr. %2)", _x, _cycleCount]] call ADF_fnc_log}};
			
			
		};
	};
	_x allowDamage true; // hack - ADF 2.22
} forEach _units;


// Clean up the building variables
[_allBuildings] spawn {
	sleep 30; // wait 1/2 min before removing the stored building positions as other groups might occupy the same building.
	params ["_allBuildings"];
	{_x setVariable ["ADF_garrPos", nil]} forEach _allBuildings;
};

// Set HC loadbalancing variables if a HC is active
if (ADF_HC_connected) then {
	_group setVariable ["ADF_hc_garrison_ADF", true];
	_group setVariable ["ADF_hc_garrisonArr", _garrisonArray];

	// Debug reporting
	if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_defendArea - ADF_hc_garrisonArr set for group: %1 -- array: %2", _group, _garrisonArray]] call ADF_fnc_log};
};

// Non garrisoned units patrol the area	
waitUntil {_unitsCount == _cycleCount};
if (_index < _unitsCount) then {[_index, _group, _position, _radius, _searchBuildings] spawn ADF_fnc_defendAreaPatrol};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_defendArea - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log};