/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission events
Author: Whiztler
Script version: 1.02

File: ADF_mission_playerRespawn
**********************************************************************************
Add here any scripts you wish to be executed when a player respawns.

You cannot suspend the script. Using SLEEP, WAITUNTIL or WHILE/DO will break the
script.  Create a new thread ([] spawn {insert sleepy code here};) for code that
requires pausing.

PARAMETERS
_unit      Object - Object the event handler is assigned to
_corpse    Object - Object the event handler was assigned to, aka the corpse/unit
                    player was previously controlling

RETURNS:
an alive player
*********************************************************************************/

params ["_unit", "_corpse"];

