#using scripts\engine\utility;

#using custom_scripts\catalog;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\pve;
#using custom_scripts\util;

#namespace cicada_mechanics;

function equipment_modes()
{
    return cicada_util::list("lethal,tactical,both");
}

function private kind_of(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return "other";

    foreach (ref in cicada_catalog::equipment_refs("primary"))
        if (ref == weapon.basename)
            return "lethal";

    foreach (ref in cicada_catalog::equipment_refs("secondary"))
        if (ref == weapon.basename)
            return "tactical";

    return "other";
}

function private wanted_equipment(weapon)
{
    mode = self cicada_util::getpers("equipment_aim_mode");
    kind = kind_of(weapon);

    if (kind == "other")
        return istrue(self cicada_util::getpers("equipment_aim_any"));

    if (!isdefined(mode) || mode == "both")
        return true;

    return mode == kind;
}

function private aim_candidates()
{
    list = [];

    foreach (player_ in level.players)
    {
        if (player_ == self || !isalive(player_))
            continue;

        if (istrue(self cicada_util::getpers("equipment_aim_enemies")) && self cicada_mods::is_friendly(player_))
            continue;

        list[list.size] = player_;
    }

    if (istrue(self cicada_util::getpers("equipment_aim_zombies")))
        foreach (agent in cicada_pve::zombies())
            list[list.size] = agent;

    return list;
}

function private equipment_target()
{
    center = self cicada_util::crosshair();
    range = self cicada_util::getpersint("equipment_aim_range");

    closest = undefined;
    best = 0;

    foreach (ent in self aim_candidates())
    {
        gap = distance(ent.origin, center);

        if (gap > range)
            continue;

        if (!isdefined(closest) || gap < best)
        {
            closest = ent;
            best = gap;
        }
    }

    return closest;
}

function private home_projectile(projectile, target)
{
    self endon("disconnect");
    level endon("game_ended");

    speed = self cicada_util::getpersint("equipment_aim_speed");
    lift = self cicada_util::getpersint("equipment_aim_height");
    step = 0.05;

    for (i = 0; i < 400; i++)
    {
        if (!isdefined(projectile) || !isdefined(target) || !isalive(target))
            return;

        spot = target.origin + (0, 0, lift);
        gap = distance(projectile.origin, spot);

        if (gap < 12)
            return;

        travel = speed * step;

        if (travel > gap)
            travel = gap;

        projectile moveto(projectile.origin + vectornormalize(spot - projectile.origin) * travel, step);
        wait step;
    }
}

function private missile_aimbot(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        self waittill("missile_fire", projectile);

        if (!isdefined(projectile) || !istrue(self cicada_util::getpers("equipment_aim_rockets")))
            continue;

        target = self equipment_target();

        if (!isdefined(target))
            continue;

        projectile missile_settargetent(target, (0, 0, 0));
        self thread [[&home_projectile]](projectile, target);
    }
}

function equipment_aimbot(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    self thread [[&missile_aimbot]](key);

    for (;;)
    {
        self waittill("grenade_fire", projectile, weapon);

        if (!isdefined(projectile) || !isdefined(weapon))
            continue;

        if (!self wanted_equipment(weapon))
            continue;

        target = self equipment_target();

        if (!isdefined(target))
            continue;

        self thread [[&home_projectile]](projectile, target);
    }
}

function is_chuting()
{
    return isalive(self) && self isparachuting();
}

function is_skydiving()
{
    return isalive(self) && self isskydiving();
}

function private chute_ready()
{
    self skydive_setbasejumpingstatus(1);
    self skydive_setdeploymentstatus(1);
    self skydive_cutautodeployon();

    if (istrue(self cicada_util::getpers("chute_can_cut")))
        self skydive_cutparachuteon();
    else
        self skydive_cutparachuteoff();
}

function private chute_smoke(state)
{
    if (!istrue(self cicada_util::getpers("chute_smoke")))
        return;

    self setscriptablepartstate("skydiveVfx", state ? "enabled" : "default", 0);
    self setisinfilskydive(state ? 1 : 0);
}

function private chute_land()
{
    self.cicada_chute = false;
    self skydive_setforcethirdpersonstatus(0);
    self animscriptsetinputparamreplicationstatus(0);
    self chute_smoke(false);
    self cicada_menu::update_menu();
    self notify("cicada_chute_stop");
}

function private chute_pull()
{
    if (self isparachuting())
        return;

    self notify("skydive_deployparachute");
    self skydive_deployparachute();
}

function private chute_pull_watch()
{
    self endon("disconnect");
    self endon("death");
    self endon("cicada_chute_stop");
    level endon("game_ended");

    for (;;)
    {
        self waittill("open_parachute");

        if (self isskydiving())
            self chute_pull();
    }
}

function private chute_watch()
{
    self endon("disconnect");
    self endon("death");
    self endon("cicada_chute_stop");
    level endon("game_ended");

    while (self jumpbuttonpressed())
        waitframe();

    for (i = 0; i < 12000; i++)
    {
        if (!isalive(self))
            return;

        if (istrue(self cicada_util::getpers("chute_jump_off")) && self isparachuting() && self jumpbuttonpressed())
        {
            self chute_cancel();
            return;
        }

        if (self isonground() && !self isskydiving())
        {
            self chute_land();
            return;
        }

        waitframe();
    }
}

function private chute_dive()
{
    self endon("disconnect");
    self endon("death");
    self endon("cicada_chute_stop");
    level endon("game_ended");

    self skydive_interrupt();
    self notifyonplayercommand("open_parachute", "+gostand");
    self skydive_beginfreefall();

    if (istrue(self cicada_util::getpers("chute_third")))
        self skydive_setforcethirdpersonstatus(1);

    self thread [[&chute_pull_watch]]();
    self thread [[&chute_watch]]();

    fall = self cicada_util::getpersfloat("chute_fall_time");

    if (fall > 0)
        wait fall;

    if (self isskydiving())
        self chute_pull();
}

function chute_open()
{
    if (!isalive(self) || self isonground() || self isparachuting())
        return;

    self.cicada_chute = true;
    self chute_ready();
    self animscriptsetinputparamreplicationstatus(1);
    self chute_smoke(true);

    if (istrue(self cicada_util::getpers("chute_freefall")))
    {
        self thread [[&chute_dive]]();
        self cicada_menu::update_menu();
        return;
    }

    if (istrue(self cicada_util::getpers("chute_third")))
        self skydive_setforcethirdpersonstatus(1);

    self chute_pull();
    self thread [[&chute_watch]]();
    self cicada_menu::update_menu();
}

function chute_cancel()
{
    if (!self isskydiving() && !istrue(self.cicada_chute))
        return;

    self skydive_interrupt();
    self chute_land();
}

function pull_chute()
{
    if (self is_skydiving())
    {
        self chute_cancel();
        return;
    }

    self chute_open();
}

function chute_height()
{
    ground = playerphysicstrace(self.origin, self.origin - (0, 0, 100000));

    if (!isdefined(ground))
        return 0;

    return self.origin[2] - ground[2];
}

function auto_chute(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        if (!self isonground() && !self is_skydiving() && isalive(self))
        {
            drop = self getvelocity()[2];

            if (drop < (self cicada_util::getpersint("chute_speed") * -1) && self chute_height() > self cicada_util::getpersint("chute_height"))
                self chute_open();
        }

        wait 0.1;
    }
}

function redeploy_modes()
{
    return cicada_util::list("hold jump,tap jump,double jump");
}

function set_redeploy(value, key)
{
    self cicada_util::setpers(key, value);
    self cicada_menu::update_menu();
}

function private redeploy_asked()
{
    mode = self cicada_util::getpers("chute_redeploy_input");

    if (mode == "hold jump")
        return self jumpbuttonpressed();

    if (!self jumpbuttonpressed())
        return false;

    while (self jumpbuttonpressed())
        waitframe();

    if (mode == "tap jump")
        return true;

    for (i = 0; i < 20; i++)
    {
        if (self jumpbuttonpressed())
            return true;

        waitframe();
    }

    return false;
}

function redeploy(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

    for (;;)
    {
        waitframe();

        if (!isalive(self) || self isonground() || self is_skydiving())
            continue;

        if (self chute_height() < self cicada_util::getpersint("chute_redeploy_height"))
            continue;

        if (!self redeploy_asked())
            continue;

        self chute_open();
    }
}

function redeploy_off(key)
{
    if (self is_skydiving())
        self chute_cancel();
}

function move_keys()
{
    return cicada_util::list("move_jump,move_sprint,move_crouch,move_prone,move_stand,move_melee,move_fire");
}

function apply_moves()
{
    self allowjump(istrue(self cicada_util::getpers("move_jump")));
    self allowsprint(istrue(self cicada_util::getpers("move_sprint")));
    self allowcrouch(istrue(self cicada_util::getpers("move_crouch")));
    self allowprone(istrue(self cicada_util::getpers("move_prone")));
    self allowstand(istrue(self cicada_util::getpers("move_stand")));
    self allowmelee(istrue(self cicada_util::getpers("move_melee")));
    self allowfire(istrue(self cicada_util::getpers("move_fire")));
    self setmovespeedscale(self cicada_util::getpersfloat("move_speed"));
}

function flip_move(key)
{
    self cicada_util::flippers(key);
    self apply_moves();
    self cicada_menu::update_menu();
}

function set_move_value(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_moves();
}

function reset_moves()
{
    foreach (key in move_keys())
        self cicada_util::setpers(key, true);

    self cicada_util::setpers("move_speed", 1);
    self apply_moves();
    self cicada_util::message("movement rules reset");
    self cicada_menu::update_menu();
}

function move_summary()
{
    blocked = 0;

    foreach (key in move_keys())
        if (!istrue(self cicada_util::getpers(key)))
            blocked++;

    if (!blocked)
        return "^:" + self cicada_util::getpersfloat("move_speed") + "x ^7speed";

    return "^1" + blocked + " ^7blocked - ^:" + self cicada_util::getpersfloat("move_speed") + "x";
}

function summary()
{
    if (self is_chuting())
        return "^2chute open";

    if (istrue(self cicada_util::getpers("chute_freefall")))
        return "^:" + self cicada_util::getpersfloat("chute_fall_time") + "s ^7of freefall";

    return "^7opens right away";
}
