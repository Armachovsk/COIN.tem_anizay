/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: mission config entries
Author: Whiztler
Script version: 1.52

File: ADF_mission_config.hpp
**********************************************************************************
Mission config entries. Below mission specific classes are automatically loaded
into the description.ext during mission init/
*********************************************************************************/

// COIN
class CfgVehicleTemplates {
	class TKA_BRDM2 {
		displayName = "RHS Gref BRDM 2 MG"; 
		author = "Red Hammer Studions";		
		textures[] = {
			"takistan",1
		};
	};
	
	class TKA_BTR70 {
		displayName = "RHS BTR 70"; 
		author = "Red Hammer Studions";	
		textures[] = {
			"Takistan",1
		};
		animationList[] = {
			"crate_l1_unhide",1,
			"crate_l2_unhide",1,
			"crate_l3_unhide",1,
			"crate_l4_unhide",1,
			"crate_r1_unhide",1,
			"crate_r2_unhide",1,
			"crate_r3_unhide",1,
			"crate_r4_unhide",1,
			"water_1_unhide",1,
			"water_2_unhide",1,
			"wheel_1_unhide",1,
			"wheel_2_unhide",1
		};
	};
	
	class TKA_Ural_Closed {
		displayName = "RHS Gref Ural Closed"; 
		author = "Red Hammer Studions";	
		textures[] = {
			"Camo7",1
		};
		animationList[] = {
			"spare_hide",0
			,"bench_hide",1,
			"people_tag_hide",0,
			"rear_numplate_hide",1,
			"light_hide",1
		};
	};

	class TKA_Ural_Repair {
		displayName = "RHS Gref Ural Repair"; 
		author = "Red Hammer Studions";	
		textures[] = {
			"Camo2",1
		};
		animationList[] = {
			"spare_hide",0
			,"bench_hide",1,
			"people_tag_hide",0,
			"rear_numplate_hide",1,
			"light_hide",1
		};
	};				
	
	class TKA_Ural {
		displayName = "RHS Gref Ural Open ZU "; 
		author = "Red Hammer Studions";	
		textures[] = {
			"Camo1",1
		};
		animationList[] = {
			"spare_hide",0
			,"bench_hide",1,
			"people_tag_hide",0,
			"rear_numplate_hide",1,
			"light_hide",1
		};
	};
	
	class TKA_Tank {
		displayName = "RHS T90 T72"; 
		author = "Red Hammer Studions";	
		textures[] = {
			"rhs_Sand",1
		};
	};		
};