/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_deleteEntities
Author: Whiztler
Script version: 1.03

File: fn_deleteEntities.sqf
**********************************************************************************
ABOUT
This function removes pre-defined entities (objects, AI units, vehicles) within a
given range (circular). The function does not delete static map objects.

When using west/east/independent as side, it does not delete empty vehicles that
have been placed on the map using the editor. Even when it is a vehicle belonging
to that specific side.

INSTRUCTIONS:
Execute (call) from the server

REQUIRED PARAMETERS:
0. Position:    Center position. Marker, object, trigger or position array [x,y,z]
1. Number:      radius in meters (number). The larger the range the more expensive the
                function is. Try keep < 50. Maximum is 1500.
2. Array:       Types of entities to delete. E.g.
                - ["ALL"] // All objects/entities
                - ["MAN"] 
                - ["MAN","CAR","APC","TANK","StaticWeapon"]                  

OPTIONAL PARAMETERS:
3. Side         Side of objects/units/vehicles to delete (west, east, civilian,
                independent). Use civilian in case of static objects.
                Default: civilian
4. Bool:        How to delete the entity. In case of destroy setDamage is set to 1:
                - true - delete the entity (default)
                - false - destroy the entity              

EXAMPLES USAGE IN SCRIPT:
["myMarker", 25, ["ALL"], west, false] call ADF_fnc_deleteEntities;

EXAMPLES USAGE IN EDEN:
[myObject, 50, ["MAN"], east, true] call ADF_fnc_deleteEntities;

DEFAULT/MINIMUM OPTIONS
[position player, 10, ["CAR"]] call ADF_fnc_deleteEntities;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_deleteEntities"};

// init
params [
	["_position", "", ["", [], objNull, grpNull, locationNull]],
	["_radius", 50, [0]],
	["_type", ["MAN"], [[]]],
	["_side", civilian, [east]],
	["_delete", true, [false]]
];

// Check valid vars
if (_radius > 1500) then {_radius = 1500;};

// Chek the position
_position = [_position] call ADF_fnc_checkPosition;

// Delete the objects
if (_side == civilian) then {	
	{
		if (_delete) then {
			[_x] call ADF_fnc_delete;
		} else {
			_x setDamage 1
		};
	} forEach (_position nearEntities [_type, _radius]);
} else {
	{
		if (side _x == _side) then {
			if (_delete) then {
				[_x] call ADF_fnc_delete;
			} else {
				_x setDamage 1
			};
		};	
	} forEach (_position nearEntities [_type, _radius]);
};

true