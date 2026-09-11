#using scripts\engine\utility;

#using custom_scripts\menu;
#using custom_scripts\movement;
#using custom_scripts\util;

#namespace cicada_props;

function init()
{
    precachemodel(clip_model());

    foreach (name in model_list())
        precachemodel(name);
}

function model_list()
{
    models = [];

    models = add_models(models, "c_jup_zmb_zombie_base_male_merc_body,c_jup_zmb_zombie_base_male_shredded_shirtless,c_jup_zmb_zombie_base_female_dress,c_jup_zmb_zombie_base_female_skirt_wrap");
    models = add_models(models, "c_jup_zmb_zombie_base_charred_male_body,c_jup_zmb_zombie_base_armored_light,c_jup_zombie_base_armored_heavy_basebody,c_jup_zmb_zod_hellhound");
    models = add_models(models, "c_jup_zmb_mangler,c_jup_zmb_disciple_body,c_jup_zmb_mimic_body,c_jup_zmb_abomination_crawler");
    models = add_models(models, "c_jup_zmb_abomination_megabomb_body,c_jup_zmb_worm,c_jup_zmb_worm_boss,c_jup_zmb_ravenov_fb");
    models = add_models(models, "body_c_jup_zmb_npc_ava_jansen,body_c_jup_zmb_npc_entity,body_c_jup_zmb_npc_fletcher");
    models = add_models(models, "body_c_jup_mp_charlie,body_c_jup_mp_delta,body_c_jup_mp_echo_22_mutant");
    models = add_models(models, "body_c_jup_ext_chemist,body_c_jup_ext_director,body_c_jup_ext_maestro,body_c_jup_ext_rainmaker");
    models = add_models(models, "body_c_jup_sp_enemy_pmc_capt_03,body_c_jup_sp_enemy_pmc_grunt_05,body_c_jup_sp_enemy_pmc_hvytac_03");
    models = add_models(models, "body_c_jup_sp_enemy_pmc_shield_04,body_c_jup_sp_enemy_pmc_sniper_03,body_c_jup_sp_enemy_pmc_spforce_05");
    models = add_models(models, "body_sp_opforce_aq_jugg_basebody,body_al_qatala_desert_01,mw_test_soldier,mw_scale_soldier");
    models = add_models(models, "offhand_2h_wm_c4_v0,offhand_2h_wm_grenade_frag_v0,offhand_2h_wm_grenade_semtex_v0,offhand_wm_clacker");
    models = add_models(models, "offhand_wm_smartphone_on,misc_wm_blackbox_laptop,misc_cigarette_01_centered,weapon_wm_pi_mike1911_phys");
    models = add_models(models, "us_decor_box_cash_01,us_decor_box_cash_02,p7_box_cardboard_d_closed,p7_bottle_plastic_16oz_water");
    models = add_models(models, "cp_disco_folding_chair_lod0,ind_flood_light_standing_tall_on,uk_industrial_light_01_on,jup_floor_circular_dubai_01");
    models = add_models(models, "equipment_wm_tripwire_standard_cp,axis_guide_createfx,axis_guide_simple,tag_origin");

    return models;
}

function private add_models(models, text)
{
    foreach (name in cicada_util::list(text))
        models[models.size] = name;

    return models;
}

function model_prefixes()
{
    prefixes = [];

    prefixes = add_models(prefixes, "body_c_jup_sp_enemy_,body_c_jup_zmb_npc_,body_c_jup_ext_,body_c_jup_mp_,body_c_jup_,body_sp_opforce_,body_");
    prefixes = add_models(prefixes, "c_jup_zmb_zombie_base_,c_jup_zmb_,c_jup_zombie_base_,c_jup_,offhand_2h_wm_,offhand_wm_,equipment_wm_,weapon_wm_");
    prefixes = add_models(prefixes, "misc_wm_,misc_,us_decor_,p7_,uk_,jup_,ee_,ind_,cp_,mw_");

    return prefixes;
}

function short_name(name)
{
    if (!isdefined(name))
        return "none";

    label = name;

    foreach (prefix in model_prefixes())
    {
        trimmed = cicada_util::trim_start(label, prefix);

        if (trimmed != label)
        {
            label = trimmed;
            break;
        }
    }

    return cicada_util::shorten(label, 20);
}

function model_labels()
{
    labels = [];

    foreach (name in model_list())
        labels[labels.size] = cicada_util::unique_in(labels, short_name(name));

    return labels;
}

function model_for_label(label)
{
    labels = model_labels();
    models = model_list();

    for (i = 0; i < labels.size; i++)
        if (labels[i] == label)
            return models[i];

    return label;
}

function model_label(name)
{
    labels = model_labels();
    models = model_list();

    for (i = 0; i < models.size; i++)
        if (models[i] == name)
            return labels[i];

    return short_name(name);
}

function random_model()
{
    models = model_list();
    return models[randomint(models.size)];
}

function props()
{
    live = [];

    if (!isdefined(level.cicada_props))
        return live;

    foreach (prop in level.cicada_props)
        if (isdefined(prop))
            live[live.size] = prop;

    return live;
}

function count()
{
    return props().size;
}

function prop_at(index)
{
    live = props();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function prop_name(prop)
{
    if (!isdefined(prop))
        return "^1missing prop";

    return "prop ^:#" + prop.cicada_prop_index;
}

function prop_summary(prop)
{
    if (!isdefined(prop))
        return "^1gone";

    return "^:" + model_label(prop.cicada_prop_model);
}

function private track(prop)
{
    if (!isdefined(level.cicada_props))
        level.cicada_props = [];

    if (!isdefined(level.cicada_prop_total))
        level.cicada_prop_total = 0;

    prop.cicada_prop_index = level.cicada_prop_total;
    level.cicada_prop_total = level.cicada_prop_total + 1;

    level.cicada_props[level.cicada_props.size] = prop;
}

function head_groups()
{
    return cicada_util::list("opforce,crowd,modern,story,other");
}

function private add_heads(list, text)
{
    foreach (name in cicada_util::list(text))
        list[list.size] = name;

    return list;
}

function heads_in(group)
{
    if (isdefined(level.cicada_heads) && isdefined(level.cicada_heads[group]))
        return level.cicada_heads[group];

    list = [];

    switch (group)
    {
        case "opforce":
            list = add_heads(list, "head_al_qatala_desert_01,head_al_qatala_desert_09_rpg,head_sp_opforce_al_qatala_ar,head_sp_opforce_al_qatala_ar_2_1");
            list = add_heads(list, "head_sp_opforce_al_qatala_lmg,head_sp_opforce_al_qatala_shotgun,head_sp_opforce_al_qatala_smg,head_sp_opforce_al_qatala_sniper");
            list = add_heads(list, "head_sp_opforce_al_qatala_tier_2_1_1,head_sp_opforce_al_qatala_tier_2_2_1,head_sp_opforce_al_qatala_tier_2_3_1,head_sp_opforce_al_qatala_tier_2_4_1");
            list = add_heads(list, "head_sp_opforce_al_qatala_tier_3_1,head_sp_opforce_aq_jugg,head_sp_opforce_grunt_var_01_civ_nohair,head_sp_opforce_grunt_var_02_civ_nohair");
            list = add_heads(list, "head_sp_opforce_grunt_var_03_civ_nohair,head_sp_opforce_grunt_var_03_var_1_civ,head_sp_opforce_grunt_var_03_var_1_civ_nofacial,head_sp_opforce_grunt_var_04_civ_nohair");
            list = add_heads(list, "head_sp_opforce_pmc_1_1,head_sp_opforce_pmc_no_goggles_3_1,head_sp_opforce_shadow_company_armored_ar_1_1,head_sp_opforce_shadow_company_armored_dmr_1_1");
            list = add_heads(list, "head_sp_opforce_shadow_company_armored_sg_1_1,head_sp_opforce_shadow_company_armored_smg_1_1");
            break;

        case "crowd":
            list = add_heads(list, "head_bg_male_10,head_bg_male_11_opt,head_bg_var_head_bg_male_09_head_hero_marine_2_opt,head_bg_var_head_male_bc_06_head_sc_lee_opt");
            list = add_heads(list, "head_bg_var_head_sc_male_08_head_male_bc_06");
            break;

        case "modern":
            list = add_heads(list, "head_c_jup_civ_plane_child,head_c_jup_civ_surge_busker_b,head_c_jup_enemy_pmc_soldier_v02,head_c_jup_ext_chemist");
            list = add_heads(list, "head_c_jup_ext_director,head_c_jup_ext_maestro,head_c_jup_ext_rainmaker,head_c_jup_mp_charlie");
            list = add_heads(list, "head_c_jup_mp_delta,head_c_jup_mp_echo_22_mutant,head_c_jup_ob_enemy_pmc_capt_01,head_c_jup_russian_army_sharipov");
            list = add_heads(list, "head_c_jup_sc_f_alicea_civ,head_c_jup_sc_f_hoggard_civ,head_c_jup_sc_f_miller,head_c_jup_sc_f_miller_whiskey_hacker");
            list = add_heads(list, "head_c_jup_sc_f_page_civ,head_c_jup_sc_f_stokes_civ,head_c_jup_sc_m_ahmadzai_no_hair,head_c_jup_sc_m_alameer");
            list = add_heads(list, "head_c_jup_sc_m_alameer_dust,head_c_jup_sc_m_allen,head_c_jup_sc_m_allen_shotgunner_03a,head_c_jup_sc_m_androsov");
            list = add_heads(list, "head_c_jup_sc_m_androsov_civ_tint,head_c_jup_sc_m_arakelyan,head_c_jup_sc_m_banks_civ,head_c_jup_sc_m_bansal_beard");
            list = add_heads(list, "head_c_jup_sc_m_bruce,head_c_jup_sc_m_colvin,head_c_jup_sc_m_ferragamo,head_c_jup_sc_m_george_civ");
            list = add_heads(list, "head_c_jup_sc_m_haghighi_civ,head_c_jup_sc_m_johnson_civ,head_c_jup_sc_m_kamalov,head_c_jup_sc_m_kamalov_bald");
            list = add_heads(list, "head_c_jup_sc_m_kindschi,head_c_jup_sc_m_kindschi_civ,head_c_jup_sc_m_krotky,head_c_jup_sc_m_montano");
            list = add_heads(list, "head_c_jup_sc_m_mrehin_beard,head_c_jup_sc_m_orlovszki_civ_tattoo,head_c_jup_sc_m_perez_civ,head_c_jup_sc_m_shapiro_shotgunner_02a");
            list = add_heads(list, "head_c_jup_sc_m_sharipov,head_c_jup_sc_m_sharipov_flashback,head_c_jup_sc_m_utnehmer,head_c_jup_sc_m_utnehmer_cine");
            list = add_heads(list, "head_c_jup_sc_m_utnehmer_shotgunner_02,head_c_jup_sc_m_valladares,head_c_jup_sc_m_vasquez,head_c_jup_sc_m_vozhyuk");
            list = add_heads(list, "head_c_jup_sc_m_vozhyuk_damage,head_c_jup_sc_m_younger,head_c_jup_sc_m_yurteri,head_c_jup_sp_ally_redshirt_01");
            list = add_heads(list, "head_c_jup_sp_civ_prisoner_02,head_c_jup_sp_enemy_pmc_airstrip_01,head_c_jup_sp_enemy_pmc_airstrip_02,head_c_jup_sp_enemy_pmc_airstrip_03");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_airstrip_04,head_c_jup_sp_enemy_pmc_capt_01,head_c_jup_sp_enemy_pmc_capt_02,head_c_jup_sp_enemy_pmc_cmdr_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_cmdr_02,head_c_jup_sp_enemy_pmc_elsniper_01,head_c_jup_sp_enemy_pmc_elsniper_02,head_c_jup_sp_enemy_pmc_grunt_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_grunt_02,head_c_jup_sp_enemy_pmc_grunt_03,head_c_jup_sp_enemy_pmc_grunt_04,head_c_jup_sp_enemy_pmc_grunt_05");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_grunt_05_01,head_c_jup_sp_enemy_pmc_grunt_05_02,head_c_jup_sp_enemy_pmc_grunt_05_03,head_c_jup_sp_enemy_pmc_grunt_05_olive_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_grunt_05_olive_02,head_c_jup_sp_enemy_pmc_grunt_05_tan_01,head_c_jup_sp_enemy_pmc_grunt_05_tan_02,head_c_jup_sp_enemy_pmc_grunt_female_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_grunt_female_02,head_c_jup_sp_enemy_pmc_grunt_female_03,head_c_jup_sp_enemy_pmc_grunt_female_04,head_c_jup_sp_enemy_pmc_hvytac_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_hvytac_02,head_c_jup_sp_enemy_pmc_hvytac_03,head_c_jup_sp_enemy_pmc_juggernaut_02,head_c_jup_sp_enemy_pmc_jumper_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_jumper_02,head_c_jup_sp_enemy_pmc_jumper_03,head_c_jup_sp_enemy_pmc_pilot_01,head_c_jup_sp_enemy_pmc_rocket_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_rocket_02,head_c_jup_sp_enemy_pmc_rocket_03,head_c_jup_sp_enemy_pmc_rook,head_c_jup_sp_enemy_pmc_rusher_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_rusher_02,head_c_jup_sp_enemy_pmc_rusher_03,head_c_jup_sp_enemy_pmc_rusher_04,head_c_jup_sp_enemy_pmc_rusher_05");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_scuba_01,head_c_jup_sp_enemy_pmc_scuba_02,head_c_jup_sp_enemy_pmc_scuba_03,head_c_jup_sp_enemy_pmc_scuba_04");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_shield_01,head_c_jup_sp_enemy_pmc_shield_02,head_c_jup_sp_enemy_pmc_shield_03,head_c_jup_sp_enemy_pmc_shield_04");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_sniper_01,head_c_jup_sp_enemy_pmc_sniper_02,head_c_jup_sp_enemy_pmc_sniper_03,head_c_jup_sp_enemy_pmc_soldier_01");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_soldier_02,head_c_jup_sp_enemy_pmc_soldier_03,head_c_jup_sp_enemy_pmc_soldier_04,head_c_jup_sp_enemy_pmc_soldier_05");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_soldier_05_alt1,head_c_jup_sp_enemy_pmc_soldier_05_alt2,head_c_jup_sp_enemy_pmc_soldier_05_alt3,head_c_jup_sp_enemy_pmc_soldier_05_masked");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_spforce_01,head_c_jup_sp_enemy_pmc_spforce_02,head_c_jup_sp_enemy_pmc_spforce_03,head_c_jup_sp_enemy_pmc_spforce_04");
            list = add_heads(list, "head_c_jup_sp_enemy_pmc_support_01,head_c_jup_sp_enemy_pmc_support_02,head_c_jup_sp_enemy_police_omon_01,head_c_jup_sp_enemy_rusgeneral_02");
            list = add_heads(list, "head_c_jup_sp_hero_farah_convoy,head_c_jup_sp_hero_farah_desert,head_c_jup_sp_hero_gaz_london,head_c_jup_sp_hero_gaz_london_tactical");
            list = add_heads(list, "head_c_jup_sp_hero_gaz_tundra_frost,head_c_jup_sp_hero_gaz_urban,head_c_jup_sp_hero_laswell_bdu,head_c_jup_sp_hero_laswell_military_nohelmet");
            list = add_heads(list, "head_c_jup_sp_hero_soap_expired,head_c_jup_sp_hero_soap_jump,head_c_jup_sp_hero_soap_nvm,head_c_jup_sp_hero_soap_tundra_frost");
            list = add_heads(list, "head_c_jup_sp_hero_soap_urban,head_c_jup_sp_hero_soap_woodland,head_c_jup_zmb_fletcher,head_c_jup_zmb_npc_ava_jansen_lod1");
            list = add_heads(list, "head_c_jup_zmb_npc_entity");
            break;

        case "story":
            list = add_heads(list, "head_hero_alex_lod_iw9,head_hero_ghost_amsterdam_cine,head_hero_hadir_teen_blendshape,head_hero_kyle_marina_blendshape");
            list = add_heads(list, "head_hero_nikolai,head_hero_nikolai_blendshape_iw9,head_hero_price_desert_lod,head_hero_price_newrig_bald");
            list = add_heads(list, "head_hero_price_nohat_blood_lod,head_hero_price_nohat_lod,head_hero_soap_lod,head_hero_stewardess_lod0");
            list = add_heads(list, "head_sc_engineering_mate_opt,head_sc_f_alicea_bg_civ,head_sc_f_alicea_civ,head_sc_f_alicea_civ_no_hair");
            list = add_heads(list, "head_sc_f_alicea_civ_nofacial,head_sc_f_anisimova_bg,head_sc_f_anisimova_bg_civ,head_sc_f_anisimova_civ");
            list = add_heads(list, "head_sc_f_anisimova_civ_nofacial,head_sc_f_aya,head_sc_f_aya_bg_civ,head_sc_f_babayeva_bg_civ");
            list = add_heads(list, "head_sc_f_babayeva_civ,head_sc_f_babayeva_civ_nofacial,head_sc_f_barkley,head_sc_f_barkley_bg");
            list = add_heads(list, "head_sc_f_barkley_bg_civ,head_sc_f_barkley_child,head_sc_f_barkley_civ,head_sc_f_chivikina");
            list = add_heads(list, "head_sc_f_chivikina_civ,head_sc_f_chivikina_civ_nofacial,head_sc_f_daly,head_sc_f_daly_bg");
            list = add_heads(list, "head_sc_f_daly_bg_civ,head_sc_f_daly_civ,head_sc_f_daly_civ_nofacial,head_sc_f_dizon_var_1");
            list = add_heads(list, "head_sc_f_dizon_var_1_bg,head_sc_f_dizon_var_1_bg_civ,head_sc_f_dizon_var_1_nofacial,head_sc_f_dizon_var_2");
            list = add_heads(list, "head_sc_f_eghbali_civ,head_sc_f_eghbali_hair,head_sc_f_eghbali_hair_bg,head_sc_f_hoggard");
            list = add_heads(list, "head_sc_f_hoggard_bg,head_sc_f_hoggard_bg_civ,head_sc_f_hoggard_civ,head_sc_f_hoggard_civ_no_hair");
            list = add_heads(list, "head_sc_f_hujbar_bg,head_sc_f_hujbar_bg_civ,head_sc_f_lim_civ,head_sc_f_lim_civ_no_hair");
            list = add_heads(list, "head_sc_f_mendoza_bg_civ,head_sc_f_mendoza_civ,head_sc_f_miller_bg_civ,head_sc_f_mostafavi_civ");
            list = add_heads(list, "head_sc_f_mostafavi_civ_flashback,head_sc_f_mostafavi_civ_nofacial,head_sc_f_page_bg_civ,head_sc_f_page_civ");
            list = add_heads(list, "head_sc_f_page_civ_no_hair,head_sc_f_rezaee,head_sc_f_rezaee_civ,head_sc_f_rezaee_civ_bg");
            list = add_heads(list, "head_sc_f_roa,head_sc_f_stokes_bg,head_sc_f_stokes_bg_civ,head_sc_f_stokes_civ");
            list = add_heads(list, "head_sc_f_stokes_civ_flashback,head_sc_f_stokes_civ_no_hair,head_sc_f_stokes_civ_nofacial,head_sc_f_toyouri_civ");
            list = add_heads(list, "head_sc_f_wetherbee,head_sc_f_wetherbee_bg,head_sc_f_wetherbee_bg_civ,head_sc_f_wetherbee_civ");
            list = add_heads(list, "head_sc_f_wetherbee_civ_nofacial,head_sc_f_wetherbee_var_1_bg_civ,head_sc_kloos_opt,head_sc_ling_opt");
            list = add_heads(list, "head_sc_m_acosta,head_sc_m_ahmadzai,head_sc_m_ahmadzai_civ,head_sc_m_ahmadzai_civ_nofacial");
            list = add_heads(list, "head_sc_m_alameer,head_sc_m_alameer_civ,head_sc_m_alameer_civ_nofacial,head_sc_m_allen_hat");
            list = add_heads(list, "head_sc_m_allen_hat_civ,head_sc_m_androsov_bg,head_sc_m_androsov_bg_no_hair,head_sc_m_androsov_civ");
            list = add_heads(list, "head_sc_m_androsov_civ_nofacial,head_sc_m_androsov_civ_tint,head_sc_m_antoniazzi_bg_civ,head_sc_m_antoniazzi_civ");
            list = add_heads(list, "head_sc_m_arakelyan_civ,head_sc_m_arakelyan_civ_w_hair,head_sc_m_arakelyan_civ_w_hair_nofacial,head_sc_m_banks_bg_civ");
            list = add_heads(list, "head_sc_m_banks_civ,head_sc_m_bansal_beard,head_sc_m_bansal_civ_bg,head_sc_m_bruce");
            list = add_heads(list, "head_sc_m_bruce_civ,head_sc_m_bruce_var_1_civ,head_sc_m_bruce_var_2,head_sc_m_bruce_var_2_civ");
            list = add_heads(list, "head_sc_m_chew_child,head_sc_m_colvin,head_sc_m_colvin_civ,head_sc_m_colvin_civ_nofacial");
            list = add_heads(list, "head_sc_m_colvin_var_1,head_sc_m_cueto,head_sc_m_cueto_child,head_sc_m_cueto_civ");
            list = add_heads(list, "head_sc_m_dunn_bg,head_sc_m_fahselt_civ_no_hair,head_sc_m_ferragamo,head_sc_m_ferragamo_civ");
            list = add_heads(list, "head_sc_m_gene_v3_lod0,head_sc_m_george_bg_civ,head_sc_m_george_civ,head_sc_m_jimenez");
            list = add_heads(list, "head_sc_m_johnson_var_1,head_sc_m_kamalov_bg,head_sc_m_kamalov_bg_civ,head_sc_m_kamalov_child");
            list = add_heads(list, "head_sc_m_karlin_bg_civ,head_sc_m_kindschi_bg,head_sc_m_konstantin_lod0,head_sc_m_lai_bg_civ");
            list = add_heads(list, "head_sc_m_love_child,head_sc_m_miller_iw9,head_sc_m_montano_bg,head_sc_m_montano_civ");
            list = add_heads(list, "head_sc_m_mrehin_civ,head_sc_m_mrehin_civ_nofacial,head_sc_m_nazeri_bg,head_sc_m_nazeri_civ_var_1");
            list = add_heads(list, "head_sc_m_orlovszki_bg,head_sc_m_perez_bg_civ,head_sc_m_perez_civ,head_sc_m_pete");
            list = add_heads(list, "head_sc_m_polister,head_sc_m_ramirez_bg,head_sc_m_ramirez_bg_civ,head_sc_m_ramirez_no_hair");
            list = add_heads(list, "head_sc_m_rosas_bg,head_sc_m_rozmiarek,head_sc_m_rozmiarek_bg_civ,head_sc_m_shapiro");
            list = add_heads(list, "head_sc_m_sharipov_bg,head_sc_m_sharipov_civ,head_sc_m_sharipov_civ_nofacial,head_sc_m_sharipov_civ_tint");
            list = add_heads(list, "head_sc_m_sharipov_nohair,head_sc_m_swaynos_bg_civ,head_sc_m_tang_bg_civ,head_sc_m_tang_civ");
            list = add_heads(list, "head_sc_m_thomas,head_sc_m_thorp_bg,head_sc_m_valladares,head_sc_m_vasquez");
            list = add_heads(list, "head_sc_m_verano_bg_civ,head_sc_m_vozhyuk_bg,head_sc_m_vozhyuk_bg_civ,head_sc_m_vozhyuk_child");
            list = add_heads(list, "head_sc_m_vozhyuk_civ,head_sc_m_vozhyuk_civ_nofacial,head_sc_m_vozhyuk_civ_tint,head_sc_m_yurteri_beard");
            list = add_heads(list, "head_sc_m_yurteri_civ,head_sc_male_16_opt");
            break;

        case "other":
            list = add_heads(list, "head_hostage_hood_01,head_mp_eastern_golem_1_1,head_mp_infected,head_mp_milsim_navy_frogman_1_1");
            list = add_heads(list, "head_russian_army_balaclava_1,head_russian_army_sharipov,head_sas_urban_ar,head_sas_urban_ar_nvg");
            list = add_heads(list, "head_sas_urban_sp_cqc,head_sas_urban_sp_dmr,head_sp_ally_mex_sf_a,head_sp_ally_mex_sf_b");
            list = add_heads(list, "head_sp_ally_mex_sf_c,head_sp_ally_mex_sf_d,head_sp_ally_mex_sf_tier_1_1_1,head_sp_ally_mex_sf_tier_1_2_1");
            list = add_heads(list, "head_sp_ally_mex_sf_tier_1_3_1,head_sp_ally_mex_sf_tier_1_4_1,head_sp_ally_usmc_ar_1_1,head_sp_civ_var_04_hat_a");
            list = add_heads(list, "head_sp_civ_var_05_hat_b_civ,head_sp_civ_var_07_hat_b_civ,head_sp_hero_ghost_urban_lod,head_sp_hero_kyle_amsterdam_lod");
            list = add_heads(list, "head_spetsnaz_ar,head_usmc_basic_ar_4,head_usmc_lmg");
            break;

    }

    if (!isdefined(level.cicada_heads))
        level.cicada_heads = [];

    level.cicada_heads[group] = list;

    return list;
}

function head_count(group)
{
    return heads_in(group).size;
}

function head_at(group, index)
{
    list = heads_in(group);

    if (index < 0 || index >= list.size)
        return undefined;

    return list[index];
}

function known_head(name)
{
    if (!isdefined(name) || name == "none")
        return false;

    foreach (group in head_groups())
        foreach (head in heads_in(group))
            if (head == name)
                return true;

    return false;
}

function head_label(name)
{
    if (!isdefined(name) || name == "none")
        return "^1no head";

    return "^:" + cicada_util::shorten(cicada_util::trim_start(name, "head_"), 24);
}

function private mapped_head(model)
{
    switch (model)
    {
        case "body_c_jup_sp_enemy_pmc_soldier_05_alt":
            return "head_c_jup_sp_enemy_pmc_soldier_05_alt1";

        case "body_c_jup_sp_enemy_pmc_soldier_05":
            return "head_c_jup_sp_enemy_pmc_soldier_05_masked";

        case "body_c_jup_sp_enemy_pmc_grunt_female_01_desert":
            return "head_c_jup_sp_enemy_pmc_grunt_female_01";

        case "body_c_jup_sp_enemy_pmc_grunt_red":
            return "head_c_jup_sp_enemy_pmc_grunt_05_02";

        case "body_c_jup_zmb_npc_fletcher":
            return "head_c_jup_zmb_fletcher";

        case "body_c_jup_sp_enemy_pmc_grunt_tan":
            return "head_c_jup_sp_enemy_pmc_grunt_05_tan_01";

        case "body_sp_opforce_aq_jugg_basebody":
            return "head_sp_opforce_aq_jugg";

        case "body_c_jup_sp_enemy_pmc_grunt_05":
            return "head_c_jup_sp_enemy_pmc_grunt_05_02";

        case "body_c_jup_sp_enemy_pmc_grunt_grey":
            return "head_c_jup_sp_enemy_pmc_grunt_05_olive_01";

        case "body_c_jup_sp_enemy_pmc_capt_03":
            return "head_sc_m_jimenez";

        case "body_c_jup_sp_enemy_pmc_spforce_05":
            return "head_c_jup_ob_enemy_pmc_capt_01";

        case "body_c_jup_sp_enemy_pmc_grunt_olive":
            return "head_c_jup_sp_enemy_pmc_grunt_05_olive_02";

        case "body_c_jup_sp_enemy_pmc_grunt_female_01":
            return "head_c_jup_sp_enemy_pmc_grunt_female_02";

        case "body_c_jup_zmb_npc_ava_jansen":
            return "head_c_jup_zmb_npc_ava_jansen_lod1";

        case "body_hero_hadir_prisoner":
            return "head_hero_hadir_teen_blendshape";

        case "body_hero_price_urban_beanie":
            return "head_hero_price_newrig_bald";

        case "body_usmc_ar":
            return "head_usmc_lmg";

        case "body_c_jup_civ_plane_bystander":
            return "head_sc_m_gene_v3_lod0";

        case "body_c_jup_sp_civ_guard_01":
            return "head_c_jup_sc_m_colvin";

        case "body_c_jup_sp_civ_guard_01a":
            return "head_c_jup_sc_m_vasquez";

        case "body_c_jup_sp_civ_guard_02":
            return "head_c_jup_sc_m_yurteri";

        case "body_c_jup_sp_civ_guard_02a":
            return "head_c_jup_sc_m_montano";

        case "body_c_jup_sp_civ_guard_03":
            return "head_c_jup_sc_m_alameer_dust";

        case "body_c_jup_sp_civ_guard_03a":
            return "head_c_jup_sc_m_androsov";

        case "body_c_jup_sp_civ_guard_04a":
            return "head_c_jup_sc_m_valladares";

        case "body_c_jup_sp_civ_guard_05":
            return "head_c_jup_sc_m_kamalov_bald";

        case "body_c_jup_sp_civ_guard_05a":
            return "head_c_jup_sc_m_kindschi_civ";

        case "body_c_jup_sp_civ_plane_attendant_02":
            return "head_hero_stewardess_lod0";

        case "body_c_jup_sp_civ_prisoner_01":
            return "head_c_jup_sc_m_vozhyuk";

        case "body_c_jup_sp_civ_prisoner_01_a":
            return "head_c_jup_sc_m_mrehin_beard";

        case "body_c_jup_sp_civ_prisoner_02":
            return "head_c_jup_sc_m_krotky";

        case "body_c_jup_sp_civ_prisoner_02_a":
            return "head_c_jup_sc_m_ahmadzai_no_hair";

        case "body_c_jup_sp_civ_prisoner_03":
            return "head_c_jup_sc_m_orlovszki_civ_tattoo";

        case "body_c_jup_sp_civ_prisoner_03_b":
            return "head_c_jup_russian_army_sharipov";

        case "body_c_jup_sp_civ_prisoner_03_b_riot":
            return "head_c_jup_sc_m_sharipov";

        case "body_c_jup_sp_civ_prisoner_04":
            return "head_c_jup_sc_m_androsov_civ_tint";

        case "body_c_jup_sp_civ_prisoner_04_b":
            return "head_c_jup_sc_m_utnehmer_cine";

        case "body_c_jup_sp_civ_prisoner_04_b_riot":
            return "head_c_jup_sc_m_utnehmer_cine";

        case "body_c_jup_sp_civ_prisoner_05":
            return "head_c_jup_sc_m_ferragamo";

        case "body_c_jup_sp_civ_prisoner_05_a":
            return "head_c_jup_sc_m_arakelyan";

        case "body_c_jup_sp_civ_prisoner_05_b":
            return "head_c_jup_sc_m_vasquez";

        case "body_c_jup_sp_civ_prisoner_05_b_riot":
            return "head_c_jup_sc_m_vasquez";

        case "body_c_jup_sp_enemy_pmc_grunt_01_winter":
            return "head_c_jup_sp_enemy_pmc_grunt_01";

        case "body_c_jup_sp_enemy_pmc_grunt_03_winter":
            return "head_c_jup_sp_enemy_pmc_grunt_03";

        case "body_c_jup_sp_enemy_pmc_grunt_04_winter":
            return "head_c_jup_sp_enemy_pmc_grunt_04";

        case "body_c_jup_sp_enemy_pmc_hooded_01":
            return "head_sc_m_johnson_var_1";

        case "body_c_jup_sp_enemy_pmc_hooded_01_jump":
            return "head_sc_m_johnson_var_1";

        case "body_c_jup_sp_enemy_pmc_hooded_02":
            return "head_sc_m_fahselt_civ_no_hair";

        case "body_c_jup_sp_enemy_pmc_hooded_02_jump":
            return "head_sc_m_fahselt_civ_no_hair";

        case "body_c_jup_sp_enemy_pmc_hooded_03":
            return "head_c_jup_sc_m_bansal_beard";

        case "body_c_jup_sp_enemy_pmc_rocket_01_winter":
            return "head_c_jup_sp_enemy_pmc_rocket_01";

        case "body_c_jup_sp_enemy_pmc_undercover":
            return "head_c_jup_sc_m_younger";

        case "body_c_jup_sp_enemy_police_kastovia_01":
            return "head_c_jup_sc_m_sharipov";

        case "body_c_jup_sp_enemy_police_kastovia_02":
            return "head_c_jup_sc_m_allen";

        case "body_c_jup_sp_enemy_police_kastovia_03":
            return "head_c_jup_sc_m_kamalov";

        case "body_c_jup_sp_enemy_police_omon_02":
            return "head_c_jup_sp_enemy_police_omon_01";

        case "body_c_jup_sp_enemy_police_omon_03":
            return "head_c_jup_sp_enemy_police_omon_01";

        case "body_c_jup_sp_enemy_police_omon_04":
            return "head_c_jup_sp_enemy_police_omon_01";

        case "body_c_jup_sp_hero_price_desert":
            return "head_hero_price_desert_lod";

        case "body_c_jup_sp_hero_price_london":
            return "head_hero_price_nohat_lod";

        case "body_c_jup_sp_hero_price_london_blood":
            return "head_hero_price_nohat_blood_lod";

        case "body_c_jup_sp_hero_price_london_tactical":
            return "head_hero_price_nohat_lod";

        case "body_c_jup_sp_hero_soap_london":
            return "head_hero_soap_lod";

        case "body_c_jup_sp_hero_soap_london_tactical":
            return "head_hero_soap_lod";

        case "body_c_jup_sp_enemy_oligarch_patroller_02":
            return "head_c_jup_sc_m_vozhyuk";

        case "body_c_jup_sp_civ_worker_06":
            return "head_c_jup_sc_m_kindschi_civ";

        case "body_c_jup_sp_civ_worker_05":
            return "head_sc_m_arakelyan_civ";

        case "body_c_jup_sp_civ_worker_03":
            return "head_sc_m_yurteri_beard";

        case "body_c_jup_sp_enemy_oligarch_patroller_03a":
            return "head_c_jup_sc_m_sharipov";

        case "body_c_jup_civ_london_male_10_1":
            return "head_c_jup_sc_m_haghighi_civ";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_02a":
            return "head_c_jup_sc_m_shapiro_shotgunner_02a";

        case "body_c_jup_sp_enemy_pmc_capt_winter":
            return "head_c_jup_sp_enemy_pmc_capt_01";

        case "body_civ_stpeterburg_male_5_1":
            return "head_sc_m_acosta";

        case "body_c_jup_sp_enemy_oligarch_patroller_02a":
            return "head_c_jup_sc_m_kindschi";

        case "body_c_jup_sp_civ_worker_02":
            return "head_c_jup_sc_m_vozhyuk";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_03":
            return "head_c_jup_sc_m_bruce";

        case "body_c_jup_sp_villain_makarov_shirt_blood":
            return "head_c_jup_sp_hero_soap_expired";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_02":
            return "head_c_jup_sc_m_utnehmer_shotgunner_02";

        case "body_c_jup_sp_enemy_oligarch_patroller_01a":
            return "head_c_jup_sc_m_kamalov";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_01a":
            return "head_c_jup_sc_m_yurteri";

        case "body_c_jup_sp_civ_guard_06":
            return "head_c_jup_sc_m_johnson_civ";

        case "body_hero_price_undercover":
            return "head_hero_price_nohat_lod";

        case "body_c_jup_sp_civ_worker_04":
            return "head_c_jup_sc_m_alameer";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_03a":
            return "head_c_jup_sc_m_allen_shotgunner_03a";

        case "body_sp_heroe_nikolai_convoy":
            return "head_hero_nikolai";

        case "body_sp_opforce_pmc_with_strap_1_1":
            return "head_sp_opforce_pmc_no_goggles_3_1";

        case "body_sp_opforce_pmc_with_radio_1_1":
            return "head_sp_opforce_pmc_no_goggles_3_1";

        case "body_c_jup_sp_hero_soap_bravo":
            return "head_hero_soap_lod";

        case "body_c_jup_civ_plane_attendant_01_jump":
            return "head_sc_m_konstantin_lod0";

        case "body_civ_london_male_2_1":
            return "head_sc_m_cueto";

        case "body_c_jup_sp_enemy_oligarch_patroller_02b":
            return "head_c_jup_sc_m_sharipov";

        case "body_c_jup_civ_paramedic_01":
            return "head_c_jup_sc_m_utnehmer";

        case "body_sp_hero_kyle_marina":
            return "head_hero_kyle_marina_blendshape";

        case "body_civ_london_male_4_1":
            return "head_sc_m_ferragamo_civ";

        case "body_sp_opforce_pmc_w_packs_1_1":
            return "head_sp_opforce_pmc_no_goggles_3_1";

        case "body_sp_hero_soap_nightwar":
            return "head_hero_soap_lod";

        case "body_civ_london_male_10_1":
            return "head_mp_eastern_golem_1_1";

        case "body_civ_london_female_9_2":
            return "head_sc_f_dizon_var_1";

        case "body_c_jup_civ_plane_attendant_01":
            return "head_sc_m_konstantin_lod0";

        case "body_c_jup_sp_hero_ghost_urban":
            return "head_sp_hero_ghost_urban_lod";

        case "body_c_jup_sp_hero_gaz_cheminfil":
            return "head_c_jup_sp_hero_gaz_urban";

        case "body_civ_london_male_8_1":
            return "head_sc_m_montano_civ";

        case "body_c_jup_sp_enemy_tundra_elsniper_01":
            return "head_c_jup_sp_enemy_pmc_sniper_02";

        case "body_c_jup_sp_civ_worker_04_a":
            return "head_c_jup_sc_m_bansal_beard";

        case "body_c_jup_npc_f_whiskey_hacker":
            return "head_c_jup_sc_f_miller_whiskey_hacker";

        case "body_c_jup_sp_civ_worker_06_a":
            return "head_c_jup_sc_m_valladares";

        case "body_c_jup_sp_civ_worker_05_a":
            return "head_c_jup_sc_m_montano";

        case "body_c_jup_sp_civ_guard_06a":
            return "head_c_jup_sc_m_sharipov";

        case "body_sp_opforce_pmc_no_packs_1_1":
            return "head_sp_opforce_pmc_no_goggles_3_1";

        case "body_c_jup_sp_enemy_oligarch_hvt":
            return "head_c_jup_sc_m_johnson_civ";

        case "body_civ_london_male_5_1":
            return "head_sc_m_colvin_var_1";

        case "body_c_jup_sp_civ_worker_01":
            return "head_c_jup_sc_m_kamalov";

        case "body_c_jup_sp_enemy_oligarch_shotgunner_01":
            return "head_c_jup_sc_m_colvin";

        case "body_c_jup_sp_enemy_oligarch_patroller_01":
            return "head_c_jup_sc_m_androsov";

        case "body_civ_london_female_6_2":
            return "head_sc_f_wetherbee";

        case "body_spetsnaz_ar":
            return "head_russian_army_balaclava_1";

    }

    return undefined;
}

function head_for_body(model)
{
    if (!isdefined(model))
        return undefined;

    found = mapped_head(model);

    if (isdefined(found) && known_head(found))
        return found;

    guess = "head_" + cicada_util::trim_start(model, "body_");

    if (guess != model && known_head(guess))
        return guess;

    return undefined;
}

function head_modes()
{
    return cicada_util::list("automatic,chosen,none");
}

function head_mode(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_head_mode))
        return "automatic";

    return prop.cicada_prop_head_mode;
}

function prop_head(prop)
{
    if (!isdefined(prop))
        return undefined;

    return prop.cicada_prop_head;
}

function head_summary(prop)
{
    if (!isdefined(prop))
        return "^1gone";

    if (head_mode(prop) == "none")
        return "^1turned off";

    if (isdefined(prop.cicada_prop_head))
        return head_label(prop.cicada_prop_head);

    if (head_mode(prop) == "automatic")
        return "^1none found";

    return "^1nothing picked";
}

function private drop_head(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_head))
        return;

    prop detach(prop.cicada_prop_head);
    prop.cicada_prop_head = undefined;
}

function private attach_head(prop, name)
{
    drop_head(prop);

    if (!known_head(name))
        return;

    prop attach(name, "", 1);
    prop.cicada_prop_head = name;
}

function refresh_head(prop)
{
    if (!isdefined(prop))
        return;

    switch (head_mode(prop))
    {
        case "none":
            drop_head(prop);
            return;

        case "chosen":
            attach_head(prop, prop.cicada_prop_head_pick);
            return;
    }

    attach_head(prop, head_for_body(prop.cicada_prop_model));
}

function set_head(name, prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_head_pick = name;
    prop.cicada_prop_head_mode = "chosen";
    refresh_head(prop);
    self cicada_menu::update_menu();
}

function set_head_mode(mode, prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_head_mode = mode;
    refresh_head(prop);
    self cicada_menu::update_menu();
}

function clear_head(prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_head_mode = "none";
    drop_head(prop);
    self cicada_menu::update_menu();
}

function random_head(prop)
{
    groups = head_groups();
    list = heads_in(groups[randomint(groups.size)]);

    if (!list.size)
        return;

    self set_head(list[randomint(list.size)], prop);
}

function private prop_model_swap(prop, name)
{
    prop.cicada_prop_model = name;
    prop setmodel(name);
    refresh_head(prop);
}

function collision_source()
{
    if (isdefined(level.cratedata) && isdefined(level.cratedata.mountmantlemodel))
        return level.cratedata.mountmantlemodel;

    clip = getent("care_package_col", "targetname");

    if (isdefined(clip))
        return clip;

    return getent("collision_clip", "targetname");
}

function has_collision(prop)
{
    return isdefined(prop) && isdefined(prop.cicada_prop_clips) && prop.cicada_prop_clips.size > 0;
}

function clip_width(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_clip_width))
        return 1;

    return prop.cicada_prop_clip_width;
}

function clip_layers(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_clip_layers))
        return 1;

    return prop.cicada_prop_clip_layers;
}

function clip_spacing(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_clip_space))
        return 56;

    return prop.cicada_prop_clip_space;
}

function clip_model()
{
    return "com_plasticcase_beige_big_iw6";
}

function private make_clip(prop, spot, source)
{
    clip = spawn("script_model", spot);
    clip.angles = prop.angles;

    if (isdefined(source))
    {
        clip clonebrushmodeltoscriptmodel(source);
        prop.cicada_prop_clip_kind = "map clip";
    }
    else
    {
        clip setmodel(clip_model());
        prop.cicada_prop_clip_kind = "crate";
    }

    clip solid();
    clip hide();

    return clip;
}

function private build_collision(prop, offset)
{
    if (!isdefined(offset))
        offset = (0, 0, 0);

    source = collision_source();

    width = clip_width(prop);
    layers = clip_layers(prop);
    space = clip_spacing(prop);

    prop.cicada_prop_clips = [];
    prop.cicada_prop_clip_offset = offset;

    edge = (width - 1) * space * 0.5;

    for (row = 0; row < width; row++)
    {
        for (column = 0; column < width; column++)
        {
            for (layer = 0; layer < layers; layer++)
            {
                spread = (row * space - edge, column * space - edge, layer * space);
                clip = make_clip(prop, prop.origin + offset + spread, source);

                clip.cicada_prop_spread = spread;
                prop.cicada_prop_clips[prop.cicada_prop_clips.size] = clip;
            }
        }
    }

    return true;
}

function private rebuild_collision(prop)
{
    if (!has_collision(prop))
        return;

    offset = prop_clip_offset(prop);

    drop_collision(prop);
    build_collision(prop, offset);
}

function set_clip_width(value, prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_clip_width = value;

    rebuild_collision(prop);
    self cicada_menu::update_menu();
}

function set_clip_layers(value, prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_clip_layers = value;

    rebuild_collision(prop);
    self cicada_menu::update_menu();
}

function set_clip_spacing(value, prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_clip_space = value;

    rebuild_collision(prop);
    self cicada_menu::update_menu();
}

function clip_count(prop)
{
    if (!has_collision(prop))
        return 0;

    return prop.cicada_prop_clips.size;
}

function clip_kind(prop)
{
    if (!has_collision(prop))
        return "off";

    if (!isdefined(prop.cicada_prop_clip_kind))
        return "on";

    return prop.cicada_prop_clip_kind;
}

function private drop_collision(prop)
{
    if (!isdefined(prop.cicada_prop_clips))
        return;

    foreach (clip in prop.cicada_prop_clips)
        if (isdefined(clip))
            clip delete();

    prop.cicada_prop_clips = undefined;
}

function add_collision(prop)
{
    if (!isdefined(prop) || has_collision(prop))
        return;

    build_collision(prop, prop_clip_offset(prop));
    self cicada_util::message("collision ^:" + clip_kind(prop) + " ^7added");
}

function prop_clip_offset(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_clip_offset))
        return (0, 0, 0);

    return prop.cicada_prop_clip_offset;
}

function clip_height(prop)
{
    return prop_clip_offset(prop)[2];
}

function raise_clip(value, prop)
{
    if (!isdefined(prop))
        return;

    offset = (0, 0, value);

    if (!has_collision(prop))
    {
        prop.cicada_prop_clip_offset = offset;
        self cicada_menu::update_menu();
        return;
    }

    drop_collision(prop);
    build_collision(prop, offset);

    self cicada_menu::update_menu();
}

function toggle_collision(prop)
{
    if (!isdefined(prop))
        return;

    if (has_collision(prop))
        drop_collision(prop);
    else
        self add_collision(prop);

    self cicada_menu::update_menu();
}

function private make_prop(name, origin, angles)
{
    prop = spawn("script_model", origin);

    prop.angles = angles;
    prop_model_swap(prop, name);

    if (istrue(self cicada_util::getpers("prop_solid")))
    {
        prop.cicada_prop_solid = true;
        prop solid();
    }

    track(prop);

    if (istrue(self cicada_util::getpers("prop_collision")))
        self add_collision(prop);

    return prop;
}

function spawn_prop(name)
{
    if (!isdefined(name))
        name = self cicada_util::getpers("prop_model");

    if (!isdefined(name))
        name = random_model();

    origin = self cicada_util::crosshair() + (0, 0, self cicada_util::getpersfloat("prop_height"));
    angles = (0, self.angles[1] + 180, 0);

    prop = make_prop(name, origin, angles);

    self cicada_util::message(prop_name(prop) + " ^7spawned");
    self cicada_menu::update_menu();
}

function spawn_of_model(value, key)
{
    name = model_for_label(value);

    self cicada_util::setpers(key, name);
    self spawn_prop(name);
}

function spawn_random()
{
    self spawn_prop(random_model());
}

function set_prop_model(name, prop)
{
    if (!isdefined(prop))
        return;

    prop_model_swap(prop, model_for_label(name));
    self cicada_menu::update_menu();
}

function randomize_prop(prop)
{
    self set_prop_model(random_model(), prop);
}

function randomize_all()
{
    foreach (prop in props())
        prop_model_swap(prop, random_model());

    self cicada_util::message("^:" + count() + " ^7props randomized");
    self cicada_menu::update_menu();
}

function move_prop(where, prop)
{
    if (!isdefined(prop))
        return;

    if (istrue(prop.cicada_prop_linked) && where != "to them")
        return;

    switch (where)
    {
        case "to crosshair":
            prop.origin = self cicada_util::crosshair();
            break;

        case "to me":
            prop.origin = self.origin;
            break;

        case "to them":
            self setorigin(prop.origin + (0, 0, 8));
            break;
    }

    settle_collision(prop);
}

function private settle_collision(prop)
{
    rebuild_collision(prop);
}

function face_me(prop)
{
    if (!isdefined(prop))
        return;

    facing = vectortoangles(self.origin - prop.origin);
    prop.angles = (0, facing[1], 0);
}

function prop_raise(prop)
{
    if (!isdefined(prop) || !isdefined(prop.cicada_prop_raise))
        return 0;

    return prop.cicada_prop_raise;
}

function raise_prop(value, prop)
{
    if (!isdefined(prop) || istrue(prop.cicada_prop_linked))
        return;

    prop.origin = prop.origin + (0, 0, value - prop_raise(prop));
    prop.cicada_prop_raise = value;

    settle_collision(prop);
    self cicada_menu::update_menu();
}

function prop_yaw(prop)
{
    if (!isdefined(prop))
        return 0;

    return int(prop.angles[1]);
}

function turn_prop(value, prop)
{
    if (!isdefined(prop))
        return;

    prop.angles = (prop.angles[0], value, prop.angles[2]);
    self cicada_menu::update_menu();
}

function is_spinning(prop)
{
    return isdefined(prop) && istrue(prop.cicada_prop_spin);
}

function private spin_prop(prop)
{
    level endon("game_ended");

    while (isdefined(prop) && istrue(prop.cicada_prop_spin))
    {
        prop rotateyaw(360, 2);
        wait 2;
    }
}

function toggle_spin(prop)
{
    if (!isdefined(prop))
        return;

    if (istrue(prop.cicada_prop_linked))
    {
        self cicada_util::message(cicada_util::warn("stop carrying it first"));
        return;
    }

    if (istrue(prop.cicada_prop_spin))
        prop.cicada_prop_spin = false;
    else
    {
        prop.cicada_prop_spin = true;
        level thread [[&spin_prop]](prop);
    }

    self cicada_menu::update_menu();
}

function is_solid(prop)
{
    return isdefined(prop) && istrue(prop.cicada_prop_solid);
}

function toggle_solid(prop)
{
    if (!isdefined(prop))
        return;

    if (istrue(prop.cicada_prop_solid))
    {
        prop.cicada_prop_solid = false;
        prop notsolid();
    }
    else
    {
        prop.cicada_prop_solid = true;
        prop solid();
    }

    self cicada_menu::update_menu();
}

function is_linked(prop)
{
    return isdefined(prop) && istrue(prop.cicada_prop_linked);
}

function toggle_link(prop)
{
    if (!isdefined(prop))
        return;

    if (istrue(prop.cicada_prop_linked))
    {
        prop.cicada_prop_linked = false;
        prop unlink();

        if (istrue(prop.cicada_prop_clip_wanted))
        {
            prop.cicada_prop_clip_wanted = undefined;
            self add_collision(prop);
        }
    }
    else
    {
        if (has_collision(prop))
        {
            prop.cicada_prop_clip_wanted = true;
            drop_collision(prop);
        }

        prop.cicada_prop_linked = true;
        prop linkto(self, "tag_origin", (48, 0, 0), (0, 0, 0));
    }

    self cicada_menu::update_menu();
}

function private rebuild()
{
    kept = [];

    foreach (prop in props())
        kept[kept.size] = prop;

    level.cicada_props = kept;
}

function delete_prop(prop)
{
    if (!isdefined(prop))
        return;

    prop.cicada_prop_spin = false;
    prop.cicada_prop_moving = false;

    if (istrue(prop.cicada_prop_linked))
    {
        prop.cicada_prop_linked = false;
        prop unlink();
    }

    drop_collision(prop);
    prop delete();

    rebuild();
    self cicada_util::message("prop ^1deleted");
    self cicada_menu::update_menu();
}

function clear_props()
{
    foreach (prop in props())
    {
        prop.cicada_prop_spin = false;
        prop.cicada_prop_moving = false;

        if (istrue(prop.cicada_prop_linked))
        {
            prop.cicada_prop_linked = false;
            prop unlink();
        }

        drop_collision(prop);
        prop delete();
    }

    level.cicada_props = [];
    self cicada_util::message("props ^1cleared");
    self cicada_menu::update_menu();
}

function is_moving(prop)
{
    return isdefined(prop) && istrue(prop.cicada_prop_moving);
}

function private run_prop_path(owner, prop, total)
{
    level endon("game_ended");

    speed = owner cicada_util::getpersfloat("prop_speed");

    if (speed <= 0)
        speed = 100;

    for (;;)
    {
        for (i = 0; i < total; i++)
        {
            if (!isdefined(prop) || !istrue(prop.cicada_prop_moving))
                return;

            spot = owner cicada_movement::point("prop_path", i);

            if (!isdefined(spot))
                continue;

            travel = distance(prop.origin, spot) / speed;

            if (travel <= 0.05)
                travel = 0.05;

            if (istrue(owner cicada_util::getpers("prop_path_face")))
            {
                facing = vectortoangles(spot - prop.origin);
                prop.angles = (0, facing[1], 0);
            }

            prop moveto(spot, travel);

            if (has_collision(prop))
            {
                base = spot + prop_clip_offset(prop);

                foreach (clip in prop.cicada_prop_clips)
                    if (isdefined(clip))
                        clip moveto(base + clip.cicada_prop_spread, travel);
            }

            wait travel;
        }

        if (!istrue(owner cicada_util::getpers("prop_path_loop")))
            break;
    }

    if (isdefined(prop))
        prop.cicada_prop_moving = false;
}

function start_prop_path(prop)
{
    if (!isdefined(prop))
        return;

    if (istrue(prop.cicada_prop_linked))
    {
        self cicada_util::message(cicada_util::warn("stop carrying it first"));
        return;
    }

    if (istrue(prop.cicada_prop_moving))
    {
        prop.cicada_prop_moving = false;
        self cicada_util::message("path movement ^1stopped");
        self cicada_menu::update_menu();
        return;
    }

    total = self cicada_movement::count("prop_path");

    if (!total)
    {
        self cicada_util::message_bold("^6save a point first");
        return;
    }

    prop.cicada_prop_moving = true;
    level thread [[&run_prop_path]](self, prop, total);

    self cicada_menu::update_menu();
}
