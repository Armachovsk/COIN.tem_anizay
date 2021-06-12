/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: CAS request with 9-liner
Author: Whiztler
Module version: 1.12

File: ADF_mod_cas.sqf
**********************************************************************************
This module will create a CAS request radio trigger with 9-liner simulated
communication messages.

INSTRUCTIONS:
Execute the module on ALL CLIENTS (server, players, HC's)!
********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_cas.sqf";
///// DO NOT EDIT ABOVE

/*
	Step 1:	Copy from (COPY FROM HERE) into your script.
	Step 2:	you'll need to place two markers:
			1. marker where the aircraft will spawn. 
			2. marker for the approach vector (North, east, South or west) of the AO.	
	Step 3.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

// the name of the unit that can request the CAS. Use a commander or JTAC.
ADF_CAS_requester = "INF_XO";

// the call sign of your squad/platoon/coy/unit
ADF_CAS_groupName = "ALPHA 1-1";

// This is where the CAS aircraft will spawn. Place a marker on the edge of map far from the AO. Name the marker: "mAirSupport"
ADF_CAS_spawn = getMarkerPos "mAirSupport"; 

 // Approach vector marker. The CAS aircraft will first fly to an approach vector before he flies to the CAS AO. Name the marker: "mAirSupportVector"
ADF_CAS_vector = getMarkerPos "mAirSupportVector";

// Delay (in seconds) for the CAS to be created. This is simulate that the CAS aircraft needs to depart from a distant airbase + time to go through emergency start-up procedures.
ADF_CAS_delay = round (180 + (random 60)); 

 // Time spend in the CAS area. After which the CAS aircraft returns to the spawn location and is deleted.
ADF_CAS_onSite = round (120 + (random 120));

// Size of the CAS radius. Blue circular marker that shows the CAS AO. Default is 800 meters
ADF_CAS_aoTriggerRad	= 800; 

// Side of the CAS aircraft/crew
ADF_CAS_side = west;

// ingame callsign of CAS aircraft. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_callSign = "HAWK"; 

// ingame name of the pilot of the CAS aircraft. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_pilotName = "Lt. Jim (Blackjack) Decker";

// ingame call sign  of the CAS station. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_station = "OSCAR";

// ingame call sign of OpFor. E.g. TANGO, CSAT, etc. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_targetName	= "ELVIS"; 

// Ingame description of target (keep it short). 
ADF_CAS_targetDesc	= "victors, small arms"; 

// CAS requirements (interdict, destroy, area security, laser target, etc. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_result = "interdict";

// direction of the approach vector (from AO). Depends on ADF_CAS_vector marker placement. Used for hint messages to simulate CAS request radio transmissions.
ADF_CAS_apprVector	= "west";

// Callsign of HQ / Command / Base. Used for hint messages to simulate CAS request radio transmissions.
ADF_HQ_callSign = "FIRESTONE";

// Callsign image (filetype PAA) of CAS unit. Used for hint messages to simulate CAS request radio transmissions. The default image is of 6 Shooters 6CAV squadron.
ADF_CAS_image = 'ADF\bin\images\logo_CAS.paa';

// Callsign image (filetype PAA) of HQ / Command / Base. Used for hint messages to simulate CAS request radio transmissions.
ADF_HQ_image = "";

// Log message in logbook (true/false)? If true, what is the logbook name?
ADF_CAS_log = false;
ADF_CAS_logName = "";

///// DO NOT EDIT BELOW
call ADF_fnc_cas;