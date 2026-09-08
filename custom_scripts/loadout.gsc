#using scripts\cp_mp\utility\game_utility;
#using scripts\cp_mp\utility\inventory_utility;
#using scripts\mp\equipment;
#using scripts\mp\utility\game;
#using scripts\mp\killstreaks\killstreaks;
#using scripts\mp\perks\perkpackage;
#using scripts\mp\utility\perk;

#using custom_scripts\catalog;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_loadout;

function build(id, camo, attachments, variantid)
{
    if (!isdefined(camo))
        camo = "none";

    if (!isdefined(attachments))
        attachments = [];

    if (!isdefined(variantid))
        variantid = -1;

    return scripts\cp_mp\weapon::buildweapon(id, attachments, camo, "none", variantid, undefined, undefined, undefined, game_utility::isnightmap());
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

// level.weaponlootmapdata is keyed "<root>|<variantid>" by scripts\cp_mp\weapon
function blueprint_id(id)
{
    if (!istrue(self cicada_util::getpers("random_class_blueprints")))
        return -1;

    if (!isdefined(level.weaponlootmapdata))
        return -1;

    variants = [];

    foreach (key, data in level.weaponlootmapdata)
    {
        parts = strtok(key, "|");

        if (parts.size != 2 || parts[0] != id)
            continue;

        if (!isdefined(data.variantid) || data.variantid <= 0)
            continue;

        variants[variants.size] = data.variantid;
    }

    if (!variants.size)
        return -1;

    return variants[randomint(variants.size)];
}

function attachment_names(weapon, slot)
{
    names = [];

    foreach (name, lootid in level.weaponattachments)
    {
        if (!cicada_catalog::in_slot(name, slot))
            continue;

        if (!weapon canuseattachment(name))
            continue;

        names[names.size] = name;
    }

    return names;
}

function random_attachments(id, category)
{
    if (!istrue(self cicada_util::getpers("random_class_attachments")))
        return [];

    if (!isdefined(level.weaponattachments))
        return [];

    base = build(id);

    if (!isdefined(base) || isnullweapon(base))
        return [];

    picked = [];
    foreach (entry in cicada_catalog::attachment_odds(category))
    {
        if (picked.size >= 5)
            break;

        if (randomint(100) >= entry.chance)
            continue;

        name = random_entry(attachment_names(base, entry.slot));

        if (isdefined(name))
            picked[picked.size] = name;
    }
    return picked;
}

function give_class_weapon(id, category)
{
    if (!isdefined(id))
        return undefined;

    weapon = build(id, self camo(), self random_attachments(id, category), self blueprint_id(id));
    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = build(id, self camo());

    if (!isdefined(weapon) || isnullweapon(weapon))
        return undefined;

    self inventory_utility::_giveweapon(weapon);
    self cicada_weapon::refill(weapon);

    return weapon;
}

function random_class_weapon(group, key)
{
    category = self random_choice(key, level.cicada_groups[group]);
    entry = random_entry(cicada_catalog::get(category));

    if (!isdefined(entry))
        return undefined;

    return self give_class_weapon(entry.id, category);
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

    weapons = [];

    primary = self random_class_weapon("primaries", "random_primary");
    if (isdefined(primary))
        weapons[weapons.size] = primary;

    secondary = self random_class_weapon("secondaries", "random_secondary");
    if (isdefined(secondary))
        weapons[weapons.size] = secondary;

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
    self store_random_class(weapons, primary, lethal, tactical);

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

function store_random_class(weapons, primary, lethal, tactical)
{
    stored = spawnstruct();
    stored.weapons = weapons;
    stored.primary = primary;
    stored.lethal = lethal;
    stored.tactical = tactical;
    stored.camo = self camo();
    self.cicada_random_class = stored;
}

function load_random_class()
{
    stored = self.cicada_random_class;

    self cicada_util::setpers("camo", stored.camo);
    self takeallweapons();

    foreach (weapon in stored.weapons)
    {
        self inventory_utility::_giveweapon(weapon);
        self cicada_weapon::refill(weapon);
    }

    if (isdefined(stored.lethal))
        self scripts\mp\equipment::giveequipment(stored.lethal, "primary");

    if (isdefined(stored.tactical))
        self scripts\mp\equipment::giveequipment(stored.tactical, "secondary");

    self give_class_perks();

    if (isdefined(stored.primary))
        self inventory_utility::_switchtoweaponimmediate(stored.primary);
}

function spawn_class()
{
    if (!istrue(self cicada_util::getpers("random_class_auto")))
        return;

    if (isdefined(self.cicada_random_class) && scripts\mp\utility\game::getbasegametype() != "dm")
    {
        self load_random_class();
        return;
    }

    self random_class();
}
