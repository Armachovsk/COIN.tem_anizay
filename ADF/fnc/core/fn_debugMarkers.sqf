/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_debugMarkers
Author: Whiztler
Script version: 1.03

File: fn_debugMarkers.sqf
**********************************************************************************
ABOUT
The function tracks foot mobiles, road vehicles, ships and aircraft. The function
does NOT keep track of new created groups.

INSTRUCTIONS:
Execute from the server after spawning an AO.

REQUIRED PARAMETERS:
N/A

OPTIONAL PARAMETERS:
0. Bool:		Enable/disable the debug markers
			- true: enable the tracker.
			- false: Disable the tracker (Default).
1. Side:	west, east, independent, civilian (default: east) 

EXAMPLES USAGE IN SCRIPT:
[true, west] call ADF_fnc_debugMarkers;

EXAMPLES USAGE IN EDEN:
[true, east] call ADF_fnc_debugMarkers;

DEFAULT/MINIMUM OPTIONS
[] call ADF_fnc_debugMarkers; // will disable tracking

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_debugMarkers"};

// Init
params [
	["_enable", true, [false]],
	["_side", east, [west]],
	["_allUnits", [], [[]]],
	["_color", "", [""]]
];

// Check if debug markers should be displayed
if !(_enable) exitWith {};

// Cancel debug markers using the action menu.
ADF_debug_cancel_markers = false;

// Populate side units array
if (_side countSide allUnits == 0) exitWith {[format ["ADF_fnc_debugMarkers - units side %1: 0. Terminating tracker!", _side]] call ADF_fnc_log};
{if (alive _x && side _x == _side) then {_allUnits pushBackUnique _x}} forEach allUnits;	
[format ["ADF_fnc_debugMarkers - Tracker activiated for side %1: (%2 units)", _side, count _allUnits]] call ADF_fnc_log;	

// Set the marker color
switch _side do {
	case west: {_color = "colorBLUFOR";};		
	case independent: {_color = "colorIndependent";};
	case civilian: {_color = "colorCivilian";};
	case east;
	default {_color = "colorOPFOR";};	
};

// spawn a thread for each unit tracking it movement
{
	[_x, _color] spawn {
		
		// Init
		params ["_unit", "_color"];
		private _size = .5;
		private _type = "mil_triangle_noShadow";
		private _alpha = 1;

		// Check if the unit is in a vehhicle. Larger marker for drivers to represent vehicle
		if !(isNull objectParent _unit) then {
			
			// if the unit is the driver the set the marker
			if (_unit == driver (vehicle _unit)) then {
				if ((vehicle _unit) isKindOf "Helicopter") then {
					_size = 1;	
				} else {
					_type = "mil_arrow2_noShadow";	
				};

			// If the unit is a gunner or is in cargo the make the marker transparent
			} else {
				_alpha = 0;
			};
		};
		
		// Create the initial marker
		private _m = createMarker [format ["m_%1", _unit], getPos _unit];
		_m setMarkerShape "ICON";
		_m setMarkerType _type;
		_m setMarkerSize [_size, _size];
		_m setMarkerDir (getDir _unit);
		_m setMarkerColor _color;
		_m setMarkerAlpha _alpha;
		
		// Start marker update loop per unit
		waitUntil {
			_m setMarkerPos [getPos _unit select 0, getPos _unit select 1];
			_m setMarkerDir (getDir _unit);
			sleep .5;
			(ADF_debug_cancel_markers || !alive _unit)
		};
		
		// Unit is no longer alive. Change the marker color to black
		_m setMarkerColor "ColorBlack";
		_m setMarkerType "mil_destroy";
		_m setMarkerAlpha 1;

	};
} forEach _allUnits;

true