#using scripts\cp_mp\utility\game_utility;
#using scripts\mp\hud_util;

#using custom_scripts\binds;
#using custom_scripts\catalog;
#using custom_scripts\cinematics;
#using custom_scripts\killcam;
#using custom_scripts\loadout;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\util;

#namespace cicada_menu;

function initial_variable()
{
    // menu variables
    self.font            = "default";
    self.font_scale      = 0.95;
    self.option_limit    = 10;
    self.option_spacing  = 16;
    self.option_summary  = true;
    self.x_offset        = -110;
    self.y_offset        = 80;
    self.element_count   = 0;
    self.element_list    = cicada_util::list("text,submenu,toggle,category,slider");

    self.color[0] = (1, 1, 1); // when cursor is over a option, this is the color. this is white for now
    self.color[1] = (0.0, 0.0, 0.0);
    self.color[2] = (0.05, 0.0, 0.0);
    self.color[3] = (0.45, 0.455, 0.45); // idk
    self.color[4] = self.color[0]; // this is normal color for option whenever cursor isn't over it

    // main accent being used
    self.current_menu_color = (1.0, 0.0, 0.10);

    self.cursor   = [];
    self.previous = [];
    self set_menu("cicada");
    self set_title(self get_menu());
}

function structure()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";

    increments = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider (^5no jump^7)";
    sliders = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to select";
    credits = "made with ^1<3^7 by ^:nyli^7 & ^:mikey";

    switch (menu)
    {
        case "cicada":
            self add_menu("cicada ^5" + cicada_util::get_current_build());
            self add_option("mods & toggles", credits, &new_menu, "mods & toggles");
            self add_option("binds", credits, &new_menu, "bind settings");
            self add_option("position", credits, &new_menu, "position");
            self add_option("cinematics", credits, &new_menu, "cinematics");
            self add_option("aimbot", credits, &new_menu, "aimbot settings");
            self add_option("class", credits, &new_menu, "class manager");
            self add_option("game", credits, &new_menu, "game settings");
            self add_option("clients", credits, &new_menu, "manage clients");
            break;

        case "mods & toggles":
            self add_menu(menu);
            self add_option("glitches", undefined, &new_menu, "glitches");
            if (game_utility::getgametype() == "sd")
                self add_option("fast last", undefined, &cicada_mods::fast_last);
            self add_feature("invincibility", undefined, "invincible");
            self add_feature("unlimited lives", undefined, "unlimited_lives");
            self add_feature("ufo", "[{+gostand}] ^5+ ^7[{+melee}] to noclip", "ufo_mode");
            self add_dvar_toggle("instashoots", undefined, "pan_instashoots");
            self add_dvar_toggle("always canswap", undefined, "pan_alwayscanswap");
            self add_dvar_toggle("sprint swaps", undefined, "pan_sprintswaps");
            self add_dvar_toggle("freeze anim", undefined, "pan_freezeanim");
            self add_dvar_toggle("canzooms", undefined, "pan_canzooms");
            self add_dvar_toggle("always altswap", undefined, "pan_alwaysaltswap");
            self add_feature("always nac", "[{+weapnext}] to swap", "always_nac");
            self add_feature("elevators", "[{+speed_throw}] ^5+ ^7[{+stance}] on the ground", "elevators");
            self add_feature("instaswaps", "[{+frag}] to swap", "instaswaps");
            self add_feature("auto prone", undefined, "auto_prone");
            self add_feature("auto reload", undefined, "auto_reload");
            self add_feature("headbounces", undefined, "headbounces");
            self add_increment("instaswaps time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("instaswaps_time"), 0.05, 1, 0.05, "instaswaps_time");
            self add_array("auto prone mode", sliders, &cicada_mods::set_value, cicada_util::list("air,always"), self cicada_util::getpers("auto_prone_mode"), "auto_prone_mode");
            break;

        case "glitches":
            self add_menu(menu);
            self add_option("one handed gun", "shoot after the swap", &cicada_mods::one_handed_gun);
            self add_option("switch to equipment", "^:" + cicada_catalog::count("equipment") + " ^7equipment available", &new_menu, "switch to equipment");
            break;

        case "switch to equipment":
            self add_menu(menu);
            foreach (item in cicada_catalog::get("equipment"))
                self add_option(item.name, "^:" + item.id, &cicada_loadout::give_equipment, item.id);
            break;

        case "cinematics":
            self add_menu(menu);
            self add_option("start camera path", self cicada_cinematics::summary(), &cicada_cinematics::start_path);
            self add_option("stop camera path", self cicada_cinematics::summary(), &cicada_cinematics::stop_path);
            self add_array("set camera mode", sliders, &cicada_cinematics::set_mode, cicada_util::list("bezier,linear"), self cicada_cinematics::mode());
            if (self cicada_cinematics::mode() == "bezier")
                self add_increment("set bezier speed", increments, &cicada_mods::set_value, self cicada_util::getpersint("camera_bezier_speed"), 1, 20, 1, "camera_bezier_speed");
            else
                self add_increment("set linear time", increments, &cicada_mods::set_value, self cicada_util::getpersint("camera_linear_time"), 1, 20, 1, "camera_linear_time");
            self add_increment("set camera rotation", increments, &cicada_cinematics::set_rotation, self cicada_util::getpersint("camera_rotation"), 0, 360, 1);
            self add_option("save node", self cicada_cinematics::summary(), &cicada_cinematics::save_node);
            self add_option("delete last node", self cicada_cinematics::summary(), &cicada_cinematics::delete_last_node);
            self add_option("clone self", undefined, &cicada_cinematics::clone_self);
            self add_option(cicada_util::warn("clear all nodes"), self cicada_cinematics::summary(), &cicada_cinematics::clear_nodes);
            break;

        case "position":
            self add_menu(menu);
            self add_array("teleport bots", sliders, &cicada_mods::move_bots, cicada_util::list("crosshair,self"), "crosshair");
            self add_feature("freeze bots", undefined, "frozen_bots");
            self add_option("kill bots", undefined, &cicada_binds::kill_bots);
            self add_option("unstuck", undefined, &cicada_mods::unstuck);
            self add_feature("save and load binds", "crouch ^5+ ^7[{+actionslot 3}] ^5/ ^7[{+actionslot 2}]", "save_load_binds");
            self add_array("manage position", sliders, &cicada_mods::manage_position, cicada_util::list("save,load,reset"), "save");
            if (self cicada_mods::has_position())
                self position_options(increments);
            self add_option("bot paths", self cicada_movement::summary("path"), &new_menu, "bot paths");
            break;

        case "bot paths":
            self add_menu(menu);
            self add_option("start path movement", self cicada_movement::summary("path"), &cicada_movement::start_bot_path);
            self add_option("save point", self cicada_movement::summary("path"), &cicada_movement::save_point, "path");
            self add_option("delete last point", self cicada_movement::summary("path"), &cicada_movement::delete_point, "path");
            break;

        case "aimbot settings":
            self add_menu(menu);
            self add_feature("aimbot", "fires on snipers and marksman rifles", "aimbot");
            self add_increment("range", increments, &cicada_mods::set_value, self cicada_util::getpersint("aimbot_range"), 100, 5000, 100, "aimbot_range");
            self add_array("delay", sliders, &cicada_mods::set_value, cicada_util::list("0,0.1,0.2,0.3,0.4,0.5"), self cicada_util::getpers("aimbot_delay"), "aimbot_delay");
            self add_option("effect manager", undefined, &new_menu, "edit effects");
            break;

        case "edit effects":
            self add_menu(menu);
            self add_state("kill effects", "current: ^:" + self cicada_util::getpers("kill_effect"), "kill_effects");
            self add_array("kill effect", sliders, &cicada_mods::set_value, cicada_mods::effect_list(), self cicada_util::getpers("kill_effect"), "kill_effect");
            self add_option("randomize kill effect", "current: ^:" + self cicada_util::getpers("kill_effect"), &cicada_mods::randomize_effect, "kill_effect");
            self add_option("preview kill effect", "current: ^:" + self cicada_util::getpers("kill_effect"), &cicada_mods::preview_effect, self cicada_util::getpers("kill_effect"));
            self add_option("tracer effects", undefined, &new_menu, "edit tracers");
            break;

        case "edit tracers":
            self add_menu(menu);
            self add_feature("tracer rounds", "current: ^:" + self cicada_util::getpers("tracer_effect"), "tracers");
            self add_increment("effect count", increments, &cicada_mods::set_value, self cicada_util::getpersint("tracer_count"), 1, 10, 1, "tracer_count");
            self add_array("tracer effect", sliders, &cicada_mods::set_value, cicada_mods::effect_list(), self cicada_util::getpers("tracer_effect"), "tracer_effect");
            self add_option("randomize tracer effects", "current: ^:" + self cicada_util::getpers("tracer_effect"), &cicada_mods::randomize_effect, "tracer_effect");
            break;

        case "binds":
            self add_menu(menu);
            foreach (name in level.cicada_bind_names)
                self add_option(name, self bind_summary(name), &new_menu, name);
            break;

        case "bind settings":
            self add_menu(menu);
            self add_option("choose bind", "^:" + level.cicada_bind_names.size + " ^7actions available", &new_menu, "binds");
            self add_option("edit record movement", self cicada_movement::summary("record"), &new_menu, "record movement settings");
            self add_option("edit bolt movement", self cicada_movement::summary("bolt"), &new_menu, "bolt movement settings");
            self add_option("edit class change", undefined, &new_menu, "class change settings");
            self add_option("edit velocity", undefined, &new_menu, "edit velocity");
            self add_option("edit bot velocity", undefined, &new_menu, "edit bot velocity");
            self add_option("choose equipment", "^:" + self cicada_util::getpers("equipment_weapon"), &new_menu, "equipment bind");
            self add_array("stuck weapon", sliders, &cicada_mods::set_value, cicada_util::list("semtex_mp,molotov_mp,thermite_mp"), self cicada_util::getpers("stuck_weapon"), "stuck_weapon");
            self add_state("put away equipment", undefined, "equipment_putaway");
            if (istrue(self cicada_util::getpers("equipment_putaway")))
                self add_increment("put away time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("equipment_putaway_time"), 0.05, 5, 0.05, "equipment_putaway_time");
            self add_state("real scavenger", undefined, "real_scavenger");
            self add_state("repeater illusions", undefined, "repeater_illusion");
            self add_increment("spectator repeater time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("spectate_time"), 0.05, 2, 0.05, "spectate_time");
            self add_increment("damage amount", increments, &cicada_mods::set_value, self cicada_util::getpersint("damage_amount"), 10, 100, 10, "damage_amount");
            self add_increment("flash amount", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("flash_amount"), 0.25, 5, 0.25, "flash_amount");
            self add_increment("shellshock amount", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("shellshock_amount"), 0.05, 1, 0.05, "shellshock_amount");
            self add_array("shellshock type", sliders, &cicada_mods::set_value, cicada_util::list("frag_grenade_mp,flash_grenade_mp,concussion_grenade_mp,thermite_mp"), self cicada_util::getpers("shellshock_type"), "shellshock_type");
            break;

        case "equipment bind":
            self add_menu(menu);
            foreach (item in cicada_catalog::get("equipment"))
                self add_option(item.name, "^:" + item.id, &cicada_mods::set_value, item.id, "equipment_weapon");
            break;

        case "bolt movement settings":
            self add_menu(menu);
            self add_option("bot bolt movement", self cicada_movement::summary("bot_bolt"), &new_menu, "bot bolt movement settings");
            self add_increment("bolt speed", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bolt_speed"), 0.1, 10, 0.1, "bolt_speed");
            self add_option("save bolt", self cicada_movement::summary("bolt"), &cicada_movement::save_point, "bolt");
            self add_option("delete last bolt", self cicada_movement::summary("bolt"), &cicada_movement::delete_point, "bolt");
            self add_option("play bolt", self cicada_movement::summary("bolt"), &cicada_movement::play_bolt);
            break;

        case "bot bolt movement settings":
            self add_menu(menu);
            self add_increment("bot bolt speed", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bot_bolt_speed"), 0.1, 10, 0.1, "bot_bolt_speed");
            self add_option("save bot bolt", self cicada_movement::summary("bot_bolt"), &cicada_movement::save_point, "bot_bolt");
            self add_option("delete last bot bolt", self cicada_movement::summary("bot_bolt"), &cicada_movement::delete_point, "bot_bolt");
            self add_option("play bot bolt", self cicada_movement::summary("bot_bolt"), &cicada_movement::play_bot_bolt);
            break;

        case "record movement settings":
            self add_menu(menu);
            self add_option("record movement", self cicada_movement::summary("record"), &cicada_movement::record_movement);
            self add_option("delete last point", self cicada_movement::summary("record"), &cicada_movement::delete_point, "record");
            self add_option("reset points", self cicada_movement::summary("record"), &cicada_movement::clear_points, "record");
            self add_option("play movement", self cicada_movement::summary("record"), &cicada_movement::play_record);
            break;

        case "class change settings":
            self add_menu(menu);
            self add_increment("class wrap", increments, &cicada_mods::set_value, self cicada_util::getpersint("class_wrap"), 1, 10, 1, "class_wrap");
            self add_state("one bullet left", undefined, "class_one_bullet");
            self add_state("empty clip", undefined, "class_empty_clip");
            self add_state("illusion", undefined, "class_illusion");
            self add_state("canswap", undefined, "class_canswap");
            break;

        case "edit velocity":
            self add_menu(menu);
            self velocity_options("", increments);
            break;

        case "edit bot velocity":
            self add_menu(menu);
            self velocity_options("bot_", increments);
            break;

        case "class manager":
            self add_menu(menu);
            self add_feature("infinite equipment", undefined, "inf_equipment");
            self add_array("drop weapon", sliders, &cicada_mods::drop_weapon, cicada_util::list("current,secondary,all"), "current");
            self add_array("save & load class", sliders, &cicada_loadout::manage_class, cicada_util::list("save,load"), "save");
            self add_array("refill ammo", sliders, &cicada_mods::refill_ammo, cicada_util::list("all,current"), "all");
            self add_option("take weapon", "^:" + self getcurrentweapon().basename, &cicada_mods::take_weapon);
            self add_state("replace weapon", "replace current when giving weapon", "replace_weapon");
            self add_option("primaries", "^:" + level.cicada_groups["primaries"].size + " ^7categories", &new_menu, "primaries");
            self add_option("secondaries", "^:" + level.cicada_groups["secondaries"].size + " ^7categories", &new_menu, "secondaries");
            self add_option("streak manager", undefined, &new_menu, "streaks");
            self add_option("apply random camo", "currently set: ^:" + self cicada_loadout::camo(), &cicada_loadout::randomize_camo);
            self add_option("clear camo", "currently set: ^:" + self cicada_loadout::camo(), &cicada_loadout::clear_camo);
            break;

        case "primaries":
        case "secondaries":
            self add_menu(menu);
            foreach (category in level.cicada_groups[menu])
                self add_option(category, "^:" + cicada_catalog::count(category) + " ^7weapons available", &new_menu, category);
            break;

        case "streaks":
            self add_menu(menu);
            self add_option("give streak", "^:" + cicada_catalog::count("streaks") + " ^7streaks available", &new_menu, "give streaks");
            break;

        case "give streaks":
            self add_menu(menu);
            foreach (streak in cicada_catalog::get("streaks"))
                self add_option(streak.name, "^:" + streak.id, &cicada_loadout::give_streak, streak.id);
            break;

        case "game settings":
            self add_menu(menu);
            self add_option("dvars", undefined, &new_menu, "dvars");
            self add_option("killcam manager", undefined, &new_menu, "killcam manager");
            self add_feature("no hud", undefined, "no_hud");
            self add_feature("bounce pads", "^:" + self cicada_mods::bounce_count() + " ^7saved", "bounce_pads");
            self add_option("save bounce pad", "^:" + self cicada_mods::bounce_count() + " ^7saved", &cicada_mods::save_bounce);
            self add_option("delete last bounce pad", "^:" + self cicada_mods::bounce_count() + " ^7saved", &cicada_mods::delete_bounce);
            self add_option(cicada_util::warn("fast restart"), undefined, &cicada_mods::fast_restart);
            self add_state("messages", undefined, "messages");
            self add_state("sounds", "menu sounds etc", "sounds");
            self add_feature("out of bounds off", undefined, "no_oob");
            self add_feature("remove barriers", undefined, "no_barriers");
            if (game_utility::getgametype() == "sd")
                self add_option(cicada_util::warn("end round"), undefined, &cicada_mods::end_round);
            break;

        case "dvars":
            self add_menu(menu);
            self add_increment("timescale", increments, &cicada_mods::set_timescale, self cicada_util::getpersfloat("timescale"), 0.25, 5, 0.25);
            break;

        case "killcam manager":
            self add_menu(menu);
            self add_feature("allow hud edits", "allow editing killcam elems", "clean_killcam");
            self add_increment("killcam time", increments, &cicada_killcam::set_time, getdvarfloat("scr_killcam_time", 5), 5, 10, 1);
            self add_state("hide weapon & items", undefined, "hide_weapon");
            self add_state("hide victim", undefined, "hide_victim");
            self add_state("hide perks", undefined, "hide_perks");
            self add_state("hide attachments", undefined, "hide_attachments");
            self add_state("hide equipment", undefined, "hide_equipment");
            self add_state("hide field upgrade", undefined, "hide_field_upgrade");
            break;

        case "manage clients":
            self add_menu(menu);
            foreach (player in level.players)
                self add_option(player cicada_util::player_name(), cicada_util::is_bot(player) ? "^:bot" : "^:player", &new_menu, "player option");
            break;

        case "player option":
            self player_options(self.select_player, sliders);
            break;

        default:
            if (isdefined(level.cicada_catalog[menu]))
            {
                self add_menu(menu);
                foreach (weapon in cicada_catalog::get(menu))
                    self add_option(weapon.name, "^:" + weapon.id, &cicada_loadout::give_weapon, weapon.id);
            }
            else if (isdefined(level.cicada_binds[menu]))
            {
                self add_menu(menu);
                self add_bind_slots(menu);
            }
            else
            {
                self add_menu("error");
                self add_option("unable to load " + menu);
            }
            break;
    }
}

function bind_summary(name)
{
    for (slot = 1; slot <= 4; slot++)
        if (self cicada_binds::has_bind(name, slot))
            return "bound to ^:actionslot " + slot;

    return "not bound";
}

function add_bind_slots(name)
{
    for (slot = 1; slot <= 4; slot++)
        self add_toggle("actionslot " + slot, "run ^:" + name + " ^7on release", self cicada_binds::has_bind(name, slot), &cicada_binds::assign, name, slot);
}

function position_options(increments)
{
    origin = self cicada_util::getpers("position");
    step = self cicada_util::getpersfloat("position_step");

    self add_increment("change x", increments, &cicada_mods::nudge_position, origin[0], -100000, 100000, step, "x");
    self add_increment("change y", increments, &cicada_mods::nudge_position, origin[1], -100000, 100000, step, "y");
    self add_increment("change z", increments, &cicada_mods::nudge_position, origin[2], -100000, 100000, step, "z");
    self add_increment("change by", increments, &cicada_mods::set_value, step, 1, 500, 1, "position_step");
}

function velocity_options(prefix, increments)
{
    step = self cicada_util::getpersfloat(prefix + "velocity_step");
    summary = "x: ^5" + self cicada_util::getpersfloat(prefix + "velocity_x") + " ^7y: ^5" + self cicada_util::getpersfloat(prefix + "velocity_y") + " ^7z: ^5" + self cicada_util::getpersfloat(prefix + "velocity_z");

    self add_increment("change x", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(prefix + "velocity_x"), -2000, 2000, step, prefix + "velocity_x");
    self add_increment("change y", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(prefix + "velocity_y"), -2000, 2000, step, prefix + "velocity_y");
    self add_increment("change z", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(prefix + "velocity_z"), -2000, 2000, step, prefix + "velocity_z");
    self add_increment("change by", increments, &cicada_mods::set_value, step, 5, 500, 5, prefix + "velocity_step");
    self add_option("randomize values", summary, &cicada_mods::randomize_velocity, prefix);
    self add_option("track & save", summary, &cicada_mods::track_velocity, prefix);
    self add_option("play velocity", summary, prefix == "" ? &cicada_mods::play_velocity : &cicada_mods::play_bot_velocity);
}

function player_options(player, sliders)
{
    if (!isdefined(player) || !isplayer(player))
    {
        self add_menu("error");
        self add_option("no client selected");
        return;
    }

    self add_menu(player cicada_util::player_name());
    self add_option("kill", undefined, &cicada_mods::kill_player, player);
    self add_option("respawn", undefined, &cicada_mods::respawn_player, player);
    self add_option("change team", undefined, &cicada_mods::change_team, player);
    self add_toggle("freeze controls", undefined, cicada_mods::is_frozen(player), &cicada_mods::toggle_freeze, player);
    self add_array("teleport", sliders, &cicada_mods::manage_teleport, cicada_util::list("crosshair,me,them"), "crosshair", player);

    if (!cicada_util::is_bot(player))
        return;

    self add_option("look at me", undefined, &cicada_mods::look_at_me, player);
    self add_option("give my weapon", "^:" + self getcurrentweapon().basename, &cicada_mods::give_bot_weapon, player, self getcurrentweapon());
    self add_option("give shield", undefined, &cicada_loadout::give_bot_shield, player);
    self add_option("apply random camo", "currently set: ^:" + player cicada_loadout::camo(), &cicada_loadout::randomize_camo, player);
}

function get_cursor()
{
    return self.cursor[self get_menu()];
}

function set_cursor(cursor)
{
    if (isdefined(cursor))
        self.cursor[self get_menu()] = cursor;
}

function get_menu()
{
    return self.menu["menu"];
}

function set_menu(menu)
{
    //if (isdefined(menu))
    self.menu["menu"] = menu;
}

function set_title(title)
{
    if (isdefined(title))
        self.menu["title"] = title;
}

function get_title()
{
    return self.menu["title"];
}

function set_procedure()
{
    self.in_menu = !istrue(self.in_menu);
}

function add_option(text, summary, func, argument_1, argument_2, argument_3, argument_4, argument_5)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = func;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;
    option["argument_4"] = argument_4;
    option["argument_5"] = argument_5;
    self.structure[self.structure.size] = option;
}

function add_toggle(text, summary, state, func, argument_1, argument_2)
{
    option               = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = func;
    option["toggle"]     = istrue(state);
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;

    self.structure[self.structure.size] = option;
}

function add_dvar_toggle(text, summary, dvar)
{
    self add_toggle(text, summary, getdvarint(dvar), &cicada_mods::toggle_dvar, dvar);
}

function add_feature(text, summary, key)
{
    self add_toggle(text, summary, self cicada_util::getpers(key), &cicada_mods::toggle, key);
}

function add_state(text, summary, key)
{
    self add_toggle(text, summary, self cicada_util::getpers(key), &cicada_util::flippers, key);
}

function add_increment(text, summary, func, start, minimum, maximum, step, argument_1, argument_2)
{
    option                 = [];
    option["text"]         = text;
    option["summary"]      = summary;
    option["function"]     = func;
    option["slider"]       = true;
    option["is_increment"] = true;
    option["start"]        = start;
    option["minimum"]      = minimum;
    option["maximum"]      = maximum;
    option["increment"]    = step;
    option["argument_1"]   = argument_1;
    option["argument_2"]   = argument_2;

    self.structure[self.structure.size] = option;
}

function add_array(text, summary, func, array, current, argument_1, argument_2)
{
    option               = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = func;
    option["slider"]     = true;
    option["is_array"]   = true;
    option["array"]      = array;
    option["start"]      = index_of(array, current);
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;

    self.structure[self.structure.size] = option;
}

function index_of(array, value)
{
    for (i = 0; i < array.size; i++)
        if (array[i] == value)
            return i;

    return 0;
}

function print_controls()
{
    self iprintln("^:cicada ^7- hold [{+speed_throw}] ^7then press [{+actionslot 1}] ^7to open");
    self iprintln("^7navigate [{+actionslot 1}] [{+actionslot 2}] ^7- slider [{+actionslot 3}] [{+actionslot 4}]");
    self iprintln("^7select [{+gostand}] ^7- back [{+activate}] ^7- close [{+melee_zoom}]");
}

function initial_monitor()
{
    self endon("disconnect");
    level endon("game_ended");

    //self thread [[ &monitor_menu_close ]]();

    for (;;)
    {
        if (isalive(self))
        {
            if (!self cicada_util::in_menu())
            {
                if (self adsbuttonpressed() && self cicada_util::isbuttonpressed("-actionslot 1"))
                {
                    self open_menu();
                    wait 0.15;
                }
            }
            else
            {
                menu   = self get_menu();
                cursor = self get_cursor();

                // force close if melee pressed
                if (self cicada_util::isbuttonpressed("+melee_zoom"))
                {
                    //self thread [[ &play_sound ]]("recondrone_tag");
                    self close_menu();
                }
                else if (self usebuttonpressed()) // back
                {
                    // self sfx("zmb_powerup_activate");

                    if (isdefined(self.previous[(self.previous.size - 1)]))
                    {
                        self new_menu(self.previous[menu]);
                    }
                    else
                    {
                        //self thread [[ &play_sound ]]("deadsilence_end");
                        self close_menu();
                    }

                    wait 0.15;
                }
                else if (self cicada_util::isbuttonpressed("-actionslot 2") && !self cicada_util::isbuttonpressed("-actionslot 1") || self cicada_util::isbuttonpressed("-actionslot 1") && !self cicada_util::isbuttonpressed("-actionslot 2")) // up & down
                {
                    if (isdefined(self.structure) && self.structure.size >= 2)
                    {
                        // self thread [[ &play_sound ]]("attachment_pickup");
                        scrolling = self cicada_util::isbuttonpressed("-actionslot 2") ? 1 : -1;
                        self set_cursor((cursor + scrolling));

                        res = self update_scrolling(scrolling);
                        while (!res)
                        {
                            res = self update_scrolling(scrolling);
                        }
                    }
                    wait 0.07;
                }
                else if (self cicada_util::isbuttonpressed("-actionslot 4") && !self cicada_util::isbuttonpressed("-actionslot 3") || self cicada_util::isbuttonpressed("-actionslot 3") && !self cicada_util::isbuttonpressed("-actionslot 4"))
                {
                    if (istrue(self.structure[cursor]["slider"]))
                    {
                        //self thread [[ &play_sound ]]("scavenger_pack_pickup");
                        scrolling = self cicada_util::isbuttonpressed("-actionslot 3") ? 1 : -1;
                        self set_slider(scrolling);

                        if (istrue(self.structure[cursor]["is_increment"]))
                        {
                            self thread [[&execute_function]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            //self thread [[ &play_sound ]]("ui_mp_weapon_pickup");
                            self update_menu(menu, cursor);
                        }
                    }
                    wait 0.07;
                }
                else if (self cicada_util::isbuttonpressed("+gostand"))
                {
                    if (isdefined(self.structure[cursor]["function"]))
                    {
                        if (istrue(self.structure[cursor]["slider"]))
                        {
                            if (istrue(self.structure[cursor]["is_array"]))
                            {
                                self thread [[&execute_function]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                                //self thread [[ &play_sound ]]("recondrone_tag");
                            }
                            else
                            {
                                self iprintlnbold("use the ^2slider controls^7, not the jump button!");
                                //self thread [[ &play_sound ]]("ammo_crate_use");
                            }
                        }
                        else
                            self thread [[&execute_function]](self.structure[cursor]["function"], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"], self.structure[cursor]["argument_4"], self.structure[cursor]["argument_5"]);

                        // self update_menu(menu, cursor);
                        // only update the menu visually if not a array (?)

                        cursor_struct = self.structure[cursor];
                        if (isdefined(cursor_struct))
                        {
                            if (isdefined(cursor_struct["toggle"]) || !istrue(cursor_struct["is_array"]))
                            {
                                self update_menu(menu, cursor);
                            }
                        }
                    }
                    wait 0.18;
                }
            }
        }

        wait 0.05;
    }
}

function set_slider(scrolling, index)
{
    menu    = self get_menu();
    index   = isdefined(index) ? index : self get_cursor();
    storage = (menu + "_" + index);

    if (isdefined(self.structure[index]["array"]))
    {
        self notify("slider_array");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage]++;
            if (scrolling == 1)
                self.slider[storage]--;
        }

        if (self.slider[storage] > (self.structure[index]["array"].size - 1))
            self.slider[storage] = 0;

        if (self.slider[storage] < 0)
            self.slider[storage] = (self.structure[index]["array"].size - 1);

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_ADDITIONAL_" + self.structure[index]["array"][self.slider[storage]]);
        }
    }
    else
    {
        self notify("slider_increment");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage] += self.structure[index]["increment"];
            if (scrolling == 1)
                self.slider[storage] -= self.structure[index]["increment"];
        }

        if (self.slider[storage] > self.structure[index]["maximum"])
            self.slider[storage] = self.structure[index]["minimum"];

        if (self.slider[storage] < self.structure[index]["minimum"])
            self.slider[storage] = self.structure[index]["maximum"];

        position = abs((self.structure[index]["maximum"] - self.structure[index]["minimum"])) / ((50 - 8));
        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            // TODO: sliders
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_STR12_" + slider_value);
        }

        self.menu["hud"]["slider"][2][index].x = (self.menu["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index]["minimum"])) / position) - 42);
    }
}

function clear_option()
{
    for (i = 0; i < self.element_list.size; i++)
    {
        clear_all(self.menu["hud"][self.element_list[i]]);
        self.menu["hud"][self.element_list[i]] = [];
    }
}

function clear_all(array)
{
    if (!isdefined(array))
        return;

    keys = getarraykeys(array);
    for (i = 0; i < keys.size; i++)
    {
        if (isarray(array[keys[i]]))
        {
            foreach (key in array[keys[i]])
                if (isdefined(key))
                    key destroy_element();
        }
        else if (isdefined(array[keys[i]]))
            array[keys[i]] destroy_element();
    }
}

function close_menu()
{
    self set_procedure();
    self clear_option();
    self clear_all(self.menu["hud"]);

    //is_prematch_done = game["flags"]["prematch_done"];
    //if (is_prematch_done)
    //    setslowmotion_wrapper(self custom_scripts\_util::getpers("slow_motion"), self custom_scripts\_util::getpers("slow_motion"), 0);

    self notify("exit_menu");
}

function update_scrolling(scrolling)
{
    cursor_index = self get_cursor();
    structure = self.structure[cursor_index];

    if (isdefined(structure) && istrue(structure["category"]))
    {
        self set_cursor((self get_cursor() + scrolling));
        return false;
    }

    if ((self.structure.size > self.option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0))
    {
        if ((self get_cursor() >= self.structure.size) || (self get_cursor() < 0))
            self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));

        self create_option();
    }

    self update_resize();

    return true;
}

function update_resize()
{
    limit    = min(self.structure.size, self.option_limit);
    height   = int((limit * self.option_spacing));
    adjust   = (self.structure.size > self.option_limit) ? int(((112 / self.structure.size) * limit)) : height;

    if ((height - adjust) > 0)
        position = (self.structure.size - 1) / (height - adjust);
    else
        position = 0;

    if (istrue(self.shader_option[self get_menu()]))
    {
        self.menu["hud"]["foreground"][1].y = (self.y_offset + 46);
        self.menu["hud"]["foreground"][1].x = (self.menu["hud"]["text"][self get_cursor()].x - 10);

        if (!isdefined(self.menu["hud"]["arrow"][0]))
            self.menu["hud"]["arrow"][0] = self create_shader("ui_scrollbar_arrow_left", "TOP_LEFT", "TOPCENTER", (self.x_offset + 10), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        if (!isdefined(self.menu["hud"]["arrow"][1]))
            self.menu["hud"]["arrow"][1] = self create_shader("ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 211), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        self.menu["hud"]["foreground"][2] destroy_element();
    }
    else
    {
        self.menu["hud"]["foreground"][1].y = (self.menu["hud"]["text"][self get_cursor()].y - 3);
        self.menu["hud"]["foreground"][1].x = (self.x_offset + 1);

        if (!isdefined(self.menu["hud"]["foreground"][2]))
            self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.6, 4);

        if (isdefined(self.menu["hud"]["arrow"][0])) self.menu["hud"]["arrow"][0] destroy_element();
        if (isdefined(self.menu["hud"]["arrow"][1])) self.menu["hud"]["arrow"][1] destroy_element();
    }

    self.menu["hud"]["background"][0] set_shader(self.menu["hud"]["background"][0].shader, self.menu["hud"]["background"][0].width, istrue(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? 66 : 50) : (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? (height + 34) : (height + 18)));
    self.menu["hud"]["background"][1] set_shader(self.menu["hud"]["background"][1].shader, self.menu["hud"]["background"][1].width, istrue(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? 64 : 48) : (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? (height + 32) : (height + 16)));
    self.menu["hud"]["foreground"][0] set_shader(self.menu["hud"]["foreground"][0].shader, self.menu["hud"]["foreground"][0].width, istrue(self.shader_option[self get_menu()]) ? 32 : height);
    self.menu["hud"]["foreground"][1] set_shader(self.menu["hud"]["foreground"][1].shader, istrue(self.shader_option[self get_menu()]) ? 20 : 214, istrue(self.shader_option[self get_menu()]) ? 2 : 16);
    self.menu["hud"]["foreground"][2] set_shader(self.menu["hud"]["foreground"][2].shader, self.menu["hud"]["foreground"][2].width, adjust);

    if (isdefined(self.menu["hud"]["foreground"][2]))
    {
        self.menu["hud"]["foreground"][2].y = (self.y_offset + 16);
        if (self.structure.size > self.option_limit)
            self.menu["hud"]["foreground"][2].y += (self get_cursor() / position);
    }

    if (isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"].y = istrue(self.shader_option[self get_menu()]) ? (self.y_offset + 51) : (self.y_offset + ((limit * self.option_spacing) + 19));
}

function new_menu(menu)
{
    if (self get_menu() == "manage clients")
        self.select_player = level.players[self get_cursor()];

    if (!isdefined(menu))
    {
        menu = self.previous[(self.previous.size - 1)];
        self.previous[(self.previous.size - 1)] = undefined;
    }
    else
        self.previous[self.previous.size] = self get_menu();

    self set_menu(menu);
    self clear_option();
    self create_option();
}

function open_menu(menu)
{
    if (!isdefined(menu))
        menu = isdefined(self get_menu()) && self get_menu() != "cicada" ? self get_menu() : "cicada";

    // setup menu hud arrays
    if (!isdefined(self.menu["hud"]))
    {
        self.menu["hud"] = [];
        self.menu["hud"]["background"] = [];
        self.menu["hud"]["foreground"] = [];
        self.menu["hud"]["submenu"] = [];
        self.menu["hud"]["toggle"] = [];
        self.menu["hud"]["slider"] = [];
        self.menu["hud"]["category"] = [];
        // category indexes need init too tbh but wtv for now
        self.menu["hud"]["text"] = [];
        self.menu["hud"]["arrow"] = [];
    }

    if (!isdefined(self.slider))
        self.slider = [];

    self.menu["hud"]["title"]        = self create_text("MP/NEURA_TITLE_" + self get_title(), "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 1.75), self.color[4], 1, 10);
    // outline
    self.menu["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), 222, 34, self.current_menu_color, 0.6, 1);
    // top bar
    self.menu["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, 220, 32, self.color[1], 0.8, 2);
    // toggle box
    self.menu["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 220, 16, self.color[1], 0.05, 3);
    // cursor - use these for flickershaders?
    self.menu["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 214, 16, self.current_menu_color, 0.6, 4);
    // scrolling bar on the side
    //self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.4, 4);

    self set_menu(menu);
    self set_procedure();
    self create_option();

    //self thread [[ &flicker_shaders ]]();

    //is_prematch_done = game["flags"]["prematch_done"];
    //if (is_prematch_done)
    //    setslowmotion_wrapper(1, 1, 0);
}

function destroy_element()
{
    if (!isdefined(self))
        return;

    self destroy();
    if (isdefined(self.player))
        self.player.element_count--;
}

function set_text(text)
{
    if (!isdefined(self) || !isdefined(text))
        return;

    self.text = text;
    self settext(text);
}

function create_text(text, override, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sort)
{
    element                = self hud_util::createfontstring(font, font_scale);
    if (isdefined(element))
    {
        element.color          = color;
        element.alpha          = alpha;
        element.sort           = sort;
        element.player         = self;
        element.archived       = false; // should_archive

        element.foreground     = true;
        element.hidewheninmenu = false;
        element.showinkillcam = 0;

        element hud_util::setpoint(alignment, relative, x_offset, y_offset);
        element set_text(text);

        self.element_count++;
    }

    return element;
}

function create_shader(shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sort)
{
    element                = newclienthudelem(self);
    element.elemtype       = "icon";
    element.children       = [];
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = false; //self should_archive();
    element.foreground     = true;
    element.hidden         = false;
    element.hidewheninmenu = true;

    element hud_util::setparent(level.uiparent);
    element hud_util::setpoint(alignment, relative, x_offset, y_offset);
    element set_shader(shader, width, height);

    self.element_count++;

    return element;
}

function update_menu(menu, cursor, force)
{
    if (isdefined(menu) && !isdefined(cursor) || !isdefined(menu) && isdefined(cursor))
        return;

    if (isdefined(menu) && isdefined(cursor))
    {
        foreach (player in level.players)
        {
            if (!isdefined(player) || !player cicada_util::in_menu())
                continue;

            if (player get_menu() == menu || self != player && player is_option(menu, cursor, self))
                if (isdefined(player.menu["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isdefined(player.menu["hud"]["text"][cursor]) || self != player && player is_option(menu, cursor, self) || istrue(force))
                    player create_option();
        }
    }
    else
    {
        if (isdefined(self) && self cicada_util::in_menu())
            self create_option();
    }
}

function is_option(menu, cursor, player)
{
    if (isdefined(self.structure) && self.structure.size)
        for (i = 0; i < self.structure.size; i++)
            if (player.structure[cursor]["text"] == self.structure[i]["text"] && self get_menu() == menu)
                return true;

    return false;
}

function add_menu(title, shader)
{
    if (isdefined(title))
        self set_title(title);

    if (!isdefined(self.shader_option)) // shader_option needs to be defined before you try to add stuff to it
        self.shader_option = [];

    if (isdefined(shader))
        self.shader_option[self get_menu()] = true;

    self.structure = [];
}

function execute_function(func, argument_1, argument_2, argument_3, argument_4, argument_5)
{
    if (!isdefined(func))
        return;

    if (isdefined(argument_5))
        return self thread [[func]](argument_1, argument_2, argument_3, argument_4, argument_5);

    if (isdefined(argument_4))
        return self thread [[func]](argument_1, argument_2, argument_3, argument_4);

    if (isdefined(argument_3))
        return self thread [[func]](argument_1, argument_2, argument_3);

    if (isdefined(argument_2))
        return self thread [[func]](argument_1, argument_2);

    if (isdefined(argument_1))
        return self thread [[func]](argument_1);

    return self thread [[func]]();
}

function set_shader(shader, width, height)
{
    self.shader = shader;
    self.width  = width;
    self.height = height;
    self setshader(shader, width, height);
}

function override_string_for_index(index)
{
    switch (index)
    {
        case 1:
            return "MP_INGAME_ONLY/HOLD_TO_START_GAME";
        case 2:
            return "MP_INGAME_ONLY/HQ_NEXT_IN";
        case 3:
            return "MP_INGAME_ONLY/HQ_NO_RESPAWN";
        case 4:
            return "MP_INGAME_ONLY/HQ_REINFORCEMENTS_IN";
        case 5:
            return "MP_INGAME_ONLY/HQ_TIME_REMAINING";
        case 6:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_1";
        case 7:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_10";
        case 8:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_11";
        case 9:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_12";
        case 10:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_13";
        case 11:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_14";
        case 12:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_15";
        case 13:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_16";
        case 14:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_17";
        default:
            return undefined;
    }
}

function sym()
{
    symbols = ["ߕ"]; // array for rn
    symbol = symbols[randomint(symbols.size)];
    return symbol + " ";
}

function create_title(title)
{
    title_ = isdefined(title) ? title : self get_title();
    self.menu["hud"]["title"] set_text("MP/NEURA_TITLE_" + sym() + title_);
}

function create_summary(summary)
{
    if (isdefined(self.menu["hud"]["summary"]) && !istrue(self.option_summary) || !isdefined(self.structure[self get_cursor()]["summary"]) && isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"] destroy_element();

    if (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary))
    {
        summary_ = tolower(isdefined(summary) ? summary : self.structure[self get_cursor()]["summary"]);
        lol_ = "MP/NEURA_INFO_" + "ߵ " + summary_;
        if (!isdefined(self.menu["hud"]["summary"]))
            self.menu["hud"]["summary"] = self create_text(lol_, "MP_INGAME_ONLY/HQ_AVAILABLE_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 35), self.color[4], 1, 10);
        else
            self.menu["hud"]["summary"] set_text(lol_);
    }
}

function create_option()
{
    self clear_option();
    structure();

    if (!isdefined(self.structure) || !self.structure.size)
        self add_option("nothing to display..");

    if (!isdefined(self get_cursor()))
        self set_cursor(0);

    start = 0;
    if ((self get_cursor() > int(((self.option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.option_limit + 1) / 2)))) && (self.structure.size > self.option_limit))
        start = (self get_cursor() - int((self.option_limit - 1) / 2));

    if ((self get_cursor() > (self.structure.size - (int(((self.option_limit + 1) / 2)) + 1))) && (self.structure.size > self.option_limit))
        start = (self.structure.size - self.option_limit);

    self create_title();
    if (istrue(self.option_summary))
        self create_summary();

    if (isdefined(self.structure) && self.structure.size)
    {
        limit = min(self.structure.size, self.option_limit);
        for (i = 0; i < limit; i++)
        {
            index      = (i + start);
            cursor     = (self get_cursor() == index);
            color[0] = cursor ? self.color[0] : self.color[4];
            color[1] = istrue(self.structure[index]["toggle"]) ? cursor ? self.color[0] : (1, 1, 1) : cursor ? self.color[2] : self.color[1];

            // new menu text
            if (isdefined(self.structure[index]["function"]) && self.structure[index]["function"] == &new_menu)
                self.menu["hud"]["submenu"][index] = self create_text("MP/NEURA_STR14_>", "MP_INGAME_ONLY/OBJ_HVT_CAPS_17", self.font, 0.65, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), color[0], 1, 10);
            if (isdefined(self.structure[index]["toggle"]))
            {
                self.menu["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 204), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, color[1],.65, 10);
                // self.menu["hud"]["current_toggle_index"] = self.menu["hud"]["toggle"][index];
            }

            if (istrue(self.structure[index]["slider"]))
            {
                storage = (self get_menu() + "_" + index);
                self.slider[storage] = self.structure[index]["start"];

                if (isdefined(self.structure[index]["array"]))
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.structure[index]["array"][self.slider[storage]], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 210), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                    }
                }
                else
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.slider[storage], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, (self.font_scale), "CENTER", "TOPCENTER", (self.x_offset + 187), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[4], 1, 10);
                    }

                    self.menu["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), 50, 8, cursor ? self.color[2] : self.color[1], 1, 8);
                    self.menu["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 170), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, cursor ? self.color[0] : self.color[3], 1, 9);
                }

                // idek what this does but Ok
                self set_slider(undefined, index);
            }

            if (istrue(self.structure[index]["category"]))
            {
                og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                override_string = override_string_for_index(i + 1);

                self.menu["hud"]["category"][0][index] = self create_text(og_string, override_string, self.font, self.font_scale, "CENTER", "TOPCENTER", (self.x_offset + 102), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[0], 1, 10);
                self.menu["hud"]["category"][1][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
                self.menu["hud"]["category"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
            }
            else
            {
                menu = self get_menu();
                shader_option = self.shader_option[menu];
                if (istrue(shader_option))
                {
                    shader = isdefined(self.structure[index]["text"]) ? self.structure[index]["text"] : "white";
                    color  = isdefined(self.structure[index]["argument_1"]) ? self.structure[index]["argument_1"] : (1, 1, 1); // come back
                    width  = isdefined(self.structure[index]["argument_2"]) ? self.structure[index]["argument_2"] : 20;
                    height = isdefined(self.structure[index]["argument_3"]) ? self.structure[index]["argument_3"] : 20;
                    self.menu["hud"]["text"][index] = self create_shader(shader, "CENTER", "TOPCENTER", (self.x_offset + ((i * 24) - ((limit * 10) - 109))), (self.y_offset + 32), width, height, color, 1, 10);
                }
                else
                {
                    menu_text = (istrue(self.structure[index]["slider"]) ? self.structure[index]["text"]/*+":"*/ : self.structure[index]["text"]);
                    if (self get_menu() != "manage clients")
                        menu_text = tolower(menu_text);

                    og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                    override_string = override_string_for_index(i + 1);

                    self.menu["hud"]["text"][index] = self create_text(og_string, override_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isdefined(self.structure[index]["toggle"]) ? (self.x_offset + 4) : (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                }
            }
        }

        if (!isdefined(self.menu["hud"]["text"][self get_cursor()]))
            self set_cursor((self.structure.size - 1));
    }

    self update_resize();
}

function close_menu_on_death()
{
    self endon("disconnect");
    level endon("game_ended");

    self waittill("death");

    if (self cicada_util::in_menu())
        self close_menu();
}
