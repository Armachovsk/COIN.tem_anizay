/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_teleport
Author: Whiztler
Script version: 1.15

File: fn_teleport.sqf
**********************************************************************************
ABOUT
This can be used to teleport players to a specific location (marker, object,
position)

INSTRUCTIONS:
Place an object (flag pole, vehicle, etc.) and copy the following into the init
field of the placed object:

this addAction ["<t align='left' color='#E4F2AA'>Teleport</t>",
{[_this # 1, AAAA, BBBB, CCCC] spawn ADF_fnc_teleport;}, 
[], 6, true, true, "", "true" , 8]; this allowDamage false;

REQUIRED PARAMETERS:
Position:      Teleport position. Marker, object, trigger, team leader 
               or position array [x,y,z]
				
OPTIONAL PARAMETERS:
String:        The name of the teleport location. Default: "the RV location"
Number:        Delay in seconds (0 is no delay). Default: 30
				
EXAMPLE TELEPORT TO TEAM LEADER
this addAction ["<t align='left' color='#E4F2AA'>Teleport</t>", 
{[_this # 1, leader player, "your team leader", 10] spawn ADF_fnc_teleport;}, 
[], 6, true, true, "", "true" , 8]; this allowDamage false;

EXAMPLE TELEPORT TO A MARKER POSITION
this addAction ["<t align='left' color='#E4F2AA'>Teleport</t>", 
{[_this # 1, "myTeleportMarker", "the RV location", 10] spawn ADF_fnc_teleport;}, 
[], 6, true, true, "", "true" , 8]; this allowDamage false;

RETURNS
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_teleport"};

// Only players
if !hasInterface exitWith {diag_log "ADF Debug: ADF_fnc_teleport - ERROR! This entity cannot execute this function!"};

params [
	["_unit", player, [objNull]],
	["_position", [0,0,0], [objNull, "", [], grpNull]],
	["_positionName", "the RV location", [""]],
	["_pause", 30, [0]],
	["_direction", 0, [0]],
	["_inVehicle", false, [true]],
	["_toGroup", false, [true]]	
];

private _leader = leader (group _unit);
private _destination = _position;
private _distance = [_unit, _destination] call ADF_fnc_checkDistance;

switch (typeName _position) do {

	case "STRING": {
		if (_position in allMapMarkers) then {_direction = markerDir _position};
		_destination = _unit;
	};		
	
	case "OBJECT": {
		_direction = getDir _position; 
		if (_position isKindOf "Man") then {
			if (!isNull objectParent _leader) then {_inVehicle = true};
			_toGroup = true;
		} else {
			if (_position isKindOf "AllVehicles") then {
				if ((({_position emptyPositions _x} forEach ["Commander", "Driver", "Gunner", "Cargo"]) + 1) > 0) then {_inVehicle = true};
			};
		};
	};		
	
	case "GROUP": {
		_direction = getDirVisual _leader;
		if (!isNull objectParent _leader) then {_inVehicle = true};
		_toGroup = true;
	};
	
	case "ARRAY";
	default {_direction = random 360};
};

// Check the position location	
_position = [_position] call ADF_fnc_checkPosition;

// Debug
if ADF_debug then {[format ["ADF_fnc_teleport - Unit: %1 | Teleport Position: %2 (%3) | Name: %4 | Delay: %5 secs | Distance: %6 meters",_unit, mapGridPosition _position, _destination, _positionName, _pause, _distance]] call ADF_fnc_log};

// Exit if player is the group leader for group teleport	
if (_toGroup && {_unit == _leader}) exitWith {hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_isLeader", name _unit];};

// Exit if the teleport location is < 250 meters away	
if (_distance < 250) exitWith {hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_tooClose", name _unit, _distance, mapGridPosition _position];};

// Check if the target is alive/mobile
if (_destination isEqualType objNull && {!(alive _destination)}) exitWith {hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_unavail", name _unit, if (_destination isKindOf "Man") then {name _destination} else {_destination}];};

// Check vars defined
if (isNil "ADF_clanLogo") then {ADF_clanLogo = ""};
if (isNil "ADF_mod_ACE3") then {ADF_mod_ACE3 = false};

private _f = {
	titleText [localize "STR_ADF_telePort_teleporting", "BLACK OUT", 2, true, true];
	uiSleep 2;
};

private _t = {
	params ["_unit", "_position", "_leader"];		
	hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_toVehicle", name _unit, name _leader];
	titleText ["", "BLACK IN", 2];
	if ADF_mod_ACE3 then {[_unit, currentWeapon _unit, currentMuzzle _unit] call ACE_SafeMode_fnc_lockSafety;};
	uiSleep 8; hintSilent "";	
};

if (_inVehicle) exitWith {	
	scopeName "ADF_TeleportVeh";
	if (((vehicle _leader) emptyPositions "commander") > 0) then {
		[] call _f;
		sleep 1;
		_unit assignAsCommander (vehicle _leader);
		_unit moveInCommander (vehicle _leader);			
		[_unit, "commander", _leader] call _t;
		breakOut "ADF_TeleportVeh";
	};
	if (((vehicle _leader) emptyPositions "gunner") > 0) then {
		[] call _f;
		sleep 1;
		_unit assignAsGunner (vehicle _leader);
		_unit moveInGunner (vehicle _leader);
		[_unit, "gunner", _leader] call _t;
		breakOut "ADF_TeleportVeh";
	};
	if (((vehicle _leader) emptyPositions "driver") > 0) then {
		[] call _f;
		sleep 1;
		_unit assignAsDriver (vehicle _leader);
		_unit moveInDriver (vehicle _leader);
		[_unit, "driver", _leader] call _t;
		breakOut "ADF_TeleportVeh";
	};
	if (((vehicle _leader) emptyPositions "cargo") > 0) then {
		[] call _f;
		sleep 1;
		_unit assignAsCargo (vehicle _leader);
		_unit moveInCargo (vehicle _leader);
		[_unit, "cargo", _leader] call _t;
		breakOut "ADF_TeleportVeh";
	};
	// No space in vehicle
	hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_noSpaceInVeh", name _unit, name _leader];
};

waitUntil {
	_pause = _pause - 1;
	hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_timerHint",name _unit, _positionName, _pause];
	sleep 1;		
	(!alive _unit || _pause < 1);
};

call _f;
sleep 1;
_unit setPosATL _position;
hintSilent parseText format ["<img size= '6' shadow='false' image='" + ADF_clanLogo + localize "STR_ADF_telePort_teleported",name _unit, _positionName];
titleText ["", "BLACK IN", 2];
if ADF_mod_ACE3 then {[_unit, currentWeapon _unit, currentMuzzle _unit] call ACE_SafeMode_fnc_lockSafety;};
uiSleep 8; hintSilent "";	