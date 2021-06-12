/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_disable3P
Author: Whiztler
Script version: 1.01

File: fn_disable3P.sqf
**********************************************************************************
ABOUT
Disables third person. In the mission params you can define if 3rd person view is
disabled. There is an extra option to disable 3rd person when inside a vehicle

INSTRUCTIONS:
Execute (spawn) on player clients

REQUIRED PARAMETERS:
0. Object:		Player.

OPTIONAL PARAMETERS:
N/a

EXAMPLES USAGE IN SCRIPT (initPlayerLocal.sqf):
if (ADF_disable3PC || ADF_disable3PV) then {player spawn ADF_fnc_disable3P};

EXAMPLES USAGE IN EDEN:
N/A must be executed after mission init

DEFAULT/MINIMUM OPTIONS
player spawn ADF_fnc_disable3P;

RETURNS:
N/a
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_disable3P"};

if !hasInterface exitWith {};

//Wait until the client has initialized
if (player != player || didJIP) then {
	waitUntil {!isNull player};
	waitUntil {time > 0};
};

// Start with 1st person view
player switchCamera "Internal";

// Stacked EH to check if player switches from 1st person view
["3P", "onEachFrame", {
		if (cameraView == "External") then {
			if !(isNull objectParent player) then {
				if (ADF_disable3PV) then {
					player switchCamera "Internal";
				}
			} else {
				player switchCamera "Internal";
			}
		}
	}
] call BIS_fnc_addStackedEventHandler;
