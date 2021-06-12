/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Module: Create Car Bomb
Author: Whiztler
Module version: 1.12

File: ADF_mod_createCarBomb.sqf
**********************************************************************************
This module creates a vehicle (default is a Fuel Track) in a predefined radius or
at a marker/trigger. The vehicle acts as a car bomb. The module aligns the vehicle
with the road and creates a trigger that will set off the bomb. 

INSTRUCTIONS:
Execute the module on the SERVER or HC only!
*********************************************************************************/

/****  vv  COPY FROM HERE  vv  *****/
///// DO NOT EDIT BELOW
diag_log "ADF rpt: Init - executing: ADF_mod_createCarBomb.sqf";
[
///// DO NOT EDIT ABOVE

/*
	Step 1.	Copy from (COPY FROM HERE) till (COPY TILL HERE) into your script for each car bomb instance.
	Step 2.	Place a marker on the map. This will be the location where the car bomb vehicle will be created. See below comment for more info.
	Step 2.	Fill out below parameters
	Note: Don't worry about the many comments as the ARMA engine ignores comments.
*/

"carBombMarker",    //  The (approx) position where thecarBomb vehicle should be created. This can be:
                    //  * Marker name (string) of a eclipse/rectangle marker. The vehicle will be placed in the marker area randomly.
                    //  * Marker icon for direct placed. The vehicle spawns at the marker and the direction of the vehicle will be the marker azimuth.
                    //  * Object. The vehicle spawns at or next to an existing object.
                    //  * Array. Position array [X,Y,Z]
                    
west,               //  Side that triggers the carBomb explosion. Usually the player side. Can be west, east, independent. Default: west

10,                 //  The carBomb trigger area. This is the radius in meters around the vehicle that activates the car bomb. Default: 10

"C_Van_01_fuel_F"	//  The class name of the vehicle that acts as the car bomb vehicle. Default: "C_Van_01_fuel_F"  (civilian fuel truck)

///// DO NOT EDIT BELOW
] call ADF_fnc_createCarBomb;
/****  ^^  COPY TILL HERE  ^^  *****/
