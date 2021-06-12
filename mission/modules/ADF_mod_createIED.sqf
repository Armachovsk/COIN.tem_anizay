/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create IED('s)
Author: Whiztler
Module version: 1.18

File: ADF_mod_createIED.sqf
**********************************************************************************
This module creates IED's. There are three way's of creating IED's:

1.  Create a single IED at a marker position (icon marker, no radius)
2.  Create multiple IED's from an array with markers. E.g.:
    ["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"]
3.  Create IED's in a rectangular or eclipse sized maker.

INSTRUCTIONS:
Execute the module on the SERVER only!
*********************************************************************************/

/****  vv  COPY FROM HERE TILL THE END  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createIED.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) into your script for each IED series you want to create.
	Step 2.	Determine how you want the IED's to be created. Options are:
			1.  Create a single IED at a marker position (icon marker, no radius)
			2.  Create multiple IED's from an array with markers. E.g.:
				["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"]
			3.  Create multiple IED's in a rectangular or eclipse sized maker.   
	Step 3.	Fill out below parameters
    Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

"IEDposition",  // The position(s) where the IED('s) will be created. Depending on marker/array input. E.g.:
                //  * Marker icon (string) for direct placed. The IED is created within the given radius position
                //  * Array of markers. E.g. ["IED_1", "IED_2", "IED_3", "IED_4", "IED_5", "IED_6", "IED_7"]
                //  * Marker name (string) of a eclipse/rectangle marker. The IED's will be created in the marker area randomly.

west,           // Side that activates the IED trigger. Usually the player side. Can be west, east or independent. Default: west

10,             // The number of IED's created within a marker area. Only change when using in combination with an eclipse/rectangle marker. Default: 1

100,            // Random position placement radius in meters. Default: 100

250             // Radius to search for suitable road position with the random position placement. Default: 250

4.5             // Road offset in meters. The is the width of the road. Large road is approx 6. Smaller road is 4.5. Default: 4.5

///// DO NOT EDIT BELOW
] call ADF_fnc_createIED;