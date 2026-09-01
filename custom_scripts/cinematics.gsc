#using custom_scripts\loadout;
#using custom_scripts\util;

#namespace cicada_cinematics;

function max_nodes()
{
    // bezier weights lose precision past roughly a dozen control points so the node list is capped
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

function clone_self()
{
    self cloneplayer(1);
}

// preview -------------------------------------------------------------------
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

// bezier --------------------------------------------------------------------
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
