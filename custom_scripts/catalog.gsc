#using custom_scripts\util;

#namespace cicada_catalog;

// every id below appears verbatim in the mwiii script dump. the game ships no master
// weapon table, so this list is what the shipped scripts actually reference.
function init()
{
    level.cicada_weapon_classes = [];
    // same token set scripts\cp_mp\weapon::getweaponrootname splits ids on
    foreach (code in cicada_util::list("ar,sm,lm,sh,sn,dm,pi,la,me,br"))
        level.cicada_weapon_classes[code] = true;

    level.cicada_catalog = [];
    level.cicada_groups = [];

    group("primaries", "assault rifles,battle rifles,sub machine guns,shotguns,light machine guns,snipers");
    group("secondaries", "launchers,pistols,misc");

    entries("assault rifles", "jup_jp01_ar_golf36,jup_jp19_ar_acharlie,jup_jp34_ar_balpha27,jup_jp36_ar_anov94,iw9_ar_akilo_mp,iw9_ar_augolf_mp,iw9_ar_mike4_mp");
    entries("battle rifles", "jup_jp02_br_bromeo2,jup_jp19_br_acharlie450,jup_cp08_br_xmike5");
    entries("sub machine guns", "jup_jp02_sm_scharlie3,jup_jp04_sm_umike,jup_cp01_sm_coscar635,iw9_sm_aviktor_mp,iw9_sm_mpapa5_mp,iw9_sm_mpapa7_mp,iw9_sm_papa90_mp");
    entries("shotguns", "jup_cp01_sh_aromeo410,jup_jp09_sh_oromeo12,jup_jp16_sh_recho870,jup_jp38_sh_spapa12,iw9_sh_charlie725_mp,iw9_sh_mbravo_mp,iw9_sh_mike1014_mp,iw9_sh_mviktor_mp,iw9_sh_tsierra12_mp,iw9_sh_vecho_mp");
    entries("light machine guns", "jup_jp01_lm_mgolf36,jup_jp06_lm_pkilop,jup_jp08_lm_qbravo95lsw,jup_jp20_lm_evictor,jup_jp28_lm_rpapa20,iw9_lm_dblmg_mp,iw9_lm_mkilo3_mp,iw9_lm_slima_mp");
    entries("snipers", "jup_jp10_sn_cdelta50,jup_jp13_sn_svictor,jup_jp17_sn_hsierra,jup_jp35_sn_moscar,jup_jp36_sn_boscar,iw9_sn_alpha50_mp,iw9_sn_india_mp,iw9_sn_limax_mp");

    entries("launchers", "jup_jp22_la_dromeo,jup_jp26_la_cluster,iw9_la_gromeo_mp,iw9_la_juliet_mp,iw9_la_kgolf_mp,iw9_la_mike32_mp,iw9_la_rpapa7_mp");
    entries("pistols", "jup_cp24_pi_glima21,jup_jp07_pi_uzulum,jup_jp12_pi_mike93,jup_jp14_pi_rsierra12,jup_jp32_pi_mpapa9,iw9_pi_decho_mp,iw9_pi_golf17_mp,iw9_pi_golf18_mp,iw9_pi_papa220_mp,iw9_pi_swhiskey_mp");
    // the compiler caps a single string literal, so the longer lists arrive in chunks
    entries("misc", "jup_jp23_me_knife,jup_jp23_me_spear,jup_me_shotel,jup_pi_goldengun_mp,jup_pi_raygun_mp,jup_la_humangun_mp,jup_la_plasmagun_mp");
    entries("misc", "iw9_me_riotshield_mp,iw9_me_knife_mp,iw9_me_fists_mp,iw9_me_kamas_mp,iw9_me_sword01_mp,iw9_me_tonfa_mp,iw9_me_buzzsaw_mp,iw9_pi_stimpistol_mp");

    entries("equipment", "frag_grenade_mp,semtex_mp,molotov_mp,thermite_mp,c4_mp,claymore_mp,throwingknife_mp,flash_grenade_mp,concussion_grenade_mp,smoke_grenade_mp,snapshot_grenade_mp");
    entries("equipment", "decoy_grenade_mp,cluster_grenade_mp,gas_grenade_mp,emp_grenade_mp,trophy_mp,at_mine_mp,shock_stick_mp,tac_camera_mp");
    entries("equipment", "jup_frag_grenade_mp,jup_c4_mp,jup_claymore_mp,jup_smoke_grenade_mp,jup_semtex_mike32_mp");

    // names passed to killstreaks::registerkillstreak across the dump
    entries("streaks", "uav,counter_uav,directional_uav,uav_bigmap,precision_airstrike,multi_airstrike,fuel_airstrike,cluster_spike,toma_strike,cruise_predator");
    entries("streaks", "sentry_gun,pac_sentry,manual_turret,remote_turret,remote_mg_turret,assault_drone,auto_drone,radar_drone_overwatch,radar_drone_recon,scrambler_drone_guard");
    entries("streaks", "hover_jet,chopper_gunner,chopper_support,gunship,juggernaut,death_switch,airdrop,airdrop_multiple,airdrop_escort,supply_sweep");
    entries("streaks", "emp,white_phosphorus,nuke,nuke_multi,nuke_select_location,circle_peek");

    // taken from scripts\mp\gametypes\arena::function_3dd5b16653c57b45
    level.cicada_camos = [];
    camos("camo_a_01,camo_b_01,camo_c_01,camo_d_01,camo_e_01,camo_f_01,camo_g_01,camo_h_01,camo_i_01,camo_j_01,camo_k_01,camo_l_01,camo_m_01,camo_n_01,camo_o_01,camo_p_01,camo_r_01,camo_comp_01");
    camos("camo_a_02,camo_b_02,camo_c_02,camo_d_02,camo_e_02,camo_f_02,camo_g_02,camo_h_02,camo_i_02,camo_j_02,camo_k_02,camo_l_02,camo_m_02,camo_n_02,camo_o_02,camo_p_02,camo_r_02,camo_comp_02");
    camos("camo_a_03,camo_b_03,camo_c_03,camo_d_03,camo_e_03,camo_f_03,camo_g_03,camo_h_03,camo_i_03,camo_j_03,camo_k_03,camo_l_03,camo_m_03,camo_n_03,camo_o_03,camo_p_03,camo_comp_03");
    camos("camo_a_04,camo_b_04,camo_c_04,camo_d_04,camo_e_04,camo_f_04,camo_g_04,camo_h_04,camo_i_04,camo_j_04,camo_k_04,camo_l_04,camo_m_04,camo_n_04,camo_o_04,camo_p_04,camo_comp_04");
    camos("camo_a_05,camo_b_05,camo_c_05,camo_d_05,camo_e_05,camo_f_05,camo_g_05,camo_h_05,camo_i_05,camo_j_05,camo_k_05,camo_l_05,camo_m_05,camo_n_05,camo_o_05,camo_p_05");
    camos("camo_a_06,camo_b_06,camo_c_06,camo_d_06,camo_e_06,camo_f_06,camo_g_06,camo_h_06,camo_i_06,camo_j_06,camo_k_06,camo_l_06,camo_m_06,camo_n_06,camo_o_06,camo_p_06");
    camos("camo_a_07,camo_b_07,camo_c_07,camo_d_07,camo_e_07,camo_f_07,camo_g_07,camo_h_07,camo_i_07,camo_j_07,camo_k_07,camo_l_07,camo_m_07,camo_n_07,camo_o_07,camo_p_07");
    camos("camo_a_08,camo_b_08,camo_c_08,camo_d_08,camo_e_08,camo_f_08,camo_g_08,camo_h_08,camo_i_08,camo_j_08,camo_k_08,camo_l_08,camo_m_08,camo_n_08,camo_o_08,camo_p_08");
    camos("camo_a_09,camo_b_09,camo_c_09,camo_d_09,camo_e_09,camo_f_09,camo_g_09,camo_h_09,camo_i_09,camo_j_09,camo_k_09,camo_l_09,camo_m_09,camo_n_09,camo_o_09");
    camos("camo_a_10,camo_b_10,camo_c_10,camo_d_10,camo_e_10,camo_f_10,camo_g_10,camo_h_10,camo_i_10,camo_j_10,camo_k_10,camo_l_10,camo_m_10,camo_n_10,camo_o_10");
    camos("camo_a_11,camo_b_11,camo_c_11,camo_d_11,camo_e_11,camo_f_11,camo_g_11,camo_h_11,camo_i_11,camo_j_11,camo_k_11,camo_l_11,camo_m_11,camo_n_11,camo_o_11");
    camos("camo_a_12,camo_b_12,camo_c_12,camo_d_12,camo_e_12,camo_f_12,camo_g_12,camo_h_12,camo_i_12,camo_j_12,camo_k_12,camo_l_12,camo_m_12,camo_n_12,camo_o_12");
    camos("camo_a_13,camo_b_13,camo_c_13,camo_d_13,camo_e_13,camo_f_13,camo_g_13,camo_h_13,camo_i_13,camo_j_13,camo_k_13,camo_l_13,camo_m_13,camo_n_13,camo_o_13");
    camos("camo_a_14,camo_b_14,camo_c_14,camo_d_14,camo_e_14,camo_f_14,camo_g_14,camo_h_14,camo_i_14,camo_j_14,camo_k_14,camo_l_14,camo_m_14,camo_n_14,camo_o_14");
    camos("camo_a_15,camo_b_15,camo_c_15,camo_d_15,camo_e_15,camo_f_15,camo_g_15,camo_h_15,camo_i_15,camo_j_15,camo_k_15,camo_l_15,camo_m_15,camo_n_15");
}

function camos(ids)
{
    foreach (id in cicada_util::list(ids))
        level.cicada_camos[level.cicada_camos.size] = id;
}

function group(name, categories)
{
    level.cicada_groups[name] = cicada_util::list(categories);
}

function entries(category, ids)
{
    list = isdefined(level.cicada_catalog[category]) ? level.cicada_catalog[category] : [];

    foreach (id in cicada_util::list(ids))
    {
        entry = spawnstruct();
        entry.id = id;
        entry.name = label(id);
        list[list.size] = entry;
    }

    level.cicada_catalog[category] = list;
}

function get(category)
{
    if (!isdefined(level.cicada_catalog[category]))
        return [];

    return level.cicada_catalog[category];
}

function count(category)
{
    return get(category).size;
}

// ids carry no display name, so the readable half is the codename the id is built from:
// "jup_jp35_sn_moscar" -> "moscar", "at_mine_mp" -> "at mine".
function label(id)
{
    parts = strtok(id, "_");

    for (i = 0; i < parts.size; i++)
        if (istrue(level.cicada_weapon_classes[parts[i]]) && (i + 1) < parts.size)
            return parts[i + 1];

    text = "";
    foreach (part in parts)
    {
        if (part == "mp" || part == "jup")
            continue;

        text = (text == "") ? part : text + " " + part;
    }

    return text;
}

function random_camo()
{
    return level.cicada_camos[randomint(level.cicada_camos.size)];
}
