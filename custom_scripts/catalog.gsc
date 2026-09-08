#using custom_scripts\util;

#namespace cicada_catalog;

// every id below appears in the mwiii script dump
function init()
{
    level.cicada_weapon_classes = [];

    // same token set as scripts\cp_mp\weapon::getweaponrootname
    foreach (code in cicada_util::list("ar,sm,lm,sh,sn,dm,pi,la,me,br"))
        level.cicada_weapon_classes[code] = true;

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
    slot_tokens("grip", "grp,ubr,fgrip,rgrip");
    slot_tokens("muzzle", "mzl,silencer,supp");
    slot_tokens("barrel", "bar");
    slot_tokens("magazine", "mag");
    slot_tokens("stock", "stk");

    attachment_chance("pistols", "dual wield", 55);
    attachment_chance("pistols", "laser", 35);
    attachment_chance("shotguns", "grip", 70);
    attachment_chance("shotguns", "laser", 40);
    attachment_chance("snipers", "laser", 80);
    attachment_chance("snipers", "barrel", 25);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "grip", 35);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "laser", 30);
    attachment_chance("assault rifles,battle rifles,sub machine guns,light machine guns", "muzzle", 20);

    entries("equipment", "frag_grenade_mp,semtex_mp,molotov_mp,thermite_mp,c4_mp,claymore_mp,throwingknife_mp,flash_grenade_mp,concussion_grenade_mp,smoke_grenade_mp,snapshot_grenade_mp");
    entries("equipment", "decoy_grenade_mp,cluster_grenade_mp,gas_grenade_mp,emp_grenade_mp,trophy_mp,at_mine_mp,shock_stick_mp,tac_camera_mp");
    entries("equipment", "jup_frag_grenade_mp,jup_c4_mp,jup_claymore_mp,jup_smoke_grenade_mp,jup_semtex_mike32_mp");

    entries("equipment", "briefcase_bomb_mp,bunkerbuster_mp,bunkerbuster_burrowed_mp,bunkerbuster_not_burrowed_mp,sonar_pulse_mp,throwstar_mp,gas_mp");
    entries("equipment", "interrogation_tools_mp,ks_gesture_phone_mp,ks_remote_device_mp,ks_remote_map_mp,remotemissile_projectile_mp,emp_pulse_device_mp,support_box_mp,emp_drone_player_mp");

    // names passed to killstreaks::registerkillstreak across the dump
    streak("uav", "uav", 4, "reveals enemies on the minimap");
    streak("loitering_munition", "loitering munition", 4, "circles the launch point, dive bombs and explodes");
    streak("switchblade_drone", "mosquito drone", 4, "drone that launches directly like a projectile");
    streak("missile_turret", "sam turret", 4, "turret that fires missiles at air vehicles");
    streak("assault_drone", "bomb drone", 4, "remote drone carrying a c4 charge");
    streak("lrad", "guardian-sc", 5, "beam that stuns, slows and blinds enemies inside it");
    //streak("scrambler_drone_guard", "counter uav", 5, "minimap scrambler"); // counter-uav
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

function equipment_refs(slot)
{
    refs = [];

    if (!isdefined(level.equipment) || !isdefined(level.equipment.table))
        return refs;

    foreach (ref, info in level.equipment.table)
        if (isdefined(info.defaultslot) && info.defaultslot == slot)
            refs[refs.size] = ref;

    return refs;
}

function super_refs()
{
    refs = [];

    if (!isdefined(level.superglobals) || !isdefined(level.superglobals.staticsuperdata))
        return refs;

    foreach (ref, data in level.superglobals.staticsuperdata)
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
        level.cicada_camos[level.cicada_camos.size] = id;
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

// mp/gesturetable.csv, column 0 ref, column 1 gesture weapon
function gestures()
{
    if (isdefined(level.cicada_gestures))
        return level.cicada_gestures;

    list = [];
    seen = [];

    for (row = 0; true; row++)
    if (isdefined(level.gestureinfobyindex))
    {
        foreach (weapon in level.gestureinfobyindex)
        {
            if (!isdefined(weapon) || weapon == "" || istrue(seen[weapon]))
                continue;

            seen[weapon] = true;
            list[list.size] = weapon;
        }
    }

    if (!list.size && isdefined(level.gestureinfo))
    {
        foreach (weapon in level.gestureinfo)
        {
            if (!isdefined(weapon) || weapon == "" || istrue(seen[weapon]))
                continue;

            seen[weapon] = true;
            list[list.size] = weapon;
        }
    }

    if (!list.size)
    {
        for (row = 0; true; row++)
        {
            ref = tablelookupbyrow("mp/gesturetable.csv", row, 0);

            if (!isdefined(ref) || ref == "")
                break;

            weapon = tablelookupbyrow("mp/gesturetable.csv", row, 1);

            if (!isdefined(weapon) || weapon == "" || istrue(seen[weapon]))
                continue;

            seen[weapon] = true;
            list[list.size] = weapon;
        }
    }

    if (list.size)
        level.cicada_gestures = list;

    return list;
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
