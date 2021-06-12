/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Mission Params
Author: Whiztler
Script version: 1.02

Game type: n/a
File: ADF_mission_config_params.sqf
*********************************************************************************
Configure mission specific params here.
*********************************************************************************/

class customBlank_1 {title = ""; values[] = {-999}; default = -999; texts[] = {""};};	
class customBlank_2 {
	title = "---------- MISSION PARAMS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
	values[] = {-999};
	default = -999;
	texts[] = {""};
};
class customBlank_3 {title = ""; values[] = {-999}; default = -999; texts[] = {""};};


class ADF_missionTime {
	title = $STR_ADF_params_startTime;
	values[] = {0, 1, 2, 3, 4, 5, 6, 7};
	texts[] = {$STR_ADF_params_startTimeOptions1, $STR_ADF_params_startTimeOptions2, $STR_ADF_params_startTimeOptions3, $STR_ADF_params_startTimeOptions4, $STR_ADF_params_startTimeOptions5, $STR_ADF_params_startTimeOptions6, $STR_ADF_params_startTimeOptions7, $STR_ADF_params_startTimeOptions8};
	default = 0;
};

class ADF_AO_missions {
	title = $STR_ADF_params_aoMissions;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_side_missions {
	title = $STR_ADF_params_sideMissions;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_air_traffic {
	title = $STR_ADF_params_airTraffic;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_map_IEDs {
	title = $STR_ADF_params_map_ieds;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_map_ACT {
	title = $STR_ADF_params_act;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_ACT_VBEDs {
	title = $STR_ADF_params_act_vbeds;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_ACT_armedCiv {
	title = $STR_ADF_params_act_armedCivs;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};

class ADF_ACT_suicideBombers {
	title = $STR_ADF_params_act_suicideBombers;
	values[] = {0,1};
	texts[] = {$STR_ADF_disabled, $STR_ADF_enabled};
	default = 1;
};
