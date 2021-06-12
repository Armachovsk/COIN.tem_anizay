/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Para drop script
Author: Whiztler
Script version: 1.30

File: fn_createPara.sqf
**********************************************************************************
ABOUT:
This script creates a transport aircraft and an infantry group (4 - 16 units).
The units are loaded into the aircraft and then flown to the drop off point
where they will para drop.

You can pass a marker, object, groupname, position [y,x,z] or and array of spawn
positions (objects, markers, triggers). In case of an array a random position will
be selected. Same goes for the drop position .

Type of aircraft is determined by passing a aircraft class for specific aircraft
spawning, or by passing a side (east, west, independent). In case of east, a CSAT
troop helicopter will be used.

You can pass 2 functions to the script:

Function1 will run (call) on individual units once the infantry group has been
created (e.g. a loadout script). Params passed to the function:
_this select 0: unit 

Function2 will run (spawn) on the group itself. Can be used to give the group
directives once they have landed (e.g. assault waypoints). Params passed to the
function: 
_this select 0: group.

After dropping off the para group, the aircraft returns to the spawn position
where the aircraft and its crew are deleted.

INSTRUCTIONS:
Execute (spawn) from the server or HC.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, Object or Trigger. This is the position
                where both the aircraft and the para group are created
                E.g.. getMarkerPos "Spawn" -or- "SpawnPos" -or- MyObject
                Array of markers/objects/grousps is also possible:
                e.g. ["markerPos1", "markerPos2", myObject10]	
1. Position:    Para drop position. Marker, Object or Trigger. The para drop
                starts approx 350m from the drop position.
                Array of markers/objects/grousps is also possible

OPTIONAL PARAMETERS:
2. Side/String: Side of the aircraft and the para group. Can be west, east or
                independent.  Or "Classname" of the aircraft as a string.
			   Default: east
3. Integer:     Para group size (one group on matter the size):
                - 1: Fire team - 4 pax
                - 2: Squad - 8 pax (default) 
                - 3: Squad plus one fire team, - 12 pax
                - 4: Two squads - 16 pax
4. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
5. String:      Code to execute on the crew on a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.

EEXAMPLES USAGE IN SCRIPT:
["paraSpawnMarker", "paraDropMarker", east, 2, "My_fnc_loadoutEast", "My_fnc_paraAssault"] spawn ADF_fnc_createPara;
["paraSpawnMarker", "paraDropMarker", "O_T_VTOL_02_infantry_grey_F", 4, "My_fnc_loadoutEast", "My_fnc_paraAssault"] spawn ADF_fnc_createPara;

EXAMPLES USAGE IN EDEN:
0 = ["paraSpawnMarker", "paraDropMarker", this, 2] spawn ADF_fnc_createPara;
0 = ["paraSpawnMarker", "paraDropMarker", this, 3, "My_fnc_Unit"] spawn ADF_fnc_createPara;

DEFAULT/MINIMUM OPTIONS
[_posSpawn, _posParaDrop] spawn ADF_fnc_createPara;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createPara"};


///// INIT

private _diagTime	= diag_tickTime;
params [
	["_positionSpawn", "", ["", [], objNull, grpNull]],
	["_positionDrop", "", ["", [], objNull, grpNull]],
	["_side", east, [west, ""]],
	["_paraGroupSize", 2, [0]],
	["_code_1", "", [""]],
	["_code_2", "", [""]],
	["_paraGroup", grpNull, [grpNull]],
	["_manualParaGroup", grpNull, [grpNull]],
	["_exit", false, [true]],
	["_paraUnits", [], [[]]],
	["_manualParaUnits", [], [[]]],
	["_vehicleClass", "", [""]],
	["_acm_groupTeam1", "", [""]],
	["_acm_groupTeam2", "", [""]],
	["_acm_groupFaction", "", [""]],
	["_acm_groupSide", "", [""]],
	["_acm_groupType", "", [""]]
];

private _direction = switch true do {
	case (_positionSpawn isEqualType ""): {markerDir _positionSpawn;};	
	case (_positionSpawn isEqualType objNull): {getDir _positionSpawn;};
	case (_positionSpawn isEqualType grpNull): {getDirVisual leader _positionSpawn;};
	case (_positionSpawn isEqualType []);
	case default {random 360;};
};

// Check valid vars
if (!(_side isEqualType "") && {!(_side in [west, east, independent])}) exitWith {[format ["ADF_fnc_createPara - Incorrect side passed (%1). Exiting", _side], true] call ADF_fnc_log; grpNull};
//if ((_side isEqualType "") && {([_side] call BIS_fnc_getCfgIsClass) == false}) exitWith {[format ["ADF_fnc_createPara - Incorrect class passed (%1). Exiting", _side], true] call ADF_fnc_log; grpNull};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createPara - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createPara - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_paraGroupSize > 4 || _paraGroupSize < 1) then {_paraGroupSize = 2; [format ["ADF_fnc_createPara - Incorrect para group size passed (%1). Chnaged to: 2", _paraGroupSize], false] call ADF_fnc_log};

// Validate the spawn/drop-off position
if ((_positionSpawn isEqualType []) && {(count _positionSpawn) > 1 && {!((_positionSpawn select 0) isEqualType 0)}}) then {_positionSpawn = selectRandom _positionSpawn};
if ((_positionDrop isEqualType []) && {(count _positionDrop) > 1 && {!((_positionDrop select 0) isEqualType 0)}}) then {_positionDrop = selectRandom _positionDrop};
_positionSpawn = [_positionSpawn] call ADF_fnc_checkPosition;
_positionDrop = [_positionDrop] call ADF_fnc_checkPosition;

// Check the side to determine the class of the transport aircraft and the para group
if (_side isEqualType "") then {
	_vehicleClass = _side;
	_side = switch (getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "side")) do {
		case 0: {east};
		case 1: {west};
		case 2: {independent};
		default {east};	
	};
	switch _side do {
		case west: {
			_acm_groupFaction = "BLU_F";
			_acm_groupSide = str _side;
			_acm_groupType = "BUS";
		};
		case east: {
			_acm_groupFaction = "OPF_F";
			_acm_groupSide = str _side;
			_acm_groupType = "OIA";
		};
		case independent: {
			_acm_groupFaction = "IND_F";
			_acm_groupSide = "Indep";
			_acm_groupType = "HAF";
		};
	};	
} else {
	switch _side do {
		case west: {
			_vehicleClass = "B_Heli_Transport_01_F";
			_acm_groupFaction = "BLU_F";
			_acm_groupSide = str _side;
			_acm_groupType = "BUS";
		};
		case east: {
			_vehicleClass = "O_Heli_Transport_04_covered_F";
			_acm_groupFaction = "OPF_F";
			_acm_groupSide = str _side;
			_acm_groupType = "OIA";
		};
		//case east: {_vehicleClass = "O_Heli_Transport_04_bench_F"; _acm_groupFaction = "OPF_F"; _acm_groupSide = str _side; _acm_groupType = "OIA"}; // open heli has incorrect cargo position reporting.
		case independent: {
			_vehicleClass = "I_Heli_light_03_unarmed_F";
			_acm_groupFaction = "IND_F";
			_acm_groupSide = "Indep";
			_acm_groupType = "HAF";
		};
	};
};

///// CREATE THE AIRCRAFT

// Create the aircraft at the spawn position
private _crew = createGroup _side;
private _altitude = 110 + (random 50);
_positionSpawn set [2, _altitude];
_crew deleteGroupWhenEmpty true;
private _v = [_positionSpawn, 0, _vehicleClass, _crew] call ADF_fnc_createCrewedVehicle;
private _vehicle = _v # 0;
_vehicle setDir _direction;
private _vehicleCargoCount = _vehicle emptyPositions "cargo";

// DIsable pilots combat abilities so that he delivers the para group to the drop off position no matter the situation
[driver _vehicle] call ADF_fnc_heliPilotAI;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_createPara - Heli crew group: %1 --- Helicopter: %2", _crew, _vehicle]] call ADF_fnc_log};

// check if the group will fit in the cargo space of the aircraft. If not then log the issue in the RPT and adjust the paragroup size to fit the aircraft
if (_vehicleCargoCount < (_paraGroupSize * 4)) then {
	private _oldSize = _paraGroupSize;
	_paraGroupSize = floor (_vehicleCargoCount/4);
	[format ["ADF_fnc_createPara - Nr. of units in the para group (%1) exceeds available cargo space (%2). Group size adjusted (%3) to fit the aircraft cargo.", _oldSize * 4, _vehicleCargoCount, _paraGroupSize * 4], false] call ADF_fnc_log
};
if (_vehicleCargoCount <= 4 && {_paraGroupSize > 1}) then {_paraGroupSize = 1};
if (_vehicleCargoCount > 4 && {_vehicleCargoCount <= 8 && {_paraGroupSize > 2}}) then {_paraGroupSize = 2};
if (_vehicleCargoCount > 8 && {_vehicleCargoCount <= 12 && {_paraGroupSize > 3}}) then {_paraGroupSize = 3};

///// CREATE THE PARA GROUP

// Determine para group size and put together classnames for ACM
private _squadArray = ["_InfSquad", "_InfSquad_Weapons", "_InfSquad", "_InfSquad"];
switch _paraGroupSize do {
	case 1: {_acm_groupTeam1 = "_InfTeam"};
	case 2: {_acm_groupTeam1 = selectRandom _squadArray};
	case 3: {
		_acm_groupTeam1 = selectRandom _squadArray;
		_acm_groupTeam2 = "_InfTeam";
	};
	case 4: {
		_acm_groupTeam1 = selectRandom _squadArray;
		_acm_groupTeam2 = selectRandom _squadArray;
	};
	default {
		_acm_groupTeam1 = "_InfSquad";
		_acm_groupTeam2 = "_InfSquad"
	};
};
_acm_groupTeam1 = format ["%1%2", _acm_groupType, _acm_groupTeam1];
// Debug reporting
if ADF_debug then {[format ["ADF_fnc_createPara - group ACM class: %1", _acm_groupTeam1]] call ADF_fnc_log};

// Create the para group
private _paraGroup = [_positionSpawn, _side, (configFile >> "CfgGroups" >> _acm_groupSide >> _acm_groupFaction >> "Infantry" >> _acm_groupTeam1)] call BIS_fnc_spawnGroup;
(leader _paraGroup) setRank "SERGEANT";

// In case of a squad > 8 AI, create a second group and make them join the para group to form one large squad.
if (_paraGroupSize > 2) then {
	_acm_groupTeam2 = format ["%1%2", _acm_groupType, _acm_groupTeam2];
	private _g = [_positionSpawn, _side, (configFile >> "CfgGroups" >> _acm_groupSide >> _acm_groupFaction >> "Infantry" >> _acm_groupTeam2)] call BIS_fnc_spawnGroup;
	(units _g) joinSilent _paraGroup;
	(leader _paraGroup) setRank "LIEUTENANT"; // promote the group leader
};
// Populate the paraUnits array with all squad members
private _paraUnits = units _paraGroup;
// Disable caching and ownership transfer to the/another HC for the time being
_paraGroup setVariable ["ADF_noHC_transfer", true];
_paraGroup setVariable ["zbe_cacheDisabled", true];
_paraGroup setVariable ["ADF_para_jump", false];

// Add the para group to Zeus
if isServer then {
	[_paraGroup] call ADF_fnc_addToCurator;
} else {
	[_paraGroup] remoteExecCall ["ADF_fnc_addToCurator", 2];
};


///// PARA GROUP BOARD AIRCRAFT

// Check for backpack and store items. Backpack will be return to the unit once it has touched ground.
[_vehicle, _paraUnits] spawn {
	params ["_vehicle", "_paraUnits"];
	{
		_x allowDamage false;
		_x disableCollisionWith _vehicle;

		// If the unit has a backpack then store the backpack + backpack items before we move the unit inside the cargo of the aircraft
		if ((backpack _x) != "") then {
			_x setVariable ["paraUnitItems", [true, backpack _x, backpackItems _x]];
			removeBackpack _x;
		} else {
			_x setVariable ["paraUnitItems", [false, "", []]];
		};

		// Assign the unit to the aircraft cargo
		_x assignAsCargo _vehicle;
		_x moveInCargo _vehicle;
		sleep 0.2;
		if ((_vehicle getCargoIndex _x) isEqualTo -1) then {
			[_x, _vehicle] spawn {
				params [_unit, _vehicle];
				private _timeOut = 1;
				waitUntil {
					if ((_vehicle getCargoIndex _unit) > -1) exitWith {true};			
					if (_timeOut > 30) then {[_unit] call ADF_fnc_delete;};
					_unit moveInCargo _vehicle;
					_timeOut = _timeOut + 1;
					sleep 0.2;
					!alive _unit
				};	
			};
		};		
	} forEach _paraUnits;
};


///// AIRCRAFT FLIGHT PLAN

// Create the waypoints for the aircraft
_vehicle flyInHeight _altitude;
private _wp = _crew addWaypoint [_positionDrop, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "NORMAL";
_wp setWaypointCompletionRadius (20 + random 50);

_wpx = _crew addWaypoint [_positionSpawn, 0];
_wpx setWaypointType "MOVE";
_wpx setWaypointSpeed "NORMAL";
_wpx setWaypointCompletionRadius 50;

// Start fall back timer. If the aircraft is stuck at the spawn position for 30+ seconds then delete the vehicle + crew + para group
private _timeOut = (time + 30);
waitUntil {
	sleep 3;
	(speed _vehicle) > 100 || time > _timeOut || !alive _vehicle
};
if (time > _timeOut || !alive _vehicle) exitWith {	
	[format ["ADF_fnc_createPara - Terminate for helicopter: %1 - group: %2 - Stuck at spawn position (30 seconds timer) or no longer alive (%3)", _vehicle, _paraGroup, alive _vehicle]] call ADF_fnc_log;
	[_vehicle] call ADF_fnc_delete;
	[_paraGroup] call ADF_fnc_delete;
	if (count _manualParaUnits > 0) then {[_manualParaGroup] call ADF_fnc_delete};
	_exit = true;
};
if (_exit) exitWith {};


///// PARAGROUP CHECKS AND ASSIGN JUMP

// Double check if the assigned para units actually boarded the aircraft. If not then add them to the manual para group.
if (count (assignedCargo _vehicle) < (count _paraUnits)) then {
	private _tempUnits = _paraUnits - (assignedCargo _vehicle);
	_manualParaGroup = createGroup _side;	
	_tempUnits joinSilent _manualParaGroup;
	_manualParaUnits = units _manualParaGroup;
	[format ["ADF_fnc_createPara - Not all units were moved into the aircraft. Para Group total: %1 (%2). Left behind: %3 (%4).", count units _paraGroup, count _paraUnits, count units _manualParaGroup, count _manualParaUnits]] call ADF_fnc_log;

	// Spawn a new thread for the manual para group so that they can join the airborne paragroup when they jump
	if (count _manualParaUnits > 0) then {
		[_manualParaUnits, _paraGroup, _manualParaGroup, _vehicle] spawn {
			params [
				"_manualParaUnits",
				"_paraGroup",
				"_manualParaGroup",
				"_vehicle"
			];
			
			[format ["ADF_fnc_createPara - Manual/left behinf units wait till the main para group jumps and then will join them: %1 {%2} ", count _manualParaUnits, _manualParaUnits]] call ADF_fnc_log;
			// Wait until the para group is jumping out of the air craft
			waitUntil {
				sleep 0.5; 
				_paraGroup getVariable ["ADF_para_jump", false]
			};
			
			sleep 0.3;
			
			// Manual jump for the left over forces
			{
				[_x, _vehicle] spawn ADF_fnc_paraDrop;
				sleep 0.65
			} forEach _manualParaUnits;
			
			sleep 30;
			
			// Leftover forces re-join the para group for further tasking
			_manualParaUnits joinSilent _paraGroup;
			sleep 0.1;
			[_manualParaGroup] call ADF_fnc_delete;		
		};
	};
};

// Check distance to drop off location and spawn the para drop function
[_paraUnits, _vehicle, _positionDrop, _paraGroup] spawn {
	params ["_paraUnits", "_vehicle", "_positionDrop", "_paraGroup"];
	
	waitUntil {
		sleep 0.5;
		(([_vehicle, _positionDrop] call ADF_fnc_checkDistance) < (((count _paraUnits) * 25) + 25)) || !alive _vehicle
	};
	if (!alive _vehicle || !alive (leader _paraGroup)) exitWith {};	
	
	//_paraUnits allowGetIn false;
	_paraGroup setVariable ["ADF_para_jump", true];
	{[_x] spawn ADF_fnc_paraDrop; sleep 0.6} forEach _paraUnits;
};

// Apply the units function on the para group units (call)
if (_code_1 != "") then {
	{[_x] call (call compile format ["%1", _code_1])} forEach _paraUnits;
	if (count _manualParaUnits > 0) then {{[_x] call (call compile format ["%1", _code_1])} forEach _manualParaUnits;};
	if ADF_debug then {[format ["ADF_fnc_createPara - call %1 for units of group: %2",_code_1, _paraGroup]] call ADF_fnc_log};
};
// Apply the para group function on the para group (spawn)
if (_code_2 != "") then {
	[_paraGroup] spawn (call compile format ["%1", _code_2]);
	if (count _manualParaUnits > 0) then {[_manualParaGroup] spawn (call compile format ["%1", _code_2]);};
	if ADF_debug then {[format ["ADF_fnc_createPara - spawn %1 for group: %2",_code_2, _paraGroup]] call ADF_fnc_log};	
};

{_x allowDamage true} forEach units _paraGroup; // hack ADF 2.22


///// HELI FALLBACK

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createPara - Diag time to execute function: %1", diag_tickTime - _diagTime]] call ADF_fnc_log};

// Delete the para aircraft and its crew after they have returned or when they are stuck the ARMA way (5 min timer).
waitUntil {
	sleep 2;
	!(alive _vehicle) || ((currentWaypoint (_wp # 0)) > (_wp # 1))
};

// Create time-out timer and delete the aircraft
private _time = (time + (5 * 60));
waitUntil {
	sleep 1;
	!alive _vehicle || time > _time || ((currentWaypoint (_wpx # 0)) > (_wpx # 1))
};
[_vehicle] call ADF_fnc_delete;