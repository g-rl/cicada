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

function private prop_model_swap(prop, name)
{
    prop.cicada_prop_model = name;
    prop setmodel(name);
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
