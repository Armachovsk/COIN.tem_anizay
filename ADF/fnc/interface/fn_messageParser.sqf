/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_messageParser
Author: Whiztler
Script version: 1.04

File: fn_messageParser.sqf
**********************************************************************************
ABOUT
This function is used by the Message Parser module (ADF_mod_messageParser.sqf).
It processes messages configured in the Message Parser module:

- Display a hint
- Stamp the message in the logbook (if configured as true in the module)

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_messageParser"};

if !hasInterface exitWith {};

// Init
params [
	"_caller_ID",
	"_receiver_ID",
	"_message"
];
private _origin = ADF_messageParserConfig # 0;
private _caller = ADF_messageParserConfig find _caller_ID;
private _receiver = ADF_messageParserConfig find _receiver_ID;

// Check if a logo has been defined
if (isNil "ADF_clanLogo") then {ADF_clanLogo = ""};

private _imageHeader = if ((ADF_messageParserConfig # (_caller + 2)) != "") then {format ["<img size= '5' shadow='false' image='mission\images\%1'/>", ADF_messageParserConfig # (_caller + 2)]} else {""};

// Radio transmission squelch sound
playSound "radioTransmit";

// Compile message and display to client
private _compiledMessage = format [localize "STR_ADF_messageParser", toUpperANSI (ADF_messageParserConfig # (_receiver + 1)), toUpperANSI (ADF_messageParserConfig # (_caller + 1)), _message];
hintSilent parseText format ["%1<br/><br/><t color='%2' align='left' size='1.1' font='EtelkaNarrowMediumPro'>%3</t><br/><br/>"	,_imageHeader , ADF_messageParserColor, _compiledMessage];

if ((ADF_messageParserConfig # _caller) != _origin && ADF_messageParserLog) then {[ADF_messageParserConfig # (_caller + 1), _compiledMessage] call ADF_fnc_MessageLog};

true