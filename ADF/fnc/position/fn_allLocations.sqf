/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: All Locations
Author: Whiztler
Script version: 1.00

File: fn_allLocations.sqf
***********************************************************************************
ABOUT
A location is a position in Arma defined by the map maker. Usually this is a town, \
airfield, army base - normally a significant item on the map.
This functions grabs all locations within a specfied radius from a specified
position.

It returns an array with the following:

select 0 - Index number.
select 1 - Name of the location formatted as a "string".
select 2 - Type of location (e.g. NameCity) formatted as a "string".
select 3 - Position of the location [x, y, z].
select 4 - Size in meters of the location
select 5 - true/false. If this a Military Location?
select 6 - true/false. Is this an airport/airbase location?

[[8, "Pyrgos", "NameCityCapital", [1234,1153,1.5], 821, false, false], [9, "Pyrgos Port", "NameMarine", [1214,1133,0.32], 68, false, false]]

INSTRUCTIONS:
Call the function from any client.

REQUIRED PARAMETERS:
0. Position:     Center position. Marker, object, trigger or position array [x,y,z].

OPTIONAL PARAMETERS:
2: Integer:      Radius from center position in meters
3: String/Array: Type of location to search for:
                 - "string" - single type, e.g. "NameLocal"
                 - array - array of types e.g. ["NameCity", "Airport", "NameMarine"]

EXAMPLES USAGE IN SCRIPT:
["myMarker", 1000, "NameCity"] call ADF_fnc_allLocations;
["myMarker", 800, ["NameVillage", "NameCity", "NameCityCapital"]] call ADF_fnc_allLocations;

EXAMPLES USAGE IN EDEN:
[this, 750] call ADF_fnc_allLocations;

DEFAULT/MINIMUM OPTIONS
["Marker"] call ADF_fnc_allLocations;

RETURNS:
Array of locations (see above)
*********************************************************************************/

// init
params [
	 ["_centerPosition", [0, 0, 0], ["", objNull, grpNull, locationNull, []]],
	 ["_radius", 500, [0]],
	 ["_types", true, [true, []]],
	 ["_allLocations", [], [[]]],
	 ["_militaryLocation", false, [true]],
	 ["_AirportLocation", false, [true]]
];
private _locationTypes = if (_types isEqualType true && {_types}) then {
	["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Airport", "NameMarine"]
} else {
	if (_types isEqualType "") then {[_types]} else {[_types]};
};

// Validate
if (_centerPosition isEqualType "" && {!(_centerPosition in allMapMarkers)}) exitWith {[format ["ADF_fnc_allLocations - %1 does not appear to be a valid marker. Exiting", _centerPosition], true] call ADF_fnc_log;};
private _position = [_centerPosition] call ADF_fnc_checkPosition;
if (_position isEqualTo [0,0,0]) exitWith {["ADF_fnc_allLocations - invalid position [0,0,0] passed. Exiting!", true] call ADF_fnc_log;};
if (_radius > 50000) then {_radius = 50000};

// Add specified locations to the allLocations array
{
	private _i = _forEachIndex;
	private _type = _x;
	{
		if (toUpperANSI (text _x) in ["MILITARY", "AIRBASE"]) then {_militaryLocation = true;};
		if (toUpperANSI (text _x) in ["AIRPORT", "AIRBASE"]) then {_AirportLocation = true;};	
		_allLocations pushBack [
			_i,
			text _x,			
			type _x,
			locationPosition _x,
			size _x,
			_militaryLocation,
			_AirportLocation
		];
	} forEach nearestLocations [_position, [_type], _radius];	
} forEach _locationTypes;

_allLocations