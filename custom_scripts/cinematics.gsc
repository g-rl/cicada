#using scripts\cp_mp\utility\player_utility;

#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\util;

#namespace cicada_cinematics;

function max_nodes()
{
    return 12;
}

function init()
{
    precachemodel("axis_guide_createfx");

    camera = spawnstruct();
    camera.nodes = [];
    camera.markers = [];
    camera.preview = [];
    camera.running = false;
    level.cicada_camera = camera;
}

function private node_key(index, part)
{
    return "camera_node_" + index + "_" + part;
}

function store_nodes()
{
    camera = level.cicada_camera;

    for (i = 0; i < max_nodes(); i++)
    {
        self cicada_util::setmappers(node_key(i, "origin"), undefined);
        self cicada_util::setmappers(node_key(i, "angles"), undefined);
    }

    for (i = 0; i < camera.nodes.size; i++)
    {
        self cicada_util::setmappers(node_key(i, "origin"), camera.nodes[i].origin);
        self cicada_util::setmappers(node_key(i, "angles"), camera.nodes[i].angles);
    }

    self cicada_util::setmappers("camera_nodes", camera.nodes.size);
}

function restore_nodes()
{
    total = self cicada_util::getmappersint("camera_nodes");

    if (!total || node_count())
        return;

    camera = level.cicada_camera;

    for (i = 0; i < total; i++)
    {
        origin = self cicada_util::getmappers(node_key(i, "origin"));
        angles = self cicada_util::getmappers(node_key(i, "angles"));

        if (!isdefined(origin) || !isdefined(angles))
            continue;

        node = spawnstruct();
        node.origin = origin;
        node.angles = angles;

        camera.nodes[camera.nodes.size] = node;
    }

    if (!node_count())
        return;

    refresh_marker_outlines();
    self rebuild_preview();
    self cicada_util::message("^:" + node_count() + " ^7camera nodes back");
}

function node_count()
{
    return level.cicada_camera.nodes.size;
}

function mode()
{
    stored = self cicada_util::getpers("camera_mode");
    return isdefined(stored) ? stored : "bezier";
}

function summary()
{
    return "^:" + node_count() + " ^7nodes, ^:" + self mode();
}

function save_node()
{
    if (node_count() >= max_nodes())
    {
        self cicada_util::message_bold("^1node limit reached");
        return;
    }

    node = spawnstruct();
    node.origin = self.origin;
    node.angles = self getplayerangles();

    camera = level.cicada_camera;
    camera.nodes[camera.nodes.size] = node;

    refresh_marker_outlines();
    self rebuild_preview();
    self store_nodes();
    self cicada_util::message("node ^:#" + node_count() + " ^7saved");
}

function delete_last_node()
{
    camera = level.cicada_camera;
    if (!camera.nodes.size)
    {
        self cicada_util::message_bold("^1no nodes to delete");
        return;
    }

    last = camera.nodes.size - 1;
    if (isdefined(camera.markers[last]))
        camera.markers[last] delete();

    camera.nodes[last] = undefined;
    camera.markers[last] = undefined;

    refresh_marker_outlines();
    self rebuild_preview();
    self store_nodes();
    self cicada_util::message("node ^:#" + (last + 1) + " ^7deleted");
}

function clear_nodes()
{
    camera = level.cicada_camera;

    foreach (marker in camera.markers)
        if (isdefined(marker))
            marker delete();

    camera.nodes = [];
    camera.markers = [];

    self clear_preview();
    self store_nodes();
    self cicada_util::message("nodes ^1cleared");
}

function refresh_marker_outlines()
{
    camera = level.cicada_camera;
    last = camera.nodes.size - 1;

    for (i = 0; i < camera.nodes.size; i++)
    {
        outline = (i == last) ? "outlinefill_nodepth_yellow" : "outlinefill_nodepth_green";

        if (isdefined(camera.markers[i]))
        {
            if (camera.markers[i].cicada_outline == outline)
                continue;

            camera.markers[i] delete();
        }

        camera.markers[i] = spawn_marker(camera.nodes[i], outline);
    }
}

function spawn_marker(node, outline)
{
    marker = spawn("script_model", node.origin + (0, 0, 58));
    marker setmodel("axis_guide_createfx");
    marker.angles = node.angles;
    marker hudoutlineenable(outline);
    marker.cicada_outline = outline;
    return marker;
}

function set_mode(value)
{
    self cicada_util::setpers("camera_mode", value);
    self rebuild_preview();
}

function set_rotation(value)
{
    self cicada_util::setpers("camera_rotation", value);
    self roll_view(int(value));
    self notify("cicada_camera_rotation");
    self thread [[&reset_roll]]();
}

function fov()
{
    return self cicada_util::getpersint("camera_fov");
}

function set_fov(value)
{
    self cicada_util::setpers("camera_fov", value);
}

function preview_fov(value)
{
    if (istrue(level.cicada_camera.running))
        return;

    self set_fov(value);
    self apply_fov(0.05);
    self notify("cicada_camera_fov");
    self thread [[&reset_fov_preview]]();
}

function apply_fov(time)
{
    value = self fov();
    if (!value)
    {
        self reset_fov();
        return;
    }

    self.cicada_camera_fov = true;

    self lerpfovscalefactor(0, 0);
    self lerpfov(value, time);
}

function reset_fov()
{
    if (!isdefined(self.cicada_camera_fov))
        return;

    self.cicada_camera_fov = undefined;
    self lerpfov(base_fov(), 0.25);
    self lerpfovbypreset("default_2seconds");
    self lerpfovscalefactor(1, 0.25);
}

function base_fov()
{
    return 65;
}

function reset_fov_preview()
{
    self endon("disconnect");
    self endon("cicada_camera_fov");

    wait 3;

    if (istrue(level.cicada_camera.running))
        return;

    self reset_fov();
}

function roll_view(roll)
{
    angles = self getplayerangles();
    self setplayerangles((angles[0], angles[1], roll));
}

function reset_roll()
{
    self endon("disconnect");
    self endon("cicada_camera_rotation");

    wait 1;
    self roll_view(0);
}

function start_path()
{
    if (node_count() < 3)
    {
        self cicada_util::message_bold("^1at least ^73 ^1nodes needed");
        return;
    }

    camera = level.cicada_camera;
    if (istrue(camera.running))
    {
        self cicada_util::message_bold("^1path already running");
        return;
    }

    type = self mode();
    speed = (type == "linear") ? self cicada_util::getpersint("camera_linear_time") : self cicada_util::getpersint("camera_bezier_speed");

    self.cicada_camera_loadout = self getweaponslistall();
    self takeallweapons();

    rig = spawn("script_model", camera.nodes[0].origin);
    rig setmodel("tag_origin");
    rig rotateto(camera.nodes[0].angles, 0.05);

    camera.rig = rig;
    camera.running = true;

    self roll_view(self cicada_util::getpersint("camera_rotation"));
    self apply_fov(0.05);
    self playerlinktodelta(rig, "tag_origin", 1, 0, 0, 0, 0, true);
    self cicada_util::message_bold("^:" + type + " ^7path - ^:" + node_count() + " ^7nodes");

    wait 2;

    if (!istrue(camera.running))
        return;

    self hide_player();
    started = gettime();

    if (type == "linear")
        self travel_linear(rig, speed);
    else
        self travel_bezier(rig, speed);

    if (istrue(camera.running))
        self stop_path();

    self cicada_util::message("path ran for ^:" + ((gettime() - started) / 1000) + "^7s");
}

function travel_linear(rig, seconds)
{
    camera = level.cicada_camera;
    angles = unwound_angles();
    leg = float(seconds) / (camera.nodes.size - 1);
    ease = leg * 0.2;

    for (i = 1; i < camera.nodes.size; i++)
    {
        if (!istrue(camera.running))
            return;

        rig moveto(camera.nodes[i].origin, leg, ease, ease);
        rig rotateto(angles[i], leg, ease, ease);
        wait (leg);
    }
}

function travel_bezier(rig, speed)
{
    camera = level.cicada_camera;
    origins = node_origins();
    angles = unwound_angles();

    steps = int(path_length() * 2 / speed);
    if (steps < 1)
        steps = 1;

    total = steps * 0.05;
    segments = int(total / 0.25);
    if (segments < 1)
        segments = 1;

    leg = total / segments;

    for (i = 1; i <= segments; i++)
    {
        if (!istrue(camera.running))
            return;

        t = float(i) / segments;
        rig moveto(bezier(origins, t), leg, 0, 0);
        rig rotateto(bezier(angles, t), leg, 0, 0);
        wait (leg);
    }
}

function stop_path()
{
    camera = level.cicada_camera;
    if (!istrue(camera.running))
    {
        self cicada_util::message_bold("^1no path running");
        return;
    }

    camera.running = false;

    self show_player();
    self unlink();

    if (isdefined(camera.rig))
        camera.rig delete();

    camera.rig = undefined;

    self roll_view(0);
    self reset_fov();
    self restore_loadout();
}

function hide_player()
{
    self freezecontrols(1);
    self playerhide();
    self setclientomnvar("ui_hide_full_hud", 1);
    setdvar("cg_drawgun", 0);
    setdvar("cg_drawcrosshair", 0);
    self set_preview_visible(false);
}

function show_player()
{
    self set_preview_visible(true);
    setdvar("cg_drawgun", 1);
    setdvar("cg_drawcrosshair", 1);
    self setclientomnvar("ui_hide_full_hud", 0);
    self playershow();
    self freezecontrols(0);
}

function restore_loadout()
{
    if (!isdefined(self.cicada_camera_loadout))
        return;

    held = undefined;

    foreach (weapon in self.cicada_camera_loadout)
    {
        if (weapon.basename == "none")
            continue;

        self giveweapon(weapon);

        if (!isdefined(held))
            held = weapon;
    }

    self.cicada_camera_loadout = undefined;

    if (!isdefined(held))
        return;

    self switchtoweaponimmediate(held);
    self cicada_loadout::apply_camo();
}

function archive_limit()
{
    limit = getdvarfloat("scr_killcam_time", 5);

    return (limit < 1) ? 5 : limit;
}

function scene_length()
{
    span = self cicada_util::getpersfloat("scene_length");

    if (span < 1)
        span = 5;

    room = archive_limit() - 1;

    if (room < 1)
        room = 1;

    if (span > room)
        span = room;

    return span;
}

function uses_overlay()
{
    return istrue(self cicada_util::getpers("scene_overlay"));
}

function scene_speed()
{
    speed = self cicada_util::getpersfloat("scene_speed");

    if (speed < 0.1)
        speed = 1;

    if (speed > 1)
        speed = 1;

    return speed;
}

function private blank_overlay()
{
    self setclientomnvar("ui_killcam_end_milliseconds", 0);
    self setclientomnvar("ui_killcam_killedby_id", -1);
    self setclientomnvar("ui_killcam_victim_id", -1);
    self setclientomnvar("ui_killcam_killedby_item_type", -1);
    self setclientomnvar("ui_killcam_killedby_item_id", -1);
    self setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
    self setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);

    for (i = 0; i < 8; i++)
        self setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);

    for (i = 0; i < 7; i++)
        self setclientomnvar("ui_killcam_killedby_perk" + i, "none");

    self setclientomnvar("ui_killcam_killedby_equipment_primary", "none");
    self setclientomnvar("ui_killcam_killedby_equipment_secondary", "none");
    self setclientomnvar("ui_killcam_text", "none");
    self setclientomnvar("ui_killcam_victim_or_attacker", -1);
    self setclientomnvar("ui_killcam_killedby_health_ratio", 0);
    self setclientomnvar("cam_scene_name", "unknown");
    self setclientomnvar("cam_scene_lead", -1);
    self setclientomnvar("cam_scene_support", -1);
}

function private hide_spectator_ui()
{
    self setclientomnvar("ui_session_state", "playing");
}

function private hold_overlay_off()
{
    self endon("disconnect");
    self endon("cicada_scene_done");

    for (;;)
    {
        self blank_overlay();
        self hide_spectator_ui();
        wait 0.05;
    }
}

function private guard_archive()
{
    self endon("disconnect");
    self endon("cicada_scene_done");

    for (;;)
    {
        waitframe();

        if (!self scene_running())
            return;

        if (isdefined(self.archivetime) && self.archivetime <= 0.5)
        {
            self end_scene();
            return;
        }
    }
}

function scene_running()
{
    return istrue(self.cicada_scene_running);
}

function private take_snapshot()
{
    saved = spawnstruct();

    saved.origin = self.origin;
    saved.angles = self getplayerangles();
    saved.health = self.health;
    saved.weapons = self getweaponslistall();
    saved.held = self getcurrentweapon();
    saved.third = istrue(self cicada_util::getpers("third_person"));

    return saved;
}

function private give_back(saved)
{
    if (!isdefined(saved) || !isdefined(saved.weapons))
        return;

    held = undefined;

    foreach (weapon in saved.weapons)
    {
        if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
            continue;

        self giveweapon(weapon);

        if (!isdefined(held))
            held = weapon;
    }

    if (isdefined(saved.held) && !isnullweapon(saved.held) && self hasweapon(saved.held))
        held = saved.held;

    if (!isdefined(held))
        return;

    self switchtoweaponimmediate(held);
    self cicada_loadout::apply_camo();
}

function private stop_archive()
{
    self.spectatekillcam = 0;
    self.forcespectatorclient = -1;
    self.killcamentity = -1;
    self.killcamentitylookat = -1;
    self.archivetime = 0;
    self.killcamlength = 0;
    self.psoffsettime = 0;

    self notify("killcam_ended");
    self notify("abort_killcam");

    player_utility::updatesessionstate("playing");
}

function private begin_archive(span)
{
    player_utility::updatesessionstate("spectator");

    self.spectatekillcam = 1;
    self.forcespectatorclient = self getentitynumber();
    self.killcamentity = -1;
    self.archivetime = span;
    self.killcamlength = span;
    self.psoffsettime = 0;

    self allowspectateteam("freelook", 1);
    self allowspectateteam("none", 1);

    if (isdefined(level.teamnamelist))
        foreach (team in level.teamnamelist)
            self allowspectateteam(team, 1);
}

function end_scene()
{
    if (!self scene_running())
        return;

    self.cicada_scene_running = false;
    level.cicada_camera.running = false;

    if (isdefined(self.cicada_scene_rig))
    {
        self.cicada_scene_rig delete();
        self.cicada_scene_rig = undefined;
    }

    self blank_overlay();
    self stop_archive();
    self cicada_mods::restore_timescale();

    if (self islinked())
        self unlink();

    self show_player();
    self roll_view(0);
    self reset_fov();

    saved = self.cicada_scene_saved;
    self.cicada_scene_saved = undefined;

    if (isdefined(saved))
    {
        if (isalive(self))
        {
            self setorigin(saved.origin);
            self setplayerangles(saved.angles);

            if (isdefined(saved.health) && saved.health > 0)
                self.health = saved.health;
        }

        self give_back(saved);
    }

    self notify("cicada_scene_done");
    self cicada_menu::update_menu();
}

function recover_scene()
{
    if (!isdefined(self.cicada_scene_saved) && !self scene_running())
        return;

    self.cicada_scene_running = true;
    self end_scene();
}

function private guard_death()
{
    self endon("disconnect");
    self endon("cicada_scene_done");

    self waittill("death");
    self end_scene();
}

function private guard_round()
{
    self endon("disconnect");
    self endon("cicada_scene_done");

    level waittill("game_ended");
    self end_scene();
}

function private scene_note(text)
{
    if (!istrue(self cicada_util::getpers("scene_notes")))
        return;

    self cicada_util::message("^:scene ^7" + text);
}

function private hold_camera(rig, span)
{
    started = gettime();
    eye = rig.origin;
    side = anglestoright(rig.angles);

    while (self scene_running() && (gettime() - started) < (span * 1000))
    {
        rig moveto(eye + side * 60, 1, 0.25, 0.25);
        wait 1;

        if (!self scene_running())
            return;

        self scene_note("archive ^:" + self.archivetime + " ^7linked ^:" + (self islinked() ? "yes" : "no"));

        rig moveto(eye, 1, 0.25, 0.25);
        wait 1;
    }
}

function private walk_nodes(rig, span)
{
    camera = level.cicada_camera;

    rig.origin = camera.nodes[0].origin;
    rig rotateto(camera.nodes[0].angles, 0.05);

    waitframe();

    self scene_note("nodes ^:" + node_count() + " ^7over ^:" + span + "^7s");

    if (istrue(self cicada_util::getpers("scene_fit")) || self mode() == "linear")
    {
        self travel_linear(rig, span);
        return;
    }

    self travel_bezier(rig, self cicada_util::getpersint("camera_bezier_speed"));
}

function private run_scene()
{
    self endon("disconnect");

    span = self scene_length();

    self.cicada_scene_running = true;
    self.cicada_scene_saved = self take_snapshot();

    self thread [[&guard_death]]();
    self thread [[&guard_round]]();
    self thread [[&guard_archive]]();

    eye = self geteye();
    angles = self getplayerangles();

    if (self cicada_util::in_menu())
        self cicada_menu::close_menu();

    self takeallweapons();
    self hide_player();

    self begin_archive(span);

    if (!self uses_overlay())
        self thread [[&hold_overlay_off]]();

    rig = spawn("script_model", eye);
    rig setmodel("tag_origin");
    rig.angles = angles;

    self.cicada_scene_rig = rig;
    self playerlinktodelta(rig, "tag_origin", 1, 0, 0, 0, 0, true);
    self.killcamentity = rig getentitynumber();

    self roll_view(self cicada_util::getpersint("camera_rotation"));
    self apply_fov(0.05);

    speed = self scene_speed();

    if (speed < 1)
        setslowmotion(1, speed, 0);

    self scene_note("rewound ^:" + span + "^7s - limit ^:" + archive_limit() + "^7s");

    if (node_count() >= 3)
    {
        level.cicada_camera.running = true;
        self walk_nodes(rig, span);
    }
    else
        self hold_camera(rig, span);

    self end_scene();
    self cicada_util::message("scene ^2done");
}

function play_scene()
{
    if (self scene_running())
    {
        self end_scene();
        self cicada_util::message("scene ^1stopped");
        return;
    }

    if (!isalive(self))
    {
        self cicada_util::message(cicada_util::warn("stay alive for this"));
        return;
    }

    if (istrue(level.cicada_camera.running))
    {
        self cicada_util::message(cicada_util::warn("stop the camera path first"));
        return;
    }

    self thread [[&run_scene]]();
}

function clone_self()
{
    self cloneplayer(1);
}

function rebuild_preview()
{
    self clear_preview();

    camera = level.cicada_camera;
    if (self mode() != "bezier" || camera.nodes.size < 3)
        return;

    origins = node_origins();
    steps = camera.nodes.size * 8;

    for (i = 0; i < steps; i++)
    {
        origin = bezier(origins, float(i) / (steps - 1));
        dot = spawn("script_model", origin + (0, 0, 58));
        dot setmodel("axis_guide_createfx");
        dot hudoutlineenable("outlinefill_nodepth_red");
        camera.preview[camera.preview.size] = dot;
    }
}

function clear_preview()
{
    camera = level.cicada_camera;

    foreach (dot in camera.preview)
        if (isdefined(dot))
            dot delete();

    camera.preview = [];
}

function set_preview_visible(visible)
{
    camera = level.cicada_camera;

    foreach (marker in camera.markers)
        if (isdefined(marker))
            marker set_visible(visible);

    foreach (dot in camera.preview)
        if (isdefined(dot))
            dot set_visible(visible);
}

function set_visible(visible)
{
    if (istrue(visible))
        self show();
    else
        self hide();
}

function bezier(points, t)
{
    x = 0;
    y = 0;
    z = 0;
    degree = points.size - 1;

    for (i = 0; i <= degree; i++)
    {
        weight = binomial(degree, i) * pow(1 - t, degree - i) * pow(t, i);

        x += points[i][0] * weight;
        y += points[i][1] * weight;
        z += points[i][2] * weight;
    }

    return (x, y, z);
}

function binomial(n, k)
{
    result = 1;

    for (i = 0; i < k; i++)
        result = result * (n - i) / (i + 1);

    return result;
}

function path_length()
{
    camera = level.cicada_camera;
    total = 0;

    for (i = 0; i < (camera.nodes.size - 1); i++)
        total += distance(camera.nodes[i].origin, camera.nodes[i + 1].origin);

    return total;
}

function node_origins()
{
    origins = [];

    foreach (node in level.cicada_camera.nodes)
        origins[origins.size] = node.origin;

    return origins;
}

function unwound_angles()
{
    camera = level.cicada_camera;
    angles = [];

    foreach (node in camera.nodes)
        angles[angles.size] = node.angles;

    for (i = 1; i < angles.size; i++)
    {
        delta = angles[i][1] - angles[i - 1][1];

        if (delta > 180)
            angles[i] -= (0, 360, 0);
        else if (delta < -180)
            angles[i] += (0, 360, 0);
    }

    return angles;
}
