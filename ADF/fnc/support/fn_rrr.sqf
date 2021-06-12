/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Reload/Rearm/Repair
Author: Xeno & Whiztler
Script version: 3.03

File: fn_rrr.sqf
***********************************************************************************
ABOUT
Basic functionality to create a FARP. The script determines the type of vehicle and
(re-)supplies accordingly.

INSTRUCTIONS:
Create a trigger, make it the size of the service area. Trigger configuration:

Name:           Any name you want
Activation by:  side of the players or whichever side you want to activate the
                Reload/Rearm/Repair function.
Repeatable:     Yes

For Helicopters:
Condition:      ("Helicopter" countType thisList  > 0) && ((getPos (thisList select 0)) select 2 < .5)
On activation:  0 = [(thisList select 0), "Mike's Air Services", "Rotor Aircraft Service Point"] spawn ADF_fnc_rrr;

For Airplanes:
Condition:      (("Plane" countType thisList  > 0) || ("airplane" countType thisList  > 0) || ("airplanex" countType thisList  > 0)) && ((getPos (thisList select 0)) select 2 < 1) && (speed (thisList select 0) < 10)
On activation:  0 = [(thisList select 0)] spawn ADF_fnc_rrr;

For Vehicles:
Condition:      (("CAR" countType thisList  > 0) || ("TRUCK" countType thisList  > 0) || ("TANK" countType thisList  > 0) || ("APC" countType thisList  > 0)) &&  ((getPos (thisList select 0)) select 2 < 3);
On activation:  0 = [(thisList select 0), "South End Garage", "Service Point since 1988"] spawn ADF_fnc_rrr;

EXAMPLES USAGE IN SCRIPT:
N/A

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
N/A

RETURNS:
A full tank of gas
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_rrr"};

// Init
params [
	["_vehicle", objNull, [objNull]],
	["_serviceName", "", [""]],
	["_serviceSub", "", [""]],
	["_vehicleDescription", "", [""]],
	["_unit", "", [""]]
];
private _position = getPosWorld _vehicle;
private _vehicleType = typeOf _vehicle;
private _isPlane = _vehicle isKindOf "Plane"; 
private _vehicleName = getText(configFile >> "CfgVehicles" >> _vehicleType >> "displayName");
private _hasTurret = if ((count ([typeOf _vehicle, false] call BIS_fnc_allTurrets) > 0) || (count (getPylonMagazines _vehicle)) > 0) then {true} else {false};
private _fuelLoad	= fuel _vehicle;
private _maxTime = round ((ADF_FARP_repairTime + ADF_FARP_reloadTime + ADF_FARP_refuelTime + 30) / 60); // maximum time in MIN
private _time = time;
private _lastService = _vehicle getVariable ["ADF_rrr_serviced", -99];

// Vaalidation & checks
if (isNil "ADF_fnc_log") then {ADF_fnc_log = {}};
if (_vehicle isKindOf "ParachuteBase") exitWith {[format ["ADF_fnc_rrr - Incorrect vehicle passed: '%1' (%2). Exiting", _vehicle, typeOf _vehicle], true] call ADF_fnc_log;};
if (!alive _vehicle) exitWith {[format ["ADF_fnc_rrr - Vehicle '%1' (%2) is beyond repair. Exiting", _vehicle, typeOf _vehicle], true] call ADF_fnc_log;};
if ((_vehicle isKindOf "Plane") || (_vehicle isKindOf "Helicopter")) then {_unit = "Pilot"; _vehicleDescription = "aircraft";} else {_unit = "Driver"; _vehicleDescription = "vehicle";};
if (isNil "ADF_fnc_typeWriter" || {!(_serviceName isEqualType "")}) then {_serviceName = ""};
if !(_serviceSub isEqualType "") then {_serviceSub = ""};
if (_vehicleName == "") then {_vehicleName = _vehicleDescription};

// Start. Announce service point and switch off engine
if !(_serviceName == "") then {
	[[_serviceName,"<t align = 'center' shadow = '1' size = '1.3'>%1</t><br/>"],[_serviceSub,"<t align = 'center' shadow = '1' size = '1.0'>%1</t>"]] spawn ADF_fnc_typeWriter;
} else {
	_vehicle vehicleChat "Rearm / Repair / Refuel Service Point";
};
_vehicle engineOn false;

// Check last service and inform driver of the service process.
sleep 3;
if (!(_lastService isEqualTo -99) && (time - _lastService) < 180) exitWith {
	_vehicle vehicleChat format ["%1 was serviced less then 3 minutes ago. You have to wait %2 seconds before you can service %1 at this RRR Service Point.", _vehicleName, round (180 - (time - _lastService))];
};
_vehicle vehicleChat format ["Servicing %1", _vehicleName];
sleep 3;
_vehicle vehicleChat format ["%1, please switch off your engine and remain in the %2", _unit, _vehicleDescription];
_vehicle setFuel 0;
sleep 3;
_vehicle vehicleChat format ["Service can take up to %1 minutes.", _maxTime];
sleep 5;


///// REARM

if (_hasTurret) then {
	private _rearm_pause = ADF_FARP_reloadTime / 3;
	private _allVehicleMagazines = getArray (configFile >> "CfgVehicles" >> _vehicleType >> "magazines");	

	if !(_allVehicleMagazines isEqualTo {}) then {
		_vehicle vehicleChat "Removing magazine stock."; 
		private _magazineStock = [];
		{
			if (!(_x in _magazineStock)) then {
				_vehicle removeMagazines _x;
				_magazineStock pushBack _x;
			};
		} forEach _allVehicleMagazines;
		
		{
			_vehicle vehicleChat format ["Reloading %1", _x]; 
			sleep _rearm_pause;
			if (!alive _vehicle) exitWith {};
			_vehicle addMagazine _x;
		} forEach _allVehicleMagazines;
		sleep 3;
	};

	private _numberOfTurrets = count (configFile >> "CfgVehicles" >> _vehicleType >> "Turrets");

	if (_numberOfTurrets > 0) then {
		for "_i" from 0 to (_numberOfTurrets - 1) do {
			scopeName "ADF_Reload";			
			private _weapon = (configFile >> "CfgVehicles" >> _vehicleType >> "Turrets") select _i;
			private _weaponMagazines = getArray (_weapon >> "magazines");
			
			private _magazineStock = [];
			_vehicle vehicleChat "Removing turret ammo stock."; 
			{
				if (!(_x in _magazineStock)) then {
					_vehicle removeMagazines _x;
					_magazineStock pushBack _x;
				};
			} forEach _weaponMagazines;
			sleep 3;
			
			{				
				_vehicle vehicleChat format ["Reloading %1", _x]; 
				sleep _rearm_pause;
				if (!alive _vehicle) then {breakOut "ADF_Reload"};
				_vehicle addMagazine _x;
				sleep _rearm_pause;
				if (!alive _vehicle) then {breakOut "ADF_Reload"};
			} forEach _weaponMagazines;
			
			// check if the main platform has other turrets
			private _secondaryTurret = count (_weapon >> "Turrets");

			if (_secondaryTurret > 0) then {
				for "_i" from 0 to (_secondaryTurret - 1) do {
					private _secondaryWeapon = (_weapon >> "Turrets") select _i;
					private _weaponMagazines = getArray (_secondaryWeapon >> "magazines");
				
					private _magazineStock = [];
					{
						if (!(_x in _magazineStock)) then {
							_vehicle removeMagazines _x;
							_magazineStock pushBack _x;
						};
					} forEach _weaponMagazines;
					
					{
						_vehicle vehicleChat format ["Reloading %1", _x]; 
						sleep _rearm_pause;
						if (!alive _vehicle) then {breakOut "ADF_Reload"};
						_vehicle addMagazine _x;
						sleep _rearm_pause;
						if (!alive _vehicle) then {breakOut "ADF_Reload"};
					} forEach _weaponMagazines;
				};
			};
		};
	};

	if (!alive _vehicle) exitWith {};
	_vehicle setVehicleAmmo 1; // Reload all turrets
	sleep 2;
	if (ADF_mod_ACE3 && {_vehicle isKindOf "Car"}) then {[_vehicle, 2, "ACE_Wheel"] call ace_repair_fnc_addSpareParts;}; 
	_vehicle vehicleChat format ["%1 is fully rearmed", _vehicleName];
} else {
	if (ADF_mod_ACE3 && {_vehicle isKindOf "Car"}) then {[_vehicle, 2, "ACE_Wheel"] call ace_repair_fnc_addSpareParts;}; 
	sleep 2;
	_vehicle vehicleChat "No rearming services needed.";
};

sleep 8;

///// REPAIR

private _totalHitPoints = getAllHitPointsDamage _vehicle;
private _HitPointLevels = [];
private _HPD_levelDamaged = 0;
private _HPD_Total = 0;
if !(_totalHitPoints isEqualTo []) then {
	private _HitPointLevels = _totalHitPoints # 2;	
	{if (_x > 0) then {_HPD_levelDamaged = _HPD_levelDamaged + 1}} count _HitPointLevels;
	{_HPD_Total = _HPD_Total + _x} count _HitPointLevels;
};

private _vehicleDamage = if (_HPD_levelDamaged > 0) then {(100/((count _HitPointLevels) - 1)) * _HPD_Total} else {0};
private _repairSleep = if (_HPD_levelDamaged > 0) then {((_vehicleDamage / 100) * ADF_FARP_repairTime) / _HPD_levelDamaged} else {0};

if (_HPD_levelDamaged > 0) then {
	_vehicle vehicleChat format ["Repairing %1", _vehicleName];
	for "_i" from 0 to ((count _HitPointLevels) -1) do {
		private _d = switch ((_totalHitPoints # 0) # _i) do {
			case "hitlfwheel": {"left front wheel"};
			case "hitrfwheel": {"right front wheel"};
			case "hitrf2wheel": {"right front wheel"};
			case "hitreservewheel": {"reserve wheel"};
			case "hitfuel1";
			case "hitfuel2";
			case "hitfuel": {"fuel tank"};
			case "hitfuel_left";
			case "hitfuell": {"left fuel tank"};
			case "hitfuel_right";
			case "hitfuelr": {"right fuel tank"};
			case "hitengine1";
			case "hitengine2";
			case "hitengine3";
			case "hitengine_c";
			case "hitengine_l1": {"engine one"};
			case "hitengine_l2": {"engine two"};
			case "hitengine_r1": {"engine three"};
			case "hitengine_r2": {"engine four"};
			case "hitengine": {"engine components"};
			case "hit_hull_point";
			case "hithull";
			case "hitbody": {"and fixing bodywork"};
			case "hitavionics": {"avionics system"};
			case "hithrotor": {"main rotor"};
			case "reverse_light_hit": {"reverse light"};
			case "searchlight": {"search light"};
			case "cabin_light";
			case "cargo_light_1";
			case "cargo_light_2";
			case "cargo_light_3";
			case "cargo_light_4": {"cargo lights"};
			case "hitvrotor": {"tail rotor"};
			case "hitglass1"; 
			case "hitglass2";
			case "hitrglass";
			case "hitglass3";
			case "hitglass4";
			case "hitglass5";
			case "hitglass6";
			case "hitglass7";
			case "hitglass8": {"door and window"};
			case "cage_left_1_point"; 
			case "cage_left_2_point";
			case "cage_left_3_point";
			case "cage_right_1_point"; 
			case "cage_right_2_point";
			case "cage_right_3_point";
			case "cage_back_point";
			case "cage_front_point";
			case "hit_main_turret_point": {if (_hasTurret) then {"turret bodywork"} else {"structural damage"}};		
			case "hit_main_gun_point": {if (_hasTurret) then {"turret gun"} else {"structural damage"}};	
			case "hitlbwheel": {"left back wheel"};
			case "hitlmwheel": {"left middle wheel"};
			case "hitrbwheel": {"right back wheel"};
			case "hitrmwheel": {"right middle wheel"};
			case "hithull": {"and patching up bodywork"};
			case "hit_com_turret_point";
			case "hit_main_turret_point";
			case "hit_com_gun_point";
			case "hitturret": {if (_hasTurret) then {"turret structure"} else {"structural damage"}};	
			case "hitgun": {if (_hasTurret) then {"machine gun systems"} else {"structural damage"}};	
			case "light_l_flare";
			case "light_r_flare": {"flare/smoke systems"};
			case "#gear_1_light_1_hit"; 
			case "#gear_1_light_2_hit"; 
			case "#gear_f_lights"; 
			case "#light_l"; 
			case "#light_r": {"lights"};
			case "#hit_trackl_point": {"left track"};
			case "#hit_trackr_point": {"right track"};
			case "ind_fire1";
			case "ind_fire2";
			case "hitmissiles": {"weapons pods/bay"};
			case "hitwinch": {"loading system"};
			case "hittransmission": {"transmission"};
			case "ind_hydr_l": {"left hydraulics"};
			case "ind_hydr_r": {"right hydraulics"};
			case "hithydraulics": {"hydraulics"};
			case "hithstabilizerl1";
			case "hithstabilizerr1";
			case "hitvstabilizer1": {"stabilizer systems"};
			case "hittail": {"tail section"};
			case "hitpitottube": {"pitot tubes"};
			case "hitstaticport": {"static port systems"};
			case "hitstarter1";
			case "hitstarter2";
			case "hitstarter3": {"starter systems"};
			case "hitlaileron_link";
			case "hitlaileron": {"left aileron"};
			case "hitraileron_link";
			case "hitraileron": {"right aileron"};
			case "hitlcrudder": {"left rudder"};
			case "hitrcrudder": {"right rudder"};
			case "hitcontrolrear": {"rear control system"};
			case "hitlcelevator";
			case "hitrcelevator": {"elevators"};
			default {"structural damage"};
		};
		_vehicle vehicleChat format ["Inspecting %1", _d];
		sleep 2;
		private _h = _vehicle getHitIndex _i;
		if (_h > 0 && alive _vehicle) then {
			_vehicle vehicleChat format ["Repairing %1", _d];
			sleep (_repairSleep / 2);
			_vehicle setHitIndex [_i, _h / 2];
			sleep ((_repairSleep / 2) - 0.5);
			_vehicle setHitIndex [_i, 0];
			sleep 0.5;				
		}; 
		if (!alive _vehicle) exitWith {};
	};
	_vehicle vehicleChat format ["%1 is fully repaired", _vehicleName];
} else {
	_vehicle vehicleChat "No repair services required.";
	_vehicle setDamage 0;
	if (!alive _vehicle) exitWith {};
};
sleep 8;

// REFUEL

if (!alive _vehicle) exitWith {};

_vehicle setFuel _fuelLoad;
if (_fuelLoad < 0.96) then {
	_vehicle vehicleChat format ["Refueling %1", _vehicleName];
	[_vehicle] spawn {
		params ["_vehicle"];
		waitUntil {
			sleep 10;
			_vehicle vehicleChat "Refueling";			
			((fuel _vehicle) > .95) || !alive _vehicle
		};
	};
	while {_fuelLoad < 1 && alive _vehicle} do {		
		_vehicle setFuel (_fuelLoad + 0.01);
		_fuelLoad = fuel _vehicle;		
		if (_fuelLoad < 0.95) then {sleep (ADF_FARP_refuelTime / 60);};
	};
	sleep 2;
	_vehicle vehicleChat format ["%1 is fully refueled", _vehicleName];
} else {
	_vehicle vehicleChat "No refuel services needed.";
	_vehicle setFuel 1;
	if (!alive _vehicle) exitWith {};
	
};
sleep 8;
if (!alive _vehicle) exitWith {};
reload _vehicle;

///// SERVICE FINISHED

private _serviceTime = round ((time - _time) / 60);
private _timeType = "minutes";
private _dayType = "day";
private _tdt = date # 3;
if (_tdt < 12) then {_dayType = "morning"};
if (_tdt > 18) then {_dayType = "evening"};
if ((time - _time) < 90) then {_serviceTime = 1;_timeType = "minute"};
_vehicle vehicleChat format ["%1 was serviced in %2 %3. Enjoy your %4", _vehicleName, _serviceTime, _timeType, _dayType];
_vehicle setVariable ["ADF_rrr_serviced", time];