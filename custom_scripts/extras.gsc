#using scripts\engine\utility;

#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\util;

#namespace cicada_extras;

function max_ammo()
{
    if (!isalive(self))
        return;

    foreach (weapon in self getweaponslistall())
    {
        if (!isdefined(weapon) || isnullweapon(weapon))
            continue;

        self givemaxammo(weapon);
        self setweaponammoclip(weapon, weaponclipsize(weapon));
    }

    self cicada_util::message("^2max ammo");
    self cicada_util::sound("ui_mp_suitcase_pickup");
}

function fill_clip()
{
    if (!isalive(self))
        return;

    weapon = self getcurrentweapon();

    if (!isdefined(weapon) || isnullweapon(weapon))
        return;

    self setweaponammoclip(weapon, weaponclipsize(weapon));
    self cicada_util::sound("ui_mp_suitcase_pickup");
}
