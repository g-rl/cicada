#using scripts\common\values;
#using scripts\engine\utility;
#using scripts\cp_mp\agents\agent_utils;
#using scripts\mp\agents\agent_common;
#using scripts\mp\agents\agents;
#using scripts\mp\ai_mp_controller;
#using scripts\mp\mp_agent;
#using scripts\mp\final_killcam;
#using scripts\mp\gamelogic;
#using scripts\mp\damage;
#using scripts\mp\killcam;
#using scripts\mp\utility\game;
#using scripts\anim\notetracks_mp;
#using scripts\asm\asm;

#using custom_scripts\catalog;
#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\util;

#namespace cicada_pve;

function start(key)
{
    if (istrue(level.cicada_pve_active))
        return;

    level.cicada_pve_active = true;
    level.cicada_pve_host = self;

    if (!isdefined(level.cicada_pve_zombies))
        level.cicada_pve_zombies = [];

    self apply_settings();

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

    self clear_zombies();

    if (isdefined(level.cicada_pve_ondamage_orig))
    {
        foreach (unittype, orig in level.cicada_pve_ondamage_orig)
            level.agent_funcs[unittype]["on_damaged"] = orig;

        level.cicada_pve_ondamage_orig = undefined;
    }

    if (isdefined(level.cicada_pve_onkilled_orig))
    {
        foreach (unittype, orig in level.cicada_pve_onkilled_orig)
            level.agent_funcs[unittype]["gametype_on_killed"] = orig;

        level.cicada_pve_onkilled_orig = undefined;
    }

    if (isdefined(level.cicada_pve_victim))
    {
        level.cicada_pve_victim delete();
        level.cicada_pve_victim = undefined;
    }

    level.cicada_pve_ready = undefined;
    level.var_3749fd90367bc366 = level.cicada_pve_aiscore_orig;

    self cicada_util::message("^1zombies ^7cleared");
}

function private horde_manager()
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    while (!istrue(game["flags"]["prematch_done"]))
        wait 0.05;

    slots = setup_agents();
    setup_threat_groups();
    level.cicada_pve_ready = true;

    if (slots > 0 && level.cicada_pve_max > slots)
    {
        level.cicada_pve_max = slots;

        if (isdefined(level.cicada_pve_host))
            level.cicada_pve_host cicada_util::message("horde capped at ^:" + slots + " ^7by this mode");
    }

    if (!isdefined(chosen_aitype()))
    {
        level.cicada_pve_active = false;
        if (isdefined(level.cicada_pve_host))
            level.cicada_pve_host cicada_util::message("^1no actor types ^7loaded on this map");

        return;
    }

    failures = 0;

    while (true)
    {
        if (count() < level.cicada_pve_max)
        {
            origin = spawn_origin();
            aitype = chosen_aitype();

            if (isdefined(origin) && isdefined(aitype))
            {
                if (isdefined(spawn_zombie(aitype, origin)))
                    failures = 0;
                else
                    failures++;
            }
            else
                failures++;

            if (failures == 20)
            {
                if (isdefined(level.cicada_pve_host))
                    level.cicada_pve_host cicada_util::message(cicada_util::warn("nothing is spawning - no free agents or no navmesh here"));
            }
        }

        wait (max(level.cicada_pve_delay, 0.05));
    }
}

function apply_settings()
{
    if (!isdefined(level.cicada_pve_host))
        level.cicada_pve_host = self;

    level.cicada_pve_max = self cicada_util::getpersint("pve_max");
    level.cicada_pve_health = self cicada_util::getpersint("pve_health");
    level.cicada_pve_delay = self cicada_util::getpersfloat("pve_delay");
    level.cicada_pve_range = self cicada_util::getpersint("pve_range");
    level.cicada_pve_speed = self cicada_util::getpers("pve_speed");
    level.cicada_pve_type = self cicada_util::getpers("pve_type");
    level.cicada_pve_spawn_type = self cicada_util::getpers("pve_spawn_type");
    level.cicada_pve_arm_armored = istrue(self cicada_util::getpers("pve_arm_armored"));
    level.cicada_pve_blip = istrue(self cicada_util::getpers("pve_blip"));
    level.cicada_pve_snipers = istrue(self cicada_util::getpers("pve_snipers"));
    level.cicada_pve_weapon_chance = self cicada_util::getpersint("pve_weapon_chance");
    level.cicada_pve_streak_chance = self cicada_util::getpersint("pve_streak_chance");
    level.cicada_pve_effect_chance = self cicada_util::getpersint("pve_effect_chance");
    level.cicada_pve_boss_chance = self cicada_util::getpersint("pve_boss_chance");
    level.cicada_pve_boss_health = self cicada_util::getpersint("pve_boss_health");
    level.cicada_pve_boss_death = self cicada_util::getpers("pve_boss_death");
    level.cicada_pve_killcam = istrue(self cicada_util::getpers("pve_killcam"));
    level.cicada_pve_score = istrue(self cicada_util::getpers("pve_score"));
    level.cicada_pve_respawn = istrue(self cicada_util::getpers("pve_respawn"));
    level.cicada_pve_respawn_delay = self cicada_util::getpersfloat("pve_respawn_delay");
    level.cicada_pve_combat = istrue(self cicada_util::getpers("pve_combat"));

    if (isdefined(level.cicada_pve_aiscore_orig))
        level.var_3749fd90367bc366 = level.cicada_pve_score ? 1 : 0;
}

function private apply_live()
{
    foreach (zombie in zombies())
    {
        if (zombie.maxhealth != level.cicada_pve_health)
        {
            zombie.maxhealth = level.cicada_pve_health;
            zombie.health = zombie.maxhealth;
        }

        if (!is_frozen(zombie))
            apply_speed(zombie, level.cicada_pve_speed);
    }
}

function set_value(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_settings();
    apply_live();
}

function flip_value(key)
{
    self cicada_util::flippers(key);
    self apply_settings();
    apply_live();
    self cicada_menu::update_menu();
}

function private clear_weapon_slot(zombie)
{
    if (!isdefined(zombie.weapon) || isnullweapon(zombie.weapon))
        return undefined;

    old = zombie.weapon;
    name = getcompleteweaponname(old);

    zombie takeweapon(old);

    if (isdefined(zombie.a) && isdefined(zombie.a.weaponpos))
    {
        foreach (slot in weapon_slots())
            if (isdefined(zombie.a.weaponpos[slot]) && zombie.a.weaponpos[slot] == old)
                zombie.a.weaponpos[slot] = undefined;
    }

    if (isdefined(zombie.weaponinfo) && isdefined(zombie.weaponinfo[name]))
        zombie.weaponinfo[name] = undefined;
}

function private register_weapon_info(zombie, weapon)
{
    name = getcompleteweaponname(weapon);

    if (!isdefined(zombie.weaponinfo))
        zombie.weaponinfo = [];

    zombie.weaponinfo[name] = spawnstruct();
    zombie.weaponinfo[name].position = "none";
    zombie.weaponinfo[name].hasclip = 1;
    zombie.weaponinfo[name].useclip = 0;
}

function private rebuild_weapon_array(zombie)
{
    if (!isdefined(zombie.secondaryweapon))
        zombie.secondaryweapon = nullweapon();

    if (!isdefined(zombie.sidearm))
        zombie.sidearm = nullweapon();

    zombie.weapons = [];

    if (!isnullweapon(zombie.primaryweapon))
        zombie.weapons[zombie.weapons.size] = zombie.primaryweapon;

    if (!isnullweapon(zombie.secondaryweapon))
        zombie.weapons[zombie.weapons.size] = zombie.secondaryweapon;

    if (!isnullweapon(zombie.sidearm))
        zombie.weapons[zombie.weapons.size] = zombie.sidearm;
}

function private apply_weapon_archetype(zombie, weapclass)
{
    if (!isdefined(zombie._blackboard) || !isdefined(zombie.asm) || !isdefined(zombie.animsetname))
        return;

    suffix = undefined;

    if (weapclass == "pistol")
        suffix = "_pistol";
    else if (weapclass == "mg")
        suffix = "_lmg";

    if (!isdefined(suffix))
    {
        zombie clearoverridearchetype("weapon");
        return;
    }

    if (archetypeassetloaded(zombie.animsetname + suffix))
    {
        zombie setoverridearchetype("weapon", zombie.animsetname + suffix);
        return;
    }

    base = zombie getbasearchetype();

    if (isdefined(base) && archetypeassetloaded(base + suffix))
    {
        zombie setoverridearchetype("weapon", base + suffix);
        return;
    }

    zombie clearoverridearchetype("weapon");
}

function private weapon_slots()
{
    return cicada_util::list("right,left,chest,back,thigh,inhand");
}

function private weapon_slot_tags()
{
    return cicada_util::list("tag_weapon_right,tag_weapon_left,tag_stowed_chest,tag_stowed_back,tag_stowed_thigh,tag_inhand");
}

function private refresh_weapon_models(zombie)
{
    if (!isdefined(zombie.a) || !isdefined(zombie.a.weaponpos))
        return;

    slots = weapon_slots();
    tags = weapon_slot_tags();

    held = [];
    used = [];

    for (i = 0; i < slots.size; i++)
    {
        weapon = zombie.a.weaponpos[slots[i]];

        if (!isdefined(weapon) || isnullweapon(weapon))
            continue;

        if (!zombie tagexists(tags[i]))
            continue;

        held[held.size] = weapon;
        used[used.size] = tags[i];
    }

    zombie updateentitywithweapons(held[0], used[0], held[1], used[1], held[2], used[2], held[3], used[3]);
}

function private hold_weapon(zombie, weapon)
{
    if (!isdefined(zombie.a))
        zombie.a = spawnstruct();

    if (!isdefined(zombie.a.weaponpos))
        zombie.a.weaponpos = [];

    if (!isdefined(zombie.a.weaponposdropping))
        zombie.a.weaponposdropping = [];

    foreach (slot in weapon_slots())
        if (isdefined(zombie.a.weaponpos[slot]) && zombie.a.weaponpos[slot] == weapon)
            zombie.a.weaponpos[slot] = undefined;

    zombie.a.weaponpos["right"] = weapon;
    zombie.weaponinfo[getcompleteweaponname(weapon)].position = "right";

    refresh_weapon_models(zombie);
}

function private replace_behaviour_tree(agent, tree)
{
    agent btterminatetreeinstance();

    if (!isdefined(tree))
        return;

    agent.behaviortreeasset = tree;
    agent btregistertreeinstance(tree);
}

function give_weapon(zombie, weapon)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return false;

    if (!isdefined(weapon) || isnullweapon(weapon) || weapon.basename == "none")
        return false;

    clear_weapon_slot(zombie);

    zombie.weapon = weapon;
    register_weapon_info(zombie, weapon);
    zombie giveweapon(weapon);
    zombie setspawnweapon(weapon);
    zombie.bulletsinclip = weaponclipsize(weapon);
    zombie.primaryweapon = weapon;
    zombie.grenadeweapon = isdefined(zombie.grenadeweapon) ? zombie.grenadeweapon : nullweapon();
    zombie.grenadeammo = isdefined(zombie.grenadeammo) ? zombie.grenadeammo : 0;

    hold_weapon(zombie, weapon);
    rebuild_weapon_array(zombie);

    zombie switchtoweaponimmediate(weapon);
    apply_weapon_archetype(zombie, weaponclass(weapon));

    return true;
}

function aitype_shoots(aitype)
{
    return isdefined(aitype) && !issubstr(aitype, "zombie") && !issubstr(aitype, "hellhound");
}

function can_shoot(zombie)
{
    return isdefined(zombie) && aitype_shoots(zombie.cicada_pve_aitype);
}

function private warn_melee(zombie)
{
    if (!can_shoot(zombie))
        self cicada_util::message(cicada_util::warn("this actor only melees - use a soldier type to see it fire"));
}

function give_my_weapon(zombie)
{
    if (self give_weapon(zombie, self getcurrentweapon()))
        self warn_melee(zombie);
}

function take_weapon(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie takeallweapons();
}

function private random_weapon()
{
    groups = level.cicada_groups["primaries"];

    if (!isdefined(groups) || !groups.size)
        return undefined;

    list = cicada_catalog::get(groups[randomint(groups.size)]);

    if (!list.size)
        return undefined;

    return cicada_loadout::build(list[randomint(list.size)].id);
}

function private streak_weapon()
{
    loaded = [];

    foreach (id in cicada_util::list("iw9_minigunksjugg_mp,iw9_lm_dblmg2_cp,iw9_tur_minigun_mp,iw9_la_juggrpg_mp"))
    {
        weapon = cicada_loadout::build(id);

        if (isdefined(weapon) && !isnullweapon(weapon) && weapon.basename != "none")
            loaded[loaded.size] = weapon;
    }

    if (!loaded.size)
        return undefined;

    return loaded[randomint(loaded.size)];
}

function give_random_weapon(zombie)
{
    if (!self give_weapon(zombie, random_weapon()))
    {
        self cicada_util::message(cicada_util::warn("no weapons loaded"));
        return;
    }

    self warn_melee(zombie);
}

function give_streak_weapon(zombie)
{
    if (!self give_weapon(zombie, streak_weapon()))
    {
        self cicada_util::message(cicada_util::warn("no killstreak weapons on this map"));
        return;
    }

    self warn_melee(zombie);
}

function is_hellhound(zombie)
{
    return isdefined(zombie) && isdefined(zombie.cicada_pve_aitype) && issubstr(zombie.cicada_pve_aitype, "hellhound");
}

function private is_armored(aitype)
{
    return isdefined(aitype) && issubstr(aitype, "armored");
}

function private shooter_aitype()
{
    foreach (aitype in cicada_util::list("actor_jup_enemy_mp_ar_gl,actor_enemy_mp_jugg_aq,actor_enemy_br_base,actor_enemy_lw_base_br"))
        if (ai_loaded(aitype))
            return aitype;

    return undefined;
}

function effect_targets()
{
    return cicada_util::list("all,marked,armed,killstreak,armored,selected");
}

function effect_match(zombie, target, player_)
{
    if (!isdefined(zombie))
        return false;

    switch (target)
    {
        case "marked":
            return istrue(zombie.cicada_pve_marked);

        case "armed":
            return istrue(zombie.cicada_pve_armed);

        case "killstreak":
            return istrue(zombie.cicada_pve_streak);

        case "armored":
            return isdefined(zombie.cicada_pve_aitype) && issubstr(zombie.cicada_pve_aitype, "armored");

        case "selected":
            return isdefined(player_) && isdefined(player_.select_zombie) && zombie == player_.select_zombie;
    }

    return true;
}

function remark_zombies()
{
    self apply_settings();

    foreach (zombie in zombies())
        zombie.cicada_pve_marked = (randomint(100) < level.cicada_pve_effect_chance);

    self cicada_util::message("marks rerolled at ^:" + level.cicada_pve_effect_chance + "%");
}

function type_names()
{
    return cicada_util::list("random,walker,lightweight,armored,hellhound,soldier,juggernaut");
}

function private aitype_for(name)
{
    switch (name)
    {
        case "walker":
            return "actor_jup_spawner_zombie_base_wm";

        case "lightweight":
            return "actor_jup_spawner_zombie_base_lightweight_mp";

        case "armored":
            return "actor_jup_spawner_zombie_base_armored_light";

        case "hellhound":
            return "actor_jup_spawner_zombie_hellhound";

        case "soldier":
            return "actor_jup_enemy_mp_ar_gl";

        case "juggernaut":
            return "actor_enemy_mp_jugg_aq";
    }

    return undefined;
}

function private spawn_aitype()
{
    name = level.cicada_pve_spawn_type;

    if (isdefined(name) && name != "random")
    {
        aitype = aitype_for(name);

        if (isdefined(aitype) && ai_loaded(aitype))
            return aitype;
    }

    return pick_aitype();
}

function private chosen_aitype()
{
    name = level.cicada_pve_type;

    if (isdefined(name) && name != "random")
    {
        aitype = aitype_for(name);

        if (isdefined(aitype) && ai_loaded(aitype))
            return aitype;
    }

    return pick_aitype();
}

function zombies()
{
    live = [];

    if (!isdefined(level.cicada_pve_zombies))
        return live;

    foreach (zombie in level.cicada_pve_zombies)
        if (isdefined(zombie) && isalive(zombie))
            live[live.size] = zombie;

    return live;
}

function count()
{
    return zombies().size;
}

function hold_ai(ent)
{
    if (isdefined(ent))
        path_release(ent);
}

function release_ai(ent)
{
    if (isdefined(ent))
        path_restore(ent);
}

function zombie_at(index)
{
    live = zombies();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function private aitype_label(aitype)
{
    if (!isdefined(aitype))
        return "zombie";

    if (issubstr(aitype, "hellhound"))
        return "hellhound";

    if (issubstr(aitype, "armored"))
        return "armored zombie";

    if (issubstr(aitype, "lightweight"))
        return "runner";

    if (issubstr(aitype, "jugg"))
        return "juggernaut";

    return short_actor(aitype);
}

function is_actor(ent)
{
    return isdefined(ent) && istrue(ent.cicada_pve_actor);
}

function zombie_kind(zombie)
{
    if (!isdefined(zombie))
        return "soldier";

    return aitype_label(zombie.cicada_pve_aitype);
}

function actors()
{
    live = [];

    foreach (zombie in zombies())
        if (is_actor(zombie))
            live[live.size] = zombie;

    return live;
}

function horde()
{
    live = [];

    foreach (zombie in zombies())
        if (!is_actor(zombie))
            live[live.size] = zombie;

    return live;
}

function live_actor_count()
{
    return actors().size;
}

function horde_count()
{
    return horde().size;
}

function actor_at(index)
{
    live = actors();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function horde_at(index)
{
    live = horde();

    if (index < 0 || index >= live.size)
        return undefined;

    return live[index];
}

function clear_actors()
{
    foreach (zombie in actors())
        zombie suicide();

    self cicada_menu::update_menu();
}

function clear_horde()
{
    foreach (zombie in horde())
        zombie suicide();

    self cicada_menu::update_menu();
}

function zombie_name(zombie)
{
    if (!isdefined(zombie))
        return "zombie";

    label = aitype_label(zombie.cicada_pve_aitype);

    if (istrue(zombie.cicada_pve_boss))
        label = "^1boss ^7" + label;
    else if (istrue(zombie.cicada_pve_streak))
        label = "armed " + label;

    return label + " ^:#" + zombie getentitynumber();
}

function boss_actions()
{
    return cicada_util::list("nothing,end round,end game");
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

    foreach (other in zombies())
        other.cicada_pve_killcam_target = 0;

    zombie.cicada_pve_killcam_target = wanted;

    if (wanted)
    {
        zombie setperk("specialty_radarblip", 1);
        self cicada_util::message("final killcam target ^:" + zombie_name(zombie));
    }
    else
        self cicada_util::message("final killcam target ^1cleared");

    self cicada_menu::update_menu();
}

function private killcam_target_killed(zombie, attacker)
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

function private winner_for(attacker)
{
    if (!level.teambased)
        return (isdefined(attacker) && isplayer(attacker)) ? attacker : undefined;

    if (isdefined(attacker) && isdefined(attacker.team) && isdefined(game["teamScores"][attacker.team]))
        return attacker.team;

    return "allies";
}

function private end_on_target(attacker)
{
    waitframe();

    if (istrue(level.gameended))
        return;

    if (istrue(level.var_1fa9e6ecce90d2c2))
        level.roundenddelay = max(level.roundenddelay, 16);

    level thread [[&target_killcam]]();
    gamelogic::endgame(winner_for(attacker), game["end_reason"]["ended_game"]);
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

function private state_key(index, field)
{
    return "pve_state_" + index + "_" + field;
}

function private state_weapon(name)
{
    if (!isdefined(name) || name == "none")
        return undefined;

    weapon = makeweaponfromstring(name);

    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = makeweapon(name);

    return (isdefined(weapon) && !isnullweapon(weapon)) ? weapon : undefined;
}

function private state_fields()
{
    return cicada_util::list("type,origin,angles,health,speed,weapon,boss,marked,target,frozen,armed,streak,actor,offmesh,crate");
}

function private off_navmesh(origin)
{
    spot = getclosestpointonnavmesh(origin);

    if (!isdefined(spot))
        return true;

    return distance(origin, spot) > 16;
}

function save_state()
{
    live = zombies();

    if (!live.size && self state_count() > 0)
        return self state_count();

    self clear_state();

    total = 0;

    foreach (zombie in live)
    {
        if (!isalive(zombie) || !isdefined(zombie.cicada_pve_aitype))
            continue;

        self cicada_util::setmappers(state_key(total, "type"), zombie.cicada_pve_aitype);
        self cicada_util::setmappers(state_key(total, "origin"), zombie.origin);
        self cicada_util::setmappers(state_key(total, "angles"), zombie.angles);
        self cicada_util::setmappers(state_key(total, "health"), zombie.maxhealth);
        self cicada_util::setmappers(state_key(total, "speed"), zombie_speed(zombie));
        self cicada_util::setmappers(state_key(total, "boss"), istrue(zombie.cicada_pve_boss));
        self cicada_util::setmappers(state_key(total, "marked"), istrue(zombie.cicada_pve_marked));
        self cicada_util::setmappers(state_key(total, "target"), istrue(zombie.cicada_pve_killcam_target));
        self cicada_util::setmappers(state_key(total, "frozen"), is_frozen(zombie));
        self cicada_util::setmappers(state_key(total, "armed"), istrue(zombie.cicada_pve_armed));
        self cicada_util::setmappers(state_key(total, "streak"), istrue(zombie.cicada_pve_streak));
        self cicada_util::setmappers(state_key(total, "actor"), is_actor(zombie));
        self cicada_util::setmappers(state_key(total, "offmesh"), off_navmesh(zombie.origin));
        self cicada_util::setmappers(state_key(total, "crate"), zombie.cicada_crate_index);

        if (isdefined(zombie.weapon) && !isnullweapon(zombie.weapon))
            self cicada_util::setmappers(state_key(total, "weapon"), zombie.weapon.basename);
        else
            self cicada_util::setmappers(state_key(total, "weapon"), undefined);

        total++;
    }

    self cicada_util::setmappers("pve_state_count", total);
    return total;
}

function state_count()
{
    return self cicada_util::getmappersint("pve_state_count");
}

function clear_state()
{
    for (i = 0; i < self state_count(); i++)
        foreach (field in state_fields())
            self cicada_util::setmappers(state_key(i, field), undefined);

    self cicada_util::setmappers("pve_state_count", 0);
}

function wait_for_agents()
{
    for (i = 0; i < 100; i++)
    {
        if (isdefined(level.agent_definition))
            return true;

        waitframe();
    }

    return isdefined(level.agent_definition);
}

function restore_state()
{
    back = self load_state();

    if (back)
        self cicada_util::message("^:" + back + " ^7reloaded");
}

function load_state()
{
    total = self state_count();

    if (!total)
        return 0;

    self apply_settings();
    self ensure_ready();
    wait_for_agents();
    self cicada_mods::ensure_crates();

    restored = 0;

    for (i = 0; i < total; i++)
    {
        aitype = self cicada_util::getmappers(state_key(i, "type"));
        origin = self cicada_util::getmappers(state_key(i, "origin"));

        if (!isdefined(aitype) || !isdefined(origin) || !ai_loaded(aitype))
            continue;

        crate = self cicada_util::getmappers(state_key(i, "crate"));
        perch = self cicada_mods::crate_spot(crate);

        if (isdefined(perch))
            origin = perch;

        if (isdefined(perch) || istrue(self cicada_util::getmappers(state_key(i, "offmesh"))))
            spot = origin;
        else
        {
            spot = getclosestpointonnavmesh(origin);

            if (!isdefined(spot))
                spot = origin;
        }

        zombie = spawn_zombie(aitype, spot, true);

        if (!isdefined(zombie))
            continue;

        zombie.cicada_crate_index = crate;

        if (istrue(self cicada_util::getmappers(state_key(i, "actor"))))
            zombie.cicada_pve_actor = 1;

        health = self cicada_util::getmappersint(state_key(i, "health"));

        if (health > 0)
        {
            zombie.maxhealth = health;
            zombie.health = health;
        }

        angles = self cicada_util::getmappers(state_key(i, "angles"));

        if (isdefined(angles))
        {
            zombie forceteleport(spot, angles);
            zombie clearpath();
            zombie forceupdategoalpos();
        }

        speed = self cicada_util::getmappers(state_key(i, "speed"));

        if (isdefined(speed))
        {
            zombie.cicada_pve_movetype = speed;
            apply_speed(zombie, speed);
        }

        weapon = state_weapon(self cicada_util::getmappers(state_key(i, "weapon")));

        if (isdefined(weapon) && give_weapon(zombie, weapon))
        {
            zombie.cicada_pve_armed = istrue(self cicada_util::getmappers(state_key(i, "armed")));
            zombie.cicada_pve_streak = istrue(self cicada_util::getmappers(state_key(i, "streak")));
        }

        if (istrue(self cicada_util::getmappers(state_key(i, "boss"))))
            make_boss(zombie);

        zombie.cicada_pve_marked = istrue(self cicada_util::getmappers(state_key(i, "marked")));
        zombie.cicada_pve_killcam_target = istrue(self cicada_util::getmappers(state_key(i, "target")));

        if (zombie.cicada_pve_killcam_target)
            zombie setperk("specialty_radarblip", 1);

        if (istrue(self cicada_util::getmappers(state_key(i, "frozen"))))
            freeze_zombie(zombie);

        restored++;
    }

    return restored;
}

function manage_state(action)
{
    switch (action)
    {
        case "save":
            self cicada_util::message("saved ^:" + self save_state() + " ^7zombies");
            break;

        case "load":
            self cicada_util::message("restored ^:" + self load_state() + " ^7zombies");
            break;

        case "clear":
            self clear_state();
            self cicada_util::message("zombie state ^1cleared");
            break;
    }

    self cicada_menu::update_menu();
}

function private watch_state()
{
    level waittill("game_ended");

    host = level.cicada_pve_host;

    if (!isdefined(host))
        return;

    if (istrue(host cicada_util::getpers("pve_save_state")) || istrue(host cicada_util::getpers("pve_autosave")))
        host save_state();
}

function private autosave_state()
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    for (;;)
    {
        wait 3;

        host = level.cicada_pve_host;

        if (!isdefined(host) || !istrue(host cicada_util::getpers("pve_autosave")))
            continue;

        if (!count())
            continue;

        host save_state();
    }
}

function private zombies_reached(spot)
{
    foreach (zombie in zombies())
        if (isalive(zombie) && distance2d(zombie.origin, spot) > 96)
            return false;

    return true;
}

function private path_release(zombie)
{
    zombie.cicada_pve_path_frozen = is_frozen(zombie);
    unfreeze_zombie(zombie);
    zombie.ignoreall = 1;
}

function private path_restore(zombie)
{
    was_frozen = istrue(zombie.cicada_pve_path_frozen);
    zombie.cicada_pve_path_frozen = undefined;

    if (was_frozen)
    {
        freeze_zombie(zombie);
        return;
    }

    zombie.ignoreall = 0;
    release_goal(zombie);
}

function start_zombie_path()
{
    self endon("disconnect");
    level endon("game_ended");
    level endon("cicada_pve_stop");

    total = self cicada_movement::count("zombie_path");

    if (!total)
    {
        self cicada_util::message_bold("^6save a point first");
        return;
    }

    if (!count())
    {
        self cicada_util::message_bold("^6spawn a zombie first");
        return;
    }

    start = self cicada_movement::point("zombie_path", 0);
    reset = istrue(self cicada_util::getpers("zombie_path_reset"));
    started = gettime();

    self cicada_movement::path_note("started with ^:" + count() + " ^7actors over ^:" + total + " ^7points");

    foreach (zombie in zombies())
    {
        if (!isalive(zombie))
            continue;

        path_release(zombie);

        if (reset)
        {
            zombie forceteleport(start, zombie.angles);
            zombie clearpath();
            zombie clearbtgoal(3);
            zombie forceupdategoalpos();
        }
    }

    if (reset)
    {
        waitframe();
        waitframe();

        self cicada_movement::path_note("reset every actor to point one");
    }

    for (i = 0; i < total; i++)
    {
        spot = self cicada_movement::point("zombie_path", i);
        leg = gettime();

        foreach (zombie in zombies())
        {
            if (!isalive(zombie))
                continue;

            send_to_spot(zombie, spot);
        }

        waitframe();

        foreach (zombie in zombies())
            if (isalive(zombie))
                zombie forceupdategoalpos();

        limit = gettime() + 15000;

        while (gettime() < limit && !zombies_reached(spot))
            waitframe();

        if (gettime() >= limit)
            self cicada_movement::path_note("point ^:" + (i + 1) + " ^7timed out after ^:15 ^7seconds");
        else
            self cicada_movement::path_note("point ^:" + (i + 1) + " ^7reached in ^:" + cicada_movement::path_seconds(leg) + "s");

        pause = self cicada_util::getpersfloat("zombie_path_pause");

        if (pause > 0)
        {
            foreach (zombie in zombies())
            {
                if (!isalive(zombie))
                    continue;

                hold_at(zombie, zombie.origin);
                zombie aisetdesiredspeed(0);
                zombie aisettargetspeed(0);
            }

            wait pause;

            foreach (zombie in zombies())
                if (isalive(zombie))
                    apply_speed(zombie, zombie_speed(zombie));
        }
    }

    foreach (zombie in zombies())
        if (isalive(zombie))
            path_restore(zombie);

    self cicada_movement::path_note("finished in ^:" + cicada_movement::path_seconds(started) + "s");
    self cicada_util::message("zombie path ^2done");
}

function private send_to_spot(zombie, spot)
{
    zombie.cicada_pve_frozen = false;
    zombie.ignoreall = 1;
    zombie.dontmelee = 1;

    apply_speed(zombie, zombie_speed(zombie));

    zombie clearpath();
    zombie clearbtgoal(3);
    zombie setbtgoalpos(3, spot);
    zombie setbtgoalradius(3, 24);
    zombie forceupdategoalpos();
}

function is_boss(zombie)
{
    return isdefined(zombie) && istrue(zombie.cicada_pve_boss);
}

function make_boss(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie.cicada_pve_boss = 1;
    zombie.maxhealth = max(level.cicada_pve_boss_health, zombie.maxhealth);
    zombie.health = zombie.maxhealth;

    zombie setperk("specialty_radarblip", 1);
}

function toggle_boss(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    if (istrue(zombie.cicada_pve_boss))
    {
        zombie.cicada_pve_boss = 0;
        zombie.maxhealth = max(level.cicada_pve_health, 100);
        zombie.health = zombie.maxhealth;
    }
    else
        make_boss(zombie);

    self cicada_menu::update_menu();
}

function private boss_killed(zombie, attacker)
{
    action = level.cicada_pve_boss_death;

    if (isdefined(level.cicada_pve_host))
        level.cicada_pve_host cicada_util::message_bold("^1" + zombie_name(zombie) + " ^7is down");

    if (!isdefined(action) || action == "nothing")
        return;

    if (!isplayer(attacker))
        attacker = level.cicada_pve_host;

    winner = winner_for(attacker);
    reason = game["end_reason"]["ended_game"];

    if (action == "end game")
        level thread [[&gamelogic::forceend]](reason);
    else
        level thread [[&gamelogic::endgame]](winner, reason);
}

function private ensure_ready()
{
    if (istrue(level.cicada_pve_ready))
        return true;

    if (!isdefined(level.cicada_pve_zombies))
        level.cicada_pve_zombies = [];

    setup_agents();
    setup_threat_groups();

    if (!istrue(level.cicada_pve_state_watch))
    {
        level.cicada_pve_state_watch = true;
        level thread [[&watch_state]]();
        level thread [[&autosave_state]]();
    }

    level.cicada_pve_ready = true;
    return true;
}

function spawn_point()
{
    where = self cicada_util::getpers("pve_spawn_where");

    if (isdefined(where) && where == "self")
        return self.origin;

    return self cicada_util::crosshair();
}

function private no_navmesh_warning()
{
    where = self cicada_util::getpers("pve_spawn_where");

    if (isdefined(where) && where == "self")
        return cicada_util::warn("no navmesh where you are standing");

    return cicada_util::warn("no navmesh where you are aiming");
}

function spawn_single()
{
    self apply_settings();
    self ensure_ready();

    origin = getclosestpointonnavmesh(self spawn_point());

    if (!isdefined(origin))
    {
        self cicada_util::message(self no_navmesh_warning());
        return;
    }

    aitype = spawn_aitype();

    if (!isdefined(aitype))
    {
        self cicada_util::message(cicada_util::warn("no actor types loaded on this map"));
        return;
    }

    zombie = spawn_zombie(aitype, origin, isdefined(level.cicada_pve_spawn_type) && level.cicada_pve_spawn_type != "random");

    self cicada_mods::auto_target_apply(zombie, "auto_ai");
    self cicada_util::message("^1zombie ^7spawned - ^:" + count() + " ^7alive");
    self cicada_menu::update_menu();
}

function spawn_of_type(value, key)
{
    self cicada_util::setpers(key, value);
    self apply_settings();
    self spawn_single();
}

function actor_names()
{
    names = [];

    if (isdefined(level.agent_definition))
    {
        foreach (aitype, definition in level.agent_definition)
            if (isdefined(definition["setup_func"]))
                names[names.size] = aitype;
    }

    if (!names.size)
        names[0] = "none";

    return names;
}

function actor_prefixes()
{
    return cicada_util::list("actor_jup_spawner_zombie_,actor_jup_spawner_,actor_jup_enemy_,actor_jup_,actor_enemy_,actor_ally_,actor_civilian_,actor_");
}

function short_actor(aitype)
{
    if (!isdefined(aitype))
        return "none";

    label = aitype;

    foreach (prefix in actor_prefixes())
    {
        trimmed = cicada_util::trim_start(label, prefix);

        if (trimmed != label)
        {
            label = trimmed;
            break;
        }
    }

    return cicada_util::shorten(label, 20);
}

function actor_labels()
{
    labels = [];

    foreach (aitype in actor_names())
        labels[labels.size] = cicada_util::unique_in(labels, short_actor(aitype));

    return labels;
}

function actor_for_label(label)
{
    labels = actor_labels();
    names = actor_names();

    for (i = 0; i < labels.size; i++)
        if (labels[i] == label)
            return names[i];

    return label;
}

function actor_label(aitype)
{
    labels = actor_labels();
    names = actor_names();

    for (i = 0; i < names.size; i++)
        if (names[i] == aitype)
            return labels[i];

    return short_actor(aitype);
}

function spawn_actor(aitype)
{
    self apply_settings();
    self ensure_ready();

    if (!isdefined(aitype) || aitype == "none" || !ai_loaded(aitype))
    {
        self cicada_util::message(cicada_util::warn("that actor is not loaded on this map"));
        return;
    }

    origin = getclosestpointonnavmesh(self spawn_point());

    if (!isdefined(origin))
    {
        self cicada_util::message(self no_navmesh_warning());
        return;
    }

    actor = spawn_zombie(aitype, origin, true);

    if (isdefined(actor))
    {
        actor.cicada_pve_actor = 1;
        self cicada_mods::auto_target_apply(actor, "auto_ai");
    }

    self cicada_util::message("^1actor ^7spawned - ^:" + live_actor_count() + " ^7alive");
    self cicada_menu::update_menu();
}

function march_actor(actor, spot, angles)
{
    if (!isdefined(actor) || !isalive(actor))
        return;

    actor clearpath();
    actor clearbtgoal(3);
    actor setbtgoalpos(3, spot + anglestoforward(angles) * 1024);
    actor setbtgoalradius(3, 8);
    actor forceupdategoalpos();

    apply_speed(actor, "walk");
}

function private hold_station_actor(spot, angles)
{
    self endon("death");
    level endon("game_ended");

    rig = spawn("script_model", spot);
    rig setmodel("tag_origin");
    rig.angles = angles;

    self.cicada_station_rig = rig;

    march_actor(self, spot, angles);
    self linkto(rig);

    self waittill("death");

    if (isdefined(rig))
        rig delete();
}

function spawn_station_actor(aitype, origin, angles)
{
    self apply_settings();
    self ensure_ready();

    if (!isdefined(aitype) || aitype == "none" || !ai_loaded(aitype))
        return undefined;

    spot = getclosestpointonnavmesh(origin);

    if (!isdefined(spot))
        spot = origin;

    actor = mp_agent::spawnnewagentaitype(aitype, spot, angles, "team_two_hundred");

    if (!isdefined(actor))
        return undefined;

    actor.cicada_pve_aitype = aitype;
    actor.cicada_pve_actor = 1;
    actor.cicada_station_actor = 1;
    actor.ignoreall = 1;
    actor.dontmelee = 1;
    actor.dontsyncmelee = 1;
    actor.takedamage = 0;
    actor.maxhealth = 100000;
    actor.health = actor.maxhealth;

    actor val::set("cicada_station", "damage", 0);
    actor setthreatbiasgroup("pve_zombie");

    actor thread [[&hold_station_actor]](spot, angles);

    return actor;
}

function move_station_actor(actor, spot, angles)
{
    if (!isdefined(actor) || !isalive(actor))
        return;

    ground = getclosestpointonnavmesh(spot);

    if (!isdefined(ground))
        ground = spot;

    actor unlink();
    actor forceteleport(ground, angles);

    if (isdefined(actor.cicada_station_rig))
    {
        actor.cicada_station_rig.origin = ground;
        actor.cicada_station_rig.angles = angles;
    }

    march_actor(actor, ground, angles);

    if (isdefined(actor.cicada_station_rig))
        actor linkto(actor.cicada_station_rig);
}

function drop_station_actor(actor)
{
    if (!isdefined(actor))
        return;

    if (isdefined(actor.cicada_station_rig))
    {
        actor unlink();
        actor.cicada_station_rig delete();
        actor.cicada_station_rig = undefined;
    }

    if (isalive(actor))
        actor suicide();
}

function spawn_of_actor(value, key)
{
    aitype = actor_for_label(value);

    self cicada_util::setpers(key, aitype);
    self spawn_actor(aitype);
}

function set_actor_type(value, key)
{
    self cicada_util::setpers(key, actor_for_label(value));
    self cicada_menu::update_menu();
}

function spawn_chosen_actor()
{
    self spawn_actor(self cicada_util::getpers("pve_actor_type"));
}

function actor_count()
{
    return actor_names().size;
}

function random_actor()
{
    names = actor_names();
    self spawn_actor(names[randomint(names.size)]);
}

function clear_zombies()
{
    foreach (zombie in zombies())
        zombie suicide();

    level.cicada_pve_zombies = [];
    self cicada_menu::update_menu();
}

function apply_speed(zombie, mode)
{
    if (!isdefined(mode))
        mode = "run";

    zombie._blackboard.movetype = mode;

    speed = getanimspeedthreshold(zombie.animsetname, mode);

    if (!isdefined(speed))
        speed = (mode == "sprint") ? 420 : ((mode == "run") ? 260 : 120);

    zombie aisetdesiredspeed(speed);
    zombie aisettargetspeed(speed);
    zombie.cicada_pve_movetype = mode;
}

function zombie_speed(zombie)
{
    if (isdefined(zombie) && isdefined(zombie.cicada_pve_movetype))
        return zombie.cicada_pve_movetype;

    return isdefined(level.cicada_pve_speed) ? level.cicada_pve_speed : "run";
}

function set_zombie_speed(value, zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    apply_speed(zombie, value);
}

function set_zombie_health(value, zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie.maxhealth = int(value);
    zombie.health = zombie.maxhealth;
}

function is_frozen(zombie)
{
    return isdefined(zombie) && istrue(zombie.cicada_pve_frozen);
}

function hold_at(zombie, spot)
{
    zombie clearpath();
    zombie setbtgoalpos(3, spot);
    zombie setbtgoalradius(3, 4);
    zombie forceupdategoalpos();
}

function release_goal(zombie)
{
    zombie clearbtgoal(3);
    zombie clearpath();
    zombie forceupdategoalpos();
}

function freeze_zombie(zombie)
{
    zombie.cicada_pve_frozen = true;
    zombie.ignoreall = 1;
    zombie.dontmelee = 1;

    hold_at(zombie, zombie.origin);

    zombie aisetdesiredspeed(0);
    zombie aisettargetspeed(0);
}

function unfreeze_zombie(zombie)
{
    zombie.cicada_pve_frozen = false;
    zombie.ignoreall = 0;
    zombie.dontmelee = 0;

    release_goal(zombie);
    apply_speed(zombie, zombie_speed(zombie));
}

function toggle_freeze(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    if (is_frozen(zombie))
        unfreeze_zombie(zombie);
    else
        freeze_zombie(zombie);

    self cicada_menu::update_menu();
}

function is_mimic(zombie)
{
    return isdefined(zombie) && isdefined(zombie.cicada_pve_aitype) && issubstr(zombie.cicada_pve_aitype, "mimic");
}

function mimics()
{
    live = [];

    foreach (zombie in zombies())
        if (is_mimic(zombie) && isalive(zombie))
            live[live.size] = zombie;

    return live;
}

function closest_mimic()
{
    pick = undefined;
    best = 0;

    foreach (mimic in mimics())
    {
        range = distancesquared(self.origin, mimic.origin);

        if (!isdefined(pick) || range < best)
        {
            pick = mimic;
            best = range;
        }
    }

    return pick;
}

function grab_me(mimic)
{
    if (!isdefined(mimic))
        mimic = self closest_mimic();

    if (!isdefined(mimic) || !isalive(mimic))
    {
        self cicada_util::message_bold("^5spawn a mimic first");
        return;
    }

    self thread [[&mimic_grab]](mimic);
}

function private grab_timeout()
{
    self endon("death");
    self endon("emerge_attack_hit");

    wait 6;
    self notify("cicada_grab_done");
}

function private mimic_grab(mimic)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (istrue(mimic.cicada_pve_grabbing))
        return;

    mimic.cicada_pve_grabbing = true;
    frozen = is_frozen(mimic);

    if (frozen)
        unfreeze_zombie(mimic);

    mimic.ignoreall = 1;
    mimic.dontmelee = 1;

    angles = vectortoangles(self.origin - mimic.origin);
    angles = (0, angles[1], 0);

    mimic forceteleport(mimic.origin, angles);

    play = level.sharedfuncs["ai"]["Animscripted_SharedFunc"];

    if (isdefined(play))
        mimic thread [[play]]("emerge_attack_hit", "emerge_attack_hit", mimic.origin, angles, "grab_end");

    rig = spawn("script_model", mimic gettagorigin("tag_player"));
    rig setmodel("tag_origin");
    rig.angles = mimic gettagangles("tag_player");
    rig linkto(mimic, "tag_player", (0, 0, -40), (0, 0, 0));

    self setstance("stand", 1, 1);
    self playerlinktoblend(rig, "tag_origin", 0.3, 0.1, 0.05);

    mimic thread [[&grab_timeout]]();
    mimic utility::waittill_any_in_array_return(cicada_util::list("emerge_attack_hit,cicada_grab_done"));

    if (self islinked())
        self unlink();

    rig delete();

    away = self.origin - mimic.origin;
    away = (away[0], away[1], 0);

    if (length(away) < 1)
        away = anglestoforward(angles);

    away = vectornormalize(away);

    self setorigin(self.origin + (0, 0, 5));
    self setvelocity(away * 700 + (0, 0, 300));
    self earthquakeforplayer(0.5, 0.8, self.origin, 500);

    mimic.cicada_pve_grabbing = undefined;
    mimic.ignoreall = 0;
    mimic.dontmelee = 0;

    if (frozen)
        freeze_zombie(mimic);
    else
        release_goal(mimic);
}

function send_at_me(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie.cicada_pve_frozen = false;
    zombie.ignoreall = 0;
    zombie.dontmelee = 0;

    apply_speed(zombie, zombie_speed(zombie));

    zombie clearpath();
    zombie setbtgoalpos(3, self.origin);
    zombie setbtgoalradius(3, 32);
    zombie forceupdategoalpos();
}

function look_at_me(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie forceteleport(zombie.origin, vectortoangles(self.origin - zombie.origin));
}

function kill_zombie(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    zombie suicide();
    self cicada_menu::update_menu();
}

function settle_after_move(zombie)
{
    if (is_frozen(zombie))
    {
        hold_at(zombie, zombie.origin);
        zombie aisetdesiredspeed(0);
        zombie aisettargetspeed(0);
        return;
    }

    release_goal(zombie);
}

function manage_teleport(where, zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    switch (where)
    {
        case "to crosshair":
            zombie forceteleport(self cicada_util::crosshair(), zombie.angles);
            settle_after_move(zombie);
            break;

        case "to me":
            zombie forceteleport(self.origin, vectortoangles(self.origin - zombie.origin));
            settle_after_move(zombie);
            break;

        case "to them":
            self setorigin(zombie.origin);
            break;
    }
}

function move_zombies(where)
{
    destination = (where == "crosshair") ? self cicada_util::crosshair() : self.origin;

    moved = 0;

    foreach (zombie in zombies())
    {
        zombie forceteleport(destination, zombie.angles);
        settle_after_move(zombie);
        moved++;
    }

    self cicada_util::message("^:" + moved + " ^7moved to ^:" + destination);
    self cicada_util::sound("scavenger_pack_pickup");
}

function all_frozen()
{
    return istrue(level.cicada_pve_frozen_all);
}

function freeze_all()
{
    wanted = !all_frozen();
    level.cicada_pve_frozen_all = wanted;

    foreach (zombie in zombies())
    {
        if (wanted)
            freeze_zombie(zombie);
        else
            unfreeze_zombie(zombie);
    }

    self cicada_util::message(wanted ? "zombies ^2frozen" : "zombies ^1unfrozen");
    self cicada_menu::update_menu();
}

function give_shield(zombie)
{
    shield = cicada_loadout::build("iw9_me_riotshield_mp");

    if (!isdefined(shield) || isnullweapon(shield))
        return;

    self give_weapon(zombie, shield);
}

function camo_weapon(zombie)
{
    if (!isdefined(zombie) || !isalive(zombie))
        return;

    weapon = zombie.weapon;

    if (!isdefined(weapon) || isnullweapon(weapon) || weapon.basename == "none")
    {
        self cicada_util::message(cicada_util::warn("give it a weapon first"));
        return;
    }

    root = scripts\cp_mp\weapon::getweaponrootname(weapon);
    variant = isdefined(weapon.variantid) ? weapon.variantid : -1;

    self give_weapon(zombie, cicada_loadout::build(root, cicada_catalog::random_camo(), weapon.attachments, variant));
}

function agent_under_crosshair()
{
    ent = self cicada_util::crosshair_ent();

    if (isdefined(ent) && isagent(ent) && isalive(ent))
        return ent;

    return undefined;
}

function marked_agent()
{
    foreach (zombie in zombies())
        if (istrue(zombie.cicada_bind_target))
            return zombie;

    return undefined;
}

function picked_agent()
{
    ent = self agent_under_crosshair();

    if (isdefined(ent))
        return ent;

    return self marked_agent();
}

function possessing()
{
    return isdefined(self.cicada_possessed) && isdefined(self.playerproxyagent) && isalive(self.playerproxyagent);
}

function possess_summary()
{
    if (!self possessing())
        return "^1nobody";

    return "^:" + zombie_name(self.cicada_possessed);
}

function release_agent()
{
    if (!isdefined(self.cicada_possessed))
        return;

    agent = self.cicada_possessed;
    self.cicada_possessed = undefined;

    self notify("cicada_possess_done");

    if (isdefined(self.playerproxyagent))
    {
        self restorecontrolagent();
        self.playerproxyagent = undefined;
    }

    setdvar("cg_drawgun", 1);
    setdvar("cg_drawcrosshair", 1);

    if (self possess_vision() != "none")
        self visionsetnakedforplayer("", 0);

    self cicada_util::message("let go of ^:" + zombie_name(agent));
    self cicada_menu::update_menu();
}

function possess_visions()
{
    list = [];
    list[0] = "none";

    foreach (name in cicada_catalog::vision_refs())
        list[list.size] = name;

    return list;
}

function possess_vision()
{
    name = self cicada_util::getpers("possess_vision");

    if (!isdefined(name) || name == "")
        return "none";

    return name;
}

function possess_agent(agent)
{
    if (self possessing())
    {
        self release_agent();
        return;
    }

    if (!isdefined(agent))
        agent = self picked_agent();

    if (!isdefined(agent) || !isalive(agent))
    {
        self cicada_util::message_bold("^1look at an agent or mark one first");
        return;
    }

    if (!isalive(self))
    {
        self cicada_util::message_bold("^1stay alive for this");
        return;
    }

    self.cicada_possessed = agent;
    self controlagent(agent);
    self.playerproxyagent = agent;

    if (self possess_vision() != "none")
        self visionsetnakedforplayer(self possess_vision(), 0);

    self thread [[&watch_possession]](agent);
    self thread [[&watch_possess_round]]();

    self cicada_util::message("riding ^:" + zombie_name(agent));
    self cicada_menu::update_menu();
}

function private watch_possession(agent)
{
    self endon("disconnect");
    self endon("cicada_possess_done");

    for (;;)
    {
        waitframe();

        if (!isdefined(agent) || !isalive(agent))
            break;

        if (!isalive(self))
            break;
    }

    self release_agent();
}

function private watch_possess_round()
{
    self endon("disconnect");
    self endon("cicada_possess_done");

    level waittill("game_ended");
    self release_agent();
}

function gesture_names()
{
    return cicada_util::list("talk,military_point,casual_point,beckon,stop,look,hide,glance,yes,no,cough");
}

function gesture_takes_target(name)
{
    switch (name)
    {
        case "military_point":
        case "casual_point":
        case "beckon":
        case "stop":
        case "look":
        case "hide":
            return true;
    }

    return false;
}

function gesture_name()
{
    name = self cicada_util::getpers("agent_gesture");

    if (!isdefined(name) || name == "")
        return "talk";

    return name;
}

function set_agent_gesture(name, agent)
{
    self cicada_util::setpers("agent_gesture", name);

    if (isdefined(agent))
        self play_gesture(agent, name);

    self cicada_menu::update_menu();
}

function play_gesture(agent, name)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    if (!isdefined(name))
        name = self gesture_name();

    hold = self cicada_util::getpersint("gesture_hold");

    if (hold < 250)
        hold = 1000;

    target = gesture_takes_target(name) ? self : undefined;

    agent thread scripts\asm\gesture::ai_request_gesture(name, target, hold, undefined);
}

function gesture_every_agent()
{
    name = self gesture_name();
    sent = 0;

    foreach (zombie in zombies())
    {
        self play_gesture(zombie, name);
        sent++;
    }

    self cicada_util::message("^:" + name + " ^7sent to ^:" + sent);
}

function private settle_lookat(ent)
{
    self endon("death");

    self clearlookatent();
    waitframe();

    if (!isdefined(ent) || !isdefined(self))
        return;

    self setlookatent(ent);
}

function look_at_ent(agent, ent)
{
    if (!isdefined(agent) || !isalive(agent) || !isdefined(ent))
        return;

    agent thread [[&settle_lookat]](ent);
}

function watch_me(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    self look_at_ent(agent, self);
    self cicada_util::message(zombie_name(agent) + " ^7is watching you");
}

function stop_watching(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent clearlookatent();
    agent stoplookat();
    self cicada_util::message(zombie_name(agent) + " ^7looked away");
}

function orient_modes()
{
    return cicada_util::list("face current,face motion,face enemy,face enemy or motion,face angle");
}

function orient_mode(agent)
{
    if (isdefined(agent) && isdefined(agent.cicada_orient))
        return agent.cicada_orient;

    return "face current";
}

function set_orient(mode, agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent.cicada_orient = mode;

    if (mode == "face angle")
        agent orientmode(mode, vectortoyaw(self.origin - agent.origin));
    else
        agent orientmode(mode);
}

function aim_agent_at(agent, target)
{
    if (!isdefined(agent) || !isalive(agent) || !isdefined(target) || !issentient(target))
        return;

    agent aieventlistenerevent("combat", target, target.origin);
    agent agentsetfavoriteenemy(target);
    agent setagentattacker(target);
    agent getenemyinfo(target);
    agent forcethreatupdate();
}

function hunt_me(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent.ignoreme = 0;
    agent.ignoreall = 0;

    self aim_agent_at(agent, self);
    self cicada_util::message(zombie_name(agent) + " ^7wants you");
}

function hunt_marked(agent)
{
    target = self marked_agent();

    if (!isdefined(target) || target == agent)
    {
        self cicada_util::message_bold("^1mark another one first");
        return;
    }

    self aim_agent_at(agent, target);
    self cicada_util::message(zombie_name(agent) + " ^7wants ^:" + zombie_name(target));
}

function forget_target(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent agentsetfavoriteenemy(undefined);
    agent forcethreatupdate();
    self cicada_util::message(zombie_name(agent) + " ^7forgot its target");
}

function hunt_every_agent()
{
    foreach (zombie in zombies())
        self hunt_me(zombie);

    self cicada_util::message("every agent wants you");
}

function behaviour_on(agent, key)
{
    if (!isdefined(agent) || !isdefined(agent.cicada_behaviour))
        return false;

    return istrue(agent.cicada_behaviour[key]);
}

function apply_behaviour(agent, key, state)
{
    switch (key)
    {
        case "no traversals":
            agent enabletraversals(state ? 0 : 1);
            break;

        case "stand only":
            if (state)
                agent allowedstances("stand");
            else
                agent allowedstances("stand", "crouch", "prone");
            break;

        case "never shoot":
            agent.dontevershoot = state ? 1 : 0;
            break;

        case "never melee":
            agent.dontmelee = state ? 1 : 0;

            if (isdefined(agent.bt))
                agent.bt.cannotmelee = state ? 1 : 0;
            break;

        case "ignore me":
            agent.ignoreme = state ? 1 : 0;
            break;

        case "ignore everyone":
            agent.ignoreall = state ? 1 : 0;
            break;

        case "aggressive":
            agent.aggressivemode = state ? 1 : 0;
            break;

        case "no flinch":
            agent.disablebulletwhizbyreaction = state ? 1 : 0;
            break;

        case "no run and gun":
            agent.disablerunngun = state ? 1 : 0;
            break;

        case "no dodge":
            agent.disabledodge = state ? 1 : 0;
            agent.nododgemove = state ? 1 : 0;
            break;

        case "crouch only":
            if (state)
                agent allowedstances("crouch");
            else
                agent allowedstances("stand", "crouch", "prone");
            break;

        case "no reload":
            agent.disablereload = state ? 1 : 0;
            break;

        case "force pistol":
            agent.forcesidearm = state ? 1 : 0;
            break;

        case "super sprint":
            if (state)
                apply_speed(agent, "super_sprint");
            else
                apply_speed(agent, isdefined(level.cicada_pve_speed) ? level.cicada_pve_speed : "run");
            break;
    }
}

function toggle_behaviour(key, agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    if (!isdefined(agent.cicada_behaviour))
        agent.cicada_behaviour = [];

    state = !behaviour_on(agent, key);
    agent.cicada_behaviour[key] = state;

    apply_behaviour(agent, key, state);
    self cicada_menu::update_menu();
}

function behaviour_keys()
{
    return cicada_util::list("no traversals,stand only,crouch only,never shoot,never melee,ignore me,ignore everyone,aggressive,no flinch,no run and gun,no dodge,no reload,force pistol,super sprint");
}

function combat_trees()
{
    return cicada_util::list("soldier_agent,soldier_jup_ob,rusher_jup_ob,juggernaut_agent");
}

function private combat_asm(tree)
{
    if (tree == "rusher_jup_ob")
        return "rusher";

    return "soldier";
}

function combat_tree()
{
    tree = self cicada_util::getpers("pve_combat_tree");

    if (!isdefined(tree))
        return "soldier_agent";

    return tree;
}

function combat_styles()
{
    return cicada_util::list("keep,full");
}

function combat_modes()
{
    return cicada_util::list("cover,ambush,guard_location,follow_player");
}

function is_combat_agent(agent)
{
    return isdefined(agent) && istrue(agent.cicada_combat);
}

function combat_count()
{
    total = 0;

    foreach (zombie in zombies())
        if (is_combat_agent(zombie))
            total++;

    return total;
}

function combat_summary(agent)
{
    if (isdefined(agent))
        return is_combat_agent(agent) ? ("^2on ^7- ^:" + agent.cicada_combat_tree) : "^1off";

    return "^:" + combat_count() + " ^7converted";
}

function private apply_combat_tuning(agent)
{
    agent.aggressivemode = 1;
    agent.dontevershoot = 0;
    agent.disablerunngun = 0;
    agent.disabledodge = 0;
    agent.nododgemove = 0;
    agent.disablepistol = 0;
    agent.disablereload = 0;
    agent.disablebulletwhizbyreaction = 0;
    agent.ignoreall = 0;
    agent.ignoreme = 0;
    agent.combatmode = self cicada_util::getpers("pve_combat_mode");
    agent.pathenemyfightdist = self cicada_util::getpersint("pve_combat_fight_dist");

    if (isdefined(agent.bt))
        agent.bt.cannotmelee = 0;

    agent allowedstances("stand", "crouch", "prone");
    agent enabletraversals(1);

    accuracy = self cicada_util::getpersfloat("pve_combat_accuracy");

    if (accuracy > 0)
        agent.baseaccuracy = accuracy;

    style = self cicada_util::getpers("pve_combat_style");
    agent.shootstyleoverride = (isdefined(style) && style == "full") ? "full" : undefined;
}

function private tree_shoots(tree)
{
    return isdefined(tree) && !issubstr(tree, "zombie") && !issubstr(tree, "civilian") && !issubstr(tree, "capture_bot");
}

function private combat_ready(agent)
{
    return isdefined(agent) && isalive(agent) && !isplayer(agent) && isdefined(agent.behaviortreeasset) && isdefined(agent.asm) && isdefined(agent._blackboard) && isdefined(agent.animsetname);
}

function private swap_combat_tree(agent, tree, asm_name)
{
    if (!archetypeassetloaded(asm_name))
        return false;

    agent.cicada_combat_swapped = true;
    agent.cicada_combat_oldtree = agent.behaviortreeasset;
    agent.cicada_combat_oldasm = agent.asmasset;
    agent.cicada_combat_oldbase = agent getbasearchetype();

    agent.ignoreall = 1;
    agent.enemy = undefined;
    agent clearbtgoal(3);
    agent clearbtgoal(4);
    agent clearpath();
    agent forceupdategoalpos();

    replace_behaviour_tree(agent, tree);

    agent setbasearchetype(asm_name);
    agent setoverridearchetype("default", asm_name);
    agent.asmasset = asm_name;
    agent.defaultasm = asm_name;

    return true;
}

function combat_convert(agent)
{
    if (!combat_ready(agent) || is_combat_agent(agent))
        return false;

    tree = self combat_tree();
    asm_name = combat_asm(tree);

    if (tree_shoots(agent.behaviortreeasset))
    {
        agent.cicada_combat = true;
        agent.cicada_combat_tree = agent.behaviortreeasset;
        self apply_combat_tuning(agent);
        return true;
    }

    if (!swap_combat_tree(agent, tree, asm_name))
        return false;

    agent.cicada_combat = true;
    agent.cicada_combat_tree = tree;

    self apply_combat_tuning(agent);

    weapon = agent.weapon;

    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = random_weapon();

    if (isdefined(weapon))
    {
        self give_weapon(agent, weapon);
        agent.cicada_pve_armed = 1;
    }

    return true;
}

function combat_restore(agent)
{
    if (!is_combat_agent(agent))
        return false;

    agent.cicada_combat = false;
    agent.shootstyleoverride = undefined;
    agent.aggressivemode = 0;

    if (!istrue(agent.cicada_combat_swapped) || !isalive(agent))
        return true;

    agent.cicada_combat_swapped = false;

    agent.enemy = undefined;
    agent clearbtgoal(3);
    agent clearbtgoal(4);
    agent clearpath();

    if (isdefined(agent.cicada_combat_oldtree))
        replace_behaviour_tree(agent, agent.cicada_combat_oldtree);

    agent clearoverridearchetype("weapon");
    agent clearoverridearchetype("default");

    if (isdefined(agent.cicada_combat_oldbase))
        agent setbasearchetype(agent.cicada_combat_oldbase);

    if (isdefined(agent.cicada_combat_oldasm))
    {
        agent.asmasset = agent.cicada_combat_oldasm;
        agent.defaultasm = agent.cicada_combat_oldasm;
    }

    return true;
}

function toggle_combat_agent(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    if (is_combat_agent(agent))
    {
        self combat_restore(agent);
        self cicada_util::message(zombie_name(agent) + " ^7combat ^1off");
    }
    else if (self combat_convert(agent))
        self cicada_util::message(zombie_name(agent) + " ^7combat ^2on ^7- ^:" + self combat_tree());
    else
        self cicada_util::message(cicada_util::warn("this actor cannot take a combat tree"));

    self cicada_menu::update_menu();
}

function convert_every_agent()
{
    done = 0;

    foreach (zombie in zombies())
        if (self combat_convert(zombie))
            done++;

    self cicada_util::message("^:" + done + " ^7given combat behaviour");
    self cicada_util::sound("scavenger_pack_pickup");
    self cicada_menu::update_menu();
}

function restore_every_agent()
{
    done = 0;

    foreach (zombie in zombies())
        if (self combat_restore(zombie))
            done++;

    self cicada_util::message("^:" + done + " ^7back to default behaviour");
    self cicada_menu::update_menu();
}

function private combat_settle(agent)
{
    self endon("disconnect");
    level endon("game_ended");

    wait 0.25 + randomfloat(0.25);

    for (i = 0; i < 40 && !combat_ready(agent); i++)
        waitframe();

    if (!combat_ready(agent))
        return;

    self combat_convert(agent);
}

function archetypes()
{
    return cicada_util::list("tier 1,tier 2,tier 3,riot shield,special");
}

function set_archetype(kind, agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent.cicada_archetype = kind;

    switch (kind)
    {
        case "tier 1":
            agent_utils::overridetier1(agent);
            break;

        case "tier 2":
            agent_utils::overridetier2(agent);
            break;

        case "tier 3":
            agent_utils::overridetier3(agent, 0);
            break;

        case "riot shield":
            agent_utils::overrideriotshield(agent);
            break;

        case "special":
            agent_utils::overridespecial(agent);
            break;
    }

    self cicada_util::message(zombie_name(agent) + " ^7is now ^:" + kind);
}

function archetype_of(agent)
{
    if (isdefined(agent) && isdefined(agent.cicada_archetype))
        return agent.cicada_archetype;

    return "tier 1";
}

function drop_ragdoll(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    agent startragdoll();
}

function clone_agent(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return;

    copy = agent cloneagent(10);

    if (!isdefined(copy))
    {
        self cicada_util::message_bold("^1no clone came back");
        return;
    }

    self cicada_util::message("clone of ^:" + zombie_name(agent) + " ^7dropped");
}

function near_agents(radius)
{
    if (!isdefined(radius))
        radius = 1000;

    return getaiarrayinradius(self.origin, radius);
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

    return level.agentarray.size;
}

function private setup_threat_groups()
{
    if (!threatbiasgroupexists("pve_zombie"))
        createthreatbiasgroup("pve_zombie");

    setignoremegroup("pve_zombie", "pve_zombie");

    if (isdefined(level.cicada_pve_ondamage_orig))
        return;

    level.cicada_pve_ondamage_orig = [];
    level.cicada_pve_onkilled_orig = [];

    foreach (unittype, funcs in level.agent_funcs)
    {
        if (unittype == "player")
            continue;

        if (isdefined(funcs["on_damaged"]))
        {
            level.cicada_pve_ondamage_orig[unittype] = funcs["on_damaged"];
            level.agent_funcs[unittype]["on_damaged"] = &cicada_pve::zombie_on_damaged;
        }

        level.cicada_pve_onkilled_orig[unittype] = funcs["gametype_on_killed"];
        level.agent_funcs[unittype]["gametype_on_killed"] = &cicada_pve::zombie_on_killed;
    }

    level.cicada_pve_aiscore_orig = level.var_3749fd90367bc366;
    level.var_3749fd90367bc366 = istrue(level.cicada_pve_score) ? 1 : 0;
}

function private zombie_on_damaged(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, modelindex, partname, objweapon)
{
    if (!isdefined(objweapon))
        objweapon = sweapon;

    if (istrue(level.cicada_pve_snipers) && istrue(self.cicada_pve_zombie) && isplayer(eattacker) && isdefined(objweapon) && isdefined(objweapon.basename) && weaponclass(objweapon.basename) == "sniper")
        idamage = self.health + 1;

    if (isplayer(eattacker) && isalive(self))
        eattacker cicada_mods::play_unit_effect(istrue(self.cicada_pve_zombie) ? "zombie" : "agent", "hit", self.origin);

    original = level.cicada_pve_ondamage_orig[self.unittype];
    if (isdefined(original))
        [[original]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, modelindex, partname, objweapon);
}

function private zombie_on_killed(einflictor, eattacker, idamage, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration)
{
    if (istrue(self.cicada_pve_zombie) && isplayer(eattacker))
    {
        target = istrue(self.cicada_pve_killcam_target);

        if (target)
        {
            level.recordfinalkillcam = 1;
            level.disable_killcam = 0;
        }

        if (target || istrue(level.cicada_pve_killcam))
            record_zombie_finalkillcam(eattacker, einflictor, objweapon, smeansofdeath, timeoffset, target);

        if (target)
            killcam_target_killed(self, eattacker);
    }

    if (istrue(self.cicada_pve_boss))
        boss_killed(self, eattacker);

    if (isplayer(eattacker))
        eattacker cicada_mods::play_unit_effect(istrue(self.cicada_pve_zombie) ? "zombie" : "agent", "kill", self.origin);

    original = level.cicada_pve_onkilled_orig[self.unittype];
    if (isdefined(original))
        [[original]](einflictor, eattacker, idamage, smeansofdeath, objweapon, vdir, shitloc, timeoffset, deathanimduration);
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

function private record_zombie_finalkillcam(attacker, einflictor, objweapon, smeansofdeath, timeoffset, force)
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

function private spawn_zombie(aitype, origin, keep_type)
{
    streak = randomint(100) < level.cicada_pve_streak_chance;
    armed = streak || randomint(100) < level.cicada_pve_weapon_chance;

    if (armed && !(istrue(level.cicada_pve_arm_armored) && is_armored(aitype)))
    {
        if (istrue(keep_type))
        {
            if (!aitype_shoots(aitype))
            {
                armed = false;
                streak = false;
            }
        }
        else
        {
            shooter = shooter_aitype();

            if (isdefined(shooter))
                aitype = shooter;
            else
            {
                armed = false;
                streak = false;
            }
        }
    }

    zombie = mp_agent::spawnnewagentaitype(aitype, origin, (0, randomint(360), 0), "team_two_hundred");
    if (!isdefined(zombie))
        return;

    zombie.maxhealth = max(level.cicada_pve_health, 100);
    zombie.health = zombie.maxhealth;
    zombie.dontsyncmelee = 1;
    zombie.cicada_pve_zombie = 1;

    if (istrue(level.cicada_pve_blip))
        zombie setperk("specialty_radarblip", 1);

    apply_speed(zombie, level.cicada_pve_speed);

    zombie.cicada_pve_aitype = aitype;
    zombie.cicada_pve_marked = (randomint(100) < level.cicada_pve_effect_chance);

    if (armed && give_weapon(zombie, streak ? streak_weapon() : random_weapon()))
    {
        zombie.cicada_pve_armed = 1;
        zombie.cicada_pve_streak = streak;
    }

    if (randomint(100) < level.cicada_pve_boss_chance)
        make_boss(zombie);

    zombie setthreatbiasgroup("pve_zombie");

    level.cicada_pve_zombies[level.cicada_pve_zombies.size] = zombie;
    zombie thread [[&watch_zombie]](zombie);

    if (istrue(level.cicada_pve_combat))
        self thread [[&combat_settle]](zombie);

    return zombie;
}

function private capture_zombie(zombie)
{
    if (!isdefined(zombie))
        return undefined;

    seed = spawnstruct();

    seed.aitype = zombie.cicada_pve_aitype;
    seed.origin = zombie.origin;
    seed.angles = zombie.angles;
    seed.health = zombie.maxhealth;
    seed.speed = zombie_speed(zombie);
    seed.boss = istrue(zombie.cicada_pve_boss);
    seed.marked = istrue(zombie.cicada_pve_marked);
    seed.target = istrue(zombie.cicada_pve_killcam_target);
    seed.frozen = is_frozen(zombie);
    seed.armed = istrue(zombie.cicada_pve_armed);
    seed.streak = istrue(zombie.cicada_pve_streak);
    seed.actor = is_actor(zombie);

    if (isdefined(zombie.weapon) && !isnullweapon(zombie.weapon))
        seed.weapon = zombie.weapon.basename;

    return seed;
}

function private respawn_from(seed)
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    if (!isdefined(seed) || !isdefined(seed.aitype))
        return;

    delay = level.cicada_pve_respawn_delay;

    if (!isdefined(delay) || delay < 0.05)
        delay = 3;

    wait delay;

    if (!istrue(level.cicada_pve_respawn))
        return;

    spot = getclosestpointonnavmesh(seed.origin);

    if (!isdefined(spot))
        spot = seed.origin;

    zombie = spawn_zombie(seed.aitype, spot, true);

    if (!isdefined(zombie))
        return;

    if (istrue(seed.actor))
        zombie.cicada_pve_actor = 1;

    zombie.maxhealth = seed.health;
    zombie.health = seed.health;
    zombie.cicada_pve_marked = seed.marked;

    if (isdefined(seed.angles))
        zombie forceteleport(spot, seed.angles);

    apply_speed(zombie, seed.speed);

    if (isdefined(seed.weapon))
        give_weapon(zombie, state_weapon(seed.weapon));

    if (istrue(seed.boss) && !is_boss(zombie))
        make_boss(zombie);

    if (istrue(seed.target))
        zombie.cicada_pve_killcam_target = 1;

    if (istrue(seed.frozen))
        freeze_zombie(zombie);
    else
    {
        zombie clearpath();
        zombie forceupdategoalpos();
    }
}

function private watch_zombie(zombie)
{
    level endon("game_ended");
    level endon("cicada_pve_stop");

    zombie waittill("death");

    seed = capture_zombie(zombie);

    for (i = 0; i < level.cicada_pve_zombies.size; i++)
    {
        if (level.cicada_pve_zombies[i] == zombie)
        {
            level.cicada_pve_zombies = utility::array_remove_index(level.cicada_pve_zombies, i);
            break;
        }
    }

    respawn = istrue(level.cicada_pve_respawn) && !istrue(zombie.cicada_pve_adopted);

    zombie.cicada_pve_zombie = undefined;
    zombie.cicada_pve_adopted = undefined;
    zombie.cicada_pve_actor = undefined;

    if (respawn)
        level thread [[&respawn_from]](seed);
}

function tracked(agent)
{
    if (!isdefined(agent) || !isdefined(level.cicada_pve_zombies))
        return false;

    foreach (zombie in level.cicada_pve_zombies)
        if (zombie == agent)
            return true;

    return false;
}

function private adopt_is_actor(aitype)
{
    if (!isdefined(aitype))
        return true;

    return !issubstr(aitype, "zombie") && !issubstr(aitype, "hellhound");
}

function private adopt_agent(agent)
{
    if (!isdefined(agent) || !isalive(agent) || isplayer(agent))
        return false;

    if (istrue(agent.cicada_station_actor) || isdefined(level.cicada_pve_victim) && agent == level.cicada_pve_victim)
        return false;

    if (tracked(agent))
        return false;

    agent.cicada_pve_zombie = 1;
    agent.cicada_pve_adopted = 1;
    agent.cicada_pve_aitype = agent.agent_type;

    if (adopt_is_actor(agent.cicada_pve_aitype))
        agent.cicada_pve_actor = 1;
    else
        agent.cicada_pve_actor = undefined;

    if (isdefined(agent.weapon) && !isnullweapon(agent.weapon))
        agent.cicada_pve_armed = 1;

    level.cicada_pve_zombies[level.cicada_pve_zombies.size] = agent;
    agent thread [[&watch_zombie]](agent);

    return true;
}

function private adopt_pass()
{
    if (!isdefined(level.agentarray))
        return;

    if (!isdefined(level.cicada_pve_zombies))
        level.cicada_pve_zombies = [];

    kept = [];

    foreach (zombie in level.cicada_pve_zombies)
        if (isdefined(zombie) && isalive(zombie))
            kept[kept.size] = zombie;

    level.cicada_pve_zombies = kept;

    found = false;

    foreach (agent in level.agentarray)
        if (adopt_agent(agent))
            found = true;

    if (!found)
        return;

    foreach (player in level.players)
        if (isdefined(player) && !cicada_util::is_bot(player))
            player cicada_menu::update_menu();
}

function adopt_watch()
{
    level endon("game_ended");

    if (istrue(level.cicada_pve_adopt_watch))
        return;

    level.cicada_pve_adopt_watch = true;

    for (;;)
    {
        adopt_pass();
        wait 0.5;
    }
}

function private spawn_origin()
{
    player = random_alive_player();
    if (!isdefined(player))
        return undefined;

    for (i = 0; i < 5; i++)
    {
        dist = randomintrange(250, max(level.cicada_pve_range, 300));
        angle = randomint(360);
        wanted = player.origin + (cos(angle) * dist, sin(angle) * dist, 0);
        point = getclosestpointonnavmesh(wanted);

        if (isdefined(point))
            return point;
    }

    return player.origin;
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
