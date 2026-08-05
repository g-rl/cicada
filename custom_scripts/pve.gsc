#using scripts\engine\utility;
#using scripts\mp\agents\agent_common;
#using scripts\mp\agents\agents;
#using scripts\mp\ai_mp_controller;
#using scripts\mp\mp_agent;
#using scripts\mp\final_killcam;
#using scripts\mp\killcam;
#using scripts\anim\notetracks_mp;
#using scripts\asm\asm;

#using custom_scripts\util;

#namespace cicada_pve;

function start(key)
{
    if (istrue(level.cicada_pve_active))
        return;

    level.cicada_pve_active = true;
    level.cicada_pve_zombies = [];
    level.cicada_pve_host = self;

    level.cicada_pve_max = 24;
    level.cicada_pve_health = 300;

    level thread [[&horde_manager]]();

    self cicada_util::message("^1zombies ^7are coming");
}

function stop(key)
{
    foreach (player in level.players)
    {
        if (player != self && istrue(player cicada_util::getpers("pve")))
            return;
    }

    level.cicada_pve_active = false;
    level notify("cicada_pve_stop");

    foreach (zombie in level.cicada_pve_zombies)
    {
        if (isdefined(zombie) && isalive(zombie))
            zombie suicide();
    }

    level.cicada_pve_zombies = [];

    foreach (unittype, orig in level.cicada_pve_ondamage_orig)
        level.agent_funcs[unittype]["on_damaged"] = orig;

    foreach (unittype, orig in level.cicada_pve_onkilled_orig)
        level.agent_funcs[unittype]["gametype_on_killed"] = orig;

    level.cicada_pve_ondamage_orig = undefined;
    level.cicada_pve_onkilled_orig = undefined;
    level.var_3749fd90367bc366 = level.cicada_pve_aiscore_orig;

    self cicada_util::message("^1zombies ^7cleared");
}

function private horde_manager()
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    while (!istrue(game["flags"]["prematch_done"]))
        wait 0.05;

    setup_agents();
    setup_threat_groups();

    aitype = pick_aitype();
    if (!isdefined(aitype))
    {
        level.cicada_pve_active = false;
        if (isdefined(level.cicada_pve_host))
            level.cicada_pve_host cicada_util::message("^1no actor types ^7loaded on this map");

        return;
    }

    while (true)
    {
        if (level.cicada_pve_zombies.size < level.cicada_pve_max)
        {
            origin = spawn_origin();
            if (isdefined(origin))
                spawn_zombie(aitype, origin);
        }

        wait 0.15;
    }
}

function private setup_agents()
{
    setdvar("scr_default_maxagents", max(getdvarint("scr_default_maxagents", 0), 60));

    ai_mp_controller::init();
    level.supportsai = 1;

    if (!isdefined(level.agentarray))
    {
        agents::setup_callbacks();
        agent_common::initagentlevelvariables();
        notetracks_mp::registernotetracks();
        level thread [[&asm::setup_level_ents]]();
    }

    while (level.agentarray.size < getmaxagents())
    {
        agent = addagent();
        if (!isdefined(agent))
            break;

        wait 0.05;
    }
}

function private setup_threat_groups()
{
    if (!threatbiasgroupexists("pve_zombie"))
        createthreatbiasgroup("pve_zombie");

    setignoremegroup("pve_zombie", "pve_zombie");

    if (isdefined(level.cicada_pve_ondamage_orig))
        return;

    level.cicada_pve_ondamage_orig = [];

    foreach (unittype in ["zombie", "soldier", "juggernaut"])
    {
        if (isdefined(level.agent_funcs[unittype]) && isdefined(level.agent_funcs[unittype]["on_damaged"]))
        {
            level.cicada_pve_ondamage_orig[unittype] = level.agent_funcs[unittype]["on_damaged"];
            level.agent_funcs[unittype]["on_damaged"] = &cicada_pve::zombie_on_damaged;
        }
    }

    level.cicada_pve_onkilled_orig = [];

    foreach (unittype in ["zombie", "soldier", "juggernaut"])
    {
        if (isdefined(level.agent_funcs[unittype]))
        {
            level.cicada_pve_onkilled_orig[unittype] = level.agent_funcs[unittype]["gametype_on_killed"];
            level.agent_funcs[unittype]["gametype_on_killed"] = &cicada_pve::zombie_on_killed;
        }
    }

    // aiKilledScoreEventsEnabled gates the kill score an agent death awards the killer. zeroing it
    // denies kill credit; the on_killed hook records the final killcam instead.
    level.cicada_pve_aiscore_orig = level.var_3749fd90367bc366;
    level.var_3749fd90367bc366 = 0;
}

// zombie_on_damaged runs before the stock damage handler (dispatched by unittype). a player wielding
// a sniper-class weapon one-taps a pve zombie; everything else delegates to the original handler.
function private zombie_on_damaged(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, modelindex, partname, objweapon)
{
    if (!isdefined(objweapon))
        objweapon = sweapon;

    if (istrue(self.cicada_pve_zombie) && isplayer(eattacker) && isdefined(objweapon) && isdefined(objweapon.basename) && weaponclass(objweapon.basename) == "sniper")
        idamage = self.health + 1;

    orig = level.cicada_pve_ondamage_orig[self.unittype];
    if (isdefined(orig))
        self [[ orig ]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, modelindex, partname, objweapon);
}

function private zombie_on_killed(einflictor, eattacker, idamage, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration)
{
    if (istrue(self.cicada_pve_zombie) && isplayer(eattacker))
        record_zombie_finalkillcam(eattacker, einflictor, objweapon, smeansofdeath, timeoffset);

    orig = level.cicada_pve_onkilled_orig[self.unittype];
    if (isdefined(orig))
        self [[ orig ]](einflictor, eattacker, idamage, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration);
}

// mirrors the setup in playerkilled_killcamsetup: agent deaths never reach it, so the final killcam
// is granted here instead. direct gun shots give no killcamentity, which the engine also expects.
function private record_zombie_finalkillcam(attacker, einflictor, objweapon, smeansofdeath, timeoffset)
{
    if (!level.recordfinalkillcam || istrue(level.disable_killcam))
        return;

    if (smeansofdeath == "MOD_SUICIDE" || attacker == self || !isdefined(objweapon))
        return;

    killcamentity = self killcam::getkillcamentity(attacker, einflictor, objweapon, smeansofdeath);
    killcamentityindex = undefined;
    killcamentitystarttime = undefined;

    if (isdefined(killcamentity))
    {
        killcamentityindex = killcamentity getentitynumber();
        killcamentitystarttime = isdefined(killcamentity.birthtime) ? killcamentity.birthtime : 0;
    }

    sticks = smeansofdeath == "MOD_IMPACT" || smeansofdeath == "MOD_HEAD_SHOT" && isdefined(einflictor) || smeansofdeath == "MOD_GRENADE" || isdefined(self.stuckbygrenade) && isdefined(einflictor) && self.stuckbygrenade == einflictor || objweapon.basename == "throwingknifec4_mp";

    final_killcam::recordfinalkillcam(5, self, attacker, attacker getentitynumber(), einflictor, killcamentityindex, killcamentitystarttime, sticks, objweapon, timeoffset, smeansofdeath);
}

function private pick_aitype()
{
    zombies = ["actor_jup_spawner_zombie_base_lightweight_mp", "actor_jup_spawner_zombie_base_wm", "actor_jup_spawner_zombie_base_armored_light", "actor_jup_spawner_zombie_hellhound"];

    loaded = [];
    foreach (aitype in zombies)
    {
        if (ai_loaded(aitype))
            loaded[loaded.size] = aitype;
    }

    if (loaded.size)
        return loaded[randomint(loaded.size)];

    fallback = ["actor_jup_enemy_mp_ar_gl", "actor_enemy_mp_jugg_aq", "actor_enemy_br_base", "actor_enemy_lw_base_br"];

    foreach (aitype in fallback)
    {
        if (ai_loaded(aitype))
            return aitype;
    }

    return undefined;
}

function private ai_loaded(aitype)
{
    if (!isdefined(level.agent_definition))
        return false;

    return isdefined(level.agent_definition[aitype]) && isdefined(level.agent_definition[aitype]["setup_func"]);
}

function private spawn_zombie(aitype, origin)
{
    zombie = mp_agent::spawnnewagentaitype(aitype, origin, (0, randomint(360), 0), "team_two_hundred");
    if (!isdefined(zombie))
        return;

    zombie.maxhealth = max(level.cicada_pve_health, 300);
    zombie.health = zombie.maxhealth;
    zombie.dontsyncmelee = 1;
    zombie.cicada_pve_zombie = 1;

    if (issubstr(aitype, "zombie"))
        zombie setperk("specialty_radarblip", 1);

    make_sprinter(zombie);

    zombie setthreatbiasgroup("pve_zombie");

    level.cicada_pve_zombies[level.cicada_pve_zombies.size] = zombie;
    zombie thread [[&watch_zombie]](zombie);
    zombie thread [[&watch_damage]](zombie);
}

// sprinting comes from the movetype plus the anim-threshold speed, the same two things the
// zombie_utils setmovespeed shared func writes when escort_horde marks a sprinter. some aitypes
// have no sprint threshold (hellhound, armored), so a floor is applied so every zombie commits.
function private make_sprinter(zombie)
{
    zombie._blackboard.movetype = "sprint";

    speed = getanimspeedthreshold(zombie.animsetname, "sprint");
    if (isdefined(speed))
        speed = max(speed, 420);
    else
        speed = 420;

    zombie aisetdesiredspeed(speed);
    zombie aisettargetspeed(speed);
}

// agents notify "pain" whenever a damage hit lands while alive, so the running hit total and
// current health can be printed off that signal alone, no per-shot callback needed.
function private watch_damage(zombie)
{
    level endon("game_ended");
    zombie endon("death");
    zombie endon("disconnect");

    prevhealth = zombie.health;

    while (true)
    {
        zombie waittill("pain");
        dmg = prevhealth - zombie.health;
        iprintln("^1zombie ^7-^2" + dmg + "^7 hp: ^3" + zombie.health + "^7/" + zombie.maxhealth);
        prevhealth = zombie.health;
    }
}

function private watch_zombie(zombie)
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    zombie waittill("death");

    for (i = 0; i < level.cicada_pve_zombies.size; i++)
    {
        if (level.cicada_pve_zombies[i] == zombie)
        {
            level.cicada_pve_zombies = utility::array_remove_index(level.cicada_pve_zombies, i);
            break;
        }
    }
}

function private spawn_origin()
{
    player = random_alive_player();
    if (!isdefined(player))
        return undefined;

    for (i = 0; i < 5; i++)
    {
        dist = randomintrange(250, 900);
        angle = randomint(360);
        point = getclosestpointonnavmesh(player.origin + (cos(angle) * dist, sin(angle) * dist, 0));

        if (isdefined(point))
            return point;
    }

    return undefined;
}

function private random_alive_player()
{
    alive = [];

    foreach (player in level.players)
    {
        if (isalive(player) && player.sessionstate == "playing")
            alive[alive.size] = player;
    }

    if (alive.size == 0)
        return undefined;

    return alive[randomint(alive.size)];
}
