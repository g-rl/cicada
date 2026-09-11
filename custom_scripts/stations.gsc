#using scripts\engine\utility;

#using custom_scripts\catalog;
#using custom_scripts\extras;
#using custom_scripts\leftovers;
#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\props;
#using custom_scripts\util;

#namespace cicada_stations;

function kinds()
{
    return cicada_util::list("magic box,wall buy,ascender");
}

function box_pools()
{
    return cicada_util::list("everything,primaries,snipers,launchers,pistols,wonder weapons");
}

function buy_modes()
{
    return cicada_util::list("weapon,ammo refill");
}

function bundle_ready()
{
    if (!isdefined(level.gamemodebundle))
        return false;

    if (!isdefined(level.gamemodebundle.magicboxbundle))
        return false;

    return isdefined(getscriptbundle("magicbox:" + level.gamemodebundle.magicboxbundle));
}

function metadata_ready()
{
    return isdefined(level.weaponmetadata);
}

function model_ready(name)
{
    if (!isdefined(name))
        return false;

    probe = spawn("script_model", (0, 0, -30000));
    probe setmodel(name);
    found = isdefined(probe gettagorigin("tag_origin"));
    probe delete();

    return found;
}

function station_model(kind)
{
    wanted = self cicada_util::getpers(kind_key(kind, "model"));

    if (isdefined(wanted) && wanted != "none")
        return cicada_props::model_for_label(wanted);

    return cicada_props::model_for_label(cicada_props::model_labels()[0]);
}

function kind_key(kind, part)
{
    switch (kind)
    {
        case "magic box":
            return "box_" + part;

        case "wall buy":
            return "buy_" + part;
    }

    return "lift_" + part;
}

function all_events()
{
    return cicada_util::list("use,reward,ride,land,idle");
}

function kind_events(kind)
{
    if (kind == "ascender")
        return cicada_util::list("use,ride,land,idle");

    return cicada_util::list("use,reward,idle");
}

function fx_label(event)
{
    switch (event)
    {
        case "use":
            return "when used";

        case "reward":
            return "when it pays out";

        case "ride":
            return "while riding";

        case "land":
            return "at the top";
    }

    return "on the model";
}

function fx_key(event)
{
    return "station_" + event + "_effect";
}

function sound_key(event)
{
    return "station_" + event + "_sound";
}

function fx_summary(event)
{
    return self cicada_mods::stack_summary(fx_key(event)) + " ^7| " + self cicada_mods::sound_stack_summary(sound_key(event));
}

function events_summary(kind)
{
    total = 0;

    foreach (event in kind_events(kind))
        if (self cicada_mods::stack_count(fx_key(event)) || self cicada_mods::stack_count(sound_key(event)))
            total++;

    if (!total)
        return "^1nothing set";

    return "^:" + total + " ^7of ^:" + kind_events(kind).size;
}

function fire_event(event, spot)
{
    if (!isdefined(spot))
        spot = self.origin + (0, 0, 40);

    self cicada_mods::play_stack(fx_key(event), spot);
    self thread [[&cicada_mods::play_sound_stack]](sound_key(event));
}

function preview_event(event)
{
    self fire_event(event, self.origin + (0, 0, 50));
}

function stations()
{
    live = [];

    if (!isdefined(level.cicada_stations))
        return live;

    foreach (station in level.cicada_stations)
        if (isdefined(station) && isdefined(station.model))
            live[live.size] = station;

    return live;
}

function station_count()
{
    return stations().size;
}

function station_at(index)
{
    live = stations();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function station_label(station)
{
    if (!isdefined(station))
        return "gone";

    return station.kind + " ^:#" + station.tag;
}

function station_summary(station)
{
    if (!isdefined(station))
        return "^1gone";

    switch (station.kind)
    {
        case "magic box":
            return "^:" + station.pool + " ^7pool";

        case "wall buy":
            return "^:" + station.mode;
    }

    return "^:" + int(station.lift) + " ^7up";
}

function summary()
{
    return "^:" + station_count() + " ^7placed";
}

function private next_tag()
{
    if (!isdefined(level.cicada_station_tag))
        level.cicada_station_tag = 0;

    level.cicada_station_tag++;
    return level.cicada_station_tag;
}

function private spot_in_front()
{
    spot = self cicada_util::crosshair();
    ground = playerphysicstrace(spot + (0, 0, 64), spot - (0, 0, 128));

    if (isdefined(ground))
        spot = ground;

    return spot;
}

function hint_text(station)
{
    if (!isdefined(station))
        return "";

    switch (station.kind)
    {
        case "magic box":
            text = "^2take a weapon";
            break;

        case "wall buy":
            text = (station.mode == "ammo refill") ? "^2refill your ammo" : "^2take the weapon";
            break;

        default:
            text = "^2ride up";
            break;
    }

    if (station.uses > 0 && isdefined(station.left))
        text = text + " ^7(^:" + station.left + "^7)";

    return text;
}

function make_hint(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    station.model makeusable();
    station.model setcursorhint("HINT_NOICON");
    station.model setuserange(station.radius);
    station.model sethintdisplayrange(station.radius);
    station.model setusefov(360);
    station.model sethintdisplayfov(90);
    station.model sethintstring(hint_text(station));
}

function drop_hint(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    station.model sethintstring("");
    station.model makeunusable();
}

function refresh_hint(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    if (station.uses > 0 && isdefined(station.left) && station.left < 1)
    {
        drop_hint(station);
        return;
    }

    station.model sethintstring(hint_text(station));
}

function place_station(kind)
{
    if (!isdefined(kind))
        kind = self cicada_util::getpers("station_kind");

    model = self station_model(kind);

    if (!isdefined(model))
    {
        self cicada_util::message(cicada_util::warn("no model picked for that"));
        return;
    }

    spot = self spot_in_front();

    station = spawnstruct();
    station.kind = kind;
    station.tag = next_tag();
    station.owner = self;
    station.radius = self cicada_util::getpersint("station_radius");
    station.cooldown = self cicada_util::getpersfloat("station_cooldown");
    station.uses = self cicada_util::getpersint("station_uses");
    station.pool = self cicada_util::getpers("box_pool");
    station.mode = self cicada_util::getpers("buy_mode");
    station.weapon = self cicada_util::getpers("buy_weapon");
    station.joker = self cicada_util::getpersint("box_joker");
    station.lift = self cicada_util::getpersint("lift_height");
    station.speed = self cicada_util::getpersfloat("lift_speed");
    station.taken = [];

    if (station.uses > 0)
        station.left = station.uses;

    station.model = spawn("script_model", spot);
    station.model setmodel(model);
    station.model.angles = (0, self getplayerangles()[1] + 180, 0);

    if (istrue(self cicada_util::getpers("station_outline")))
        station.model hudoutlineenable("outlinefill_nodepth_green");

    if (!isdefined(level.cicada_stations))
        level.cicada_stations = [];

    level.cicada_stations[level.cicada_stations.size] = station;

    make_hint(station);

    level thread [[&station_think]](station);

    self cicada_util::message("^2" + kind + " ^7placed");
    self cicada_menu::update_menu();
}

function move_station(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    drop_hint(station);
    station.model.origin = self spot_in_front();
    station.model.angles = (0, self getplayerangles()[1] + 180, 0);
    make_hint(station);
    self cicada_util::message(station.kind + " ^2moved");
    self cicada_menu::update_menu();
}

function raise_station(value, station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    spot = station.model.origin;
    station.model.origin = (spot[0], spot[1], value);
    make_hint(station);
}

function remove_station(station)
{
    if (!isdefined(station))
        return;

    drop_hint(station);

    if (isdefined(station.model))
        station.model delete();

    station.model = undefined;
    level.cicada_stations = utility::array_remove(level.cicada_stations, station);

    self cicada_util::message(station.kind + " ^1removed");
    self cicada_menu::new_menu();
}

function clear_stations()
{
    foreach (station in stations())
    {
        drop_hint(station);

        if (isdefined(station.model))
            station.model delete();

        station.model = undefined;
    }

    level.cicada_stations = [];
    self cicada_util::message("stations ^1cleared");
    self cicada_menu::update_menu();
}

function manage_stations(action)
{
    switch (action)
    {
        case "place":
            self place_station(self cicada_util::getpers("station_kind"));
            break;

        case "clear":
            self clear_stations();
            break;
    }
}

function private cooled(station, player_)
{
    tag = player_ getentitynumber();

    if (isdefined(station.taken[tag]) && gettime() < station.taken[tag])
        return false;

    station.taken[tag] = gettime() + int(station.cooldown * 1000);
    return true;
}

function private idle_effects(station)
{
    level endon("game_ended");

    for (;;)
    {
        rate = station.owner cicada_util::getpersfloat("station_idle_rate");

        if (rate < 0.25)
            rate = 1;

        wait rate;

        if (!isdefined(station) || !isdefined(station.model) || !isdefined(station.owner))
            return;

        station.owner fire_event("idle", station.model.origin + (0, 0, 20));
    }
}

function private station_think(station)
{
    level endon("game_ended");

    level thread [[&idle_effects]](station);

    for (;;)
    {
        wait 0.1;

        if (!isdefined(station) || !isdefined(station.model))
            return;

        foreach (player_ in level.players)
        {
            if (!isalive(player_) || !player_ usebuttonpressed())
                continue;

            if (distance(player_.origin, station.model.origin) > station.radius)
                continue;

            if (!cooled(station, player_))
                continue;

            player_ thread [[&use_station]](station);
        }
    }
}

function private pool_categories()
{
    return cicada_util::list("assault rifles,submachine guns,shotguns,light machine guns,marksman rifles,snipers,pistols,launchers,melee,misc");
}

function private pool_weapons(pool)
{
    switch (pool)
    {
        case "primaries":
            return cicada_catalog::get("assault rifles");

        case "snipers":
            return cicada_catalog::get("snipers");

        case "launchers":
            return cicada_catalog::get("launchers");

        case "pistols":
            return cicada_catalog::get("pistols");

        case "wonder weapons":
            return cicada_catalog::get("misc");
    }

    return cicada_catalog::get(pool_categories()[randomint(pool_categories().size)]);
}

function private roll_box(station)
{
    list = pool_weapons(station.pool);

    if (!isdefined(list) || !list.size)
    {
        self cicada_util::message(cicada_util::warn("that pool is empty"));
        return;
    }

    wait (self cicada_util::getpersfloat("station_roll_time"));

    if (!isdefined(station) || !isdefined(station.model) || !isalive(self))
        return;

    pick = list[randomint(list.size)];

    self fire_event("reward", station.model.origin + (0, 0, 40));
    self cicada_loadout::give_weapon(pick.id);

    if (station.joker > 0 && randomint(100) < station.joker)
        station.model.origin = station.model.origin + (randomintrange(-400, 400), randomintrange(-400, 400), 0);
}

function private use_buy(station)
{
    switch (station.mode)
    {
        case "ammo refill":
            self cicada_extras::max_ammo();
            self fire_event("reward", station.model.origin + (0, 0, 40));
            return;
    }

    if (!isdefined(station.weapon) || station.weapon == "none")
    {
        self cicada_util::message(cicada_util::warn("no weapon set on that buy"));
        return;
    }

    self cicada_loadout::give_weapon(station.weapon);
    self fire_event("reward", station.model.origin + (0, 0, 40));
}

function private ride_effects()
{
    self endon("disconnect");
    self endon("death");
    self endon("cicada_lift_done");
    level endon("game_ended");

    rate = self cicada_util::getpersfloat("station_ride_rate");

    if (rate < 0.05)
        rate = 0.25;

    for (;;)
    {
        self fire_event("ride", self.origin + (0, 0, 30));
        wait rate;
    }
}

function private ride_lift(station)
{
    self endon("disconnect");
    self endon("death");

    if (istrue(self.cicada_lift_on))
        return;

    self.cicada_lift_on = true;

    rig = spawn("script_model", self.origin);
    rig setmodel("tag_origin");

    self playerlinkto(rig, "tag_origin", 1);
    self thread [[&ride_effects]]();

    top = self.origin + (0, 0, station.lift);
    rig moveto(top, station.speed);
    rig waittill("movedone");

    self notify("cicada_lift_done");
    self unlink();
    rig delete();

    self setvelocity((0, 0, 150));
    self.cicada_lift_on = false;
    self fire_event("land", self.origin + (0, 0, 30));
}

function private use_station(station)
{
    self endon("disconnect");

    if (station.uses > 0)
    {
        if (!isdefined(station.left))
            station.left = station.uses;

        if (station.left < 1)
        {
            self cicada_util::message(cicada_util::warn("that one is used up"));
            return;
        }

        station.left--;
        refresh_hint(station);
    }

    self fire_event("use", station.model.origin + (0, 0, 30));

    switch (station.kind)
    {
        case "magic box":
            self roll_box(station);
            return;

        case "wall buy":
            self use_buy(station);
            return;
    }

    self ride_lift(station);
}

function pool_count(pool)
{
    list = pool_weapons(pool);

    if (!isdefined(list))
        return 0;

    return list.size;
}

function set_buy_weapon()
{
    weapon = self getcurrentweapon();

    if (!isdefined(weapon) || isnullweapon(weapon))
    {
        self cicada_util::message(cicada_util::warn("hold the weapon you want"));
        return;
    }

    self cicada_util::setpers("buy_weapon", cicada_loadout::weapon_root(weapon));
    self cicada_util::message("buy set to ^:" + cicada_loadout::weapon_label(weapon));
    self cicada_menu::update_menu();
}

function probe_line(text, ready)
{
    return text + ": " + (ready ? "^2yes" : "^1no");
}

function probe_report()
{
    self cicada_util::message(probe_line("magic box bundle", bundle_ready()));
    self cicada_util::message(probe_line("weapon metadata", metadata_ready()));
    self cicada_util::message(probe_line("agent types", isdefined(level.agent_definition)));
    self cicada_util::message(probe_line("effects loaded", cicada_mods::effect_list().size > 0));
    self cicada_util::message(probe_line("prop models", cicada_props::model_labels().size > 0));
}
