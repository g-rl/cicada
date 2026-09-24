#using scripts\mp\final_killcam;
#using scripts\mp\gamelogic;
#using scripts\mp\killcam;

#using custom_scripts\cinematics;
#using custom_scripts\menu;
#using custom_scripts\pve;
#using custom_scripts\util;

#namespace cicada_killcam;

function clean()
{
    self endon("disconnect");

    for (;;)
    {
        if (self cicada_cinematics::scene_running())
        {
            wait 0.05;
            continue;
        }

        if (istrue(self cicada_util::getpers("hide_weapon")))
        {
            self setclientomnvar("ui_killcam_killedby_item_type", -1);
            self setclientomnvar("ui_killcam_killedby_item_id", -1);
            self setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
            self setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);
        }

        if (istrue(self cicada_util::getpers("hide_victim")))
            self setclientomnvar("ui_killcam_victim_id", -1);

        if (istrue(self cicada_util::getpers("hide_perks")))
            for (i = 0; i < 7; i++)
                self setclientomnvar("ui_killcam_killedby_perk" + i, "none");

        if (istrue(self cicada_util::getpers("hide_attachments")))
            for (i = 0; i < 8; i++)
                self setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);

        if (istrue(self cicada_util::getpers("hide_equipment")))
        {
            self setclientomnvar("ui_killcam_killedby_equipment_primary", "none");
            self setclientomnvar("ui_killcam_killedby_equipment_secondary", "none");
        }

        if (istrue(self cicada_util::getpers("hide_field_upgrade")) && !isalive(self))
        {
            self setclientomnvar("ui_killcam_killedby_super1", "none");
            self setclientomnvar("ui_killcam_killedby_super2", "none");
            self setclientomnvar("ui_super_ref", "none");
            self setclientomnvar("ui_super_progress", 0);
        }

        wait 0.05;
    }
}

function skip_final()
{
    self endon("disconnect");

    self waittill("showing_final_killcam");
    self thread [[&wait_for_skip]]();
}

function wait_for_skip()
{
    self endon("disconnect");
    self endon("stop_waiting_killcam");

    self waittill("button_pressed_+gostand");

    foreach (player in level.players)
        skip(player);
}

function skip(player)
{
    if (player cicada_cinematics::scene_running())
        return;

    player setclientomnvar("ui_killcam_end_milliseconds", 0);
    player setclientomnvar("ui_killcam_killedby_id", -1);
    player setclientomnvar("ui_killcam_victim_id", -1);
    player setclientomnvar("ui_killcam_killedby_item_type", -1);
    player setclientomnvar("ui_killcam_killedby_item_id", -1);
    player setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
    player setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);

    for (i = 0; i < 8; i++)
        player setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);

    for (i = 0; i < 7; i++)
        player setclientomnvar("ui_killcam_killedby_perk" + i, "none");

    player.killcam = undefined;
    player.forcespectatorclient = -1;
    player.killcamentity = -1;
    player.archivetime = 0;
    player.archiveusepotg = 0;
    player.psoffsettime = 0;
    player.spectatekillcam = 0;

    player allowspectateteam("freelook", 0);
    player allowspectateteam("none", 1);
    player setclientomnvar("ui_session_state", "dead");
    player.sessionstate = "dead";

    player setclientomnvar("cam_scene_name", "unknown");
    player setclientomnvar("cam_scene_lead", -1);
    player setclientomnvar("cam_scene_support", -1);

    player notify("abort_killcam");
    player notify("killcam_ended");
    player notify("stop_waiting_killcam");
    player setclientomnvar("post_game_state", 1);
}

function set_time(value)
{
    setdvar("scr_killcam_time", float(value));
}

function is_killcam_target(zombie)
{
    return isdefined(zombie) && istrue(zombie.cicada_pve_killcam_target);
}

function toggle_killcam_target(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    wanted = !is_killcam_target(zombie);

    foreach (other in cicada_pve::zombies())
        other.cicada_pve_killcam_target = 0;

    zombie.cicada_pve_killcam_target = wanted;

    if (wanted)
    {
        zombie setperk("specialty_radarblip", 1);
        self cicada_util::message("final killcam target ^:" + cicada_pve::zombie_name(zombie));
    }
    else
        self cicada_util::message("final killcam target ^1cleared");

    self cicada_menu::update_menu();
}

function killcam_target_killed(zombie, attacker)
{
    level.cicada_pve_active = false;
    level notify("cicada_pve_stop");

    level.potgenabled = 0;
    level.finalkillcamtype = 0;
    level.finalkillcamenabled = 1;
    level.skipfinalkillcam = 0;

    if (level.teambased && isdefined(attacker.team))
        level.finalkillcam_winner = attacker.team;
    else if (isdefined(attacker.guid))
        level.finalkillcam_winner = attacker.guid;
    else
        level.finalkillcam_winner = "none";

    level thread [[&end_on_target]](attacker);
}

function private end_on_target(attacker)
{
    waitframe();

    if (istrue(level.gameended))
        return;

    if (istrue(level.var_1fa9e6ecce90d2c2))
        level.roundenddelay = max(level.roundenddelay, 16);

    level thread [[&target_killcam]]();
    gamelogic::endgame(cicada_pve::winner_for(attacker), game["end_reason"]["ended_game"]);
}

function private killcam_blocker()
{
    if (isdefined(level.nukeinfo) && istrue(level.nukeinfo.detonated))
        return "a nuke ended the round";

    if (istrue(level.brdisablefinalkillcam))
        return "brdisablefinalkillcam is set";

    if (istrue(level.var_ee656bfaf5da1c13))
        return "the mode blocks the final killcam";

    if (istrue(level.skipfinalkillcam))
        return "skipfinalkillcam is set";

    if (!istrue(level.finalkillcamenabled))
        return "finalkillcamenabled is off";

    if (!isdefined(level.finalkillcams) || !isdefined(level.finalkillcams["none"]))
        return "nothing was recorded for that kill";

    killcamstruct = level.finalkillcams["none"];

    if (!isdefined(killcamstruct.attacker))
        return "the struct has no attacker";

    if (!isdefined(killcamstruct.victim))
        return "the zombie entity is gone";

    if (!isdefined(killcamstruct.victim.deathtime))
        return "the zombie has no death time";

    if (!isdefined(killcamstruct.attackernum) || killcamstruct.attackernum < 0)
        return "the attacker has no archive slot";

    if (!isdefined(killcamstruct.timerecorded) || (game_utility::getsecondspassed() - killcamstruct.timerecorded) > 20)
        return "the kill is over twenty seconds old";

    return undefined;
}

function private wait_for_preload()
{
    limit = gettime() + 4000;

    while (gettime() < limit)
    {
        if (isdefined(level.levelflags) && istrue(level.levelflags["final_killcam_preloaded"]))
            return true;

        waitframe();
    }

    return false;
}

function private watch_playback()
{
    limit = gettime() + int((level.roundenddelay + 20) * 1000);

    while (gettime() < limit)
    {
        if (istrue(level.showingfinalkillcam))
            return;

        foreach (player in level.players)
            if (istrue(player.killcam))
                return;

        waitframe();
    }

    killcam_missed(level.cicada_pve_host, "nothing was refused but no camera came up");
}

function private target_killcam()
{
    level waittill("game_ended");

    if (!isdefined(level.finalkillcams))
        level.finalkillcams = [];

    if (!isdefined(level.finalkillcam_winner) || !isdefined(level.finalkillcams[level.finalkillcam_winner]))
        level.finalkillcam_winner = "none";

    level.finalkillcamenabled = 1;
    level.potgenabled = 0;
    level.skipfinalkillcam = 0;
    level.showingfinalkillcam = 0;

    blocker = killcam_blocker();

    if (isdefined(blocker))
    {
        killcam_missed(level.cicada_pve_host, blocker);
        return;
    }

    level thread [[&watch_playback]]();

    if (!istrue(level.var_1fa9e6ecce90d2c2))
        return;

    if (!wait_for_preload())
        killcam_missed(level.cicada_pve_host, "the preload never finished, playing anyway");

    final_killcam::dofinalkillcam();
}

function private prepare_victim(attacker)
{
    self.deathtime = gettime();

    if (!isdefined(self.attackers))
        self.attackers = [];

    if (!isdefined(self.attackerdata))
        self.attackerdata = [];

    if (isdefined(attacker) && isplayer(attacker))
        self killcam::prekillcamnotify(attacker);
}

function private killcam_missed(attacker, reason)
{
    if (isplayer(attacker))
        attacker cicada_util::message(cicada_util::warn("killcam skipped - " + reason));
}

function record_zombie_finalkillcam(attacker, einflictor, objweapon, smeansofdeath, timeoffset, force)
{
    if (!istrue(force) && (!level.recordfinalkillcam || istrue(level.disable_killcam)))
        return;

    if (smeansofdeath == "MOD_SUICIDE" || attacker == self)
    {
        killcam_missed(attacker, "the zombie killed itself");
        return;
    }

    if (!isdefined(objweapon) || isnullweapon(objweapon))
        objweapon = attacker getcurrentweapon();

    if (!isdefined(objweapon) || isnullweapon(objweapon))
    {
        killcam_missed(attacker, "no weapon on the kill");
        return;
    }

    if (!isdefined(attacker.classname) || attacker.classname == "trigger_hurt" || attacker.classname == "worldspawn")
    {
        killcam_missed(attacker, "the attacker is not a player entity");
        return;
    }

    if (level.teambased && isdefined(attacker.team) && isdefined(self.team) && attacker.team == self.team)
    {
        killcam_missed(attacker, "the zombie is on your team");
        return;
    }

    self prepare_victim(attacker);

    killcamentity = self killcam::getkillcamentity(attacker, einflictor, objweapon, smeansofdeath);
    killcamentityindex = undefined;
    killcamentitystarttime = undefined;

    if (isdefined(killcamentity))
    {
        killcamentityindex = killcamentity getentitynumber();
        killcamentitystarttime = isdefined(killcamentity.birthtime) ? killcamentity.birthtime : 0;
    }

    sticks = smeansofdeath == "MOD_IMPACT" || smeansofdeath == "MOD_HEAD_SHOT" && isdefined(einflictor) || smeansofdeath == "MOD_GRENADE" || isdefined(self.stuckbygrenade) && isdefined(einflictor) && self.stuckbygrenade == einflictor || objweapon.basename == "throwingknifec4_mp";

    self store_finalkillcam(attacker, attacker getentitynumber(), einflictor, killcamentityindex, killcamentitystarttime, sticks, objweapon, timeoffset, smeansofdeath);
}

function private store_finalkillcam(attacker, attackernum, einflictor, killcamentityindex, killcamentitystarttime, sticks, objweapon, timeoffset, smeansofdeath)
{
    if (!isdefined(level.finalkillcams))
        level.finalkillcams = [];

    inflictoragentinfo = spawnstruct();

    if (isdefined(einflictor) && isagent(einflictor))
    {
        inflictoragentinfo.agent_type = einflictor.agent_type;
        inflictoragentinfo.lastspawntime = isdefined(einflictor.lastspawntime) ? einflictor.lastspawntime : einflictor.spawntime;
    }

    perkarray = [];

    if (isdefined(attacker.pers["loadoutPerks"]))
        foreach (perk in attacker.pers["loadoutPerks"])
            perkarray[perkarray.size] = perk;

    victim = self killcam_victim(isdefined(self.deathtime) ? self.deathtime : gettime());

    killcamstruct = killcam::makekillcamdata(einflictor, inflictoragentinfo, attackernum, killcamentityindex, killcamentitystarttime, victim getentitynumber(), sticks, objweapon, timeoffset, 12, attacker, victim, smeansofdeath, perkarray, 0, 1);

    killcamstruct.timerecorded = game_utility::getsecondspassed();
    killcamstruct.attackers = victim.attackers;
    killcamstruct.attackerdata = victim.attackerdata;

    if (level.teambased && isdefined(attacker.team))
        level.finalkillcams[attacker.team] = killcamstruct;
    else if (!level.teambased)
        level.finalkillcams[attacker.guid] = killcamstruct;

    level.finalkillcams["none"] = killcamstruct;
}

function private killcam_victim(deathtime)
{
    if (isdefined(level.cicada_pve_victim))
        level.cicada_pve_victim delete();

    spot = isdefined(self.body) ? self.body.origin : self.origin;

    victim = spawn("script_origin", spot);

    victim.deathtime = deathtime;
    victim.attackers = self.attackers;
    victim.attackerdata = self.attackerdata;

    if (isdefined(self.body))
        victim thread [[&follow_body]](self.body);

    level.cicada_pve_victim = victim;
    return victim;
}

function private follow_body(body)
{
    self endon("death");
    level endon("game_ended");

    while (isdefined(body) && isdefined(self))
    {
        self.origin = body.origin;
        waitframe();
    }
}
