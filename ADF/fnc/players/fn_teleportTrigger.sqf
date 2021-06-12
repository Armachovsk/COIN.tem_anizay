/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_teleportTrigger
Author: Whiztler
Script version: 1.03

File: fn_teleportTrigger.sqf
**********************************************************************************
ABOUT
Use ths scipt to teleport players to a specific location (marker, object,
position)

FUNCTION IS REPLACED BY ADF_fnc_teleport. LEFT HERE FOR BACKWARD COMPATIBILITY!

INSTRUCTIONS:
Create a trigger or place a trigger on the map. 
Name:           any name you want
Size:           5 x 5
Repeatable:     Yes
Condition:      {vehicle _x in thisList && isPlayer _x} count allUnits > 0;
Activation by:  side of the players or whichever side you want to activate the
                teleporter.
On activate:    0 = [Teleport_Position, "My Teleport Location", 15, player] spawn ADF_fnc_teleportTrigger;
    
REQUIRED PARAMETERS (On Active):
0. Position:    Teleport position. Marker, object, trigger or position araay [x,y,z]

OPTIONAL PARAMETERS:
1. String:      Text that is used in the message that is displayed when teleporting.
                E.g. "my groups teleport location". Default: "the RV location"
2. Number       Delay in seconds before the player is teleported.

EXAMPLE
See instructions;

RETURNS:
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_teleportTrigger"};

// Only players
if !hasInterface exitWith {};

// Init
params [
	["_p", "", ["", [], objNull, grpNull]],
	["_n", "the RV location", [""]],
	["_c", 30, [0]],
	["_u", player, [ObjNull]]
];

[_u, _p, _n, _c] spawn ADF_fnc_teleport;