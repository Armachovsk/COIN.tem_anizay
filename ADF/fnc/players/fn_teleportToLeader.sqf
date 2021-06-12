/*********************************************************************************

 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Teleport to group leader script
Author: Whiztler
Script version: 1.14

File: fn_teleportToLeader.sqf
**********************************************************************************
ABOUT:
Teleport function to teleport reinforcements to the position of their team leader.

FUNCTION IS REPLACED BY ADF_fnc_teleport. LEFT HERE FOR BACKWARD COMPATIBILITY!

INSTRUCTIONS:
Place an object (flag pole, vehicle, etc.) and copy the following into the init
field of the placed object:

this addAction ["<t align='left' color='#E4F2AA'>Teleport to team leader</t>",
{[_this # 0,_this # 1] spawn ADF_fnc_teleportToLeader;},
[], 6, true, true, "", "true" , 5]; this allowDamage false;

RETURNS:
Nothing
*********************************************************************************/

if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_teleportToLeader"};

// Init
params [
	["_o", objNull, [objNull]],
	["_u", objNull, [objNull]]
];

[_o, _u] spawn ADF_fnc_teleport;