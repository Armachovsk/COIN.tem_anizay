/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Spawn on Demand
Author: Whiztler
Script version: 1.25

File: fn_SOD.sqf
**********************************************************************************
ABOUT
Spawn On Demand (SOD) spawns infantry units in a given radius. You can have foot
mobiles patrol the area or defend (garrison) the area. The SOD zone is activated
when a player is within a predefined distance of the zone.

CUSTIMIZATION
Spawn of Demand (SOD) spawns infantry units in a predefined radius. The function
offers a lot of options for customization:
- SOD zone(s) can be placed by markers or objects. You can define the SOD zone
  activation radius.
- The SOD zone sensor position does not have to be the same as the unit spawn
  position.
- You can use SOD on existing units (Eden placed or scripted) or SOD can create
  the units for you.
- Units can go on foot patrol, garrison (defend a position) or both. In case
  garrison, the units will occupy empty turrets of unlocked vehicle/static
  weapons and occupy defence positions in buildings.
- You can define group size (2, 4, 8) and how many foot patrol and garrison
  groups SOD should spawn.

Once players move out of the zone activation area, the infantry units will be
cached. Killed units will not re-spawn/un-cache. 
Upon reactivation, the units resume their pre-existing patrol/garrison duties.
Note: airborne players cannot activate a SOD zone.

You can pass 4 functions / snippets of code:
Code 1: Code/Function is called for each group member when they spawn for the
        first time.
Code 2: Code/Function is called for the group as a whole when the group spawns for
        the first time.
Code 3: Code/Function is executed (spawn) on each zone re-activation except the
        first time activation.
Code 4: Code/Function is spawned on the first time activation (first run).
        Code is run prior to the creation of the group(s). 

INSTRUCTIONS:
Execute (spawn) from the server or headless client.

REQUIRED PARAMETERS:
0: Position:      position. Scan/Sensor position. Marker or Object.
                  Does not have to be the same as the spawn position. See this as
                  the center of the trigger area.			  

OPTIONAL PARAMETERS:
1: Position:      position. Spawn position. Marker, Object or [x, y, z] array.
                  "" empty string: same position as scan position (default)
2. Side:          west, east or independent. Default: east
3. Bool/Group:    Use on pre-placed group of units or create new group(s):
                  group - use on existing group (execute from group)
                  false - create new group (default)
4. Integer/Array: Group size In case of create new group):
                  2     - Team
                  4     - Fire Team (default)
                  8     - Squad
			      array - [# patrol, # defend]
5. Integer/Array: Group count. How many groups to spawn/create:
                  1     - Number of groups to spawn. Min 1 (default), maximum 50.
			      array - [# patrol groups, # defend groups]
6. Integer/Array: Radius in meters. If a ellipse/rect marker is used then the 
                  marker = radius. Default: 500 meters.
			      array - [radius patrol groups, radius defend groups]
7. Integer/Bool:  Activation. How far out do units spawn / cache in meters:
                  integers - Number in meters. In case of auto then 1.75 x radius.
                  true - Auto (default)
8. String:        Patrol, garrison/defend, both?.
                  "patrol" - group(s) will patrol the given radius (default)
                  "defend" - group(s) garrison buildings within the given radius
				  "all"    - Patrol and defend. Use array options to define group size
				             group count and radius for each patrol / defend group.
9. String:        Code 1. Code to execute on each unit of the group (e.g. a function).
                  Default = "". Code is CALLED. Each unit of the group is passed
                  (_this select 0) to the code/fnc.
10. String:       Code 2. Code to execute on the group (e.g. a function). Default = "".
                  Code is CALLED. The group is passed (_this select 0) to the code/fnc.
11. String:       Code 3. Code to execute on each activation. Code is executed (spawn)
                  on the client that executes the SOD function (hc or server).
                  Default = "". Passed information:
                  _this select 0 - spawn position
                  _this select 1 - sensor position
                  _this select 2 - array of SOD groups
                  _this select 3 - sensor name/variable/Marker name
                  _this select 4 - spawn position name/variable/Marker name
12. String:       Code 4. Code to execute on first-run activation. Code is spawned
                  on the client that executes the SOD function (hc or server).
                  Default = "". Passed information: 
                  _this select 0 - spawn position
                  _this select 1 - sensor position
                  _this select 2 - sensor name/variable/Marker name
                  _this select 3 - spawn position name/variable/Marker name
                  _this select 4 - Size of the sensor area
13. Bool:		  Function debugging/testing:
                  false - switch off (default)
                  true - switch on debugging

EXAMPLES USAGE IN SCRIPT (CREATE GROUP):
["myMarker", "spawnPosition", west, false, 4, 1, 250, true, "patrol", "MyUnitFunction", "MyGroupFunction", "runEachTime", "runFirstTime"] spawn ADF_fnc_SOD;

EXAMPLES USAGE IN SCRIPT (CREATE GROUP) with both patrol and defend:
["myMarker", "spawnPosition", west, false, [4, 8], [1, 3], [250, 100], true, "all", "MyUnitFunction", "MyGroupFunction"] spawn ADF_fnc_SOD;

EXAMPLES USAGE IN SCRIPT (EXISTING GROUP):
["myMarker", "", east, _myGroup, 4, 1, 250, true, "patrol", "MyUnitFunction"] spawn ADF_fnc_SOD;

EXAMPLES USAGE IN EDEN:
0 = [position this, position this, east, false, 8, 2, 750, "patrol"] spawn ADF_fnc_SOD;
0 = [position this, "spawnPos", east, false, [4, 8], [2 ,1], [750, 200], 1000, "all"] spawn ADF_fnc_SOD; // multiple groups, patrol and defence

EXAMPLES USAGE IN EDEN PRE-PLACED GROUP
0 = [position this, position this, east, group this, 8, 2, 750, "patrol"] spawn ADF_fnc_SOD;

DEFAULT/MINIMUM OPTIONS
["myMarker"] spawn ADF_fnc_SOD;

EXAMPLE CODE FOR FUNCTIONS ON FIRST RUN AND EACH ACTIVATION
My_fnc_FirstZoneActivation = {
	params ["_spawnPos", "_sensorPos"];
	hint parseText format ["zone aactivated!<br/><br/>Sensor position: %1<br/><br/>Units will spawn at: %2", _sensorPos, _spawnPos];
};

My_fnc_eachZoneActivation = {
	params ["_spawnPos", "_sensorPos", "_allGroups"];
	hint parseText format ["zone aactivated!<br/><br/>Sensor position: %1<br/><br/>Units will spawn at: %2", _sensorPos, _spawnPos];
	{_x setBehaviour "COMBAT";} forEach _allGroups;
};

RETURNS:
element of surprise and increased mission performance
*********************************************************************************/

// Init
params [
	["_sensorPos", [0, 0, 0], ["", objNull, locationNull, []]],
	["_spawnPos", "", ["", objNull, []]],
	["_side", east, [west]],
	["_groupExist", false, [true, grpNull]],
	["_groupSize", 4, [0, []]],
	["_groupCount", 1, [0, []]],
	["_radius", 500, [0, []]],
	["_activation", true, [0, false]],
	["_activity", "patrol", [""]],
	["_code_1", "", [""]],
	["_code_2", "", [""]],
	["_code_3", "", [""]],
	["_code_4", "", [""]],
	["_SOD_test", false, [true]], // Debug
	["_SOD_groups", [], [[]]],
	["_SOD_firstRun", true, [false]],
	["_SOD_execute", true, [false]],
	["_SOD_active", false, [true]],
	["_createGroup", false, [true]],
	["_group", grpNull, [grpNull]],
	["_spawnPosition", [0,0,0], [[]]],
	["_sensorPosition", [0,0,0], [[]]],
	["_posCheck", true, [false]],
	["_groupSizePatrol", 0, [0]],
	["_groupSizeDefend", 0, [0]],
	["_groupCountPatrol", 0, [0]],
	["_groupCountDefend", 0, [0]],
	["_radiusPatrol", 0, [0]],
	["_radiusDefend", 0, [0]],
	["_largestRadius", 0, [0]]
];

// Reporting
if (time < 300 || {_SOD_test || {ADF_extRpt || {ADF_debug}}}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_SOD"};
private _sensorPosName = _sensorPos;
private _spawnPosName = _spawnPos;

// Set vars and check valid vars
if (_sensorPos isEqualType "" && {!(_sensorPos in allMapMarkers)}) exitWith {[format ["ADF_fnc_SOD - %1 does not appear to be a valid SOD marker. Exiting", _sensorPos], true] call ADF_fnc_log;};
if (_spawnPos isEqualType "" && {!(_spawnPos == "") && {!(_spawnPos in allMapMarkers)}}) exitWith {[format ["ADF_fnc_SOD - %1 does not appear to be a valid SOD marker. Exiting", _spawnPos], true] call ADF_fnc_log;};
_sensorPosition = [_sensorPos] call ADF_fnc_checkPosition;
if (_sensorPosition isEqualTo [0,0,0]) exitWith {["ADF_fnc_SOD - invalid sensor position [0,0,0] passed. Exiting!", true] call ADF_fnc_log;};
if (_spawnPos isEqualType "" && {_spawnPos == ""}) then {_spawnPosition = _sensorPosition; _spawnPosName = _sensorPosName; _posCheck = false};
if _posCheck then {_spawnPosition = [_spawnPos] call ADF_fnc_checkPosition};
if (_spawnPosition isEqualTo [0,0,0]) exitWith {["ADF_fnc_SOD - invalid spawn position [0,0,0] passed. Exiting!", true] call ADF_fnc_log;};
if (_groupExist isEqualType false) then {_createGroup = true;} else {_group = _groupExist;}; // Exisiting group is a group not a bool!
if (_radius isEqualType []) then {_largestRadius = selectMax _radius; _radiusPatrol = _radius # 0; _radiusDefend = _radius # 1;} else {_largestRadius = _radius; _radiusPatrol = _radius; _radiusDefend = _radius;};
if (_activation isEqualType true && {_activation isEqualTo true}) then {_activation = _largestRadius * 1.75};
if (_activation isEqualType true && {_activation isEqualTo false}) then {_activation = _largestRadius};
if (_activation < _largestRadius) then {_activation = _largestRadius};
if (_groupSize isEqualType []) then {_groupSizePatrol = _groupSize # 0; _groupSizeDefend = _groupSize # 1;} else {_groupSizePatrol = _groupSize; _groupSizeDefend = _groupSize;};
if (_groupCount isEqualType []) then {_groupCountPatrol = _groupCount # 0; _groupCountDefend = _groupCount # 1;} else {_groupCountPatrol = _groupCount; _groupCountDefend = _groupCount;};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_SOD - incorrect code 1 (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_SOD - incorrect code 2 (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_code_3 != "") then {if (isNil _code_3) then {if ADF_debug then {[format ["ADF_fnc_SOD - incorrect code 3 (%1) passed. Defaulted to ''.", _code_3]] call ADF_fnc_log;}; _code_3 = "";}};
if (_code_4 != "") then {if (isNil _code_4) then {if ADF_debug then {[format ["ADF_fnc_SOD - incorrect code 4 (%1) passed. Defaulted to ''.", _code_4]] call ADF_fnc_log;}; _code_4 = "";}};

// Function testing
if _SOD_test then {
	if (	(_sensorPos isEqualType "" && {((getMarkerSize _sensorPos) # 0) < 2}) || !(_sensorPos isEqualType "")) then {
		_positionMarker = createMarker [format ["posMarker_%1",diag_tickTime], _sensorPosition];
		_positionMarker setMarkerShape "ELLIPSE";
		_positionMarker setMarkerColor "ColorRed";
		_positionMarker setMarkerSize [_radiusPatrol, _radiusPatrol];
		_positionMarker setMarkerAlpha 0.5;	
	} else {
		_sensorPos setMarkerColor "ColorRed";
	};
	private _actSize = _activation + (_activation/10);
	_activationMarker = createMarker [format ["testMarker_%1",diag_tickTime], _sensorPosition];
	_activationMarker setMarkerShape "ELLIPSE";
	_activationMarker setMarkerColor "ColorYellow";
	_activationMarker setMarkerSize [_actSize, _actSize];
	_activationMarker setMarkerAlpha 0.75;
};

// Un-chache chached groups upon SOD zone activation
private _SOD_unCache = {
	params ["_SOD_groups"];
	
	{
		_units = units _x;
		{
			_x allowDamage true;	
			_x enableSimulationGlobal true;
			_x hideObjectGlobal false;			
			_x enableAI "FSM";				
		} forEach _units;		
	} forEach _SOD_groups;
	if isServer then {_SOD_groups call ADF_fnc_addToCurator} else {_SOD_groups remoteExecCall ["ADF_fnc_addToCurator", 2]};
};

// Execution of passed functions/code upon first-run/activation/deactivation (depending on situation)
private _SOD_execCode = {
	// init
	params [
		"_code_3",
		["_run_code_3", false, [true]],		
		"_code_4",
		["_run_code_4", false, [true]],
		"_spawnPosition",
		"_sensorPosition",
		"_SOD_groups",
		["_SOD_test", false, [true]],
		"_sensorPosName",
		"_spawnPosName",
		"_sensorSize"
	];
	
	// Code 3 - on each zone re-activation
	if (_run_code_3 && {_code_3 != ""}) then {
		[_spawnPosition, _sensorPosition, _SOD_groups, _sensorPosName, _spawnPosName]  spawn (call compile format ["%1", _code_3]);
		// Debug reporting
		if (_SOD_test || {ADF_debug}) then {[format ["ADF_fnc_SOD - spawned code 3 (%1)", _code_3]] call ADF_fnc_log};	
	};

	// Code 4 - on first time zone activation (first run)
	if (_run_code_4 && {_code_4 != ""}) then {
		[_spawnPosition, _sensorPosition, _sensorPosName, _spawnPosName, _sensorSize] spawn (call compile format ["%1", _code_4]);
		// Debug reporting
		if (_SOD_test || {ADF_debug}) then {[format ["ADF_fnc_SOD - spawned code 4 (%1)", _code_4]] call ADF_fnc_log};		
	};
};

// Add the group to Zeus
private _addToZeus = {
	params ["_toAdd"];
	if isServer then {[_toAdd] call ADF_fnc_addToCurator} else {[_toAdd] remoteExecCall ["ADF_fnc_addToCurator", 2]};
};

// If SOD is executed for an existing group then cache the group untill SOD zone activation
if !_createGroup then {
	{
		_x allowDamage false;
		_x enableSimulationGlobal false;
		_x hideObjectGlobal true;			
		_x disableAI "FSM";	
	} forEach units _group;
	
	// Add the group to Zeus
	[_group] call _addToZeus;	
};

// Start the SOD zone monitor loop. This will create a loop that will check every 2-4 seconds if a player has entered
// the SOD zone. If a player has entered the SOD zone then SOD will spawn (or if previously activate) un-cache the infantry
// groups and give them their pre-divined directives (patrol/garrison). Once all players have left the SOD zone, all groups
// (minus dead units) will be cached. If all SOD zone enemy units have been killed then the monitor loop will exit.

while {_SOD_execute} do {
	private _playersClose = false;	

	// Check the distance of each player to the SOD radius
	{if ((_sensorPosition distance _x) < _activation) exitWith {_playersClose = true}} forEach allPlayers select {((getPosATL _x) select 2) < 5};	
	
	// CHeck if we need to spawn SOD zone, cache the SOD zone or do nothing
	if !_SOD_active then {	
		if _playersClose then {
			// A player is within the activation radius so let's create/activate the infantry group(s). EIther patrol or garrison/defend or both (all)
			if _SOD_firstRun then {
				// First time activation
				switch _activity do {
				
					///// PATROL
					case "patrol": {
						if (_code_4 != "") then {["", false, _code_4, true, _spawnPosition, _sensorPosition, _SOD_groups, _SOD_test, _sensorPosName, _spawnPosName, _largestRadius] call _SOD_execCode};
						// Define number of waypoints based on radius size
						private _waypoints = switch true do {
							case (_radiusPatrol < 100): {6};
							case (_radiusPatrol > 99 && _radiusPatrol < 500): {5};
							case (_radiusPatrol > 499 && _radiusPatrol < 1500): {4};
							case (_radiusPatrol > 1500): {3};
							default {4};
						};					
						// Create new group or run on existing/pre-placed group
						if (_createGroup) then {
							// First run, let's create the infantry foot mobile group(s) and assign orders
							for "_i" from 1 to _groupCountPatrol do {
								private _weaponSquad = if (random 100 < 75) then {false} else {true};
								private _patrolSearch = if (random 100 < 60) then {false} else {true};	
								_group = [_spawnPosition, _side, _groupSizePatrol, _weaponSquad, _radiusPatrol, _waypoints, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, _patrolSearch, _code_1, _code_2] call ADF_fnc_createFootPatrol;
								_SOD_groups  pushBack _group;								
							};
							[_SOD_groups] call _addToZeus;	
						// Execute the patrol function on an exisiting group
						} else {
							// First uncache the cached existing group
							[[_group]] call _SOD_unCache;
							private _patrolSearch = if (random 100 < 60) then {false} else {true};	
							[_group, _spawnPosition, _radiusPatrol, _waypoints, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, _patrolSearch] call ADF_fnc_footPatrol;
							_SOD_groups pushBack _group;
						};
					};
					
					///// DEFEND
					case "defend": {
						if (_code_4 != "") then {["", false, _code_4, true, _spawnPosition, _sensorPosition, _SOD_groups, _SOD_test, _sensorPosName, _spawnPosName, _largestRadius] call _SOD_execCode};				
						//Create new group or run on existing/pre-placed group
						if (_createGroup) then {				
							// First run, let's create the infantry foot mobile group(s) and assign orders
							for "_i" from 1 to _groupCountDefend do {	
								private _patrolSearch = if (random 100 < 60) then {false} else {true};
								private _weaponSquad = if (random 100 < 75) then {false} else {true};
								_group = [_spawnPosition, _side, _groupSizeDefend, _weaponSquad, _radiusDefend, _patrolSearch, _code_1, _code_2, 4, selectRandom [false, true]] call ADF_fnc_createGarrison;
								_SOD_groups  pushBack _group;
							};
							[_SOD_groups] call _addToZeus;	
						// Execute the defend function on an exisiting group
						} else {
							// First uncache the cached existing group
							[[_group]] call _SOD_unCache;
							private _patrolSearch = if (random 100 < 60) then {false} else {true};
							[_group, _spawnPosition, _radiusDefend, 4, _patrolSearch, selectRandom [false, true, false]] call ADF_fnc_defendArea;
							_SOD_groups pushBack _group;
						};
					};
					
					///// ALL (PATROL & DEFEND)
					case "all";
					default {
						if (_code_4 != "") then {["", false, _code_4, true, _spawnPosition, _sensorPosition, _SOD_groups, _SOD_test, _sensorPosName, _spawnPosName, _largestRadius] call _SOD_execCode};
						// Define number of waypoints based on radius size
						private _waypoints = switch true do {
							case (_radiusPatrol < 100): {6};
							case (_radiusPatrol > 99 && _radiusPatrol < 500): {5};
							case (_radiusPatrol > 499 && _radiusPatrol < 1500): {4};
							case (_radiusPatrol > 1500): {3};
							default {4};
						};					
						// Create new group or run on existing/pre-placed group
						if (_createGroup) then {
							// First run, let's create the infantry foot mobile group(s) and assign orders
							for "_i" from 1 to _groupCountPatrol do {
								private _weaponSquad = if (random 100 < 75) then {false} else {true};
								private _patrolSearch = if (random 100 < 60) then {false} else {true};	
								_group = [_spawnPosition, _side, _groupSizePatrol, _weaponSquad, _radiusPatrol, _waypoints, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, _patrolSearch, _code_1, _code_2] call ADF_fnc_createFootPatrol;
								_SOD_groups  pushBack _group;
								};
							for "_i" from 1 to _groupCountDefend do {	
								private _patrolSearch = if (random 100 < 60) then {false} else {true};
								private _weaponSquad = if (random 100 < 75) then {false} else {true};
								_group = [_spawnPosition, _side, _groupSizeDefend, _weaponSquad, _radiusDefend, _patrolSearch, _code_1, _code_2, 4, selectRandom [true, false]] call ADF_fnc_createGarrison;
								_SOD_groups pushBack _group;
							};
							[_SOD_groups] call _addToZeus;	
						// The "all" selection does not work on existing groups. Throw an error
						} else {
							["ADF_fnc_SOD - running the 'ALL' option on existing group(s) is invalid! Exiting", true] call ADF_fnc_log;
							_SOD_execute = false;
						};
					};
				};
				{_x deleteGroupWhenEmpty false; _x setVariable ["zbe_cacheDisabled", true];} forEach _SOD_groups;
				_SOD_firstRun = false;				
			} else {
				// Re-activation. Let's un-cache the groups and assign orders
				[_SOD_groups] call _SOD_unCache;
				// Run custom code 3 (on each run)				
				if (_code_3 != "") then {[_code_3, true, "", false, _spawnPosition, _sensorPosition, _SOD_groups, _SOD_test, _sensorPosName, _spawnPosName] call _SOD_execCode};			
			};			
			
			_SOD_active = true;			
		
			// SOD zone is active. Start loop to scan the zone for players. If there are no players in the activated zone then the loop will exit.
			waitUntil {
				private _noPlayersInZone = true;
				sleep (3 + random 2);		
				{if ((_sensorPosition distance _x) < (_activation * 1.10)) exitWith {_noPlayersInZone = false}} forEach allPlayers select {((getPosATL _x) select 2) < 5};
				_noPlayersInZone
			};				
			
			_SOD_active = false;
	
			// Delete empty groups - 1.14
			{
				if (units _x isEqualTo []) then {
					_SOD_groups deleteAt _forEachIndex;
					[_x] call ADF_fnc_delete;
				}		
			} forEach _SOD_groups;
			
			// Exit if no units left alive
			if (_SOD_groups isEqualTo []) exitWith {_SOD_execute = false;};
			
			// Cache the remaining group(s)
			{
				_units = units _x;
				{
					_x allowDamage false;
					_x enableSimulationGlobal false;
					_x hideObjectGlobal true;			
					_x disableAI "FSM";				
				} forEach _units;
				{_x removeCuratorEditableObjects [_units, false]} count allCurators; // Only works on server
			} forEach _SOD_groups;
		};	
	};		
		
	// Check if any opfor units were alive since last zone activation. If not exit the loop
	if !_SOD_firstRun then {
		if (_SOD_groups isEqualTo []) exitWith {
			_SOD_execute = false;
		};
	};
	
	sleep (2 + random 2); 	
};