#using scripts\cp_mp\utility\inventory_utility;
#using scripts\mp\equipment;
#using scripts\mp\perks\perkpackage;
#using scripts\mp\supers;

#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\util;
#using custom_scripts\weapon;

#namespace cicada_builds;

function private store_build_weapon(index, weapon)
{
    root = scripts\cp_mp\weapon::getweaponrootname(weapon);
    if (!isdefined(root) || root == "")
        return false;

    attachments = "";

    if (isdefined(weapon.attachments))
    {
        foreach (name in weapon.attachments)
            attachments = attachments == "" ? name : attachments + "," + name;
    }

    nengine_store_set("builds", "w" + index + "_id", root);
    nengine_store_set("builds", "w" + index + "_attachments", attachments);
    nengine_store_set("builds", "w" + index + "_variant", isdefined(weapon.variantid) ? weapon.variantid : -1);

    return true;
}

function private equipment_ref(slot)
{
    ref = self scripts\mp\equipment::getcurrentequipment(slot);
    return (isdefined(ref) && ref != "none") ? ref : "";
}

function private stored_ref(key)
{
    value = nengine_store_get("builds", key);
    return (isdefined(value) && value != "" && value != "none") ? value : undefined;
}

function private capture_build()
{
    nengine_store_clear("builds");

    stored = 0;

    foreach (weapon in self getweaponslistprimaries())
    {
        if (!isdefined(weapon) || !isdefined(weapon.basename) || weapon.basename == "none")
            continue;

        if (store_build_weapon(stored, weapon))
            stored++;
    }

    super = supers::getcurrentsuperref();

    nengine_store_set("builds", "count", stored);
    nengine_store_set("builds", "camo", self cicada_loadout::camo());
    nengine_store_set("builds", "lethal", self equipment_ref("primary"));
    nengine_store_set("builds", "tactical", self equipment_ref("secondary"));
    nengine_store_set("builds", "super", isdefined(super) ? super : "");

    return stored;
}

function private apply_build()
{
    total = nengine_store_get("builds", "count");
    if (total <= 0)
        return 0;

    camo = nengine_store_get("builds", "camo");
    if (camo != "")
        self cicada_util::setpers("camo", camo);

    self takeallweapons();

    first = undefined;
    given = 0;

    for (i = 0; i < total; i++)
    {
        id = nengine_store_get("builds", "w" + i + "_id");
        attachments = nengine_store_get("builds", "w" + i + "_attachments");
        variant = nengine_store_get("builds", "w" + i + "_variant");

        weapon = cicada_loadout::build(id, camo, attachments == "" ? [] : strtok(attachments, ","), variant);

        if (!isdefined(weapon) || isnullweapon(weapon))
            continue;

        self inventory_utility::_giveweapon(weapon);
        self cicada_weapon::refill(weapon);

        if (!isdefined(first))
            first = weapon;

        given++;
    }

    self give_build_equipment();

    if (isdefined(first))
        self inventory_utility::_switchtoweaponimmediate(first);

    return given;
}

function private give_equipment_slot(slot, key)
{
    ref = stored_ref(key);

    if (!isdefined(ref))
        return;

    self scripts\mp\equipment::giveequipment(ref, slot);

    info = scripts\mp\equipment::getequipmenttableinfo(ref);

    if (!isdefined(info) || !isdefined(info.objweapon) || isnullweapon(info.objweapon))
        return;

    self setweaponammoclip(info.objweapon, 1);
    self givemaxammo(info.objweapon);
}

function private give_build_equipment()
{
    self give_equipment_slot("primary", "lethal");
    self give_equipment_slot("secondary", "tactical");

    super = stored_ref("super");
    if (isdefined(super))
    {
        self scripts\mp\perks\perkpackage::perkpackage_givedebug(super, 0);
        self thread [[&charge_super]]();
    }

    self cicada_loadout::give_class_perks();
}

function private charge_super()
{
    self endon("disconnect");

    wait 0.05;

    if (!isdefined(supers::getcurrentsuper()))
        return;

    self thread [[&supers::givesuperpoints]](supers::getsuperpointsneeded());
}

function private free_build_name()
{
    used = [];
    total = nengine_store_list_count("builds");

    for (i = 0; i < total; i++)
        used[nengine_store_list_name("builds", i)] = true;

    for (i = 1; i <= 32; i++)
        if (!isdefined(used["build_" + i]))
            return "build_" + i;

    return undefined;
}

function build_count()
{
    return nengine_store_list_count("builds");
}

function build_at(index)
{
    if (index < 0 || index >= nengine_store_list_count("builds"))
        return undefined;
    return nengine_store_list_name("builds", index);
}

function build_default_name()
{
    name = nengine_store_default("builds");
    return name.size > 0 ? name : undefined;
}

function build_is_default(name)
{
    if (!isdefined(name) || name.size == 0)
        return false;

    return nengine_store_default("builds") == name;
}

function build_summary(name)
{
    if (!isdefined(name))
        return undefined;
    return build_is_default(name) ? "^:given on every spawn" : "^7saved build";
}

function build_save(name)
{
    if (!self capture_build())
    {
        self cicada_util::message(cicada_util::warn("nothing to save"));
        return false;
    }

    if (nengine_store_save("builds", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not save ^:" + name));
        return false;
    }

    self cicada_util::message("build ^:" + name + " ^7saved");
    self cicada_util::sound("scavenger_pack_pickup");
    return true;
}

function build_load(name)
{
    if (nengine_store_load("builds", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not load ^:" + name));
        return false;
    }

    if (!self apply_build())
    {
        self cicada_util::message(cicada_util::warn("build ^:" + name + " ^7has no usable weapons"));
        return false;
    }

    self cicada_util::message("build ^:" + name + " ^7loaded");
    self cicada_util::sound("ui_mp_weapon_pickup");
    return true;
}

function spawn_apply()
{
    name = build_default_name();
    if (!isdefined(name))
        return false;

    if (nengine_store_load("builds", name) != 1)
        return false;

    return self apply_build() > 0;
}

function new_build()
{
    name = free_build_name();

    if (!isdefined(name))
    {
        self cicada_util::message(cicada_util::warn("no free build slots"));
        return;
    }

    self build_save(name);
    self cicada_menu::update_menu();
}

function save_over_build()
{
    if (!isdefined(self.select_build))
        return;

    self build_save(self.select_build);
    self cicada_menu::update_menu();
}

function give_build()
{
    if (!isdefined(self.select_build))
        return;

    self build_load(self.select_build);
    self cicada_menu::update_menu();
}

function toggle_build_default()
{
    if (!isdefined(self.select_build))
        return;

    name = build_is_default(self.select_build) ? "" : self.select_build;

    if (nengine_store_set_default("builds", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not change the default build"));
        return;
    }

    self cicada_util::message(name == "" ? "default build cleared" : ("build ^:" + name + " ^7set as default"));
    self cicada_menu::update_menu();
}

function delete_build()
{
    if (!isdefined(self.select_build))
        return;

    if (nengine_store_delete("builds", self.select_build) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not delete ^:" + self.select_build));
        return;
    }

    self cicada_util::message("build ^:" + self.select_build + " ^7deleted");
    self.select_build = undefined;
    self cicada_menu::new_menu();
}
