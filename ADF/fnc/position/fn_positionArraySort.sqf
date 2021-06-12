/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_positionArraySort
Author: Ruebe. Adapted for ADF by whiztler
Script version: 1.03

File: fn_positionArraySort.sqf
**********************************************************************************
ABOUT
Sorts an array of positions (z-axe, altitude), either ascending or descending. The
function is used by the ADF_fnc_buildingPositions function to find the highest 
located garrison positions within a building. In combination with the 
ADF_fnc_outsidePos function you can determine if the position is on a rooftop.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0: Array:       array of positions [x,y,z]

OPTIONAL PARAMETERS:
1: Variable:    Sort function:
                ADF_fnc_altitudeDescending for descending (default)
                ADF_fnc_altitudeAcending for ascending

EXAMPLES USAGE IN SCRIPT:
_arr = [allUnits, ADF_fnc_altitudeDescending] call ADF_fnc_positionArraySort;   

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
_a = [_builingPos] call ADF_fnc_positionArraySort;  

RETURNS:
Array
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_positionArraySort"};

// Init
params [
	["_array", [], [[]]],
	"_function"
];

// Check if array is not empty. Terminate script if it is
if ((count _array) == 0) exitWith {
	if ADF_debug then {[format ["ADF_fnc_positionArraySort - ERROR, array seems to be empty: %1. Exiting", _array]] call ADF_fnc_log};
	[]
};

for "_i" from 1 to ((count _array) - 1) do {
	private _selected = _array # _i;
	private _index = 0;

	for [{_index = _i}, {_index > 0}, {_index = _index - 1}] do {
		if (((_array # (_index - 1)) call _function) < (_selected call _function)) exitWith {};
		_array set [_index, (_array # (_index - 1))];
	};

	_array set [_index, _selected];
};

_array