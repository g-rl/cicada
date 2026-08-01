#using scripts\cp_mp\utility\game_utility;
#using scripts\cp_mp\utility\inventory_utility;
#using scripts\mp\killstreaks\killstreaks;

#using custom_scripts\catalog;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_loadout;

function build(id, camo)
{
    if (!isdefined(camo))
        camo = "none";

    return scripts\cp_mp\weapon::buildweapon(id, [], camo, "none", -1, undefined, undefined, undefined, game_utility::isnightmap());
}

function give_weapon(id)
{
    weapon = build(id, self camo());

    if (!isdefined(weapon) || isnullweapon(weapon))
    {
        self cicada_util::message("^1unable to build ^7" + id);
        return;
    }

    if (self hasweapon(weapon))
    {
        self switchtoweapon(weapon);
        return;
    }

    if (istrue(self cicada_util::getpers("replace_weapon")))
        self inventory_utility::_takeweapon(self getcurrentweapon());

    self inventory_utility::_giveweapon(weapon);
    self inventory_utility::_switchtoweaponimmediate(weapon);
    self cicada_weapon::refill(weapon);
    self cicada_util::sound("ui_mp_weapon_pickup");
}

function give_equipment(id)
{
    self cicada_weapon::nacto(id, true);
}

function give_bot_shield(player_)
{
    shield = build("iw9_me_riotshield_mp");
    if (!isdefined(shield) || isnullweapon(shield))
        return;

    player_ giveweapon(shield);
    player_ switchtoweapon(shield);
}

function give_streak(name)
{
    self killstreaks::awardkillstreak(name, "other");
    self cicada_util::sound("ui_killstreak_select");
}

function camo()
{
    stored = self cicada_util::getpers("camo");
    return isdefined(stored) ? stored : "none";
}

function randomize_camo(player_)
{
    if (!isdefined(player_))
        player_ = self;

    player_ cicada_util::setpers("camo", cicada_catalog::random_camo());
    player_ apply_camo();
}

function clear_camo()
{
    self cicada_util::setpers("camo", "none");
    self cicada_util::message("camo ^1cleared");
}

// the current weapon keeps the old camo until it is re-drawn, so the stowed weapon is
// rebuilt first and the held one second.
function apply_camo()
{
    camo = self camo();
    if (camo == "none")
        return;

    self recamo(self cicada_weapon::next_weapon(), camo, false);
    self recamo(self getcurrentweapon(), camo, true);
}

function recamo(weapon, camo, do_switch)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
        return;

    root = scripts\cp_mp\weapon::getweaponrootname(weapon);
    variant = isdefined(weapon.variantid) ? weapon.variantid : -1;
    rebuilt = scripts\cp_mp\weapon::buildweapon(root, weapon.attachments, camo, "none", variant, undefined, undefined, undefined, game_utility::isnightmap());

    if (!isdefined(rebuilt) || isnullweapon(rebuilt))
        return;

    self takeweapon(weapon);
    self giveweapon(rebuilt);

    if (istrue(do_switch))
        self inventory_utility::_switchtoweaponimmediate(rebuilt);
}

function has_class()
{
    return isdefined(self.cicada_class) && self.cicada_class.size;
}

function save_class()
{
    self.cicada_class = self getweaponslistall();
    self cicada_util::message("class saved with ^:" + self.cicada_class.size + " ^7items");
    self cicada_util::sound("scavenger_pack_pickup");
}

function load_class()
{
    if (!self has_class())
    {
        self cicada_util::message_bold("^6save a class first");
        return;
    }

    self takeallweapons();

    foreach (weapon in self.cicada_class)
    {
        if (weapon.basename == "none")
            continue;

        self giveweapon(weapon);
    }

    self apply_camo();
    self inventory_utility::_switchtoweaponimmediate(self.cicada_class[0]);
}

function manage_class(action)
{
    if (action == "save")
        self save_class();
    else
        self load_class();
}

function class_count()
{
    return self has_class() ? self.cicada_class.size : 0;
}
