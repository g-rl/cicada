#using scripts\cp_mp\utility\game_utility;
#using scripts\mp\hud_util;

#using custom_scripts\afterhits;
#using custom_scripts\binds;
#using custom_scripts\builds;
#using custom_scripts\catalog;
#using custom_scripts\cinematics;
#using custom_scripts\killcam;
#using custom_scripts\extras;
#using custom_scripts\leftovers;
//#using custom_scripts\link;
#using custom_scripts\stations;
#using custom_scripts\loadout;
#using custom_scripts\mechanics;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\props;
#using custom_scripts\pve;
#using custom_scripts\session;
#using custom_scripts\util;

#namespace cicada_menu;

function initial_variable()
{
    // menu variables
    self.element_count   = 0;
    self.element_list    = cicada_util::list("text,submenu,toggle,category,slider");

    self.color[2] = (0.05, 0.0, 0.0);
    self.color[3] = (0.45, 0.455, 0.45); // idk

    self load_layout();

    self.cursor   = [];
    self.previous = [];
    self set_menu("cicada");
    self set_title(self get_menu());
}

function color_names()
{
    return cicada_util::list("red,pink,purple,blue,cyan,green,lime,yellow,orange,white,grey,black");
}

function accent()
{
    switch (self cicada_util::getpers("menu_accent"))
    {
        case "green":
        case "lime":
            return "^2";

        case "yellow":
        case "orange":
            return "^3";

        case "blue":
            return "^4";

        case "cyan":
            return "^5";

        case "pink":
        case "purple":
            return "^6";

        case "white":
        case "grey":
            return "^7";

        case "black":
            return "^0";
    }

    return "^1";
}

function color_value(name)
{
    switch (name)
    {
        case "pink":   return (1.0, 0.25, 0.55);
        case "purple": return (0.55, 0.2, 0.9);
        case "blue":   return (0.15, 0.35, 1.0);
        case "cyan":   return (0.0, 0.8, 0.95);
        case "green":  return (0.1, 0.7, 0.25);
        case "lime":   return (0.55, 0.95, 0.2);
        case "yellow": return (1.0, 0.85, 0.1);
        case "orange": return (1.0, 0.5, 0.05);
        case "white":  return (1, 1, 1);
        case "grey":   return (0.45, 0.455, 0.45);
        case "black":  return (0.0, 0.0, 0.0);
        default:       return (1.0, 0.0, 0.10); // red
    }
}

function layout_value(key, fallback, minimum, maximum)
{
    stored = self cicada_util::getpers(key);

    if (!isdefined(stored) || !isnumber(stored) && !isstring(stored))
        return fallback;

    value = float(stored);

    if (value < minimum || value > maximum)
        return fallback;

    return value;
}

function load_layout()
{
    font = self cicada_util::getpers("menu_font");

    self.font           = (isdefined(font) && isstring(font) && font != "") ? font : "default";
    self.font_scale     = self layout_value("menu_scale", 0.95, 0.5, 1.5);
    self.option_limit   = int(self layout_value("menu_limit", 7, 4, 7));
    self.option_spacing = int(self layout_value("menu_spacing", 16, 10, 30));
    self.option_summary = istrue(self cicada_util::getpers("menu_summary"));
    self.x_offset       = int(self layout_value("menu_x", -110, -300, 300));
    self.y_offset       = int(self layout_value("menu_y", 80, -200, 300));

    self.color[0] = color_value(self cicada_util::getpers("menu_text"));
    self.color[1] = color_value(self cicada_util::getpers("menu_background"));
    self.color[4] = self.color[0];

    self.current_menu_color = color_value(self cicada_util::getpers("menu_accent"));
}

function rebuild_menu()
{
    if (!self cicada_util::in_menu())
        return;

    self clear_option();
    self clear_all(self.menu["hud"]);
    self.menu["hud"] = undefined;

    self create_hud();
    self create_option();
}

function set_layout(value, key)
{
    self cicada_util::setpers(key, value);
    self load_layout();
    self rebuild_menu();
}

function flip_layout(key)
{
    self cicada_util::flippers(key);
    self load_layout();
    self rebuild_menu();
}

function reset_layout()
{
    self cicada_util::setpers("menu_x", -110);
    self cicada_util::setpers("menu_y", 80);
    self cicada_util::setpers("menu_spacing", 16);
    self cicada_util::setpers("menu_limit", 7);
    self cicada_util::setpers("menu_scale", 0.95);
    self cicada_util::setpers("menu_font", "default");
    self cicada_util::setpers("menu_accent", "red");
    self cicada_util::setpers("menu_text", "white");
    self cicada_util::setpers("menu_background", "black");
    self cicada_util::setpers("menu_summary", true);
    self cicada_util::setpers("menu_version", true);

    self load_layout();
    self rebuild_menu();
    self cicada_util::message("menu settings ^1reset");
}

function structure()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";

    increments = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider (^5no jump^7)";
    sliders = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to select";
    live_sliders = live_slider_hint();
    credits = "made with ^1<3^7 by ^:nyli^7 & ^:mikey";
    gametype = scripts\mp\utility\game::getgametype();

    switch (menu)
    {
        case "cicada":
            self.bind_index = false;
            self add_menu(istrue(self cicada_util::getpers("menu_version")) ? ("cicada ^5" + cicada_util::get_current_build()) : "cicada");
            self add_option("mods & toggles", credits, &new_menu, "mods & toggles");
            self add_option("binds", credits, &new_menu, "bind settings");
            self add_option("position", credits, &new_menu, "position");
            self add_option("cinematics", credits, &new_menu, "cinematics");
            self add_option("aimbot", credits, &new_menu, "aimbot settings");
            self add_option("class", credits, &new_menu, "class manager");
            self add_option("game", credits, &new_menu, "game manager");
            self add_option("session", credits, &new_menu, "session manager");
            self add_option("bots", credits, &new_menu, "bot manager");
            self add_option("killcam", undefined, &new_menu, "killcam manager");
            self add_option("zombies & actors", credits, &new_menu, "zombies & actors");
            self add_option("models", credits, &new_menu, "model manager");
            self add_option("effects", credits, &new_menu, "effect manager");
            self add_option("customization", credits, &new_menu, "menu manager");
            self add_option("clients", credits, &new_menu, "manage clients");
            break;

        case "mods & toggles":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("glitches", undefined, &new_menu, "glitches");
            self add_option("afterhits", self cicada_afterhits::summary(), &new_menu, "afterhits");
            self add_option("parachute", self cicada_mechanics::summary(), &new_menu, "parachute settings");
            self add_option("movement rules", self cicada_mechanics::move_summary(), &new_menu, "movement rules");
            self add_option("leftovers", "warzone and zombies bits", &new_menu, "leftovers");
            self add_option("visions", undefined, &new_menu, "visions");
            if (gametype == "dm")
                self add_option("fast last", undefined, &cicada_mods::fast_last);
            self add_feature("invincibility", undefined, "invincible");
            self add_feature("unlimited lives", undefined, "unlimited_lives");
            self add_feature("ufo", "[{+gostand}] ^5+ ^7[{+melee}] to noclip", "ufo_mode");

            // engine toggles
            self add_dvar_toggle("instashoots", undefined, "pan_instashoots");
            self add_dvar_toggle("always canswap", undefined, "pan_alwayscanswap");
            self add_dvar_toggle("sprint swaps", undefined, "pan_sprintswaps");
            self add_dvar_toggle("freeze anim", undefined, "pan_freezeanim");
            self add_dvar_toggle("canzooms", undefined, "pan_canzooms");
            self add_dvar_toggle("always altswap", undefined, "pan_alwaysaltswap");

            self add_feature("always nac", "[{+weapnext}] to easily swap", "always_nac");
            self add_feature("elevators", "[{+speed_throw}] ^5+ ^7[{+stance}] on the ground", "elevators");
            // alt swaps
            self add_feature("instaswaps", "[{+frag}] to swap", "instaswaps");
            self add_feature("auto prone", undefined, "auto_prone");
            self add_feature("auto reload", undefined, "auto_reload");
            self add_feature("headbounces", undefined, "headbounces");
            self add_increment("instaswaps time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("instaswaps_time"), 0.05, 1, 0.05, "instaswaps_time");
            self add_array("auto prone mode", sliders, &cicada_mods::set_value, cicada_util::list("air,always"), self cicada_util::getpers("auto_prone_mode"), "auto_prone_mode");
            break;

        case "glitches":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("one handed gun", undefined, &cicada_mods::one_handed_gun);
            self add_option("switch to equipment", "^:" + cicada_catalog::count("equipment") + " ^7equipment available", &new_menu, "switch to equipment");
            break;

            // extension of glitches
        case "switch to equipment":
            self.bind_index = false;
            self add_menu(menu);
            foreach (item in cicada_catalog::get("equipment"))
                self add_option(item.name, "^:" + item.id, &cicada_loadout::give_equipment, item.id);
            break;

        case "visions":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("vision sets", "^:" + cicada_catalog::vision_refs().size + " ^7visions loaded", &new_menu, "vision sets");
            self add_option("killstreak visions", "^:" + cicada_catalog::killstreak_vision_refs().size + " ^7visions loaded", &new_menu, "killstreak visions");
            self add_option("killstreak " + self accent() + "hud", self cicada_mods::vision_hud_summary(), &new_menu, "killstreak hud");
            self add_option("clear visions", self cicada_mods::vision_summary("vision"), &cicada_mods::clear_visions);
            self add_array("thermal vision", sliders, &cicada_mods::set_vision_effect, cicada_util::list("off,on"), self cicada_util::getpers("vision_thermal"), "thermal");
            self add_array("pain vision", sliders, &cicada_mods::set_vision_effect, cicada_util::list("off,on"), self cicada_util::getpers("vision_pain"), "pain");
            self add_array("night vision", sliders, &cicada_mods::set_vision_effect, cicada_util::list("off,on"), self cicada_util::getpers("vision_night"), "night");
            self add_increment("vision fade time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("vision_time"), 0, 5, 0.05, "vision_time");
            break;

        case "killstreak hud":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_catalog::streak_hud_ready())
            {
                self add_option("^1no killstreak huds loaded");
                break;
            }
            self add_toggle("show the hud", self toggle_summary("vision_hud", self cicada_mods::vision_hud_summary()), self cicada_util::getpers("vision_hud"), &cicada_mods::flip_vision_hud, "vision_hud");
            self add_array("choose hud", "^:" + cicada_catalog::streak_hud_count() + " ^7registered", &cicada_mods::set_vision_hud, cicada_mods::vision_hud_modes(), self cicada_util::getpers("vision_hud_mode"), "vision_hud_mode");
            self add_toggle("health bar", undefined, self cicada_util::getpers("vision_hud_health"), &cicada_mods::flip_vision_hud, "vision_hud_health");
            if (istrue(self cicada_util::getpers("vision_hud_health")))
                self add_increment("health shown", increments, &cicada_mods::set_vision_hud, self cicada_util::getpersfloat("vision_hud_health_amount"), 0, 1, 0.05, "vision_hud_health_amount");
            self add_toggle("countdown", undefined, self cicada_util::getpers("vision_hud_countdown"), &cicada_mods::flip_vision_hud, "vision_hud_countdown");
            if (istrue(self cicada_util::getpers("vision_hud_countdown")))
                self add_increment("countdown time", increments, &cicada_mods::set_vision_hud, self cicada_util::getpersfloat("vision_hud_countdown_time"), 1, 300, 1, "vision_hud_countdown_time");
            self add_toggle("flare count", undefined, self cicada_util::getpers("vision_hud_flares"), &cicada_mods::flip_vision_hud, "vision_hud_flares");
            if (istrue(self cicada_util::getpers("vision_hud_flares")))
                self add_increment("flares shown", increments, &cicada_mods::set_vision_hud, self cicada_util::getpersint("vision_hud_flare_count"), 0, 10, 1, "vision_hud_flare_count");
            self add_toggle("thermal marker", undefined, self cicada_util::getpers("vision_hud_thermal"), &cicada_mods::flip_vision_hud, "vision_hud_thermal");
            self add_toggle("damage state", undefined, self cicada_util::getpers("vision_hud_damage"), &cicada_mods::flip_vision_hud, "vision_hud_damage");
            if (istrue(self cicada_util::getpers("vision_hud_damage")))
                self add_increment("damage shown", increments, &cicada_mods::set_vision_hud, self cicada_util::getpersint("vision_hud_damage_state"), 0, 3, 1, "vision_hud_damage_state");
            self add_option(cicada_util::warn("clear hud"), undefined, &cicada_mods::clear_vision_hud);
            break;

        case "afterhits":
            self.bind_index = false;
            self add_menu(menu);
            self add_state("turn on", self toggle_summary("after_on", self cicada_afterhits::summary()), "after_on");
            self add_array("delay", "waits before it fires", &cicada_mods::set_value, cicada_afterhits::delay_options(), self cicada_util::getpers("after_delay"), "after_delay");
            self add_option("preview", "runs the whole thing", &cicada_afterhits::preview);
            self afterhits_part("weapon", self cicada_afterhits::weapon_summary(), "afterhits weapon", increments);
            self afterhits_part("equipment", self cicada_afterhits::equipment_summary(), "afterhits equipment", increments);
            self afterhits_part("streak", self cicada_afterhits::streak_summary(), "afterhits support", increments);
            self afterhits_part("effect", self cicada_mods::stack_summary("after_effect"), "afterhits effect stack", increments);
            self afterhits_part("sound", self cicada_mods::sound_stack_summary("after_sound"), "afterhits sound stack", increments);
            self afterhits_part("anim", self cicada_afterhits::anim_summary(), "afterhits anim", increments);
            self afterhits_part("spot", self cicada_afterhits::spot_summary(), "afterhits position", increments);
            self add_option("extra " + self accent() + "actions", ("^:" + self cicada_afterhits::extra_count() + " ^7of ^:" + cicada_afterhits::extra_names().size), &new_menu, "afterhits extras");
            break;

        case "afterhits extras":
            self.bind_index = false;
            self add_menu(menu);
            self add_option(cicada_util::warn("clear extras"), ("^:" + self cicada_afterhits::extra_count() + " ^7of ^:" + cicada_afterhits::extra_names().size), &cicada_afterhits::clear_extras);
            foreach (name in cicada_afterhits::extra_names())
            {
                self add_toggle(name, self cicada_afterhits::extra_on(name) ? self cicada_afterhits::extra_delay_summary(name) : undefined, self cicada_afterhits::extra_on(name), &cicada_afterhits::flip_extra, name);
                if (self cicada_afterhits::extra_on(name))
                    self add_increment("^7- delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(cicada_afterhits::extra_delay_key(name)), 0, 20, 0.05, cicada_afterhits::extra_delay_key(name));
            }
            break;

        case "afterhits weapon":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("use held weapon", self cicada_afterhits::weapon_summary(), &cicada_afterhits::set_held_weapon);
            self add_option(cicada_util::warn("clear weapon"), undefined, &cicada_afterhits::clear_weapon);
            foreach (category in cicada_catalog::weapon_categories())
                self add_option(category, "^:" + cicada_catalog::count(category) + " ^7loaded", &new_menu, "afterhits weapon list");
            break;

        case "afterhits weapon list":
            self.bind_index = false;
            self add_menu(self.select_category);
            foreach (weapon in cicada_catalog::get(self.select_category))
                self add_option(weapon.name, "^:" + weapon.id, &cicada_afterhits::set_weapon, weapon.id);
            break;

        case "afterhits equipment":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::equipment_refs("primary"))
                self add_option(cicada_catalog::label(ref), "^2lethal", &cicada_afterhits::set_equipment, ref);
            foreach (ref in cicada_catalog::equipment_refs("secondary"))
                self add_option(cicada_catalog::label(ref), "^1tactical", &cicada_afterhits::set_equipment, ref);
            foreach (item in cicada_catalog::get("equipment"))
                self add_option(item.name, "^:" + item.id, &cicada_afterhits::set_equipment, item.id);
            break;

        case "afterhits support":
            self.bind_index = false;
            self add_menu(menu);
            foreach (streak in cicada_catalog::get("mp streaks"))
                self add_option(streak.name, cicada_catalog::streak_summary(streak), &cicada_afterhits::set_streak, streak.id);
            foreach (streak in cicada_catalog::get("warzone extras"))
                self add_option(streak.name, cicada_catalog::streak_summary(streak), &cicada_afterhits::set_streak, streak.id);
            break;

        case "afterhits effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("after_effect", "afterhits effect list", increments, sliders);
            self add_state("play at the spot", "otherwise it plays on you", "after_effect_here");
            if (!istrue(self cicada_util::getpers("after_effect_here")))
                self add_increment("effect height", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_effect_lift"), -200, 200, 5, "after_effect_lift");
            break;

        case "afterhits sound stack":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("stack manager", sliders, &cicada_mods::manage_sound_stack, cicada_util::list("add current,remove last,clear,randomize"), "pick_stack", "after_sound");
            self add_option("preview stack", self cicada_mods::sound_stack_summary("after_sound"), &cicada_mods::preview_sound_stack, "after_sound");
            self add_increment("random stack size", increments, &cicada_mods::set_value, self cicada_util::getpersint("stack_size"), 1, 10, 1, "stack_size");
            self add_increment("wait between", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("after_sound_gap"), 0, 3, 0.05, "after_sound_gap");
            for (i = 0; i < self cicada_mods::stack_count("after_sound"); i++)
                self add_option("^:" + (i + 1) + " ^7- " + self cicada_mods::sound_label(self cicada_mods::stack_effect("after_sound", i)), "^:stacked sound");
            foreach (group in cicada_catalog::sound_groups())
                self add_option(group, "^:" + cicada_catalog::sound_count(group) + " ^7loaded", &new_menu, "afterhits sound list");
            break;

        case "afterhits sound list":
            self.bind_index = false;
            self add_menu(self.select_sound_group);
            self add_option("stack a random one", "^:" + cicada_catalog::sound_count(self.select_sound_group) + " ^7loaded", &cicada_mods::add_stack_sound, cicada_catalog::random_sound(self.select_sound_group), "after_sound");
            for (i = 0; i < cicada_catalog::sound_count(self.select_sound_group); i++)
            {
                name = cicada_catalog::sound_at(self.select_sound_group, i);
                self add_option(self cicada_mods::sound_label(name), "^:adds to the stack", &cicada_mods::add_stack_sound, name, "after_sound");
            }
            break;

        case "afterhits anim":
            self.bind_index = false;
            self add_menu(menu);
            self add_increment("anim id", "^5[{+gostand}] ^7to preview", &cicada_mods::set_value, self cicada_util::getpersint("after_anim_id"), 0, 255, 1, "after_anim_id", undefined, &cicada_afterhits::preview_anim);
            self add_array("hands", sliders, &cicada_mods::set_value, cicada_util::list("right,both"), self cicada_util::getpers("after_anim_hands"), "after_anim_hands");
            self add_state("always random", self toggle_summary("after_anim_random", self cicada_mods::anim_range_summary("after_anim_random", "after_anim_range", "after_anim_min", "after_anim_max")), "after_anim_random");
            if (istrue(self cicada_util::getpers("after_anim_random")))
            {
                self add_state("randomize range", "^:1 ^7to ^:150 ^7when on", "after_anim_range");
                if (!istrue(self cicada_util::getpers("after_anim_range")))
                {
                    self add_increment("lowest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_anim_min"), 1, 255, 1, "after_anim_min");
                    self add_increment("highest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_anim_max"), 1, 255, 1, "after_anim_max");
                }
            }
            break;

        case "afterhits position":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("save spot", self cicada_afterhits::spot_summary(), &cicada_afterhits::save_spot);
            self add_option("go to spot", self cicada_afterhits::spot_summary(), &cicada_afterhits::go_to_spot);
            self add_option(cicada_util::warn("clear spot"), undefined, &cicada_afterhits::clear_spot);
            self add_increment("offset x", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_x"), -500, 500, 5, "after_x");
            self add_increment("offset y", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_y"), -500, 500, 5, "after_y");
            self add_increment("offset z", increments, &cicada_mods::set_value, self cicada_util::getpersint("after_z"), -500, 500, 5, "after_z");
            break;

        case "vision sets":
            self.bind_index = false;
            self add_menu(menu);
            foreach (name in cicada_catalog::vision_refs())
                self add_option(cicada_catalog::vision_label(name), "^:" + name, &cicada_mods::set_vision, name);
            break;

        case "killstreak visions":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_catalog::killstreak_vision_refs().size)
                self add_option("^1no killstreak visions loaded");
            else
                foreach (name in cicada_catalog::killstreak_vision_refs())
                    self add_option(cicada_catalog::vision_label(name), "^:" + name, &cicada_mods::set_killstreak_vision, name);
            break;

        case "cinematics":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("start camera path", self cicada_cinematics::summary(), &cicada_cinematics::start_path);
            self add_option("stop camera path", self cicada_cinematics::summary(), &cicada_cinematics::stop_path);
            self add_array("set camera mode", sliders, &cicada_cinematics::set_mode, cicada_util::list("bezier,linear"), self cicada_cinematics::mode());
            if (self cicada_cinematics::mode() == "bezier")
                self add_increment("set bezier speed", increments, &cicada_mods::set_value, self cicada_util::getpersint("camera_bezier_speed"), 1, 20, 1, "camera_bezier_speed");
            else
                self add_increment("set linear time", increments, &cicada_mods::set_value, self cicada_util::getpersint("camera_linear_time"), 1, 20, 1, "camera_linear_time");
            self add_increment("set camera rotation", increments, &cicada_cinematics::set_rotation, self cicada_util::getpersint("camera_rotation"), 0, 360, 1);
            self add_increment("set camera fov", "^:0 ^7uses your own fov, ^5[{+gostand}]^7 to preview", &cicada_cinematics::set_fov, self cicada_cinematics::fov(), 0, 120, 1, undefined, undefined, &cicada_cinematics::preview_fov);
            self add_option("save node", self cicada_cinematics::summary(), &cicada_cinematics::save_node);
            self add_option("delete last node", self cicada_cinematics::summary(), &cicada_cinematics::delete_last_node);
            self add_option("clone self", undefined, &cicada_cinematics::clone_self);
            self add_option(cicada_util::warn("clear all nodes"), self cicada_cinematics::summary(), &cicada_cinematics::clear_nodes);
            break;

        case "position":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("unstuck", undefined, &cicada_mods::unstuck);
            self add_feature("save and load binds", ("crouch ^5+ ^7" + self cicada_binds::slot_label(self cicada_util::getpers("save_slot")) + " ^5/ ^7" + self cicada_binds::slot_label(self cicada_util::getpers("load_slot"))), "save_load_binds");
            self add_array_live("save position button", live_sliders, &cicada_binds::set_slot_key, self cicada_binds::slot_labels(), self cicada_binds::slot_label(self cicada_util::getpers("save_slot")), "save_slot");
            self add_array_live("load position button", live_sliders, &cicada_binds::set_slot_key, self cicada_binds::slot_labels(), self cicada_binds::slot_label(self cicada_util::getpers("load_slot")), "load_slot");
            self add_array_pers("manage position", sliders, &cicada_mods::manage_position, cicada_util::list("save,load,reset"), "pick_position");
            if (self cicada_mods::has_position())
                self add_option("manage coords", self cicada_mods::position_summary(), &new_menu, "manage coords");
            self add_option("bot paths", self cicada_movement::summary("path"), &new_menu, "bot paths");
            break;

        case "manage coords":
            self.bind_index = false;
            self add_menu(menu);
            if (self cicada_mods::has_position())
                self position_options(increments);
            else
                self add_option("^1no position saved");
            break;

            //case "link manager":
            //self.bind_index = false;
            //self add_menu(menu);
            //self add_option(self cicada_link::is_linked() ? "^1unlink" : "^2ride now", self cicada_link::summary(), self cicada_link::is_linked() ? &cicada_link::stop_ride : &cicada_link::start_ride);
            //self add_array("ride what", sliders, &cicada_mods::set_value, cicada_link::targets(), self cicada_util::getpers("link_target"), "link_target");
            //self add_array("link mode", sliders, &cicada_mods::set_value, cicada_link::modes(), self cicada_util::getpers("link_mode"), "link_mode");
            //self add_array("thrown stuff", "grenades and rockets", &cicada_mods::set_value, cicada_link::when_modes(), self cicada_util::getpers("link_when"), "link_when");
            //self add_state("steer yourself", "moves it where you look", "link_control");
            //if (istrue(self cicada_util::getpers("link_control")))
            //self add_increment("steer speed", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_speed"), 100, 4000, 50, "link_speed");
            //self add_option("ride offset", "^:" + self cicada_util::getpersint("link_x") + " ^7/ ^:" + self cicada_util::getpersint("link_y") + " ^7/ ^:" + self cicada_util::getpersint("link_z"), &new_menu, "link offset");
            //self add_option("view limits", "^:" + self cicada_util::getpersfloat("link_view") + " ^7view fraction", &new_menu, "link view");
            //self add_state("invincible while riding", undefined, "link_god");
            //self add_state("third person", undefined, "link_third");
            //self add_state("jump to unlink", "jump drops you off it", "link_jump_off");
            //self add_state("match angles", "the rig spins with it", "link_spin");
            //self add_state("hop off at the end", undefined, "link_drop");
            //if (istrue(self cicada_util::getpers("link_drop")))
            //self add_increment("hop off lift", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_drop_lift"), 0, 1000, 50, "link_drop_lift");
            //self add_increment("auto unlink after", "^:0 ^7keeps you on it", &cicada_mods::set_value, self cicada_util::getpersfloat("link_time"), 0, 60, 0.5, "link_time");
            //break;

            //case "link offset":
            //self.bind_index = false;
            //self add_menu(menu);
            //self add_increment("offset x", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_x"), -200, 200, 5, "link_x");
            //self add_increment("offset y", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_y"), -200, 200, 5, "link_y");
            //self add_increment("offset z", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_z"), -200, 200, 5, "link_z");
            //break;

            //case "link view":
            //self.bind_index = false;
            //self add_menu(menu);
            //self add_increment("view fraction", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("link_view"), 0, 1, 0.05, "link_view");
            //self add_increment("look right", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_arc_right"), 0, 180, 5, "link_arc_right");
            //self add_increment("look left", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_arc_left"), 0, 180, 5, "link_arc_left");
            //self add_increment("look up", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_arc_top"), 0, 90, 5, "link_arc_top");
            //self add_increment("look down", increments, &cicada_mods::set_value, self cicada_util::getpersint("link_arc_bottom"), 0, 90, 5, "link_arc_bottom");
            //break;

        case "parachute settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("open now", self cicada_mechanics::summary(), &cicada_mechanics::chute_open);
            self add_option("^1cut chute", "drops the chute right away", &cicada_mechanics::chute_cancel);
            self add_state("jump to cut", "jump cancels the chute", "chute_jump_off");
            self add_state("freefall first", "skydive before it opens", "chute_freefall");
            if (istrue(self cicada_util::getpers("chute_freefall")))
                self add_increment("freefall time", "^5[{+gostand}] ^7pulls it sooner", &cicada_mods::set_value, self cicada_util::getpersfloat("chute_fall_time"), 0, 15, 0.5, "chute_fall_time");
            self add_state("can cut the chute", undefined, "chute_can_cut");
            self add_state("third person", undefined, "chute_third");
            self add_state("infil smoke", "the skydive trail", "chute_smoke");
            self add_feature("auto parachute", "opens it on a long drop", "auto_chute");
            if (istrue(self cicada_util::getpers("auto_chute")))
            {
                self add_increment("fall speed needed", increments, &cicada_mods::set_value, self cicada_util::getpersint("chute_speed"), 100, 2000, 50, "chute_speed");
                self add_increment("height needed", increments, &cicada_mods::set_value, self cicada_util::getpersint("chute_height"), 100, 3000, 50, "chute_height");
            }
            self add_feature("jump to redeploy", "jump in the air to open it", "redeploy");
            if (istrue(self cicada_util::getpers("redeploy")))
            {
                self add_array("redeploy input", sliders, &cicada_mechanics::set_redeploy, cicada_mechanics::redeploy_modes(), self cicada_util::getpers("chute_redeploy_input"), "chute_redeploy_input");
                self add_increment("redeploy height", increments, &cicada_mechanics::set_redeploy, self cicada_util::getpersint("chute_redeploy_height"), 64, 2000, 32, "chute_redeploy_height");
            }
            break;

        case "leftovers":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("radiation " + self accent() + "zones", ("^:" + self cicada_leftovers::zone_count() + " ^7zones"), &new_menu, "radiation zones");
            self add_option("tripwires", self cicada_leftovers::wire_summary(), &new_menu, "tripwires");
            self add_option("explosive " + self accent() + "rounds", (istrue(self.cicada_xrounds) ? "^2on" : "^1off"), &new_menu, "explosive rounds");
            self add_option("station " + self accent() + "manager", self cicada_stations::summary(), &new_menu, "station manager");
            self add_option("what is loaded", "prints it for you", &cicada_stations::probe_report);
            break;

        case "station manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("station manager", sliders, &cicada_stations::manage_stations, cicada_util::list("place,clear"), "pick_station");
            self add_array("what to place", sliders, &cicada_mods::set_value, cicada_stations::kinds(), self cicada_util::getpers("station_kind"), "station_kind");
            self add_option("station settings", "^:" + self cicada_util::getpers("station_kind"), &new_menu, "station settings");
            self add_option("placed stations", self cicada_stations::summary(), &new_menu, "placed stations");
            break;

        case "station settings":
            self.bind_index = false;
            self add_menu(self cicada_util::getpers("station_kind"));
            self add_array("model", sliders, &cicada_mods::set_value, cicada_props::model_labels(), self cicada_util::getpers(cicada_stations::kind_key(self cicada_util::getpers("station_kind"), "model")), cicada_stations::kind_key(self cicada_util::getpers("station_kind"), "model"));
            self add_increment("use range", increments, &cicada_mods::set_value, self cicada_util::getpersint("station_radius"), 30, 500, 10, "station_radius");
            self add_increment("cooldown", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("station_cooldown"), 0.5, 30, 0.5, "station_cooldown");
            self add_increment("uses allowed", "^:0 ^7never runs out", &cicada_mods::set_value, self cicada_util::getpersint("station_uses"), 0, 50, 1, "station_uses");
            self add_state("outline it", undefined, "station_outline");
            self add_option("effects " + self accent() + "& sounds", self cicada_stations::events_summary(self cicada_util::getpers("station_kind")), &new_menu, "station events");
            self add_increment("model effect rate", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("station_idle_rate"), 0.25, 10, 0.25, "station_idle_rate");
            if (self cicada_util::getpers("station_kind") == "magic box")
            {
                self add_array("weapon pool", "^:" + cicada_stations::pool_count(self cicada_util::getpers("box_pool")) + " ^7in there", &cicada_mods::set_value, cicada_stations::box_pools(), self cicada_util::getpers("box_pool"), "box_pool");
                self add_increment("joker chance", "^7% it hops away", &cicada_mods::set_value, self cicada_util::getpersint("box_joker"), 0, 100, 5, "box_joker");
                self add_increment("roll time", "wait before it pays out", &cicada_mods::set_value, self cicada_util::getpersfloat("station_roll_time"), 0, 5, 0.1, "station_roll_time");
            }
            if (self cicada_util::getpers("station_kind") == "wall buy")
            {
                self add_array("it gives", sliders, &cicada_mods::set_value, cicada_stations::buy_modes(), self cicada_util::getpers("buy_mode"), "buy_mode");
                if (self cicada_util::getpers("buy_mode") == "weapon")
                    self add_option("choose weapon", "^:" + self cicada_mods::sound_label(self cicada_util::getpers("buy_weapon")), &cicada_stations::set_buy_weapon);
            }
            if (self cicada_util::getpers("station_kind") == "ascender")
            {
                self add_increment("ride height", increments, &cicada_mods::set_value, self cicada_util::getpersint("lift_height"), 100, 3000, 50, "lift_height");
                self add_increment("ride time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("lift_speed"), 0.25, 10, 0.25, "lift_speed");
                self add_increment("ride effect rate", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("station_ride_rate"), 0.05, 2, 0.05, "station_ride_rate");
            }
            break;

        case "station events":
            self.bind_index = false;
            self add_menu(menu);
            foreach (event in cicada_stations::kind_events(self cicada_util::getpers("station_kind")))
                self add_option(cicada_stations::fx_label(event), (self cicada_mods::stack_summary(cicada_stations::fx_key(event)) + " ^7| " + self cicada_mods::sound_stack_summary(cicada_stations::sound_key(event))), &new_menu, "station event");
            break;

        case "station event":
            self.bind_index = false;
            self add_menu(cicada_stations::fx_label(self.select_event));
            self add_option("preview", (self cicada_mods::stack_summary(cicada_stations::fx_key(self.select_event)) + " ^7| " + self cicada_mods::sound_stack_summary(cicada_stations::sound_key(self.select_event))), &cicada_stations::preview_event, self.select_event);
            self add_option("effects", self cicada_mods::stack_summary(cicada_stations::fx_key(self.select_event)), &new_menu, "station effect stack");
            self add_option("sounds", self cicada_mods::sound_stack_summary(cicada_stations::sound_key(self.select_event)), &new_menu, "station sound stack");
            break;

        case "station effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options(cicada_stations::fx_key(self.select_event), "station effect list", increments, sliders);
            break;

        case "station sound stack":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("stack manager", sliders, &cicada_mods::manage_sound_stack, cicada_util::list("add current,remove last,clear,randomize"), "pick_stack", cicada_stations::sound_key(self.select_event));
            self add_option("preview stack", self cicada_mods::sound_stack_summary(cicada_stations::sound_key(self.select_event)), &cicada_mods::preview_sound_stack, cicada_stations::sound_key(self.select_event));
            self add_increment("random stack size", increments, &cicada_mods::set_value, self cicada_util::getpersint("stack_size"), 1, 10, 1, "stack_size");
            self add_increment("wait between", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(cicada_stations::sound_key(self.select_event) + "_gap"), 0, 3, 0.05, cicada_stations::sound_key(self.select_event) + "_gap");
            for (i = 0; i < self cicada_mods::stack_count(cicada_stations::sound_key(self.select_event)); i++)
                self add_option("^:" + (i + 1) + " ^7- " + self cicada_mods::sound_label(self cicada_mods::stack_effect(cicada_stations::sound_key(self.select_event), i)), "^:stacked sound");
            foreach (group in cicada_catalog::sound_groups())
                self add_option(group, "^:" + cicada_catalog::sound_count(group) + " ^7loaded", &new_menu, "station sound list");
            break;

        case "station sound list":
            self.bind_index = false;
            self add_menu(self.select_sound_group);
            self add_option("stack a random one", "^:" + cicada_catalog::sound_count(self.select_sound_group) + " ^7loaded", &cicada_mods::add_stack_sound, cicada_catalog::random_sound(self.select_sound_group), cicada_stations::sound_key(self.select_event));
            for (i = 0; i < cicada_catalog::sound_count(self.select_sound_group); i++)
            {
                name = cicada_catalog::sound_at(self.select_sound_group, i);
                self add_option(self cicada_mods::sound_label(name), "^:adds to the stack", &cicada_mods::add_stack_sound, name, cicada_stations::sound_key(self.select_event));
            }
            break;

        case "placed stations":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_stations::station_count())
                self add_option("^1nothing placed");
            for (i = 0; i < cicada_stations::station_count(); i++)
                self add_option(cicada_stations::station_label(cicada_stations::station_at(i)), self cicada_stations::station_summary(cicada_stations::station_at(i)), &new_menu, "station option");
            break;

        case "station option":
            self.bind_index = false;
            self add_menu(cicada_stations::station_label(self.select_station));
            self add_option("bring here", self cicada_stations::station_summary(self.select_station), &cicada_stations::move_station, self.select_station);
            if (isdefined(self.select_station) && isdefined(self.select_station.model))
                self add_increment("height", increments, &cicada_stations::raise_station, self.select_station.model.origin[2], -100000, 100000, 10, self.select_station);
            self add_option(cicada_util::warn("remove station"), undefined, &cicada_stations::remove_station, self.select_station);
            break;

        case "radiation zones":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("zone manager", sliders, &cicada_leftovers::manage_zones, cicada_util::list("place,delete last,clear"), "pick_zone");
            self add_increment("zone width", increments, &cicada_mods::set_value, self cicada_util::getpersint("zone_radius"), 50, 3000, 50, "zone_radius");
            self add_increment("zone damage", increments, &cicada_mods::set_value, self cicada_util::getpersint("zone_damage"), 1, 200, 1, "zone_damage");
            self add_increment("damage every", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("zone_rate"), 0.05, 5, 0.05, "zone_rate");
            self add_state("enemies only", undefined, "zone_enemies");
            self add_state("hurts you too", undefined, "zone_hurt_owner");
            self add_option("zone effects", self cicada_mods::stack_summary("zone_effect"), &new_menu, "zone effect stack");
            break;

        case "zone effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("zone_effect", "zone effect list", increments, sliders);
            break;

        case "tripwires":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("wire manager", sliders, &cicada_leftovers::manage_wires, cicada_util::list("save point,clear"), "pick_wire");
            self add_option("save point", self cicada_leftovers::wire_summary(), &cicada_leftovers::save_wire_point);
            self add_increment("wire thickness", increments, &cicada_mods::set_value, self cicada_util::getpersint("wire_reach"), 4, 200, 4, "wire_reach");
            self add_increment("wire damage", increments, &cicada_mods::set_value, self cicada_util::getpersint("wire_damage"), 10, 1000, 10, "wire_damage");
            self add_increment("blast width", increments, &cicada_mods::set_value, self cicada_util::getpersint("wire_blast"), 32, 1000, 16, "wire_blast");
            self add_state("one use only", undefined, "wire_once");
            self add_state("enemies only", undefined, "wire_enemies");
            self add_state("hurts you too", undefined, "wire_hurt_owner");
            self add_option("wire effects", self cicada_mods::stack_summary("wire_effect"), &new_menu, "wire effect stack");
            break;

        case "wire effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("wire_effect", "wire effect list", increments, sliders);
            break;

        case "explosive rounds":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("turn on or off", (istrue(self.cicada_xrounds) ? "^2on" : "^1off"), &cicada_leftovers::explosive_rounds);
            self add_increment("blast damage", increments, &cicada_mods::set_value, self cicada_util::getpersint("xrounds_damage"), 10, 1000, 10, "xrounds_damage");
            self add_increment("blast width", increments, &cicada_mods::set_value, self cicada_util::getpersint("xrounds_blast"), 32, 1000, 16, "xrounds_blast");
            self add_increment("wait between", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("xrounds_rate"), 0, 2, 0.05, "xrounds_rate");
            self add_option("blast effects", self cicada_mods::stack_summary("xrounds_effect"), &new_menu, "xrounds effect stack");
            break;

        case "xrounds effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("xrounds_effect", "xrounds effect list", increments, sliders);
            break;

        case "movement rules":
            self.bind_index = false;
            self add_menu(menu);
            self add_toggle("can jump", undefined, self cicada_util::getpers("move_jump"), &cicada_mechanics::flip_move, "move_jump");
            self add_toggle("can sprint", undefined, self cicada_util::getpers("move_sprint"), &cicada_mechanics::flip_move, "move_sprint");
            self add_toggle("can crouch", undefined, self cicada_util::getpers("move_crouch"), &cicada_mechanics::flip_move, "move_crouch");
            self add_toggle("can go prone", undefined, self cicada_util::getpers("move_prone"), &cicada_mechanics::flip_move, "move_prone");
            self add_toggle("can stand", undefined, self cicada_util::getpers("move_stand"), &cicada_mechanics::flip_move, "move_stand");
            self add_toggle("can melee", undefined, self cicada_util::getpers("move_melee"), &cicada_mechanics::flip_move, "move_melee");
            self add_toggle("can fire", undefined, self cicada_util::getpers("move_fire"), &cicada_mechanics::flip_move, "move_fire");
            self add_increment("move speed", increments, &cicada_mechanics::set_move_value, self cicada_util::getpersfloat("move_speed"), 0.25, 3, 0.05, "move_speed");
            self add_option(cicada_util::warn("reset movement rules"), undefined, &cicada_mechanics::reset_moves);
            break;

        case "bot manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("bot paths", self cicada_movement::summary("path"), &new_menu, "bot paths");
            self add_array("spawn bot", "^5[{+gostand}] ^7to spawn", &cicada_mods::spawn_bot_of, cicada_util::list("enemy,friendly"), self cicada_util::getpers("bot_team"), "bot_team");
            self add_array("bot difficulty", sliders, &cicada_mods::set_value, cicada_util::list("recruit,regular,hardened,veteran"), self cicada_util::getpers("bot_difficulty"), "bot_difficulty");
            self add_array_pers("teleport bots", sliders, &cicada_mods::move_bots, cicada_util::list("crosshair,self"), "pick_bots");
            self add_feature("freeze bots", undefined, "frozen_bots");
            self add_increment("auto respawn delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bot_respawn_delay"), 0.5, 30, 0.5, "bot_respawn_delay");
            self add_option("kill bots", "^:" + self cicada_util::getpers("kill_bot_mode"), &cicada_binds::kill_bots);
            break;

        case "bot paths":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("start path movement", self cicada_movement::summary("path"), &cicada_movement::start_bot_path);
            self add_option("save point", self cicada_movement::summary("path"), &cicada_movement::save_point, "path");
            self add_option("delete last point", self cicada_movement::summary("path"), &cicada_movement::delete_point, "path");
            self add_option("reset points", self cicada_movement::summary("path"), &cicada_movement::clear_points, "path");
            self add_toggle("show waypoints", "marks every saved point", cicada_movement::markers_on("path"), &cicada_movement::toggle_markers, "path");
            self add_state("reset to start point", "starts it at point one", "path_reset");
            self add_state("path messages", "prints each leg and time", "path_debug");
            break;

        case "zombie & actor paths":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("start path movement", self cicada_movement::summary("zombie_path"), &cicada_pve::start_zombie_path);
            self add_option("save point", self cicada_movement::summary("zombie_path"), &cicada_movement::save_point, "zombie_path");
            self add_option("delete last point", self cicada_movement::summary("zombie_path"), &cicada_movement::delete_point, "zombie_path");
            self add_option("reset points", self cicada_movement::summary("zombie_path"), &cicada_movement::clear_points, "zombie_path");
            self add_toggle("show waypoints", undefined, cicada_movement::markers_on("zombie_path"), &cicada_movement::toggle_markers, "zombie_path");
            self add_state("reset to start point", undefined, "zombie_path_reset");
            self add_state("path messages", undefined, "path_debug");
            break;

        case "aimbot settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_feature("aimbot", undefined, "aimbot");
            self add_array("aimbot weapons", sliders, &cicada_mods::set_aimbot_mode, cicada_mods::aimbot_modes(), self cicada_util::getpers("aimbot_mode"), "aimbot_mode");
            if (self cicada_util::getpers("aimbot_mode") == "selected weapons")
            {
                self add_option("aimbot weapon", "^:" + self cicada_mods::aimbot_weapon_name("aimbot_weapon"), &cicada_mods::set_aimbot_weapon, "aimbot_weapon");
                self add_option("second aimbot weapon", "^:" + self cicada_mods::aimbot_weapon_name("aimbot_weapon_2"), &cicada_mods::set_aimbot_weapon, "aimbot_weapon_2");
            }
            self add_array("hitmarker aimbot weapons", sliders, &cicada_mods::set_aimbot_mode, cicada_mods::hitmarker_modes(), self cicada_util::getpers("hitmarker_mode"), "hitmarker_mode");
            if (self cicada_util::getpers("hitmarker_mode") == "selected weapons")
                self add_option("hitmarker aimbot weapon", "^:" + self cicada_mods::aimbot_weapon_name("aimbot_weapon_hitmarker"), &cicada_mods::set_aimbot_weapon, "aimbot_weapon_hitmarker");
            if (self cicada_mods::uses_selected_weapons())
                self add_option("clear aimbot weapons", "aimbot off until one is set", &cicada_mods::clear_aimbot_weapons);
            self add_increment("range", increments, &cicada_mods::set_value, self cicada_util::getpersint("aimbot_range"), 100, 5000, 100, "aimbot_range");
            self add_array("delay", sliders, &cicada_mods::set_value, cicada_util::list("0,0.1,0.2,0.3,0.4,0.5"), self cicada_util::getpers("aimbot_delay"), "aimbot_delay");
            self add_state("works on zombies", "aimbot shoots zombies too", "aimbot_zombies");
            self add_option("equipment " + self accent() + "aimbot", self cicada_util::getpers("equipment_aimbot") ? "^:" + self cicada_util::getpers("equipment_aim_mode") : "^1off", &new_menu, "equipment aimbot");
            break;

        case "equipment aimbot":
            self.bind_index = false;
            self add_menu(menu);
            self add_feature("equipment aimbot", "throws home in on targets", "equipment_aimbot");
            self add_array("throws", sliders, &cicada_mods::set_value, cicada_mechanics::equipment_modes(), self cicada_util::getpers("equipment_aim_mode"), "equipment_aim_mode");
            self add_state("rockets and missiles", "launchers lock on as well", "equipment_aim_rockets");
            self add_state("anything thrown", "covers field upgrades too", "equipment_aim_any");
            self add_state("enemies only", undefined, "equipment_aim_enemies");
            self add_state("works on zombies", undefined, "equipment_aim_zombies");
            self add_increment("range", increments, &cicada_mods::set_value, self cicada_util::getpersint("equipment_aim_range"), 100, 5000, 100, "equipment_aim_range");
            self add_increment("homing speed", increments, &cicada_mods::set_value, self cicada_util::getpersint("equipment_aim_speed"), 200, 4000, 100, "equipment_aim_speed");
            self add_increment("aim height", increments, &cicada_mods::set_value, self cicada_util::getpersint("equipment_aim_height"), 0, 80, 5, "equipment_aim_height");
            break;

        case "effect manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("kill effects", self cicada_mods::stack_summary("kill_effect"), &new_menu, "kill effects");
            self add_option("tracer effects", self cicada_mods::stack_summary("tracer_effect"), &new_menu, "tracer effects");
            self add_option("bot effects", "loops effects on living bots", &new_menu, "bot effects");
            self add_option("zombie effects", "loops effects on the horde", &new_menu, "zombie effects");
            break;

        case "kill effects":
            self.bind_index = false;
            self add_menu(menu);
            self add_state("kill effects", "^:" + cicada_mods::effect_label(self cicada_util::getpers("kill_effect")), "kill_effects");
            self add_array("kill effect", sliders, &cicada_mods::set_value, cicada_mods::effect_list(), self cicada_util::getpers("kill_effect"), "kill_effect");
            self add_option("randomize kill effect", "^:" + cicada_mods::effect_label(self cicada_util::getpers("kill_effect")), &cicada_mods::randomize_effect, "kill_effect");
            self add_option("preview kill effect", "^:" + cicada_mods::effect_label(self cicada_util::getpers("kill_effect")), &cicada_mods::preview_effect, self cicada_util::getpers("kill_effect"));
            self add_option("stack kill effects", self cicada_mods::stack_summary("kill_effect"), &new_menu, "kill effect stack");
            break;

        case "tracer effects":
            self.bind_index = false;
            self add_menu(menu);
            self add_feature("tracer rounds", "^:" + cicada_mods::effect_label(self cicada_util::getpers("tracer_effect")), "tracers");
            self add_increment("effect count", increments, &cicada_mods::set_value, self cicada_util::getpersint("tracer_count"), 1, 10, 1, "tracer_count");
            self add_array("tracer effect", sliders, &cicada_mods::set_value, cicada_mods::effect_list(), self cicada_util::getpers("tracer_effect"), "tracer_effect");
            self add_option("randomize tracer effects", "^:" + cicada_mods::effect_label(self cicada_util::getpers("tracer_effect")), &cicada_mods::randomize_effect, "tracer_effect");
            self add_option("stack tracer effects", self cicada_mods::stack_summary("tracer_effect"), &new_menu, "tracer effect stack");
            break;

        case "kill effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("kill_effect", "kill effect list", increments, sliders);
            break;

        case "tracer effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("tracer_effect", "tracer effect list", increments, sliders);
            break;

        case "bot effects":
            self.bind_index = false;
            self add_menu(menu);
            self add_feature("loop effects on bots", "stops when the bot dies", "bot_effects");
            self add_increment("effect delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bot_effect_time"), 0.1, 5, 0.1, "bot_effect_time");
            self add_increment("effect height", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bot_effect_height"), 0, 100, 5, "bot_effect_height");
            self add_option("^1enemies", self cicada_mods::stack_summary("bot_effect_enemy"), &new_menu, "bot effects enemies");
            self add_option("^2friendly", self cicada_mods::stack_summary("bot_effect_friendly"), &new_menu, "bot effects friendly");
            break;

        case "zombie effects":
            self.bind_index = false;
            self add_menu(menu);
            self add_feature("loop effects on zombies", "^:" + cicada_pve::count() + " ^7alive", "zombie_effects");
            self add_array("applies to", sliders, &cicada_mods::set_value, cicada_pve::effect_targets(), self cicada_util::getpers("zombie_effect_target"), "zombie_effect_target");
            self add_increment("marked chance", "^7% counted as marked", &cicada_pve::set_value, self cicada_util::getpersint("pve_effect_chance"), 0, 100, 5, "pve_effect_chance");
            self add_option("reroll marks", "reapplies to zombies out", &cicada_pve::remark_zombies);
            self add_increment("effect delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("zombie_effect_time"), 0.1, 5, 0.1, "zombie_effect_time");
            self add_increment("effect height", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("zombie_effect_height"), 0, 100, 5, "zombie_effect_height");
            self stack_options("zombie_effect", "zombie effect list", increments, sliders);
            break;

        case "bot effects enemies":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("bot_effect_enemy", "enemy effect list", increments, sliders);
            break;

        case "bot effects friendly":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("bot_effect_friendly", "friendly effect list", increments, sliders);
            break;

        case "teleport sounds":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("replay picked", "^:" + self cicada_mods::sound_label(self cicada_util::getpers("teleport_sound_name")), &cicada_mods::preview_sound, self cicada_util::getpers("teleport_sound_name"));
            foreach (group in cicada_catalog::sound_groups())
                self add_option(group, "^:" + cicada_catalog::sound_count(group) + " ^7loaded", &new_menu, "teleport sound list");
            break;

        case "teleport sound list":
            self.bind_index = false;
            self add_menu(self.select_sound_group);
            self add_option("pick a random one", "^:" + cicada_catalog::sound_count(self.select_sound_group) + " ^7loaded", &cicada_mods::set_random_sound, self.select_sound_group, "teleport_sound_name");
            for (i = 0; i < cicada_catalog::sound_count(self.select_sound_group); i++)
            {
                name = cicada_catalog::sound_at(self.select_sound_group, i);
                self add_option(self cicada_mods::sound_label(name), "sets it and plays it", &cicada_mods::set_sound, name, "teleport_sound_name");
            }
            break;

        case "teleport effect stack":
            self.bind_index = false;
            self add_menu(menu);
            self stack_options("teleport_effect", "teleport effect list", increments, sliders);
            break;

        case "kill effect list":
        case "tracer effect list":
        case "enemy effect list":
        case "friendly effect list":
        case "zombie effect list":
        case "teleport effect list":
        case "station effect list":
        case "afterhits effect list":
        case "zone effect list":
        case "wire effect list":
        case "xrounds effect list":
            self.bind_index = false;
            self add_menu(menu);
            foreach (name in cicada_mods::effect_list())
                self add_option(cicada_mods::effect_label(name), "^:adds to the stack", &cicada_mods::add_stack_effect, name, stack_key(menu));
            break;

        case "binds":
            self.bind_index = false;
            self add_menu(menu);

            self add_option("reset all binds", "turns every bind off", &cicada_binds::reset_all);

            foreach (name in level.cicada_bind_names)
            {
                if (self cicada_binds::hidden(name))
                    continue;

                if (cicada_binds::has_settings(name))
                {
                    self add_option(name, "button and settings for ^:" + name, &new_menu, name);
                    continue;
                }

                self add_array_live(name, live_sliders, &cicada_binds::set_slot, self cicada_binds::slot_labels(), self cicada_binds::slot_label(self cicada_util::getpers(cicada_binds::slot_key(name))), name);
            }
            break;

        case "bind settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("choose bind", "^:" + self cicada_binds::visible_count() + " ^7available ^7- ^:" + self cicada_binds::used_count() + " ^7in use", &new_menu, "binds");
            self add_option("anim slots", "^:" + self cicada_mods::anim_slot_count() + " ^7of ^:" + cicada_mods::max_anim_slots() + " ^7used", &new_menu, "anim slots");
            self add_option("edit record movement", self cicada_movement::summary("record"), &new_menu, "record movement settings");
            self add_option("edit bolt movement", self cicada_movement::summary("bolt"), &new_menu, "bolt movement settings");
            self add_option("edit class change", undefined, &new_menu, "class change settings");
            self add_option("edit velocity", undefined, &new_menu, "edit velocity");
            self add_option("edit bot velocity", undefined, &new_menu, "edit bot velocity");
            self add_option("edit agent velocity", undefined, &new_menu, "edit agent velocity");
            self add_option("edit zombie velocity", undefined, &new_menu, "edit zombie velocity");
            self add_option("choose equipment", self cicada_mods::equipment_bind_summary(), &new_menu, "equipment bind");
            self add_array("stuck weapon", sliders, &cicada_mods::set_value, cicada_util::list("semtex_mp,molotov_mp,thermite_mp"), self cicada_util::getpers("stuck_weapon"), "stuck_weapon");
            self add_state("put away equipment", undefined, "equipment_putaway");
            self add_state("real scavenger", undefined, "real_scavenger");
            self add_state("repeater illusions", undefined, "repeater_illusion");
            self add_array("shellshock type", sliders, &cicada_mods::set_value, cicada_util::list("frag_grenade_mp,flash_grenade_mp,concussion_grenade_mp,thermite_mp"), self cicada_util::getpers("shellshock_type"), "shellshock_type");
            self add_option("bind amounts", "times and strengths", &new_menu, "bind amounts");
            break;

        case "attachment manager":
            self.bind_index = false;
            self add_menu(menu);
            weapons = self cicada_loadout::held_weapons();
            if (!weapons.size)
                self add_option("^1nothing to work on");
            for (i = 0; i < weapons.size; i++)
                self add_option(self cicada_loadout::weapon_label(weapons[i]), "^:" + cicada_loadout::fitted_attachments(weapons[i]).size + " ^7of ^:5 ^7fitted", &new_menu, "weapon attachments");
            break;

        case "weapon attachments":
            self.bind_index = false;
            self add_menu(self cicada_loadout::weapon_label(self cicada_loadout::weapon_by_root(self.select_weapon)));
            slots = self cicada_loadout::weapon_slots(self cicada_loadout::weapon_by_root(self.select_weapon));
            for (i = 0; i < slots.size; i++)
                self add_option(slots[i], self cicada_loadout::slot_summary(self.select_weapon, slots[i]), &new_menu, "attachment slot");
            if (!slots.size)
                self add_option("^1no attachments for this one");
            self add_option("^:random ^7attachments", "rolls a valid mix", &cicada_loadout::randomize_weapon_attachments, self.select_weapon);
            self add_option(cicada_util::warn("clear attachments"), "^:" + self cicada_loadout::fitted_count(self.select_weapon) + " ^7fitted", &cicada_loadout::clear_attachments, self.select_weapon);
            break;

        case "attachment slot":
            self.bind_index = false;
            self add_menu(self.select_slot);
            self add_option("clear this slot", self cicada_loadout::slot_summary(self.select_weapon, self.select_slot), &cicada_loadout::clear_slot, self.select_weapon, self.select_slot);
            foreach (name in self cicada_loadout::slot_options(self.select_weapon, self.select_slot))
                self add_option(cicada_loadout::attachment_label(self.select_weapon, name), "fits it right away", &cicada_loadout::set_attachment, name, self.select_weapon, self.select_slot);
            break;

        case "bind amounts":
            self.bind_index = false;
            self add_menu(menu);
            if (istrue(self cicada_util::getpers("equipment_putaway")))
                self add_increment("put away time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("equipment_putaway_time"), 0.05, 5, 0.05, "equipment_putaway_time");
            self add_increment("instant tac time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("instant_tac_time"), 0.05, 3, 0.05, "instant_tac_time");
            self add_increment("spectator repeater time", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("spectate_time"), 0.05, 2, 0.05, "spectate_time");
            self add_increment("damage amount", increments, &cicada_mods::set_value, self cicada_util::getpersint("damage_amount"), 10, 100, 10, "damage_amount");
            self add_increment("flash amount", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("flash_amount"), 0.25, 5, 0.25, "flash_amount");
            self add_increment("shellshock amount", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("shellshock_amount"), 0.05, 1, 0.05, "shellshock_amount");
            break;

        case "anim slots":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("add an anim slot", "^:" + self cicada_mods::anim_slot_count() + " ^7of ^:" + cicada_mods::max_anim_slots() + " ^7used", &cicada_mods::add_anim_slot);
            self add_option("remove the last slot", "clears its anim and button", &cicada_mods::remove_last_anim_slot);
            for (i = 1; i <= self cicada_mods::anim_slot_count(); i++)
                self add_option(cicada_mods::anim_slot_name(i), self cicada_mods::anim_slot_summary(i), &new_menu, cicada_mods::anim_slot_name(i));
            break;

        case "equipment bind":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("choose ^2lethal^7", "^:" + cicada_catalog::equipment_refs("primary").size + " ^7lethals loaded", &new_menu, "equipment bind lethal");
            self add_option("choose ^1tactical^7", "^:" + cicada_catalog::equipment_refs("secondary").size + " ^7tacticals loaded", &new_menu, "equipment bind tactical");
            self add_option("choose ^5field upgrade^7", "^:" + cicada_catalog::super_refs().size + " ^7upgrades loaded", &new_menu, "equipment bind upgrade");
            self add_option("choose weapon", "^:" + cicada_catalog::count("equipment") + " ^7weapons loaded", &new_menu, "equipment bind weapon");
            break;

        case "equipment bind lethal":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::equipment_refs("primary"))
                self add_option(cicada_catalog::pretty(ref, "equip"), "^:" + ref, &cicada_mods::set_equipment_bind, ref, "primary");
            break;

        case "equipment bind tactical":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::equipment_refs("secondary"))
                self add_option(cicada_catalog::pretty(ref, "equip"), "^:" + ref, &cicada_mods::set_equipment_bind, ref, "secondary");
            break;

        case "equipment bind upgrade":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::super_refs())
                self add_option(cicada_catalog::pretty(ref, "super"), "^:" + ref, &cicada_mods::set_equipment_bind, ref, "super");
            break;

        case "equipment bind weapon":
            self.bind_index = false;
            self add_menu(menu);
            foreach (item in cicada_catalog::get("equipment"))
                self add_option(item.name, "^:" + item.id, &cicada_mods::set_equipment_bind, item.id, "weapon");
            break;

        case "bolt movement settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("bot bolt movement", self cicada_movement::summary("bot_bolt"), &new_menu, "bot bolt movement settings");
            self add_option("agent bolt movement", self cicada_movement::summary("agent_bolt"), &new_menu, "agent bolt movement settings");
            self add_option("zombie bolt movement", self cicada_movement::summary("zombie_bolt"), &new_menu, "zombie bolt movement settings");
            self add_increment("bolt speed", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("bolt_speed"), 0.1, 10, 0.1, "bolt_speed");
            self add_option("save bolt", self cicada_movement::summary("bolt"), &cicada_movement::save_point, "bolt");
            self add_option("delete last bolt", self cicada_movement::summary("bolt"), &cicada_movement::delete_point, "bolt");
            self add_option("play bolt", self cicada_movement::summary("bolt"), &cicada_movement::play_bolt);
            break;

        case "bot bolt movement settings":
            self.bind_index = false;
            self add_menu(menu);
            self ai_bolt_options("bot", increments);
            break;

        case "agent bolt movement settings":
            self.bind_index = false;
            self add_menu(menu);
            self ai_bolt_options("agent", increments);
            break;

        case "zombie bolt movement settings":
            self.bind_index = false;
            self add_menu(menu);
            self ai_bolt_options("zombie", increments);
            break;

        case "record movement settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("record movement", self cicada_movement::summary("record"), &cicada_movement::record_movement);
            self add_option("delete last point", self cicada_movement::summary("record"), &cicada_movement::delete_point, "record");
            self add_option("reset points", self cicada_movement::summary("record"), &cicada_movement::clear_points, "record");
            self add_option("play movement", self cicada_movement::summary("record"), &cicada_movement::play_record);
            break;

        case "class change settings":
            self.bind_index = false;
            self add_menu(menu);
            self add_increment("class wrap", increments, &cicada_mods::set_value, self cicada_util::getpersint("class_wrap"), 1, 10, 1, "class_wrap");
            self add_state("one bullet left", undefined, "class_one_bullet");
            self add_state("empty clip", undefined, "class_empty_clip");
            self add_state("illusion", undefined, "class_illusion");
            self add_state("canswap", undefined, "class_canswap");
            self add_option("set anim", (istrue(self cicada_util::getpers("class_anim")) ? ("^:anim " + self cicada_util::getpersint("class_anim_id") + " ^7on ^:" + self cicada_util::getpers("class_anim_hands") + " ^7hands") : "^1off"), &new_menu, "class change anim");
            break;

        case "class change anim":
            self.bind_index = false;
            self add_menu(menu);
            self add_state("set anim", undefined, "class_anim");
            self add_increment("anim id", "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to pick, ^5[{+gostand}] ^7to preview", &cicada_mods::set_class_anim, self cicada_util::getpersint("class_anim_id"), 0, 255, 1, undefined, undefined, &cicada_mods::play_class_anim_once);
            self add_array("hands", sliders, &cicada_mods::set_value, cicada_util::list("right,both"), self cicada_util::getpers("class_anim_hands"), "class_anim_hands");
            self add_option("^:random ^7anim", "picks anim ^:1 ^7to ^:150", &cicada_mods::randomize_anim, "class_anim_id", "class_anim_hands");
            break;

        case "edit velocity":
            self.bind_index = false;
            self add_menu(menu);
            self velocity_options("", increments);
            break;

        case "edit bot velocity":
            self.bind_index = false;
            self add_menu(menu);
            self velocity_options("bot_", increments);
            break;

        case "edit agent velocity":
            self.bind_index = false;
            self add_menu(menu);
            self velocity_options("agent_", increments);
            break;

        case "edit zombie velocity":
            self.bind_index = false;
            self add_menu(menu);
            self velocity_options("zombie_", increments);
            break;

        case "class manager":
            self.bind_index = false;
            self add_menu(menu);

            self add_option("^:random ^7class^7", undefined, &new_menu, "random class");
            self add_option("builds " + self accent() + "manager", undefined, &new_menu, "builds manager");
            self add_option("attachment " + self accent() + "manager", "^:" + self cicada_loadout::held_weapons().size + " ^7weapons held", &new_menu, "attachment manager");

            self add_array("drop weapon", sliders, &cicada_mods::drop_weapon, cicada_util::list("current,secondary,all"), "current");
            self add_array("save & load class", sliders, &cicada_loadout::manage_class, cicada_util::list("save,load"), "save");
            self add_array("refill ammo", sliders, &cicada_mods::refill_ammo, cicada_util::list("all,current"), "all");

            self add_feature("infinite equipment", undefined, "inf_equipment");

            self add_option("take weapon", "^:" + self getcurrentweapon().basename, &cicada_mods::take_weapon);
            self add_state("replace weapon", "swaps the current weapon", "replace_weapon");
            self add_option("primaries", "^:" + level.cicada_groups["primaries"].size + " ^7categories", &new_menu, "primaries");
            self add_option("secondaries", "^:" + level.cicada_groups["secondaries"].size + " ^7categories", &new_menu, "secondaries");
            self add_option("streak " + self accent() + "manager^7", undefined, &new_menu, "streaks");
            self add_option("equipment " + self accent() + "manager^7", undefined, &new_menu, "equipment manager");
            self add_option("camo " + self accent() + "manager^7", "currently set: ^:" + self cicada_loadout::camo(), &new_menu, "camo manager");
            break;

        case "camo manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("^:random camo", "currently set: ^:" + self cicada_loadout::camo(), &cicada_loadout::randomize_camo);
            self add_option("clear camo", "currently set: ^:" + self cicada_loadout::camo(), &cicada_loadout::clear_camo);
            foreach (family in cicada_catalog::camo_families())
                self add_option(family, "^:" + cicada_catalog::camos_in(family).size + " ^7camos", &new_menu, family);
            break;

        case "primaries":
        case "secondaries":
            self.bind_index = false;
            self add_menu(menu);
            foreach (category in level.cicada_groups[menu])
                self add_option(category, "^:" + cicada_catalog::count(category) + " ^7weapons available", &new_menu, category);
            break;

        case "random class":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("give ^:random ^7class", undefined, &cicada_loadout::random_class);
            self add_state("give on spawn", undefined, "random_class_auto");
            //self add_state("give streaks", undefined,, "random_class_streaks");
            self add_state("give field upgrade", undefined, "random_class_super");
            self add_state("quick-grip gloves", "faster weapon swap", "random_class_gloves");
            self add_state("use blueprints", "rolls blueprint variants", "random_class_blueprints");
            self add_state("random attachments", "attachments that fit", "random_class_attachments");
            self add_state("random camo", "currently set: ^:" + self cicada_loadout::camo(), "random_class_camo");
            self add_state("no repeats", "no repeat of last class", "random_class_unique");
            self add_array("primary type", sliders, &cicada_loadout::set_random_type, cicada_catalog::with_random(level.cicada_groups["primaries"]), self cicada_util::getpers("random_primary"), "random_primary");
            self add_array("secondary type", sliders, &cicada_loadout::set_random_type, cicada_catalog::with_random(level.cicada_groups["secondary types"]), self cicada_util::getpers("random_secondary"), "random_secondary");
            self add_array("lethal type", sliders, &cicada_loadout::set_random_type, cicada_catalog::with_random(cicada_catalog::equipment_refs("primary")), self cicada_util::getpers("random_lethal"), "random_lethal");
            self add_array("tactical type", sliders, &cicada_loadout::set_random_type, cicada_catalog::with_random(cicada_catalog::equipment_refs("secondary")), self cicada_util::getpers("random_tactical"), "random_tactical");
            break;

        case "equipment manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("replace ^2lethal^7", "^:" + cicada_catalog::equipment_refs("primary").size + " ^7lethals loaded", &new_menu, "replace lethal");
            self add_option("replace ^1tactical^7", "^:" + cicada_catalog::equipment_refs("secondary").size + " ^7tacticals loaded", &new_menu, "replace tactical");
            self add_option("give ^5field upgrade^7", "^:" + cicada_catalog::super_refs().size + " ^7upgrades loaded", &new_menu, "give field upgrade");
            break;

        case "replace lethal":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::equipment_refs("primary"))
                self add_option(cicada_catalog::pretty(ref, "equip"), "^:" + ref, &cicada_loadout::set_equipment, ref, "primary");
            break;

        case "replace tactical":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::equipment_refs("secondary"))
                self add_option(cicada_catalog::pretty(ref, "equip"), "^:" + ref, &cicada_loadout::set_equipment, ref, "secondary");
            break;

        case "give field upgrade":
            self.bind_index = false;
            self add_menu(menu);
            foreach (ref in cicada_catalog::super_refs())
                self add_option(cicada_catalog::pretty(ref, "super"), "^:" + ref, &cicada_loadout::give_field_upgrade, ref);
            break;

        case "streaks":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("mp streaks", "^:" + cicada_catalog::count("mp streaks") + " ^7streaks available", &new_menu, "mp streaks");
            self add_option("warzone extras", "^:" + cicada_catalog::count("warzone extras") + " ^7streaks available", &new_menu, "warzone extras");
            break;

        case "mp streaks":
        case "warzone extras":
            self.bind_index = false;
            self add_menu(menu);
            foreach (streak in cicada_catalog::get(menu == "warzone extras" ? "warzone extras" : "mp streaks"))
                self add_option(streak.name, cicada_catalog::streak_summary(streak), &cicada_loadout::give_streak, streak.id);
            break;

        case "game manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("dvars", undefined, &new_menu, "dvars");
            self add_option("sound " + self accent() + "manager", "play any loaded sound", &new_menu, "sound manager");
            self add_feature("no hud", undefined, "no_hud");
            self add_feature("bounces", "^:" + self cicada_mods::bounce_count() + " ^7saved", "bounce_pads");
            self add_array_pers("bounce manager", sliders, &cicada_mods::manage_bounce, cicada_util::list("save,delete last,clear"), "pick_bounce");
            self add_option("invis crates", "^:" + self cicada_mods::crate_count() + " ^7spawned", &new_menu, "invis crates");
            //self add_option(cicada_util::warn("fast restart"), undefined, &cicada_mods::fast_restart);
            self add_state("button names", "words instead of icons", "bind_names");
            //self add_option("link " + self accent() + "manager", self cicada_link::summary(), &new_menu, "link manager");
            self add_option("^:map restart", "reload map & scripts", &nengine_map_restart);
            self add_state("messages", undefined, "messages");
            self add_state("sounds", "menu sounds etc", "sounds");
            self add_feature("out of bounds off", undefined, "no_oob");
            self add_feature("remove barriers", undefined, "no_barriers");
            self add_feature("round resetting", "randomizes the round score", "round_reset");
            if (istrue(self cicada_util::getpers("round_reset")))
            {
                self add_state("randomize scores", "off uses the highest score", "round_random");
                self add_increment("highest score", increments, &cicada_mods::set_value, self cicada_util::getpersint("round_cap"), 0, 9, 1, "round_cap");
            }
            self add_feature("auto pause timer", "stops the round clock", "auto_pause");
            if (istrue(self cicada_util::getpers("auto_pause")))
            {
                self add_state("randomize pause time", "any point in the limit", "pause_random");
                if (!istrue(self cicada_util::getpers("pause_random")))
                    self add_increment("pause after", increments, &cicada_mods::set_value, self cicada_util::getpersint("pause_after"), 1, 300, 5, "pause_after");
            }
            if (game_utility::getgametype() == "sd")
            {
                self add_feature("freeze round timer", "holds the clock at prematch", "freeze_timer");
                self add_feature("auto plant", "plants before time runs out", "auto_plant");
                if (istrue(self cicada_util::getpers("auto_plant")))
                {
                    self add_increment("plant no sooner than", increments, &cicada_mods::set_value, self cicada_util::getpersint("plant_early"), 1, 60, 1, "plant_early");
                    self add_increment("plant no later than", increments, &cicada_mods::set_value, self cicada_util::getpersint("plant_late"), 1, 60, 1, "plant_late");
                }
                self add_option(cicada_util::warn("end round"), undefined, &cicada_mods::end_round);
            }
            break;

        case "menu manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("layout", "position, spacing and scale", &new_menu, "menu layout");
            // self add_array("font", sliders, &set_layout, cicada_util::list("default,objective,big,small,bold"), self cicada_util::getpers("menu_font"), "menu_font");
            self add_option("menu " + self accent() + "colors", "accent ^:" + self cicada_util::getpers("menu_accent") + " ^7- text ^:" + self cicada_util::getpers("menu_text"), &new_menu, "menu colors");
            self add_option("menu " + self accent() + "controls", ("open " + self control_token("control_hold", "ads") + " " + self control_token("control_open", "actionslot 1")), &new_menu, "menu controls");
            self add_toggle("summaries", "the info line under the menu", self cicada_util::getpers("menu_summary"), &flip_layout, "menu_summary");
            self add_toggle("version text", "build name in the title", self cicada_util::getpers("menu_version"), &flip_layout, "menu_version");
            self add_option(cicada_util::warn("reset menu settings"), undefined, &reset_layout);
            break;

        case "menu controls":
            self.bind_index = false;
            self add_menu(menu);
            self add_array("hold to open", sliders, &cicada_mods::set_control, self control_labels("control_hold"), self control_label(self cicada_util::getpers("control_hold")), "control_hold");
            self add_array("open button", sliders, &cicada_mods::set_control, self control_labels("control_open"), self control_label(self cicada_util::getpers("control_open")), "control_open");
            self add_array("select button", sliders, &cicada_mods::set_control, self control_labels("control_select"), self control_label(self cicada_util::getpers("control_select")), "control_select");
            self add_array("back button", sliders, &cicada_mods::set_control, self control_labels("control_back"), self control_label(self cicada_util::getpers("control_back")), "control_back");
            self add_array("force close button", sliders, &cicada_mods::set_control, self control_labels("control_close"), self control_label(self cicada_util::getpers("control_close")), "control_close");
            self add_option("show the controls", "prints them for you", &print_controls);
            self add_option(cicada_util::warn("reset controls"), undefined, &cicada_mods::reset_controls);
            break;

        case "menu layout":
            self.bind_index = false;
            self add_menu(menu);
            self add_increment("x position", increments, &set_layout, self cicada_util::getpersint("menu_x"), -300, 300, 5, "menu_x");
            self add_increment("y position", increments, &set_layout, self cicada_util::getpersint("menu_y"), -200, 300, 5, "menu_y");
            self add_increment("option spacing", increments, &set_layout, self cicada_util::getpersint("menu_spacing"), 10, 30, 1, "menu_spacing");
            self add_increment("options shown", increments, &set_layout, self cicada_util::getpersint("menu_limit"), 4, 7, 1, "menu_limit");
            self add_increment("font scale", increments, &set_layout, self cicada_util::getpersfloat("menu_scale"), 0.5, 1.5, 0.05, "menu_scale");
            break;

        case "menu colors":
            self.bind_index = false;
            self add_menu(menu);
            self add_array("accent color", sliders, &set_layout, color_names(), self cicada_util::getpers("menu_accent"), "menu_accent");
            self add_array("text color", sliders, &set_layout, color_names(), self cicada_util::getpers("menu_text"), "menu_text");
            self add_array("background color", sliders, &set_layout, color_names(), self cicada_util::getpers("menu_background"), "menu_background");
            break;

        case "dvars":
            self.bind_index = false;
            self add_menu(menu);
            self add_increment("timescale", increments, &cicada_mods::set_timescale, self cicada_util::getpersfloat("timescale"), 0.25, 5, 0.25);
            self add_array("timescale mode", sliders, &cicada_mods::set_timescale_mode, cicada_util::list("normal,round end,start of killcam"), self cicada_util::getpers("timescale_mode"));
            self add_increment("field upgrade recharge", "higher = faster recharge", &cicada_mods::set_super_charge_rate, self cicada_util::getpersint("super_charge_rate"), 0, 100, 5, undefined, undefined, undefined, "x");
            self add_increment("snapshot delay", increments, &cicada_mods::set_snapshot_delay, self cicada_util::getpersint("snapshot_delay"), 0, 5000, 100);
            break;

        case "invis crates":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("invis crate manager", sliders, &cicada_mods::manage_crate, cicada_util::list("spawn,delete last,clear"), "pick_crate");
            self add_increment("spawn distance", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("crate_offset"), -100, 100, 5, "crate_offset");
            self add_increment("spawn height", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("crate_height"), -100, 200, 5, "crate_height");
            self add_feature("preview platforms", "^:" + self cicada_mods::crate_count() + " ^7spawned", "crate_preview");
            self add_increment("preview delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("crate_preview_time"), 0.25, 5, 0.25, "crate_preview_time");
            self add_option("preview effect", "current: ^:" + self cicada_util::getpers("crate_effect"), &cicada_mods::preview_effect, self cicada_util::getpers("crate_effect"));
            self add_option("randomize preview effect", "^:" + cicada_mods::effect_label(self cicada_util::getpers("crate_effect")), &cicada_mods::randomize_effect, "crate_effect");
            break;

        case "model manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_array("spawn model", "^5[{+gostand}] ^7to spawn", &cicada_props::spawn_of_model, cicada_props::model_labels(), cicada_props::model_label(self cicada_util::getpers("prop_model")), "prop_model");
            self add_option("spawn random model", "picks any model in the list", &cicada_props::spawn_random);
            self add_option("manage models", "^:" + cicada_props::count() + " ^7spawned", &new_menu, "manage models");
            self add_option("randomize every model", "^:" + cicada_props::count() + " ^7spawned", &cicada_props::randomize_all);
            self add_option("model paths", self cicada_movement::summary("prop_path"), &new_menu, "model paths");
            self add_increment("spawn height", increments, &cicada_mods::set_value, self cicada_util::getpersfloat("prop_height"), -100, 300, 5, "prop_height");
            self add_increment("path speed", increments, &cicada_mods::set_value, self cicada_util::getpersint("prop_speed"), 25, 1000, 25, "prop_speed");
            self add_state("solid on spawn", "model blocks bullets", "prop_solid");
            self add_state("collision on spawn", "clips on new models", "prop_collision");
            self add_option(cicada_util::warn("clear models"), "^:" + cicada_props::count() + " ^7spawned", &cicada_props::clear_props);
            break;

        case "manage models":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_props::count())
                self add_option("^1no models spawned");
            else
                foreach (prop in cicada_props::props())
                    self add_option(cicada_props::prop_name(prop), cicada_props::prop_summary(prop), &new_menu, "model option");
            break;

        case "model option":
            self.bind_index = false;
            self prop_options(self.select_prop, increments, sliders);
            break;

        case "model collision":
            self.bind_index = false;
            self prop_collision_options(self.select_prop, increments);
            break;

        case "model head":
            self.bind_index = false;
            self prop_head_options(self.select_prop, sliders);
            break;

        case "model head list":
            self.bind_index = false;
            self add_menu(self.select_head_group);
            for (i = 0; i < cicada_props::head_count(self.select_head_group); i++)
            {
                name = cicada_props::head_at(self.select_head_group, i);
                self add_option(cicada_props::head_label(name), "^:attaches to the model", &cicada_props::set_head, name, self.select_prop);
            }
            break;

        case "model paths":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("save point", self cicada_movement::summary("prop_path"), &cicada_movement::save_point, "prop_path");
            self add_option("delete last point", self cicada_movement::summary("prop_path"), &cicada_movement::delete_point, "prop_path");
            self add_option("reset points", self cicada_movement::summary("prop_path"), &cicada_movement::clear_points, "prop_path");
            self add_toggle("show waypoints", undefined, cicada_movement::markers_on("prop_path"), &cicada_movement::toggle_markers, "prop_path");
            self add_state("loop paths", undefined, "prop_path_loop");
            self add_state("face next point", undefined, "prop_path_face");
            self add_state("path messages", undefined, "path_debug");
            break;

        case "zombies & actors":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("manage zombies", "^:" + cicada_pve::horde_count() + " ^7alive", &new_menu, "manage zombies");
            self add_option("actor " + self accent() + "manager", "^:" + cicada_pve::actor_count() + " ^7types loaded", &new_menu, "actor manager");
            self add_option("zombie paths", self cicada_movement::summary("zombie_path"), &new_menu, "zombie & actor paths");
            self add_feature("zombie horde", "keeps zombies spawning", "pve");
            self add_toggle("zombie killcams", undefined, self cicada_util::getpers("pve_killcam"), &cicada_pve::flip_value, "pve_killcam");
            self add_array("spawn type", "^5[{+gostand}] ^7to spawn", &cicada_pve::spawn_of_type, cicada_pve::type_names(), self cicada_util::getpers("pve_spawn_type"), "pve_spawn_type");
            self add_array("actor type", "^5[{+gostand}] ^7to spawn", &cicada_pve::spawn_of_actor, cicada_pve::actor_labels(), cicada_pve::actor_label(self cicada_util::getpers("pve_actor_type")), "pve_actor_type");
            self add_toggle("kill score", "points on a zombie kill", self cicada_util::getpers("pve_score"), &cicada_pve::flip_value, "pve_score");
            self add_toggle("save zombies", "keeps them for next round", self cicada_util::getpers("pve_save_state"), &cicada_pve::flip_value, "pve_save_state");
            self add_toggle("autosave zombies", "saves every edit as you go", self cicada_util::getpers("pve_autosave"), &cicada_pve::flip_value, "pve_autosave");
            self add_toggle("auto respawn", "respawns it with its settings", self cicada_util::getpers("pve_respawn"), &cicada_pve::flip_value, "pve_respawn");
            self add_increment("respawn delay", increments, &cicada_pve::set_value, self cicada_util::getpersfloat("pve_respawn_delay"), 0.5, 30, 0.5, "pve_respawn_delay");
            self add_array_pers("zombie state", sliders, &cicada_pve::manage_state, cicada_util::list("save,load,clear"), "pick_state");
            self add_option(cicada_util::warn("clear zombies"), "^:" + cicada_pve::horde_count() + " ^7alive", &cicada_pve::clear_horde);
            self add_array("horde type", sliders, &cicada_pve::set_value, cicada_pve::type_names(), self cicada_util::getpers("pve_type"), "pve_type");
            self add_array("zombie speed", sliders, &cicada_pve::set_value, cicada_util::list("walk,run,sprint"), self cicada_util::getpers("pve_speed"), "pve_speed");
            self add_increment("horde size", increments, &cicada_pve::set_value, self cicada_util::getpersint("pve_max"), 5, 100, 5, "pve_max");
            self add_increment("zombie health", increments, &cicada_pve::set_value, self cicada_util::getpersint("pve_health"), 100, 5000, 25, "pve_health");
            self add_increment("spawn delay", increments, &cicada_pve::set_value, self cicada_util::getpersfloat("pve_delay"), 0.05, 3, 0.05, "pve_delay");
            self add_increment("spawn range", increments, &cicada_pve::set_value, self cicada_util::getpersint("pve_range"), 300, 3000, 100, "pve_range");
            self add_toggle("radar blips", "zombies on the minimap", self cicada_util::getpers("pve_blip"), &cicada_pve::flip_value, "pve_blip");
            self add_toggle("snipers one shot", "any sniper hit kills a zombie", self cicada_util::getpers("pve_snipers"), &cicada_pve::flip_value, "pve_snipers");
            self add_increment("armed chance", "^7% spawning armed", &cicada_pve::set_value, self cicada_util::getpersint("pve_weapon_chance"), 0, 100, 5, "pve_weapon_chance");
            self add_increment("killstreak chance", "^7% with a killstreak", &cicada_pve::set_value, self cicada_util::getpersint("pve_streak_chance"), 0, 100, 5, "pve_streak_chance");
            self add_toggle("arm armored zombies", undefined, self cicada_util::getpers("pve_arm_armored"), &cicada_pve::flip_value, "pve_arm_armored");
            self add_increment("boss chance", "^7% spawning as a boss", &cicada_pve::set_value, self cicada_util::getpersint("pve_boss_chance"), 0, 100, 5, "pve_boss_chance");
            self add_increment("boss health", increments, &cicada_pve::set_value, self cicada_util::getpersint("pve_boss_health"), 500, 25000, 500, "pve_boss_health");
            self add_array("on boss death", sliders, &cicada_pve::set_value, cicada_pve::boss_actions(), self cicada_util::getpers("pve_boss_death"), "pve_boss_death");
            break;

        case "actor manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_array("actor type", "^5[{+gostand}] ^7to spawn", &cicada_pve::spawn_of_actor, cicada_pve::actor_labels(), cicada_pve::actor_label(self cicada_util::getpers("pve_actor_type")), "pve_actor_type");
            self add_option("spawn this actor", "^:" + cicada_pve::actor_label(self cicada_util::getpers("pve_actor_type")), &cicada_pve::spawn_chosen_actor);
            self add_option("spawn random actor", "^:" + cicada_pve::actor_count() + " ^7types loaded", &cicada_pve::random_actor);
            self add_option("kill agents", "^:" + self cicada_util::getpers("kill_agent_mode"), &cicada_binds::kill_agents);
            self add_option("manage actors", "^:" + cicada_pve::live_actor_count() + " ^7alive", &new_menu, "manage actors");
            self add_option("actor paths", self cicada_movement::summary("zombie_path"), &new_menu, "zombie & actor paths");
            self add_array_pers("actor state", sliders, &cicada_pve::manage_state, cicada_util::list("save,load,clear"), "pick_state");
            self add_toggle("auto respawn", "respawns it with its settings", self cicada_util::getpers("pve_respawn"), &cicada_pve::flip_value, "pve_respawn");
            self add_increment("respawn delay", increments, &cicada_pve::set_value, self cicada_util::getpersfloat("pve_respawn_delay"), 0.5, 30, 0.5, "pve_respawn_delay");
            self add_option(cicada_util::warn("clear actors"), "^:" + cicada_pve::live_actor_count() + " ^7alive", &cicada_pve::clear_actors);
            break;

        case "manage zombies":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_pve::horde_count())
                self add_option("^1no zombies alive");
            else
                foreach (zombie in cicada_pve::horde())
                    self add_option(cicada_pve::zombie_name(zombie), "^:" + zombie.health + " ^7hp", &new_menu, "zombie option");
            break;

        case "manage actors":
            self.bind_index = false;
            self add_menu(menu);
            if (!cicada_pve::live_actor_count())
                self add_option("^1no actors alive");
            else
                foreach (zombie in cicada_pve::actors())
                    self add_option(cicada_pve::zombie_name(zombie), "^:" + zombie.health + " ^7hp", &new_menu, "zombie option");
            break;

        case "zombie option":
            self.bind_index = false;
            self zombie_options(self.select_zombie, increments, sliders);
            break;

        case "sound manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("replay last", "^:" + self cicada_mods::sound_label(self cicada_util::getpers("last_sound")), &cicada_mods::replay_sound);
            foreach (group in cicada_catalog::sound_groups())
                self add_option(group, "^:" + cicada_catalog::sound_count(group) + " ^7loaded", &new_menu, "sound list");
            break;

        case "sound list":
            self.bind_index = false;
            self add_menu(self.select_sound_group);
            self add_option("play a random one", "^:" + cicada_catalog::sound_count(self.select_sound_group) + " ^7loaded", &cicada_mods::preview_random_sound, self.select_sound_group);
            for (i = 0; i < cicada_catalog::sound_count(self.select_sound_group); i++)
            {
                name = cicada_catalog::sound_at(self.select_sound_group, i);
                self add_option(self cicada_mods::sound_label(name), undefined, &cicada_mods::preview_sound, name);
            }
            break;

        case "killcam manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_increment("killcam time", increments, &cicada_killcam::set_time, getdvarfloat("scr_killcam_time", 5), 5, 10, 1);
            self add_feature("target selecting", "only calls on selected", "kill_target");
            self add_state("hide weapon & items", undefined, "hide_weapon");
            self add_state("hide victim", undefined, "hide_victim");
            self add_state("hide perks", undefined, "hide_perks");
            self add_state("hide attachments", undefined, "hide_attachments");
            self add_state("hide equipment", undefined, "hide_equipment");
            self add_state("hide field upgrade", undefined, "hide_field_upgrade");
            break;

        case "session manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_array_pers("session manager", cicada_session::autosave_on() ? ("^7acts on ^:" + cicada_session::autosave_name()) : sliders, &cicada_session::manage, cicada_util::list("save new,save current,reset current,clear all,preview"), "pick_session");
            self add_toggle("autosave", "keeps ^:autosave ^7current", self cicada_util::getpers("session_autosave"), &cicada_session::flip_auto, "session_autosave");
            self add_toggle("autoload", "loads ^:autosave ^7on join", self cicada_util::getpers("session_autoload"), &cicada_session::flip_auto, "session_autoload");
            for (i = 0; i < cicada_session::count(); i++)
            {
                name = cicada_session::name_at(i);
                self add_option(name, cicada_session::summary(name), &new_menu, "session option");
            }
            break;

        case "session option":
            self.bind_index = false;
            self add_menu(self.select_session);
            if (cicada_session::autosave_on() && self.select_session != cicada_session::autosave_name())
                self add_option(cicada_util::warn("autosave is on"), "autosave blocks edits");
            self add_option("load session", "^1overwrites ^7your settings", &cicada_session::load_selected);
            self add_option("save over session", undefined, &cicada_session::save_selected);
            self add_option("preview session", undefined, &cicada_session::preview_selected);
            if (cicada_session::map_count(self.select_session))
                self add_option("map settings", "^:" + cicada_session::map_count(self.select_session) + " ^7maps stored", &new_menu, "session maps");
            if (self.select_session != cicada_session::autosave_name())
                self add_toggle("auto-load session", undefined, cicada_session::is_default(self.select_session), &cicada_session::toggle_default);
            self add_option(cicada_util::warn("delete session"), undefined, &cicada_session::delete_selected);
            break;

        case "session maps":
            self.bind_index = false;
            self add_menu(self.select_session);
            for (i = 0; i < cicada_session::map_count(self.select_session); i++)
            {
                map = cicada_session::map_at(self.select_session, i);
                self add_option(cicada_session::map_label(map), cicada_session::map_summary(self.select_session, map), &new_menu, "map option");
            }
            break;

        case "map option":
            self.bind_index = false;
            self add_menu(cicada_session::map_label(self.select_map));
            self add_option("print settings", cicada_session::map_summary(self.select_session, self.select_map), &cicada_session::preview_selected_map);
            if (!cicada_session::is_current_map(self.select_map))
                self add_option("copy onto this map", undefined, &cicada_session::copy_selected_map);
            self add_option(cicada_util::warn("delete map settings"), cicada_session::map_summary(self.select_session, self.select_map), &cicada_session::delete_selected_map);
            break;

        case "builds manager":
            self.bind_index = false;
            self add_menu(menu);
            self add_option("save current class", "^:" + cicada_builds::build_count() + " ^7stored", &cicada_builds::new_build);
            for (i = 0; i < cicada_builds::build_count(); i++)
            {
                name = cicada_builds::build_at(i);
                self add_option(name, cicada_builds::build_summary(name), &new_menu, "build option");
            }
            break;

        case "build option":
            self.bind_index = false;
            self add_menu(self.select_build);
            self add_option("give build", "^1replaces ^7your weapons", &cicada_builds::give_build);
            self add_option("save over build", undefined, &cicada_builds::save_over_build);
            self add_toggle("give on every spawn", undefined, cicada_builds::build_is_default(self.select_build), &cicada_builds::toggle_build_default);
            self add_option(cicada_util::warn("delete build"), undefined, &cicada_builds::delete_build);
            break;

        case "manage clients":
            self.bind_index = false;
            self add_menu(menu);
            for (i = 0; i < level.players.size; i++)
            {
                client = level.players[i];
                self add_option(self cicada_mods::team_color(client) + client cicada_util::player_name(), (cicada_util::is_bot(client) ? "^7bot - " : "^7player - ") + self cicada_mods::team_label(client), &new_menu, "player option");
            }
            break;

        case "player option":
            self.bind_index = false;
            self player_options(self.select_player, sliders);
            break;

        default:
            if (isdefined(level.cicada_catalog[menu]))
            {
                self add_menu(menu);
                foreach (weapon in cicada_catalog::get(menu))
                    self add_option(weapon.name, "^:" + weapon.id, &cicada_loadout::give_weapon, weapon.id);
            }
            else if (isdefined(level.cicada_camo_sets[menu]))
            {
                self add_menu(menu);
                foreach (id in cicada_catalog::camos_in(menu))
                    self add_option(cicada_catalog::pretty(id, "camo"), "^:" + id, &cicada_loadout::set_camo, id);
            }
            else if (isdefined(level.cicada_binds[menu]))
            {
                self add_menu(menu);
                self add_bind_slots(menu, increments, sliders);
            }
            else
            {
                self add_menu("error");
                self add_option("unable to load " + menu);
            }
            break;
    }
}

function stack_key(menu)
{
    switch (menu)
    {
        case "kill effect list":
            return "kill_effect";

        case "tracer effect list":
            return "tracer_effect";

        case "enemy effect list":
            return "bot_effect_enemy";

        case "friendly effect list":
            return "bot_effect_friendly";

        case "zombie effect list":
            return "zombie_effect";

        case "teleport effect list":
            return "teleport_effect";

        case "station effect list":
            return cicada_stations::fx_key(self.select_event);

        case "afterhits effect list":
            return "after_effect";

        case "zone effect list":
            return "zone_effect";

        case "wire effect list":
            return "wire_effect";

        case "xrounds effect list":
            return "xrounds_effect";
    }

    return undefined;
}

function stack_options(key, list_menu, increments, sliders)
{
    self add_array_pers("stack manager", sliders, &cicada_mods::manage_stack, cicada_util::list("add current,remove last,clear,randomize"), "pick_stack", key);
    self add_option("add effect", "^:" + cicada_mods::effect_list().size + " ^7effects loaded", &new_menu, list_menu);
    self add_option("preview stack", self cicada_mods::stack_summary(key), &cicada_mods::preview_stack, key);
    self add_increment("random stack size", increments, &cicada_mods::set_value, self cicada_util::getpersint("stack_size"), 1, 10, 1, "stack_size");

    for (i = 0; i < self cicada_mods::stack_count(key); i++)
        self add_option("^:" + (i + 1) + " ^7- " + cicada_mods::effect_label(self cicada_mods::stack_effect(key, i)), "^:stacked effect");
}

function teleport_bind_options(increments, sliders)
{
    mode = self cicada_util::getpers("teleport_mode");

    self add_array("target", sliders, &cicada_mods::set_value, cicada_mods::teleport_targets(), mode, "teleport_mode");
    self add_array("how to pick", sliders, &cicada_mods::set_value, cicada_mods::teleport_picks(), self cicada_util::getpers("teleport_pick"), "teleport_pick");
    self add_option("marked " + mode, self cicada_mods::teleport_summary(mode));
    self add_increment("closest distance", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_near_min"), 0, 1000, 10, "teleport_near_min");
    self add_increment("furthest distance", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_near_max"), 0, 1000, 10, "teleport_near_max");
    self add_increment("drop height", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_height"), 0, 300, 5, "teleport_height");
    self add_state("face the target", undefined, "teleport_face_target");
    self add_option("teleport effects", self cicada_mods::stack_summary("teleport_effect"), &new_menu, "teleport effect stack");
    self add_state("play a sound", "^:" + self cicada_mods::sound_label(self cicada_util::getpers("teleport_sound_name")), "teleport_sound");
    if (istrue(self cicada_util::getpers("teleport_sound")))
        self add_option("choose sound", "^:" + self cicada_mods::sound_label(self cicada_util::getpers("teleport_sound_name")), &new_menu, "teleport sounds");
    self add_state("swap vision", undefined, "teleport_vision");
    self add_state("canswap", undefined, "teleport_canswap");
    self add_state("play anim", undefined, "teleport_anim");
    self add_state("knock yourself back", undefined, "teleport_push");
    if (istrue(self cicada_util::getpers("teleport_push")))
    {
        self add_increment("knockback distance", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_push_power"), 100, 3000, 50, "teleport_push_power");
        self add_increment("knockback lift", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_push_lift"), 0, 1000, 25, "teleport_push_lift");
    }
    self add_state("damage the target", undefined, "teleport_damage");
    if (istrue(self cicada_util::getpers("teleport_damage")))
        self add_increment("damage amount", increments, &cicada_mods::set_value, self cicada_util::getpersint("teleport_damage_amount"), 10, 500, 10, "teleport_damage_amount");
}

function add_bind_slots(name, increments, sliders)
{
    self add_array_live("button", live_slider_hint(), &cicada_binds::set_slot, self cicada_binds::slot_labels(), self cicada_binds::slot_label(self cicada_util::getpers(cicada_binds::slot_key(name))), name);

    if (name == "snapshot delay")
    {
        self add_increment(
            "lag while held",
            increments,
            &cicada_mods::set_value,
            self cicada_util::getpersint("snapshot_bind_delay"),
            0,
            5000,
            100,
            "snapshot_bind_delay"
            );

        self add_increment(
            "seconds held",
            increments,
            &cicada_mods::set_value,
            self cicada_util::getpersfloat("snapshot_bind_time"),
            0.1,
            10,
            0.1,
            "snapshot_bind_time"
            );
    }
    if (name == "kill bots")
    {
        self add_array("target", sliders, &cicada_mods::set_value, cicada_binds::bot_targets(), self cicada_util::getpers("kill_bot_mode"), "kill_bot_mode");

        if (self cicada_util::getpers("kill_bot_mode") == "selected bot")
            self add_array("which bot", sliders, &cicada_mods::set_value, cicada_binds::bot_names(), self cicada_util::getpers("kill_bot_name"), "kill_bot_name");
    }
    if (name == "kill agents")
    {
        self add_array("target", sliders, &cicada_mods::set_value, cicada_binds::agent_targets(), self cicada_util::getpers("kill_agent_mode"), "kill_agent_mode");

        if (self cicada_util::getpers("kill_agent_mode") == "selected agent")
            self add_array("which one", sliders, &cicada_mods::set_value, cicada_binds::agent_names(), self cicada_util::getpers("kill_agent_name"), "kill_agent_name");
    }
    if (name == "teleport near")
        self teleport_bind_options(increments, sliders);
    if (name == "bot velocity" || name == "bot bolt movement")
        self ai_bind_options("bot");
    if (name == "agent velocity" || name == "agent bolt movement")
        self ai_bind_options("agent");
    if (name == "zombie velocity" || name == "zombie bolt movement")
        self ai_bind_options("zombie");
    //if (name == "link ride")
    //{
    //    self add_array("ride what", sliders, &cicada_mods::set_value, cicada_link::targets(), self cicada_util::getpers("link_target"), "link_target");
    //    self add_option("link settings", self cicada_link::summary(), &new_menu, "link manager");
    //}
    if (name == "place station")
    {
        self add_array("what to place", sliders, &cicada_mods::set_value, cicada_stations::kinds(), self cicada_util::getpers("station_kind"), "station_kind");
        self add_option("station settings", self cicada_stations::summary(), &new_menu, "station manager");
    }
    if (name == "parachute")
        self add_option("parachute settings", self cicada_mechanics::summary(), &new_menu, "parachute settings");
    if (name == "knockback")
    {
        self add_increment(
            "knockback distance",
            increments,
            &cicada_mods::set_value,
            self cicada_util::getpersint("knockback_power"),
            100,
            3000,
            50,
            "knockback_power"
            );

        self add_increment(
            "knockback height",
            increments,
            &cicada_mods::set_value,
            self cicada_util::getpersint("knockback_lift"),
            0,
            1500,
            50,
            "knockback_lift"
            );

        self add_state("take the damage", "the shot hurts you as well", "knockback_damage");
    }
    if (cicada_binds::is_anim_slot(name))
    {
        index = cicada_binds::anim_slot_index(name);

        self add_increment(
            "anim id",
            "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to pick, ^5[{+gostand}] ^7to preview",
            &cicada_mods::set_anim_slot_id,
            self cicada_mods::anim_slot_id(index),
            0,
            255,
            1,
            index,
            undefined,
            &cicada_mods::preview_anim_slot
            );

        self add_array("hands", sliders, &cicada_mods::set_anim_slot_hands, cicada_util::list("right,both"), self cicada_mods::anim_slot_hands(index), index);
        self add_option("^:random ^7anim", "picks anim ^:1 ^7to ^:150", &cicada_mods::randomize_anim_slot, index);
        self add_state("always random", self toggle_summary(cicada_mods::anim_slot_key(index, "random"), self cicada_mods::anim_slot_range_summary(index)), cicada_mods::anim_slot_key(index, "random"));
        if (istrue(self cicada_util::getpers(cicada_mods::anim_slot_key(index, "random"))))
        {
            self add_state("randomize range", "^:1 ^7to ^:150 ^7when on", cicada_mods::anim_slot_key(index, "range"));
            if (!istrue(self cicada_util::getpers(cicada_mods::anim_slot_key(index, "range"))))
            {
                self add_increment("lowest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint(cicada_mods::anim_slot_key(index, "min")), 1, 255, 1, cicada_mods::anim_slot_key(index, "min"));
                self add_increment("highest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint(cicada_mods::anim_slot_key(index, "max")), 1, 255, 1, cicada_mods::anim_slot_key(index, "max"));
            }
        }
        self add_option("remove this slot", "clears its anim and button", &cicada_mods::remove_anim_slot, index);
    }

    if (name == "play anim")
    {
        self add_increment(
            "anim id",
            "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to pick, ^5[{+gostand}] ^7to preview",
            &cicada_mods::set_anim,
            self cicada_util::getpersint("anim_id"),
            0,
            255, // max anims usually
            1,
            undefined,
            undefined,
            &cicada_mods::play_anim_once
            );

        self add_array(
            "hands",
            sliders,
            &cicada_mods::set_anim_hands,
            cicada_util::list("right,both"),
            self cicada_util::getpers("anim_hands")
            );

        self add_option("^:random ^7anim", "picks anim ^:1 ^7to ^:150", &cicada_mods::randomize_anim, "anim_id", "anim_hands");
        self add_state("always random", self toggle_summary("anim_random", self cicada_mods::anim_range_summary("anim_random", "anim_random_range", "anim_min", "anim_max")), "anim_random");
        if (istrue(self cicada_util::getpers("anim_random")))
        {
            self add_state("randomize range", "^:1 ^7to ^:150 ^7when on", "anim_random_range");
            if (!istrue(self cicada_util::getpers("anim_random_range")))
            {
                self add_increment("lowest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint("anim_min"), 1, 255, 1, "anim_min");
                self add_increment("highest anim", increments, &cicada_mods::set_value, self cicada_util::getpersint("anim_max"), 1, 255, 1, "anim_max");
            }
        }
    }

    if (name == "play gesture")
    {
        gestures = cicada_catalog::gestures();

        if (!gestures.size)
            self add_option("^1no gestures loaded");
        else
            self add_increment(
                "gesture id",
                "^:" + gestures.size + " ^7loaded - ^5[{+gostand}] ^7to preview",
                &cicada_mods::set_gesture,
                self cicada_util::getpersint("gesture_id"),
                0,
                gestures.size - 1,
                1,
                undefined,
                undefined,
                &cicada_mods::play_gesture_once
                );
    }
}

function position_options(increments)
{
    origin = self cicada_util::getmappers("position");
    step = self cicada_util::getpersfloat("position_step");

    self add_increment("change x", increments, &cicada_mods::nudge_position, origin[0], -100000, 100000, step, "x");
    self add_increment("change y", increments, &cicada_mods::nudge_position, origin[1], -100000, 100000, step, "y");
    self add_increment("change z", increments, &cicada_mods::nudge_position, origin[2], -100000, 100000, step, "z");
    self add_increment("change by", increments, &cicada_mods::set_value, step, 1, 500, 1, "position_step");
}

function ai_bolt_options(kind, increments)
{
    key = cicada_movement::bolt_key(kind);

    self add_increment(kind + " bolt speed", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(kind + "_bolt_speed"), 0.1, 10, 0.1, kind + "_bolt_speed");
    self add_option("save point", self cicada_movement::summary(key), &cicada_movement::save_point, key);
    self add_option("delete last point", self cicada_movement::summary(key), &cicada_movement::delete_point, key);
    self add_option(cicada_util::warn("clear points"), self cicada_movement::summary(key), &cicada_movement::clear_points, key);
    self add_option("play now", self cicada_movement::summary(key), &cicada_movement::play_ai_bolt, kind);
    self ai_bind_options(kind);
}

function ai_target_menu(kind)
{
    if (kind == "bot")
        return "manage clients";

    return (kind == "agent") ? "manage actors" : "manage zombies";
}

function ai_bind_options(kind)
{
    self add_state("pick one " + kind, "off sends it to every " + kind, cicada_mods::ai_pick_key(kind));
    self add_option("bind target", self cicada_mods::ai_target_summary(kind), &new_menu, ai_target_menu(kind));
}

function toggle_summary(key, summary)
{
    if (!istrue(self cicada_util::getpers(key)))
        return undefined;

    return summary;
}

function afterhits_part(name, summary, page, increments)
{
    self add_state(cicada_afterhits::part_label(name), self toggle_summary("after_" + name + "_on", summary), "after_" + name + "_on");

    if (!istrue(self cicada_util::getpers("after_" + name + "_on")))
        return;

    self add_option(cicada_afterhits::part_choice(name), summary, &new_menu, page);
    self add_increment("^7- delay", increments, &cicada_mods::set_value, self cicada_util::getpersfloat(cicada_afterhits::part_delay_key(name)), 0, 20, 0.05, cicada_afterhits::part_delay_key(name));
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
    if (prefix == "")
        self add_option("play velocity", summary, &cicada_mods::play_velocity);
    else
        self add_option("play velocity", summary, &cicada_mods::play_ai_velocity, cicada_util::trim_end(prefix, "_"));

    if (prefix == "")
        return;

    kind = cicada_util::trim_end(prefix, "_");

    self add_increment("teleport back time", "^:0 ^7leaves it there", &cicada_mods::set_value, self cicada_util::getpersfloat(prefix + "return_time"), 0, 30, 0.5, prefix + "return_time");
    self ai_bind_options(kind);
}

function player_options(player, sliders)
{
    if (!isdefined(player) || !isplayer(player))
    {
        self add_menu("error");
        self add_option("no client selected");
        return;
    }

    self add_menu(self cicada_mods::team_color(player) + player cicada_util::player_name());
    self add_option("kill", undefined, &cicada_mods::kill_player, player);
    self add_option("respawn", player cicada_mods::has_position() ? "puts them back on their spot" : undefined, &cicada_mods::respawn_player, player);
    if (cicada_mods::may_auto_respawn(player))
        self add_toggle("auto respawn", "^:" + self cicada_util::getpersfloat("bot_respawn_delay") + "s ^7after they die", cicada_mods::is_auto_respawn(player), &cicada_mods::toggle_auto_respawn, player);
    self add_option("change team", "currently " + self cicada_mods::team_label(player), &cicada_mods::change_team, player);
    if (istrue(self cicada_util::getpers("kill_target")))
        self add_toggle("final killcam target", "others respawn until it dies", cicada_mods::is_kill_target(player), &cicada_mods::toggle_kill_target, player);
    self add_toggle("freeze controls", undefined, cicada_mods::is_frozen(player), &cicada_mods::toggle_freeze, player);
    self add_toggle("teleport near target", "for the teleport near bind", cicada_mods::is_teleport_target(player), &cicada_mods::toggle_teleport_target, player);
    if (cicada_util::is_bot(player))
        self add_toggle("bind target", "for the bot velocity and bolt binds", cicada_mods::is_ai_target(player), &cicada_mods::toggle_ai_target, player);
    self add_array_pers("teleport", sliders, &cicada_mods::manage_teleport, cicada_util::list("to crosshair,to me,to them"), "pick_teleport", player);

    if (!cicada_util::is_bot(player))
        return;

    self add_option("look at me", undefined, &cicada_mods::look_at_me, player);
    self add_option("give my weapon", "^:" + self getcurrentweapon().basename, &cicada_mods::give_bot_weapon, player, self getcurrentweapon());
    self add_option("give shield", undefined, &cicada_loadout::give_bot_shield, player);
    self add_option("apply ^:random camo", "currently set: ^:" + player cicada_loadout::camo(), &cicada_loadout::randomize_camo, player);
}

function prop_options(prop, increments, sliders)
{
    if (!isdefined(prop))
    {
        self add_menu("error");
        self add_option("^1that model is gone");
        return;
    }

    self add_menu(cicada_props::prop_name(prop));
    self add_array("model", sliders, &cicada_props::set_prop_model, cicada_props::model_labels(), cicada_props::model_label(prop.cicada_prop_model), prop);
    self add_option("random model", cicada_props::prop_summary(prop), &cicada_props::randomize_prop, prop);
    self add_array_pers("teleport", sliders, &cicada_props::move_prop, cicada_util::list("to crosshair,to me,to them"), "pick_teleport", prop);
    self add_option("face me", undefined, &cicada_props::face_me, prop);
    self add_increment("height", increments, &cicada_props::raise_prop, cicada_props::prop_raise(prop), -300, 300, 5, prop);
    self add_increment("rotation", increments, &cicada_props::turn_prop, cicada_props::prop_yaw(prop), 0, 355, 5, prop);
    self add_toggle("spin", "turns the model on the spot", cicada_props::is_spinning(prop), &cicada_props::toggle_spin, prop);
    self add_toggle("solid", "model blocks bullets", cicada_props::is_solid(prop), &cicada_props::toggle_solid, prop);
    self add_option("collision", cicada_props::has_collision(prop) ? ("^:" + cicada_props::clip_count(prop) + " ^7clips - ^:" + cicada_props::clip_kind(prop)) : "^1no collision", &new_menu, "model collision");
    self add_option("head", cicada_props::head_summary(prop), &new_menu, "model head");
    self add_toggle("carry", "holds it in front of you", cicada_props::is_linked(prop), &cicada_props::toggle_link, prop);
    self add_toggle("path movement", self cicada_movement::summary("prop_path"), cicada_props::is_moving(prop), &cicada_props::start_prop_path, prop);
    self add_option(cicada_util::warn("delete model"), cicada_props::prop_summary(prop), &cicada_props::delete_prop, prop);
}

function prop_head_options(prop, sliders)
{
    if (!isdefined(prop))
    {
        self add_menu("error");
        self add_option("^1that model is gone");
        return;
    }

    self add_menu(cicada_props::prop_name(prop));
    self add_array("how to pick", sliders, &cicada_props::set_head_mode, cicada_props::head_modes(), cicada_props::head_mode(prop), prop);
    self add_option("what it found", cicada_props::head_label(cicada_props::head_for_body(prop.cicada_prop_model)), &cicada_props::set_head_mode, "automatic", prop);
    self add_option("^:random ^7head", cicada_props::head_summary(prop), &cicada_props::random_head, prop);
    self add_option(cicada_util::warn("no head"), undefined, &cicada_props::clear_head, prop);

    foreach (group in cicada_props::head_groups())
        self add_option(group, "^:" + cicada_props::head_count(group) + " ^7loaded", &new_menu, "model head list");
}

function prop_collision_options(prop, increments)
{
    if (!isdefined(prop))
    {
        self add_menu("error");
        self add_option("^1that model is gone");
        return;
    }

    self add_menu(cicada_props::prop_name(prop));
    self add_toggle("collision box", "stand on it - ^:" + cicada_props::clip_kind(prop), cicada_props::has_collision(prop), &cicada_props::toggle_collision, prop);
    self add_increment("height", increments, &cicada_props::raise_clip, cicada_props::clip_height(prop), -200, 200, 4, prop);
    self add_increment("width", "clips per side - ^:" + cicada_props::clip_count(prop), &cicada_props::set_clip_width, cicada_props::clip_width(prop), 1, 7, 1, prop);
    self add_increment("layers", "clips stacked - ^:" + cicada_props::clip_count(prop), &cicada_props::set_clip_layers, cicada_props::clip_layers(prop), 1, 7, 1, prop);
    self add_increment("spacing", "gap between each clip", &cicada_props::set_clip_spacing, cicada_props::clip_spacing(prop), 8, 128, 4, prop);
}

function zombie_options(zombie, increments, sliders)
{
    if (!isdefined(zombie) || !isalive(zombie))
    {
        self add_menu("error");
        self add_option("^1that zombie is gone");
        return;
    }

    self add_menu(cicada_pve::zombie_name(zombie));
    self add_option("kill", "^:" + zombie.health + " ^7hp", &cicada_pve::kill_zombie, zombie);
    self add_option("send at me", "paths it straight to you", &cicada_pve::send_at_me, zombie);
    self add_option("look at me", undefined, &cicada_pve::look_at_me, zombie);
    self add_toggle("freeze", "pins it in place & blinds it", cicada_pve::is_frozen(zombie), &cicada_pve::toggle_freeze, zombie);
    self add_array_pers("teleport", sliders, &cicada_pve::manage_teleport, cicada_util::list("to crosshair,to me,to them"), "pick_teleport", zombie);
    self add_array("speed", sliders, &cicada_pve::set_zombie_speed, cicada_util::list("walk,run,sprint"), cicada_pve::zombie_speed(zombie), zombie);
    self add_increment("health", increments, &cicada_pve::set_zombie_health, zombie.health, 25, 5000, 25, zombie);
    if (!cicada_pve::is_hellhound(zombie))
    {
        self add_option("give my weapon", "^:" + self getcurrentweapon().basename, &cicada_pve::give_my_weapon, zombie);
        self add_option("give random weapon", undefined, &cicada_pve::give_random_weapon, zombie);
        self add_option("give killstreak weapon", "minigun & friends", &cicada_pve::give_streak_weapon, zombie);
        self add_option("take weapon", undefined, &cicada_pve::take_weapon, zombie);
    }
    self add_toggle("boss", "its death ends the round", cicada_pve::is_boss(zombie), &cicada_pve::toggle_boss, zombie);
    self add_toggle("final killcam target", "its death ends on killcam", cicada_pve::is_killcam_target(zombie), &cicada_pve::toggle_killcam_target, zombie);
    self add_toggle("teleport near target", "for the teleport near bind", cicada_mods::is_teleport_target(zombie), &cicada_mods::toggle_teleport_target, zombie);
    self add_toggle("bind target", "for the " + cicada_mods::ai_class(zombie) + " velocity and bolt binds", cicada_mods::is_ai_target(zombie), &cicada_mods::toggle_ai_target, zombie);
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

    if (!isdefined(self.slider_kept))
        self.slider_kept = [];

    if (isdefined(menu))
        self.slider_kept[menu] = false;
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

function add_increment(text, summary, func, start, minimum, maximum, step, argument_1, argument_2, select_function, value_prefix)
{
    option                    = [];
    option["text"]            = text;
    option["summary"]         = summary;
    option["function"]        = func;
    option["slider"]          = true;
    option["is_increment"]    = true;
    option["start"]           = start;
    option["minimum"]         = minimum;
    option["maximum"]         = maximum;
    option["increment"]       = step;
    option["argument_1"]      = argument_1;
    option["argument_2"]      = argument_2;
    option["select_function"] = select_function;
    option["value_prefix"]    = value_prefix;

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

function live_slider_hint()
{
    return "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to turn off";
}

function add_array_pers(text, summary, func, array, key, argument_1, argument_2)
{
    self add_array(text, summary, func, array, self cicada_util::getpers(key), argument_1, argument_2);
    self.structure[self.structure.size - 1]["remember"] = key;
}

function remember_slider(cursor)
{
    key = self.structure[cursor]["remember"];

    if (!isdefined(key) || !isdefined(self.structure[cursor]["array"]))
        return;

    value = self.structure[cursor]["array"][self.slider[self get_menu() + "_" + cursor]];

    if (isdefined(value))
        self cicada_util::setpers(key, value);
}

function add_array_live(text, summary, func, array, current, argument_1, argument_2)
{
    self add_array(text, summary, func, array, current, argument_1, argument_2);
    self.structure[self.structure.size - 1]["live"] = true;
}

function slider_text(index)
{
    storage = (self get_menu() + "_" + index);

    if (isdefined(self.structure[index]["array"]))
        return slider_fit("" + self.structure[index]["array"][self.slider[storage]]);

    return self value_text(index, self.slider[storage]);
}

function slider_fit(text)
{
    limit = 18;

    if (!isdefined(text) || text.size <= limit)
        return text;

    cut = cicada_util::shorten(text, limit - 2);

    while (cut.size && cut[cut.size - 1] == "^")
        cut = cicada_util::shorten(cut, cut.size - 1);

    return cut + "..";
}

function update_value_text(index)
{
    values = self.menu["hud"]["slider"][0];

    if (!isdefined(values))
        return;

    element = values[index];

    if (!isdefined(element) || !isdefined(element.prefix))
        return;

    element set_text(element.prefix + self slider_text(index));
}

function value_text(index, value)
{
    prefix = self.structure[index]["value_prefix"];
    return isdefined(prefix) ? (prefix + value) : ("" + value);
}

function index_of(array, value)
{
    for (i = 0; i < array.size; i++)
        if (array[i] == value)
            return i;

    return 0;
}

function hold_names()
{
    return cicada_util::list("ads,crouch,none");
}

function open_names()
{
    return cicada_util::list("actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7");
}

function control_names()
{
    return cicada_util::list("use,gostand,stance,usereload,weapnext,melee,melee_zoom,frag,smoke,special");
}

function control_button(key, fallback)
{
    button = self cicada_util::getpers(key);

    return isdefined(button) ? button : fallback;
}

function button_token(button)
{
    if (!isdefined(button) || button == "none")
        return "nothing";

    if (button == "use")
        return "[{+activate}]";

    if (button == "ads")
        return "[{+speed_throw}]";

    if (button == "crouch")
        return "[{+stance}]";

    return "[{+" + button + "}]";
}

function control_token(key, fallback)
{
    return button_token(self control_button(key, fallback));
}

function control_label(button)
{
    if (!isdefined(button))
        return "none";

    if (istrue(self cicada_util::getpers("bind_names")) || button == "none")
        return button;

    return button_token(button);
}

function control_list(key)
{
    if (key == "control_hold")
        return hold_names();

    if (key == "control_open")
        return open_names();

    return control_names();
}

function control_labels(key)
{
    labels = [];

    foreach (button in control_list(key))
        labels[labels.size] = self control_label(button);

    return labels;
}

function control_from_label(label, key)
{
    names = control_list(key);

    foreach (button in names)
        if (self control_label(button) == label)
            return button;

    return names[0];
}

function control_pressed(key, fallback)
{
    button = self control_button(key, fallback);

    if (button == "none")
        return true;

    if (button == "use")
        return self usebuttonpressed();

    if (button == "ads")
        return self adsbuttonpressed();

    return self cicada_util::isbuttonpressed("+" + button);
}

function open_pressed()
{
    if (!self control_pressed("control_hold", "ads"))
        return false;

    return self cicada_util::isbuttonpressed("-" + self control_button("control_open", "actionslot 1"));
}

function print_controls()
{
    self iprintln("^:cicada ^7- hold " + self control_token("control_hold", "ads") + " ^7then press [{+" + self control_button("control_open", "actionslot 1") + "}] ^7to open");
    self iprintln("^7navigate [{+actionslot 1}] [{+actionslot 2}] ^7- slider [{+actionslot 3}] [{+actionslot 4}]");
    self iprintln("^7select " + self control_token("control_select", "gostand") + " ^7- back " + self control_token("control_back", "use") + " ^7- close " + self control_token("control_close", "melee_zoom"));
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
                if (self open_pressed())
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
                if (self control_pressed("control_close", "melee_zoom"))
                {
                    //self thread [[ &play_sound ]]("recondrone_tag");
                    self close_menu();
                }
                else if (self control_pressed("control_back", "use")) // back
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
                        self remember_slider(cursor);

                        if (istrue(self.structure[cursor]["is_increment"]) || istrue(self.structure[cursor]["live"]))
                        {
                            self thread [[&execute_function]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            //self thread [[ &play_sound ]]("ui_mp_weapon_pickup");
                            self cicada_session::autosave();

                            // a live array already shows the value it just wrote
                            if (!istrue(self.structure[cursor]["live"]))
                                self update_menu(menu, cursor);
                        }
                    }
                    wait 0.07;
                }
                else if (self control_pressed("control_select", "gostand"))
                {
                    if (isdefined(self.structure[cursor]["function"]))
                    {
                        if (istrue(self.structure[cursor]["slider"]))
                        {
                            if (istrue(self.structure[cursor]["live"]))
                            {
                                self.slider[menu + "_" + cursor] = 0;
                                self set_slider(undefined, cursor);
                                self thread [[&execute_function]](self.structure[cursor]["function"], self.structure[cursor]["array"][0], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            }
                            else if (istrue(self.structure[cursor]["is_array"]))
                            {
                                self remember_slider(cursor);
                                self thread [[&execute_function]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                                //self thread [[ &play_sound ]]("recondrone_tag");
                            }
                            else if (isdefined(self.structure[cursor]["select_function"]))
                                self thread [[&execute_function]](self.structure[cursor]["select_function"], self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"]);
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

                        self cicada_session::autosave();

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

        self update_value_text(index);
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

        self update_value_text(index);

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

    foreach (entry in array)
    {
        if (isarray(entry))
        {
            foreach (element in entry)
                if (isdefined(element))
                    element destroy_element();
        }
        else if (isdefined(entry))
            entry destroy_element();
    }
}

function close_menu()
{
    self set_procedure();
    self cicada_mods::menu_resume();
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
    if (!isdefined(self.menu["hud"]) || !isdefined(self.menu["hud"]["text"][self get_cursor()]))
        return;

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

    if (self get_menu() == "manage zombies")
        self.select_zombie = cicada_pve::horde_at(self get_cursor());

    if (self get_menu() == "manage actors")
        self.select_zombie = cicada_pve::actor_at(self get_cursor());

    if (self get_menu() == "attachment manager")
        self.select_weapon = self cicada_loadout::held_at(self get_cursor());

    if (self get_menu() == "weapon attachments")
        self.select_slot = self cicada_loadout::slot_at(self.select_weapon, self get_cursor());

    if (self get_menu() == "placed stations")
        self.select_station = cicada_stations::station_at(self get_cursor());

    if (self get_menu() == "afterhits weapon")
        self.select_category = cicada_catalog::weapon_categories()[(self get_cursor() - 2) % cicada_catalog::weapon_categories().size];

    if (self get_menu() == "manage models")
        self.select_prop = cicada_props::prop_at(self get_cursor());

    if (self get_menu() == "model head")
        self.select_head_group = cicada_props::head_groups()[(self get_cursor() - 4) % cicada_props::head_groups().size];

    if (self get_menu() == "station events")
        self.select_event = cicada_stations::kind_events(self cicada_util::getpers("station_kind"))[self get_cursor()];

    if (self get_menu() == "sound manager" || self get_menu() == "teleport sounds")
        self.select_sound_group = cicada_catalog::sound_groups()[self get_cursor() - 1];

    if (self get_menu() == "afterhits sound stack")
        self.select_sound_group = cicada_catalog::sound_groups()[(self get_cursor() - (4 + self cicada_mods::stack_count("after_sound"))) % cicada_catalog::sound_groups().size];

    if (self get_menu() == "station sound stack")
        self.select_sound_group = cicada_catalog::sound_groups()[(self get_cursor() - (4 + self cicada_mods::stack_count(cicada_stations::sound_key(self.select_event)))) % cicada_catalog::sound_groups().size];

    if (self get_menu() == "session manager")
        self.select_session = cicada_session::name_at(self get_cursor() - 3);

    if (self get_menu() == "session maps")
        self.select_map = cicada_session::map_at(self.select_session, self get_cursor());

    if (self get_menu() == "builds manager")
        self.select_build = cicada_builds::build_at(self get_cursor() - 1);

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

    self create_hud();

    self set_menu(menu);
    self set_procedure();
    self cicada_mods::menu_suspend();
    self create_option();

    //self thread [[ &flicker_shaders ]]();

    //is_prematch_done = game["flags"]["prematch_done"];
    //if (is_prematch_done)
    //    setslowmotion_wrapper(1, 1, 0);
}

function create_hud()
{
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

    if (!isdefined(self.slider_kept))
        self.slider_kept = [];

    self.menu["hud"]["title"]        = self create_text("MP/NEURA_TITLE_" + self get_title(), "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 1.75), self.color[4], 1, 10);
    self.menu["hud"]["index"]        = self create_text("MP/NEURA_INDEX_[]", "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 217), (self.y_offset + 1.75), self.color[4], 1, 10);
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
        element.hidewheninmenu = true;
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

function update_index()
{
    if (!isdefined(self.menu["hud"]["index"]))
        return;

    self.menu["hud"]["index"] set_text("MP/NEURA_INDEX_[" + (self get_cursor() + 1) + "/" + self.structure.size + "]");
}

function keep_slider(index, storage)
{
    if (!isdefined(self.structure[index]["array"]))
        return false;

    if (!isdefined(self.slider_kept) || !istrue(self.slider_kept[self get_menu()]))
        return false;

    if (!isdefined(self.slider[storage]))
        return false;

    return self.slider[storage] < self.structure[index]["array"].size;
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
                self.menu["hud"]["submenu"][index] = self create_text("MP/NEURA_ADDITIONAL_>", "MP_INGAME_ONLY/OBJ_HVT_CAPS_17", self.font, 0.65, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), color[0], 1, 10);
            if (isdefined(self.structure[index]["toggle"]))
            {
                self.menu["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 204), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, color[1],.65, 10);
                // self.menu["hud"]["current_toggle_index"] = self.menu["hud"]["toggle"][index];
            }

            if (istrue(self.structure[index]["slider"]))
            {
                storage = (self get_menu() + "_" + index);

                if (!keep_slider(index, storage))
                    self.slider[storage] = self.structure[index]["start"];

                value_slot = "MP/NEURA_STR" + ((i * 2) + 2) + "_";

                if (isdefined(self.structure[index]["array"]))
                    self.menu["hud"]["slider"][0][index] = self create_text(value_slot + self slider_text(index), override_string_for_index((i * 2) + 2), self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 210), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                else
                {
                    self.menu["hud"]["slider"][0][index] = self create_text(value_slot + self slider_text(index), override_string_for_index((i * 2) + 2), self.font, self.font_scale, "CENTER", "TOPCENTER", (self.x_offset + 187), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[4], 1, 10);

                    self.menu["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), 50, 8, cursor ? self.color[2] : self.color[1], 1, 8);
                    self.menu["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 170), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, cursor ? self.color[0] : self.color[3], 1, 9);
                }

                if (isdefined(self.menu["hud"]["slider"][0][index]))
                    self.menu["hud"]["slider"][0][index].prefix = value_slot;

                // idek what this does but Ok
                self set_slider(undefined, index);

                if (!isdefined(self.slider_kept))
                    self.slider_kept = [];

                self.slider_kept[self get_menu()] = true;
            }

            if (istrue(self.structure[index]["category"]))
            {
                og_string = "MP/NEURA_STR" + ((i * 2) + 1) + "_" + tolower(self.structure[index]["text"]);
                override_string = override_string_for_index((i * 2) + 1);

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
                    og_string = "MP/NEURA_STR" + ((i * 2) + 1) + "_" + tolower(self.structure[index]["text"]);
                    override_string = override_string_for_index((i * 2) + 1);

                    self.menu["hud"]["text"][index] = self create_text(og_string, override_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                }
            }
        }

        if (!isdefined(self.menu["hud"]["text"][self get_cursor()]))
            self set_cursor((self.structure.size - 1));
    }

    self update_index();
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

function private nengine_map_restart()
{
    nengine_mr();
}
