/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_allAlivePlayers
Author: Whiztler
Script version: 1.00

File: fn_allAlivePlayers.sqf
**********************************************************************************
ABOUT
This function returns all current alive players (minus the headless client). 

INSTRUCTIONS:
call from the server or HC
    
REQUIRED PARAMETERS:
Not applicable

OPTIONAL PARAMETERS:
Not applicable

EXAMPLE
call ADF_fnc_allAlivePlayers;

RETURNS:
Array of all alive players
*********************************************************************************/

(allPlayers - entities "HeadlessClient_F") select {alive _x};

