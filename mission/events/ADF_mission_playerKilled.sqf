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

File: ADF_mission_playerKilled
**********************************************************************************
Add here any scripts you wish to be executed when a player dies. 

You cannot suspend the script. Using SLEEP, WAITUNTIL or WHILE/DO will break the
script.  Create a new thread ([] spawn {insert sleepy code here};) for code that
requires pausing.

PARAMETERS PASSED:              
_unit          the player
_killer        unit that killed the player
_instigator    Object/Person who pulled the trigger
_useEffects    Boolean - same as useEffects in setDamage alt syntax
*********************************************************************************/

params ["_unit", "_killer", "_instigator", "_useEffects"];
diag_log format ["ADF rpt: Client %1 was killed by %2 / %3.", _unit, _killer, _instigator];

//removeAllActions COIN_leadership;
if (_unit isEqualTo COIN_leadership) then {
	diag_log format ["« C O I N »   ADF_mission_playerKilled - Leadership player (%1) was KIA. Removing leadership actions", _unit];
	_unit removeAction airdropActionID;
	_unit removeAction airliftActionID;
	_unit removeAction airsupportActionID;
	_unit removeAction tanksupportActionID;
};