// World Config 0.92
call {
	COIN_ambientAir = true;
	COIN_ACT = true;
	COIN_IED = true;
	COIN_africanTheme = false;
	COIN_sides_maxGradHi = 0.07;
	COIN_sides_maxGradlow = 0.025;
	COIN_EasterEgg = [];
	if (ADF_WorldName isEqualTo "RESHMAAN") exitWith {
		COIN_WorldName = localize "STR_ADF_worldNames_reshmaan"; // size: 20480
		COIN_EasterEgg = [
			[[18732.8, 17740.5, 0], 190], 
			[[2504.66, 12538.6, 0], 120], 
			[[3362.31, 2046.92, 0], 115], 
			[[13028.2, 1298.94, 0], 20], 
			[[9272.99, 15349.4, 0], 140]
		];
	};
	if (ADF_WorldName isEqualTo "CLAFGHAN") exitWith { // size: 20480
		COIN_WorldName = localize "STR_ADF_worldNames_clafghan";
		COIN_sides_maxGradHi = 0.25;
		COIN_sides_maxGradlow = 0.1;
		COIN_EasterEgg = [
			[[9306.56, 8192.47, 0], 265], 
			[[17220.3, 14569.1, 0], 95], 
			[[8714.5, 18479.5, 0], 150]
		];
	};
	if (ADF_WorldName isEqualTo "TAKISTAN") exitWith { // size: 12800
		COIN_WorldName = localize "STR_ADF_worldNames_takistan";
		COIN_EasterEgg = [
			[[1620.98, 8798.12, 0], 0], 
			[[1063.46, 11437.1, 0], 0], 
			[[4203.18, 7505.88, 0], 0], 
			[[8666.83, 10789.8, 0], 0], 
			[[10830.8, 5553.28, 0], 0], 
			[[8035.69, 12239.6, 0], 0], 
			[[6590.59, 3775.04, 0], 0]
		];
	};
	if (ADF_WorldName isEqualTo "FATA") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_fata";
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.15;
		COIN_sides_maxGradlow = 0.07;
	};
	if (ADF_WorldName isEqualTo "TORABORA") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_toraBora";
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.15;
		COIN_sides_maxGradlow = 0.07;
	};
	if (ADF_WorldName isEqualTo "TEM_ANIZAY") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_anizay";
		COIN_ambientAir = false;
	};
	if (ADF_WorldName isEqualTo "DYA") exitWith { // size: 8192
		COIN_WorldName = localize "STR_ADF_worldNames_diyala";
		COIN_ambientAir = false;
	};
	if (ADF_WorldName isEqualTo "MCN_ALIABAD") exitWith { // size: 5120
		COIN_WorldName = localize "STR_ADF_worldNames_aliabad";
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.15;
		COIN_sides_maxGradlow = 0.05;
	};
	if (ADF_WorldName isEqualTo "TEM_KUJARI") exitWith { // size: 16384
		COIN_WorldName = localize "STR_ADF_worldNames_kujari";
		COIN_africanTheme = true;  // African theme maps
		COIN_ambientAir = false;
		COIN_EasterEgg = [
			[[452.97, 4197.01, 0], 0], 
			[[3027.61, 10191.6, 0], 305], 
			[[15562.1, 7184.64, 0], 5], 
			[[15961.4, 14993.4, 0], 0], 
			[[143.964, 11085.4, 0], 55], 
			[[10976.9, 9451.98, 0], 290]
		];
	};
	if (ADF_WorldName isEqualTo "PJA307") exitWith { // size: 20480
		COIN_WorldName = localize "STR_ADF_worldNames_dariya";
		COIN_africanTheme = true;  // African theme maps
		COIN_ACT = false;
		COIN_IED = false;
	};	
	if (ADF_WorldName isEqualTo "SWU_PUBLIC_SALMAN_MAP") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_al-salman";
		COIN_ambientAir = false;		
	};	
	if (ADF_WorldName isEqualTo "ZARGABAD") exitWith { // size: 8192
		COIN_WorldName = localize "STR_ADF_worldNames_zargabad";
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.15;
		COIN_sides_maxGradlow = 0.03;
	};	
	if (ADF_WorldName isEqualTo "SARALITE") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_sahrani";
		COIN_ambientAir = false;
	};	
	if (ADF_WorldName isEqualTo "LYTHIUM") exitWith { // size: 20480
		COIN_WorldName = localize "STR_ADF_worldNames_lythium";
		COIN_EasterEgg = [
			[[1303.76, 18607.8, 0], random 360], 
			[[18677.2, 18346.1, 0], random 360], 
			[[19512, 8632.06, 0], random 360], 
			[[3517.49, 11255.9, 0], 100], 
			[[2065.02, 1657.45, 0], 290]
		];
		COIN_sides_maxGradHi = 0.17;
		COIN_sides_maxGradlow = 0.09;
	};
	if (ADF_WorldName isEqualTo "PJA310") exitWith { // size: 20480
		COIN_WorldName = localize "STR_ADF_worldNames_al-rayak";
		COIN_EasterEgg = [
			[[11846.5, 7014.78, 0], 30], 
			[[18535.7, 8561.32, 0], 60], 
			[[16974.6, 15845.3, 0], 340], 
			[[5740.07, 18885.6, 0], 0], 
			[[6658.98, 12408.7, 0], 345], 
			[[12972.5, 11556.2, 0], 280], 
			[[14247.8, 1798.34, 0], 320]
		];
	};
	if (ADF_WorldName isEqualTo "FARKHAR") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_farkhar";
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.13;
		COIN_sides_maxGradlow = 0.06;
	};
	if (ADF_WorldName isEqualTo "DINGOR") exitWith { // size: 10240
		COIN_WorldName = localize "STR_ADF_worldNames_dingor";
		COIN_EasterEgg = [
			[[2222.89, 3531, 0], 0], 
			[[3783.14, 7720.1, 0], 0], 
			[[5539.61, 1803.71, 0], 0]
		];
	};
	if (ADF_WorldName isEqualTo "CHONGO") exitWith { // size: 12288 
		COIN_WorldName = localize "STR_ADF_worldNames_chongo";
		COIN_africanTheme = true;  // African theme maps
		COIN_ambientAir = false;
		COIN_sides_maxGradHi = 0.2;
		COIN_EasterEgg = [
			[[9806.4, 2642.51, 0], 235], 
			[[2162.34, 8953.08, 0], 255], 
			[[5362.31, 8515.34, 0], 85]
		];
	};
};


