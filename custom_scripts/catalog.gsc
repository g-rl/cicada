#using custom_scripts\util;

#namespace cicada_catalog;

function init()
{
    level.cicada_weapon_classes = [];

    foreach (code in cicada_util::list("ar,sm,lm,sh,sn,dm,pi,la,me,br"))
        level.cicada_weapon_classes[code] = true;

    level.cicada_weapon_types = [];
    level.cicada_type_tokens = [];

    weapon_type("assault rifles", "ar");
    weapon_type("battle rifles", "br");
    weapon_type("sub machine guns", "sm");
    weapon_type("shotguns", "sh");
    weapon_type("light machine guns", "lm");
    weapon_type("snipers", "sn,dm");
    weapon_type("launchers", "la");
    weapon_type("pistols", "pi");
    weapon_type("melee", "me");

    level.cicada_blocked_refs = [];

    // this stuff crashes the game lol
    block_refs("equip_adrenaline,equip_battlerage,equip_gas_grenade,equip_advanced_vehicle_drop,equip_deployable_kiosk_drop_jup");
    block_refs("equip_armor_onehanded,equip_armor_onehanded_quick,equip_mutation_shield,equip_mutation_give_shield,equip_mutant_ability_5,equip_mutant_ability_6");

    level.cicada_catalog = [];
    level.cicada_groups = [];

    group("primaries", "assault rifles,battle rifles,sub machine guns,shotguns,light machine guns,snipers");
    group("secondaries", "launchers,pistols,misc");

    group_union("secondary types", "secondaries,primaries");

    entries("assault rifles", "jup_jp01_ar_golf36,jup_jp19_ar_acharlie,jup_jp34_ar_balpha27,jup_jp36_ar_anov94,iw9_ar_akilo_mp,iw9_ar_augolf_mp,iw9_ar_mike4_mp");
    entries("battle rifles", "jup_jp02_br_bromeo2,jup_jp19_br_acharlie450,jup_cp08_br_xmike5");
    entries("sub machine guns", "jup_jp02_sm_scharlie3,jup_jp04_sm_umike,jup_cp01_sm_coscar635,iw9_sm_aviktor_mp,iw9_sm_mpapa5_mp,iw9_sm_mpapa7_mp,iw9_sm_papa90_mp");
    entries("shotguns", "jup_cp01_sh_aromeo410,jup_jp09_sh_oromeo12,jup_jp16_sh_recho870,jup_jp38_sh_spapa12,iw9_sh_charlie725_mp,iw9_sh_mbravo_mp,iw9_sh_mike1014_mp,iw9_sh_mviktor_mp,iw9_sh_tsierra12_mp,iw9_sh_vecho_mp");
    entries("light machine guns", "jup_jp01_lm_mgolf36,jup_jp06_lm_pkilop,jup_jp08_lm_qbravo95lsw,jup_jp20_lm_evictor,jup_jp28_lm_rpapa20,iw9_lm_dblmg_mp,iw9_lm_mkilo3_mp,iw9_lm_slima_mp");
    entries("snipers", "jup_jp10_sn_cdelta50,jup_jp13_sn_svictor,jup_jp17_sn_hsierra,jup_jp35_sn_moscar,jup_jp36_sn_boscar,iw9_sn_alpha50_mp,iw9_sn_india_mp,iw9_sn_limax_mp");

    entries("launchers", "jup_jp22_la_dromeo,jup_jp26_la_cluster,iw9_la_gromeo_mp,iw9_la_juliet_mp,iw9_la_kgolf_mp,iw9_la_mike32_mp,iw9_la_rpapa7_mp");
    entries("pistols", "jup_cp24_pi_glima21,jup_jp07_pi_uzulum,jup_jp12_pi_mike93,jup_jp14_pi_rsierra12,jup_jp32_pi_mpapa9,iw9_pi_decho_mp,iw9_pi_golf17_mp,iw9_pi_golf18_mp,iw9_pi_papa220_mp,iw9_pi_swhiskey_mp");
    entries("misc", "jup_jp23_me_knife,jup_jp23_me_spear,jup_me_shotel,jup_pi_goldengun_mp,jup_pi_raygun_mp,jup_la_humangun_mp,jup_la_plasmagun_mp");
    entries("misc", "iw9_me_riotshield_mp,iw9_me_knife_mp,iw9_me_fists_mp,iw9_me_kamas_mp,iw9_me_sword01_mp,iw9_me_tonfa_mp,iw9_me_buzzsaw_mp,iw9_pi_stimpistol_mp");

    level.cicada_attachment_slots = [];
    level.cicada_attachment_odds = [];

    slot_tokens("dual wield", "akimbo");
    slot_tokens("laser", "lsr,laserir");
    slot_tokens("optic", "opt,scope,reflex,holo,thermal,acog,sight,snprscope");
    slot_tokens("muzzle", "mzl,silencer,supp,brake,comp");
    slot_tokens("underbarrel", "ubr,grenade_launcher,shotgun_under");
    slot_tokens("rear grip", "rgrip,grip_rear,tape");
    slot_tokens("grip", "grp,fgrip,guard_");
    slot_tokens("barrel", "bar,slide_");
    slot_tokens("magazine", "mag,xmags,drums,box_,rack,cal");
    slot_tokens("ammunition", "ammo_,rounds");
    slot_tokens("stock", "stk,back_");

    attachment_chance("pistols", "dual wield", 55);
    attachment_chance("pistols", "laser", 35);
    attachment_chance("shotguns", "grip", 70);
    attachment_chance("shotguns", "laser", 40);
    attachment_chance("snipers", "laser", 80);
    attachment_chance("snipers", "barrel", 25);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "grip", 35);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "laser", 30);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "muzzle", 20);

    entries("equipment", "frag_grenade_mp,semtex_mp,molotov_mp,thermite_mp,c4_mp,claymore_mp,throwingknife_mp,flash_grenade_mp,concussion_grenade_mp,snapshot_grenade_mp");
    entries("equipment", "decoy_grenade_mp,cluster_grenade_mp,gas_grenade_mp,emp_grenade_mp,trophy_mp,at_mine_mp,shock_stick_mp,tac_camera_mp");
    entries("equipment", "jup_frag_grenade_mp,jup_c4_mp,jup_claymore_mp,jup_semtex_mike32_mp");

    entries("equipment", "briefcase_bomb_mp,bunkerbuster_mp,bunkerbuster_burrowed_mp,bunkerbuster_not_burrowed_mp,sonar_pulse_mp,throwstar_mp,gas_mp");
    entries("equipment", "interrogation_tools_mp,ks_gesture_phone_mp,ks_remote_device_mp,ks_remote_map_mp,remotemissile_projectile_mp,emp_pulse_device_mp,support_box_mp,emp_drone_player_mp");

    streak("uav", "uav", 4, "reveals enemies on the minimap");
    streak("loitering_munition", "loitering munition", 4, "circles the launch point, dive bombs and explodes");
    streak("switchblade_drone", "mosquito drone", 4, "drone that launches directly like a projectile");
    streak("missile_turret", "sam turret", 4, "turret that fires missiles at air vehicles");
    streak("assault_drone", "bomb drone", 4, "remote drone carrying a c4 charge");
    streak("lrad", "guardian-sc", 5, "beam that stuns, slows and blinds enemies inside it");
    streak("airdrop", "care package", 5, "random streak crate at your location");
    streak("counter_uav", "counter uav", 5, "scrambles every enemy minimap");
    streak("cluster_spike", "cluster mine", 6, "thrown device that scatters smaller mines");
    streak("precision_airstrike", "precision airstrike", 6, "twin jets strike along a painted path");
    streak("cruise_predator", "cruise missile", 6, "player controlled missile with boost");
    streak("remote_turret", "remote turret", 7, "auto turret firing incendiary rounds");
    streak("toma_strike", "mortar strike", 7, "several waves of mortars on a location");
    streak("multi_airstrike", "sae", 7, "trio of jets drop explosives on marked targets");
    streak("juggernaut_recon", "juggernaut recon", 8, "recon jugg crate: riot shield, haymaker, enemy radar");
    streak("pac_sentry", "wheelson-hs", 8, "remote amphibious vehicle with auto sentry");
    streak("radar_drone_overwatch", "overwatch helo", 8, "escort helo pings then engages enemies");
    streak("auto_drone", "carpet bomb", 10, "bomber lays a long line of explosives along its path");
    streak("hover_jet", "vtol jet", 10, "drops bombs then guards a chosen location");
    streak("airdrop_multiple", "emergency airdrop", 10, "three random streak crates");
    //streak("fuel_airstrike", "carpet bomb?", 10, "bomber lays a long line of explosives"); // SAE
    streak("directional_uav", "advanced uav", 12, "orbital uav showing enemy facing in real time");
    streak("chopper_gunner", "chopper gunner", 12, "controllable chopper with turret and missiles");
    streak("gunship", "gunship", 12, "40mm / 25mm cannons plus a laser guided missile");
    streak("juggernaut", "juggernaut", 15, "assault juggernaut suit dropped in a crate");

    // warzone & mwii leftovers
    streak("drone_swarm", "drone swarm", undefined, "warzone swarm of attack drones");
    streak("missile_drone", "missile drone", undefined, "drone that fires missiles at marked targets");
    streak("dna_nuke", "dna nuke", undefined, "warzone dna bomb");
    streak("juggernaut_mutant", "juggernaut (mutant)", undefined, "event juggernaut variant");
    streak("specialist_perk_1", "specialist perk 1", undefined, "specialist bonus perk slot");
    streak("specialist_perk_2", "specialist perk 2", undefined, "specialist bonus perk slot");
    streak("specialist_perk_3", "specialist perk 3", undefined, "specialist bonus perk slot");
    streak("specialist_perk_bonus", "specialist bonus", undefined, "specialist package completion bonus");
    streak("ims", "ims", undefined, "i.m.s. proximity mine launcher");
    streak("uav_bigmap", "uav (big map)", undefined, "warzone sized uav sweep");
    streak("sentry_gun", "sentry gun", undefined, "classic auto turret, mwii style");
    streak("manual_turret", "manual turret", undefined, "player operated mounted turret");
    streak("remote_mg_turret", "remote mg turret", undefined, "remote machine gun turret");
    streak("radar_drone_recon", "recon drone", undefined, "juggernaut recon crate / recon drone");
    streak("chopper_support", "support helo", undefined, "ai helo that patrols and engages");
    streak("airdrop_escort", "escort airdrop", undefined, "crate guarded by an escort helo");
    streak("supply_sweep", "supply sweep", undefined, "warzone supply run drop");
    streak("death_switch", "death switch", undefined, "detonates around you on death");
    streak("emp", "emp", undefined, "disables enemy electronics and hud");
    streak("white_phosphorus", "white phosphorus", undefined, "burning smoke that blinds and damages");
    streak("nuke", "tactical nuke", undefined, "ends the match");
    streak("nuke_multi", "nuke (multi)", undefined, "multi warhead nuke variant");
    streak("nuke_select_location", "nuke (placed)", undefined, "nuke on a chosen location");
    streak("circle_peek", "circle peek", undefined, "warzone next circle recon");

    level.cicada_camos = [];
    level.cicada_camo_sets = [];
    level.cicada_camo_families = [];
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

    level.cicada_visions = [];
    visions("black_bw,end_game,focus,thermal_vision,nuke_deathblur,nuke_global_aftermath,cer_gas_mp");
    visions("battlerage-full-health,battlerage-low-health,flir_2_color_gradient,flir_0_black_to_white_heavy_damage");
    visions("proto_apache_flir_mp,recon_drone_color_mp,iw9_mp_nvg_base_color,aviCougarGunner,tacCam");
    visions("mp_core_infil,mp_core_infil_2,respawn_camera,respawn_camera_night,wp_flare,pe_auavscan_flash");
    visions("mp_jup_killstreak_dna,tac_ops_slamzoom,infil_spear_pm,cruise_intro_shipment,mp_jup_estate_helicopter_intro");
    visions("mp_jup_invasion_jltv_infil_2,mp_frontend_mgl_lobby,mp_frontend_jup_01_lobby,mp_frontend_mgl_lethal,mp_frontend_mgl_tactical");
}

function streak(id, name, cost, summary)
{
    category = isdefined(cost) ? "mp streaks" : "warzone extras";
    list = isdefined(level.cicada_catalog[category]) ? level.cicada_catalog[category] : [];

    // documenting it for future use cases
    entry = spawnstruct();
    entry.id = id;
    entry.name = name;
    entry.cost = cost;
    entry.summary = summary;
    list[list.size] = entry;

    level.cicada_catalog[category] = list;
}

function block_refs(refs)
{
    foreach (ref in cicada_util::list(refs))
        level.cicada_blocked_refs[ref] = true;
}

function is_blocked(ref)
{
    return isdefined(level.cicada_blocked_refs) && istrue(level.cicada_blocked_refs[ref]);
}

function equipment_refs(slot)
{
    refs = [];

    if (!isdefined(level.equipment) || !isdefined(level.equipment.table))
        return refs;

    foreach (ref, info in level.equipment.table)
        if (isdefined(info.defaultslot) && info.defaultslot == slot && !is_blocked(ref))
            refs[refs.size] = ref;

    return refs;
}

function super_refs()
{
    refs = [];

    if (!isdefined(level.superglobals) || !isdefined(level.superglobals.staticsuperdata))
        return refs;

    foreach (ref, data in level.superglobals.staticsuperdata)
        if (!is_blocked(ref))
            refs[refs.size] = ref;

    return refs;
}

function pretty(ref, prefix)
{
    text = "";

    foreach (part in strtok(ref, "_"))
    {
        if (text == "" && isdefined(prefix) && part == prefix)
            continue;

        text = (text == "") ? part : text + " " + part;
    }

    return (text == "") ? ref : text;
}

function camos(ids)
{
    foreach (id in cicada_util::list(ids))
    {
        level.cicada_camos[level.cicada_camos.size] = id;

        family = camo_family(id);

        if (!isdefined(level.cicada_camo_sets[family]))
        {
            level.cicada_camo_sets[family] = [];
            level.cicada_camo_families[level.cicada_camo_families.size] = family;
        }

        set = level.cicada_camo_sets[family];
        set[set.size] = id;
        level.cicada_camo_sets[family] = set;
    }
}

// camo_<family>_<number>
function camo_family(id)
{
    parts = strtok(id, "_");
    return (parts.size > 2) ? ("camo set " + parts[1]) : id;
}

function camo_families()
{
    return level.cicada_camo_families;
}

function camos_in(family)
{
    if (!isdefined(level.cicada_camo_sets[family]))
        return [];

    return level.cicada_camo_sets[family];
}

function visions(ids)
{
    foreach (id in cicada_util::list(ids))
        level.cicada_visions[level.cicada_visions.size] = id;
}

function vision_refs()
{
    return level.cicada_visions;
}

function killstreak_vision_refs()
{
    refs = [];

    if (!isdefined(level.killstreakvisionsets))
        return refs;

    foreach (name, data in level.killstreakvisionsets)
        refs[refs.size] = name;

    return refs;
}

function streak_hud_ready()
{
    return isdefined(level.killstreak_visbilityomnvarlist);
}

function streak_hud_labels()
{
    labels = [];
    labels[0] = "off";

    if (!streak_hud_ready())
        return labels;

    foreach (streak, states in level.killstreak_visbilityomnvarlist)
        foreach (state, value in states)
            labels[labels.size] = streak + " - " + state;

    return labels;
}

function streak_hud_count()
{
    return streak_hud_labels().size - 1;
}

function streak_hud_value(label)
{
    if (!isdefined(label) || label == "off" || !streak_hud_ready())
        return 0;

    foreach (streak, states in level.killstreak_visbilityomnvarlist)
        foreach (state, value in states)
            if ((streak + " - " + state) == label)
                return value;

    return 0;
}

function private streak_first_value(streak)
{
    states = level.killstreak_visbilityomnvarlist[streak];

    if (!isdefined(states))
        return 0;

    if (isdefined(states["on"]))
        return states["on"];

    foreach (state, value in states)
        return value;

    return 0;
}

function streak_hud_guess(vision)
{
    if (!isdefined(vision) || vision == "" || !streak_hud_ready())
        return 0;

    pairs = cicada_util::list("chopper:chopper_gunner,gunship:gunship,cruise:cruise_predator,manual_turret:manual_turret,turret:remote_turret,sentry:pac_sentry,tank:pac_sentry,missile:missile_drone,jugg:juggernaut,mask:juggernaut");

    foreach (pair in pairs)
    {
        mark = cicada_util::before_mark(pair, ":");

        if (!issubstr(vision, mark))
            continue;

        value = streak_first_value(cicada_util::after_mark(pair, ":"));

        if (value)
            return value;
    }

    return 0;
}

function streak_hud_label_for(value)
{
    if (!value || !streak_hud_ready())
        return "off";

    foreach (streak, states in level.killstreak_visbilityomnvarlist)
        foreach (state, other in states)
            if (other == value)
                return streak + " - " + state;

    return "off";
}

function vision_label(name)
{
    text = "";

    foreach (part in strtok(name, "_"))
        text = (text == "") ? part : text + " " + part;

    return (text == "") ? name : text;
}

function weapon_type(name, tokens)
{
    level.cicada_weapon_types[level.cicada_weapon_types.size] = name;
    level.cicada_type_tokens[name] = cicada_util::list(tokens);
}

function weapon_types()
{
    return level.cicada_weapon_types;
}

function weapon_class(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return undefined;

    foreach (part in strtok(weapon.basename, "_"))
        if (istrue(level.cicada_weapon_classes[part]))
            return part;

    return undefined;
}

function is_weapon_type(weapon, type)
{
    weapon_token = weapon_class(weapon);

    if (!isdefined(weapon_token) || !isdefined(level.cicada_type_tokens[type]))
        return false;

    foreach (token in level.cicada_type_tokens[type])
        if (token == weapon_token)
            return true;

    return false;
}

function group(name, categories)
{
    level.cicada_groups[name] = cicada_util::list(categories);
}

function group_union(name, sources)
{
    list = [];

    foreach (source in cicada_util::list(sources))
        foreach (category in level.cicada_groups[source])
            list[list.size] = category;

    level.cicada_groups[name] = list;
}

function weapon_categories()
{
    return cicada_util::list("assault rifles,battle rifles,sub machine guns,shotguns,light machine guns,snipers,pistols,launchers,misc,equipment");
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

function streak_summary(entry)
{
    return entry.summary;
}

function count(category)
{
    return get(category).size;
}

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

function with_random(options)
{
    list = [];
    list[0] = "random";

    foreach (option in options)
        list[list.size] = option;

    return list;
}

// mp/gesturetable.csv
function private add_gesture(list, seen, weapon)
{
    if (!isdefined(weapon) || weapon == "" || weapon == "none" || istrue(seen[weapon]))
        return list;

    seen[weapon] = true;
    list[list.size] = weapon;

    return list;
}

function gestures()
{
    if (isdefined(level.cicada_gestures))
        return level.cicada_gestures;

    list = [];
    seen = [];

    if (isdefined(level.gestureinfo))
        foreach (ref, weapon in level.gestureinfo)
            list = add_gesture(list, seen, weapon);

    if (isdefined(level.gestureinfobyindex))
        foreach (index, weapon in level.gestureinfobyindex)
            list = add_gesture(list, seen, weapon);

    for (row = 0; row < 1024; row++)
    {
        ref = tablelookupbyrow("mp/gesturetable.csv", row, 0);

        if (!isdefined(ref) || ref == "")
            break;

        list = add_gesture(list, seen, tablelookupbyrow("mp/gesturetable.csv", row, 1));
    }

    if (list.size)
        level.cicada_gestures = list;

    return list;
}

function gesture_count()
{
    return gestures().size;
}

function gesture_ref(id)
{
    list = gestures();

    if (!list.size)
        return undefined;

    return list[id % list.size];
}

function random_camo()
{
    return level.cicada_camos[randomint(level.cicada_camos.size)];
}

function slot_tokens(slot, tokens)
{
    level.cicada_attachment_slots[slot] = cicada_util::list(tokens);
}

function attachment_chance(categories, slot, chance)
{
    foreach (category in cicada_util::list(categories))
    {
        list = isdefined(level.cicada_attachment_odds[category]) ? level.cicada_attachment_odds[category] : [];

        entry = spawnstruct();
        entry.slot = slot;
        entry.chance = chance;
        list[list.size] = entry;

        level.cicada_attachment_odds[category] = list;
    }
}

function slot_names()
{
    return cicada_util::list("optic,muzzle,barrel,underbarrel,magazine,ammunition,stock,grip,rear grip,laser,dual wield,other");
}

function slot_of(name)
{
    foreach (slot in slot_names())
        if (slot != "other" && in_slot(name, slot))
            return slot;

    return "other";
}

function attachment_odds(category)
{
    if (!isdefined(level.cicada_attachment_odds[category]))
        return [];
    return level.cicada_attachment_odds[category];
}

function in_slot(name, slot)
{
    tokens = level.cicada_attachment_slots[slot];

    if (!isdefined(tokens))
        return false;

    foreach (token in tokens)
        if (issubstr(name, token))
            return true;

    return false;
}

function sound_groups()
{
    return cicada_util::list("interface,multiplayer,jupiter,killstreaks,weapons,zombies,events,warzone,vehicles,ambient,shared,misc");
}

function private add_sounds(list, text)
{
    foreach (name in cicada_util::list(text))
        if (soundexists(name))
            list[list.size] = name;

    return list;
}

function private sounds_interface()
{
    list = [];

    list = add_sounds(list, "ui_chyron_firstline,ui_chyron_plusminus,ui_menu_ability_hover,ui_mp_fire_sale_timer,ui_mp_suitcasebomb_timer,ui_mp_suitcasebomb_timer_urgent");
    list = add_sounds(list, "ui_mp_timer_countdown,ui_mp_timer_countdown_half_sec,ui_restock_lethals,ui_restock_tactical,ui_select_purchase_confirm,ui_select_purchase_deny");
    list = add_sounds(list, "ui_stealth_threat_hud_periph_vision,ui_team_wipe_splash,ui_text_type,uin_ammomod_proc_to_player_2d,uin_firingrange_target_fall");
    list = add_sounds(list, "uin_firingrange_target_move,uin_hvt_ally_downed,uin_hvt_ally_killed,uin_hvt_ally_spawned,uin_hvt_enemy_downed,uin_hvt_enemy_killed");
    list = add_sounds(list, "uin_hvt_enemy_spawned,uin_iw9_ftue_tip_generic,uin_iw9_lockdown_zone_exit,uin_jup_br_perk_combat_scout_marking_resist,uin_mp_flag_ally_captured");
    list = add_sounds(list, "uin_mp_flag_ally_pickup,uin_mp_flag_ally_returned,uin_mp_flag_enemy_captured,uin_mp_flag_enemy_pickup,uin_mp_flag_enemy_returned,uin_ping_confirm");
    list = add_sounds(list, "uin_ping_enemy,uin_ping_wheel_announce_help,uin_splash_bounty_unmarked,uin_tip_appearance");

    return list;
}

function private sounds_multiplayer()
{
    list = [];

    list = add_sounds(list, "mp_altered_strain_dna_pickup_ally,mp_altered_strain_dna_pickup_enemy,mp_bodycount_tick_negative,mp_bodycount_tick_negative_final");
    list = add_sounds(list, "mp_bodycount_tick_positive,mp_bodycount_tick_positive_final,mp_bomb_defuse,mp_bomb_pickup,mp_bomb_raise_noise,mp_bombplaced_enemy");
    list = add_sounds(list, "mp_bombplaced_friendly,mp_camera_intro_whoosh,mp_care_package_high_impact,mp_care_package_retrieve_mesh_net,mp_cmd_camera_zoom_in");
    list = add_sounds(list, "mp_cmd_camera_zoom_out,mp_codball_pulse_npc,mp_codball_pulse_plr,mp_codball_pulse_ready_npc,mp_codball_pulse_ready_plr,mp_combat_outpost_activateobj");
    list = add_sounds(list, "mp_countdown_dna_pickup_ally,mp_countdown_dna_pickup_enemy,mp_dmz_alrm_star,mp_dmz_hostage_unzip,mp_dmz_phone_pickup,mp_dom_flag_captured");
    list = add_sounds(list, "mp_dom_flag_captured_all,mp_dom_flag_lost,mp_dom_flag_lost_all,mp_dropzone_captured_negative,mp_dropzone_captured_positive,mp_dropzone_obj_new");
    list = add_sounds(list, "mp_elevator_button_press,mp_elevator_open,mp_enemy_obj_captured,mp_equip_box_destroyed,mp_equip_destroyed,mp_grind_token_pickup");
    list = add_sounds(list, "mp_hardpoint_captured_negative,mp_hardpoint_captured_positive,mp_hit_alert_final_npc,mp_hq_deactivate_sfx,mp_hq_respawn_disabled");
    list = add_sounds(list, "mp_jugg_mus_toggle_button,mp_jup_bait_duck_game_start,mp_jup_control_capturing_negative,mp_jup_control_capturing_positive");
    list = add_sounds(list, "mp_jup_control_defending_negative,mp_jup_control_defending_positive,mp_jup_point_captured,mp_jup_point_lost,mp_jup_secure_ally_hack_screen");
    list = add_sounds(list, "mp_jup_secure_ally_hack_timer_beep,mp_jup_secure_ally_hack_timer_complete,mp_jup_secure_ally_hack_timer_start,mp_jup_secure_enemy_hack_screen");
    list = add_sounds(list, "mp_jup_secure_enemy_hack_timer_beep,mp_jup_secure_enemy_hack_timer_complete,mp_jup_secure_enemy_hack_timer_start,mp_jup_secure_hack_screens_popup");
    list = add_sounds(list, "mp_jup_slam_deathmatch_takedown_crowd,mp_jup_training_objective_success,mp_jup_training_target_down,mp_jup_training_target_fail");
    list = add_sounds(list, "mp_jup_training_target_success,mp_jup_training_target_up,mp_kill_alert,mp_kill_alert_quiet,mp_killconfirm_tags_pickup,mp_killstreak_apache_death_plr");
    list = add_sounds(list, "mp_killstreak_disappear,mp_killstreak_transition_whoosh,mp_obj_captured,mp_obj_returned,mp_obj_taken,mp_oic_ammo_pickup,mp_overcharge_off");
    list = add_sounds(list, "mp_overcharge_on,mp_parachute_land_ally,mp_walla_invasion_charge_individual");

    return list;
}

function private sounds_jupiter()
{
    list = [];

    list = add_sounds(list, "jup_arcade_powerup_expire,jup_arcade_powerup_pickup_ally,jup_arcade_powerup_pickup_enemy,jup_arcade_weapon_pickup_ally,jup_arcade_weapon_pickup_enemy");
    list = add_sounds(list, "jup_bounty_hvt_killed_negative,jup_bounty_hvt_killed_positive,jup_bounty_hvt_killed_positive_player,jup_bounty_hvt_marked_enemy");
    list = add_sounds(list, "jup_bounty_hvt_marked_player,jup_bounty_hvt_marked_team,jup_bounty_hvt_new_target_splash,jup_br_interrogation_pda_ui_ally_0");
    list = add_sounds(list, "jup_br_interrogation_pda_ui_enemy_0,jup_cache_obj_pickup_allies,jup_cache_spawn_lrg,jup_cache_spawn_med,jup_cache_spawn_sml,jup_confv_perk_durability");
    list = add_sounds(list, "jup_confv_perk_super_speed,jup_confv_perk_super_strength,jup_confv_vile_pickup_ally,jup_confv_vile_pickup_enemy,jup_cranked_timer_refill");
    list = add_sounds(list, "jup_cranked_timer_refill_assist,jup_cranked_timer_start,jup_cranked_timer_tick,jup_cranked_timer_tick_half,jup_cranked_timer_tick_last");
    list = add_sounds(list, "jup_cranked_timer_warning,jup_ctf_obj_captured_allies,jup_ctf_obj_captured_enemy,jup_ctf_obj_captured_player,jup_ctf_obj_drop_allies");
    list = add_sounds(list, "jup_ctf_obj_drop_enemy,jup_ctf_obj_drop_player,jup_ctf_obj_pickup_allies,jup_ctf_obj_pickup_enemy,jup_ctf_obj_pickup_player");
    list = add_sounds(list, "jup_ctf_obj_returned_allies,jup_ctf_obj_returned_enemy,jup_ctf_obj_returned_player,jup_ctf_obj_returned_time_allies,jup_ctf_obj_returned_time_enemy");
    list = add_sounds(list, "jup_gethigh_checkpoint_reached,jup_gethigh_checkpoint_respawn,jup_gethigh_death,jup_gethigh_falling_land,jup_gethigh_score_100");
    list = add_sounds(list, "jup_gethigh_score_completed,jup_gethigh_score_timeout,jup_gethigh_target_hit,jup_hordepoint_bone_pickup_ally,jup_hordepoint_bone_pickup_enemy");
    list = add_sounds(list, "jup_hordepoint_elite_splash,jup_hordepoint_pap_weapon_pickup,jup_hordepoint_skull_dog_pickup_ally,jup_hordepoint_skull_dog_pickup_enemy");
    list = add_sounds(list, "jup_hordepoint_skull_elite_pickup_ally,jup_hordepoint_skull_elite_pickup_enemy,jup_hordepoint_skull_helmet_pickup_ally");
    list = add_sounds(list, "jup_hordepoint_skull_helmet_pickup_enemy,jup_infected_enemy_last_stand,jup_infected_player_death_pulse,jup_infected_player_last_stand");
    list = add_sounds(list, "jup_infected_player_spawn,jup_infected_player_team_killed,jup_infil_blima_lr,jup_infil_c17_shot_01_lr,jup_infil_c17_shot_02_lr");
    list = add_sounds(list, "jup_infil_c17_shot_03_lr,jup_infil_dpv_preinfil_start,jup_infil_dpv_vehicle_01_brake,jup_infil_dpv_vehicle_02_brake,jup_infil_elevator_bell");
    list = add_sounds(list, "jup_infil_elevator_quad_lr,jup_infil_jltv_preinfil_start,jup_infil_mi8_heli_int_lr,jup_infil_palfa_estate_lr,jup_infil_palfa_lr,jup_kls_lrad_pickup");
    list = add_sounds(list, "jup_machine_gun_explode,jup_machine_gun_smoke,jup_maestro_drone_activate_launch,jup_maestro_drone_damaged,jup_maestro_drone_destroyed");
    list = add_sounds(list, "jup_mode_gun_rank_down,jup_mode_gun_rank_up,jup_mode_gunfight_newloadout_fade_in,jup_mode_gunfight_newloadout_fade_out,jup_mode_havoc_mod_timer_start");
    list = add_sounds(list, "jup_mode_havoc_mod_timer_tick,jup_mode_team_gun_rank_timer_0,jup_mode_team_gun_rank_up_gain,jup_mode_team_gun_rank_up_splash");
    list = add_sounds(list, "jup_mode_wm_pds_ally_drop,jup_mode_wm_pds_ally_pickup,jup_mode_wm_pds_ally_placed,jup_mode_wm_pds_enemy_drop,jup_mode_wm_pds_enemy_pickup");
    list = add_sounds(list, "jup_mode_wm_pds_enemy_placed,jup_mp_mode_mutation_acid_blast,jup_mp_mode_mutation_sludge_expl_vo,jup_revive_teammate_success");
    list = add_sounds(list, "jup_shared_bomb_defuse_start,jup_shared_team_revived,jup_shared_zone_defended,jup_shared_zone_spawned,jup_skydiving_geiger_high");
    list = add_sounds(list, "jup_skydiving_geiger_low,jup_skydiving_laser_armed,jup_skydiving_pds_capture_lp_start,jup_skydiving_pds_capture_lp_stop");
    list = add_sounds(list, "jup_wm_bombsite_recovered_ally,jup_wm_bombsite_recovered_enemy,jup_wm_bombsite_start_ally,jup_wm_bombsite_start_enemy,jup_wm_hack_beep_ally");
    list = add_sounds(list, "jup_wm_hack_beep_enemy,jup_wm_hack_complete_ally,jup_wm_hack_complete_enemy,jup_wm_hack_init_ally,jup_wm_hack_init_enemy,jup_wm_hack_recovered_ally");
    list = add_sounds(list, "jup_wm_hack_recovered_enemy,jup_wm_hack_start_ally,jup_wm_hack_start_enemy,jup_wz_purgatory_teleport_3d");

    return list;
}

function private sounds_killstreaks()
{
    list = [];

    list = add_sounds(list, "kls_jup_missile_drone_105mm_mp_reload,kls_jup_missile_drone_damage_light,kls_jup_missile_drone_exp_radio_hellfire_dist,kls_jup_missile_drone_zoom_in");
    list = add_sounds(list, "kls_jup_missile_drone_zoom_out,kls_location_select,kls_loitering_munition_fire,kls_remote_turret_pickup,kls_sam_turret_pickup,recondrone_damaged");
    list = add_sounds(list, "recondrone_destroyed,recondrone_lockon,recondrone_tag,recondrone_tag_plr,sentry_explode,sentry_explode_smoke,sentry_explode_sparks,sentry_gun_beep");
    list = add_sounds(list, "sentry_gun_plant,sentry_gun_plant_foley,sentry_gun_target_lock_beep,sentry_pickup,uav_tower_foley,uav_tower_foley_npc");

    return list;
}

function private sounds_weapons()
{
    list = [];

    list = add_sounds(list, "ammo_crate_use,attachment_pickup,c4_expl_swt,c4_expl_trans,eqp_bunkerbuster_drill_npc,eqp_personal_redeploy_drone_error,eqp_spotter_scope_marked_beep");
    list = add_sounds(list, "eqp_spotter_scope_marking,eqp_spycam_marked,scavenger_pack_pickup,shield_death_c6_1,weap_ammo_full,weap_bradley_reload_npc,weap_bradley_reload_plr");
    list = add_sounds(list, "weap_cluster_fire,weap_codball_shockstick_fire,weap_dblmg_spindown_npc,weap_dblmg_spinup_npc,weap_laser_fire_start_npc,weap_laser_fire_stop_npc");
    list = add_sounds(list, "weap_lasereyes_levitate_npc,weap_mortar_incoming,weap_mortar_load,weap_pickup_knife_plr,weap_pickup_spear,weap_reload_pistol_clipout_npc");
    list = add_sounds(list, "weap_reload_smg_clipout_npc,weap_samsite_plant_c4,weap_snowball_pickup,weap_thermal_toggle_click");

    return list;
}

function private sounds_zombies()
{
    list = [];

    list = add_sounds(list, "evt_entity_beam_zombie_dissolve_death,jup_mp_mode_mutation_zombie_superjump_charge,jup_mp_mode_mutation_zombie_superjump_leap");
    list = add_sounds(list, "jup_mp_mode_mutation_zombie_superjump_whoosh,scn_zr_infestation_zombies_far,vox_ai_aether_disciple_vulnerable,zmb_npc_breath_land_dropin");
    list = add_sounds(list, "zmb_npc_breath_land_hi,zmb_npc_impact_hit,zmb_player_impact_hit,zxp_charge_jump_full,zxp_charge_jump_start,zxp_grenade_vo_npc,zxp_spawn_splat_npc");
    list = add_sounds(list, "zxp_splat_npc");

    return list;
}

function private sounds_events()
{
    list = [];

    list = add_sounds(list, "evt_ai_entity_lightning_strike_hold_warning,evt_ai_entity_weakpoint_hit_marker,evt_ai_jansen_lightbomb_entity_explo");
    list = add_sounds(list, "evt_ai_jansen_lightbomb_soul_gather_death,evt_br_elite_arrow_neptunium_shock_in,evt_br_elite_arrow_neptunium_shock_out,evt_br_infil_jump_buzzer");
    list = add_sounds(list, "evt_br_infil_jump_stinger,evt_elite_arrow_element_pickup_swt,evt_elite_arrow_geiger_counter_tick,evt_elite_arrow_plutonium_damage");
    list = add_sounds(list, "evt_entity_arena_respawn_teleport_plr,evt_ob_entity_arena_arrive_stinger,evt_ob_pre_extract_thunder,evt_ob_rr_crystal_break_rune_trail_impact");
    list = add_sounds(list, "evt_ob_rr_crystal_break_rune_trail_spawn,evt_ob_rr_crystal_break_rune_unlink,evt_ob_rr_grenade_bandolier_activate,evt_ob_rr_keres_mask_activate");
    list = add_sounds(list, "evt_ob_rr_maestro_activate,evt_ob_rr_meteor_affirm,evt_ob_rr_obelisk_item_takeoff,evt_ob_rr_obelisk_soul_spawn,evt_ob_rr_red_beret_activate");
    list = add_sounds(list, "evt_ob_story_launch_pad_whoosh_npc,evt_ob_story_tear_teleport_plr,evt_ob_story_tower_intro,evt_zm_core_powerup_nuke_soul");
    list = add_sounds(list, "evt_zm_ob_rr_s5_5_thermal_phone_pickup,hostage_warning_beep_01,hostage_warning_beep_02,hostage_warning_beep_03,hostage_warning_beep_04");
    list = add_sounds(list, "hostage_warning_beep_05,scn_br_c17_infil_int,scn_infil_hackney_heli1_door_open,scn_infil_hackney_heli2_door_open,scn_infil_mbravo_heli_wind");
    list = add_sounds(list, "scn_mp_hackney_van_lr,scn_zr_infestation_siren,soc_ball_bounce_small,soc_ball_explode,soc_ball_goal_music,soc_ball_vanish");

    return list;
}

function private sounds_warzone()
{
    list = [];

    list = add_sounds(list, "br_bunker_door_open_01,br_bunker_door_open_02,br_circle_closing,br_deployable_kiosk_detach,br_deployable_kiosk_explode,br_event1_scramble_sfx");
    list = add_sounds(list, "br_exfil_end_part_lr,br_exfil_incoming_heli_lr,br_finish_them_splash,br_gulag_rock_player_impact,br_heli_infil_part1_lr,br_heli_infil_part2_lr");
    list = add_sounds(list, "br_infil_part1_lr,br_inventory_drop_weap_toss_only,br_pickup_cash_lrg_01,br_pickup_cash_vlrg_01,br_pickup_deny,br_pickup_deny_lyr,br_pickup_generic");
    list = add_sounds(list, "br_player_interrogated_enemy,br_player_revived,br_plunder_atm_cancel,br_plunder_atm_deposit_gtr,br_plunder_atm_use,br_reviver_use_end,br_rock_pickup");
    list = add_sounds(list, "br_the_boys_teleport_out_npc,breach_c4_plant_05,breach_warning_beep_01,breach_warning_beep_02,breach_warning_beep_03,breach_warning_beep_04");
    list = add_sounds(list, "breach_warning_beep_05,breathing_better,dmz_bombsite_warning_beep_01,dmz_bombsite_warning_beep_02,dmz_bombsite_warning_beep_03");
    list = add_sounds(list, "dmz_bombsite_warning_beep_04,dmz_bombsite_warning_beep_05,dmz_camera_zoom_in,wz_parkour_race_checkpoint,wz_parkour_race_failure,wz_parkour_race_start");
    list = add_sounds(list, "wz_parkour_race_success,wz_parkour_race_time_ticking_0");

    return list;
}

function private sounds_vehicles()
{
    list = [];

    list = add_sounds(list, "elev_bell_ding,elev_door_close,elev_door_interupt,elev_door_open,elev_run_end,elev_run_start,truck_sattruck_engineoff,truck_sattruck_initdeploy_os");
    list = add_sounds(list, "truck_sattruck_initialstartup_os,truck_sattruck_scanning_off,veh_ks_wheelson_explode,veh_train_pass_overhead,veh_warning_missile_incoming");
    list = add_sounds(list, "veh_warning_missile_locking");

    return list;
}

function private sounds_ambient()
{
    list = [];

    list = add_sounds(list, "amb_emt_cctv_monitor_static_burst,amb_infil_defender_lr,amb_infil_defender_skid_asphalt_01,amb_infil_defender_skid_asphalt_02");
    list = add_sounds(list, "amb_infil_defender_skid_dirt,amb_infil_van_lr,amb_mp_drivethru_carousel_music_speaker_start,amb_mp_drivethru_carousel_music_speaker_stop");
    list = add_sounds(list, "amb_skydiving_alarm_01_allies_fl,amb_skydiving_alarm_01_allies_fr,amb_skydiving_alarm_01_allies_rl,amb_skydiving_alarm_01_allies_rr");
    list = add_sounds(list, "amb_skydiving_alarm_01_allies_wet,amb_skydiving_alarm_01_enemy_fl,amb_skydiving_alarm_01_enemy_fr,amb_skydiving_alarm_01_enemy_rl");
    list = add_sounds(list, "amb_skydiving_alarm_01_enemy_rr,amb_skydiving_alarm_01_enemy_wet,amb_skydiving_alarm_02_allies_fl,amb_skydiving_alarm_02_allies_fr");
    list = add_sounds(list, "amb_skydiving_alarm_02_allies_rl,amb_skydiving_alarm_02_allies_rr,amb_skydiving_alarm_02_allies_wet,amb_skydiving_alarm_02_enemy_fl");
    list = add_sounds(list, "amb_skydiving_alarm_02_enemy_fr,amb_skydiving_alarm_02_enemy_rl,amb_skydiving_alarm_02_enemy_rr,amb_skydiving_alarm_02_enemy_wet");
    list = add_sounds(list, "amb_skydiving_gas_inside_stop");

    return list;
}

function private sounds_shared()
{
    list = [];

    list = add_sounds(list, "iw8_ks_ac130_weaponswitch,iw8_mp_perk_shrapnel,iw8_mp_perk_tactical_recon_marked,iw8_new_objective_sfx,iw8_rc_plane_engine_exp");
    list = add_sounds(list, "iw9_cruise_missile_exp_static,iw9_frag_grenade_expl_trans,iw9_geiger_counter_tick,iw9_ks_tablet_foly_lower_plr,iw9_ks_tablet_foly_raise_plr");
    list = add_sounds(list, "iw9_ks_tablet_ui_screen_plr,iw9_ks_tablet_ui_select_final_plr,iw9_ks_tablet_ui_select_plr,iw9_mgb_siren,iw9_mgb_splash,iw9_mp_disguise_alert");
    list = add_sounds(list, "iw9_mp_oitc_eliminate_player,iw9_mp_oitc_last_players,iw9_mp_radiation_tick,iw9_mp_ui_objective_lost,iw9_mp_ui_objective_taken");
    list = add_sounds(list, "iw9_mtx_tb_stim_activate_npc,iw9_smoke_airdrop_center_incoming,iw9_smoke_airdrop_center_outgoing,iw9_smoke_airdrop_release");
    list = add_sounds(list, "iw9_smoke_airdrop_smoke_start,iw9_smoke_airdrop_travel_incoming,iw9_smoke_airdrop_travel_outgoing,iw9_spotter_perk_tablet_ui");
    list = add_sounds(list, "iw9_support_box_bring_up_plr_1,iw9_support_box_use,iw9_tactical_insert_flare_pu,iw9_weap_molotov_fire_enemy_burn_end,iw9_weap_mtx_souleater_absorb");

    return list;
}

function private sounds_misc()
{
    list = [];

    list = add_sounds(list, "2pop,2pop_low,ai_melee_vs_shield,ai_radioactive_beast_charge_activate_swt,ai_radioactive_beast_charge_press,bullet_impact_headshot_npc");
    list = add_sounds(list, "bullet_npc_helmet_break,bullet_npc_helmet_impact,carousel_motor_start,carousel_motor_stop,carousel_toggle_switch,cp_bank_gate_fall,cp_bank_vault_open");
    list = add_sounds(list, "crate_impact,crossing_suv_lr,deadsilence_end,deadsilence_start,deaths_door_death,deaths_door_death_quiet,deaths_door_in,deaths_door_out");
    list = add_sounds(list, "dropship_explode_mp,dx_br_dbos_dbli_dbtp_bitr,dx_mp_grpx_annc_paan_theracehasbeencancel,dx_mpb_us3_hvt_up,emp_nade_lp_end,emt_diving_board");
    list = add_sounds(list, "equip_codball_shockstick_pickup,equip_tactical_cam_marked,equip_tactical_cam_passive_marked,exgm_parachute_detach_npc,exgm_parachute_open_npc");
    list = add_sounds(list, "exp_helicopter_fuel,exp_stinger_armor_destroy,final_killcam_in,final_killcam_out,flag_spawned,fly_dmz_disguise_off,fly_dmz_disguise_on");
    list = add_sounds(list, "fly_player_activate_portal,gas_player_cough,generic_flashbang_c6_1,ghost_wall_attach,ghost_wall_detach,gib_fullbody,hit_marker_dud");
    list = add_sounds(list, "jammer_drone_shockwave,javelin_clu_aquiring_lock,javelin_clu_lock,ks_ac130_damage_warning,ks_ac130_flares,laststand_heal_done,laststand_heal_start");
    list = add_sounds(list, "maaws_incoming_lp,maaws_reticle_locked,maaws_reticle_tracking,melee_knife_hit_body,mus_iw9_mpmusictest_ambient1_intro,mus_iw9_mpmusictest_hit1_intro");
    list = add_sounds(list, "mus_ob_rr_easteregg_115_instrumental,mvmt_heartbeat_plr_laststand,mvmt_swim_exitwater_plr,mvmt_swim_plunging_plr_fast");
    list = add_sounds(list, "mvmt_swim_surfacing_plr_sprint_gasping,npc_breath_revive,ob_entity_orb_spawn_in,ob_entity_reveal_impact_swt,ob_intro_storm_atmosphere");
    list = add_sounds(list, "ob_s5_story_intro_portal_close,oracle_radar_pulse_npc,perk_iw9_high_alert_dog_growl,plr_breath_land_parachute,plr_breath_pain_init");
    list = add_sounds(list, "plr_breath_pain_ong_exh,plr_breath_revive,radar_drone_explode,recon_drone_explode,recon_drone_marked_owner,recon_drone_marking_owner");
    list = add_sounds(list, "recon_drone_spotted_plr,rfid_tick,sfx_occupation_pre_scan_timer,shock_sentry_charge_up,smoke_canister_tail_dissipate,smoke_carepackage_expl_trans");
    list = add_sounds(list, "sonic_shotgun_debuff,tactical_spawn,thermite_bomb_crossbow_fire_end,thermite_bomb_crossbow_impact,tmp_br_infil_ac130_jumpmaster_go");
    list = add_sounds(list, "train_veh_impact_body,tripwire_pop,vest_expl_trans,wallrun_end_npc,wallrun_start_npc,wpn_combat_axe_pickup_plr");

    return list;
}

function sounds_in(group)
{
    switch (group)
    {
        case "interface":
            return sounds_interface();
        case "multiplayer":
            return sounds_multiplayer();
        case "jupiter":
            return sounds_jupiter();
        case "killstreaks":
            return sounds_killstreaks();
        case "weapons":
            return sounds_weapons();
        case "zombies":
            return sounds_zombies();
        case "events":
            return sounds_events();
        case "warzone":
            return sounds_warzone();
        case "vehicles":
            return sounds_vehicles();
        case "ambient":
            return sounds_ambient();
        case "shared":
            return sounds_shared();
        case "misc":
            return sounds_misc();
    }

    return [];
}

function sound_count(group)
{
    return sounds_in(group).size;
}

function sound_at(group, index)
{
    list = sounds_in(group);

    if (index < 0 || index >= list.size)
        return undefined;

    return list[index];
}

function random_sound(group)
{
    list = sounds_in(group);

    if (!list.size)
        return undefined;

    return list[randomint(list.size)];
}
