#using scripts\engine\utility;

#using custom_scripts\util;

#namespace cicada_movement;

function init()
{
    precachemodel("tag_origin");
}

function limit(key)
{
    return (key == "record") ? 50 : 20;
}

function count(key)
{
    return self cicada_util::getpersint(key + "_count");
}

function point(key, index)
{
    return self cicada_util::getpers(key + "_point_" + index);
}

function summary(key)
{
    return "^:" + self count(key) + " ^7points";
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
    self cicada_util::setpers(key + "_point_" + total, self.origin);
    self cicada_util::setpers(key + "_count", total + 1);
}

function delete_point(key)
{
    total = self count(key);
    if (!total)
    {
        self cicada_util::message_bold("^1no points to delete");
        return;
    }

    self cicada_util::setpers(key + "_point_" + (total - 1), undefined);
    self cicada_util::setpers(key + "_count", total - 1);
    self cicada_util::message("point ^:#" + total + " ^7deleted");
}

function clear_points(key)
{
    for (i = 0; i < self count(key); i++)
        self cicada_util::setpers(key + "_point_" + i, undefined);

    self cicada_util::setpers(key + "_count", 0);
    self cicada_util::message("points ^1cleared");
}

// bolt & record playback ----------------------------------------------------

function play_bolt()
{
    self ride_points("bolt", self, self cicada_util::getpersfloat("bolt_speed"));
}

function play_bot_bolt()
{
    bot = self cicada_util::enemy_player();
    if (bot == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    self ride_points("bot_bolt", bot, self cicada_util::getpersfloat("bot_bolt_speed"));
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
    rider playerlinkto(rig);
    rider thread [[&stop_ride_on_death]]();

    for (i = 0; i < total; i++)
    {
        if (!isdefined(rider.cicada_rig))
            return;

        rig moveto(self point(key, i), leg, 0, 0);
        wait (leg);
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

// bot paths -----------------------------------------------------------------

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
    behaviours = cicada_util::list("objective,critical,hunt,guard");

    for (i = 0; i < total; i++)
    {
        bot botsetscriptgoal(self point("path", i), 0, behaviours[randomint(behaviours.size)]);
        bot utility::waittill_any_in_array_return(cicada_util::list("goal,bad_path,no_path,node_relinquished,script_goal_changed"));
        wait (randomintrange(1, 4));
    }

    bot setgoalpos(origin);
}
