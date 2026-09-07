#using scripts\cp_mp\utility\game_utility;
#using scripts\cp_mp\utility\inventory_utility;
#using scripts\mp\equipment;
#using scripts\mp\killstreaks\killstreaks;
#using scripts\mp\perks\perkpackage;
#using scripts\mp\utility\perk;

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
    weapon = makeweapon(id);

    if (!isdefined(weapon) || isnullweapon(weapon))
    {
        self cicada_util::message("^1unable to build ^7" + id);
        return;
    }

    self cicada_weapon::nacto(weapon, true);
}

// scripts\mp\dev::devgivefieldupgradethink
function give_field_upgrade(ref)
{
    self scripts\mp\perks\perkpackage::perkpackage_givedebug(ref, 0);
    self cicada_util::sound("ui_killstreak_select");
}

function set_equipment(ref, slot)
{
    self scripts\mp\equipment::giveequipment(ref, slot);
    self cicada_util::sound("ui_mp_weapon_pickup");
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

function random_entry(options)
{
    if (!isdefined(options) || !options.size)
        return undefined;
    return options[randomint(options.size)];
}

function random_choice(key, options)
{
    stored = self cicada_util::getpers(key);
    if (isdefined(stored) && stored != "random")
        return stored;
    return random_entry(options);
}

function random_weapon_id(group, key)
{
    category = self random_choice(key, level.cicada_groups[group]);
    entry = random_entry(cicada_catalog::get(category));
    return isdefined(entry) ? entry.id : undefined;
}

function give_class_weapon(id)
{
    if (!isdefined(id))
        return undefined;

    weapon = build(id, self camo());
    if (!isdefined(weapon) || isnullweapon(weapon))
        return undefined;

    self inventory_utility::_giveweapon(weapon);
    self cicada_weapon::refill(weapon);

    return weapon;
}

function random_streaks()
{
    streaks = cicada_catalog::get("mp streaks");
    if (!streaks.size)
        return;

    index = randomint(streaks.size);

    for (i = 0; i < 3 && i < streaks.size; i++)
    {
        self killstreaks::awardkillstreak(streaks[index].id, "other");

        index++;
        if (index >= streaks.size)
            index = 0;

        wait 0.05;
    }

    self cicada_util::sound("ui_killstreak_select");
}

function set_random_type(value, key)
{
    self cicada_util::setpers(key, value);
    self cicada_util::message(cicada_catalog::pretty(key, "random") + " type set to ^:" + value);
}

function give_class_perks()
{
    self scripts\mp\utility\perk::giveperk("specialty_ultra_light_boots");

    if (istrue(self cicada_util::getpers("random_class_gloves")))
        self scripts\mp\utility\perk::giveperk("specialty_custom_gloves");
}

function random_class()
{
    if (istrue(self cicada_util::getpers("random_class_camo")))
        self cicada_util::setpers("camo", cicada_catalog::random_camo());

    self takeallweapons();

    primary = self give_class_weapon(self random_weapon_id("primaries", "random_primary"));
    self give_class_weapon(self random_weapon_id("secondaries", "random_secondary"));

    lethal = self random_choice("random_lethal", cicada_catalog::equipment_refs("primary"));
    if (isdefined(lethal))
        self scripts\mp\equipment::giveequipment(lethal, "primary");

    tactical = self random_choice("random_tactical", cicada_catalog::equipment_refs("secondary"));
    if (isdefined(tactical))
        self scripts\mp\equipment::giveequipment(tactical, "secondary");

    if (istrue(self cicada_util::getpers("random_class_super")))
    {
        super = random_entry(cicada_catalog::super_refs());
        if (isdefined(super))
            self scripts\mp\perks\perkpackage::perkpackage_givedebug(super, 0);
    }

    self give_class_perks();

    if (isdefined(primary))
        self inventory_utility::_switchtoweaponimmediate(primary);

    self cicada_util::sound("ui_mp_weapon_pickup");

    if (istrue(self cicada_util::getpers("random_class_streaks")))
        self random_streaks();
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
