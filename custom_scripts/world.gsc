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
        self cicada_util::message("^:" + back + " ^7turrets back from the last round");

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
        self cicada_util::message("^:" + back + " ^7vehicles back from the last round");
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

function spawn_restore()
{
    self apply_ragdoll_gravity();

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
