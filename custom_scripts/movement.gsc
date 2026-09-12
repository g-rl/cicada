#using scripts\engine\utility;

#using custom_scripts\mods;
#using custom_scripts\pve;
#using custom_scripts\util;

#namespace cicada_movement;

function init()
{
    precachemodel("tag_origin");
    precachemodel("axis_guide_createfx");
}

function path_note(text)
{
    if (!istrue(self cicada_util::getpers("path_debug")))
        return;

    self cicada_util::message("^:path ^7" + text);
}

function path_seconds(started)
{
    return (gettime() - started) / 1000;
}

function path_key(key)
{
    return key == "path" || key == "zombie_path";
}

function navmesh_point(origin)
{
    spot = getclosestpointonnavmesh(origin);
    return isdefined(spot) ? spot : origin;
}

function markers_on(key)
{
    return isdefined(level.cicada_path_markers) && isdefined(level.cicada_path_markers[key]);
}

function clear_markers(key)
{
    if (!markers_on(key))
        return;

    foreach (marker in level.cicada_path_markers[key])
        if (isdefined(marker))
            marker delete();

    level.cicada_path_markers[key] = undefined;
}

function build_markers(key)
{
    markers = [];

    for (i = 0; i < self count(key); i++)
    {
        marker = spawn("script_model", self point(key, i) + (0, 0, 24));
        marker setmodel("axis_guide_createfx");
        marker hudoutlineenable(i == 0 ? "outlinefill_nodepth_yellow" : "outlinefill_nodepth_green");
        markers[markers.size] = marker;
    }

    level.cicada_path_markers[key] = markers;
    return markers.size;
}

function refresh_markers(key)
{
    if (!markers_on(key))
        return;

    clear_markers(key);
    self build_markers(key);
}

function toggle_markers(key)
{
    if (!isdefined(level.cicada_path_markers))
        level.cicada_path_markers = [];

    if (markers_on(key))
    {
        clear_markers(key);
        self cicada_util::message("waypoints ^1hidden");
        return;
    }

    if (!self count(key))
    {
        self cicada_util::message_bold("^6save a point first");
        return;
    }

    self cicada_util::message("waypoints shown - ^:" + self build_markers(key));
}

function limit(key)
{
    return (key == "record") ? 50 : 20;
}

function count(key)
{
    return self cicada_util::getmappersint(key + "_count");
}

function point(key, index)
{
    return self cicada_util::getmappers(key + "_point_" + index);
}

function summary(key)
{
    return "^:" + self count(key) + " ^7points";
}

function speed_key(key, index)
{
    return key + "_speed_" + index;
}

function leg_time(key, index, fallback)
{
    speed = self cicada_util::getmappers(speed_key(key, index));

    if (isdefined(speed) && speed > 0)
        return float(speed);

    return fallback;
}

function set_point_speed(value, key, index)
{
    self cicada_util::setmappers(speed_key(key, index), value);
}

function save_point(key)
{
    if (self count(key) >= limit(key))
    {
        self cicada_util::message_bold("^1point limit reached");
        return;
    }

    self store_point(key);
    self cicada_util::message("point ^:#" + self count(key) + " ^7saved");
}

function store_point(key)
{
    total = self count(key);
    origin = path_key(key) ? navmesh_point(self.origin) : self.origin;

    self cicada_util::setmappers(key + "_point_" + total, origin);
    self cicada_util::setmappers(key + "_count", total + 1);
    self refresh_markers(key);
}

function delete_point(key)
{
    total = self count(key);
    if (!total)
    {
        self cicada_util::message_bold("^1no points to delete");
        return;
    }

    self cicada_util::setmappers(key + "_point_" + (total - 1), undefined);
    self cicada_util::setmappers(speed_key(key, total - 1), undefined);
    self cicada_util::setmappers(key + "_count", total - 1);
    self refresh_markers(key);
    self cicada_util::message("point ^:#" + total + " ^7deleted");
}

function clear_points(key)
{
    for (i = 0; i < self count(key); i++)
    {
        self cicada_util::setmappers(key + "_point_" + i, undefined);
        self cicada_util::setmappers(speed_key(key, i), undefined);
    }

    self cicada_util::setmappers(key + "_count", 0);
    clear_markers(key);
    self cicada_util::message("points ^1cleared");
}

function play_bolt()
{
    self ride_points("bolt", self, self cicada_util::getpersfloat("bolt_speed"));
}

function bolt_key(kind)
{
    return kind + "_bolt";
}

function play_ai_bolt(kind)
{
    if (!isdefined(kind))
        kind = "bot";

    rider = self cicada_mods::ai_target(kind);

    if (!isdefined(rider))
    {
        if (kind == "bot")
            rider = self cicada_util::enemy_player();
        else
        {
            pool = self cicada_mods::ai_pool(kind);

            if (pool.size)
                rider = pool[0];
        }
    }

    if (!isdefined(rider) || rider == self)
    {
        self cicada_util::message_bold("^5spawn " + (kind == "bot" ? "an enemy" : "an " + kind) + " first");
        return;
    }

    self ride_points(bolt_key(kind), rider, self cicada_util::getpersfloat(kind + "_bolt_speed"));
}

function play_bot_bolt()
{
    self play_ai_bolt("bot");
}

function play_agent_bolt()
{
    self play_ai_bolt("agent");
}

function play_zombie_bolt()
{
    self play_ai_bolt("zombie");
}

function play_record()
{
    self ride_points("record", self, 0.1);
}

function ride_points(key, rider, leg)
{
    self endon("disconnect");
    level endon("game_ended");

    total = self count(key);
    if (!total)
    {
        self cicada_util::message_bold("^6save a point first");
        return;
    }

    if (isdefined(rider.cicada_rig))
        return;

    rig = spawn("script_model", rider.origin);
    rig setmodel("tag_origin");
    rider.cicada_rig = rig;

    if (isplayer(rider))
        rider playerlinkto(rig);
    else
    {
        cicada_pve::hold_ai(rider);
        rider.cicada_rig_ai = true;
        rider linkto(rig);
    }

    rider thread [[&stop_ride_on_death]]();

    for (i = 0; i < total; i++)
    {
        if (!isdefined(rider.cicada_rig))
            return;

        step = self leg_time(key, i, leg);

        rig moveto(self point(key, i), step, 0, 0);
        wait (step);
    }

    rider stop_ride();
}

function stop_ride_on_death()
{
    self endon("disconnect");
    self endon("cicada_ride_ended");

    self waittill("death");
    self stop_ride();
}

function stop_ride()
{
    if (!isdefined(self.cicada_rig))
        return;

    self unlink();
    self.cicada_rig delete();
    self.cicada_rig = undefined;

    if (istrue(self.cicada_rig_ai))
    {
        self.cicada_rig_ai = undefined;
        cicada_pve::release_ai(self);
    }

    self notify("cicada_ride_ended");
}

function record_movement()
{
    self endon("disconnect");
    level endon("game_ended");
    self endon("death");

    self clear_points("record");

    for (i = 3; i > 0; i--)
    {
        self cicada_util::message_bold("recording in ^:" + i);
        wait 1;
    }

    self cicada_util::message_bold("recording - [{+melee_zoom}] to stop");

    while (!self meleebuttonpressed() && self count("record") < limit("record"))
    {
        self store_point("record");
        wait 0.1;
    }

    self cicada_util::message_bold("recorded ^:" + self count("record") + " ^7points");
}

function start_bot_path()
{
    self endon("disconnect");
    level endon("game_ended");

    total = self count("path");
    if (!total)
    {
        self cicada_util::message_bold("^6save a point first");
        return;
    }

    bot = self cicada_util::enemy_player();
    if (bot == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    bot endon("death");

    origin = bot.origin;
    started = gettime();

    self path_note("started on ^:" + total + " ^7points");

    bot.cicada_launched = true;
    bot freezecontrols(0);
    bot botsetpathingstyle("scripted");

    if (istrue(self cicada_util::getpers("path_reset")))
    {
        bot setorigin(navmesh_point(self point("path", 0)));
        waitframe();

        self path_note("reset the bot to point one");
    }

    bot thread [[&release_on_death]]();

    for (i = 0; i < total; i++)
    {
        leg = gettime();

        bot botclearscriptgoal();
        waitframe();

        bot botsetscriptgoal(navmesh_point(self point("path", i)), 16, "critical");
        bot thread [[&path_timeout]]();
        reason = bot utility::waittill_any_in_array_return(cicada_util::list("goal,bad_path,no_path,node_relinquished,script_goal_changed,cicada_path_timeout"));
        bot notify("cicada_path_reached");

        self path_note("point ^:" + (i + 1) + " ^7" + reason + " in ^:" + path_seconds(leg) + "s");

        pause = self cicada_util::getpersfloat("path_pause");

        if (pause > 0)
        {
            bot botclearscriptgoal();
            bot botsetscriptgoal(bot.origin, 16, "critical");

            wait pause;
        }
        else
            waitframe();
    }

    bot notify("cicada_path_done");

    bot botclearscriptgoal();
    bot botsetpathingstyle(undefined);
    bot setgoalpos(origin);
    bot.cicada_launched = false;

    self path_note("finished in ^:" + path_seconds(started) + "s");
}

function release_on_death()
{
    self endon("disconnect");
    self endon("cicada_path_done");

    self waittill("death");
    self.cicada_launched = false;
}

function path_timeout()
{
    self endon("disconnect");
    self endon("death");
    self endon("cicada_path_reached");

    wait 20;
    self notify("cicada_path_timeout");
}
