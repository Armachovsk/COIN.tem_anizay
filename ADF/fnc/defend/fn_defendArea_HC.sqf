/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_defendArea_HC
Author: Whiztler
Script version: 1.16

File: fn_defendArea_HC.sqf
**********************************************************************************
ABOUT
Executed automatically by a Headless Client once the ownership of a garrisoned
group changes from Server to HC (HC load balancer). The HC reapplies garrison
directives such as garrison position, stance, altitude.
The function is exclusively used by ADF_fnc_DefendArea

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0: Group        Garrisoned group
1: Array        Array of garrison data for each unit of the group (set by
                ADF_fnc_DefendArea)

OPTIONAL PARAMETERS:
N/a

EXAMPLE
[_grp, _arr] call ADF_fnc_defendArea_HC;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_defendArea_HC"};

// init
private _diag_time = diag_tickTime;
params [
	["_group", grpNull, [grpNull]],
	["_garrisonArray", [], [[]]]
];
private _count = count _garrisonArray;

if (_count == 0) exitWith {if ADF_debug then {[format ["ADF_fnc_defendArea_HC - Passed array: %1 seems to be empty (%2)", _garrisonArray, _count]] call ADF_fnc_log}};
_group enableAttack false;	

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_defendArea_HC - group: %1 -- array count: %2 -- array: %3", _group, _count, _garrisonArray]] call ADF_fnc_log};

// reapply garrison position for each unit
for "_i" from 0 to (_count - 1) do {
	private _unit = (_garrisonArray # _i) # 0;
	private _position	= (_garrisonArray # _i) # 1;
	
	_unit allowDamage false;
	_unit setPosATL [_position # 0, _position # 1, ( _position # 2) + .15]; // Direct placement without movement.
	if ADF_debug then {[format ["ADF_fnc_defendArea_HC - SetPosATL for unit: %1 -- position: %2",_unit,_position]] call ADF_fnc_log};
	_unit disableAI "move";
	if ((_position # 2) > 4) then {_unit setUnitPos "MIDDLE"} else {_unit setUnitPos "_UP"};
	_unit setDir (_unit getVariable ["ADF_garrSetDir", (random 360)]);		
	doStop _unit;
	_unit allowDamage true;
	
	[_unit] spawn {
		params ["_unit"];
		waitUntil {sleep 1 + (random 1); !(unitReady _unit)};
		_unit enableAI "move";
	};
};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_defendArea_HC - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

true
