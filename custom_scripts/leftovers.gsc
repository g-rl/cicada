#using scripts\engine\utility;

#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\props;
#using custom_scripts\util;

#namespace cicada_leftovers;

function zone_count()
{
    if (!isdefined(self.cicada_zones))
        return 0;

    return self.cicada_zones.size;
}

function private zone_hurts(zone, player_)
{
    if (player_ == zone.owner && !istrue(zone.hurt_owner))
        return false;

    if (istrue(zone.enemies) && zone.owner cicada_mods::is_friendly(player_))
        return false;

    return distance(player_.origin, zone.model.origin) <= zone.radius;
}

function private zone_think(zone)
{
    level endon("game_ended");

    for (;;)
    {
        wait (zone.rate);

        if (!isdefined(zone) || !isdefined(zone.model))
            return;

        foreach (player_ in level.players)
        {
            if (!isalive(player_))
                continue;

            if (!zone_hurts(zone, player_))
                continue;

            player_ dodamage(zone.damage, zone.model.origin, zone.owner, zone.model, "MOD_EXPLOSIVE");
        }

        if (isdefined(zone.owner))
            zone.owner cicada_mods::play_stack("zone_effect", zone.model.origin);
    }
}

function make_zone()
{
    spot = self cicada_util::crosshair();

    zone = spawnstruct();
    zone.owner = self;
    zone.radius = self cicada_util::getpersint("zone_radius");
    zone.damage = self cicada_util::getpersint("zone_damage");
    zone.rate = self cicada_util::getpersfloat("zone_rate");
    zone.enemies = self cicada_util::getpers("zone_enemies");
    zone.hurt_owner = self cicada_util::getpers("zone_hurt_owner");

    if (zone.rate < 0.05)
        zone.rate = 0.05;

    zone.model = spawn("script_model", spot);
    zone.model setmodel("tag_origin");

    if (!isdefined(self.cicada_zones))
        self.cicada_zones = [];

    self.cicada_zones[self.cicada_zones.size] = zone;

    level thread [[&zone_think]](zone);

    self cicada_util::message("^2zone ^7at ^:" + zone.radius + " ^7wide");
    self cicada_menu::update_menu();
}

function private drop_zone(zone)
{
    if (!isdefined(zone))
        return;

    if (isdefined(zone.model))
        zone.model delete();

    zone.model = undefined;
}

function drop_last_zone()
{
    if (!self zone_count())
        return;

    last = self.cicada_zones.size - 1;
    drop_zone(self.cicada_zones[last]);

    kept = [];

    for (i = 0; i < last; i++)
        kept[kept.size] = self.cicada_zones[i];

    self.cicada_zones = kept;
    self cicada_util::message("zone ^1removed");
    self cicada_menu::update_menu();
}

function clear_zones()
{
    if (!self zone_count())
        return;

    foreach (zone in self.cicada_zones)
        drop_zone(zone);

    self.cicada_zones = [];
    self cicada_util::message("zones ^1cleared");
    self cicada_menu::update_menu();
}

function manage_zones(action)
{
    switch (action)
    {
        case "place":
            self make_zone();
            break;

        case "delete last":
            self drop_last_zone();
            break;

        case "clear":
            self clear_zones();
            break;
    }
}

function wire_count()
{
    if (!isdefined(self.cicada_wires))
        return 0;

    return self.cicada_wires.size;
}

function wire_summary()
{
    if (isdefined(self.cicada_wire_start))
        return "^5end point ^7next";

    return "^:" + self wire_count() + " ^7wires";
}

function private on_the_wire(wire, spot)
{
    away = wire.tail - wire.head;
    span = length(away);

    if (span < 1)
        return false;

    along = vectordot(spot - wire.head, away / span);

    if (along < 0 || along > span)
        return false;

    near = wire.head + (away / span) * along;

    return distance(spot, near) <= wire.reach;
}

function private wire_think(wire)
{
    level endon("game_ended");

    for (;;)
    {
        waitframe();

        if (!isdefined(wire) || !isdefined(wire.marks))
            return;

        if (istrue(wire.spent))
            return;

        foreach (player_ in level.players)
        {
            if (!isalive(player_))
                continue;

            if (player_ == wire.owner && !istrue(wire.hurt_owner))
                continue;

            if (istrue(wire.enemies) && wire.owner cicada_mods::is_friendly(player_))
                continue;

            if (!on_the_wire(wire, player_.origin))
                continue;

            wire.marks[0] radiusdamage(player_.origin, wire.blast, wire.damage, int(wire.damage / 4), wire.owner, "MOD_EXPLOSIVE");

            wire.owner cicada_mods::play_stack("wire_effect", player_.origin);

            wire.owner cicada_util::message("tripwire ^1hit ^7- " + player_ cicada_util::player_name());

            if (istrue(wire.once))
            {
                wire.spent = true;
                clear_wire(wire);
                return;
            }

            wait 1;
        }
    }
}

function private wire_mark(spot)
{
    mark = spawn("script_model", spot);
    mark setmodel("tag_origin");

    return mark;
}

function save_wire_point()
{
    spot = self cicada_util::crosshair();

    if (!isdefined(self.cicada_wire_start))
    {
        self.cicada_wire_start = spot;
        self cicada_util::message("start point ^2saved");
        self cicada_menu::update_menu();
        return;
    }

    wire = spawnstruct();
    wire.owner = self;
    wire.head = self.cicada_wire_start;
    wire.tail = spot;
    wire.reach = self cicada_util::getpersint("wire_reach");
    wire.damage = self cicada_util::getpersint("wire_damage");
    wire.blast = self cicada_util::getpersint("wire_blast");
    wire.once = self cicada_util::getpers("wire_once");
    wire.enemies = self cicada_util::getpers("wire_enemies");
    wire.hurt_owner = self cicada_util::getpers("wire_hurt_owner");
    wire.marks = [];
    wire.marks[0] = wire_mark(wire.head);
    wire.marks[1] = wire_mark(wire.tail);

    self.cicada_wire_start = undefined;

    if (!isdefined(self.cicada_wires))
        self.cicada_wires = [];

    self.cicada_wires[self.cicada_wires.size] = wire;

    level thread [[&wire_think]](wire);

    self cicada_util::message("^2tripwire ^7placed");
    self cicada_menu::update_menu();
}

function private clear_wire(wire)
{
    if (!isdefined(wire) || !isdefined(wire.marks))
        return;

    foreach (mark in wire.marks)
        if (isdefined(mark))
            mark delete();

    wire.marks = undefined;
}

function clear_wires()
{
    self.cicada_wire_start = undefined;

    if (!self wire_count())
        return;

    foreach (wire in self.cicada_wires)
        clear_wire(wire);

    self.cicada_wires = [];
    self cicada_util::message("tripwires ^1cleared");
    self cicada_menu::update_menu();
}

function manage_wires(action)
{
    switch (action)
    {
        case "save point":
            self save_wire_point();
            break;

        case "clear":
            self clear_wires();
            break;
    }
}

function private explosive_loop()
{
    self endon("disconnect");
    self endon("cicada_xrounds_stop");
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");

        if (!istrue(self.cicada_xrounds) || !isalive(self))
            return;

        spot = self cicada_util::crosshair();

        if (!isdefined(spot))
            continue;

        self cicada_mods::play_stack("xrounds_effect", spot);

        self radiusdamage(spot, self cicada_util::getpersint("xrounds_blast"), self cicada_util::getpersint("xrounds_damage"), int(self cicada_util::getpersint("xrounds_damage") / 4), self, "MOD_EXPLOSIVE");

        rate = self cicada_util::getpersfloat("xrounds_rate");

        if (rate > 0)
            wait rate;
    }
}

function explosive_rounds()
{
    if (istrue(self.cicada_xrounds))
    {
        self.cicada_xrounds = false;
        self notify("cicada_xrounds_stop");
        self cicada_util::message("explosive rounds ^1off");
        self cicada_menu::update_menu();
        return;
    }

    self.cicada_xrounds = true;
    self thread [[&explosive_loop]]();
    self cicada_util::message("^2explosive rounds ^7on");
    self cicada_menu::update_menu();
}
