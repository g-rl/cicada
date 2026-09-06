#using scripts\cp_mp\damagefeedback;
#using scripts\mp\utility\player;
#using scripts\mp\weapons;

#using custom_scripts\cinematics;
#using custom_scripts\loadout;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_binds;

function init()
{
    level.cicada_binds = [];
    level.cicada_bind_names = [];

    register("play anim", &cicada_mods::play_anim_once);
    register("nac", &nac);
    register("instaswap", &instaswap);
    register("canswap", &canswap);
    register("illusion", &illusion);
    register("empty clip", &empty_clip);
    register("one bullet", &one_bullet);
    register("pull equipment", &pull_equipment);
    register("change class", &change_class);
    register("freeze anim", &freeze_anim);
    register("third person", &third_person);
    register("bounce", &bounce);
    register("velocity", &apply_velocity);
    register("bot velocity", &apply_bot_velocity);
    register("bolt movement", &cicada_movement::play_bolt);
    register("bot bolt movement", &cicada_movement::play_bot_bolt);
    register("record movement", &cicada_movement::play_record);
    register("load class", &cicada_loadout::load_class);
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
    register("flash", &flash);
    register("shellshock", &shellshock_self);
    register("stuck", &stuck);
    register("kill bots", &kill_bots);
}

function register(name, action)
{
    level.cicada_binds[name] = action;
    level.cicada_bind_names[level.cicada_bind_names.size] = name;
}

function slot_key(slot)
{
    return "bind_slot_" + slot;
}

function assigned_bind(slot)
{
    return self cicada_util::getpers(slot_key(slot));
}

function has_bind(name, slot)
{
    assigned = self assigned_bind(slot);
    return isdefined(name) && isdefined(assigned) && assigned == name;
}

function slot_icon(slot)
{
    return "[{+actionslot " + slot + "}]";
}

function assign(name, slot)
{
    if (!isdefined(name) || !isdefined(level.cicada_binds[name]))
        return;

    if (self has_bind(name, slot))
    {
        self cicada_util::setpers(slot_key(slot), undefined);
        self cicada_util::message(slot_icon(slot) + " ^7unbound from ^:" + name);
        return;
    }

    for (i = 1; i <= 4; i++)
        if (self has_bind(name, i))
            self cicada_util::setpers(slot_key(i), undefined);

    self cicada_util::setpers(slot_key(slot), name);
    self cicada_util::message(slot_icon(slot) + " ^7bound to ^:" + name);
}

function start_monitors()
{
    for (slot = 1; slot <= 4; slot++)
        self thread [[&monitor]](slot);
}

function monitor(slot)
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + slot);

        if (self cicada_util::in_menu())
            continue;

        name = self assigned_bind(slot);
        if (!isdefined(name) || !isdefined(level.cicada_binds[name]))
            continue;

        self thread [[level.cicada_binds[name]]]();
    }
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

function pull_equipment()
{
    previous = self getcurrentweapon();
    self cicada_weapon::nacto(self cicada_util::getpers("equipment_weapon"), true);

    if (!istrue(self cicada_util::getpers("equipment_putaway")))
        return;

    wait (self cicada_util::getpersfloat("equipment_putaway_time"));
    self switchtoweapon(previous);
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
    target = self cicada_util::enemy_player();
    if (target == self)
    {
        self cicada_util::message_bold("^5spawn an enemy first");
        return;
    }

    grenade = self magicgrenademanual(self cicada_util::getpers("stuck_weapon"), self.origin, (0, 0, 0), 3);
    thread [[&weapons::grenadestuckto]](grenade, target, false);
}

function kill_bots()
{
    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_) && isalive(player_))
            player_ suicide();
}
