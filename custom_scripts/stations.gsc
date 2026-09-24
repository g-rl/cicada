#using scripts\engine\utility;

#using custom_scripts\catalog;
#using custom_scripts\weapon;
#using custom_scripts\world;
#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\props;
#using custom_scripts\pve;
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

function base_kinds()
{
    return cicada_util::list("model,agent");
}

function station_base()
{
    base = self cicada_util::getpers("station_base");

    return isdefined(base) ? base : "model";
}

function station_actor_type()
{
    return self cicada_util::getpers("station_actor");
}

function previewing()
{
    return isdefined(self.cicada_station_preview);
}

function preview_spot()
{
    range = self cicada_util::getpersint("station_preview_range");

    if (range < 40)
        range = 120;

    return self.origin + anglestoforward((0, self getplayerangles()[1], 0)) * range;
}

function drop_preview()
{
    if (!self previewing())
        return;

    if (isdefined(self.cicada_station_preview_actor))
    {
        cicada_pve::drop_station_actor(self.cicada_station_preview_actor);
        self.cicada_station_preview_actor = undefined;
    }

    self.cicada_station_preview delete();
    self.cicada_station_preview = undefined;
}

function private build_preview()
{
    spot = self preview_spot();
    angles = (0, self getplayerangles()[1] + 180, 0);

    holder = spawn("script_model", spot);
    holder.angles = angles;

    if (self station_base() == "agent")
    {
        holder setmodel("tag_origin");

        actor = self cicada_pve::spawn_station_actor(self station_actor_type(), spot, angles);

        if (!isdefined(actor))
        {
            holder delete();
            self cicada_util::message(cicada_util::warn("that actor is not loaded on this map"));
            return;
        }

        self.cicada_station_preview_actor = actor;
    }
    else
        holder setmodel(self station_model(self cicada_util::getpers("station_kind")));

    self.cicada_station_preview = holder;
    self cicada_util::message("preview ^2on");
}

function toggle_preview()
{
    if (self previewing())
    {
        self drop_preview();
        self cicada_util::message("preview ^1off");
        self cicada_menu::update_menu();
        return;
    }

    self build_preview();
    self cicada_menu::update_menu();
}

function set_base(value, key)
{
    self cicada_util::setpers(key, value);

    if (self previewing())
    {
        self drop_preview();
        self build_preview();
    }

    self cicada_menu::update_menu();
}

function set_actor(value, key)
{
    self cicada_util::setpers(key, cicada_pve::actor_for_label(value));

    if (self previewing())
    {
        self drop_preview();
        self build_preview();
    }

    self cicada_menu::update_menu();
}

function set_preview_range(value, key)
{
    self cicada_util::setpers(key, value);

    if (!self previewing())
        return;

    spot = self preview_spot();

    self.cicada_station_preview.origin = spot;

    if (isdefined(self.cicada_station_preview_actor))
        cicada_pve::move_station_actor(self.cicada_station_preview_actor, spot, self.cicada_station_preview.angles);
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
            return "SHARED_HINTSTRINGS/MAGICBOX_GRAB_WEAPON";

        case "wall buy":
            if (station.mode == "ammo refill")
                return "EQUIPMENT_HINTS/AMMO_BOX_USE";

            return "SHARED_HINTSTRINGS/MAGICBOX_GRAB_WEAPON";
    }

    return "ELEVATOR_USE_HINT";
}

function hint_name(station)
{
    if (!isdefined(station) || station.kind == "ascender")
        return undefined;

    if (station.kind == "wall buy")
    {
        if (station.mode == "ammo refill")
            return undefined;

        if (isdefined(station.weapon) && station.weapon != "none")
        {
            weapon = makeweapon(station.weapon);

            if (isdefined(weapon) && !isnullweapon(weapon))
                return weapon.displayname;
        }
    }

    if (station.kind == "magic box" || station.kind == "wall buy")
        return "SHARED_HINTSTRINGS/DEFAULT_WEAPON_WALLBUY_NAME";

    return undefined;
}

function apply_hint(hint, station)
{
    hint sethintstring(hint_text(station));

    name = hint_name(station);

    if (isdefined(name))
        hint sethintstringparams(name);
}

function make_hint(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    drop_hint(station);

    hint = spawn("script_model", station.model.origin + (0, 0, 32));
    hint setmodel("tag_origin");
    hint makeusable();
    hint setcursorhint("HINT_BUTTON");
    apply_hint(hint, station);
    hint setusepriority(0);
    hint setuseholdduration("duration_none");
    hint sethintonobstruction("show");
    hint sethintdisplayrange(station.radius);
    hint sethintdisplayfov(120);
    hint setuserange(station.radius);
    hint setusefov(120);
    hint enableplayeruseforallplayers();

    station.hint = hint;
}

function drop_hint(station)
{
    if (!isdefined(station) || !isdefined(station.hint))
        return;

    station.hint sethintstring("");
    station.hint makeunusable();
    station.hint delete();
    station.hint = undefined;
}

function refresh_hint(station)
{
    if (!isdefined(station) || !isdefined(station.hint))
        return;

    if (station.uses > 0 && isdefined(station.left) && station.left < 1)
    {
        drop_hint(station);
        return;
    }

    apply_hint(station.hint, station);
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
    station.model_name = model;
    station.taken = [];

    if (station.uses > 0)
        station.left = station.uses;

    station.base = self station_base();
    station.model = spawn("script_model", spot);
    station.model.angles = (0, self getplayerangles()[1] + 180, 0);

    if (station.base == "agent")
    {
        station.model setmodel("tag_origin");
        station.actor = self cicada_pve::spawn_station_actor(self station_actor_type(), spot, station.model.angles);

        if (!isdefined(station.actor))
        {
            station.base = "model";
            station.model setmodel(model);
            self cicada_util::message(cicada_util::warn("that actor is not loaded - model used"));
        }
    }
    else
    {
        station.model setmodel(model);
        cicada_props::dress_model(station.model, model);
    }

    station.outline = istrue(self cicada_util::getpers("station_outline"));

    if (station.outline)
    {
        if (isdefined(station.actor))
            station.actor hudoutlineenable("outlinefill_nodepth_green");
        else
            station.model hudoutlineenable("outlinefill_nodepth_green");
    }

    if (!isdefined(level.cicada_stations))
        level.cicada_stations = [];

    level.cicada_stations[level.cicada_stations.size] = station;

    make_hint(station);

    level thread [[&station_think]](station);

    self save_stations();
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
    cicada_pve::move_station_actor(station.actor, station.model.origin, station.model.angles);
    make_hint(station);
    self save_stations();
    self cicada_util::message(station.kind + " ^2moved");
    self cicada_menu::update_menu();
}

function raise_station(value, station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    spot = station.model.origin;
    station.model.origin = (spot[0], spot[1], value);
    cicada_pve::move_station_actor(station.actor, station.model.origin, station.model.angles);
    make_hint(station);
    self save_stations();
}

function remove_station(station)
{
    if (!isdefined(station))
        return;

    drop_hint(station);
    cicada_pve::drop_station_actor(station.actor);
    station.actor = undefined;

    if (isdefined(station.model))
        station.model delete();

    station.model = undefined;
    level.cicada_stations = utility::array_remove(level.cicada_stations, station);

    self save_stations();
    self cicada_util::message(station.kind + " ^1removed");
    self cicada_menu::new_menu();
}

function clear_stations()
{
    foreach (station in stations())
    {
        drop_hint(station);
        cicada_pve::drop_station_actor(station.actor);
        station.actor = undefined;

        if (isdefined(station.model))
            station.model delete();

        station.model = undefined;
    }

    level.cicada_stations = [];
    self save_stations(true);
    self cicada_util::message("stations ^1cleared");
    self cicada_menu::update_menu();
}

function private station_fields()
{
    return cicada_util::list("kind,base,actor,model,origin,angles,radius,cooldown,uses,left,pool,mode,weapon,joker,lift,speed,outline,head_mode,head_pick");
}

function private station_key(index, field)
{
    return "station_saved_" + index + "_" + field;
}

function saved_count()
{
    return self cicada_util::getmappersint("stations_saved");
}

function clear_saved()
{
    for (i = 0; i < self saved_count(); i++)
        foreach (field in station_fields())
            self cicada_util::setmappers(station_key(i, field), undefined);

    self cicada_util::setmappers("stations_saved", 0);
}

function save_stations(force)
{
    if (!istrue(self cicada_util::getpers("station_save")))
        return;

    live = stations();

    if (!live.size && !istrue(force) && self saved_count() > 0)
        return;

    self clear_saved();

    total = 0;

    foreach (station in live)
    {
        if (!isdefined(station) || !isdefined(station.model))
            continue;

        self cicada_util::setmappers(station_key(total, "kind"), station.kind);
        self cicada_util::setmappers(station_key(total, "base"), isdefined(station.base) ? station.base : "model");
        self cicada_util::setmappers(station_key(total, "actor"), isdefined(station.actor) ? station.actor.cicada_pve_aitype : undefined);
        self cicada_util::setmappers(station_key(total, "model"), station.model_name);
        self cicada_util::setmappers(station_key(total, "origin"), station.model.origin);
        self cicada_util::setmappers(station_key(total, "angles"), station.model.angles);
        self cicada_util::setmappers(station_key(total, "radius"), station.radius);
        self cicada_util::setmappers(station_key(total, "cooldown"), station.cooldown);
        self cicada_util::setmappers(station_key(total, "uses"), station.uses);
        self cicada_util::setmappers(station_key(total, "left"), station.left);
        self cicada_util::setmappers(station_key(total, "pool"), station.pool);
        self cicada_util::setmappers(station_key(total, "mode"), station.mode);
        self cicada_util::setmappers(station_key(total, "weapon"), station.weapon);
        self cicada_util::setmappers(station_key(total, "joker"), station.joker);
        self cicada_util::setmappers(station_key(total, "lift"), station.lift);
        self cicada_util::setmappers(station_key(total, "speed"), station.speed);
        self cicada_util::setmappers(station_key(total, "outline"), istrue(station.outline));
        self cicada_util::setmappers(station_key(total, "head_mode"), cicada_props::head_mode(station.model));
        self cicada_util::setmappers(station_key(total, "head_pick"), station.model.cicada_prop_head_pick);

        total++;
    }

    self cicada_util::setmappers("stations_saved", total);
}

function private restore_station(index)
{
    kind = self cicada_util::getmappers(station_key(index, "kind"));
    origin = self cicada_util::getmappers(station_key(index, "origin"));

    if (!isdefined(kind) || !isdefined(origin))
        return false;

    angles = self cicada_util::getmappers(station_key(index, "angles"));

    if (!isdefined(angles))
        angles = (0, 0, 0);

    station = spawnstruct();
    station.kind = kind;
    station.tag = next_tag();
    station.owner = self;
    station.base = self cicada_util::getmappers(station_key(index, "base"));
    station.radius = self cicada_util::getmappersint(station_key(index, "radius"));
    station.cooldown = self cicada_util::getmappers(station_key(index, "cooldown"));
    station.uses = self cicada_util::getmappersint(station_key(index, "uses"));
    station.pool = self cicada_util::getmappers(station_key(index, "pool"));
    station.mode = self cicada_util::getmappers(station_key(index, "mode"));
    station.weapon = self cicada_util::getmappers(station_key(index, "weapon"));
    station.joker = self cicada_util::getmappersint(station_key(index, "joker"));
    station.lift = self cicada_util::getmappersint(station_key(index, "lift"));
    station.speed = self cicada_util::getmappers(station_key(index, "speed"));
    station.model_name = self cicada_util::getmappers(station_key(index, "model"));
    station.outline = istrue(self cicada_util::getmappers(station_key(index, "outline")));
    station.taken = [];

    if (!isdefined(station.base))
        station.base = "model";

    if (!isdefined(station.model_name))
        station.model_name = self station_model(kind);

    if (!isdefined(station.cooldown))
        station.cooldown = 1;

    if (!isdefined(station.speed))
        station.speed = 1;

    if (station.uses > 0)
    {
        left = self cicada_util::getmappers(station_key(index, "left"));
        station.left = isdefined(left) ? int(left) : station.uses;

        if (station.left < 1)
            return false;
    }

    station.model = spawn("script_model", origin);
    station.model.angles = angles;

    if (station.base == "agent")
    {
        station.model setmodel("tag_origin");
        station.actor = self cicada_pve::spawn_station_actor(self cicada_util::getmappers(station_key(index, "actor")), origin, angles);

        if (!isdefined(station.actor))
        {
            station.base = "model";
            station.model setmodel(station.model_name);
        }
    }
    else
    {
        station.model setmodel(station.model_name);

        pick = self cicada_util::getmappers(station_key(index, "head_pick"));

        if (isdefined(pick))
            station.model.cicada_prop_head_pick = pick;

        mode = self cicada_util::getmappers(station_key(index, "head_mode"));

        if (isdefined(mode))
            station.model.cicada_prop_head_mode = mode;

        cicada_props::dress_model(station.model, station.model_name);
    }

    if (station.outline)
    {
        if (isdefined(station.actor))
            station.actor hudoutlineenable("outlinefill_nodepth_green");
        else
            station.model hudoutlineenable("outlinefill_nodepth_green");
    }

    if (!isdefined(level.cicada_stations))
        level.cicada_stations = [];

    level.cicada_stations[level.cicada_stations.size] = station;

    make_hint(station);
    level thread [[&station_think]](station);

    return true;
}

function private saved_needs_agents(total)
{
    for (i = 0; i < total; i++)
        if (self cicada_util::getmappers(station_key(i, "base")) == "agent")
            return true;

    return false;
}

function load_stations()
{
    total = self saved_count();

    if (!total)
        return;

    if (self saved_needs_agents(total))
        cicada_pve::wait_for_agents();

    back = 0;

    for (i = 0; i < total; i++)
        if (self restore_station(i))
            back++;

    if (back)
        self cicada_util::message("^:" + back + " ^7stations back");

    self cicada_menu::update_menu();
}

function open_head(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return;

    if (station.base == "agent")
    {
        self cicada_util::message(cicada_util::warn("agents keep their own head"));
        return;
    }

    self.select_prop = station.model;
    self cicada_menu::new_menu("model head");
}

function head_summary(station)
{
    if (!isdefined(station) || !isdefined(station.model))
        return "^1gone";

    if (station.base == "agent")
        return "^1agent base";

    return cicada_props::head_summary(station.model);
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
            self cicada_weapon::max_ammo();
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

        if (isdefined(station.owner))
            station.owner save_stations();
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
