#using scripts\cp_mp\damagefeedback;
#using scripts\cp_mp\utility\inventory_utility;
#using scripts\engine\utility;
#using scripts\mp\bots\bots;
#using scripts\mp\class;
#using scripts\mp\flags;
#using scripts\mp\gamelogic;
#using scripts\mp\gamescore;
#using scripts\mp\gamestaterestore;
#using scripts\mp\gametypes\obj_bombzone;
#using scripts\mp\menus;
#using scripts\mp\outofbounds;
#using scripts\mp\perks\perks;
#using scripts\mp\playerlogic;
#using scripts\mp\supers;
#using scripts\mp\utility\game;
#using scripts\mp\utility\perk;
#using scripts\mp\utility\player;

#using custom_scripts\binds;
#using custom_scripts\builds;
#using custom_scripts\catalog;
#using custom_scripts\extras;
#using custom_scripts\leftovers;
//#using custom_scripts\link;
#using custom_scripts\mechanics;
#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\movement;
#using custom_scripts\props;
#using custom_scripts\stations;
#using custom_scripts\pve;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_mods;

function init()
{
    level.cicada_features = [];

    register("invincible", &godmode, &mortal);
    register("ufo_mode", &noclip);
    register("always_nac", &always_nac);
    register("instaswaps", &instaswaps);
    register("elevators", &elevators);
    register("auto_prone", &auto_prone);
    register("auto_reload", &auto_reload);
    register("inf_equipment", &infinite_equipment);
    register("unlimited_lives", &unlimited_lives, &limited_lives);
    register("headbounces", &headbounces);
    register("bounce_pads", &bounce_pads);
    register("crate_preview", &crate_preview);
    register("bot_effects", &bot_effects);
    register("zombie_effects", &zombie_effects);
    register("save_load_binds", &save_load_binds);
    register("frozen_bots", &freeze_bots, &unfreeze_bots);
    register("aimbot", &aimbot);
    register("tracers", &tracers);
    register("no_hud", &hide_hud, &show_hud);
    register("no_oob", &disable_oob, &enable_oob);
    register("no_barriers", &remove_barriers, &restore_barriers);
    register("pve", &cicada_pve::start, &cicada_pve::stop);
    register("freeze_timer", &freeze_timer, &unfreeze_timer);
    register("round_reset", &round_reset);
    register("auto_pause", &auto_pause, &unpause_timer);
    register("auto_plant", &auto_plant);
    register("kill_target", &kill_target_mode, &kill_target_off);
    register("equipment_aimbot", &cicada_mechanics::equipment_aimbot);
    register("auto_chute", &cicada_mechanics::auto_chute);
    register("redeploy", &cicada_mechanics::redeploy, &cicada_mechanics::redeploy_off);
}

function register(key, start, stop)
{
    feature = [];
    feature["start"] = start;
    feature["stop"] = stop;
    level.cicada_features[key] = feature;
}

function toggle(key)
{
    if (self cicada_util::flippers(key))
        self start(key);
    else
        self stop(key);
}

function start(key)
{
    feature = level.cicada_features[key];
    if (isdefined(feature))
        self thread [[feature["start"]]](key);
}

function stop(key)
{
    self notify(cicada_util::stop_event(key));

    feature = level.cicada_features[key];
    if (isdefined(feature) && isdefined(feature["stop"]))
        self thread [[feature["stop"]]](key);
}

function restore_features()
{
    foreach (key, feature in level.cicada_features)
        if (istrue(self cicada_util::getpers(key)))
            self thread [[feature["start"]]](key);
}

function refresh_on_spawn()
{
    self endon("disconnect");

    wait 0.05;

    if (isdefined(self.noclip_anchor))
        self detach_anchor();

    self stop_elevator();
    self cicada_movement::stop_ride();
    self cicada_loadout::apply_camo();

    if (self crate_count())
        self build_crates();

    if (istrue(self cicada_util::getpers("pve")) && !istrue(level.cicada_pve_active))
        self cicada_pve::start("pve");

    if ((istrue(self cicada_util::getpers("pve_save_state")) || istrue(self cicada_util::getpers("pve_autosave"))) && !istrue(level.cicada_pve_restored))
    {
        level.cicada_pve_restored = true;
        self thread [[&cicada_pve::load_state]]();
    }

    if (istrue(self cicada_util::getpers("no_hud")))
        self hide_hud("no_hud");

    if (istrue(self cicada_util::getpers("invincible")))
    {
        self enableinvulnerability();
        self.maxhealth = 9999;
        self.health = self.maxhealth;
    }

    if (self has_position())
        self load_position();

    if (!self cicada_builds::spawn_apply())
        self cicada_loadout::spawn_class();
}

function anyone_using(key)
{
    foreach (player_ in level.players)
        if (istrue(player_ cicada_util::getpers(key)))
            return true;

    return false;
}

function set_value(value, key)
{
    self cicada_util::setpers(key, value);
}

function toggle_dvar(dvar)
{
    setdvar(dvar, !istrue(getdvarint(dvar)));
}

function godmode(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    if (!isdefined(level.cicada_fall_height))
        level.cicada_fall_height = getdvarfloat("bg_falldamageminheight", 200.0);

    setdvar("bg_falldamageminheight", 100000);

    self enableinvulnerability();
    self.maxhealth = 9999;
    self.health = self.maxhealth;

    for (;;)
    {
        self waittill("damage");

        if (self isinvulnerable())
            self.health = self.maxhealth;
    }
}

function mortal(key)
{
    if (isdefined(level.cicada_fall_height) && !anyone_using(key))
        setdvar("bg_falldamageminheight", level.cicada_fall_height);

    self disableinvulnerability();
    self.maxhealth = 100;
    self.health = self.maxhealth;
}

function noclip(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    while (!isalive(self))
        wait 0.05;

    self.noclip_anchor = undefined;

    for (;;)
    {
        if (self meleebuttonpressed() && self jumpbuttonpressed() && !self cicada_util::in_menu())
        {
            if (isdefined(self.noclip_anchor))
                self detach_anchor();
            else
                self attach_anchor();

            wait 0.2;
        }

        if (isdefined(self.noclip_anchor))
            self move_anchor();

        wait 0.05;
    }
}

function attach_anchor()
{
    self allowsprint(0);
    self.noclip_anchor = spawn("script_origin", self.origin);
    self.noclip_anchor.angles = self.angles;
    self playerlinkto(self.noclip_anchor);
}

function detach_anchor()
{
    self allowsprint(1);
    self unlink();
    self.noclip_anchor delete();
    self.noclip_anchor = undefined;
}

function move_anchor()
{
    angles = self getplayerangles();
    movement = self getnormalizedmovement();
    lift = 0;

    if (!self cicada_util::in_menu())
    {
        if (self jumpbuttonpressed())
            lift = 1;

        if (self stancebuttonpressed())
            lift = -1;
    }

    speed = self sprintbuttonpressed() ? 40 : 16.5;
    direction = anglestoforward(angles) * movement[0] + anglestoright(angles) * movement[1] + (0, 0, lift * 1.7);

    self.noclip_anchor.origin = self.noclip_anchor.origin + direction * speed;
    self.noclip_anchor.angles = angles;
}

function always_nac(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_+weapnext");
        self cicada_weapon::nacto(self cicada_weapon::previous_weapon(), true);
    }
}

function instaswaps(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_+frag");

        wait (self cicada_util::getpersfloat("instaswaps_time"));
        self cicada_weapon::switchto(self cicada_weapon::previous_weapon());
    }
}

function elevators(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        if (self adsbuttonpressed() && self cicada_util::isbuttonpressed("+stance") && self isonground() && !self isonladder() && !self ismantling())
        {
            self thread [[&ride_elevator]]("up");
            wait 0.25;
        }

        wait 0.05;
    }
}

function ride_elevator(mode)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (isdefined(self.elevator))
        return;

    self.elevator = spawn("script_origin", self.origin);
    self playerlinkto(self.elevator);

    while (!self cicada_util::isbuttonpressed("+gostand"))
    {
        self.elevator.origin = self.elevator.origin + (0, 0, (mode == "down") ? -3 : randomintrange(8, 20));
        wait 0.05;
    }

    self stop_elevator();
}

function stop_elevator()
{
    if (!isdefined(self.elevator))
        return;

    self unlink();
    self.elevator delete();
    self.elevator = undefined;
}

function auto_prone(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired", weapon);

        if (self cicada_util::getpers("auto_prone_mode") == "air" && (self isonground() || self isonladder()))
            continue;

        if (!cicada_weapon::is_ads_weapon(weapon))
            continue;

        self thread [[&hold_prone]]();
        wait 0.5;
        self notify("cicada_prone_done");
    }
}

function hold_prone()
{
    self endon("disconnect");
    self endon("cicada_prone_done");
    level endon("game_ended");

    for (;;)
    {
        self setstance("prone");
        wait 0.01;
    }
}

function auto_reload(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));

    level waittill("game_ended");

    weapon = self getcurrentweapon();
    if (!self getweaponammostock(weapon))
        self setweaponammostock(weapon, 1);

    self setweaponammoclip(weapon, 0);
}

function infinite_equipment(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("grenade_fire", grenade, item);
        wait 0.05;
        self setweaponammoclip(item, 1);
        self givemaxammo(item);
    }
}

function unlimited_lives(key)
{
    self.pers["lives"] = 99;
}

function limited_lives(key)
{
    self.pers["lives"] = 1;
}

function headbounces(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        foreach (player_ in level.players)
        {
            if (player_ == self || distance(player_.origin + (0, 0, 90), self.origin) > 80)
                continue;

            self bounce();
        }

        wait 0.05;
    }
}

function bounce_pads(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        for (i = 0; i < self bounce_count(); i++)
        {
            if (distance(self.origin, self cicada_util::getmappers("bounce_" + i)) < 90)
                self bounce();
        }

        wait 0.05;
    }
}

function bounce()
{
    velocity = self getvelocity();
    if (velocity[2] > -250)
        return;

    self setvelocity(velocity - (0, 0, velocity[2] * 2));
    wait 0.2;
}

function bounce_count()
{
    return self cicada_util::getmappersint("bounce_count");
}

function save_bounce()
{
    count = self bounce_count();
    self cicada_util::setmappers("bounce_" + count, self.origin);
    self cicada_util::setmappers("bounce_count", count + 1);
    self cicada_util::message("bounce ^:#" + count + " ^7saved");
}

function delete_bounce()
{
    count = self bounce_count();
    if (!count)
    {
        self cicada_util::message("^1no bounces to delete");
        return;
    }

    self cicada_util::setmappers("bounce_" + (count - 1), undefined);
    self cicada_util::setmappers("bounce_count", count - 1);
    self cicada_util::message("bounce ^:#" + (count - 1) + " ^7deleted");
}

function clear_bounces()
{
    count = self bounce_count();

    for (i = 0; i < count; i++)
        self cicada_util::setmappers("bounce_" + i, undefined);

    self cicada_util::setmappers("bounce_count", 0);
    self cicada_util::message("bounces ^1cleared");
}

function manage_bounce(action)
{
    switch (action)
    {
        case "save":
            self save_bounce();
            break;

        case "delete last":
            self delete_bounce();
            break;

        case "clear":
            self clear_bounces();
            break;
    }

    self cicada_menu::update_menu();
}

function crate_model()
{
    return "com_plasticcase_beige_big_iw6";
}

function crate_count()
{
    return self cicada_util::getmappersint("crate_count");
}

function crate_origin()
{
    forward = anglestoforward((0, self.angles[1], 0));

    return self.origin + forward * self cicada_util::getpersfloat("crate_offset") + (0, 0, self cicada_util::getpersfloat("crate_height"));
}

function crate_clip()
{
    if (isdefined(level.cratedata) && isdefined(level.cratedata.mountmantlemodel))
        return level.cratedata.mountmantlemodel;

    return getent("care_package_col", "targetname");
}

function spawn_crate(origin, angles)
{
    crate = spawn("script_model", origin);

    if (isdefined(angles))
        crate.angles = angles;

    clip = crate_clip();

    if (isdefined(clip))
        crate clonebrushmodeltoscriptmodel(clip);
    else
    {
        // fallback
        crate setmodel(crate_model());
        crate hide();
    }

    crate solid();

    return crate;
}

function clear_crate_models()
{
    if (!isdefined(self.cicada_crates))
        return;

    foreach (crate in self.cicada_crates)
        if (isdefined(crate))
            crate delete();

    self.cicada_crates = [];
}

function build_crates()
{
    self clear_crate_models();
    self.cicada_crates = [];

    for (i = 0; i < self crate_count(); i++)
    {
        origin = self cicada_util::getmappers("crate_" + i);

        if (!isdefined(origin))
            continue;

        self.cicada_crates[self.cicada_crates.size] = spawn_crate(origin, self cicada_util::getmappers("crate_angles_" + i));
    }
}

function crate_top(origin)
{
    spot = playerphysicstrace(origin + (0, 0, 128), origin + (0, 0, 4));

    if (!isdefined(spot))
        return origin + (0, 0, 4);

    return spot;
}

function crate_landing(origin)
{
    self endon("disconnect");
    self endon("death");

    if (self isonground() || istrue(self.cicada_launched))
        return;

    held = is_frozen(self);

    self.cicada_launched = true;

    self setorigin(crate_top(origin));
    self setvelocity((0, 0, 0));
    self freezecontrols(1);

    wait 1;

    self.cicada_launched = false;

    if (!held)
        self freezecontrols(0);
}

function save_crate()
{
    count = self crate_count();
    origin = self crate_origin();

    self cicada_util::setmappers("crate_" + count, origin);
    self cicada_util::setmappers("crate_angles_" + count, (0, self.angles[1], 0));
    self cicada_util::setmappers("crate_count", count + 1);

    self build_crates();
    self play_effect("golden_gun_torso", origin);
    self thread [[&crate_landing]](origin);
    self cicada_util::message("invis crate ^:#" + count + " ^7spawned");
}

function delete_crate()
{
    count = self crate_count();

    if (!count)
    {
        self cicada_util::message("^1no invis crates to delete");
        return;
    }

    self cicada_util::setmappers("crate_" + (count - 1), undefined);
    self cicada_util::setmappers("crate_angles_" + (count - 1), undefined);
    self cicada_util::setmappers("crate_count", count - 1);

    self build_crates();
    self cicada_util::message("invis crate ^:#" + (count - 1) + " ^7deleted");
}

function clear_crates()
{
    count = self crate_count();

    for (i = 0; i < count; i++)
    {
        self cicada_util::setmappers("crate_" + i, undefined);
        self cicada_util::setmappers("crate_angles_" + i, undefined);
    }

    self cicada_util::setmappers("crate_count", 0);
    self clear_crate_models();
    self cicada_util::message("invis crates ^1cleared");
}

function manage_crate(action)
{
    switch (action)
    {
        case "spawn":
            self save_crate();
            break;

        case "delete last":
            self delete_crate();
            break;

        case "clear":
            self clear_crates();
            break;
    }

    self cicada_menu::update_menu();
}

function crate_preview(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        effect = self cicada_util::getpers("crate_effect");

        for (i = 0; i < self crate_count(); i++)
        {
            origin = self cicada_util::getmappers("crate_" + i);

            if (isdefined(origin))
                play_effect(effect, origin + (0, 0, 4));
        }

        wait (self cicada_util::getpersfloat("crate_preview_time"));
    }
}

function save_load_binds(key)
{
    foreach (command in cicada_binds::commands())
        self thread [[&crouch_bind]](command);
}

function crouch_bind(command)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event("save_load_binds"));
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-" + command);

        if (self getstance() != "crouch" || self cicada_util::in_menu())
            continue;

        if (command == cicada_binds::slot_command(self cicada_util::getpers("save_slot")))
            self thread [[&save_position]]();

        if (command == cicada_binds::slot_command(self cicada_util::getpers("load_slot")))
            self thread [[&load_position]]();
    }
}

function has_position()
{
    return isdefined(self cicada_util::getmappers("position"));
}

function save_position()
{
    self cicada_util::setmappers("position", self.origin);
    self cicada_util::setmappers("angles", self getplayerangles());
    self cicada_util::sound("scavenger_pack_pickup");
}

function load_position()
{
    if (!self has_position())
    {
        self cicada_util::message_bold("^6save a position first");
        return;
    }

    if (self.sessionstate != "playing")
        return;

    self setvelocity((0, 0, 0));
    self setorigin(self cicada_util::getmappers("position"));
    self setplayerangles(self cicada_util::getmappers("angles"));
}

function reset_position()
{
    self cicada_util::setmappers("position", undefined);
    self cicada_util::setmappers("angles", undefined);
    self cicada_util::message("position ^1cleared");
}

function manage_position(action)
{
    switch (action)
    {
        case "save":
            self save_position();
            break;
        case "load":
            self load_position();
            break;
        case "reset":
            self reset_position();
            break;
    }
}

function nudge_position(value, axis)
{
    if (!self has_position())
        return;

    origin = self cicada_util::getmappers("position");

    if (axis == "x")
        origin = (float(value), origin[1], origin[2]);
    else if (axis == "y")
        origin = (origin[0], float(value), origin[2]);
    else
        origin = (origin[0], origin[1], float(value));

    self cicada_util::setmappers("position", origin);
}

function unstuck()
{
    self setorigin(self.origin + (0, 0, 20));
    self setvelocity((0, 0, 0));
}

function mark_freeze_spot(player_)
{
    if (!isdefined(player_) || istrue(player_.cicada_launched))
        return;

    player_.cicada_freeze_spot = player_.origin;
    player_.cicada_freeze_angles = player_ getplayerangles();
}

function private hold_freeze_spot(player_)
{
    if (!isdefined(player_.cicada_freeze_spot) || istrue(player_.cicada_launched))
    {
        mark_freeze_spot(player_);
        return;
    }

    if (distance(player_.origin, player_.cicada_freeze_spot) > 32)
        mark_freeze_spot(player_);
}

function private restore_freeze_spot(player_)
{
    if (!isdefined(player_.cicada_freeze_spot) || istrue(player_.cicada_launched))
        return;

    gap = distance(player_.origin, player_.cicada_freeze_spot);

    if (gap < 0.05 || gap > 32)
        return;

    player_ setorigin(player_.cicada_freeze_spot);
    player_ setvelocity((0, 0, 0));

    if (isdefined(player_.cicada_freeze_angles))
        player_ setplayerangles(player_.cicada_freeze_angles);
}

function frozen_now(player_)
{
    if (!isalive(player_))
        return false;

    if (is_frozen(player_))
        return true;

    return cicada_util::is_bot(player_) && anyone_using("frozen_bots");
}

function guard_frozen()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("prematch_over");

        for (i = 0; i < 40; i++)
        {
            foreach (player_ in level.players)
            {
                if (!frozen_now(player_))
                    continue;

                player_ freezecontrols(1);
                restore_freeze_spot(player_);
            }

            waitframe();
        }
    }
}

function freeze_bots(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        foreach (player_ in level.players)
        {
            if (!cicada_util::is_bot(player_) || istrue(player_.cicada_launched))
                continue;

            player_ freezecontrols(1);
            hold_freeze_spot(player_);
        }

        wait 0.5;
    }
}

function unfreeze_bots(key)
{
    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_))
            player_ freezecontrols(0);
}

function is_frozen(player_)
{
    return isdefined(player_) && istrue(player_.cicada_frozen);
}

function toggle_freeze(player_)
{
    if (player_ == self)
    {
        self cicada_util::message("^1cannot freeze yourself");
        return;
    }

    if (is_frozen(player_))
    {
        player_.cicada_frozen = false;
        player_ notify("cicada_unfreeze");
        player_ freezecontrols(0);
        return;
    }

    player_.cicada_frozen = true;
    mark_freeze_spot(player_);
    player_ thread [[&hold_freeze]]();
}

function hold_freeze()
{
    self endon("disconnect");
    self endon("cicada_unfreeze");
    level endon("game_ended");

    for (;;)
    {
        if (!istrue(self.cicada_launched))
        {
            self freezecontrols(1);
            hold_freeze_spot(self);
        }

        wait 0.5;
    }
}

function bot_spawn_team(team)
{
    if (!istrue(level.teambased))
        return "none";

    if (team == "friendly")
        return self.team;

    return (self.team == "allies") ? "axis" : "allies";
}

function is_friendly(player_)
{
    return isdefined(player_) && isdefined(self.team) && player_.team == self.team;
}

function team_color(player_)
{
    if (!istrue(level.teambased))
        return "^7";

    return self is_friendly(player_) ? "^5" : "^1";
}

function team_label(player_)
{
    if (!istrue(level.teambased))
        return "free for all";

    return self is_friendly(player_) ? "^5friendly" : "^1enemy";
}

function on_team(player_, team)
{
    return isdefined(player_) && player_.team == team && istrue(player_.pers["team"] == team) && istrue(player_.sessionteam == team);
}

function set_team(player_, team)
{
    player_ menus::addtoteam(team, false, true);
    player_.sessionteam = team;

    if (cicada_util::is_bot(player_))
    {
        player_.bot_team = team;
        player_.pers["bot_team"] = team;
    }

    self respawn_player(player_);
}

function has_kill_target()
{
    foreach (player_ in level.players)
        if (istrue(player_.cicada_killcam_target))
            return true;

    return false;
}

function is_kill_target(player_)
{
    return isdefined(player_) && istrue(player_.cicada_killcam_target);
}

function toggle_kill_target(player_)
{
    if (!isdefined(player_))
        return;

    if (istrue(player_.cicada_killcam_target))
        player_.cicada_killcam_target = false;
    else
    {
        foreach (other in level.players)
            other.cicada_killcam_target = false;

        player_.cicada_killcam_target = true;
        player_.cicada_auto_respawn = false;
    }

    self cicada_menu::update_menu();
}

function private kill_winner(attacker)
{
    if (!istrue(level.teambased))
        return (isdefined(attacker) && isplayer(attacker)) ? attacker : undefined;

    if (isdefined(attacker) && isdefined(attacker.team) && isdefined(game["teamScores"][attacker.team]))
        return attacker.team;

    return "allies";
}

function private end_on_kill_target(attacker)
{
    waitframe();

    if (istrue(level.gameended))
        return;

    gamelogic::endgame(kill_winner(attacker), game["end_reason"]["ended_game"]);
}

function private revive_after_death()
{
    self endon("disconnect");
    level endon("game_ended");

    wait 1;

    if (istrue(level.gameended) || isalive(self))
        return;

    self thread [[&playerlogic::spawnclient]]();
}

function player_killed_hook(einflictor, eattacker, idamage, idflags, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration)
{
    if (istrue(level.cicada_target_mode) && isplayer(self) && has_kill_target())
    {
        if (istrue(self.cicada_killcam_target))
        {
            level.recordfinalkillcam = 1;
            level.disable_killcam = 0;
            level thread [[&end_on_kill_target]](eattacker);
        }
        else
            self thread [[&revive_after_death]]();
    }

    [[level.cicada_onkilled_orig]](einflictor, eattacker, idamage, idflags, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration);
}

function may_consider_dead(victim)
{
    if (istrue(level.cicada_target_mode) && isplayer(victim) && has_kill_target() && !istrue(victim.cicada_killcam_target))
        return false;

    if (isdefined(level.cicada_maydead_orig))
        return [[level.cicada_maydead_orig]](victim);

    return true;
}

function private ensure_kill_hook()
{
    if (istrue(level.cicada_kill_hook))
        return;

    level.cicada_kill_hook = true;
    level.cicada_onkilled_orig = level.callbackplayerkilled;
    level.callbackplayerkilled = &player_killed_hook;

    level.cicada_maydead_orig = level.modemayconsiderplayerdead;
    level.modemayconsiderplayerdead = &may_consider_dead;
}

function kill_target_mode(key)
{
    ensure_kill_hook();
    level.cicada_target_mode = true;
}

function kill_target_off(key)
{
    level.cicada_target_mode = false;

    foreach (player_ in level.players)
        player_.cicada_killcam_target = false;
}

function spawn_bot_of(value, key)
{
    self cicada_util::setpers(key, value);
    self spawn_bot();
}

function private hold_bot_team(wanted)
{
    self endon("disconnect");
    level endon("game_ended");

    known = [];

    foreach (player_ in level.players)
        known[player_ getentitynumber()] = true;

    limit = gettime() + 15000;

    while (gettime() < limit)
    {
        foreach (player_ in level.players)
        {
            if (!cicada_util::is_bot(player_) || istrue(known[player_ getentitynumber()]))
                continue;

            known[player_ getentitynumber()] = true;
            self thread [[&settle_bot_team]](player_, wanted);
        }

        waitframe();
    }
}

function private settle_bot_team(bot, wanted)
{
    self endon("disconnect");
    bot endon("disconnect");

    for (i = 0; i < 60 && bot.sessionstate != "playing"; i++)
        wait 0.1;

    bot.bot_team = wanted;
    bot.pers["bot_team"] = wanted;

    if (on_team(bot, wanted))
        return;

    self set_team(bot, wanted);
    self cicada_util::message("bot moved to ^:" + self team_label(bot));
}

function spawn_bot()
{
    if (!isdefined(level.bot_funcs) || !isdefined(level.bot_funcs["bots_spawn"]))
    {
        self cicada_util::message_bold("^5bots are not supported in this match");
        return;
    }

    team = self cicada_util::getpers("bot_team");
    difficulty = self cicada_util::getpers("bot_difficulty");
    wanted = self bot_spawn_team(team);

    level thread [[level.bot_funcs["bots_spawn"]]](1, wanted, undefined, undefined, undefined, difficulty);

    if (wanted != "none")
        self thread [[&hold_bot_team]](wanted);

    self cicada_util::message("spawning ^:" + difficulty + " ^7bot on ^:" + team);
    self cicada_util::sound("scavenger_pack_pickup");
}

function clear_perk(perk_name)
{
    for (i = 0; i < 8 && self perk::_hasperk(perk_name); i++)
        self perks::_unsetperk(perk_name);
}

function strip_bot_laststand()
{
    self endon("disconnect");
    self endon("death");

    for (;;)
    {
        self clear_perk("specialty_pistoldeath");
        self clear_perk("specialty_survivor");

        if (istrue(self.inlaststand))
        {
            self suicide();
            return;
        }

        wait 0.1;
    }
}

function move_bots(target)
{
    destination = (target == "crosshair") ? self cicada_util::crosshair() : self.origin;

    foreach (player_ in level.players)
    {
        if (!cicada_util::is_bot(player_) || player_.sessionstate != "playing")
            continue;

        place_player(player_, destination);
    }

    self cicada_util::message("bots moved to ^:" + destination);
    self cicada_util::sound("scavenger_pack_pickup");
}

function stored_velocity(prefix)
{
    return (self cicada_util::getpersfloat(prefix + "velocity_x"), self cicada_util::getpersfloat(prefix + "velocity_y"), self cicada_util::getpersfloat(prefix + "velocity_z"));
}

function play_velocity()
{
    self setvelocity(self stored_velocity(""));
}

function knockback_push()
{
    enemy = self cicada_util::enemy_player();

    if (enemy == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    weapon = enemy getcurrentweapon();

    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = self getcurrentweapon();

    push = self cicada_util::getpersfloat("knockback_power");
    lift = self cicada_util::getpersfloat("knockback_lift");

    away = self.origin - enemy.origin;
    away = (away[0], away[1], 0);

    if (length(away) < 1)
        away = anglestoforward((0, self.angles[1], 0)) * -1;

    away = vectornormalize(away);

    if (self isonground())
    {
        self setvelocity((0, 0, 200));
        waitframe();
        waitframe();
    }

    target = self.origin + (0, 0, 40);

    if (!istrue(self cicada_util::getpers("knockback_damage")))
        target = target + vectorcross(away, (0, 0, 1)) * 40;

    magicbullet(weapon, enemy geteye(), target, enemy);

    self setvelocity(away * push + (0, 0, lift));
}

function ai_kinds()
{
    return cicada_util::list("bot,agent,zombie");
}

function ai_class(ent)
{
    if (!isdefined(ent) || isplayer(ent))
        return "bot";

    return cicada_pve::is_actor(ent) ? "agent" : "zombie";
}

function ai_name(ent)
{
    if (!isdefined(ent))
        return "nothing";

    if (isplayer(ent))
        return ent cicada_util::player_name();

    return cicada_pve::zombie_name(ent);
}

function ai_pool(kind)
{
    pool = [];

    if (!isdefined(kind))
        kind = "bot";

    if (kind == "bot")
    {
        foreach (player_ in level.players)
            if (cicada_util::is_bot(player_) && player_.sessionstate == "playing")
                pool[pool.size] = player_;

        return pool;
    }

    foreach (ent in cicada_pve::zombies())
        if (ai_class(ent) == kind)
            pool[pool.size] = ent;

    return pool;
}

function is_ai_target(ent)
{
    return isdefined(ent) && istrue(ent.cicada_bind_target);
}

function toggle_ai_target(ent)
{
    if (!isdefined(ent))
        return;

    wanted = !is_ai_target(ent);

    foreach (other in self ai_pool(ai_class(ent)))
        other.cicada_bind_target = 0;

    ent.cicada_bind_target = wanted;

    if (wanted)
        self cicada_util::message("bind target ^:" + ai_name(ent));
    else
        self cicada_util::message("bind target ^1cleared");

    self cicada_menu::update_menu();
}

function ai_pick_key(kind)
{
    return kind + "_pick";
}

function ai_target(kind)
{
    if (!istrue(self cicada_util::getpers(ai_pick_key(kind))))
        return undefined;

    foreach (ent in self ai_pool(kind))
        if (is_ai_target(ent))
            return ent;

    return undefined;
}

function ai_target_summary(kind)
{
    if (!istrue(self cicada_util::getpers(ai_pick_key(kind))))
        return "^7every " + kind;

    picked = self ai_target(kind);

    if (!isdefined(picked))
        return "^1nothing marked ^7- mark one in its menu";

    return "^:" + ai_name(picked);
}

function ai_bind_pool(kind)
{
    picked = self ai_target(kind);

    if (isdefined(picked))
    {
        only = [];
        only[0] = picked;

        return only;
    }

    return self ai_pool(kind);
}

function launch_ai(velocity, delay)
{
    if (istrue(self.cicada_launched) || !isalive(self))
        return;

    self.cicada_launched = true;

    start = self.origin;
    facing = self.angles;

    cicada_pve::hold_ai(self);

    rig = spawn("script_model", start);
    rig setmodel("tag_origin");
    self linkto(rig);

    span = length(velocity) / 600;

    if (span < 0.2)
        span = 0.2;

    if (span > 3)
        span = 3;

    rig moveto(start + velocity, span, span * 0.35, span * 0.35);
    wait span;

    if (isdefined(self))
    {
        self unlink();
        self.cicada_launched = false;
    }

    rig delete();

    if (!isalive(self))
        return;

    if (delay > 0)
    {
        wait delay;

        if (!isalive(self))
            return;

        self forceteleport(start, facing);
    }

    cicada_pve::release_ai(self);
}

function play_ai_velocity(kind)
{
    if (!isdefined(kind))
        kind = "bot";

    prefix = kind + "_";
    velocity = self stored_velocity(prefix);
    delay = self cicada_util::getpersfloat(prefix + "return_time");
    pool = self ai_bind_pool(kind);

    if (!pool.size)
    {
        self cicada_util::message_bold("^5spawn " + (kind == "bot" ? "a bot" : "an " + kind) + " first");
        return;
    }

    foreach (ent in pool)
    {
        if (kind == "bot")
        {
            ent thread [[&launch_bot]](velocity, delay);
            continue;
        }

        ent thread [[&launch_ai]](velocity, delay);
    }
}

function play_bot_velocity()
{
    self play_ai_velocity("bot");
}

function play_agent_velocity()
{
    self play_ai_velocity("agent");
}

function play_zombie_velocity()
{
    self play_ai_velocity("zombie");
}

function freeze_wanted(player_)
{
    return is_frozen(player_) || anyone_using("frozen_bots");
}

function wait_landing()
{
    self endon("disconnect");
    self endon("death");

    wait 0.25;

    for (i = 0; i < 200 && !self isonground(); i++)
        wait 0.05;
}

function launch_bot(velocity, delay)
{
    self endon("disconnect");
    self endon("death");

    if (istrue(self.cicada_launched))
        return;

    frozen = freeze_wanted(self);
    started = gettime();

    self.cicada_launched = true;

    if (frozen)
        self freezecontrols(0);

    if (self isonground())
    {
        self setvelocity((0, 0, 200));
        waitframe();
        waitframe();
    }

    self setvelocity(velocity);
    self wait_landing();

    self.cicada_launched = false;

    if (frozen)
        self freezecontrols(1);

    if (delay <= 0 || !self has_position())
        return;

    remaining = delay - (gettime() - started) / 1000;
    if (remaining > 0)
        wait remaining;

    self load_position();
}

function randomize_velocity(prefix)
{
    self cicada_util::setpers(prefix + "velocity_x", randomintrange(-500, 500));
    self cicada_util::setpers(prefix + "velocity_y", randomintrange(-500, 500));
    self cicada_util::setpers(prefix + "velocity_z", randomintrange(-500, 500));
    self cicada_util::sound("scavenger_pack_pickup");
}

function track_velocity(prefix)
{
    for (i = 3; i > 0; i--)
    {
        self cicada_util::message_bold("tracking in ^:" + i);
        wait 1;
    }

    velocity = self getvelocity();
    self cicada_util::setpers(prefix + "velocity_x", velocity[0]);
    self cicada_util::setpers(prefix + "velocity_y", velocity[1]);
    self cicada_util::setpers(prefix + "velocity_z", velocity[2]);
    self cicada_util::sound("scavenger_pack_pickup");
}

function aimbot_weapon_keys()
{
    return cicada_util::list("aimbot_weapon,aimbot_weapon_2,aimbot_weapon_hitmarker");
}

function aimbot_damage_keys()
{
    return cicada_util::list("aimbot_weapon,aimbot_weapon_2");
}

function aimbot_modes()
{
    return cicada_util::list("all snipers,selected weapons");
}

function hitmarker_modes()
{
    list = [];
    list[0] = "all weapons";

    foreach (type in cicada_catalog::weapon_types())
        list[list.size] = type;

    list[list.size] = "selected weapons";
    return list;
}

function set_aimbot_mode(value, key)
{
    self cicada_util::setpers(key, value);
    self cicada_menu::update_menu();
}

function uses_selected_weapons()
{
    return self cicada_util::getpers("aimbot_mode") == "selected weapons" || self cicada_util::getpers("hitmarker_mode") == "selected weapons";
}

function aimbot_weapon_name(key)
{
    stored = self cicada_util::getpers(key);
    if (!isdefined(stored) || stored == "" || stored == "none")
        return "not set";
    return stored;
}

function set_aimbot_weapon(key)
{
    weapon = self getcurrentweapon();
    if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
        return;

    self cicada_util::setpers(key, weapon.basename);
    self cicada_util::message("aimbot weapon set to ^:" + weapon.basename);
}

function clear_aimbot_weapons()
{
    foreach (key in aimbot_weapon_keys())
        self cicada_util::setpers(key, undefined);

    self cicada_util::message("aimbot weapons cleared");
}

function weapon_in_keys(weapon, keys)
{
    foreach (key in keys)
    {
        stored = self cicada_util::getpers(key);

        if (!isdefined(stored) || stored == "" || stored == "none")
            continue;

        if (stored == weapon.basename)
            return true;
    }

    return false;
}

function aimbot_matches(mode, weapon, keys)
{
    if (!isdefined(mode))
        return false;

    if (mode == "selected weapons")
        return self weapon_in_keys(weapon, keys);

    if (mode == "all weapons")
        return isdefined(cicada_catalog::weapon_class(weapon));

    if (mode == "all snipers")
        return cicada_catalog::is_weapon_type(weapon, "snipers");

    return cicada_catalog::is_weapon_type(weapon, mode);
}

function aimbot(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");

        weapon = self getcurrentweapon();

        if (!isdefined(weapon) || !isdefined(weapon.basename))
            continue;

        if (self aimbot_matches(self cicada_util::getpers("aimbot_mode"), weapon, aimbot_damage_keys()))
        {
            self shoot_nearest_target(false);
            continue;
        }

        if (self aimbot_matches(self cicada_util::getpers("hitmarker_mode"), weapon, cicada_util::list("aimbot_weapon_hitmarker")))
            self shoot_nearest_target(true);
    }
}

function damage_zombie(zombie, amount)
{
    zombie dodamage(amount, zombie.origin, self, self, "MOD_RIFLE_BULLET", self getcurrentweapon(), "torso_upper");
}

function shoot_nearest_zombies(feedback_only, center, range, delay)
{
    foreach (zombie in cicada_pve::zombies())
    {
        if (!isdefined(zombie) || !isalive(zombie) || distance(zombie.origin, center) > range)
            continue;

        if (delay > 0)
            wait (delay);

        if (istrue(feedback_only))
        {
            self damagefeedback::updatedamagefeedback("standard", 0, 0, "standard", 0);
            continue;
        }

        self damage_zombie(zombie, 350);

        if (istrue(self cicada_util::getpers("kill_effects")))
            self play_stack("kill_effect", zombie.origin + (0, 0, 50));
    }
}

function shoot_nearest_target(feedback_only)
{
    center = self cicada_util::crosshair();
    range = self cicada_util::getpersint("aimbot_range");
    delay = self cicada_util::getpersfloat("aimbot_delay");

    foreach (player_ in level.players)
    {
        if (player_ == self || !isalive(player_) || distance(player_.origin, center) > range)
            continue;

        if (delay > 0)
            wait (delay);

        if (istrue(feedback_only))
        {
            self damagefeedback::updatedamagefeedback("standard", 0, 0, "standard", 0);
            continue;
        }

        self deal_damage(player_, 350);

        if (istrue(self cicada_util::getpers("kill_effects")))
            self play_stack("kill_effect", player_.origin + (0, 0, 50));
    }

    if (istrue(self cicada_util::getpers("aimbot_zombies")))
        self shoot_nearest_zombies(feedback_only, center, range, delay);
}

function deal_damage(victim, amount, attacker)
{
    if (!isdefined(attacker))
        attacker = self;

    victim thread [[level.callbackplayerdamage]](attacker, attacker, amount, 0, "MOD_RIFLE_BULLET", randomfloatrange(20.0, 50.0), attacker getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", randomintrange(0, 66), 0, undefined, 1, 102);
}

function tracers(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");
        self thread [[&tracer_trail]]();
    }
}

function tracer_trail()
{
    self endon("disconnect");

    forward = anglestoforward(self getplayerangles());
    origin = self gettagorigin("tag_weapon_right");
    offset = 12;

    for (i = 0; i < self cicada_util::getpersint("tracer_count"); i++)
    {
        self play_stack("tracer_effect", origin + forward * offset);
        offset = offset * 2;
        wait 0.05;
    }
}

function play_effect(effect, origin)
{
    if (!isdefined(effect) || !utility::fxexists(effect))
        return;

    playfx(utility::getfx(effect), origin);
}

function preview_sound(name)
{
    if (!isdefined(name) || !soundexists(name))
    {
        self cicada_util::message(cicada_util::warn("that sound is not loaded"));
        return;
    }

    self cicada_util::setpers("last_sound", name);
    self playlocalsound(name);
}

function preview_random_sound(group)
{
    self preview_sound(cicada_catalog::random_sound(group));
    self cicada_menu::update_menu();
}

function replay_sound()
{
    self preview_sound(self cicada_util::getpers("last_sound"));
}

function set_sound(name, key)
{
    if (!isdefined(name) || !soundexists(name))
    {
        self cicada_util::message(cicada_util::warn("that sound is not loaded"));
        return;
    }

    self cicada_util::setpers(key, name);
    self preview_sound(name);
    self cicada_menu::update_menu();
}

function set_random_sound(group, key)
{
    self set_sound(cicada_catalog::random_sound(group), key);
}

function sound_label(name)
{
    if (!isdefined(name))
        return "none";

    return cicada_util::shorten(name, 26);
}

function preview_effect(effect)
{
    play_effect(effect, self.origin + (0, 0, 50));
}

function effect_list()
{
    if (!isdefined(level._effect))
        return [];

    names = [];
    foreach (name, effect in level._effect)
        names[names.size] = name;
    return names;
}

function effect_label(name)
{
    if (!isdefined(name))
        return "none";

    return cicada_util::shorten(cicada_util::after_mark(name, ":"), 28);
}

function stack_count(key)
{
    return self cicada_util::getpersint(key + "_count");
}

function stack_effect(key, index)
{
    return self cicada_util::getpers(key + "_" + index);
}

function stack_summary(key)
{
    count = self stack_count(key);

    if (!count)
    {
        single = self cicada_util::getpers(key);
        return isdefined(single) ? ("^:" + effect_label(single)) : "^1nothing stacked";
    }

    return "^:" + count + " ^7effects stacked";
}

function add_stack_effect(effect, key)
{
    if (!isdefined(effect))
        return;

    count = self stack_count(key);

    self cicada_util::setpers(key + "_" + count, effect);
    self cicada_util::setpers(key + "_count", count + 1);
    self cicada_util::message("^:" + effect_label(effect) + " ^7stacked");
}

function remove_stack_effect(key)
{
    count = self stack_count(key);

    if (!count)
    {
        self cicada_util::message("^1nothing stacked");
        return;
    }

    self cicada_util::setpers(key + "_" + (count - 1), undefined);
    self cicada_util::setpers(key + "_count", count - 1);
}

function clear_stack(key)
{
    count = self stack_count(key);

    for (i = 0; i < count; i++)
        self cicada_util::setpers(key + "_" + i, undefined);

    self cicada_util::setpers(key + "_count", 0);
}

function randomize_stack(key)
{
    effects = effect_list();

    if (!effects.size)
    {
        self cicada_util::message("^1no effects loaded yet");
        return;
    }

    total = self cicada_util::getpersint("stack_size");

    if (total < 1)
        total = self stack_count(key);

    if (total < 1)
        total = 1;

    self clear_stack(key);

    for (i = 0; i < total; i++)
        self cicada_util::setpers(key + "_" + i, effects[randomint(effects.size)]);

    self cicada_util::setpers(key + "_count", total);
}

function manage_stack(action, key)
{
    switch (action)
    {
        case "add current":
            self add_stack_effect(self cicada_util::getpers(key), key);
            break;

        case "remove last":
            self remove_stack_effect(key);
            break;

        case "clear":
            self clear_stack(key);
            break;

        case "randomize":
            self randomize_stack(key);
            break;
    }

    self cicada_menu::update_menu();
}

function play_stack(key, origin)
{
    count = self stack_count(key);

    if (!count)
    {
        play_effect(self cicada_util::getpers(key), origin);
        return;
    }

    for (i = 0; i < count; i++)
        play_effect(self stack_effect(key, i), origin);
}

function preview_stack(key)
{
    self play_stack(key, self.origin + (0, 0, 50));
}

function sound_stack_summary(key)
{
    count = self stack_count(key);

    if (!count)
    {
        single = self cicada_util::getpers(key);
        return isdefined(single) ? ("^:" + sound_label(single)) : "^1nothing stacked";
    }

    return "^:" + count + " ^7sounds stacked";
}

function add_stack_sound(name, key)
{
    if (!isdefined(name) || !soundexists(name))
    {
        self cicada_util::message(cicada_util::warn("that sound is not loaded"));
        return;
    }

    count = self stack_count(key);

    self cicada_util::setpers(key + "_" + count, name);
    self cicada_util::setpers(key + "_count", count + 1);
    self cicada_util::message("^:" + sound_label(name) + " ^7stacked");
    self playlocalsound(name);
    self cicada_menu::update_menu();
}

function randomize_sound_stack(key, group)
{
    if (!isdefined(group))
        group = cicada_catalog::sound_groups()[randomint(cicada_catalog::sound_groups().size)];

    list = cicada_catalog::sounds_in(group);

    if (!list.size)
    {
        self cicada_util::message("^1no sounds loaded in that group");
        return;
    }

    total = self cicada_util::getpersint("stack_size");

    if (total < 1)
        total = self stack_count(key);

    if (total < 1)
        total = 1;

    self clear_stack(key);

    for (i = 0; i < total; i++)
        self cicada_util::setpers(key + "_" + i, list[randomint(list.size)]);

    self cicada_util::setpers(key + "_count", total);
}

function manage_sound_stack(action, key)
{
    switch (action)
    {
        case "add current":
            self add_stack_sound(self cicada_util::getpers(key), key);
            break;

        case "remove last":
            self remove_stack_effect(key);
            break;

        case "clear":
            self clear_stack(key);
            break;

        case "randomize":
            self randomize_sound_stack(key, undefined);
            break;
    }

    self cicada_menu::update_menu();
}

function play_sound_stack(key)
{
    count = self stack_count(key);

    if (!count)
    {
        single = self cicada_util::getpers(key);

        if (isdefined(single) && soundexists(single))
            self playlocalsound(single);

        return;
    }

    gap = self cicada_util::getpersfloat(key + "_gap");

    for (i = 0; i < count; i++)
    {
        name = self stack_effect(key, i);

        if (isdefined(name) && soundexists(name))
            self playlocalsound(name);

        if (gap > 0)
            wait gap;
    }
}

function preview_sound_stack(key)
{
    self thread [[&play_sound_stack]](key);
}

function bot_effect_key(player_)
{
    if (isdefined(player_.team) && isdefined(self.team) && player_.team == self.team)
        return "bot_effect_friendly";

    return "bot_effect_enemy";
}

function bot_effects(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        height = self cicada_util::getpersfloat("bot_effect_height");

        foreach (player_ in level.players)
        {
            if (!cicada_util::is_bot(player_) || !isalive(player_) || player_.sessionstate != "playing")
                continue;

            self play_stack(self bot_effect_key(player_), player_.origin + (0, 0, height));
        }

        wait (self cicada_util::getpersfloat("bot_effect_time"));
    }
}

function zombie_effects(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        height = self cicada_util::getpersfloat("zombie_effect_height");
        target = self cicada_util::getpers("zombie_effect_target");

        foreach (zombie in cicada_pve::zombies())
            if (cicada_pve::effect_match(zombie, target, self))
                self play_stack("zombie_effect", zombie.origin + (0, 0, height));

        wait (self cicada_util::getpersfloat("zombie_effect_time"));
    }
}

function randomize_effect(key)
{
    effects = effect_list();
    if (!effects.size)
    {
        self cicada_util::message("^1no effects loaded yet");
        return;
    }

    self cicada_util::setpers(key, effects[randomint(effects.size)]);
}

function hide_hud(key)
{
    self setclientomnvar("ui_hide_hud", 1);
}

function show_hud(key)
{
    self setclientomnvar("ui_hide_hud", 0);
}

function disable_oob(key)
{
    outofbounds::enableoobimmunity(self);
    self.allowedintrigger = 1;
    self.alreadytouchingtrigger = 0;
}

function enable_oob(key)
{
    outofbounds::disableoobimmunity(self);
    self.allowedintrigger = 0;
    self.alreadytouchingtrigger = undefined;
}

function collect_barriers()
{
    if (isdefined(level.cicada_barriers))
        return;

    level.cicada_barriers = [];

    store_barriers(getentarray("trigger_hurt", "classname"));
    store_barriers(getentarray("trigger_multiple", "classname"));
    store_barriers(getentarray("trigger_once", "classname"));
    store_barriers(getentarray("barrier", "targetname"));
}

function store_barriers(entities)
{
    foreach (entity in entities)
    {
        entry = spawnstruct();
        entry.entity = entity;
        entry.origin = entity.origin;
        level.cicada_barriers[level.cicada_barriers.size] = entry;
    }
}

function remove_barriers(key)
{
    collect_barriers();

    foreach (entry in level.cicada_barriers)
        if (isdefined(entry.entity))
            entry.entity.origin = (999999, 999999, 999999);
}

function restore_barriers(key)
{
    if (!isdefined(level.cicada_barriers))
        return;

    foreach (entry in level.cicada_barriers)
        if (isdefined(entry.entity))
            entry.entity.origin = entry.origin;
}

function set_timescale(value)
{
    scale = float(value);
    self cicada_util::setpers("timescale", scale);

    // park timescale in menu to be safe..
    if (self cicada_util::in_menu())
        return;

    setslowmotion(scale, scale, 0);
}

function menu_suspend()
{
    setslowmotion(1, 1, 0);
    setdvar("sv_snapshotDelay", 0);
}

function menu_resume()
{
    scale = self cicada_util::getpersfloat("timescale");
    setslowmotion(scale, scale, 0);
    setdvar("sv_snapshotDelay", self cicada_util::getpersint("snapshot_delay"));
}

function set_timescale_mode(value)
{
    self cicada_util::setpers("timescale_mode", value);
    self notify("cicada_timescale_mode");
    self thread [[&watch_timescale_reset]]();
}

function watch_timescale_reset()
{
    self endon("disconnect");
    self endon("cicada_timescale_mode");

    mode = self cicada_util::getpers("timescale_mode");

    if (mode == "round end")
        level waittill("game_ended");
    else if (mode == "start of killcam")
        self waittill("showing_final_killcam");
    else
        return;

    setslowmotion(1, 1, 0);
}

function set_snapshot_delay(value)
{
    delay = int(value);
    self cicada_util::setpers("snapshot_delay", delay);

    if (self cicada_util::in_menu())
        return;

    setdvar("sv_snapshotDelay", delay);
}

// don't add an endon here - if killed early the game will infinitely lag
function snapshot_burst()
{
    if (istrue(level.cicada_snapshot_burst))
        return;

    level.cicada_snapshot_burst = true;

    // read before the wait, because the player can be gone by the time it is over
    hold = self cicada_util::getpersfloat("snapshot_bind_time");

    setdvar("sv_snapshotDelay", self cicada_util::getpersint("snapshot_bind_delay"));
    wait hold;
    setdvar("sv_snapshotDelay", 0);

    level.cicada_snapshot_burst = false;
}

function watch_snapshot()
{
    self endon("disconnect");
    self endon("cicada_snapshot_mode");

    self waittill("showing_final_killcam");
    setdvar("sv_snapshotDelay", 0);
}

function restore_snapshot()
{
    self endon("disconnect");
    level endon("game_ended");

    self cicada_util::wait_prematch();

    if (!self cicada_util::in_menu())
        setdvar("sv_snapshotDelay", self cicada_util::getpersint("snapshot_delay"));

    self notify("cicada_snapshot_mode");
    self thread [[&watch_snapshot]]();
}

function set_super_charge_rate(value)
{
    rate = int(value);
    self cicada_util::setpers("super_charge_rate", rate);

    setdvar("scr_game_superfastchargerate", rate);
    level.superfastchargerate = rate;
}

function restore_super_charge_rate()
{
    self endon("disconnect");
    level endon("game_ended");

    self cicada_util::wait_prematch();

    self set_super_charge_rate(self cicada_util::getpersint("super_charge_rate"));
}

function restore_timescale()
{
    self endon("disconnect");
    level endon("game_ended");

    self cicada_util::wait_prematch();

    if (!self cicada_util::in_menu())
    {
        scale = self cicada_util::getpersfloat("timescale");
        setslowmotion(scale, scale, 0);
    }

    self notify("cicada_timescale_mode");
    self thread [[&watch_timescale_reset]]();
}

function refuse_feature(key, reason)
{
    self cicada_util::setpers(key, false);
    self cicada_util::message_bold(reason);
    self cicada_menu::update_menu();
}

function timer_held()
{
    return istrue(self cicada_util::getpers("freeze_timer")) || istrue(self cicada_util::getpers("auto_pause"));
}

function freeze_timer(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    if (scripts\mp\utility\game::getbasegametype() != "sd")
        return;

    if (istrue(self cicada_util::getpers("auto_plant")))
    {
        self refuse_feature(key, "^1turn auto plant off first");
        return;
    }

    self cicada_util::wait_prematch();

    gamelogic::pausetimer();
}

function round_limit()
{
    if (isdefined(level.winlimit) && level.winlimit > 1)
        return level.winlimit;

    return 6;
}

function round_cap()
{
    cap = self cicada_util::getpersint("round_cap");
    top = round_limit() - 1;

    if (cap > top)
        cap = top;

    if (cap < 0)
        cap = 0;

    return cap;
}

function round_score()
{
    cap = self round_cap();

    if (!istrue(self cicada_util::getpers("round_random")))
        return cap;

    return randomint(cap + 1);
}

function apply_round_scores()
{
    if (!isdefined(game["roundsWon"]))
        return;

    state = spawnstruct();
    state.team1score = self round_score();
    state.team2score = self round_score();

    gamestaterestore::function_cc67f138614157c4(state);

    // self cicada_util::message("round scores ^:" + state.team1score + " ^7- ^:" + state.team2score + " ^7for the next round");
}

function round_reset(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));

    level waittill("game_ended");

    self apply_round_scores();
}

function pause_delay()
{
    limit = scripts\mp\utility\game::gettimelimit();

    if (!isdefined(limit) || limit <= 10)
        limit = 90;

    if (istrue(self cicada_util::getpers("pause_random")))
        return randomintrange(5, int(limit) - 5);

    delay = self cicada_util::getpersint("pause_after");

    if (delay > int(limit) - 5)
        delay = int(limit) - 5;

    if (delay < 1)
        delay = 1;

    return delay;
}

function auto_pause(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    if (istrue(self cicada_util::getpers("auto_plant")))
    {
        self refuse_feature(key, "^1turn auto plant off first");
        return;
    }

    self cicada_util::wait_prematch();

    delay = self pause_delay();

    wait delay;

    gamelogic::pausetimer();
}

function unpause_timer(key)
{
    gamelogic::resumetimer();
}

function plant_zone()
{
    if (!isdefined(level.bombzones))
        return undefined;

    foreach (zone in level.bombzones)
        if (isdefined(zone) && !istrue(zone.bombplanted))
            return zone;

    return undefined;
}

function plant_window()
{
    early = self cicada_util::getpersint("plant_early");
    late = self cicada_util::getpersint("plant_late");

    if (late < early)
        late = early;

    return randomintrange(early, late + 1);
}

function auto_plant(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    if (scripts\mp\utility\game::getbasegametype() != "sd")
    {
        self refuse_feature(key, "^1search and destroy only");
        return;
    }

    if (self timer_held())
    {
        self refuse_feature(key, "^1turn the timer holds off first");
        return;
    }

    self cicada_util::wait_prematch();

    window = self plant_window();
    left = gamelogic::gettimeremaining() / 1000;

    while (!istrue(level.bombplanted) && left > window)
    {
        wait 0.25;
        left = gamelogic::gettimeremaining() / 1000;
    }

    if (istrue(level.bombplanted))
        return;

    zone = plant_zone();

    if (!isdefined(zone))
    {
        self cicada_util::message(cicada_util::warn("no bomb site to plant on"));
        return;
    }

    level thread [[&obj_bombzone::bombzone_onbombplanted]](zone, self);
    self cicada_util::message("bomb ^2planted ^7with ^:" + int(left) + "s ^7left");
}

function unfreeze_timer(key)
{
    gamelogic::resumetimer();
}

function skip_prematch()
{
    level notify("cicada_skip_prematch"); // end old thread if it exists
    level endon("cicada_skip_prematch");
    level endon("game_ended");

    if (scripts\mp\utility\game::getbasegametype() != "dm")
        return;

    setdvar("scr_game_matchstarttime", 0);

    while (!istrue(level.prematchstarted))
    {
        level.prematchperiodend = 0;
        level.prematchperiod = 0;
        waitframe();
    }

    if (isdefined(level.matchcountdowntime))
        cancel_countdown();
}

function cancel_countdown()
{
    level notify("match_start_timer_beginning");
    level.matchcountdowntime = undefined;

    foreach (player_ in level.players)
    {
        playerlogic::clearprematchlook(player_);
        player_ setclientomnvar("ui_match_start_countdown", -1);
        player_ setclientomnvar("ui_match_in_progress", 1);

        if (!is_frozen(player_))
            player_ freezecontrols(0);
    }

    flags::gameflagset("prematch_values_reset");
    visionsetnaked("", 0);
    level notify("matchStartTimer_done");
}

function fast_restart()
{
    if (scripts\mp\utility\game::getbasegametype() != "sd")
        setdvar("scr_game_matchstarttime", 0);

    map_restart(1);
}

function end_round()
{
    setomnvarforallclients("ui_objective_state", 0);
    setomnvar("ui_bomb_interacting", 0);
    thread [[&gamelogic::endgame]](game["attackers"], game["end_reason"][tolower(game[game["defenders"]]) + "_eliminated"]);
}

function may_manage_score()
{
    kind = scripts\mp\utility\game::getbasegametype();

    return kind == "dm" || kind == "war";
}

function score_limit()
{
    if (isdefined(level.scorelimit) && level.scorelimit > 0)
        return int(level.scorelimit);

    if (isdefined(level.roundscorelimit) && level.roundscorelimit > 0)
        return int(level.roundscorelimit);

    return 0;
}

function score_now()
{
    if (istrue(level.teambased))
    {
        if (isdefined(self.team) && isdefined(game["teamScores"]) && isdefined(game["teamScores"][self.team]))
            return int(game["teamScores"][self.team]);

        return 0;
    }

    return isdefined(self.score) ? int(self.score) : 0;
}

function private give_score(player_, points)
{
    if (!isdefined(player_) || !isplayer(player_))
        return;

    gamescore::_setplayerscore(player_, points);

    player_.score = points;
    player_.pers["score"] = points;
    player_.kills = points;
    player_.pers["kills"] = points;
}

function private give_team_score(team, points)
{
    if (!isdefined(team) || !istrue(level.teambased))
        return;

    gamescore::_setteamscore(team, points, 0);
}

function private score_below(back)
{
    limit = score_limit();

    if (limit < 1)
    {
        self cicada_util::message(cicada_util::warn("no score limit on this mode"));
        return;
    }

    points = limit - back;

    if (points < 0)
        points = 0;

    if (istrue(level.teambased))
        give_team_score(self.team, points);

    give_score(self, points);
    self cicada_util::message("^:" + points + " ^7of ^:" + limit);
}

function reset_scores()
{
    foreach (player_ in level.players)
        give_score(player_, 0);

    if (istrue(level.teambased) && isdefined(game["teamScores"]))
        foreach (team, value in game["teamScores"])
            give_team_score(team, 0);

    self cicada_util::message("scores ^1reset");
}

function manage_score(action)
{
    switch (action)
    {
        case "fast last":
            self score_below(1);
            break;

        case "two piece":
            self score_below(2);
            break;

        case "reset scores":
            self reset_scores();
            break;
    }

    self cicada_menu::update_menu();
}

function drop_weapon(which)
{
    current = self getcurrentweapon();
    primaries = self getweaponslistprimaries();

    switch (which)
    {
        case "current":
            self dropitem(current);
            wait 0.05;
            self inventory_utility::_switchtoweaponimmediate(primaries[0]);
            break;
        case "secondary":
            next = self cicada_weapon::next_weapon();
            self inventory_utility::_switchtoweaponimmediate(next);
            self dropitem(next);
            wait 0.05;
            self inventory_utility::_switchtoweaponimmediate(primaries[0]);
            break;
        case "all":
            foreach (item in primaries)
            {
                self inventory_utility::_switchtoweaponimmediate(item);
                wait 0.05;
                self dropitem(item);
            }
            break;
    }
}

function take_weapon()
{
    self takeweapon(self getcurrentweapon());
}

function refill_ammo(which)
{
    if (which == "current")
    {
        self cicada_weapon::refill(self getcurrentweapon());
        return;
    }

    foreach (item in self getweaponslistall())
        self cicada_weapon::refill(item);
}

function kill_player(player_)
{
    player_ suicide();
}

function respawn_player(player_)
{
    if (!isdefined(player_) || !isplayer(player_))
        return;

    if (player_.sessionstate == "playing")
    {
        if (player_ isinvulnerable())
            player_ disableinvulnerability();

        player_ suicide();
    }

    player_ player::updatesessionstate("spectator");
    waitframe();

    if (!isdefined(player_) || istrue(level.gameended))
        return;

    player_ thread [[&playerlogic::spawnclient]]();

    if (!player_ has_position())
        return;

    for (i = 0; i < 40 && isdefined(player_) && !isalive(player_); i++)
        waitframe();

    if (!isdefined(player_) || !isalive(player_))
        return;

    waitframe();
    player_ load_position();
}

function is_auto_respawn(player_)
{
    return isdefined(player_) && istrue(player_.cicada_auto_respawn);
}

function may_auto_respawn(player_)
{
    return isdefined(player_) && !is_kill_target(player_);
}

function toggle_auto_respawn(player_)
{
    if (!isdefined(player_))
        return;

    if (is_auto_respawn(player_))
    {
        player_.cicada_auto_respawn = false;
        self cicada_menu::update_menu();
        return;
    }

    if (!may_auto_respawn(player_))
    {
        self cicada_util::message(cicada_util::warn("the killcam target cannot auto respawn"));
        return;
    }

    player_.cicada_auto_respawn = true;
    self thread [[&watch_auto_respawn]](player_);
    self cicada_menu::update_menu();
}

function private watch_auto_respawn(player_)
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        if (!isdefined(player_) || !is_auto_respawn(player_))
            return;

        if (isalive(player_))
        {
            waitframe();
            continue;
        }

        if (!may_auto_respawn(player_))
        {
            waitframe();
            continue;
        }

        wait (self cicada_util::getpersfloat("bot_respawn_delay"));

        if (!isdefined(player_) || !is_auto_respawn(player_) || istrue(level.gameended))
            return;

        if (isalive(player_) || !may_auto_respawn(player_))
            continue;

        self respawn_player(player_);
    }
}

function keep_team(player_, team)
{
    player_ endon("disconnect");
    level endon("game_ended");

    for (i = 0; i < 20; i++)
    {
        wait 0.25;

        if (!isdefined(player_) || on_team(player_, team))
            continue;

        self set_team(player_, team);
    }
}

function change_team(player_)
{
    if (player_ ishost())
    {
        self cicada_util::message("^1cannot change the host team");
        return;
    }

    if (!istrue(level.teambased))
    {
        self cicada_util::message("^1no teams in this mode");
        return;
    }

    wanted = game_utility::getotherteam(player_.team)[0];

    player_ menus::addtoteam(wanted, false, true);
    player_.sessionteam = wanted;

    player_ notify("luinotifyserver", "team_select", 0);
    player_ notify("luinotifyserver", "class_select", player_.pers["class"]);

    self respawn_player(player_);

    if (cicada_util::is_bot(player_))
    {
        player_.bot_team = wanted;
        player_.pers["bot_team"] = wanted;
        self thread [[&keep_team]](player_, wanted);
    }

    self cicada_util::message(player_ cicada_util::player_name() + " ^7is now " + self team_label(player_));
    self cicada_menu::update_menu();
}

function place_player(target, destination)
{
    target setorigin(destination);

    if (!cicada_util::is_bot(target))
        return;

    target cicada_util::setmappers("position", destination);
    target cicada_util::setmappers("angles", target getplayerangles());
}

function teleport_targets()
{
    return cicada_util::list("enemy,friendly,agent,zombie");
}

function teleport_picks()
{
    return cicada_util::list("selected,nearest,crosshair,random");
}

function teleport_class(ent)
{
    if (!isdefined(ent))
        return "agent";

    if (isplayer(ent))
        return self is_friendly(ent) ? "friendly" : "enemy";

    return cicada_pve::is_actor(ent) ? "agent" : "zombie";
}

function teleport_name(ent)
{
    if (!isdefined(ent))
        return "nothing";

    if (isplayer(ent))
        return ent cicada_util::player_name();

    return cicada_pve::zombie_name(ent);
}

function teleport_pool(mode)
{
    pool = [];

    if (!isdefined(mode))
        mode = "enemy";

    if (mode == "enemy" || mode == "friendly")
    {
        foreach (player_ in level.players)
        {
            if (player_ == self || !isalive(player_))
                continue;

            if (self teleport_class(player_) != mode)
                continue;

            pool[pool.size] = player_;
        }

        return pool;
    }

    foreach (agent in cicada_pve::zombies())
        if (self teleport_class(agent) == mode)
            pool[pool.size] = agent;

    return pool;
}

function is_teleport_target(ent)
{
    return isdefined(ent) && istrue(ent.cicada_teleport_target);
}

function toggle_teleport_target(ent)
{
    if (!isdefined(ent))
        return;

    wanted = !is_teleport_target(ent);

    foreach (other in self teleport_pool(self teleport_class(ent)))
        other.cicada_teleport_target = 0;

    ent.cicada_teleport_target = wanted;

    if (wanted)
        self cicada_util::message("teleport target ^:" + self teleport_name(ent));
    else
        self cicada_util::message("teleport target ^1cleared");

    self cicada_menu::update_menu();
}

function teleport_selected(mode)
{
    foreach (ent in self teleport_pool(mode))
        if (is_teleport_target(ent))
            return ent;

    return undefined;
}

function teleport_summary(mode)
{
    picked = self teleport_selected(mode);

    if (!isdefined(picked))
        return "^1nothing marked ^7- mark one in its menu";

    return "^:" + self teleport_name(picked);
}

function teleport_choice()
{
    mode = self cicada_util::getpers("teleport_mode");
    pool = self teleport_pool(mode);

    if (!pool.size)
        return undefined;

    pick = self cicada_util::getpers("teleport_pick");

    if (pick == "selected")
        return self teleport_selected(mode);

    if (pick == "random")
        return pool[randomint(pool.size)];

    spot = pick == "crosshair" ? self cicada_util::crosshair() : self.origin;

    closest = undefined;
    best = 0;

    foreach (ent in pool)
    {
        gap = distance(ent.origin, spot);

        if (!isdefined(closest) || gap < best)
        {
            closest = ent;
            best = gap;
        }
    }

    return closest;
}

function teleport_spot(target)
{
    near = self cicada_util::getpersint("teleport_near_min");
    far = self cicada_util::getpersint("teleport_near_max");

    if (far < near)
        far = near;

    gap = randomintrange(near, far + 1);
    away = anglestoforward((0, randomfloat(360), 0)) * gap;
    lift = self cicada_util::getpersint("teleport_height");

    spot = target.origin + away;
    ground = playerphysicstrace(spot + (0, 0, 72), spot - (0, 0, 160));

    if (isdefined(ground))
        spot = ground;

    return spot + (0, 0, lift);
}

function private teleport_face(target)
{
    look = target.origin - self.origin;

    if (length(look) < 1)
        return;

    look = vectortoangles(look);
    self setplayerangles((0, look[1], 0));
}

function private teleport_hurt(target)
{
    amount = self cicada_util::getpersint("teleport_damage_amount");

    if (!isalive(target))
        return;

    if (isplayer(target))
    {
        if (target isinvulnerable())
            return;

        self deal_damage(target, amount);
        return;
    }

    self damage_zombie(target, amount);
}

function private teleport_knock(target)
{
    push = self cicada_util::getpersfloat("teleport_push_power");
    lift = self cicada_util::getpersfloat("teleport_push_lift");

    away = self.origin - target.origin;
    away = (away[0], away[1], 0);

    if (length(away) < 1)
        away = anglestoforward((0, self.angles[1], 0)) * -1;

    away = vectornormalize(away);

    if (self isonground())
    {
        self setvelocity((0, 0, 200));
        waitframe();
        waitframe();
    }

    self setvelocity(away * push + (0, 0, lift));
}

function private teleport_sound()
{
    name = self cicada_util::getpers("teleport_sound_name");

    if (!isdefined(name))
        name = self cicada_util::getpers("last_sound");

    if (!isdefined(name) || !soundexists(name))
        return;

    self playlocalsound(name);
}

function teleport_near()
{
    if (self.sessionstate != "playing")
        return;

    target = self teleport_choice();

    if (!isdefined(target))
    {
        self cicada_util::message_bold("^1nothing to teleport to");
        return;
    }

    spot = self teleport_spot(target);

    self play_stack("teleport_effect", self.origin + (0, 0, 30));

    place_player(self, spot);

    if (istrue(self cicada_util::getpers("teleport_face_target")))
        self teleport_face(target);

    self play_stack("teleport_effect", spot + (0, 0, 30));

    if (istrue(self cicada_util::getpers("teleport_sound")))
        self teleport_sound();
    else
        self cicada_util::sound("scavenger_pack_pickup");

    if (istrue(self cicada_util::getpers("teleport_vision")))
        self toggle_vision();

    if (istrue(self cicada_util::getpers("teleport_canswap")))
        self cicada_weapon::canswap();

    if (istrue(self cicada_util::getpers("teleport_anim")))
        self thread [[&play_anim_once]]();

    if (istrue(self cicada_util::getpers("teleport_damage")))
        self teleport_hurt(target);

    if (istrue(self cicada_util::getpers("teleport_push")))
        self teleport_knock(target);
}

function teleport_player(target, destination)
{
    if (target.sessionstate != "playing")
        return;

    place_player(target, destination);
    self cicada_util::sound("scavenger_pack_pickup");
}

function restore_bot_position()
{
    self endon("disconnect");
    self endon("death");

    self.cicada_launched = false;

    wait 0.05;

    if (self has_position())
        self load_position();
}

function manage_teleport(where, player_)
{
    switch (where)
    {
        case "to crosshair":
            self teleport_player(player_, self cicada_util::crosshair());
            break;
        case "to me":
            self teleport_player(player_, self.origin);
            break;
        case "to them":
            self teleport_player(self, player_.origin);
            break;
        default:
            break;
    }
}

function look_at_me(player_)
{
    player_ setplayerangles(vectortoangles(self.origin - player_.origin));
}

function give_bot_weapon(player_, weapon)
{
    player_ giveweapon(weapon);
    player_ switchtoweapon(weapon);
}

function set_class(newclass)
{
    self.pers["class"] = newclass;
    self.gamemode_chosenclass = newclass;
}

function reload_class()
{
    scripts\mp\class::setclass(self.pers["class"]);
    self.tag_stowed_back = undefined;
    self.tag_stowed_hip = undefined;
    scripts\mp\class::giveloadout(self.team, self.pers["class"], undefined, 1);

    super = supers::getcurrentsuper();
    if (!isdefined(super))
        return;

    self thread [[&supers::givesuperweapon]](super);
    self thread [[&supers::givesuperpoints]](supers::getsuperpointsneeded());
}

function next_class()
{
    index = (scripts\mp\class::getclassindex(self.pers["class"]) + 2);
    if (index > self cicada_util::getpersint("class_wrap"))
        index = 1;

    self set_class("custom" + index);
    self reload_class();
    self thread [[&after_class_change]]();
}

function after_class_change()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    wait 0.5;

    if (istrue(self cicada_util::getpers("class_empty_clip")))
        self cicada_weapon::empty_clip();

    if (istrue(self cicada_util::getpers("class_one_bullet")))
        self cicada_weapon::one_bullet();

    if (istrue(self cicada_util::getpers("class_canswap")))
        self cicada_weapon::canswap();

    if (istrue(self cicada_util::getpers("class_illusion")))
        self cicada_weapon::illusion();

    if (istrue(self cicada_util::getpers("class_anim")))
        self play_class_anim_once();
}

function one_handed_gun()
{
    if (!isalive(self) || !self cicada_util::prematch_done())
        return;

    self cicada_util::message_bold("^5shoot your weapon");
    self cicada_weapon::nacto("snapshot_grenade_mp", true);

    wait 2;

    self notify("luinotifyserver", "class_select", self.pers["class"]);
    self set_class("custom" + (scripts\mp\class::getclassindex(self.pers["class"]) + 1));
    self reload_class();
}

function position_summary()
{
    origin = self cicada_util::getmappers("position");

    if (!isdefined(origin))
        return "^1nothing saved";

    return "^:" + int(origin[0]) + " ^7/ ^:" + int(origin[1]) + " ^7/ ^:" + int(origin[2]);
}

function control_keys()
{
    return cicada_util::list("control_select,control_back,control_close");
}

function set_control(label, key)
{
    value = self cicada_menu::control_from_label(label, key);

    if (key != "control_hold" && key != "control_open")
    {
        foreach (other in control_keys())
        {
            if (other == key)
                continue;

            if (self cicada_util::getpers(other) == value)
            {
                self cicada_util::message(cicada_util::warn("that button is already used"));
                self cicada_menu::update_menu();
                return;
            }
        }
    }

    self cicada_util::setpers(key, value);
    self cicada_menu::update_menu();
}

function reset_controls()
{
    self cicada_util::setpers("control_hold", "ads");
    self cicada_util::setpers("control_open", "actionslot 1");
    self cicada_util::setpers("control_select", "gostand");
    self cicada_util::setpers("control_back", "use");
    self cicada_util::setpers("control_close", "melee_zoom");
    self cicada_util::message("menu controls reset");
    self cicada_menu::update_menu();
}

function set_anim(id)
{
    self cicada_util::setpers("anim_id", id);
}

function max_anim_slots()
{
    return 8;
}

function anim_slot_count()
{
    count = self cicada_util::getpersint("anim_slots");

    if (count < 1)
        return 0;

    if (count > max_anim_slots())
        return max_anim_slots();

    return count;
}

function anim_slot_name(index)
{
    return "anim slot " + index;
}

function anim_slot_key(index, part)
{
    return "anim_slot_" + index + "_" + part;
}

function anim_slot_id(index)
{
    return self cicada_util::getpersint(anim_slot_key(index, "id"));
}

function anim_slot_hands(index)
{
    hands = self cicada_util::getpers(anim_slot_key(index, "hands"));

    return isdefined(hands) ? hands : "right";
}

function anim_slot_summary(index)
{
    button = self cicada_binds::slot_label(self cicada_util::getpers(cicada_binds::slot_key(anim_slot_name(index))));

    if (istrue(self cicada_util::getpers(anim_slot_key(index, "random"))))
        return "^:random " + self anim_slot_range_summary(index) + " ^7on " + button;

    return "^:anim " + self anim_slot_id(index) + " ^7on " + button;
}

function play_anim_slot(index)
{
    self play_anim_once(self anim_slot_pick(index), self anim_slot_hands(index) == "both");
}

function preview_anim_slot(id, index)
{
    self play_anim_once(id, self anim_slot_hands(index) == "both");
}

function private wipe_anim_slot(index)
{
    self cicada_util::setpers(anim_slot_key(index, "id"), 0);
    self cicada_util::setpers(anim_slot_key(index, "hands"), "right");
    self cicada_util::setpers(anim_slot_key(index, "random"), false);
    self cicada_util::setpers(anim_slot_key(index, "range"), true);
    self cicada_util::setpers(anim_slot_key(index, "min"), 1);
    self cicada_util::setpers(anim_slot_key(index, "max"), 150);
    self cicada_util::setpers(cicada_binds::slot_key(anim_slot_name(index)), "off");
}

function private shift_anim_slot(from, to)
{
    self cicada_util::setpers(anim_slot_key(to, "id"), self anim_slot_id(from));
    self cicada_util::setpers(anim_slot_key(to, "hands"), self anim_slot_hands(from));
    self cicada_util::setpers(anim_slot_key(to, "random"), self cicada_util::getpers(anim_slot_key(from, "random")));
    self cicada_util::setpers(anim_slot_key(to, "range"), self cicada_util::getpers(anim_slot_key(from, "range")));
    self cicada_util::setpers(anim_slot_key(to, "min"), self cicada_util::getpersint(anim_slot_key(from, "min")));
    self cicada_util::setpers(anim_slot_key(to, "max"), self cicada_util::getpersint(anim_slot_key(from, "max")));
    self cicada_util::setpers(cicada_binds::slot_key(anim_slot_name(to)), self cicada_util::getpers(cicada_binds::slot_key(anim_slot_name(from))));
}

function add_anim_slot()
{
    count = self anim_slot_count();

    if (count >= max_anim_slots())
    {
        self cicada_util::message(cicada_util::warn("no anim slots left"));
        return;
    }

    self wipe_anim_slot(count + 1);
    self cicada_util::setpers("anim_slots", count + 1);
    self cicada_util::message("anim slot ^:" + (count + 1) + " ^7added");
    self cicada_menu::update_menu();
}

function remove_anim_slot(index)
{
    count = self anim_slot_count();

    if (!count || index < 1 || index > count)
        return;

    for (i = index; i < count; i++)
        self shift_anim_slot(i + 1, i);

    self wipe_anim_slot(count);
    self cicada_util::setpers("anim_slots", count - 1);
    self cicada_util::message("anim slot ^:" + index + " ^7removed");
    self cicada_menu::new_menu();
}

function remove_last_anim_slot()
{
    count = self anim_slot_count();

    if (!count)
    {
        self cicada_util::message(cicada_util::warn("no anim slots to remove"));
        return;
    }

    self wipe_anim_slot(count);
    self cicada_util::setpers("anim_slots", count - 1);
    self cicada_util::message("anim slot ^:" + count + " ^7removed");
    self cicada_menu::update_menu();
}

function set_anim_slot_id(id, index)
{
    self cicada_util::setpers(anim_slot_key(index, "id"), id);
}

function set_anim_slot_hands(mode, index)
{
    self cicada_util::setpers(anim_slot_key(index, "hands"), mode);
}

function random_anim_id()
{
    return randomintrange(1, 151);
}

function anim_pick(id_key, random_key, range_key, min_key, max_key)
{
    if (!istrue(self cicada_util::getpers(random_key)))
        return self cicada_util::getpersint(id_key);

    wanted = self cicada_util::getpers(range_key);

    if (!isdefined(wanted) || istrue(wanted))
        return random_anim_id();

    low = self cicada_util::getpersint(min_key);
    high = self cicada_util::getpersint(max_key);

    if (low < 1)
        low = 1;

    if (high < low)
        high = low;

    return randomintrange(low, high + 1);
}

function anim_range_summary(random_key, range_key, min_key, max_key)
{
    if (!istrue(self cicada_util::getpers(random_key)))
        return "^1off";

    wanted = self cicada_util::getpers(range_key);

    if (!isdefined(wanted) || istrue(wanted))
        return "^:1 ^7to ^:150";

    return "^:" + self cicada_util::getpersint(min_key) + " ^7to ^:" + self cicada_util::getpersint(max_key);
}

function anim_slot_pick(index)
{
    return self anim_pick(anim_slot_key(index, "id"), anim_slot_key(index, "random"), anim_slot_key(index, "range"), anim_slot_key(index, "min"), anim_slot_key(index, "max"));
}

function anim_slot_range_summary(index)
{
    return self anim_range_summary(anim_slot_key(index, "random"), anim_slot_key(index, "range"), anim_slot_key(index, "min"), anim_slot_key(index, "max"));
}

function randomize_anim(id_key, hands_key)
{
    id = random_anim_id();
    self cicada_util::setpers(id_key, id);

    both = isdefined(hands_key) && self cicada_util::getpers(hands_key) == "both";

    self cicada_util::message("anim ^:" + id);
    self thread [[&play_anim_once]](id, both);
    self cicada_menu::update_menu();
}

function randomize_anim_slot(index)
{
    self randomize_anim(anim_slot_key(index, "id"), anim_slot_key(index, "hands"));
}

function set_equipment_bind(id, kind)
{
    self cicada_util::setpers("equipment_weapon", id);
    self cicada_util::setpers("equipment_kind", kind);
    self cicada_util::message("equipment bind set to ^:" + id);
}

function equipment_bind_kind()
{
    kind = self cicada_util::getpers("equipment_kind");
    return isdefined(kind) ? kind : "weapon";
}

function equipment_bind_summary()
{
    id = self cicada_util::getpers("equipment_weapon");

    if (!isdefined(id))
        return "not set";

    switch (self equipment_bind_kind())
    {
        case "primary":
            return "^:" + id + " ^7lethal";
        case "secondary":
            return "^:" + id + " ^7tactical";
        case "super":
            return "^:" + id + " ^7field upgrade";
    }

    return "^:" + id;
}

function set_class_anim(id)
{
    self cicada_util::setpers("class_anim_id", id);
}

function play_class_anim_once(id)
{
    if (!isdefined(id))
        id = self cicada_util::getpersint("class_anim_id");

    self play_anim_once(id, self cicada_util::getpers("class_anim_hands") == "both");
}

function set_anim_hands(mode)
{
    self cicada_util::setpers("anim_hands", mode);
}

function set_gesture(id)
{
    self cicada_util::setpers("gesture_id", id);
}

function vision_time()
{
    return self cicada_util::getpersfloat("vision_time");
}

function stored_vision(key)
{
    stored = self cicada_util::getpers(key);
    return isdefined(stored) ? stored : "";
}

function vision_summary(key)
{
    name = self stored_vision(key);
    return "current: ^:" + ((name == "") ? "none" : name);
}

function vision_hud_on()
{
    return istrue(self cicada_util::getpers("vision_hud"));
}

function vision_hud_pick()
{
    picked = self cicada_util::getpers("vision_hud_mode");

    if (!isdefined(picked))
        return "auto";

    return picked;
}

function vision_hud_modes()
{
    modes = [];
    modes[0] = "auto";

    foreach (label in cicada_catalog::streak_hud_labels())
        if (label != "off")
            modes[modes.size] = label;

    return modes;
}

function vision_hud_value()
{
    picked = self vision_hud_pick();

    if (picked == "auto")
        return cicada_catalog::streak_hud_guess(self stored_vision("killstreak_vision"));

    return cicada_catalog::streak_hud_value(picked);
}

function vision_hud_summary()
{
    if (!cicada_catalog::streak_hud_ready())
        return "^1no killstreak huds loaded";

    if (!self vision_hud_on())
        return "^1off";

    value = self vision_hud_value();

    if (!value)
        return "^1nothing matched";

    return "^2" + cicada_catalog::streak_hud_label_for(value);
}

function private push_hud_extras()
{
    if (istrue(self cicada_util::getpers("vision_hud_health")))
        self setclientomnvar("ui_killstreak_health", self cicada_util::getpersfloat("vision_hud_health_amount"));

    if (istrue(self cicada_util::getpers("vision_hud_countdown")))
        self setclientomnvar("ui_killstreak_countdown", gettime() + int(self cicada_util::getpersfloat("vision_hud_countdown_time") * 1000));

    if (istrue(self cicada_util::getpers("vision_hud_flares")))
        self setclientomnvar("ui_killstreak_flares", self cicada_util::getpersint("vision_hud_flare_count"));

    if (istrue(self cicada_util::getpers("vision_hud_thermal")))
        self setclientomnvar("ui_killstreak_thermal_mode", 1);

    if (istrue(self cicada_util::getpers("vision_hud_damage")))
        self setclientomnvar("ui_killstreak_damage_state", self cicada_util::getpersint("vision_hud_damage_state"));
}

function private wipe_hud_extras()
{
    self setclientomnvar("ui_killstreak_health", 0);
    self setclientomnvar("ui_killstreak_countdown", 0);
    self setclientomnvar("ui_killstreak_flares", 0);
    self setclientomnvar("ui_killstreak_thermal_mode", 0);
    self setclientomnvar("ui_killstreak_damage_state", 0);
    self setclientomnvar("ui_killstreak_use_widget", 0);
}

function apply_vision_hud()
{
    if (!self vision_hud_on())
    {
        self clear_vision_hud();
        return;
    }

    value = self vision_hud_value();

    self setclientomnvar("ui_killstreak_controls", value);

    if (!value)
    {
        self wipe_hud_extras();
        return;
    }

    self push_hud_extras();
}

function clear_vision_hud()
{
    self setclientomnvar("ui_killstreak_controls", 0);
    self wipe_hud_extras();
}

function set_vision_hud(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_vision_hud();
    self cicada_menu::update_menu();
}

function flip_vision_hud(key)
{
    self cicada_util::setpers(key, !istrue(self cicada_util::getpers(key)));
    self apply_vision_hud();
    self cicada_menu::update_menu();
}

function apply_visions()
{
    self visionsetnakedforplayer(self stored_vision("vision"), self vision_time());
    self visionsetkillstreakforplayer(self stored_vision("killstreak_vision"), self vision_time());
    self apply_vision_hud();
}

function set_vision(name)
{
    self cicada_util::setpers("vision", name);
    self.cicada_vision_on = true;
    self visionsetnakedforplayer(name, self vision_time());
    self cicada_util::message("vision set to ^:" + name);
}

function set_killstreak_vision(name)
{
    self cicada_util::setpers("killstreak_vision", name);
    self.cicada_vision_on = true;
    self visionsetkillstreakforplayer(name, self vision_time());
    self apply_vision_hud();
    self cicada_util::message("killstreak vision set to ^:" + name);
}

function clear_visions()
{
    self cicada_util::setpers("vision", "");
    self cicada_util::setpers("killstreak_vision", "");

    self.cicada_vision_on = false;

    self visionsetnakedforplayer("", self vision_time());
    self visionsetkillstreakforplayer("", self vision_time());
    self visionsetthermalforplayer("", 0);

    self thermalvisionoff();
    self painvisionoff();
    self nightvisionviewoff();
    self clear_vision_hud();

    self cicada_util::message("visions ^1cleared");
    self cicada_menu::update_menu();
}

// bind: flips the stored visionsets on and off
function toggle_vision()
{
    if (istrue(self.cicada_vision_on))
    {
        self.cicada_vision_on = false;
        self visionsetnakedforplayer("", self vision_time());
        self visionsetkillstreakforplayer("", self vision_time());
        self clear_vision_hud();
        return;
    }

    self.cicada_vision_on = true;
    self apply_visions();
}

function set_vision_effect(value, kind)
{
    on = (value == "on");

    switch (kind)
    {
        case "thermal":
            if (on)
                self thermalvisionon();
            else
                self thermalvisionoff();
            break;

        case "pain":
            if (on)
                self painvisionon();
            else
                self painvisionoff();
            break;

        case "night":
            if (on)
                self nightvisionviewon();
            else
                self nightvisionviewoff();
            break;
    }

    self cicada_util::setpers("vision_" + kind, value);
}

function apply_defaults()
{
    self cicada_util::initpers("messages", true);
    self cicada_util::initpers("sounds", true);
    self cicada_util::initpers("snapshot_delay", 0);
    self cicada_util::initpers("snapshot_bind_delay", 500);
    self cicada_util::initpers("snapshot_bind_time", 1);

    self cicada_util::initpers("instaswaps_time", 0.3);
    self cicada_util::initpers("auto_prone_mode", "air");
    self cicada_util::initpers("anim_id", 0);
    self cicada_util::initpers("anim_slots", 0);
    self cicada_util::initpers("bot_respawn_delay", 3);
    self cicada_util::initpers("equipment_aimbot", false);
    self cicada_util::initpers("equipment_aim_mode", "both");
    self cicada_util::initpers("equipment_aim_range", 2000);
    self cicada_util::initpers("equipment_aim_speed", 1200);
    self cicada_util::initpers("equipment_aim_height", 20);
    self cicada_util::initpers("equipment_aim_zombies", true);
    self cicada_util::initpers("equipment_aim_enemies", true);
    self cicada_util::initpers("equipment_aim_rockets", true);
    self cicada_util::initpers("equipment_aim_any", false);
    self cicada_util::initpers("auto_chute", false);
    self cicada_util::initpers("chute_fall_time", 3);
    self cicada_util::initpers("chute_freefall", false);
    self cicada_util::initpers("chute_can_cut", true);
    self cicada_util::initpers("chute_third", true);
    self cicada_util::initpers("chute_smoke", false);
    self cicada_util::initpers("chute_speed", 400);
    self cicada_util::initpers("chute_height", 400);
    self cicada_util::initpers("redeploy", false);
    self cicada_util::initpers("chute_redeploy_height", 256);
    self cicada_util::initpers("chute_redeploy_input", "double jump");
    self cicada_util::initpers("move_jump", true);
    self cicada_util::initpers("move_sprint", true);
    self cicada_util::initpers("move_crouch", true);
    self cicada_util::initpers("move_prone", true);
    self cicada_util::initpers("move_stand", true);
    self cicada_util::initpers("move_melee", true);
    self cicada_util::initpers("move_fire", true);
    self cicada_util::initpers("move_speed", 1);
    self cicada_util::initpers("zone_radius", 400);
    self cicada_util::initpers("zone_damage", 20);
    self cicada_util::initpers("zone_rate", 1);
    self cicada_util::initpers("pick_zone", "place");
    self cicada_util::initpers("pick_wire", "save point");
    self cicada_util::initpers("zone_enemies", true);
    self cicada_util::initpers("zone_hurt_owner", false);
    self cicada_util::initpers("wire_reach", 24);
    self cicada_util::initpers("wire_damage", 200);
    self cicada_util::initpers("wire_blast", 160);
    self cicada_util::initpers("wire_once", true);
    self cicada_util::initpers("wire_enemies", true);
    self cicada_util::initpers("wire_hurt_owner", false);
    self cicada_util::initpers("xrounds_damage", 120);
    self cicada_util::initpers("xrounds_blast", 128);
    self cicada_util::initpers("xrounds_rate", 0.1);
    self cicada_util::initpers("station_kind", "magic box");
    self cicada_util::initpers("station_radius", 90);
    self cicada_util::initpers("station_cooldown", 2);
    self cicada_util::initpers("station_uses", 0);
    self cicada_util::initpers("station_outline", true);
    self cicada_util::initpers("pick_station", "place");
    self cicada_util::initpers("box_pool", "everything");
    self cicada_util::initpers("box_joker", 0);
    self cicada_util::initpers("buy_mode", "weapon");
    self cicada_util::initpers("station_roll_time", 0.9);
    self cicada_util::initpers("station_ride_rate", 0.25);
    self cicada_util::initpers("station_idle_rate", 1);
    self cicada_util::initpers("buy_weapon", "none");
    self cicada_util::initpers("lift_height", 400);
    self cicada_util::initpers("lift_speed", 1.5);
    //self cicada_util::initpers("link_mode", "free look");
    //self cicada_util::initpers("link_target", "next grenade");
    //self cicada_util::initpers("link_view", 1);
    //self cicada_util::initpers("link_x", 0);
    //self cicada_util::initpers("link_y", 0);
    //self cicada_util::initpers("link_z", 0);
    //self cicada_util::initpers("link_arc_right", 180);
    //self cicada_util::initpers("link_arc_left", 180);
    //self cicada_util::initpers("link_arc_top", 90);
    //self cicada_util::initpers("link_arc_bottom", 90);
    //self cicada_util::initpers("link_control", false);
    //self cicada_util::initpers("link_speed", 600);
    //self cicada_util::initpers("link_god", true);
    //self cicada_util::initpers("link_third", false);
    //self cicada_util::initpers("link_time", 0);
    //self cicada_util::initpers("link_jump_off", true);
    //self cicada_util::initpers("link_when", "when it lands");
    //self cicada_util::initpers("link_spin", false);
    self cicada_util::initpers("bot_pick", false);
    self cicada_util::initpers("agent_pick", false);
    self cicada_util::initpers("zombie_pick", false);
    self cicada_util::initpers("agent_bolt_speed", 0.5);
    self cicada_util::initpers("zombie_bolt_speed", 0.5);
    self cicada_util::initpers("chute_jump_off", true);
    //self cicada_util::initpers("link_drop", true);
    //self cicada_util::initpers("link_drop_lift", 200);
    self cicada_util::initpers("control_hold", "ads");
    self cicada_util::initpers("control_open", "actionslot 1");
    self cicada_util::initpers("control_select", "gostand");
    self cicada_util::initpers("control_back", "use");
    self cicada_util::initpers("control_close", "melee_zoom");
    self cicada_util::initpers("anim_random", false);
    self cicada_util::initpers("anim_random_range", true);
    self cicada_util::initpers("anim_min", 1);
    self cicada_util::initpers("anim_max", 150);
    self cicada_util::initpers("anim_hands", "right");
    self cicada_util::initpers("gesture_id", 0);
    self cicada_util::initpers("class_wrap", 5);
    self cicada_util::initpers("class_anim", false);
    self cicada_util::initpers("class_anim_id", 0);
    self cicada_util::initpers("class_anim_hands", "right");

    self cicada_util::initpers("aimbot_mode", "all snipers");
    self cicada_util::initpers("hitmarker_mode", "selected weapons");
    self cicada_util::initpers("aimbot_range", 1500);
    self cicada_util::initpers("aimbot_zombies", true);
    self cicada_util::initpers("aimbot_delay", 0);
    self cicada_util::initpers("kill_effects", false);
    self cicada_util::initpers("tracer_count", 3);

    self cicada_util::initpers("position_step", 10);
    self cicada_util::initpers("timescale", 1.0);
    self cicada_util::initpers("timescale_mode", "start of killcam");

    self cicada_util::initpers("random_primary", "snipers");
    self cicada_util::initpers("random_secondary", "random");
    self cicada_util::initpers("random_lethal", "random");
    self cicada_util::initpers("random_tactical", "random");
    self cicada_util::initpers("random_class_streaks", false); // TODO: improve in a bit
    self cicada_util::initpers("random_class_super", false);
    self cicada_util::initpers("random_class_camo", false);
    self cicada_util::initpers("random_class_gloves", true);
    self cicada_util::initpers("random_class_blueprints", false);
    self cicada_util::initpers("random_class_attachments", true);
    self cicada_util::initpers("random_class_auto", false);

    self cicada_util::initpers("damage_amount", 50);
    self cicada_util::initpers("flash_amount", 1);
    self cicada_util::initpers("shellshock_amount", 0.25);
    self cicada_util::initpers("shellshock_type", "frag_grenade_mp");
    self cicada_util::initpers("stuck_weapon", "semtex_mp");
    self cicada_util::initpers("spectate_time", 0.1);
    self cicada_util::initpers("repeater_illusion", false);
    self cicada_util::initpers("real_scavenger", true);

    self cicada_util::initpers("equipment_weapon", "semtex_mp");
    self cicada_util::initpers("equipment_kind", "weapon");
    self cicada_util::initpers("instant_tac_time", 0.05);
    self cicada_util::initpers("equipment_putaway", false);
    self cicada_util::initpers("equipment_putaway_time", 0.05);

    self cicada_util::initpers("class_one_bullet", false);
    self cicada_util::initpers("class_empty_clip", false);
    self cicada_util::initpers("class_illusion", false);
    self cicada_util::initpers("class_canswap", false);

    self cicada_util::initpers("camo", "none");
    self cicada_util::initpers("random_class_unique", true);

    self cicada_util::initpers("crate_offset", -40);
    self cicada_util::initpers("crate_height", 0);
    self cicada_util::initpers("crate_preview_time", 1);

    self cicada_util::initpers("stack_size", 3);

    self cicada_util::initpers("pve_max", 24);
    self cicada_util::initpers("pve_health", 300);
    self cicada_util::initpers("pve_delay", 0.15);
    self cicada_util::initpers("pve_range", 900);
    self cicada_util::initpers("pve_speed", "run");
    self cicada_util::initpers("pve_type", "random");
    self cicada_util::initpers("pve_spawn_type", "random");
    self cicada_util::initpers("pve_arm_armored", false);
    self cicada_util::initpers("pve_blip", true);
    self cicada_util::initpers("pve_snipers", true);
    self cicada_util::initpers("pve_weapon_chance", 0);
    self cicada_util::initpers("pve_streak_chance", 0);
    self cicada_util::initpers("pve_effect_chance", 25);
    self cicada_util::initpers("pve_boss_chance", 0);
    self cicada_util::initpers("pve_boss_health", 5000);
    self cicada_util::initpers("pve_boss_death", "nothing");
    self cicada_util::initpers("pve_killcam", true);
    self cicada_util::initpers("pve_score", true);
    self cicada_util::initpers("pve_save_state", false);
    self cicada_util::initpers("pve_autosave", false);
    self cicada_util::initpers("pve_respawn", false);
    self cicada_util::initpers("pve_respawn_delay", 3);
    self cicada_util::initpers("path_debug", false);
    self cicada_util::initpers("knockback_power", 800);
    self cicada_util::initpers("knockback_lift", 300);
    self cicada_util::initpers("knockback_damage", false);
    self cicada_util::initpers("kill_bot_mode", "all bots");
    self cicada_util::initpers("kill_bot_name", "none");
    self cicada_util::initpers("kill_agent_mode", "all agents");
    self cicada_util::initpers("kill_agent_name", "none");
    self cicada_util::initpers("kill_target", false);
    self cicada_util::initpers("pick_teleport", "to crosshair");
    self cicada_util::initpers("pick_state", "save");
    self cicada_util::initpers("pick_position", "save");
    self cicada_util::initpers("pick_crate", "spawn");
    self cicada_util::initpers("pick_bounce", "save");
    self cicada_util::initpers("pick_bots", "crosshair");
    self cicada_util::initpers("pick_stack", "add current");
    self cicada_util::initpers("pick_score", "fast last");
    self cicada_util::initpers("pick_session", "save new");
    self cicada_util::initpers("last_sound", "ui_mp_suitcase_pickup");
    self cicada_util::initpers("teleport_mode", "enemy");
    self cicada_util::initpers("teleport_pick", "selected");
    self cicada_util::initpers("teleport_near_min", 60);
    self cicada_util::initpers("teleport_near_max", 200);
    self cicada_util::initpers("teleport_height", 0);
    self cicada_util::initpers("teleport_face_target", true);
    self cicada_util::initpers("teleport_sound", false);
    self cicada_util::initpers("teleport_sound_name", "ui_mp_suitcase_pickup");
    self cicada_util::initpers("teleport_push", false);
    self cicada_util::initpers("teleport_push_power", 600);
    self cicada_util::initpers("teleport_push_lift", 200);
    self cicada_util::initpers("teleport_damage", false);
    self cicada_util::initpers("teleport_damage_amount", 50);
    self cicada_util::initpers("teleport_anim", false);
    self cicada_util::initpers("teleport_canswap", false);
    self cicada_util::initpers("teleport_vision", false);
    self cicada_util::initpers("pve_actor_type", cicada_pve::actor_names()[0]);
    self cicada_util::initpers("prop_model", cicada_props::model_list()[0]);
    self cicada_util::initpers("prop_height", 0);
    self cicada_util::initpers("prop_speed", 100);
    self cicada_util::initpers("prop_solid", false);
    self cicada_util::initpers("prop_collision", false);
    self cicada_util::initpers("prop_path_loop", true);
    self cicada_util::initpers("prop_path_face", true);
    self cicada_util::initpers("path_reset", false);
    self cicada_util::initpers("zombie_path_reset", false);
    self cicada_util::initpers("bot_effect_time", 0.5);
    self cicada_util::initpers("bot_effect_height", 40);
    self cicada_util::initpers("zombie_effect_time", 0.5);
    self cicada_util::initpers("zombie_effect_height", 40);
    self cicada_util::initpers("zombie_effect_target", "all");

    self cicada_util::initpers("menu_x", -110);
    self cicada_util::initpers("menu_y", 80);
    self cicada_util::initpers("menu_spacing", 16);
    self cicada_util::initpers("menu_limit", 7);
    self cicada_util::initpers("menu_scale", 0.95);
    self cicada_util::initpers("menu_font", "default");
    self cicada_util::initpers("menu_accent", "red");
    self cicada_util::initpers("menu_text", "white");
    self cicada_util::initpers("menu_background", "black");
    self cicada_util::initpers("menu_summary", true);
    self cicada_util::initpers("menu_version", true);

    self cicada_util::initpers("session_autosave", false);
    self cicada_util::initpers("session_autoload", true);

    self cicada_util::initpers("vision", "");
    self cicada_util::initpers("killstreak_vision", "");
    self cicada_util::initpers("after_on", false);
    self cicada_util::initpers("after_delay", 0);
    self cicada_util::initpers("after_weapon_delay", 0);
    self cicada_util::initpers("after_equipment_delay", 0);
    self cicada_util::initpers("after_streak_delay", 0);
    self cicada_util::initpers("after_effect_delay", 0);
    self cicada_util::initpers("after_sound_delay", 0);
    self cicada_util::initpers("after_anim_delay", 0);
    self cicada_util::initpers("after_spot_delay", 0);
    self cicada_util::initpers("after_weapon_on", false);
    self cicada_util::initpers("after_weapon", "none");
    self cicada_util::initpers("after_equipment_on", false);
    self cicada_util::initpers("after_equipment", "none");
    self cicada_util::initpers("after_streak_on", false);
    self cicada_util::initpers("after_streak", "none");
    self cicada_util::initpers("after_effect_on", false);
    self cicada_util::initpers("after_sound_on", false);
    self cicada_util::initpers("after_sound_gap", 0);
    self cicada_util::initpers("after_effect_here", false);
    self cicada_util::initpers("after_effect_lift", 0);
    self cicada_util::initpers("after_anim_on", false);
    self cicada_util::initpers("after_anim_id", 0);
    self cicada_util::initpers("after_anim_hands", "right");
    self cicada_util::initpers("after_anim_random", false);
    self cicada_util::initpers("after_anim_range", true);
    self cicada_util::initpers("after_anim_min", 1);
    self cicada_util::initpers("after_anim_max", 150);
    self cicada_util::initpers("after_spot_on", false);
    self cicada_util::initpers("after_x", 0);
    self cicada_util::initpers("after_y", 0);
    self cicada_util::initpers("after_z", 0);
    self cicada_util::initpers("vision_hud", false);
    self cicada_util::initpers("vision_hud_mode", "auto");
    self cicada_util::initpers("vision_hud_health", true);
    self cicada_util::initpers("vision_hud_health_amount", 1);
    self cicada_util::initpers("vision_hud_countdown", false);
    self cicada_util::initpers("vision_hud_countdown_time", 30);
    self cicada_util::initpers("vision_hud_flares", false);
    self cicada_util::initpers("vision_hud_flare_count", 3);
    self cicada_util::initpers("vision_hud_thermal", false);
    self cicada_util::initpers("vision_hud_damage", false);
    self cicada_util::initpers("vision_hud_damage_state", 0);
    self cicada_util::initpers("vision_time", 0);
    self cicada_util::initpers("vision_thermal", "off");
    self cicada_util::initpers("vision_pain", "off");
    self cicada_util::initpers("vision_night", "off");
    self cicada_util::initpers("replace_weapon", false);

    self cicada_util::initpers("camera_mode", "bezier");
    self cicada_util::initpers("camera_bezier_speed", 5);
    self cicada_util::initpers("camera_linear_time", 10);
    self cicada_util::initpers("camera_rotation", 0);
    self cicada_util::initpers("camera_fov", 0);

    self cicada_util::initpers("freeze_timer", true);
    self cicada_util::initpers("round_reset", true);
    self cicada_util::initpers("round_random", true);
    self cicada_util::initpers("round_cap", 4);
    self cicada_util::initpers("auto_pause", false);
    self cicada_util::initpers("pause_after", 30);
    self cicada_util::initpers("pause_random", false);
    self cicada_util::initpers("auto_plant", false);
    self cicada_util::initpers("plant_early", 5);
    self cicada_util::initpers("plant_late", 10);
    self cicada_util::initpers("super_charge_rate", 55);
    self cicada_util::initpers("frozen_bots", scripts\mp\utility\game::getbasegametype() == "sd");

    self cicada_util::initpers("bot_team", "enemy");
    self cicada_util::initpers("bot_difficulty", "recruit");

    self cicada_util::initpers("pve_max", 40);
    self cicada_util::initpers("pve_health", 300);

    self cicada_util::initpers("bolt_speed", 1);
    self cicada_util::initpers("bot_bolt_speed", 1);

    self cicada_util::initpers("hide_weapon", true);
    self cicada_util::initpers("hide_victim", true);
    self cicada_util::initpers("hide_perks", true);
    self cicada_util::initpers("hide_attachments", true);
    self cicada_util::initpers("hide_equipment", true);
    self cicada_util::initpers("hide_field_upgrade", true);

    self cicada_util::initpers("invincible", true);
    self cicada_util::initpers("ufo_mode", true);
    self cicada_util::initpers("save_load_binds", true);
    self cicada_util::initpers("save_slot", "dpad left");
    self cicada_util::initpers("load_slot", "dpad down");
    self cicada_util::initpers("bind_names", false);
    self cicada_util::initpers("aimbot", true);

    self default_velocity("");
    self default_velocity("bot_");
    self default_velocity("agent_");
    self default_velocity("zombie_");

    effects = effect_list();
    if (!effects.size)
        return;

    self cicada_util::initpers("kill_effect", effects[0]);
    self cicada_util::initpers("tracer_effect", effects[0]);
    self cicada_util::initpers("crate_effect", effects[0]);

    self cicada_util::initpers("inf_equipment", true);
    self cicada_util::initpers("no_oob", true);
    self cicada_util::initpers("no_barriers", true);
    self cicada_util::initpers("unlimited_lives", true);
}

function default_velocity(prefix)
{
    self cicada_util::initpers(prefix + "velocity_x", 250);
    self cicada_util::initpers(prefix + "velocity_y", 250);
    self cicada_util::initpers(prefix + "velocity_z", 250);
    self cicada_util::initpers(prefix + "velocity_step", 50);

    if (prefix != "")
        self cicada_util::initpers(prefix + "return_time", 0);
}

function monitor_class()
{
    self endon("disconnect");
    level endon("game_ended");

    //game["strings"]["change_class"] = "";

    self cicada_util::wait_prematch();

    for (;;)
    {
        self waittill("luinotifyserver", menu, response);

        if (!isalive(self))
            continue;

        if (menu != "class_select")
            continue;

        // the picked class replaces the roll, so nothing random is left to hand back
        self.cicada_random_class = undefined;
        self takeallweapons();

        scripts\mp\class::setclass(self.pers["class"]);
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;
        scripts\mp\class::giveloadout(self.pers["team"], self.pers["class"], undefined, 1);
        //self handle_camo(); // TODO

        // also give the super each class change
        super = supers::getcurrentsuper();
        if (isdefined(super)) // supers = field upgrade
        {
            self thread [[&supers::givesuperweapon]](super);
            self thread [[&supers::givesuperpoints]](supers::getsuperpointsneeded());
        }

        // give fast perks too (i dont think i want this or if i do, i want it as a pers in class options)
        // self thread give_perks();
        wait 0.05;
    }
}

function gesture_weapon(ref)
{
    weapon = makeweaponfromstring(ref);

    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = makeweapon(ref);

    return (isdefined(weapon) && !isnullweapon(weapon)) ? weapon : undefined;
}

function gesture_slot()
{
    return utility::is_player_gamepad_enabled() ? 1 : 7;
}

function private holds_gesture()
{
    return isdefined(self.gestureweapon) && self.gestureweapon != "none";
}

function play_gesture_once(id)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (istrue(self.cicada_gesture_busy))
        return;

    if (!isdefined(id))
        id = self cicada_util::getpersint("gesture_id");

    ref = cicada_catalog::gesture_ref(id);
    if (!isdefined(ref))
    {
        self cicada_util::message("^1no gestures loaded");
        return;
    }

    weapon = gesture_weapon(ref);

    if (!isdefined(weapon) && isdefined(self.loadoutgesture))
    {
        weapon = gesture_weapon(self.loadoutgesture);

        if (isdefined(weapon))
            self cicada_util::message("^1" + ref + " ^7not loaded, played equipped gesture");
    }

    if (!isdefined(weapon))
    {
        self cicada_util::message("^1unable to build ^7" + ref);
        return;
    }

    self.cicada_gesture_busy = true;

    slot = gesture_slot();
    borrowed = !self holds_gesture();

    self setactionslot(slot, "taunt");
    self assignweaponoffhandtaunt(weapon);
    self giveandfireoffhand(weapon);

    end = gettime() + 5000;
    while (gettime() < end && self hasweapon(weapon))
        waitframe();

    if (self hasweapon(weapon))
        self takeweapon(weapon);

    if (borrowed)
    {
        self setactionslot(slot, "");
        self.gestureweapon = "none";
    }
    else
        self assignweaponoffhandtaunt(gesture_weapon(self.gestureweapon));

    self.cicada_gesture_busy = false;
}

function play_anim_once(id, both_hands)
{
    if (!isdefined(id))
        id = self anim_pick("anim_id", "anim_random", "anim_random_range", "anim_min", "anim_max");

    if (!isdefined(both_hands))
        both_hands = (self cicada_util::getpers("anim_hands") == "both");

    if (both_hands)
        self nengine_set_anim(id, 1);
    else
        self nengine_set_anim(id);

    wait 0.05;

    self nengine_set_anim(-1);
}
