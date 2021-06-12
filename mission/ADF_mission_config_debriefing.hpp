/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission config entries
Author: Whiztler
Script version: 1.51

File: ADF_mission_debriefing.hpp
*********************************************************************************
Here you can define the various mission endings, The information is show at the
end of the mission.

More information: https://community.bistudio.com/wiki/Description.ext#CfgDebriefing
and https://community.bistudio.com/wiki/Debriefing
*********************************************************************************/

class CfgDebriefing
{  
	class End1
	{
		title = $STR_ADF_debriefing_end1Title;
		subtitle = $STR_ADF_debriefing_subTitle;
		description = $STR_ADF_debriefing_end1Desc;
		//pictureBackground = "mission\images\loadScreen_TwoSierra.jpg"; // eg. "img\yourpicture.jpg" no picture? use "";
		picture = "mission\images\logo_1recon.paa"; // Marker icon
		pictureColor[] = {0.0,0.3,0.6,1}; // Overlay color
	};
	
	class End2
	{
		title = $STR_ADF_debriefing_end2Title;
		subtitle = $STR_ADF_debriefing_subTitle;
		description = $STR_ADF_debriefing_end2Desc;
		//pictureBackground = "mission\images\loadScreen_TwoSierra.jpg"; // eg. "img\yourpicture.jpg" no picture? use "";
		picture = "mission\images\logo_1recon.paa"; // Marker icon
		pictureColor[] = {0.0,0.3,0.6,1}; // Overlay color
	};
	
	class Killed
	{
		title = $STR_ADF_debriefing_end3Title;
		subtitle = $STR_ADF_debriefing_subTitle;
		description = "Bravo Co R.I.P.";
		//pictureBackground = "mission\images\loadScreen_TwoSierra.jpg"; // eg. "img\yourpicture.jpg" no picture? use "";
		picture = "mission\images\logo_1recon.paa"; // Marker icon
		pictureColor[] = {0.0,0.3,0.6,1}; // Overlay color
	};
};

