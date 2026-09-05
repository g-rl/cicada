#using scripts\cp_mp\utility\inventory_utility;
#using scripts\engine\utility;
#using scripts\mp\bots\bots;
#using scripts\mp\class;
#using scripts\mp\flags;
#using scripts\mp\gamelogic;
#using scripts\mp\outofbounds;
#using scripts\mp\perks\perks;
#using scripts\mp\playerlogic;
#using scripts\mp\supers;
#using scripts\mp\utility\game;
#using scripts\mp\utility\perk;
#using scripts\mp\utility\player;

#using custom_scripts\killcam;
#using custom_scripts\loadout;
#using custom_scripts\movement;
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
    register("save_load_binds", &save_load_binds);
    register("frozen_bots", &freeze_bots, &unfreeze_bots);
    register("aimbot", &aimbot);
    register("tracers", &tracers);
    register("no_hud", &hide_hud, &show_hud);
    register("no_oob", &disable_oob, &enable_oob);
    register("no_barriers", &remove_barriers, &restore_barriers);
    register("pve", &cicada_pve::start, &cicada_pve::stop);
    register("clean_killcam", &cicada_killcam::clean);
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

    if (istrue(self cicada_util::getpers("invincible")))
    {
        self enableinvulnerability();
        self.maxhealth = 9999;
        self.health = self.maxhealth;
    }

    if (self has_position())
        self load_position();
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
            if (distance(self.origin, self cicada_util::getpers("bounce_" + i)) < 90)
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
    return self cicada_util::getpersint("bounce_count");
}

function save_bounce()
{
    count = self bounce_count();
    self cicada_util::setpers("bounce_" + count, self.origin);
    self cicada_util::setpers("bounce_count", count + 1);
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

    self cicada_util::setpers("bounce_" + (count - 1), undefined);
    self cicada_util::setpers("bounce_count", count - 1);
    self cicada_util::message("bounce ^:#" + (count - 1) + " ^7deleted");
}

function save_load_binds(key)
{
    self thread [[&crouch_bind]]("+actionslot 3", &save_position);
    self thread [[&crouch_bind]]("-actionslot 2", &load_position);
}

function crouch_bind(button, action)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event("save_load_binds"));
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_" + button);

        if (self getstance() == "crouch" && !self cicada_util::in_menu())
            self thread [[action]]();
    }
}

function has_position()
{
    return isdefined(self cicada_util::getpers("position"));
}

function save_position()
{
    self cicada_util::setpers("position", self.origin);
    self cicada_util::setpers("angles", self getplayerangles());
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
    self setorigin(self cicada_util::getpers("position"));
    self setplayerangles(self cicada_util::getpers("angles"));
}

function reset_position()
{
    self cicada_util::setpers("position", undefined);
    self cicada_util::setpers("angles", undefined);
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

    origin = self cicada_util::getpers("position");

    if (axis == "x")
        origin = (float(value), origin[1], origin[2]);
    else if (axis == "y")
        origin = (origin[0], float(value), origin[2]);
    else
        origin = (origin[0], origin[1], float(value));

    self cicada_util::setpers("position", origin);
}

function unstuck()
{
    self setorigin(self.origin + (0, 0, 20));
    self setvelocity((0, 0, 0));
}

function freeze_bots(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        foreach (player_ in level.players)
            if (cicada_util::is_bot(player_))
                player_ freezecontrols(1);

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
    player_ thread [[&hold_freeze]]();
}

function hold_freeze()
{
    self endon("disconnect");
    self endon("cicada_unfreeze");
    level endon("game_ended");

    for (;;)
    {
        self freezecontrols(1);
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

function spawn_bot()
{
    if (!isdefined(level.bot_funcs) || !isdefined(level.bot_funcs["bots_spawn"]))
    {
        self cicada_util::message_bold("^5bots are not supported in this match");
        return;
    }

    team = self cicada_util::getpers("bot_team");
    difficulty = self cicada_util::getpers("bot_difficulty");

    level thread [[level.bot_funcs["bots_spawn"]]](1, self bot_spawn_team(team), undefined, undefined, undefined, difficulty);

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

        player_ setorigin(destination);
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

function play_bot_velocity()
{
    velocity = self stored_velocity("bot_");

    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_))
            player_ setvelocity(velocity);
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

function aimbot(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");

        if (!cicada_weapon::is_ads_weapon(self getcurrentweapon()))
            continue;

        self shoot_nearest_target();
    }
}

function shoot_nearest_target()
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

        self deal_damage(player_, 350);

        if (istrue(self cicada_util::getpers("kill_effects")))
            play_effect(self cicada_util::getpers("kill_effect"), player_.origin + (0, 0, 50));
    }
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

    effect = self cicada_util::getpers("tracer_effect");
    forward = anglestoforward(self getplayerangles());
    origin = self gettagorigin("tag_weapon_right");
    offset = 12;

    for (i = 0; i < self cicada_util::getpersint("tracer_count"); i++)
    {
        play_effect(effect, origin + forward * offset);
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

function preview_effect(effect)
{
    play_effect(effect, self.origin + (0, 0, 50));
}

function effect_list()
{
    if (!isdefined(level._effect))
        return [];

    return getarraykeys(level._effect);
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
    setslowmotion(scale, scale, 0);
}

function restore_timescale()
{
    self endon("disconnect");
    level endon("game_ended");

    self cicada_util::wait_prematch();

    scale = self cicada_util::getpersfloat("timescale");
    setslowmotion(scale, scale, 0);
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

function fast_last()
{
    limit = (level.roundscorelimit - 1);
    self.score = limit;
    self.pers["score"] = limit;
    self.kills = limit;
    self.pers["kills"] = limit;
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
    player_ player::updatesessionstate("spectator");
    wait 0.05;
    player_ player::updatesessionstate("playing");
}

function change_team(player_)
{
    if (player_ ishost())
    {
        self cicada_util::message("^1cannot change the host team");
        return;
    }

    player_.team = game_utility::getotherteam(player_.team)[0];
    player_ player::updatesessionstate("spectator");
    wait 0.05;
    player_ notify("luinotifyserver", "team_select", 0);
    wait 0.05;
    player_ notify("luinotifyserver", "class_select", player_.pers["class"]);
    wait 0.05;
    player_ player::updatesessionstate("playing");
}

function teleport_player(target, destination)
{
    if (target.sessionstate != "playing")
        return;

    target setorigin(destination);
    self cicada_util::sound("scavenger_pack_pickup");
}

function manage_teleport(where, player_)
{
    switch (where)
    {
        case "crosshair":
            self teleport_player(player_, self cicada_util::crosshair());
            break;
        case "me":
            self teleport_player(player_, self.origin);
            break;
        case "them":
            self teleport_player(self, player_.origin);
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

// acts lexes "class" as a keyword, so self.class cannot be written directly.
// giveloadout syncs self.class from self.gamemode_chosenclass, then clears it.
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
    scripts\mp\class::giveloadout(self.team, self.pers["class"]);

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

function apply_defaults()
{
    self cicada_util::initpers("messages", true);
    self cicada_util::initpers("sounds", true);

    self cicada_util::initpers("instaswaps_time", 0.3);
    self cicada_util::initpers("auto_prone_mode", "air");
    self cicada_util::initpers("class_wrap", 5);

    self cicada_util::initpers("aimbot_range", 1500);
    self cicada_util::initpers("aimbot_delay", 0);
    self cicada_util::initpers("kill_effects", false);
    self cicada_util::initpers("tracer_count", 3);

    self cicada_util::initpers("position_step", 10);
    self cicada_util::initpers("bounce_count", 0);
    self cicada_util::initpers("timescale", 1.0);

    self cicada_util::initpers("damage_amount", 50);
    self cicada_util::initpers("flash_amount", 1);
    self cicada_util::initpers("shellshock_amount", 0.25);
    self cicada_util::initpers("shellshock_type", "frag_grenade_mp");
    self cicada_util::initpers("stuck_weapon", "semtex_mp");
    self cicada_util::initpers("spectate_time", 0.1);
    self cicada_util::initpers("repeater_illusion", false);
    self cicada_util::initpers("real_scavenger", true);

    self cicada_util::initpers("equipment_weapon", "semtex_mp");
    self cicada_util::initpers("equipment_putaway", false);
    self cicada_util::initpers("equipment_putaway_time", 0.05);

    self cicada_util::initpers("class_one_bullet", false);
    self cicada_util::initpers("class_empty_clip", false);
    self cicada_util::initpers("class_illusion", false);
    self cicada_util::initpers("class_canswap", false);

    self cicada_util::initpers("camo", "none");
    self cicada_util::initpers("replace_weapon", false);

    self cicada_util::initpers("camera_mode", "bezier");
    self cicada_util::initpers("camera_bezier_speed", 5);
    self cicada_util::initpers("camera_linear_time", 10);
    self cicada_util::initpers("camera_rotation", 0);

    self cicada_util::initpers("bot_team", "enemy");
    self cicada_util::initpers("bot_difficulty", "recruit");

    self cicada_util::initpers("pve_max", 40);
    self cicada_util::initpers("pve_health", 300);

    self cicada_util::initpers("bolt_speed", 1);
    self cicada_util::initpers("bot_bolt_speed", 1);
    self cicada_util::initpers("bolt_count", 0);
    self cicada_util::initpers("bot_bolt_count", 0);
    self cicada_util::initpers("record_count", 0);
    self cicada_util::initpers("path_count", 0);

    self cicada_util::initpers("hide_weapon", true);
    self cicada_util::initpers("hide_victim", true);
    self cicada_util::initpers("hide_perks", true);
    self cicada_util::initpers("hide_attachments", true);
    self cicada_util::initpers("hide_equipment", true);
    self cicada_util::initpers("hide_field_upgrade", true);

    self default_velocity("");
    self default_velocity("bot_");

    effects = effect_list();
    if (!effects.size)
        return;

    self cicada_util::initpers("kill_effect", effects[0]);
    self cicada_util::initpers("tracer_effect", effects[0]);
}

function default_velocity(prefix)
{
    self cicada_util::initpers(prefix + "velocity_x", 250);
    self cicada_util::initpers(prefix + "velocity_y", 250);
    self cicada_util::initpers(prefix + "velocity_z", 250);
    self cicada_util::initpers(prefix + "velocity_step", 50);
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

        scripts\mp\class::setclass(self.pers["class"]);
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;
        scripts\mp\class::giveloadout(self.pers["team"], self.pers["class"]);
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
