/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_stripVehicle
Author: Whiztler
Script version: 1.06

File: fn_stripVehicle.sqf
Diag: 0.0112 ms
**********************************************************************************
ABOUT
Clears the cargo contents of a vehicle.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      vehicle, aircraft, etc.

OPTIONAL PARAMETERS:
N/A      

EXAMPLES USAGE IN SCRIPT:
[myCar] call ADF_fnc_stripVehicle;

EXAMPLES USAGE IN EDEN:
[myCar] call ADF_fnc_stripVehicle;

DEFAULT/MINIMUM OPTIONS
[myCar] call ADF_fnc_stripVehicle;

RETURNS:
Bool (success flag)
*********************************************************************************/

//Init
params [
	["_vehicle", objNull, [objNull, ""]]
];

// Reporting
diag_log format ["ADF rpt: fnc - executing: ADF_fnc_stripVehicle (%1)", _vehicle];

if (isMultiplayer && {hasInterface}) exitWith {[format ["ADF_fnc_stripVehicle - Can only be executed from server of HC. vehicle passed: '%1' (%2) at position: %3. Exiting", _vehicle, typeOf _vehicle, getPosATL _vehicle], true] call ADF_fnc_log; false};
if (isMultiplayer && {isNil "ADF_preInit"}) exitWith {[format ["ADF_fnc_stripVehicle - Was executed before Pre-Init. Function terminated (%1 - %2)", _vehicle, typeOf _vehicle], true] call ADF_fnc_log; false};


ADF_vStrip = false;
if (_vehicle isEqualType "") then {_vehicle = call compile _vehicle;};

clearWeaponCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;	
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;

true