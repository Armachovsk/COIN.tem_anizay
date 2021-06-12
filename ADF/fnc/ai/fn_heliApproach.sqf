/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_heliApproach
Author: Whiztler
Script version: 1.03

File: fn_heliApproach.sqf
Diag: n/a
**********************************************************************************
ABOUT
Function that intends to smooth the AI helicopter approach by reducing airspeed
gradually based on the distance from the landing position. Works with all heli's.

The function doen not create waypoints, it just controls airspeed on the approach
vector.

INSTRUCTIONS:
Execute (spawn) from the server or HC

REQUIRED PARAMETERS:
0. Object:      Helicopter
1. Object:      helipad, marker, object at landing position (needed to calculate
                distance).

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[myHeli, LandingSpot] spawn ADF_fnc_heliApproach;

EXAMPLES USAGE IN EDEN:
[this, LandingSpot] spawn ADF_fnc_heliApproach;

DEFAULT/MINIMUM OPTIONS
[myHeli, LandingSpot] spawn ADF_fnc_heliApproach;

RETURNS:
A smooth ride
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_heliApproach"};

// init
params [
	["_aircraft", objNull, [objNull]],
	["_landPos", objNull, ["", objNull]]
];	

// Check vars
if !(_aircraft isKindOf "Helicopter") exitWith {[format ["ADF_fnc_heliApproach - Incorrect/no aircraft passed: '%1'. Exiting", _aircraft], true] call ADF_fnc_log;}; 
if (_landPos isEqualType objNull && {_landPos == objNull}) exitWith {[format ["ADF_fnc_heliApproach - Incorrect/no landing position object: '%1'. Exiting", _landPos], true] call ADF_fnc_log;}; 
if (_landPos isEqualType "" && {!(_landPos in allMapMarkers)}) exitWith {[format ["ADF_fnc_heliApproach - incorrect landing position marker: '%1'. Exiting", _landPos], true] call ADF_fnc_log;}; 

// Create an invisible helipad if the position is a marker
if (_landPos isEqualType "") then {
	private _v = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
	_v setPosATL (getMarkerPos _landPos);
	_landPos = _v;
};

// Wait untill the aircraft has reached airborne speed
waitUntil {
	sleep 0.1;
	(speed _aircraft) > 100
};	

// Wait untill the calculated travel time is approx 39 seconds from the landing position
waitUntil {
	sleep 0.5;
	private _time = ((_aircraft distance2D _landPos) / ((speed _aircraft) * 0.277777));
	// systemChat format ["time remaining: %1", _time]; // debug
	_time < 40
};

// pre-calculated approach velocity decrementer based on the speed of the aircraft
private _apprVelDecr = 0;
private _airSpeed = speed _aircraft;
call {
	if (_airSpeed > 300) exitWith {_apprVelDecr = 0.71}; 
	if (_airSpeed > 280) exitWith {_apprVelDecr = 0.77}; 
	if (_airSpeed > 270) exitWith {_apprVelDecr = 0.63}; 
	if (_airSpeed > 260) exitWith {_apprVelDecr = 0.59}; 
	if (_airSpeed > 250) exitWith {_apprVelDecr = 0.55}; 
	if (_airSpeed > 235) exitWith {_apprVelDecr = 0.51}; 
	if (_airSpeed > 225) exitWith {_apprVelDecr = 0.47}; 
	if (_airSpeed > 210) exitWith {_apprVelDecr = 0.43}; 
	if (_airSpeed > 195) exitWith {_apprVelDecr = 0.39}; 
	if (_airSpeed > 185) exitWith {_apprVelDecr = 0.35}; 
	if (_airSpeed > 175) exitWith {_apprVelDecr = 0.31}; 
	if (_airSpeed <= 175) exitWith {_apprVelDecr = 0.31}; 
	_apprVelDecr = 0.68; 
};	

waitUntil {
	sleep 0.1;
	_airSpeed = _airSpeed - _apprVelDecr;
	_aircraft limitSpeed _airSpeed;		
	_distance = _aircraft distance2D _landPos;
	_distance < 150 || (speed _aircraft) < 75
};