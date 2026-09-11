#using scripts\engine\trace;
#using scripts\engine\utility;

#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\props;
#using custom_scripts\pve;
#using custom_scripts\util;

#namespace cicada_link;

function modes()
{
    return cicada_util::list("free look,rigid,absolute,attach");
}

function targets()
{
    return cicada_util::list("next grenade,next rocket,crosshair,nearest bot,nearest zombie,spawned model,nearest drone");
}

function is_linked()
{
    return istrue(self.cicada_link_on);
}

function is_arming()
{
    return istrue(self.cicada_link_arming);
}

function when_modes()
{
    return cicada_util::list("when it lands,right away");
}

function summary()
{
    if (self is_linked())
        return "^2riding ^7- " + self cicada_util::getpers("link_mode");

    if (self is_arming())
        return "^5waiting ^7for " + self cicada_util::getpers("link_target");

    return "^:" + self cicada_util::getpers("link_target");
}

function private link_offset()
{
    return (self cicada_util::getpersint("link_x"), self cicada_util::getpersint("link_y"), self cicada_util::getpersint("link_z"));
}

function private make_rig(ent)
{
    rig = spawn("script_model", ent.origin + self link_offset());
    rig setmodel("tag_origin");
    rig.angles = ent.angles;

    return rig;
}

function private follow_rig(ent, rig)
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    level endon("game_ended");

    spin = istrue(self cicada_util::getpers("link_spin"));

    for (;;)
    {
        if (!isdefined(ent) || !isdefined(rig))
            return;

        rig.origin = ent.origin + self link_offset();

        if (spin)
            rig.angles = ent.angles;

        waitframe();
    }
}

function private attach(ent)
{
    view = self cicada_util::getpersfloat("link_view");
    right = self cicada_util::getpersint("link_arc_right");
    left = self cicada_util::getpersint("link_arc_left");
    top = self cicada_util::getpersint("link_arc_top");
    bottom = self cicada_util::getpersint("link_arc_bottom");

    rig = self make_rig(ent);

    self.cicada_link_ent = ent;
    self.cicada_link_rig = rig;

    self thread [[&follow_rig]](ent, rig);

    switch (self cicada_util::getpers("link_mode"))
    {
        case "attach":
            self linkto(rig, "tag_origin", (0, 0, 0), (0, 0, 0));
            break;

        case "rigid":
            self playerlinkto(rig, "tag_origin", view);
            break;

        case "absolute":
            self playerlinktoabsolute(rig, "tag_origin", view, right, left, top, bottom, 1);
            break;

        default:
            self playerlinktodelta(rig, "tag_origin", view, right, left, top, bottom, 1);
            break;
    }
}

function private nearest_of(list, spot)
{
    closest = undefined;
    best = 0;

    foreach (ent in list)
    {
        if (!isdefined(ent))
            continue;

        gap = distance(ent.origin, spot);

        if (!isdefined(closest) || gap < best)
        {
            closest = ent;
            best = gap;
        }
    }

    return closest;
}

function private bot_list()
{
    list = [];

    foreach (player_ in level.players)
        if (player_ != self && isalive(player_))
            list[list.size] = player_;

    return list;
}

function private drone_list()
{
    list = [];

    foreach (ent in getentarray("script_vehicle", "classname"))
        if (isdefined(ent))
            list[list.size] = ent;

    foreach (ent in getentarray("script_model", "classname"))
        if (isdefined(ent) && isdefined(ent.streakinfo))
            list[list.size] = ent;

    return list;
}

function private crosshair_ent()
{
    eye = self geteye();
    hit = trace::_bullet_trace(eye, eye + anglestoforward(self getplayerangles()) * 100000, 0, self);

    return hit["entity"];
}

function private wait_landing(projectile)
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    self endon("death");
    level endon("game_ended");

    last = projectile.origin;

    for (i = 0; i < 400; i++)
    {
        waitframe();

        if (!isdefined(projectile))
            return false;

        if (i > 4 && distance(projectile.origin, last) < 0.5)
            return true;

        last = projectile.origin;
    }

    return isdefined(projectile);
}

function private wait_projectile(kind)
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    self endon("death");
    level endon("game_ended");

    self cicada_util::message("throw or fire to ^2ride ^7it");

    if (kind == "next rocket")
        self waittill("missile_fire", projectile);
    else
        self waittill("grenade_fire", projectile);

    if (!isdefined(projectile))
        return undefined;

    if (self cicada_util::getpers("link_when") == "when it lands")
    {
        if (!self wait_landing(projectile))
            return undefined;
    }

    return projectile;
}

function private pick_target(kind)
{
    switch (kind)
    {
        case "next grenade":
        case "next rocket":
            return self wait_projectile(kind);

        case "crosshair":
            return self crosshair_ent();

        case "nearest bot":
            return nearest_of(self bot_list(), self.origin);

        case "nearest zombie":
            return nearest_of(cicada_pve::zombies(), self.origin);

        case "nearest drone":
            return nearest_of(drone_list(), self.origin);

        case "spawned model":
            return cicada_props::prop_at(0);
    }

    return undefined;
}

function private steer(ent)
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    self endon("death");
    level endon("game_ended");

    step = 0.05;

    for (;;)
    {
        if (!isdefined(ent) || !isdefined(self.cicada_link_rig) || !self is_linked() || !isalive(self))
            return;

        if (istrue(self cicada_util::getpers("link_control")))
        {
            speed = self cicada_util::getpersint("link_speed");
            forward = anglestoforward(self getplayerangles());

            ent moveto(ent.origin + forward * speed * step, step);
        }

        wait step;
    }
}

function private watch_jump()
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    self endon("death");
    level endon("game_ended");

    while (self jumpbuttonpressed())
        waitframe();

    for (;;)
    {
        if (!self is_linked())
            return;

        if (istrue(self cicada_util::getpers("link_jump_off")) && self jumpbuttonpressed())
        {
            self stop_ride();
            return;
        }

        waitframe();
    }
}

function private watch_ride(ent)
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    level endon("game_ended");

    self thread [[&steer]](ent);
    self thread [[&watch_jump]]();

    held = self cicada_util::getpersfloat("link_time");
    started = gettime();

    for (;;)
    {
        if (!isdefined(ent) || !isalive(self) || !self is_linked())
        {
            self stop_ride();
            return;
        }

        if (held > 0 && (gettime() - started) >= (held * 1000))
        {
            self stop_ride();
            return;
        }

        waitframe();
    }
}

function ride(ent)
{
    self.cicada_link_arming = false;

    if (!isdefined(ent))
    {
        self cicada_util::message(cicada_util::warn("nothing to ride"));
        return;
    }

    if (self is_linked())
        self stop_ride();

    if (!isalive(self))
        return;

    self attach(ent);
    self.cicada_link_on = true;

    if (istrue(self cicada_util::getpers("link_god")))
        self enableinvulnerability();

    if (istrue(self cicada_util::getpers("link_third")))
        self setclientdvar("camera_thirdperson", 1);

    self cicada_util::message("^2riding ^7- press the unlink bind to drop");
    self thread [[&watch_ride]](ent);
    self cicada_menu::update_menu();
}

function start_ride()
{
    if (self is_linked() || self is_arming())
    {
        self stop_ride();
        return;
    }

    self thread [[&find_and_ride]]();
}

function private find_and_ride()
{
    self endon("disconnect");
    self endon("cicada_link_stop");
    self endon("death");
    level endon("game_ended");

    self.cicada_link_arming = true;
    self cicada_menu::update_menu();

    target = self pick_target(self cicada_util::getpers("link_target"));

    self.cicada_link_arming = false;
    self thread [[&ride]](target);
}

function stop_ride()
{
    waiting = self is_arming();
    linked = self is_linked();

    self.cicada_link_arming = false;
    self.cicada_link_ent = undefined;

    if (linked)
    {
        self.cicada_link_on = false;
        self unlink();
    }

    if (isdefined(self.cicada_link_rig))
    {
        self.cicada_link_rig delete();
        self.cicada_link_rig = undefined;
    }

    if (!linked)
    {
        if (waiting)
        {
            self cicada_util::message("^1link cancelled");
            self cicada_menu::update_menu();
        }

        self notify("cicada_link_stop");
        return;
    }

    if (istrue(self cicada_util::getpers("link_god")))
        self disableinvulnerability();

    if (istrue(self cicada_util::getpers("link_third")))
        self setclientdvar("camera_thirdperson", 0);

    if (istrue(self cicada_util::getpers("link_drop")) && isalive(self))
        self setvelocity((0, 0, self cicada_util::getpersint("link_drop_lift")));

    self cicada_util::message("^1unlinked");
    self cicada_menu::update_menu();
    self notify("cicada_link_stop");
}

function ride_selected(player_)
{
    self ride(player_);
}
