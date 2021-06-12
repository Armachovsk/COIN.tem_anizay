/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_setTurretGunner
Author: Whiztler
Script version: 1.03

File: fn_setTurretGunner.sqf
Diag: 0.0107 ms
**********************************************************************************
Increases skill set for turret units to make them more responsive to threads.
If you have vehicles on the map you DO NOT want to be populated by AI's,
then 'LOCK' the vehicle (not player lock!)

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      The AI unit that is assigned to a turret

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
[_myGunner] call ADF_fnc_setTurretGunner;

EXAMPLES USAGE IN EDEN:
[this] call ADF_fnc_setTurretGunner;

DEFAULT/MINIMUM OPTIONS
[_unit] call ADF_fnc_setTurretGunner;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_setTurretGunner"};

// init
params [
	["_unit", objNull, [objNull]]
];

// Increase gunner skill so they are more responsive to approaching enemies
_unit setSkill ["spotDistance",.8 + (random .2)];
_unit setSkill ["spotTime",.7 + (random .3)];
_unit setSkill ["aimingAccuracy",.5 + (random .5)];
_unit setSkill ["aimingSpeed",.5 + (random .5)];
_unit setCombatMode "RED";

true