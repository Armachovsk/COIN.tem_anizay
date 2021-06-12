/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Objects Grabber
Author: Joris-Jan van 't Land/BIS. Edited for ADF by Whiztler
Script version: 1.00

File: fn_objectsGrabber.sqf
***********************************************************************************
ABOUT
Converts objects created in 3den or scripted to an array. The array can be used for
the BIS object mapper function (BIS_fnc_objectsMapper). 

The ADF objectsGrabber function is more accurate than the BIS objectsGrabber
function which is bugged for objects placed at an altitude.

INSTRUCTIONS:
Call the function from the server or a HC.

REQUIRED PARAMETERS:
0. Position:     Anchor (center) position. Marker, object, trigger or position array [x,y,z].

OPTIONAL PARAMETERS:
2. Integer:      Radius from center position in meters. Default: 50 meters
3. Bool:         Use Pich/Bank for very precise placement?
                 - true = enable (default)
                 - false = disable. Output will be [0,0]
4. Bool          Use precise object direction?
                 - true = enable (default)
                 - false = disable. Direction will be rounded up.
5. Bool          Use precise object altitude placement?
                 - true = enable (default)
                 - false = disable. The object will be created slightly (1.5 cm) above the
				   intended position.
				   
EXAMPLES USAGE IN SCRIPT:
[hookObject, 100, false, false, false] call ADF_fnc_objectsGrabber;
["myMarker", 75, false, false, true] call ADF_fnc_objectsGrabber;

EXAMPLES USAGE IN EDEN:
[this, 100] call ADF_fnc_objectsGrabber;

DEFAULT/MINIMUM OPTIONS
["Marker"] call ADF_fnc_objectsGrabber;

RETURNS:
Array of objects to be used with the objectsMapper function
*********************************************************************************/

params [
	["_anchorPosition", [0,0,0], [[], "", objNull]],
	["_radius", 50, [0]],
	["_usePitchBank", true, [false]],
	["_preciseDirection", true, [false]],
	["_preciseAltitude", true, [false]],
	["_orientation", [], [[]]]
];
private _br = toString [13, 10];
private _tab = toString [9];
private _result = "[" + _br;

if (_anchorPosition isEqualType "" && {_anchorPosition in allMapMarkers}) then {_anchorPosition = getMarkerPos _anchorPosition};
if (_anchorPosition isEqualType objNull) then {_anchorPosition = getPosATL _anchorPosition};

private _grabbedObjects = nearestObjects [_anchorPosition, ["All"], _radius];


//First filter illegal objects
{
	//Exclude non-dynamic objects (world objects)
	private _allDynamic = allMissionObjects "All";
	
	if (_x in _allDynamic) then {	
		//Exclude characters
		private _sim = getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "simulation");
		
		if (_sim in ["soldier"]) then {_grabbedObjects set [_forEachIndex, -1];};
	} else {_grabbedObjects set [_forEachIndex, -1];};
} forEach _grabbedObjects;

_grabbedObjects = _grabbedObjects - [-1];	

//Process remaining objects
{		
	private _typeOf = typeOf _x;
	private _objectPosition = getPosATL _x;
	private _delta_x = (_objectPosition select 0) - (_anchorPosition select 0);
	private _delta_y = (_objectPosition select 1) - (_anchorPosition select 1);
	private _delta_z = _objectPosition select 2;
	private _direction = direction _x;		
	private _fuel = fuel _x;
	private _damage = damage _x;
	private _varName = vehicleVarName _x;
	private _init = _x getVariable ["init", ""];
	private _simulation = _x getVariable ["simulation", true];	
	private _replaceBy = _x getVariable ["replaceBy", ""];
	private _orientation = [0,0];
	if (!_preciseDirection) then {
		if (_direction >= 100) then {_direction = (round (_direction/10))*10
		} else {
			_direction = round _direction
		};
	};
	if (_direction == 360) then {_direction = 0};
	if _usePitchBank then {_orientation = _x call BIS_fnc_getPitchBank;};
	if (_replaceBy != "") then {_typeOf = _replaceBy;};
	if !_preciseAltitude then {
		_delta_z = (round (_delta_z * 100))/100;
		_delta_z = _delta_z + 0.01;
	};
	
	_outputArray = [_typeOf, [_delta_x, _delta_y, _delta_z], _direction, _fuel, _damage, _orientation, _varName, _init, _simulation, false];
	_result = _result + _tab + (str _outputArray);
	_result = if (_forEachIndex < ((count _grabbedObjects) - 1)) then {_result + ", " + _br} else {_result + _br};
} forEach _grabbedObjects;

_result = _result + "]";
copyToClipboard _result;

_result