/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: recall foot patrol script
Author: Whiztler
Script version: 1.05

File: fn_recallPatrol.sqf
Diag: 0.184513 ms
**********************************************************************************
ABOUT
This function recalls existing foot patrols to a specified location. The recalled
patrols either defend or are deleted (see params). In case of a defend setting,
there is a 75% change they do a local search and destroy patrol and a 25% change
they garrison in nearby buildings.
After a random timer (5-10 min) the group(s) go back out on their previously
assigned patrol. 

You can add an optional array for the resume patrol:

0: start location (Marker, object, trigger or position array [x,y,z])
1: patrol radius in meters

Example: ["spawnMarker", 500]

The array needs to be stored (group) in the patrolConfig variable:
_group setVariable ["patrolConfig", ["spawnMarker", 500]];

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Group/Array: Group or array of groups
1. position:    Recall position. Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
2. Bool:        Defend the area (SAD patrol or garrison)?
                - true (default)
                - false: delete the group(s) after the arrive at the recall 
				 position.
3. Number:      Radius: search and detroy patrol radius and garrison building
                radius. Default: 100
4. String:      Code to execute on each unit of the group (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
5. String:      Code to execute on all units of the group. (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.

EXAMPLES USAGE IN SCRIPT:
[_grp, _pos, true, 100, "", "myGroupFunction"] call ADF_fnc_recallPatrol;
[_g, _p, true, 75, "myUnitFunction", "myGroupFunction"] call ADF_fnc_recallPatrol;

EXAMPLES USAGE IN EDEN:
[group this, getMarkerPos "myMarker", true, 100] call ADF_fnc_recallPatrol;

DEFAULT/MINIMUM OPTIONS
[_group, "myMarker"] call ADF_fnc_recallPatrol;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_recallPatrol"};

// init
params [
	["_patrolGroups", [], [[], grpNull]],
	["_position", "", ["", [], objNull, grpNull]],
	["_defend", true, [false]],
	["_radius", 100, [0]],
	["_execUnit", "", [""]],
	["_execGroup", "", [""]]		
];

// Check valid vars
if (_patrolGroups isEqualType [] && {_patrolGroups isEqualTo []}) exitWith {[format ["ADF_fnc_recallPatrol - No groups in the passed array: %1. Exiting", _patrolGroups]] call ADF_fnc_log; false};	
if (_patrolGroups isEqualType grpNull) then {_patrolGroups = [_patrolGroups]};
if (_execUnit != "") then {if (isNil _execUnit) then {if ADF_debug then {[format ["ADF_fnc_recallPatrol - incorrect code (%1) passed. Defaulted to ''.", _execUnit]] call ADF_fnc_log;}; _execUnit = "";}};
if (_execGroup != "") then {if (isNil _execGroup) then {if ADF_debug then {[format ["ADF_fnc_recallPatrol - incorrect code (%1) passed. Defaulted to ''.", _execGroup]] call ADF_fnc_log;}; _execGroup = "";}};
if (_radius > 1000) then {_radius = 1000;};
if (_radius < 50) then {_radius = 50;};

// Check the location position
private _moveToPos = [_position] call ADF_fnc_checkPosition;	

// Run the recall process for all groups in the array
{
	[_x, _moveToPos, _defend, _radius, _execUnit, _execGroup] spawn {
		
		// init
		params [
			"_group",
			"_moveToPos",
			"_defend",
			"_radius",
			"_execUnit",
			"_execGroup"
		];
		// If all group units are KIA then abort the process.		
		if ((count (units _group select {alive _x;})) == 0) exitWith {[format ["ADF_fnc_recallPatrol - This group (%1) seems to be empty. Cancelling recall process for this group.", _group]] call ADF_fnc_log;};	
		private _unitsCount = 0;
		private _patrolRadius = 5 * _radius;
		if (_patrolRadius > 500) then {_patrolRadius = 500};
		
		// Cancel existing waypoints 
		private _groupWaypoints = waypoints _group;
		{deleteWaypoint [_group, 0]} forEach _groupWaypoints;
		private _waypoint = _group addWaypoint [_moveToPos, 0];
		_waypoint setWaypointStatements ["true", "deleteWaypoint [group this, currentWaypoint (group this)]"];
		
		// Move the units to the regroup position asap
		{
			_x allowSprint false;
			_x doMove _moveToPos;
		} forEach units _group;	
		_group setSpeedMode "FULL";
		
		// Once the leader has arrive at the regroup position give them new orders
		waitUntil {
			sleep 1;
			_unitsCount = count (units _group select {alive _x;}); 
			unitReady (leader _group)  || _unitsCount == 0
		};			
		if (_unitsCount == 0) exitWith {};			
		
		if (!_defend) then {
			[_group] call ADF_fnc_delete;
		} else {
			// Execute custom passed code/function
			if (_execUnit != "") then {
				// Each unit in the group
				{[_x] call (call compile format ["%1", _execUnit])} forEach units _group;
				// Debug reporting
				if ADF_debug then {[format ["ADF_mod_createGarrison - call %1 for each unit of group: %2", _execUnit, _group]] call ADF_fnc_log};
			};

			if (_execGroup != "") then {
				// Group
				[_group] call (call compile format ["%1", _execGroup]);
				// Debug reporting
				if ADF_debug then {[format ["ADF_mod_createGarrison - call %1 for group: %2", _execGroup, _group]] call ADF_fnc_log};		
			};		
		
			// 75% change of SAD patrol, rest will garrison
			if (random 100 < 75) then {
				private _waypoint = _group addWaypoint [_moveToPos, 0];
				_waypoint setWaypointType "SAD";
				_waypoint setWaypointSpeed "FULL";
				_waypoint setWaypointBehaviour "COMBAT";
				
				// Override the default BIS timeout for SAD and set the SAD to at least 5-10 minutes.
				private _timeout = time + (selectRandom [5,6,7,8,9,10] * 60);
				waitUntil {
					sleep 5;
					_unitsCount = count (units _group select {alive _x;}); 
					if (unitReady (leader _group)) then {
						[_group] call ADF_fnc_delWaypoint;
						private _waypoint = _group addWaypoint [_moveToPos, 0];							
						_waypoint setWaypointType "SAD";
						_waypoint setWaypointSpeed "FULL";
						_waypoint setWaypointBehaviour "COMBAT";							
					};
					time > _timeout || _unitsCount == 0
				};
				if (_unitsCount == 0) exitWith {};		
				
				// resume normal patrol
				private _patrolConfig = _group getVariable ["patrolConfig", [_moveToPos, _patrolRadius]];
				[_group, _patrolConfig # 0, _patrolConfig # 1] call ADF_fnc_footPatrol;					
			} else {
				// Garrison the group
				[_group, _moveToPos, _radius, -1, true] call ADF_fnc_defendArea;
				
				// Set timer from 5-10 min after which the group will resume normal patrol duties
				private _timeout = time + (selectRandom [5,6,7,8,9,10] * 60);
				waitUntil {sleep 1; time > _timeout};
				if ((count (units _group select {alive _x})) == 0) exitWith {}; 
				
				// Resume patrol
				{_x enableAI "move"; _x doMove _moveToPos;} forEach units _group;
				waitUntil {
					sleep 1;
					_unitsCount = count (units _group select {alive _x;}); 
					unitReady (leader _group)  || _unitsCount == 0
				};			
				if (_unitsCount == 0) exitWith {};
				
				private _patrolConfig = _group getVariable ["patrolConfig", [_moveToPos, _patrolRadius]];
				[_group, _patrolConfig # 0, _patrolConfig # 1] call ADF_fnc_footPatrol;						
			};				
		};
	};
} forEach _patrolGroups;

true