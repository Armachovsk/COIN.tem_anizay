/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Vehicle Convoy
Author: Whiztler
Script version: 1.18

File: fn_createConvoy.sqf
**********************************************************************************
ABOUT:
The Create Vehicle Convoy function creates a customizable vehicle with a start and
termination waypoint. At the termination waypoint the conoy is deleted. The lead
vehicle is an armed MRAP or APC. The lead vehicle and the last vehicle each have a
flag attached the the vehicle.

>>>>> NOTE THAT ARMA3 IS NOT WELL SUITED FOR VEHICLE CONVOYS. VEHICLES TEND TO
CLUSTER F&$K ALL OVER THE PLACE, CREATING CHAOS. ONLY USE WHEN ABSOLUTELY NEEDED!

CUSTOMIZATION
- type of convoy (trucks, MRAP's, armored vehicles)
- Number of vehicles in the convoy
- start location
- termination location

INSTRUCTIONS:
Execute (spawn) from the server or headless client.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, object, trigger or position array [x, y, z].
1. Position:    Destination position. Marker, object, trigger or array [x, y, z].

OPTIONAL PARAMETERS:
2: Side:        west, east or independent. Default: east
3: Integer:     Type of convoy (lead vehicle is combat vehicle):
                - 1 - Random Transport truck (default)
                - 2 - Random MRAP
                - 3 - Random APC / Armored
4: Integer:     Number of vehicles including the lead vehicle. Max: 10. Default: 5
6: Integer:     Spawn delay timer in seconds. Default: 0. Maximum 1 hour (3600)
7. String:      Name of this convoy in case you wish to create multiple convoys. 

EXAMPLES USAGE IN SCRIPT:
["spawn_Marker", "destination_Marker", east, 1, 6, 300, "my_CSAT_convoy"] spawn ADF_fnc_createConvoy;

EXAMPLES USAGE IN EDEN:
0 = [position this, "destination_Marker", west, 3, 3, 10, "bluFor_convoy"] spawn ADF_fnc_createConvoy;

DEFAULT/MINIMUM OPTIONS
["spawn_Marker", "destination_Marker"] spawn ADF_fnc_createConvoy;

Returns
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createConvoy"};

// Init
params [
	["_posSpawn", "", ["", [], objNull, grpNull]], 
	["_posTerminate", "", ["", [], objNull, grpNull]], 
	["_side", east, [west]], 
	["_convoyType", 1, [0]], 
	["_numberOfVehicles", 5, [0]], 
	["_delay", 0, [0]], 
	["_chk", "convoy1", [""]],
	["_allConvoyVehicleClasses", [], [[]]],
	["_allLeaderVehicleClasses", "", [""]],
	["_flag", "", [""]],
	["_convoyVehicles", [], [[]]],
	["_exit", false, [true]]
];

// Check valid vars
if ((_convoyType > 3) || {_convoyType < 1}) then {_convoyType = 1;};
if (_numberOfVehicles > 10) then {_numberOfVehicles = 10};
if (_delay > 3600) then {_delay = 3600};

// Check if we should run the convoy script
if !(isNil (format ["%1_exec", _chk])) exitWith {[format ["ADF_fnc_createConvoy - convoy (%1) already executed!", _chk]] call ADF_fnc_log; false};
missionNamespace setVariable [(format ["%1_exec", _chk]), true]; 

// Sleep timer
sleep _delay;

// Determine vehicle based on side and type
if (_side == west) then {
	_flag = "\A3\Data_F\Flags\Flag_nato_CO.paa";
	switch _convoyType do {		
		case 1: {
			_allConvoyVehicleClasses = ["B_Truck_01_transport_F", "B_Truck_01_covered_F", "B_Truck_01_mover_F", "B_Truck_01_box_F", "B_Truck_01_Repair_F", "B_Truck_01_ammo_F", "B_Truck_01_fuel_F", "B_Truck_01_medical_F"];
			_allLeaderVehicleClasses = selectRandom ["B_APC_Wheeled_01_cannon_F", "B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"];
		};
		case 2: {
			_allConvoyVehicleClasses = ["B_MRAP_01_F", "B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"];
			_allLeaderVehicleClasses = selectRandom ["B_APC_Wheeled_01_cannon_F", "B_MRAP_01_gmg_F", "B_MRAP_01_hmg_F"];
		};
		case 3;
		default {
			_allConvoyVehicleClasses = ["B_APC_Tracked_01_rcws_F", "B_APC_Tracked_01_CRV_F", "B_APC_Wheeled_01_cannon_F", "B_APC_Tracked_01_AA_F", "B_MBT_01_cannon_F", "B_MBT_01_arty_F", "B_MBT_01_TUSK_F"];
			_allLeaderVehicleClasses = "B_MRAP_01_F";
		};
	};
};
if (_side == east) then {
	_flag = "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
	switch _convoyType do {		
		case 1: {
			_allConvoyVehicleClasses = ["O_Truck_02_covered_F", "O_Truck_02_transport_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F", "O_Truck_03_repair_F", "O_Truck_03_ammo_F", "O_Truck_03_fuel_F", "O_Truck_03_medical_F", "O_Truck_03_device_F", "O_Truck_02_box_F", "O_Truck_02_Ammo_F", "O_Truck_02_fuel_F", "O_Truck_02_covered_F"];
			_allLeaderVehicleClasses = selectRandom ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_APC_Wheeled_02_rcws_F"];
		};
		case 2: {
			_allConvoyVehicleClasses = ["O_MRAP_02_F", "O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F"];
			_allLeaderVehicleClasses = selectRandom ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_APC_Wheeled_02_rcws_F"];
		};
		case 3;
		default {
			_allConvoyVehicleClasses = ["O_APC_Wheeled_02_rcws_F", "O_APC_Tracked_02_cannon_F", "O_APC_Tracked_02_AA_F", "O_MBT_02_cannon_F", "O_MBT_02_arty_F"];
			_allLeaderVehicleClasses = "O_MRAP_02_F";
		};
	};
};
if (_side == independent) then {
	_flag = "\A3\Data_F\Flags\Flag_AAF_CO.paa";
	switch _convoyType do {
		case 1: {
			_allConvoyVehicleClasses = ["I_Truck_02_covered_F", "I_Truck_02_transport_F", "I_Truck_02_ammo_F", "I_Truck_02_box_F", "I_Truck_02_medical_F", "I_Truck_02_fuel_F"];
			_allLeaderVehicleClasses = selectRandom ["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F", "I_APC_Wheeled_03_cannon_F"];
		};
		case 2: {
			_allConvoyVehicleClasses = ["I_MRAP_03_F", "I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F"];
			_allLeaderVehicleClasses = selectRandom ["I_MRAP_03_hmg_F", "I_MRAP_03_gmg_F", "I_APC_Wheeled_03_cannon_F"];
		};
		case 3;
		default {
			_allConvoyVehicleClasses = ["I_MBT_03_cannon_F"];
			_allLeaderVehicleClasses = "I_APC_Wheeled_03_cannon_F";
		};
	};
};

// Get the direction of the spawn position
private _direction = if (_posSpawn isEqualType "") then {markerDir _posSpawn} else {getDir _posSpawn};

// Check position. Return valid [x, y, z] position
private _positionTerminate = [_posTerminate] call ADF_fnc_checkPosition;
private _positionSpawn = [_posSpawn] call ADF_fnc_checkPosition;

// Create the group and create group directives 
private _group = createGroup _side;
_group setCombatMode "GREEN";
_group setFormation "COLUMN";
_group setBehaviour "SAFE";

// Create the waypoint first so that the convoy vehicles move immediately after spawn
private _waypoint = _group addWaypoint [_positionTerminate, 0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointBehaviour "SAFE";
_waypoint setWaypointCompletionRadius 20;
_waypoint setWaypointFormation "COLUMN";	
	
// Create the convoy lead vehicle and add it to the convoy array
private _vehicleLeader = [_posSpawn, _direction, _allLeaderVehicleClasses, _group, "", "", true, false] call ADF_fnc_createCrewedVehicle;
_convoyVehicles pushBack (_vehicleLeader # 0);
(commander (_vehicleLeader # 0)) setRank "MAJOR";
[driver (_vehicleLeader # 0)] call ADF_fnc_heliPilotAI; 
(_vehicleLeader # 0) limitSpeed 50;
(_vehicleLeader # 0) setConvoySeparation 50; 
(_vehicleLeader # 0) forceFlagTexture _flag; 

// Wait till the leader vehicle is moving and then create the other convoy vehicles
private _time = time;
waitUntil {
	sleep 1;
	if (time > _time + 120) exitWith {_exit = true};
	((_vehicleLeader # 0) distance2D _positionSpawn) > 35 || _exit
};

if _exit exitWith {[_convoyVehicles] call ADF_fnc_delete;};

for "_i" from 1 to _numberOfVehicles do {
	private _time = time;
	private _vehicle = [_posSpawn, _direction, selectRandom _allConvoyVehicleClasses, _group, "", "", true, false] call ADF_fnc_createCrewedVehicle;
	[driver (_vehicle # 0)] call ADF_fnc_heliPilotAI; 
	_convoyVehicles pushBack (_vehicle # 0);
	if (_i == _numberOfVehicles) exitWith {(_vehicle # 0) forceFlagTexture _flag;};

	waitUntil {
		sleep 1;
		if (time > _time + 120) exitWith {_exit = true};
		((_vehicle # 0) distance2D _positionSpawn) > 35 ||  _exit
	};

	(_vehicle # 0) setConvoySeparation 50;
	(_vehicleLeader # 0) limitSpeed 55;
};

if _exit exitWith {[_convoyVehicles] call ADF_fnc_delete;};

// Once the convoy reaches its destination it will be deleted. The convoy has 30 seconds to catch up with the lead vehicle
waitUntil {sleep 1; ((currentWaypoint (_waypoint # 0)) > (_waypoint # 1))};
sleep 30;
[_convoyVehicles] call ADF_fnc_delete;