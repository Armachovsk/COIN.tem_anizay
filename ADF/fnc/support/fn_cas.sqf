/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_CAS
Author: Whiztler
Script version: 1.07

File: fn_CAS.sqf
**********************************************************************************
This function is exclusively used by the Create CAS module

INSTRUCTIONS:
Spawn from script on server + players.

REQUIRED PARAMETERS:
see \missions\modules\ADF_mod_cas.sqf

OPTIONAL PARAMETERS:
see \missions\modules\ADF_mod_cas.sqf

EXAMPLE
[] call ADF_fnc_CAS;

RETURNS:
Bool
*********************************************************************************/

// Reporting
diag_log "ADF rpt: fnc - executing: ADF_fnc_CAS";
if (isNil "ADF_CAS_requester") exitWith {["ADF_fnc_CAS - CAS support was activated but the CAS_requester was not defined by the mission maker! Exciting.", true] call ADF_fnc_log; false};

// Init
ADF_CAS_pos = []; 
ADF_CAS_active = false;
ADF_CAS_marker = false;
ADF_CAS_bingoFuel 	= false;
ADF_CAS_requester = call compile format ["%1", ADF_CAS_requester];
ADF_CAS_kia = false;
ADF_CAS_clanName = toUpperANSI ADF_clanName;

ADF_CAS_destroyVars = {
	ADF_CAS_pos = nil;
	ADF_CAS_active = nil;
	ADF_CAS_marker = nil;
	ADF_CAS_bingoFuel 	= nil; 
	ADF_CAS_spawn = nil;
	ADF_CAS_vector = nil;
	ADF_CAS_delay = nil;
	ADF_CAS_onSite = nil;
	ADF_CAS_callSign = nil;
	ADF_CAS_station = nil;
	ADF_CAS_targetName	= nil;
	ADF_CAS_targetDesc	= nil;
	ADF_CAS_result = nil;
	ADF_CAS_apprVector	= nil;
	ADF_HQ_callSign = nil;
	ADF_CAS_aoTriggerRad	= nil;
	ADF_CAS_log = nil;
	ADF_CAS_logName = nil;
	ADF_CAS_groupName = nil;
	ADF_fnc_CAS_supportRq = nil;
	ADF_fnc_CAS_Activated = nil;
	if !isServer exitWith {};
	diag_log	"-----------------------------------------------------";
	diag_log "ADF rpt: CAS (server) terminated";
	diag_log	"-----------------------------------------------------";

	true
};

ADF_CAS_server = {
	// init
	private _markerClass = "";
	private _vehicleClass = "";

	waitUntil {sleep 1; ADF_CAS_marker}; // wait till the CAS request action was executed

	diag_log	"-----------------------------------------------------";
	diag_log "ADF rpt: CAS (server) activated";
	diag_log	"-----------------------------------------------------";

	// Create the CAS circle marker
	switch ADF_CAS_side do {
		case west		: {_markerClass = "ColorWEST"; _vehicleClass = "B_Heli_Attack_01_F"};
		case east		: {_markerClass = "ColorEAST"; _vehicleClass = "O_Heli_Attack_02_black_F"};
		case independent	: {_markerClass = "ColorGUER"; _vehicleClass = "I_Heli_light_03_F"};
	};	

	private _marker = createMarker ["mCAS_SAD", ADF_CAS_pos];
	_marker setMarkerSize [500, 500];
	_marker setMarkerShape "ELLIPSE";
	_marker setMarkerBrush "Border";
	_marker setMarkerColor _markerClass;
	_marker setMarkerDir 0;

	// Create the CAS AO triggerActivated
	tCAS = createTrigger ["EmptyDetector", ADF_CAS_pos];
	tCAS setTriggerActivation [str ADF_CAS_side, "PRESENT", true];
	tCAS setTriggerArea [ADF_CAS_aoTriggerRad, ADF_CAS_aoTriggerRad, 0, false];
	tCAS setTriggerStatements ["(vehicle ADF_vCAS in thisList && ((getPosATL ADF_vCAS) # 2) > 25)", "", ""];

	waitUntil {sleep 1; ADF_CAS_active}; // wait till the 9-liners are finished and CAS-delay timer is 0. 

	// Create CAS aircraft
	private _crew = createGroup ADF_CAS_side;
	_crew setGroupIdGlobal [format ["%1", ADF_CAS_callSign]];
	private _vehicle = [ADF_CAS_spawn, 90, _vehicleClass, _crew] call ADF_fnc_createCrewedVehicle;
	ADF_vCAS = _vehicle # 0;
	publicVariable "ADF_vCAS";
	ADF_vCAS allowDamage false;

	// Add an EH to the CAS aircraft. If the aircraft is killed/shot down it will trigger a CAS KIA message and exit the script
	ADF_vCAS addEventHandler ["killed", "ADF_CAS_bingoFuel = true; publicVariable 'ADF_CAS_bingoFuel';ADF_CAS_kia = true;"];

	// Attach marker to CAS aircraft
	[ADF_vCAS] spawn {	
		private _marker = createMarker ["mCasIcon", getPosASL ADF_vCAS];
		_marker setMarkerSize [.8, .8];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "b_air";
		_marker setMarkerColor "Colorwest";
		_marker setMarkerText format [" %1", ADF_CAS_callSign];
		while {alive ADF_vCAS} do {"mCasIcon" setMarkerPos (getPosASL ADF_vCAS); sleep .5};
		_marker setMarkerColor "ColorGrey"; // CAS aircraft is no more...
	};

	// Create waypoints for CAS aircraft based on appraoch vectors
	private _waypoint = _crew addWaypoint [ADF_CAS_vector, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointSpeed "FULL";
	_waypoint setWaypointCombatMode "BLUE";
	_waypoint setWaypointCompletionRadius 250;

	private _waypoint = _crew addWaypoint [ADF_CAS_pos, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "COMBAT";
	_waypoint setWaypointSpeed "NORMAL";
	_waypoint setWaypointCombatMode "RED";

	waitUntil {triggerActivated tCAS}; // Let CAS aircraft reach the AO

	ADF_vCAS flyInHeight (25 + (random 10));

	if (ADF_CAS_kia) exitWith {call ADF_CAS_destroyVars};
	sleep ADF_CAS_onSite; // Limited time in AO
	if (ADF_CAS_kia) exitWith {call ADF_CAS_destroyVars};

	// RTB Bingo Fuel
	deleteMarker "mCAS_SAD";
	{[_x] call ADF_fnc_heliPilotAI} forEach units _crew;
	[_crew] call ADF_fnc_delWaypoint; 
	ADF_CAS_bingoFuel = true; publicVariable "ADF_CAS_bingoFuel";
	ADF_vCAS setFuel 0.3;	

	private _waypoint = _crew addWaypoint [ADF_CAS_vector, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointSpeed "FULL";
	_waypoint setWaypointCombatMode "BLUE";
	_waypoint setWaypointCompletionRadius 350;

	private _waypoint = _crew addWaypoint [ADF_CAS_spawn, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointSpeed "FULL";
	_waypoint setWaypointCombatMode "BLUE";
	_waypoint setWaypointCompletionRadius 350;
	ADF_vCAS flyInHeight 100;
	waitUntil {
		sleep 0.5;
		if (ADF_CAS_kia) exitWith {call ADF_CAS_destroyVars};
		(currentWaypoint (_waypoint # 0)) > (_waypoint # 1)
	};

	// Delete CAS heli and its crew
	if !(ADF_CAS_kia) then {[ADF_vCAS] call ADF_fnc_delete;};
	deleteMarker "mCasIcon";

	call ADF_CAS_destroyVars;
};

ADF_CAS_activated = {
	// Init
	private _msg_position = str (format ["%1 . %2", round (ADF_CAS_pos # 0), round (ADF_CAS_pos # 1)]);
	private _dummy = createVehicle ["Land_HelipadEmpty_F", ADF_CAS_pos, [], 0, "CAN_COLLIDE"];
	private _dummyPosition	= getPosASL _dummy;
	private _msg_msl	= round (_dummyPosition # 2);
	[_dummy] call ADF_fnc_delete;

	private _eta	= [ADF_CAS_spawn, ADF_CAS_pos, 275] call ADF_fnc_calcTravelTime; 
	private _eta_mins	= str (floor ((ADF_CAS_delay / 60) + (_eta # 1)));

	// NLT
	private _hour	= date # 3;
	private _minutes	= date # 4;
	if ((_minutes + 10) >= 60) then {
		_hour	= _hour + 1;
		_minutes	= (_minutes + 10) - 60; 
	} else {_minutes = _minutes + 10};

	private _msg_nlt = format ["%1:%2", _hour, _minutes];

	ADF_CAS_marker = true; publicVariableServer "ADF_CAS_marker";

	if !hasInterface exitWith {};

	// 9-liner CAS procedure
	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='%4'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1 this is %3. Request %2. How copy?</t><br/><br/>", ADF_CAS_callSign, ADF_CAS_station, ADF_CAS_groupName, ADF_clanLogo];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_CAS_groupName+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>"+ ADF_CAS_callSign +" this is "+ ADF_CAS_groupName +". Request "+ ADF_CAS_station +". How copy?</font><br/><br/>"]];
	};
	sleep 6;

	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_CAS_image+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1: %3 this is %2. Ready to copy. Over.</t><br/><br/>", ADF_CAS_pilotName, ADF_CAS_callSign, ADF_CAS_groupName];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: "+ ADF_CAS_callSign +"</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/>	<font color='#6C7169'>"+ ADF_CAS_pilotName +": " +ADF_CAS_groupName+ " this is "+ ADF_CAS_callSign +". Ready to copy. Over.</font><br/><br/>"]];
	};
	sleep 9;

	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_clanLogo+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1 with %2:</t><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>PRIORIY: #1</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>TARGET: %3, %4</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>LOCATION: %5, %6 MSL</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>TARGET TIME: NLT %7</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>RESULT: %8</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>CONTROL: %10 command</t><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>REMARKS: Vectors %9, Friendlies close. How copy?</t><br/><br/>", ADF_CAS_callSign, ADF_CAS_station, ADF_CAS_targetName, ADF_CAS_targetDesc, _msg_position, _msg_msl, _msg_nlt, ADF_CAS_result, ADF_CAS_apprVector, ADF_CAS_groupName];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_CAS_groupName+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/>		<font color='#6C7169'>"+ ADF_CAS_callSign +" with "+ ADF_CAS_station +":<br/><br/>PRIORIY: #1<br/><br/>TARGET: " +ADF_CAS_targetName+ ", " +ADF_CAS_targetDesc+ "<br/><br/>LOCATION: "+ _msg_position +", "+ str _msg_msl +" MSL<br/><br/>TARGET TIME: NLT "+ _msg_nlt +"<br/><br/>RESULT: " +ADF_CAS_result+ "<br/><br/>CONTROL: " +ADF_CAS_groupName+ " command<br/><br/>REMARKS: Vectors "+ ADF_CAS_apprVector +", Friendlies close. How copy?</font><br/><br/>"]];
	};
	sleep 30;

	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_CAS_image+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1: Read back. PRIORIY: #1, TARGET: %2, %3, LOCATION: %4, %5 MSL, NLT %6, RESULT: %7, CONTROL: %9, REMARKS: Vectors %8, Friendlies close. Over.</t><br/><br/>", ADF_CAS_pilotName, ADF_CAS_targetName, ADF_CAS_targetDesc, _msg_position, _msg_msl, _msg_nlt, ADF_CAS_result, ADF_CAS_apprVector, ADF_CAS_groupName];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_CAS_callSign+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>"+ ADF_CAS_pilotName +": Read back. PRIORIY: #1, TARGET: " +ADF_CAS_targetName+ ", " +ADF_CAS_targetDesc+ ", LOCATION: "+ _msg_position +", "+ str _msg_msl +" MSL, NLT "+ _msg_nlt +", RESULT: " +ADF_CAS_result+ ", CONTROL: " +ADF_CAS_groupName+ ", REMARKS: Vectors "+ ADF_CAS_apprVector +", Friendlies close. Over.</font><br/><br/>"]];
	};
	sleep 18;

	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_clanLogo+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>Read back correct. Execute %1. Cleared %1. How Copy?</t><br/><br/>", ADF_CAS_station];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_CAS_groupName+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>Read back correct. Execute " +ADF_CAS_station+ ". Cleared " +ADF_CAS_station+ ". How Copy?</font><br/><br/>"]];
	};
	sleep 8;

	playSound "radioTransmit";
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_CAS_image+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1: Go on %2. ETA %3 Mikes. Out.</t><br/><br/>", ADF_CAS_pilotName, ADF_CAS_station, _eta_mins];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_CAS_callSign+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>" +ADF_CAS_callSign+ ": Go on " +ADF_CAS_station+ ". ETA "+ _eta_mins +" Mikes. Out.</font><br/><br/>"]];
	};

	// Time from map entrance it will take CAS to reach the AO
	if ADF_debug then {diag_log format ["ADF rpt: ADF_fnc_CAS_Activated - CAS delay sleep: %1",ADF_CAS_delay]};
	sleep ADF_CAS_delay; 

	// Inform the server to create the CAS vehicle
	ADF_CAS_active = true; publicVariableServer "ADF_CAS_active"; 

	// Wait till the CAS ao timer runs out
	waitUntil {sleep 3; ADF_CAS_bingoFuel}; 

	if (!alive ADF_vCAS) exitWith { // CAS is kia!
		hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_clanLogo+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1 this is %3. %2 is down. How copy?</t><br/><br/>", ADF_HQ_callSign, ADF_CAS_callSign, ADF_CAS_groupName];
		sleep 9;
		hintSilent parseText"<img size= '5' shadow='false' image='image='" +ADF_HQ_image+ "'/>'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>" +ADF_CAS_groupName+ " this is" +ADF_HQ_callSign+ ". Solid Copy. We'll inform AOC. Stay on mission. Out.</t><br/><br/>";
		if (ADF_CAS_log) then {
			private _logTime = [dayTime] call BIS_fnc_timeToString; private _logTimeText = "Log: " + _logTime;
			player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: " +ADF_HQ_callSign+ "</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>" +ADF_CAS_groupName+ " this is " +ADF_HQ_callSign+ ". Solid copy. We'll inform AOC. Stay on mission. Out.</font><br/><br/>"]];
		};		
		sleep 12;
		hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_clanLogo+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1 this is %3. Roger. Out.</t><br/><br/>", ADF_HQ_callSign, ADF_CAS_callSign, ADF_CAS_groupName];
		call ADF_CAS_destroyVars;
	};	

	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_CAS_image+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%2: %3 this is %1 with bingo fuel. We are RTB. Over.</t><br/><br/>", ADF_CAS_callSign, ADF_CAS_pilotName, ADF_CAS_groupName];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString; private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [ADF_CAS_logName, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: "+ ADF_CAS_callSign +"</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>"+ ADF_CAS_pilotName +": " +ADF_CAS_groupName+ " this is " +ADF_CAS_callSign+ " with bingo fuel. We are RTB. Over.</font><br/><br/>"]];
	};
	sleep 11;
	hintSilent parseText format ["<img size= '5' shadow='false' image='" +ADF_clanLogo+ "'/><br/><br/><t color='#6C7169' size='1.1' font='EtelkaNarrowMediumPro' align='left'>%1 this is %3. Roger. Thanks for the assist. Out.</t><br/><br/>", ADF_CAS_callSign, ADF_CAS_groupName];
	call ADF_CAS_destroyVars;
};

ADF_CAS_request = {
	// Init
	params ["_u", "_i"];

	// Remove the action
	_u removeAction _i;

	// Map click process.
	if (player == ADF_CAS_requester) then {openMap true; hintSilent format ["\n%1, click on a location\n on the map where you want\nClose Air Support.\n\n", name _u]};
	ADF_CAS_requester onMapSingleClick {
		ADF_CAS_pos = _pos;
		publicVariableServer "ADF_CAS_pos";
		onMapSingleClick ""; true;
		openMap false; hint "";
		[] spawn ADF_CAS_activated;
		remoteExec ["ADF_CAS_server", 2, false];
	};
};


// Add the action to the unit that can request CAS
if !(isNil "ADF_CAS_requester") then {
	if !(player == ADF_CAS_requester) exitWith {false};
	private _menuText = format ["<t align='left' color='#92b680' shadow='false'>Request CAS: %1", ADF_CAS_callSign];
	ADF_CAS_requester addAction [
		_menuText,{
			[_this select 1, _this select 2] remoteExec ["ADF_CAS_request", 0, true]
		},[],-95, false, true,"", ""
	];
};

if hasInterface then {
	if (ADF_CAS_active || ADF_CAS_marker) exitWith {};
	if (ADF_debug || !isMultiplayer) then {sleep 30} else {sleep (30 + (random 130) + (random 130))};
	if (ADF_CAS_active || ADF_CAS_marker) exitWith {};
	private _n	= format ["%1 log", ADF_clanName];
	hintSilent parseText format ["<img size= '5' shadow='false' image='%4'/><br/><br/><t color='#6C7169' align='left' size='1.1' font='EtelkaNarrowMediumPro'>%1: %5 this is %2. Standing by with %3. Out.</t><br/><br/>", ADF_CAS_pilotName, ADF_CAS_callSign, ADF_CAS_station, ADF_CAS_image, ADF_CAS_groupName];
	if (ADF_CAS_log) then {
		private _logTime = [dayTime] call BIS_fnc_timeToString;
		private _logTimeText = "Log: " + _logTime;
		player createDiaryRecord [_n, [_logTimeText,"<br/><br/><font color='#9da698' size='14'>From: "+ ADF_CAS_callSign +"</font><br/><font color='#9da698' size='14'>Time: " + _logTime + "</font><br/><br/><font color='#6c7169'>------------------------------------------------------------------------------------------</font><br/><br/><font color='#6C7169'>" +ADF_CAS_pilotName+ ": " +ADF_CAS_groupName+ " this is " +ADF_CAS_callSign+ ". Standing by with " +ADF_CAS_station+ ". Out.</font><br/><br/>"]];	
	};
};

true