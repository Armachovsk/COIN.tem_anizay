/****************************************************************
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Mission Briefing
Author: Whiztler
Script version: 1.42

Game type: COOP
File: ADF_Briefing.sqf
****************************************************************
Instructions:

Note the reverse order of topics. Start from the bottom.
Change the "Text goes here..." line with your info. Use a <br/> to
start a new line.
****************************************************************/

diag_log "ADF rpt: Init - executing: briefing.sqf"; // Reporting. Do NOT edit/remove
if !hasInterface exitWith {};

///// CREDITS
player createDiaryRecord ["Diary",[localize "STR_ADF_briefing_creditsHeader",localize "STR_ADF_briefing_creditsBody"]];

///// OPORD
player createDiarySubject ["COINOPORD","COIN OPORD"];
player createDiaryRecord ["COINOPORD",[localize "STR_ADF_briefing_OpOrdHeader", localize "STR_ADF_briefing_OpOrdBody"]];

///// CAMPAIGN
player createDiarySubject ["COINMIS",localize "STR_ADF_briefing_COIN_Missions"];
player createDiaryRecord ["COINMIS",[localize "STR_ADF_briefing_gameMasterHeader", localize "STR_ADF_briefing_gameMasterBody"]];
player createDiaryRecord ["COINMIS",[localize "STR_ADF_briefing_serverInfoHeader", localize "STR_ADF_briefing_serverInfoBody"]];
player createDiaryRecord ["COINMIS",[localize "STR_ADF_briefing_clientInfoHeader", localize "STR_ADF_briefing_clientInfoBody"]];
player createDiaryRecord ["COINMIS",["1st Recon Bn",localize "STR_ADF_briefing_1stReconBody"]];
player createDiaryRecord ["COINMIS",[localize "STR_ADF_briefing_backgroundHeader",localize "STR_ADF_briefing_backgroundBody"]];
player createDiaryRecord ["COINMIS",[localize "STR_ADF_briefing_AboutHeader", localize "STR_ADF_briefing_AboutBody"]];