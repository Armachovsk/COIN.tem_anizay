/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_ambientAnimals
Author: BIS/Borivoj Hlava. Edited and adapted by Whiztler for ADF
Script version: 1.04

File: fn_ambientAnimals.sqf
**********************************************************************************
ABOUT
Based on the BIS Vanilla animals site function, this function creates defined or 
random animals at a given position. You can configure options such as which
animals, how many animals, radius, chacing distance and chance of spawning.
The caching distance is checked every few seconds to see if a player is near the
animal spawn location. If that is the case then the animals are spawned in. Once
no players are present in the area, the animals will be cached.

INSTRUCTIONS:
Execute (spawn) the function on the server.

REQUIRED PARAMETERS:
0. location:    Spawning location. Marker, object, trigger or position
                array [x, y, z]
				
OPTIONAL PARAMETERS:
1. Number       Type of animal(s) to spawn: 
                0 - Random farm animals (sheep, goats, poultry) (default)
                1 - Sheep
                2 - Goats
                3 - Poultry
                4 - Dogs				
2. Number       Number of animals to spawn. With 0 (default) the script will
                spawn between 3 and 15 animals randomly.       
3. Number       Radius in meters in which the animals will remain. Default: 25
4. Number       Caching/Spawningdistance in meters from players. Default: 500
5. Number       Chance of spawning the animal site:
			   50 - Any number is used to calculate the chance of spawning
			   false - With false used (default) the animals are always spawned.

EXAMPLES USAGE IN SCRIPT:
["myMarker", 1, 20, 50, 300, 60] spawn ADF_fnc_ambientAnimals;

EXAMPLES USAGE IN EDEN:
[position this, 0, 10, 30, 750, 75] spawn ADF_fnc_ambientAnimals; // using in a trigger

DEFAULT/MINIMUM OPTIONS
["myMarker"] spawn ADF_fnc_ambientAnimals;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (time < 180 || {ADF_extRpt || {ADF_debug}}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_ambientAnimals"};

// Init
params [
	["_pos", [0, 0, 0], ["", [], objNull, grpNull]],
	["_animals", 0, [0]],
	["_size", 0, [0]],
	["_radius", 25, [0]],
	["_caching", 500, [0]],
	["_go", true, [0, false]]
];	
private _class = "";
private _active = false;
private _group = [];
private _posName = _pos;

// Check chance
private _chance = 100;
private _random = random 99.99;
if (_go isEqualType 0) then {_chance = _go};
if (_random > _chance) exitWith {if (ADF_extRpt || {ADF_debug}) then {[format["ADF_fnc_ambientAnimals - Chance setting applied [%1 > %2] for %3 position. Exiting!", _random, _chance, _posName]] call ADF_fnc_log;}};

// Check animal(s)
switch _animals do {
	case 0: {_class = selectRandom [["Hen_random_F", "Hen_random_F", "Hen_random_F", "Hen_random_F", "Cock_random_F", "Hen_random_F"], "Goat_random_F", "Sheep_random_F", ["Hen_random_F", "Hen_random_F", "Hen_random_F", "Hen_random_F", "Cock_random_F", "Hen_random_F"], "Goat_random_F", "Sheep_random_F"]};
	case 1: {_class = "Sheep_random_F"};
	case 2: {_class = "Goat_random_F"};
	case 3: {_class = ["Hen_random_F", "Hen_random_F", "Hen_random_F", "Hen_random_F", "Cock_random_F", "Hen_random_F"]};
	case 4: {_class = ["Fin_random_F", "Alsatian_random_F"]};
	default {_class = -1};
};	

// Checks
if !(isServer) exitWith {["ADF_fnc_ambientAnimals - This function must be executed on the server. Exiting from this client!", true] call ADF_fnc_log;};
private _position = [_pos] call ADF_fnc_checkPosition;
if (_position isEqualTo [0,0,0]) exitWith {["ADF_fnc_ambientAnimals - invalid position [0,0,0] passed. Exiting!", true] call ADF_fnc_log;};
if (_class isEqualType 0) exitWith {[format ["ADF_fnc_ambientAnimals - invalid animal type (%1) passed. Exiting!", _animals], true] call ADF_fnc_log;};
if (_radius > 1000) then {[format ["ADF_fnc_ambientAnimals - Radius too large (%1m). Adjusted to 1000m.", _radius]] call ADF_fnc_log; _radius = 1000;};
if (_caching > 2000) then {[format ["ADF_fnc_ambientAnimals - Caching distance too large (%1m). Adjusted to 2000m.", _caching]] call ADF_fnc_log; _caching = 2000;};
if (_size == 0) then {_size = [3, 15] call BIS_fnc_randomNum};

// Start the caching-spawning loop
while {true} do {
	private _playersClose = false;	
	private _distance = 0;
	// Check the distance of each player to the animal site radius
	{
		_distance = _position distance _x;
		if (_distance < _radius) exitWith {_playersClose = true;};
	} forEach allPlayers select {((getPosATL _x) select 2) < 5};		
	
	if !(_active) then {		
		if (_playersClose) then {				
			private _count = 0;		
			private _animal = "";
			while {_count < _size} do {				
				private _spawnClass = if (_class isEqualType "") then {_class} else {selectRandom _class};
				private _spawnPos = [_position, _radius] call ADF_fnc_randomPos;
				_animal = createAgent [_spawnClass, _spawnPos, [], 0, "NONE"];
				_animal setDir (random 360);
				_group pushBack _animal;
				_count = _count + 1;
				sleep 0.035;
			};
			//hint format ["spawned: %1 %2\nradius: %3\ncaching: %4",_size, _animal,  _radius, _caching]; // debug - spawning animals
			_active = true
		};			
	} else {		
		if (_distance > (_caching + _caching/10)) then {
			//hint format ["caching: %1", _group]; // debug - caching animals
			[_group] call ADF_fnc_delete;
			_group = [];
			_active = false;
		};		
	};

	sleep (2 + random 2);		
};