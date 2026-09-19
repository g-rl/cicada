#using scripts\cp_mp\utility\game_utility;
#using scripts\cp_mp\utility\inventory_utility;
#using scripts\mp\equipment;
#using scripts\mp\utility\game;
#using scripts\mp\killstreaks\killstreaks;
#using scripts\mp\perks\perkpackage;
#using scripts\mp\supers;
#using scripts\mp\utility\perk;

#using custom_scripts\menu;
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
    if (!isdefined(id))
        return;

    self give_built(build(id, self camo()), id);
}

function give_built(weapon, id)
{
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
    self thread [[&autosave_class]]();
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
    self thread [[&autosave_class]]();
}

function give_field_upgrade(ref)
{
    self.cicada_super_ref = ref;
    self scripts\mp\perks\perkpackage::perkpackage_givedebug(ref, 0);
    self cicada_util::sound("ui_killstreak_select");
    self thread [[&autosave_class]]();
}

function use_field_upgrade(ref)
{
    self give_field_upgrade(ref);

    wait 0.25;

    super = supers::getcurrentsuper();
    if (!isdefined(super) || !isdefined(super.weaponobj))
        return;

    self supers::givesuperweapon(super);
    self supers::givesuperpoints(supers::getsuperpointsneeded());

    wait 0.05;

    self notify("special_weapon_fired", super.weaponobj);

    wait 0.1;

    if (!self supers::issuperinuse())
        self supers::beginsuperuse();
}

function set_equipment(ref, slot)
{
    self scripts\mp\equipment::giveequipment(ref, slot);
    self cicada_util::sound("ui_mp_weapon_pickup");
    self thread [[&autosave_class]]();
}

function no_equipment(slot)
{
    key = (slot == "primary") ? "no_lethal" : "no_tactical";

    return istrue(self cicada_util::getpers(key));
}

function strip_equipment()
{
    if (self no_equipment("primary"))
        self scripts\mp\equipment::takeequipment("primary");

    if (self no_equipment("secondary"))
        self scripts\mp\equipment::takeequipment("secondary");
}

function watch_equipment()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        if (isalive(self))
            self strip_equipment();

        wait 0.5;
    }
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

function set_camo(id)
{
    self cicada_util::setpers("camo", id);
    self apply_camo();
    self cicada_util::message("camo set to ^:" + cicada_catalog::pretty(id, "camo"));
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

function pick_id(option)
{
    if (isstruct(option) && isdefined(option.id))
        return option.id;

    return option;
}

function last_pick(key)
{
    if (!isdefined(self.cicada_last_random))
        return undefined;

    return self.cicada_last_random[key];
}

function store_pick(key, option)
{
    if (!isdefined(self.cicada_last_random))
        self.cicada_last_random = [];

    self.cicada_last_random[key] = pick_id(option);
}

function fresh_entry(key, options)
{
    if (!isdefined(options) || !options.size)
        return undefined;

    last = self last_pick(key);
    picks = [];

    if (isdefined(last) && istrue(self cicada_util::getpers("random_class_unique")))
        foreach (option in options)
            if (pick_id(option) != last)
                picks[picks.size] = option;

    picked = picks.size ? random_entry(picks) : random_entry(options);

    self store_pick(key, picked);

    return picked;
}

function fresh_choice(key, options)
{
    stored = self cicada_util::getpers(key);

    if (isdefined(stored) && stored != "random")
        return stored;

    return self fresh_entry(key, options);
}

function random_choice(key, options)
{
    stored = self cicada_util::getpers(key);
    if (isdefined(stored) && stored != "random")
        return stored;
    return random_entry(options);
}

// keyed: "<root>|<variantid>" - scripts\cp_mp\weapon
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

function weapon_root(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return undefined;

    return scripts\cp_mp\weapon::getweaponrootname(weapon);
}

function held_weapons()
{
    list = [];

    foreach (weapon in self getweaponslistprimaries())
    {
        if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
            continue;

        list[list.size] = weapon;
    }

    return list;
}

function carried_weapons()
{
    list = [];

    foreach (weapon in self getweaponslistall())
    {
        if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
            continue;

        list[list.size] = weapon;
    }

    return list;
}

function private was_carried(before, weapon)
{
    foreach (held in before)
        if (held == weapon)
            return true;

    return false;
}

function take_new_weapons(before, keep)
{
    foreach (weapon in self carried_weapons())
        if (!was_carried(before, weapon))
            self inventory_utility::_takeweapon(weapon);

    if (isdefined(keep) && !isnullweapon(keep) && self hasweapon(keep))
        self inventory_utility::_switchtoweaponimmediate(keep);
}

function editable_weapons()
{
    list = [];

    foreach (weapon in self held_weapons())
        if (weapon_slots(weapon).size)
            list[list.size] = weapon;

    return list;
}

function editable_at(index)
{
    list = self editable_weapons();

    if (index < 0 || index >= list.size)
        return undefined;

    return weapon_root(list[index]);
}

function held_at(index)
{
    list = self held_weapons();

    if (index < 0 || index >= list.size)
        return undefined;

    return weapon_root(list[index]);
}

function weapon_by_root(root)
{
    if (!isdefined(root))
        return undefined;

    foreach (weapon in self getweaponslistall())
    {
        if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
            continue;

        if (weapon_root(weapon) == root)
            return weapon;
    }

    return undefined;
}

function weapon_label(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return "none";

    return cicada_util::shorten(cicada_catalog::pretty(weapon_root(weapon), "weapon"), 22);
}

function attachment_label(root, name)
{
    if (!isdefined(name))
        return "none";

    text = name;

    if (isdefined(root) && isstartstr(text, root + "_"))
        text = cicada_util::trim_start(text, root + "_");

    return cicada_util::shorten(text, 24);
}

function fitted_attachments(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.attachments))
        return [];

    return weapon.attachments;
}

function fitted_count(root)
{
    return fitted_attachments(self weapon_by_root(root)).size;
}

function slot_current(weapon, slot)
{
    foreach (name in fitted_attachments(weapon))
        if (cicada_catalog::slot_of(name) == slot)
            return name;

    return undefined;
}

function slot_summary(root, slot)
{
    weapon = self weapon_by_root(root);
    name = slot_current(weapon, slot);

    if (!isdefined(name))
        return "^1empty";

    return "^:" + attachment_label(root, name);
}

function weapon_slots(weapon)
{
    ordered = [];

    if (!isdefined(weapon) || !isdefined(level.weaponattachments))
        return ordered;

    found = [];

    foreach (name, lootid in level.weaponattachments)
    {
        if (!weapon canuseattachment(name))
            continue;

        found[cicada_catalog::slot_of(name)] = true;
    }

    foreach (slot in cicada_catalog::slot_names())
        if (isdefined(found[slot]))
            ordered[ordered.size] = slot;

    return ordered;
}

function slot_at(root, index)
{
    slots = weapon_slots(self weapon_by_root(root));

    if (index < 0 || index >= slots.size)
        return undefined;

    return slots[index];
}

function slot_count(root)
{
    return weapon_slots(self weapon_by_root(root)).size;
}

function attachments_in_slot(weapon, slot)
{
    names = [];

    if (!isdefined(weapon) || !isdefined(level.weaponattachments))
        return names;

    foreach (name, lootid in level.weaponattachments)
    {
        if (cicada_catalog::slot_of(name) != slot)
            continue;

        if (!weapon canuseattachment(name))
            continue;

        names[names.size] = name;
    }

    return names;
}

function slot_options(root, slot)
{
    return attachments_in_slot(self weapon_by_root(root), slot);
}

function rebuild_with(weapon, attachments)
{
    root = weapon_root(weapon);
    variant = isdefined(weapon.variantid) ? weapon.variantid : -1;
    holding = self getcurrentweapon() == weapon;

    rebuilt = scripts\cp_mp\weapon::buildweapon(root, attachments, self camo(), "none", variant, undefined, undefined, undefined, game_utility::isnightmap());

    if (!isdefined(rebuilt) || isnullweapon(rebuilt))
    {
        self cicada_util::message(cicada_util::warn("that mix is not valid"));
        return false;
    }

    self inventory_utility::_takeweapon(weapon);
    self inventory_utility::_giveweapon(rebuilt);

    if (holding)
        self inventory_utility::_switchtoweaponimmediate(rebuilt);

    self thread [[&autosave_class]]();

    return true;
}

function private without_slot(weapon, slot)
{
    list = [];

    foreach (name in fitted_attachments(weapon))
        if (cicada_catalog::slot_of(name) != slot)
            list[list.size] = name;

    return list;
}

function set_attachment(name, root, slot)
{
    weapon = self weapon_by_root(root);

    if (!isdefined(weapon))
    {
        self cicada_util::message(cicada_util::warn("that weapon is gone"));
        return;
    }

    list = without_slot(weapon, slot);

    if (isdefined(name))
        list[list.size] = name;

    if (self rebuild_with(weapon, list))
        self cicada_util::message(isdefined(name) ? ("^:" + attachment_label(root, name) + " ^7fitted") : ("^:" + slot + " ^7cleared"));

    self cicada_menu::update_menu();
}

function clear_slot(root, slot)
{
    self set_attachment(undefined, root, slot);
}

function clear_attachments(root)
{
    weapon = self weapon_by_root(root);

    if (!isdefined(weapon))
        return;

    if (self rebuild_with(weapon, []))
        self cicada_util::message("attachments ^1cleared");

    self cicada_menu::update_menu();
}

function randomize_weapon_attachments(root)
{
    weapon = self weapon_by_root(root);

    if (!isdefined(weapon))
        return;

    picked = [];

    foreach (slot in weapon_slots(weapon))
    {
        if (picked.size >= 5)
            break;

        if (randomint(100) >= 50)
            continue;

        names = attachments_in_slot(weapon, slot);

        if (!names.size)
            continue;

        picked[picked.size] = names[randomint(names.size)];
    }

    if (self rebuild_with(weapon, picked))
        self cicada_util::message("^:" + picked.size + " ^7attachments rolled");

    self cicada_menu::update_menu();
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

function blueprints(ref)
{
    list = [];

    if (!isdefined(ref) || !isdefined(level.weaponlootmapdata))
        return list;

    foreach (key, data in level.weaponlootmapdata)
    {
        parts = strtok(key, "|");

        if (parts.size != 2 || parts[0] != ref)
            continue;

        if (!isdefined(data.variantid) || data.variantid <= 0)
            continue;

        list[list.size] = data.variantid;
    }

    return list;
}

function give_blueprint(ref, variantid)
{
    weapon = build(ref, self camo(), self.cicada_build, variantid);

    if (!isdefined(weapon) || isnullweapon(weapon))
        weapon = build(ref, self camo(), undefined, variantid);

    self give_built(weapon, ref);
}

function reset_build(ref)
{
    if (isdefined(self.cicada_build_ref) && self.cicada_build_ref == ref && isdefined(self.cicada_build))
        return;

    self.cicada_build_ref = ref;
    self.cicada_build = [];
}

function build_count()
{
    if (!isdefined(self.cicada_build))
        return 0;

    return self.cicada_build.size;
}

function build_weapon()
{
    if (!isdefined(self.cicada_build_ref))
        return undefined;

    return build(self.cicada_build_ref, self camo(), self.cicada_build);
}

function build_slots()
{
    return weapon_slots(self build_weapon());
}

function build_slot_at(index)
{
    slots = self build_slots();

    if (index < 0 || index >= slots.size)
        return undefined;

    return slots[index];
}

function build_slot_current(slot)
{
    if (!isdefined(self.cicada_build))
        return undefined;

    foreach (name in self.cicada_build)
        if (cicada_catalog::slot_of(name) == slot)
            return name;

    return undefined;
}

function build_slot_summary(slot)
{
    name = self build_slot_current(slot);

    if (!isdefined(name))
        return "^1empty";

    return "^:" + attachment_label(self.cicada_build_ref, name);
}

function build_slot_options(slot)
{
    return attachments_in_slot(self build_weapon(), slot);
}

function private build_without_slot(slot)
{
    list = [];

    if (!isdefined(self.cicada_build))
        return list;

    foreach (name in self.cicada_build)
        if (cicada_catalog::slot_of(name) != slot)
            list[list.size] = name;

    return list;
}

function set_build_attachment(name, slot)
{
    if (!isdefined(self.cicada_build_ref))
        return;

    list = self build_without_slot(slot);

    if (isdefined(name))
        list[list.size] = name;

    weapon = build(self.cicada_build_ref, self camo(), list);

    if (!isdefined(weapon) || isnullweapon(weapon))
    {
        self cicada_util::message(cicada_util::warn("that mix is not valid"));
        return;
    }

    self.cicada_build = list;
    self cicada_util::message(isdefined(name) ? ("^:" + attachment_label(self.cicada_build_ref, name) + " ^7fitted") : ("^:" + slot + " ^7cleared"));
    self cicada_menu::update_menu();
}

function clear_build_slot(slot)
{
    self set_build_attachment(undefined, slot);
}

function clear_build()
{
    self.cicada_build = [];
    self cicada_util::message("attachments ^1cleared");
    self cicada_menu::update_menu();
}

function randomize_build()
{
    if (!isdefined(self.cicada_build_ref))
        return;

    list = [];

    foreach (slot in self build_slots())
    {
        if (list.size >= 5 || randomint(100) >= 45)
            continue;

        options = attachments_in_slot(build(self.cicada_build_ref, self camo(), list), slot);

        if (!options.size)
            continue;

        mix = list;
        mix[mix.size] = options[randomint(options.size)];

        weapon = build(self.cicada_build_ref, self camo(), mix);

        if (isdefined(weapon) && !isnullweapon(weapon))
            list = mix;
    }

    self.cicada_build = list;
    self cicada_util::message("^:" + list.size + " ^7attachments rolled");
    self cicada_menu::update_menu();
}

function give_build()
{
    if (!isdefined(self.cicada_build_ref))
        return;

    self give_built(self build_weapon(), self.cicada_build_ref);
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
    entry = self fresh_entry(key + "_weapon", cicada_catalog::get(category));

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
        self cicada_util::setpers("camo", self fresh_entry("random_camo", level.cicada_camos));

    self takeallweapons();

    weapons = [];

    primary = self random_class_weapon("primaries", "random_primary");
    if (isdefined(primary))
        weapons[weapons.size] = primary;

    secondary = self random_class_weapon("secondaries", "random_secondary");
    if (isdefined(secondary))
        weapons[weapons.size] = secondary;

    lethal = self fresh_choice("random_lethal", cicada_catalog::equipment_refs("primary"));
    if (isdefined(lethal) && !self no_equipment("primary"))
        self scripts\mp\equipment::giveequipment(lethal, "primary");

    tactical = self fresh_choice("random_tactical", cicada_catalog::equipment_refs("secondary"));
    if (isdefined(tactical) && !self no_equipment("secondary"))
        self scripts\mp\equipment::giveequipment(tactical, "secondary");

    if (istrue(self cicada_util::getpers("random_class_super")))
    {
        super = self fresh_entry("random_super", cicada_catalog::super_refs());
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

function class_key()
{
    if (!isdefined(self.pers) || !isdefined(self.pers["class"]))
        return "none";

    return self.pers["class"];
}

function class_saved(key)
{
    if (!isdefined(self.cicada_class_saves) || !isdefined(self.cicada_class_saves[key]))
        return undefined;

    return self.cicada_class_saves[key];
}

function class_save_count()
{
    if (!isdefined(self.cicada_class_saves))
        return 0;

    total = 0;

    foreach (key, stored in self.cicada_class_saves)
        total++;

    return total;
}

function class_autosave_on()
{
    return istrue(self cicada_util::getpers("class_autosave"));
}

function save_class_state()
{
    if (!self class_autosave_on() || istrue(self.cicada_class_loading) || !isalive(self))
        return;

    stored = spawnstruct();
    stored.weapons = self held_weapons();
    stored.current = self getcurrentweapon();
    stored.lethal = self scripts\mp\equipment::getcurrentequipment("primary");
    stored.tactical = self scripts\mp\equipment::getcurrentequipment("secondary");
    stored.super = self.cicada_super_ref;

    if (!isdefined(self.cicada_class_saves))
        self.cicada_class_saves = [];

    self.cicada_class_saves[self class_key()] = stored;
}

function autosave_class()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!self class_autosave_on())
        return;

    self notify("cicada_class_autosave");
    self endon("cicada_class_autosave");

    wait 0.25;

    self save_class_state();
}

function load_class_state()
{
    if (!self class_autosave_on())
        return;

    stored = self class_saved(self class_key());

    if (!isdefined(stored))
        return;

    self.cicada_class_loading = 1;

    foreach (weapon in self held_weapons())
        if (!was_carried(stored.weapons, weapon))
            self inventory_utility::_takeweapon(weapon);

    foreach (weapon in stored.weapons)
    {
        if (!isdefined(weapon) || isnullweapon(weapon) || weapon.basename == "none" || self hasweapon(weapon))
            continue;

        self inventory_utility::_giveweapon(weapon);
        self cicada_weapon::refill(weapon);
    }

    if (isdefined(stored.lethal) && !self no_equipment("primary") && self scripts\mp\equipment::getcurrentequipment("primary") != stored.lethal)
        self scripts\mp\equipment::giveequipment(stored.lethal, "primary");

    if (isdefined(stored.tactical) && !self no_equipment("secondary") && self scripts\mp\equipment::getcurrentequipment("secondary") != stored.tactical)
        self scripts\mp\equipment::giveequipment(stored.tactical, "secondary");

    if (isdefined(stored.super))
        self give_field_upgrade(stored.super);

    self apply_camo();

    if (isdefined(stored.current) && !isnullweapon(stored.current) && self hasweapon(stored.current))
        self inventory_utility::_switchtoweaponimmediate(stored.current);
    else if (stored.weapons.size)
        self inventory_utility::_switchtoweaponimmediate(stored.weapons[0]);

    self.cicada_class_loading = undefined;
}

function clear_class_states()
{
    self.cicada_class_saves = [];
    self cicada_util::message("class saves ^1cleared");
    self cicada_menu::update_menu();
}

function class_state_summary()
{
    stored = self class_saved(self class_key());

    if (!isdefined(stored))
        return "^:" + self class_save_count() + " ^7classes saved";

    return "^:" + stored.weapons.size + " ^7items on this class";
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

    if (isdefined(stored.lethal) && !self no_equipment("primary"))
        self scripts\mp\equipment::giveequipment(stored.lethal, "primary");

    if (isdefined(stored.tactical) && !self no_equipment("secondary"))
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
