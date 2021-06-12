/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: search and destroy
Author: Whiztler
Script version: 1.07

File: fn_sad.sqf
**********************************************************************************
ABOUT
This function orders a group to search and destroy another group. It can be used 
for AI's hunting down player(s). You can config the function with a unique variable
that should be set to false on start. When the value turns true then the search
and destroy action will be terminated and the assault group will be deleted.

INSTRUCTIONS:
Execute (spawn) from the server or HC

REQUIRED PARAMETERS:
0. Group:       SAD/Assaulting group.
1. Group:       Group that will be tracked/assaulted (e.g. group player).

OPTIONAL PARAMETERS:
2: String:     This can be a variable set to either true or false. At the end off
               each cycle it checks the variable. If set to true it stops the
               cycle. By default it is set to false (infinite cycle).

EXAMPLES USAGE IN SCRIPT:
[_redGroup, _bluGroup] spawn ADF_fnc_sad;
[_redGroup, _bluGroup, "huntBlue"] spawn ADF_fnc_sad;

EXAMPLES USAGE IN EDEN:
[group this, blueGroup1] spawn ADF_fnc_sad;

DEFAULT/MINIMUM OPTIONS
[_group1, _group2] spawn ADF_fnc_sad;

RETURNS:
Happy hunters
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_sad"};

// Init
params [
	["_assaultGroup", grpNull, [grpNull]],
	["_targetGroup", grpNull, [grpNull]],
	["_exit", false, ["", true]],
	["_test", false, [true]], // debug mode
	["_SpeedMode", "FULL", [""]]	
];

// Check valid vars
if (_assaultGroup == grpNull) exitWith {[format ["ADF_fnc_sad - Empty SAD group passed: %1. Exiting", _assaultGroup], true] call ADF_fnc_log; false};
if (_targetGroup == grpNull) then {_targetGroup = group _targetGroup;};
private _startDistance = [_assaultGroup, _targetGroup] call ADF_fnc_checkDistance;

// Search and Destroy
waitUntil {	
	// Get an estimated position (75 m radius) of the leader of the target group
	private _position = [_targetGroup, 75] call ADF_fnc_randomPos;
	
	// Move order
	{_x allowSprint false; _x doMove _position;} forEach units _assaultGroup;		
	
	// Check how close the SAD group is to their target.
	private _distance = [_assaultGroup, _targetGroup] call ADF_fnc_checkDistance;
	if _test then {systemChat format ["assault group distance to target: %1 meters (speedmode: %2)", _distance, _SpeedMode]};
	
	// If the assault group is within striking distance then enable combat mode
	if (_distance < 250) then {
		_assaultGroup setCombatMode "RED";
		_assaultGroup setBehaviour "COMBAT";	
		_assaultGroup enableGunLights "Auto"; 
		_assaultGroup enableIRLasers false;	
		_SpeedMode = "NORMAL";
		if (_distance < 150) then {
			_SpeedMode = "LIMITED";
			{_x setUnitPos "MIDDLE";} forEach units _assaultGroup;
		};			
	} else {
		_assaultGroup enableGunLights "forceOn"; 
		_assaultGroup enableIRLasers true;
		_SpeedMode = "FULL";
	};

	_assaultGroup setSpeedMode _SpeedMode;
	
	sleep 3;
	
	// Check if the SAD order is still valid. If so, repeat the cycle.
	(
		((units _assaultGroup) isEqualTo []) || 
		((units _targetGroup) isEqualTo []) || 
		(((leader _assaultGroup) distance2D (leader _targetGroup)) > (_startDistance * 1.5)) || 
		(if (_exit isEqualType "") then {missionNamespace getVariable [_exit, false]} else {_exit})
	)
};

if ADF_debug then {[format ["ADF_fnc_sad - SAD canceled for group %1 assaulting group %2. Deleting the assault group.", _assaultGroup, _targetGroup]] call ADF_fnc_log};
[_assaultGroup] call ADF_fnc_delete;