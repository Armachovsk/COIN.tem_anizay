diag_log "ADF rpt: Init - executing: scripts/init_vehicles.sqf"; // Reporting. Do NOT edit/remove

/*********************************************************************
MIDDLE EAST VEHICLES by Whiztler
v 1.04

Sets variables for TKA/Milita vehicles based on active mods

Requires:
- RHS USAF/AFRF/GREF + Project Opfor and/or 3CB Factions mods. 
  -or-
- CUP Weapons/Vehicles + Community Factions Project
*********************************************************************/
private _army_tank_heavy = [];
private _army_tank_light = [];
private _army_apc_heavy = [];
private _army_apc_light = [];
private _army_allArmor = [];
private _army_allAPC = [];
private _army_Static_HMG = [];
private _army_Static_D30 = [];
private _army_Static_ZU23 = [];
private _army_truck = [];
private _army_car = [];
private _army_tech = [];
private _army_allCars = [];
private _army_heli_CAS = [];
private _army_heli_trp = [];
private _army_air_CAS = [];
private _civ_car = [];
private _civ_tech = [];
private _flag_Afghan = [];
private _flag_Iraq = [];
private _flag_Pesh = [];
private _flag_SLA = [];

if ADF_mod_PROPFOR then {
	// TKA
	_army_tank_heavy append ["LOP_TKA_T72BA", "LOP_TKA_T72BA", "LOP_TKA_ZSU234"];
	_army_tank_light append ["LOP_TKA_T34", "LOP_TKA_T55"];
	_army_apc_heavy append ["LOP_TKA_BMP1", "LOP_TKA_BMP1D", "LOP_TKA_BMP2", "LOP_TKA_BMP2D", "LOP_TKA_BTR60", "LOP_TKA_BTR70"];
	_army_apc_light append ["rhsgref_BRDM2", "rhsgref_BRDM2_ATGM"];

	_army_Static_HMG append ["LOP_TKA_Static_DSHKM", "LOP_AM_OPF_Kord_High", "LOP_AM_OPF_Static_M2"];
	_army_Static_D30 append ["LOP_TKA_Static_D30"];
	_army_Static_ZU23 append ["LOP_TKA_ZU23"];

	_army_truck append ["LOP_TKA_Ural", "LOP_TKA_Ural_open", "LOP_TKA_Ural_open"];
	_army_car append ["LOP_TKA_UAZ", "LOP_TKA_UAZ_Open", "rhsgref_BRDM2UM", "LOP_TKA_UAZ"];
	_army_tech append ["LOP_TKA_BM21", "LOP_TKA_UAZ_AGS", "LOP_TKA_UAZ_DshKM", "LOP_TKA_UAZ_SPG", "LOP_TKA_UAZ_AGS"];

	_army_heli_CAS append ["LOP_TKA_Mi24V_AT", "LOP_TKA_Mi24V_FAB", "LOP_TKA_Mi24V_UPK23", "LOP_TKA_Mi8MTV3_FAB", "LOP_TKA_Mi8MTV3_UPK23"];
	_army_heli_trp append ["LOP_TKA_Mi8MT_Cargo"];

	_army_air_CAS append ["LOP_TKA_Mi24V_FAB", "LOP_TKA_Mi24V_UPK23"];

	// Cars Civilian
	_civ_car append ["LOP_CHR_civ_Landrover", "LOP_CHR_civ_UAZ"];
	_civ_tech append ["LOP_AM_OPF_Landrover_M2", "LOP_AM_OPF_Landrover_SPG9", "LOP_ISTS_OPF_Nissan_PKM", "LOP_AM_OPF_Offroad_AT"];

	// Props
	_flag_Afghan append ["lop_flag_Afghan_f"];
	_flag_Iraq append ["lop_flag_Iraq_f"];
	_flag_Pesh append ["lop_flag_pesh_f"];
	_flag_SLA append ["lop_Flag_sla_F"];	
};

if ADF_mod_3CB_FACT then {
	// TKA
	_army_tank_heavy append ["UK3CB_TKA_O_ZsuTank", "UK3CB_TKA_O_T72A", "UK3CB_TKA_O_T72BM"];
	_army_tank_light append ["UK3CB_TKA_O_T34", "UK3CB_TKA_O_T55"];
	_army_apc_heavy append ["UK3CB_TKA_O_BMP1", "UK3CB_TKA_O_BMP1", "UK3CB_TKA_O_BMP2", "UK3CB_TKA_O_BMP2K", "UK3CB_TKA_O_BTR60", "UK3CB_TKA_O_BTR70"];
	_army_apc_light append ["UK3CB_TKA_O_BRDM2", "UK3CB_TKA_O_BRDM2_ATGM"];

	_army_Static_HMG append ["UK3CB_TKA_O_DSHKM", "UK3CB_TKA_O_KORD_high"];
	_army_Static_D30 append ["UK3CB_TKA_B_D30"];
	_army_Static_ZU23 append ["UK3CB_TKA_O_ZU23"];

	_army_truck append ["UK3CB_TKA_O_Ural", "UK3CB_TKA_O_Ural_Open", "UK3CB_TKA_O_Ural_Fuel", "UK3CB_TKA_O_Ural_Repair", "UK3CB_TKA_O_Ural_Ammo"];
	_army_car append ["UK3CB_TKA_O_UAZ_Closed", "UK3CB_TKA_O_UAZ_Open", "UK3CB_TKA_O_BRDM2_HQ", "UK3CB_TKA_O_Hilux_Closed"];
	_army_tech append ["UK3CB_TKA_O_UAZ_AGS30", "UK3CB_TKA_O_UAZ_MG", "UK3CB_TKA_O_UAZ_SPG9", "UK3CB_TKA_O_Hilux_GMG", "UK3CB_TKA_O_Hilux_Dshkm", "UK3CB_TKA_O_Hilux_Pkm", "UK3CB_TKA_O_Hilux_Spg9", "UK3CB_TKA_O_BM21", "UK3CB_TKA_O_Ural_Zu23"];

	_army_heli_CAS append ["UK3CB_TKA_O_Mi_24V", "UK3CB_TKA_O_Mi_24V", "UK3CB_TKA_O_Mi_24V", "UK3CB_TKA_O_Mi8AMTSh"];
	_army_heli_trp append ["UK3CB_TKA_O_Mi8AMT"];

	_army_air_CAS append ["UK3CB_TKA_O_L39_CAS", "UK3CB_TKA_O_Su25SM_CAS"];

	// Cars Civilian
	_civ_car append ["UK3CB_TKC_C_LR_Closed", "UK3CB_TKC_C_UAZ_Closed"];
	_civ_tech append ["UK3CB_TKM_O_UAZ_SPG9", "UK3CB_TKM_O_UAZ_Dshkm", "UK3CB_TKM_O_LR_SF_M2", "UK3CB_TKM_O_LR_SPG9", "UK3CB_TKM_O_LR_M2", "UK3CB_TKM_O_Hilux_Zu23", "UK3CB_TKM_O_Hilux_Spg9", "UK3CB_TKM_O_Hilux_Pkm", "UK3CB_TKM_O_Hilux_Dshkm", "UK3CB_TKM_O_Hilux_Rocket_Arty", "UK3CB_TKM_O_Hilux_GMG", "UK3CB_TKM_O_Datsun_Pkm"];

	// Props
	_flag_Afghan append ["Flag_AFG_13"];
	_flag_Iraq append ["Flag_TKC"];
	_flag_Pesh append ["Flag_ANA"];
	_flag_SLA append ["Flag_TKA"];	
};

if ADF_mod_CFP then { // Community Factions Project (requires CUP W/V/U)
	// TKA
	_army_tank_heavy append ["CUP_O_ZSU23_TK", "CUP_O_T72_TKA", "CUP_O_T72_TKA"];
	_army_tank_light append ["CUP_O_T34_TKA", "CUP_O_T55_TK"];
	_army_apc_heavy append ["CUP_O_BMP1_TKA", "CUP_O_BMP1P_TKA", "CUP_O_BMP2_TKA", "CUP_O_BMP2_ZU_TKA", "CUP_O_BTR60_TK", "CUP_O_BTR80_TK", "CUP_O_BTR80A_TK"];
	_army_apc_light append ["CUP_O_BRDM2_TKA", "CUP_O_BTR40_TKA", "CUP_O_BMP_HQ_TKA", "CUP_O_M113_Med_TKA", "CUP_O_BRDM2_ATGM_TKA", "CUP_O_BTR40_MG_TKA", "CUP_O_M113_TKA"];

	_army_Static_HMG append ["CUP_O_KORD_high_TK", "CFP_O_RUARMY_KORD_DES_01"];
	_army_Static_D30 append ["CUP_O_D30_TK", "CUP_O_D30_AT_TK"];
	_army_Static_ZU23 append ["CUP_O_ZU23_TK"];

	_army_truck append ["CUP_O_Ural_TKA", "CUP_O_V3S_Open_TKA", "CUP_O_Ural_Open_TKA", "CUP_O_V3S_Covered_TKA", "CUP_O_Ural_Refuel_TKA", "CUP_O_V3S_Rearm_TKA", "CUP_O_Ural_Reammo_TKA", "CUP_O_V3S_Repair_TKA", "CUP_O_Ural_Repair_TKA", "CUP_O_V3S_Refuel_TKA"];
	_army_car append ["CUP_O_LR_Ambulance_TKA", "CUP_O_M113_Med_TKA", "CUP_O_BTR40_MG_TKA", "CUP_O_BRDM2_HQ_TKA", "CUP_O_UAZ_Open_TKA", "CUP_O_UAZ_Unarmed_TKA", "CUP_O_LR_Transport_TKA", "CUP_O_LR_Transport_TKM"];
	_army_tech append ["CUP_O_LR_MG_TKA", "CUP_O_UAZ_SPG9_TKA", "CUP_O_UAZ_METIS_TKA", "CUP_O_UAZ_MG_TKA", "CUP_O_UAZ_AGS30_TKA", "CUP_O_LR_SPG9_TKA"];

	_army_heli_CAS append ["CUP_O_UH1H_gunship_TKA", "CUP_O_Mi24_D_Dynamic_TK"];
	_army_heli_trp append ["CUP_O_UH1H_TKA", "CUP_O_MI6A_TKA", "CUP_O_UH1H_armed_TKA", "CUP_O_Mi17_VIV_TK", "CUP_O_Mi17_TK", "CUP_O_MI6T_TKA"];

	_army_air_CAS append ["CUP_O_L39_TK", "CUP_O_Su25_Dyn_TKA"];

	// Cars Civilian
	_civ_car append ["CUP_O_Hilux_unarmed_TK_INS", "CFP_O_TBAN_Hilux_01", "CUP_O_Hilux_armored_unarmed_TK_INS"];
	_civ_tech append ["CUP_O_Hilux_armored_zu23_TK_INS", "CUP_O_Hilux_armored_UB32_TK_INS", "CUP_O_Hilux_armored_SPG9_TK_INS", "CUP_O_Hilux_armored_podnos_TK_INS", "CUP_O_Hilux_armored_MLRS_TK_INS", "CUP_O_Hilux_armored_M2_TK_INS", "CUP_O_Hilux_armored_DSHKM_TK_INS", "CUP_O_Hilux_armored_BTR60_TK_INS", "CUP_O_Hilux_armored_BMP1_TK_INS", "CUP_O_Hilux_SPG9_TK_INS", "CUP_O_Hilux_MLRS_TK_INS", "CUP_O_Hilux_M2_TK_INS", "CUP_O_Hilux_DSHKM_TK_INS", "CUP_O_Hilux_btr60_TK_INS", "CUP_O_Hilux_BMP1_TK_INS", "CFP_O_TBAN_Hilux_AGS_30_01", "CFP_O_TBAN_Hilux_DShKM_01", "CFP_O_TBAN_Hilux_Igla_01", "CFP_O_TBAN_Hilux_Metis_01", "CFP_O_TBAN_Hilux_MLRS_01", "CFP_O_TBAN_Hilux_Podnos_01", "CFP_O_TBAN_Hilux_SPG_01", "CFP_O_TBAN_Hilux_UB_32_01", "CFP_O_TBAN_Hilux_ZU_23_01", "CFP_O_TBAN_Offroad_Armed_01", "CFP_O_TBAN_Technical_PK_01"];

	// Props
	_flag_Afghan append ["Afghanistan_Flag"];
	_flag_Iraq append ["Iraq_Flag"];
	_flag_Pesh append ["FreeSyrianArmyFSA_Flag"];
	_flag_SLA append ["FlagCarrierNorth"];	
};

{_army_allArmor append _x} forEach [_army_tank_heavy, _army_tank_light, _army_apc_heavy];
{_army_allAPC append _x} forEach [_army_apc_heavy, _army_apc_light];
{_army_allCars append _x} forEach [_army_truck, _army_car, _civ_car];

