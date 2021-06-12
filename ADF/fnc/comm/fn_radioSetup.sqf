/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: TFAR/ACRE radio setup
Author: Whiztler
Script version: 1.01

File: fn_radioSetup
**********************************************************************************
ABOUT
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX

OPTIONAL PARAMETERS:
1. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
2. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
3. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
4. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        

EXAMPLES USAGE IN SCRIPT:
XXXXXXXXXXXXXXXXXXXXXXXXXXX

EXAMPLES USAGE IN EDEN:
XXXXXXXXXXXXXXXXXXXXXXXXXXX

DEFAULT/MINIMUM OPTIONS
XXXXXXXXXXXXXXXXXXXXXXXXXXX

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (time < 180 || {ADF_extRpt || {ADF_debug}}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_radioSetup"};

// Let's check if we need to execute this function. If no TFAR or ACRE is active then terminate.
if !(ADF_mod_ACRE && ADF_mod_TFAR) exitWith {["ADF_fnc_radioSetup - No TFAR or ACRE addon present. Exiting"] call ADF_fnc_log; false}; 




