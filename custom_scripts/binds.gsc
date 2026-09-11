#using scripts\cp_mp\damagefeedback;
#using scripts\mp\utility\player;
#using scripts\mp\weapons;

#using custom_scripts\cinematics;
#using custom_scripts\extras;
#using custom_scripts\leftovers;
//#using custom_scripts\link;
#using custom_scripts\stations;
#using custom_scripts\loadout;
#using custom_scripts\mechanics;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\props;
#using custom_scripts\pve;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_binds;

function init()
{
    level.cicada_binds = [];
    level.cicada_bind_names = [];

    register("play anim", &cicada_mods::play_anim_once);
    register("smooth anim", &smooth_anim);
    register("play gesture", &cicada_mods::play_gesture_once);
    register("nac", &nac);
    register("instaswap", &instaswap);
    register("canswap", &canswap);
    register("illusion", &illusion);
    register("empty clip", &empty_clip);
    register("one bullet", &one_bullet);
    register("pull equipment", &pull_equipment);
    register("instant tac", &instant_tac);
    register("change class", &change_class);
    register("freeze anim", &freeze_anim);
    register("third person", &third_person);
    register("vision", &cicada_mods::toggle_vision);
    register("bounce", &bounce);
    register("invis crate", &cicada_mods::save_crate);
    register("velocity", &apply_velocity);
    register("bot velocity", &apply_bot_velocity);
    register("agent velocity", &apply_agent_velocity);
    register("zombie velocity", &apply_zombie_velocity);
    register("bolt movement", &cicada_movement::play_bolt);
    register("bot bolt movement", &cicada_movement::play_bot_bolt);
    register("agent bolt movement", &cicada_movement::play_agent_bolt);
    register("zombie bolt movement", &cicada_movement::play_zombie_bolt);
    register("record movement", &cicada_movement::play_record);
    register("bot movement", &cicada_movement::start_bot_path);
    register("zombie movement", &cicada_pve::start_zombie_path);
    register("load class", &cicada_loadout::load_class);
    register("^:random ^7class", &cicada_loadout::random_class);
    register("start camera", &cicada_cinematics::start_path);
    register("save position", &save_position);
    register("load position", &load_position);
    register("unstuck", &unstuck);
    register("reverse ele", &reverse_ele);
    register("spectator", &spectator);
    register("spectate repeater", &spectate_repeater);
    register("spectate damage repeater", &spectate_damage_repeater);
    register("damage", &self_damage);
    register("scavenger", &scavenger);
    register("hitmarker", &hitmarker);
    register("snapshot delay", &cicada_mods::snapshot_burst);
    register("flash", &flash);
    register("shellshock", &shellshock_self);
    register("stuck", &stuck);
    register("kill bots", &kill_bots);
    register("kill agents", &kill_agents);
    register("knockback", &cicada_mods::knockback_push);
    register("teleport near", &cicada_mods::teleport_near);
    //register("link ride", &cicada_link::start_ride);
    //register("unlink", &cicada_link::stop_ride);
    register("parachute", &cicada_mechanics::pull_chute);
    register("max ammo", &cicada_extras::max_ammo);
    register("fill the clip", &cicada_extras::fill_clip);
    register("explosive rounds", &cicada_leftovers::explosive_rounds);
    register("radiation zone", &cicada_leftovers::make_zone);
    register("tripwire point", &cicada_leftovers::save_wire_point);
    register("place station", &cicada_stations::place_station);
    register("anim slot 1", &anim_slot_1);
    register("anim slot 2", &anim_slot_2);
    register("anim slot 3", &anim_slot_3);
    register("anim slot 4", &anim_slot_4);
    register("anim slot 5", &anim_slot_5);
    register("anim slot 6", &anim_slot_6);
    register("anim slot 7", &anim_slot_7);
    register("anim slot 8", &anim_slot_8);
}

function register(name, action)
{
    level.cicada_binds[name] = action;
    level.cicada_bind_names[level.cicada_bind_names.size] = name;
}

function anim_slot_1()
{
    self cicada_mods::play_anim_slot(1);
}

function anim_slot_2()
{
    self cicada_mods::play_anim_slot(2);
}

function anim_slot_3()
{
    self cicada_mods::play_anim_slot(3);
}

function anim_slot_4()
{
    self cicada_mods::play_anim_slot(4);
}

function anim_slot_5()
{
    self cicada_mods::play_anim_slot(5);
}

function anim_slot_6()
{
    self cicada_mods::play_anim_slot(6);
}

function anim_slot_7()
{
    self cicada_mods::play_anim_slot(7);
}

function anim_slot_8()
{
    self cicada_mods::play_anim_slot(8);
}

function is_anim_slot(name)
{
    return isstartstr(name, "anim slot ");
}

function anim_slot_index(name)
{
    return int(cicada_util::trim_start(name, "anim slot "));
}

function hidden(name)
{
    if (!is_anim_slot(name))
        return false;

    return anim_slot_index(name) > self cicada_mods::anim_slot_count();
}

function visible_count()
{
    total = 0;

    foreach (name in level.cicada_bind_names)
        if (!self hidden(name))
            total++;

    return total;
}

function used_count()
{
    total = 0;

    foreach (name in level.cicada_bind_names)
    {
        if (self hidden(name))
            continue;

        slot = self cicada_util::getpers(slot_key(name));

        if (isdefined(slot) && slot != "off")
            total++;
    }

    return total;
}

function bind_key(name)
{
    return "bind_" + name;
}

function slot_names()
{
    return cicada_util::list("off,dpad up,dpad down,dpad left,dpad right,rb,lb,a,b,x,y");
}

function slot_command(name)
{
    switch (name)
    {
        case "dpad up":    return "actionslot 1";
        case "dpad down":  return "actionslot 2";
        case "dpad left":  return "actionslot 3";
        case "dpad right": return "actionslot 4";
        case "rb":         return "frag";
        case "lb":         return "smoke";
        case "a":          return "gostand";
        case "b":          return "stance";
        case "x":          return "usereload";
        case "y":          return "weapnext";
    }

    return undefined;
}

function slot_key(name)
{
    return "slot_" + name;
}

function slot_label(name)
{
    if (!isdefined(name))
        name = "off";

    if (name == "off" || istrue(self cicada_util::getpers("bind_names")))
        return name;

    command = slot_command(name);
    return isdefined(command) ? ("[{+" + command + "}]") : name;
}

function slot_labels()
{
    labels = [];

    foreach (name in slot_names())
        labels[labels.size] = self slot_label(name);

    return labels;
}

function slot_from_label(label)
{
    foreach (name in slot_names())
        if (self slot_label(name) == label)
            return name;

    return "off";
}

function has_settings(name)
{
    return name == "play anim" || name == "play gesture" || name == "snapshot delay" || name == "knockback" || name == "kill bots" || name == "kill agents" || name == "teleport near" || name == "bot velocity" || name == "bot bolt movement" || name == "agent velocity" || name == "agent bolt movement" || name == "zombie velocity" || name == "zombie bolt movement" || name == "parachute" || name == "place station" || is_anim_slot(name);
}

function assigned_command(name)
{
    return slot_command(self cicada_util::getpers(slot_key(name)));
}

function binds_on_command(command)
{
    names = [];

    foreach (name in level.cicada_bind_names)
    {
        assigned = self assigned_command(name);

        if (isdefined(assigned) && assigned == command)
            names[names.size] = name;
    }

    return names;
}

function set_slot_key(value, key)
{
    self cicada_util::setpers(key, self slot_from_label(value));
}

function set_slot(value, name)
{
    self set_slot_key(value, slot_key(name));
}

function reset_all()
{
    foreach (name in level.cicada_bind_names)
        self cicada_util::setpers(slot_key(name), "off");

    self cicada_util::message("every bind turned ^:off");
}

function commands()
{
    return cicada_util::list("actionslot 1,actionslot 2,actionslot 3,actionslot 4,frag,smoke,gostand,stance,usereload,weapnext");
}

function private migrate_binds()
{
    foreach (name in level.cicada_bind_names)
    {
        old = self cicada_util::getpers(bind_key(name));

        if (!isdefined(old))
            continue;

        self cicada_util::setpers(bind_key(name), undefined);

        if (!isdefined(self cicada_util::getpers(slot_key(name))))
            self cicada_util::setpers(slot_key(name), slot_names()[old]);
    }
}

function start_monitors()
{
    self migrate_binds();

    foreach (command in commands())
        self thread [[&command_monitor]](command);
}

function command_monitor(command)
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-" + command);

        if (self cicada_util::in_menu())
            continue;

        foreach (name in self binds_on_command(command))
            self thread [[level.cicada_binds[name]]]();
    }
}

function smooth_anim()
{
    self cicada_mods::play_anim_once(1, true);
}

function nac()
{
    self cicada_weapon::nacto(self cicada_weapon::next_weapon(), true);
}

function instaswap()
{
    self cicada_weapon::instaswapto(self cicada_weapon::next_weapon());
}

function canswap()
{
    self cicada_weapon::canswap();
}

function illusion()
{
    self cicada_weapon::illusion();
}

function empty_clip()
{
    self cicada_weapon::empty_clip();
}

function one_bullet()
{
    self cicada_weapon::one_bullet();
}

function equipment_slot_weapon(ref)
{
    info = scripts\mp\equipment::getequipmenttableinfo(ref);

    if (!isdefined(info) || !isdefined(info.objweapon) || isnullweapon(info.objweapon))
        return undefined;

    return info.objweapon;
}

function pull_equipment()
{
    id = self cicada_util::getpers("equipment_weapon");
    kind = self cicada_mods::equipment_bind_kind();

    if (kind == "super")
    {
        self cicada_loadout::use_field_upgrade(id);
        return;
    }

    previous = self getcurrentweapon();

    if (kind == "primary" || kind == "secondary")
    {
        self cicada_loadout::set_equipment(id, kind);
        self cicada_weapon::nacto(equipment_slot_weapon(id), true);
    }
    else
        self cicada_loadout::give_equipment(id);

    if (!istrue(self cicada_util::getpers("equipment_putaway")))
        return;

    wait (self cicada_util::getpersfloat("equipment_putaway_time"));
    self switchtoweapon(previous);
}

function instant_tac()
{
    weapon = equipment_slot_weapon("equip_tac_insert");

    if (!isdefined(weapon))
    {
        self cicada_util::message(cicada_util::warn("tac insert is not loaded"));
        return;
    }

    previous = self getcurrentweapon();

    self giveweapon(weapon);
    self cicada_weapon::nacto(weapon, true);
    wait (self cicada_util::getpersfloat("instant_tac_time"));
    self cicada_mods::play_anim_once(3, false);

    // man idfk
    // wait 0.1;
    // self switchtoweapon(previous);
    // self cicada_weapon::nacto(previous);
}

function change_class()
{
    self cicada_mods::next_class();
}

function freeze_anim()
{
    cicada_mods::toggle_dvar("pan_freezeanim");
}

function third_person()
{
    cicada_mods::toggle_dvar("camera_thirdperson");
}

function bounce()
{
    velocity = self getvelocity();
    self setvelocity(velocity - (0, 0, velocity[2] * 2));
}

function apply_velocity()
{
    self cicada_mods::play_velocity();
}

function apply_bot_velocity()
{
    self cicada_mods::play_bot_velocity();
}

function apply_agent_velocity()
{
    self cicada_mods::play_agent_velocity();
}

function apply_zombie_velocity()
{
    self cicada_mods::play_zombie_velocity();
}

function save_position()
{
    self cicada_mods::save_position();
}

function load_position()
{
    self cicada_mods::load_position();
}

function unstuck()
{
    self cicada_mods::unstuck();
}

function reverse_ele()
{
    self cicada_mods::ride_elevator("down");
}

function spectator()
{
    if (self.sessionstate == "playing")
        self player::updatesessionstate("spectator");
    else
        self player::updatesessionstate("playing");
}

function spectate_repeater()
{
    if (self.sessionstate != "playing")
        return;

    self player::updatesessionstate("spectator");
    wait (self cicada_util::getpersfloat("spectate_time"));
    self player::updatesessionstate("playing");

    if (istrue(self cicada_util::getpers("repeater_illusion")))
        self cicada_weapon::illusion();
}

function spectate_damage_repeater()
{
    self self_damage();
    wait 0.05;
    self spectate_repeater();
}

function self_damage()
{
    attacker = self cicada_util::enemy_player();
    if (attacker == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    invulnerable = self isinvulnerable();
    if (invulnerable)
        self disableinvulnerability();

    maxhealth = self.maxhealth;
    self.maxhealth = 100;
    self.health = self.maxhealth;

    self cicada_mods::deal_damage(self, self cicada_util::getpersint("damage_amount"), attacker);
    wait 0.05;

    self.maxhealth = maxhealth;
    self.health = self.maxhealth;

    if (invulnerable)
        self enableinvulnerability();
}

function scavenger()
{
    self damagefeedback::hudicontype("scavenger");
    self cicada_util::sound("scavenger_pack_pickup");

    if (!istrue(self cicada_util::getpers("real_scavenger")))
        return;

    weapon = self getcurrentweapon();
    self setweaponammoclip(weapon, 0);
    self setweaponammostock(weapon, 9999);
    self cicada_weapon::illusion();
}

function hitmarker()
{
    self damagefeedback::updatedamagefeedback("standard", 0, 0, "standard", 0);
}

function flash()
{
    self shellshock("flash_grenade_mp", self cicada_util::getpersfloat("flash_amount"));
}

function shellshock_self()
{
    self shellshock(self cicada_util::getpers("shellshock_type"), self cicada_util::getpersfloat("shellshock_amount"));
}

function stuck()
{
    enemy = self cicada_util::enemy_player();
    if (enemy == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    grenade = enemy magicgrenademanual(self cicada_util::getpers("stuck_weapon"), self.origin + (0, 0, 40), (0, 0, 0), 3);

    if (!isdefined(grenade))
        return;

    grenade linkto(self, "tag_origin", (0, 0, 40), (0, 0, 0));
    enemy thread [[&weapons::grenadestuckto]](grenade, self, false);
}

function bot_targets()
{
    return cicada_util::list("all bots,enemies only,friendlies only,selected bot");
}

function bot_names()
{
    names = [];

    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_))
            names[names.size] = player_ cicada_util::player_name();

    if (!names.size)
        names[0] = "none";

    return names;
}

function bot_by_name(name)
{
    if (!isdefined(name))
        return undefined;

    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_) && player_ cicada_util::player_name() == name)
            return player_;

    return undefined;
}

function bot_wanted(player_, mode)
{
    if (mode == "enemies only")
        return !self cicada_mods::is_friendly(player_);

    if (mode == "friendlies only")
        return self cicada_mods::is_friendly(player_);

    return true;
}

function kill_bot(player_)
{
    if (!isdefined(player_) || !isalive(player_))
        return;

    if (player_ isinvulnerable())
        player_ disableinvulnerability();

    self cicada_mods::deal_damage(player_, player_.health + 500);
}

function kill_bots()
{
    mode = self cicada_util::getpers("kill_bot_mode");

    if (!isdefined(mode))
        mode = "all bots";

    if (mode == "selected bot")
    {
        target = bot_by_name(self cicada_util::getpers("kill_bot_name"));

        if (!isdefined(target))
        {
            self cicada_util::message_bold("^1that bot is gone");
            return;
        }

        self kill_bot(target);
        return;
    }

    killed = 0;

    foreach (player_ in level.players)
    {
        if (!cicada_util::is_bot(player_) || !isalive(player_))
            continue;

        if (!self bot_wanted(player_, mode))
            continue;

        self kill_bot(player_);
        killed++;
    }

    if (!killed)
        self cicada_util::message_bold("^1no bots matched that filter");
}

function agent_targets()
{
    return cicada_util::list("all agents,selected agent,crosshair agent,nearest agent");
}

function agent_names()
{
    names = [];

    foreach (agent in cicada_pve::zombies())
        names[names.size] = cicada_pve::zombie_name(agent);

    if (!names.size)
        names[0] = "none";

    return names;
}

function agent_by_name(name)
{
    if (!isdefined(name))
        return undefined;

    foreach (agent in cicada_pve::zombies())
        if (cicada_pve::zombie_name(agent) == name)
            return agent;

    return undefined;
}

function agent_closest_to(spot)
{
    closest = undefined;
    best = 0;

    foreach (agent in cicada_pve::zombies())
    {
        gap = distance(agent.origin, spot);

        if (!isdefined(closest) || gap < best)
        {
            closest = agent;
            best = gap;
        }
    }

    return closest;
}

function kill_agent(agent)
{
    if (!isdefined(agent) || !isalive(agent))
        return false;

    self cicada_mods::damage_zombie(agent, agent.health + 500);
    return true;
}

function kill_agents()
{
    mode = self cicada_util::getpers("kill_agent_mode");

    if (!isdefined(mode))
        mode = "all agents";

    if (!cicada_pve::count())
    {
        self cicada_util::message_bold("^1nothing is alive to kill");
        return;
    }

    switch (mode)
    {
        case "selected agent":
            if (!self kill_agent(agent_by_name(self cicada_util::getpers("kill_agent_name"))))
                self cicada_util::message_bold("^1that one is gone");
            return;

        case "crosshair agent":
            self kill_agent(agent_closest_to(self cicada_util::crosshair()));
            return;

        case "nearest agent":
            self kill_agent(agent_closest_to(self.origin));
            return;
    }

    foreach (agent in cicada_pve::zombies())
        self kill_agent(agent);
}
