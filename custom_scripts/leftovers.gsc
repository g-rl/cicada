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

        foreach (player_ in zone.owner cicada_mods::damage_targets(istrue(zone.hits_ai)))
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
    zone.hits_ai = self cicada_util::getpers("zone_hits_ai");
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

        if (istrue(self cicada_util::getpers("xrounds_hits_ai")))
            self cicada_mods::splash_ai(spot, self cicada_util::getpersint("xrounds_blast"), self cicada_util::getpersint("xrounds_damage"));

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
