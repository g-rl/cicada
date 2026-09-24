#using scripts\engine\utility;

#using custom_scripts\catalog;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\props;
#using custom_scripts\pve;
#using custom_scripts\util;

#namespace cicada_world;

function init()
{
    if (!isdefined(level.cicada_turrets))
        level.cicada_turrets = [];

    if (!isdefined(level.cicada_vehicles))
        level.cicada_vehicles = [];

    if (!isdefined(level.vehiclecount))
        level.vehiclecount = 0;

    if (!isdefined(level.maxvehiclecount))
        level.maxvehiclecount = 16;
}

function private map_vehicle_types()
{
    types = [];

    foreach (spawner in vehicle_getspawnerarray())
    {
        if (!isdefined(spawner) || !isdefined(spawner.vehicletype))
            continue;

        known = false;

        foreach (name in types)
            if (name == spawner.vehicletype)
                known = true;

        if (!known)
            types[types.size] = spawner.vehicletype;
    }

    return types;
}

function turret_kinds()
{
    return cicada_util::list("sentry gun,defend turret,manual turret,remote turret,shock sentry,tank turret,chopper turret");
}

function turret_weapon_for(kind)
{
    switch (kind)
    {
        case "defend turret":
            return "jup_ob_defend_turret";

        case "manual turret":
            return "manual_turret_mp";

        case "remote turret":
            return "remote_turret_mp";

        case "shock sentry":
            return "sentry_shock_mp";

        case "tank turret":
            return "iw9_tur_light_tank_mp";

        case "chopper turret":
            return "chopper_support_turret_mp";
    }

    return "sentry_turret_mp";
}

function turret_model_for(kind)
{
    switch (kind)
    {
        case "defend turret":
            return "jup_wm_zm_defend_turret";

        case "manual turret":
            return "weapon_wm_mg_mobile_turret";

        case "remote turret":
            return "wm_jup_2h_remote_turret_00";

        case "tank turret":
            return "veh9_mil_lnd_tank_turret";

        case "chopper turret":
            return "veh9_mil_air_heli_hind_turret_mp";
    }

    return "wpn_wm_p45_mg_auto_sentry_v0_mp";
}

function turret_kind()
{
    kind = self cicada_util::getpers("turret_kind");

    if (!isdefined(kind) || kind == "")
        return "sentry gun";

    return kind;
}

function turret_modes()
{
    return cicada_util::list("sentry,sentry_offline,manual,manual_target,auto_nonai");
}

function turret_sides()
{
    return cicada_util::list("yours,enemy");
}

function turrets()
{
    live = [];

    if (!isdefined(level.cicada_turrets))
        return live;

    foreach (turret in level.cicada_turrets)
        if (isdefined(turret))
            live[live.size] = turret;

    return live;
}

function turret_count()
{
    return turrets().size;
}

function turret_at(index)
{
    live = turrets();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function turret_name(turret)
{
    if (!isdefined(turret))
        return "gone";

    if (isdefined(turret.cicada_turret_kind))
        return turret.cicada_turret_kind;

    return "turret";
}

function turret_summary()
{
    return "^:" + turret_count() + " ^7placed";
}

function my_team()
{
    if (isdefined(self.team))
        return self.team;

    return "allies";
}

function other_team()
{
    return (self my_team() == "allies") ? "axis" : "allies";
}

function team_for(pick)
{
    if (isdefined(pick) && pick == "enemy")
        return self other_team();

    return self my_team();
}

function private build_turret(kind, spot, angles, mode, team)
{
    turret = spawnturret("misc_turret", spot, turret_weapon_for(kind));

    if (!isdefined(turret))
        return undefined;

    turret setmodel(turret_model_for(kind));
    turret.origin = spot;
    turret.angles = angles;
    turret.owner = self;
    turret.team = team;
    turret.health = 9999;
    turret.maxhealth = 9999;

    turret setturretowner(self);
    turret setturretteam(team);
    turret setsentryowner(self);
    turret makeunusable();
    turret setdefaultdroppitch(0);
    turret setturretmodechangewait(1);
    turret setleftarc(180);
    turret setrightarc(180);
    turret settoparc(60);
    turret setbottomarc(60);
    turret setconvergencetime(0.4, "pitch");
    turret setconvergencetime(0.4, "yaw");
    turret setmode(mode);
    turret turretfireenable();

    turret.cicada_turret_kind = kind;
    turret.cicada_turret_mode = mode;
    turret.cicada_turret_team = team;

    level.cicada_turrets[level.cicada_turrets.size] = turret;
    return turret;
}

function place_turret()
{
    spot = self cicada_util::crosshair();

    if (!isdefined(spot))
    {
        self cicada_util::message_bold("^1look at the ground first");
        return;
    }

    kind = self turret_kind();
    mode = self cicada_util::getpers("turret_mode");
    team = self team_for(self cicada_util::getpers("turret_team"));

    turret = self build_turret(kind, spot + (0, 0, 4), (0, self getplayerangles()[1], 0), mode, team);

    if (!isdefined(turret))
    {
        self cicada_util::message_bold("^1the turret did not spawn");
        return;
    }

    self cicada_util::message(kind + " ^7placed - " + turret_summary());
    self cicada_util::sound("scavenger_pack_pickup");

    self save_turrets(true);
    self cicada_menu::update_menu();
}

function set_turret_kind(kind)
{
    self cicada_util::setpers("turret_kind", kind);
    self place_turret();
}

function set_turret_mode(mode, turret)
{
    if (!isdefined(turret))
    {
        self cicada_util::setpers("turret_mode", mode);
        self cicada_menu::update_menu();
        return;
    }

    turret.cicada_turret_mode = mode;
    turret setmode(mode);

    self save_turrets(true);
    self cicada_menu::update_menu();
}

function turret_mode(turret)
{
    if (isdefined(turret) && isdefined(turret.cicada_turret_mode))
        return turret.cicada_turret_mode;

    return "sentry";
}

function set_turret_side(pick, turret)
{
    if (!isdefined(turret))
    {
        self cicada_util::setpers("turret_team", pick);
        self cicada_menu::update_menu();
        return;
    }

    team = self team_for(pick);

    turret.team = team;
    turret.cicada_turret_team = team;
    turret setturretteam(team);

    self save_turrets(true);
    self cicada_menu::update_menu();
}

function turret_side(turret)
{
    if (isdefined(turret) && isdefined(turret.cicada_turret_team) && turret.cicada_turret_team != self my_team())
        return "enemy";

    return "yours";
}

function private aim_pick()
{
    target = self cicada_pve::marked_agent();

    if (isdefined(target) && isalive(target))
        return target;

    target = self cicada_util::crosshair_ent();

    if (isdefined(target) && isalive(target) && target != self)
        return target;

    return undefined;
}

function aim_turret(turret)
{
    if (!isdefined(turret))
        return;

    target = self aim_pick();

    if (!isdefined(target))
    {
        self cicada_util::message_bold("^1mark an agent or look at one");
        return;
    }

    turret setturrettargetent(target);
    self cicada_util::message("turret is on ^:" + cicada_mods::ai_name(target));
}

function aim_all_turrets()
{
    target = self aim_pick();

    if (!isdefined(target))
    {
        self cicada_util::message_bold("^1mark an agent or look at one");
        return;
    }

    hit = 0;

    foreach (turret in turrets())
    {
        turret setturrettargetent(target);
        hit++;
    }

    self cicada_util::message("^:" + hit + " ^7turrets on ^:" + cicada_mods::ai_name(target));
}

function point_turret_here(turret)
{
    if (!isdefined(turret))
        return;

    spot = self cicada_util::crosshair();

    if (!isdefined(spot))
        return;

    turret clearturrettarget();
    turret setturrettargetvec(spot);
}

function clear_turret_aim(turret)
{
    if (!isdefined(turret))
        return;

    turret clearturrettarget();
    self cicada_util::message("turret target ^1cleared");
}

function toggle_turret_fire(turret)
{
    if (!isdefined(turret))
        return;

    wanted = !istrue(turret.cicada_turret_hold);
    turret.cicada_turret_hold = wanted;

    if (wanted)
        turret turretfiredisable();
    else
        turret turretfireenable();

    self save_turrets(true);
    self cicada_menu::update_menu();
}

function turret_firing(turret)
{
    return isdefined(turret) && !istrue(turret.cicada_turret_hold);
}

function move_turret(where, turret)
{
    if (!isdefined(turret))
        return;

    if (where == "crosshair")
    {
        spot = self cicada_util::crosshair();

        if (isdefined(spot))
            turret.origin = spot + (0, 0, 4);
    }
    else
        turret.origin = self.origin;

    self save_turrets(true);
}

function delete_turret(turret)
{
    if (!isdefined(turret))
        return;

    turret delete();

    self save_turrets(true);
    self cicada_util::message("turret ^1deleted");
    self cicada_menu::update_menu();
}

function clear_turrets()
{
    gone = 0;

    foreach (turret in turrets())
    {
        turret delete();
        gone++;
    }

    level.cicada_turrets = [];

    self save_turrets(true);
    self cicada_util::message("^:" + gone + " ^7turrets cleared");
    self cicada_menu::update_menu();
}

function private turret_key(index, field)
{
    return "turret_" + index + "_" + field;
}

function saved_turrets()
{
    total = self cicada_util::getmappersint("turrets_saved");

    if (!isdefined(total) || total < 0)
        return 0;

    return total;
}

function private clear_saved_turrets()
{
    for (i = 0; i < saved_turrets(); i++)
    {
        self cicada_util::setmappers(turret_key(i, "origin"), undefined);
        self cicada_util::setmappers(turret_key(i, "angles"), undefined);
        self cicada_util::setmappers(turret_key(i, "kind"), undefined);
        self cicada_util::setmappers(turret_key(i, "mode"), undefined);
        self cicada_util::setmappers(turret_key(i, "team"), undefined);
        self cicada_util::setmappers(turret_key(i, "hold"), undefined);
    }

    self cicada_util::setmappers("turrets_saved", 0);
}

function save_turrets(force)
{
    if (!istrue(self cicada_util::getpers("turret_save")) && !istrue(force))
        return;

    self clear_saved_turrets();

    total = 0;

    foreach (turret in turrets())
    {
        if (!isdefined(turret.cicada_turret_kind))
            continue;

        self cicada_util::setmappers(turret_key(total, "origin"), turret.origin);
        self cicada_util::setmappers(turret_key(total, "angles"), turret.angles);
        self cicada_util::setmappers(turret_key(total, "kind"), turret.cicada_turret_kind);
        self cicada_util::setmappers(turret_key(total, "mode"), turret_mode(turret));
        self cicada_util::setmappers(turret_key(total, "team"), turret.cicada_turret_team);
        self cicada_util::setmappers(turret_key(total, "hold"), istrue(turret.cicada_turret_hold));

        total++;
    }

    self cicada_util::setmappers("turrets_saved", total);
}

function load_turrets()
{
    total = self saved_turrets();

    if (!total || turret_count())
        return;

    back = 0;

    for (i = 0; i < total; i++)
    {
        spot = self cicada_util::getmappers(turret_key(i, "origin"));
        kind = self cicada_util::getmappers(turret_key(i, "kind"));

        if (!isdefined(spot) || !isdefined(kind))
            continue;

        angles = self cicada_util::getmappers(turret_key(i, "angles"));

        if (!isdefined(angles))
            angles = (0, 0, 0);

        mode = self cicada_util::getmappers(turret_key(i, "mode"));

        if (!isdefined(mode))
            mode = "sentry";

        team = self cicada_util::getmappers(turret_key(i, "team"));

        if (!isdefined(team))
            team = self my_team();

        turret = self build_turret(kind, spot, angles, mode, team);

        if (!isdefined(turret))
            continue;

        if (istrue(self cicada_util::getmappers(turret_key(i, "hold"))))
        {
            turret.cicada_turret_hold = true;
            turret turretfiredisable();
        }

        back++;
    }

    if (back)
        self cicada_util::message("^:" + back + " ^7turrets reloaded");

    self cicada_menu::update_menu();
}

function turrets_autosave()
{
    self endon("disconnect");
    level endon("game_ended");

    self notify("cicada_turret_autosave");
    self endon("cicada_turret_autosave");

    for (;;)
    {
        wait 2;

        if (!istrue(self cicada_util::getpers("turret_save")))
            continue;

        self save_turrets();
    }
}

function private add_types(types, text)
{
    foreach (name in cicada_util::list(text))
        types[types.size] = name;

    return types;
}

function every_vehicle_type()
{
    types = cicada_util::list("veh9_jltv_physics_mp,veh9_jltv_mg_physics_mp,veh9_mil_lnd_tank_physics_mp,veh9_mil_lnd_atv_physics_mp");

    types = add_types(types, "veh9_mil_lnd_utv_physics_mp,veh9_mil_lnd_cargo_truck_physics_mp,veh9_civ_lnd_hummer_physics_mp");
    types = add_types(types, "veh9_civ_lnd_van_cargo_physics_mp,veh9_civ_lnd_dirt_bike_physics_mp,veh9_civ_lnd_scooter_eu_physics_mp");
    types = add_types(types, "veh9_motorcycle_blood_burner_physics_mp,veh9_mil_air_heli_palfa_physics_mp,veh9_mil_air_heli_medium_physics_mp");
    types = add_types(types, "veh9_armored_patrol_boat_physics_mp,veh9_rhib_physics_mp,veh9_suv_1996_physics_mp");

    return types;
}

function map_types()
{
    if (!isdefined(level.cicada_map_vehicles))
        level.cicada_map_vehicles = map_vehicle_types();

    return level.cicada_map_vehicles;
}

function type_is_safe(type)
{
    foreach (name in map_types())
        if (name == type)
            return true;

    return false;
}

function vehicle_types()
{
    if (istrue(self cicada_util::getpers("vehicle_any_type")) || !map_types().size)
        return every_vehicle_type();

    return map_types();
}

function type_summary()
{
    if (!map_types().size)
        return "^1this map loads no vehicles";

    return "^:" + map_types().size + " ^7types on this map";
}

function vehicle_type()
{
    type = self cicada_util::getpers("vehicle_type");

    if (!isdefined(type) || type == "")
        return vehicle_types()[0];

    return type;
}

function vehicle_label(type)
{
    if (!isdefined(type))
        return "vehicle";

    return cicada_catalog::pretty(type, "veh9");
}

function vehicles()
{
    live = [];

    if (!isdefined(level.cicada_vehicles))
        return live;

    foreach (car in level.cicada_vehicles)
        if (isdefined(car))
            live[live.size] = car;

    return live;
}

function vehicle_count()
{
    return vehicles().size;
}

function vehicle_at(index)
{
    live = vehicles();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function vehicle_name(car)
{
    if (!isdefined(car))
        return "gone";

    return vehicle_label(car.cicada_vehicle_type);
}

function vehicle_summary()
{
    return "^:" + vehicle_count() + " ^7spawned";
}

function private build_vehicle(type, spot, angles)
{
    if (!isdefined(type) || type == "")
        return undefined;

    if (!isdefined(level.vehiclecount))
        level.vehiclecount = 0;

    if (!isdefined(level.maxvehiclecount))
        level.maxvehiclecount = 16;

    if (level.vehiclecount >= level.maxvehiclecount)
        return undefined;

    car = spawnvehicle(undefined, "cicada_vehicle", type, spot, angles, self);

    if (!isdefined(car))
        return undefined;

    level.vehiclecount++;

    car.cicada_vehicle_type = type;
    car.owner = self;

    level.cicada_vehicles[level.cicada_vehicles.size] = car;
    return car;
}

function spawn_vehicle()
{
    spot = self cicada_util::crosshair();

    if (!isdefined(spot))
    {
        self cicada_util::message_bold("^1look at the ground first");
        return;
    }

    type = self vehicle_type();

    if (!type_is_safe(type) && !istrue(self cicada_util::getpers("vehicle_any_type")))
    {
        self cicada_util::message_bold("^1this map does not load that vehicle");
        return;
    }

    car = self build_vehicle(type, spot + (0, 0, 32), (0, self getplayerangles()[1], 0));

    if (!isdefined(car))
    {
        self cicada_util::message_bold("^1that vehicle did not spawn - the map may cap them");
        return;
    }

    vehicle_allowplayeruse(self, 1);

    self cicada_util::message(vehicle_label(type) + " ^7spawned - " + vehicle_summary());
    self cicada_util::sound("scavenger_pack_pickup");

    self save_vehicles(true);
    self cicada_menu::update_menu();
}

function set_vehicle_type(type)
{
    self cicada_util::setpers("vehicle_type", type);
    self spawn_vehicle();
}

function move_vehicle(where, car)
{
    if (!isdefined(car))
        return;

    switch (where)
    {
        case "crosshair":
            spot = self cicada_util::crosshair();

            if (isdefined(spot))
                car vehicle_teleport(spot + (0, 0, 32), car.angles);

            break;

        case "in front of me":
            car vehicle_teleport(self.origin + anglestoforward(self getplayerangles()) * 200 + (0, 0, 32), car.angles);
            break;

        case "me to it":
            self setorigin(car.origin + (0, 0, 72));
            break;
    }

    self save_vehicles(true);
}

function set_vehicle_speed(value, key)
{
    self cicada_util::setpers(key, value);

    foreach (car in vehicles())
    {
        car vehicle_settopspeedforward(value);
        car vehicle_settopspeedreverse(int(value / 2));
    }
}

function toggle_engine(car)
{
    if (!isdefined(car))
        return;

    wanted = !istrue(car.cicada_vehicle_off);
    car.cicada_vehicle_off = wanted;

    if (wanted)
        car vehicle_turnengineoff();
    else
        car vehicle_turnengineon();

    self cicada_menu::update_menu();
}

function engine_on(car)
{
    return isdefined(car) && !istrue(car.cicada_vehicle_off);
}

function set_vehicle_side(pick, car)
{
    if (!isdefined(car))
        return;

    team = self team_for(pick);

    car.team = team;
    car.cicada_vehicle_team = team;
    car setvehicleteam(team);

    self save_vehicles(true);
    self cicada_menu::update_menu();
}

function vehicle_side(car)
{
    if (isdefined(car) && isdefined(car.cicada_vehicle_team) && car.cicada_vehicle_team != self my_team())
        return "enemy";

    return "yours";
}

function toggle_vehicle_blip(car)
{
    if (!isdefined(car))
        return;

    wanted = !istrue(car.cicada_vehicle_blip);
    car.cicada_vehicle_blip = wanted;

    if (wanted)
        car vehicleshowonminimap(1);
    else
        car vehicleshowonminimap(0);

    self save_vehicles(true);
    self cicada_menu::update_menu();
}

function vehicle_blip(car)
{
    return isdefined(car) && istrue(car.cicada_vehicle_blip);
}

function drive_vehicle(car)
{
    if (!isdefined(car) || !isalive(self))
        return;

    vehicle_allowplayeruse(self, 1);
    self usevehicle(car, 0);
    self cicada_util::message("driving the ^:" + vehicle_name(car));
}

function delete_vehicle(car)
{
    if (!isdefined(car))
        return;

    car delete();

    if (isdefined(level.vehiclecount) && level.vehiclecount > 0)
        level.vehiclecount--;

    self save_vehicles(true);
    self cicada_util::message("vehicle ^1deleted");
    self cicada_menu::update_menu();
}

function clear_vehicles()
{
    gone = 0;

    foreach (car in vehicles())
    {
        car delete();
        gone++;

        if (isdefined(level.vehiclecount) && level.vehiclecount > 0)
            level.vehiclecount--;
    }

    level.cicada_vehicles = [];

    self save_vehicles(true);
    self cicada_util::message("^:" + gone + " ^7vehicles cleared");
    self cicada_menu::update_menu();
}

function private vehicle_key(index, field)
{
    return "vehicle_" + index + "_" + field;
}

function saved_vehicles()
{
    total = self cicada_util::getmappersint("vehicles_saved");

    if (!isdefined(total) || total < 0)
        return 0;

    return total;
}

function private clear_saved_vehicles()
{
    for (i = 0; i < saved_vehicles(); i++)
    {
        self cicada_util::setmappers(vehicle_key(i, "type"), undefined);
        self cicada_util::setmappers(vehicle_key(i, "origin"), undefined);
        self cicada_util::setmappers(vehicle_key(i, "angles"), undefined);
        self cicada_util::setmappers(vehicle_key(i, "team"), undefined);
        self cicada_util::setmappers(vehicle_key(i, "blip"), undefined);
    }

    self cicada_util::setmappers("vehicles_saved", 0);
}

function save_vehicles(force)
{
    if (!istrue(self cicada_util::getpers("vehicle_save")) && !istrue(force))
        return;

    self clear_saved_vehicles();

    total = 0;

    foreach (car in vehicles())
    {
        if (!isdefined(car.cicada_vehicle_type))
            continue;

        self cicada_util::setmappers(vehicle_key(total, "type"), car.cicada_vehicle_type);
        self cicada_util::setmappers(vehicle_key(total, "origin"), car.origin);
        self cicada_util::setmappers(vehicle_key(total, "angles"), car.angles);
        self cicada_util::setmappers(vehicle_key(total, "team"), car.cicada_vehicle_team);
        self cicada_util::setmappers(vehicle_key(total, "blip"), istrue(car.cicada_vehicle_blip));

        total++;
    }

    self cicada_util::setmappers("vehicles_saved", total);
}

function load_vehicles()
{
    total = self saved_vehicles();

    if (!total || vehicle_count())
        return;

    back = 0;

    for (i = 0; i < total; i++)
    {
        type = self cicada_util::getmappers(vehicle_key(i, "type"));
        spot = self cicada_util::getmappers(vehicle_key(i, "origin"));

        if (!isdefined(type) || !isdefined(spot))
            continue;

        angles = self cicada_util::getmappers(vehicle_key(i, "angles"));

        if (!isdefined(angles))
            angles = (0, 0, 0);

        car = self build_vehicle(type, spot, angles);

        if (!isdefined(car))
            continue;

        team = self cicada_util::getmappers(vehicle_key(i, "team"));

        if (isdefined(team))
        {
            car.team = team;
            car.cicada_vehicle_team = team;
            car setvehicleteam(team);
        }

        if (istrue(self cicada_util::getmappers(vehicle_key(i, "blip"))))
        {
            car.cicada_vehicle_blip = true;
            car vehicleshowonminimap(1);
        }

        back++;
    }

    if (back)
    {
        vehicle_allowplayeruse(self, 1);
        self cicada_util::message("^:" + back + " ^7vehicles reloaded");
    }

    self cicada_menu::update_menu();
}

function vehicles_autosave()
{
    self endon("disconnect");
    level endon("game_ended");

    self notify("cicada_vehicle_autosave");
    self endon("cicada_vehicle_autosave");

    for (;;)
    {
        wait 2;

        if (!istrue(self cicada_util::getpers("vehicle_save")))
            continue;

        self save_vehicles();
    }
}

function private shock_spot()
{
    spot = self cicada_util::crosshair();

    if (!isdefined(spot))
        spot = self.origin;

    return spot;
}

function shock_ai(spot, radius, force)
{
    hit = 0;

    foreach (ent in getaiarrayinradius(spot, radius))
    {
        if (!isalive(ent))
            continue;

        away = vectornormalize(ent.origin - spot);

        if (istrue(self cicada_util::getpers("shock_hurts_ai")))
            ent dodamage(self cicada_util::getpersint("shock_damage"), spot, self, self, "MOD_EXPLOSIVE");

        if (isalive(ent))
            ent startragdollfromimpact("torso_upper", away * force + (0, 0, force));

        hit++;
    }

    return hit;
}

function shockwave()
{
    spot = self shock_spot();

    outer = self cicada_util::getpersint("shock_radius");
    inner = int(outer / 2);
    force = self cicada_util::getpersfloat("shock_force");

    physicsexplosionsphere(spot, outer, inner, force);

    if (istrue(self cicada_util::getpers("shock_hits_ai")))
        self shock_ai(spot, outer, force * 100);

    if (istrue(self cicada_util::getpers("shock_quake")))
        self earthquakeforplayer(0.4, 0.7, spot, outer * 2);

    self cicada_util::sound("grenade_explode_default");
    self cicada_util::message("shockwave at ^:" + outer + " ^7units");
}

function launch_models()
{
    spot = self shock_spot();

    radius = self cicada_util::getpersint("shock_radius");
    force = self cicada_util::getpersfloat("shock_force") * 100;

    sent = 0;

    foreach (prop in cicada_props::props())
    {
        if (!isdefined(prop) || distance(prop.origin, spot) > radius)
            continue;

        away = vectornormalize(prop.origin - spot);
        prop physicslaunchserver(prop.origin, away * force + (0, 0, force));
        sent++;
    }

    self cicada_util::message("^:" + sent + " ^7models launched");
}

function launch_ai()
{
    spot = self shock_spot();

    radius = self cicada_util::getpersint("shock_radius");
    force = self cicada_util::getpersfloat("shock_force") * 100;

    self cicada_util::message("^:" + self shock_ai(spot, radius, force) + " ^7agents launched");
}

function ragdoll_gravity()
{
    value = self cicada_util::getpersfloat("ragdoll_gravity");

    if (value <= 0)
        return 1;

    return value;
}

function apply_ragdoll_gravity()
{
    physics_setgravityragdollscalar(self ragdoll_gravity());
}

function set_ragdoll_gravity(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_ragdoll_gravity();
}

function door_radius()
{
    radius = self cicada_util::getpersint("door_radius");

    if (radius < 100)
        return 1000;

    return radius;
}

function doors_near()
{
    list = [];

    foreach (ent in getentitylessscriptablearray(undefined, undefined, self.origin, self door_radius(), "door"))
        if (isdefined(ent) && ent scriptableisdoor())
            list[list.size] = ent;

    return list;
}

function door_summary()
{
    return "^:" + doors_near().size + " ^7near you";
}

function manage_doors(action)
{
    hit = 0;

    foreach (door in doors_near())
    {
        switch (action)
        {
            case "open":
                door scriptabledoorfreeze(0);
                door scriptabledooropen();
                break;

            case "close":
                door scriptabledoorfreeze(0);
                door scriptabledoorclose();
                break;

            case "freeze":
                door scriptabledoorfreeze(1);
                break;

            case "unfreeze":
                door scriptabledoorfreeze(0);
                break;
        }

        hit++;
    }

    self cicada_util::message("^:" + hit + " ^7doors - ^:" + action);
    self cicada_menu::update_menu();
}

function radius_report()
{
    radius = self door_radius();

    self cicada_util::message("^:" + getentitylessscriptablearray(undefined, undefined, self.origin, radius, "door").size + " ^7door scriptables - ^:" + doors_near().size + " ^7doors");
    self cicada_util::message("^:" + self cicada_pve::near_agents(radius).size + " ^7agents - ^:" + vehicle_getarrayinradius(self.origin, radius, radius).size + " ^7vehicles - ^:" + turret_count() + " ^7turrets");
}

function crates()
{
    list = [];

    if (!isdefined(level.cratedata) || !isdefined(level.cratedata.crates))
        return list;

    foreach (crate in level.cratedata.crates)
        if (isdefined(crate) && isdefined(crate.cratetype))
            list[list.size] = crate;

    return list;
}

function crate_count()
{
    return crates().size;
}

function crate_summary()
{
    total = crate_count();

    if (!total)
        return "^1no crates on the map";

    return "^:" + total + " ^7crates dropped";
}

function capture_radius()
{
    value = self cicada_util::getpersint("capture_radius");

    if (value < 64)
        return 64;

    return value;
}

function private crate_near()
{
    best = undefined;
    gap = self capture_radius();

    foreach (crate in crates())
    {
        if (!isdefined(crate.origin))
            continue;

        space = distance(self.origin, crate.origin);

        if (space > gap)
            continue;

        gap = space;
        best = crate;
    }

    return best;
}

function private take_crate(crate)
{
    if (!isdefined(crate) || !isdefined(crate.cratetype))
        return false;

    crate scripts\cp_mp\killstreaks\airdrop::capturecrate(self);
    return true;
}

function capture_crate()
{
    crate = self crate_near();

    if (!isdefined(crate))
    {
        self cicada_util::message(cicada_util::warn("no crate within ^:" + self capture_radius()));
        return;
    }

    self take_crate(crate);
    self cicada_util::message("crate ^2captured");
    self cicada_menu::update_menu();
}

function capture_every_crate()
{
    taken = 0;

    foreach (crate in crates())
        if (self take_crate(crate))
            taken++;

    if (!taken)
    {
        self cicada_util::message(cicada_util::warn("no crates to capture"));
        return;
    }

    self cicada_util::message("^:" + taken + " ^7crates captured");
    self cicada_menu::update_menu();
}

function objectives()
{
    list = [];

    if (!isdefined(self.touchinggameobjects))
        return list;

    foreach (object in self.touchinggameobjects)
        if (isdefined(object))
            list[list.size] = object;

    return list;
}

function using_objects()
{
    list = [];

    if (!isdefined(self.usinggameobjects))
        return list;

    foreach (object in self.usinggameobjects)
        if (isdefined(object))
            list[list.size] = object;

    return list;
}

function objective_summary()
{
    total = self objectives().size;

    if (!total)
        return "^1stand on an objective first";

    return "^:" + total + " ^7in reach";
}

function capture_objective()
{
    done = 0;

    foreach (object in self objectives())
    {
        if (!isdefined(object.onuse))
            continue;

        object [[object.onuse]](self);
        done++;
    }

    if (!done)
    {
        self cicada_util::message(cicada_util::warn("nothing here to capture"));
        return;
    }

    self cicada_util::message("^:" + done + " ^7objectives taken");
    self cicada_menu::update_menu();
}

function finish_bar()
{
    done = 0;

    foreach (object in self using_objects())
    {
        if (!isdefined(object.usetime))
            continue;

        if (isdefined(object.clientprogress) && isdefined(self.clientid))
            object.clientprogress[self.clientid] = object.usetime;
        else
            object.curprogress = object.usetime;

        done++;
    }

    if (!done)
    {
        self cicada_util::message(cicada_util::warn("hold use on something first"));
        return;
    }

    self cicada_util::message("bar ^2filled");
}

function objective_speed()
{
    value = self cicada_util::getpersfloat("objective_speed");

    if (value < 1)
        return 1;

    return value;
}

function private push_objective_speed()
{
    speed = self objective_speed();

    foreach (player_ in level.players)
        if (isdefined(player_) && cicada_util::is_bot(player_))
            player_.objectivescaler = speed;

    foreach (agent in self cicada_pve::near_agents(100000))
        if (isdefined(agent))
            agent.objectivescaler = speed;
}

function apply_objective_speed()
{
    self.objectivescaler = self objective_speed();

    if (istrue(self cicada_util::getpers("objective_speed_ai")))
        self push_objective_speed();
}

function set_objective_speed(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_objective_speed();
}

function apply_objective_cap()
{
    level.objectivescaler = self cicada_util::getpersfloat("objective_cap");
}

function set_objective_cap(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_objective_cap();
}

function speed_summary()
{
    return "^:" + self objective_speed() + "x ^7on every bar";
}

function bar_label()
{
    value = self cicada_util::getpersint("bar_label");

    if (value < 0)
        return 0;

    return value;
}

function bar_time()
{
    value = self cicada_util::getpersfloat("bar_time");

    if (value < 0.25)
        return 0.25;

    return value;
}

function bar_payoffs()
{
    return cicada_util::list("nothing,capture crate,capture every crate,capture objective");
}

function bar_summary()
{
    if (istrue(self.cicada_bar_on))
        return "^2bar is running";

    return "^:" + self bar_time() + "s ^7label ^:" + self bar_label();
}

function clear_bar()
{
    self setclientomnvar("ui_securing", 0);
    self setclientomnvar("ui_securing_progress", 0);
}

function set_bar_payoff(value, key)
{
    self cicada_util::setpers(key, value);
    self cicada_menu::update_menu();
}

function private frame_step()
{
    if (!isdefined(level.framedurationseconds) || level.framedurationseconds <= 0)
        return 0.05;

    return level.framedurationseconds;
}

function private bar_payoff()
{
    pick = self cicada_util::getpers("bar_payoff");

    if (!isdefined(pick))
        return;

    switch (pick)
    {
        case "nothing":
            break;

        case "capture crate":
            self capture_crate();
            break;

        case "capture every crate":
            self capture_every_crate();
            break;

        default:
            self capture_objective();
            break;
    }
}

function private release_bar()
{
    self.cicada_bar_on = undefined;

    if (istrue(self.cicada_bar_frozen))
    {
        self.cicada_bar_frozen = undefined;

        if (isalive(self))
            self freezecontrols(0);
    }

    self clear_bar();
}

function end_bar()
{
    self notify("cicada_bar_preview");

    if (istrue(self.cicada_bar_on))
        self notify("cicada_bar_stop");

    self release_bar();
}

function private bar_loop()
{
    self endon("disconnect");
    self endon("cicada_bar_stop");
    level endon("game_ended");

    self.cicada_bar_on = true;

    hold = istrue(self cicada_util::getpers("bar_freeze"));
    spot = self.origin;
    span = self bar_time();
    step = frame_step();
    done = 0;

    if (hold)
    {
        self.cicada_bar_frozen = true;
        self freezecontrols(1);
    }

    self setclientomnvar("ui_securing", self bar_label());

    while (done < span && isalive(self))
    {
        self setclientomnvar("ui_securing_progress", done / span);

        if (hold)
        {
            self setorigin(spot);
            self setvelocity((0, 0, 0));
        }

        done += step;
        waitframe();
    }

    filled = done >= span && isalive(self);

    if (filled)
    {
        self setclientomnvar("ui_securing_progress", 1);
        wait 0.15;
    }

    self release_bar();

    if (filled)
        self bar_payoff();

    self cicada_menu::update_menu();
}

function stop_bar()
{
    if (!istrue(self.cicada_bar_on))
        return;

    self end_bar();
    self cicada_menu::update_menu();
}

function run_bar()
{
    self end_bar();
    self thread [[&bar_loop]]();
}

function private clear_bar_soon()
{
    self endon("disconnect");
    self notify("cicada_bar_preview");
    self endon("cicada_bar_preview");

    wait 1.5;

    if (!istrue(self.cicada_bar_on))
        self clear_bar();
}

function preview_bar_label(value)
{
    self end_bar();

    self setclientomnvar("ui_securing", value);
    self setclientomnvar("ui_securing_progress", 0.5);
    self thread [[&clear_bar_soon]]();
}

function spawn_restore()
{
    self end_bar();
    self apply_ragdoll_gravity();
    self apply_objective_speed();
    self apply_objective_cap();

    if (istrue(self cicada_util::getpers("turret_save")) && !istrue(level.cicada_turrets_restored))
    {
        level.cicada_turrets_restored = true;
        self load_turrets();
    }

    if (istrue(self cicada_util::getpers("vehicle_save")) && !istrue(level.cicada_vehicles_restored))
    {
        level.cicada_vehicles_restored = true;
        self load_vehicles();
    }

    self thread [[&turrets_autosave]]();
    self thread [[&vehicles_autosave]]();
}

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
