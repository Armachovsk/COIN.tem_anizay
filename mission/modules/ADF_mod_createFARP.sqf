/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: ADF_mod_createFARP
Author: Whiztler
Module version: 1.01

File: ADF_MOD_createFARP.sqf
**********************************************************************************
The createFARP module creates Repair/Refuel/Rearm site (F.A.R.P.). There are
three FARP types you can create: car, helicopter, jet plane.
The FARPS are fully dressed up with FARP objects. AlMost all objects have
simulation disabled making it performance efficient.

INSTRUCTIONS:
Execute the module on the SERVER only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_MOD_createFARP.sqf";
if (isNil "ADF_fnc_createFARP") then {call compile preprocessFileLineNumbers "ADF\fnc\spawn\ADF_fnc_createFARP.sqf"};
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) into your script (Server) for each FARP you want to create.
	Step 2.	Create an icon (type none or mil icon) marker on the map.
			Give the marker a unique name. E.g. vehicleFARP1
			The marker is th center position of the FARP. The marker orientation (azimuth) will determine the FARP orientation (direction).
	Step 3.	Fill out below parameters
	Note: Don't worry about the many comments as the ARMA engine ignores comments.	
*/

"vehicleFARP1", // Change "vehicleFARP1" with the name of the marker where you want the FARP created. Make sure to wrap the name in "".
"car"           // Which kind of FARP:
                // - "car" for a vehicle FARP (all road vehicles, incl tracked vehicles)
                // - "heli" for helicopters. Cannot be used by jet/prop aircraft.
                // - "jet" for jet/prop aircraft. Cannot be used by helicopters.
                
///// DO NOT EDIT BELOW
] call ADF_fnc_createFARP;