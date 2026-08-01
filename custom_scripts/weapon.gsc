#using scripts\cp_mp\utility\inventory_utility;

#namespace cicada_weapon;

function is_swappable(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return false;

    basename = weapon.basename;
    return !issubstr(basename, "knifestab") && !issubstr(basename, "diveknife") && !issubstr(basename, "climbfists");
}

function swappable_weapons()
{
    weapons = [];

    foreach (weapon in self inventory_utility::getcurrentprimaryweaponsminusalt())
        if (is_swappable(weapon))
            weapons[weapons.size] = weapon;

    return weapons;
}

function next_weapon()
{
    return self neighbour_weapon(1);
}

function previous_weapon()
{
    return self neighbour_weapon(-1);
}

function neighbour_weapon(step)
{
    weapons = self swappable_weapons();
    if (!weapons.size)
        return undefined;

    current = self getcurrentweapon();

    for (i = 0; i < weapons.size; i++)
    {
        if (current != weapons[i])
            continue;

        index = (i + step);
        if (index >= weapons.size)
            index = 0;
        if (index < 0)
            index = (weapons.size - 1);

        return weapons[index];
    }

    return weapons[0];
}

function stash_weapon(weapon)
{
    self.stashed_weapon = weapon;
    self.stashed_clip = self getweaponammoclip(weapon);
    self.stashed_stock = self getweaponammostock(weapon);
    self takeweapon(weapon);
}

function restore_weapon()
{
    if (!isdefined(self.stashed_weapon))
        return;

    self giveweapon(self.stashed_weapon);
    self setweaponammoclip(self.stashed_weapon, self.stashed_clip);
    self setweaponammostock(self.stashed_weapon, self.stashed_stock);
}

function nacto(weapon, do_wait)
{
    if (!isdefined(weapon))
        return;

    current = self getcurrentweapon();

    self stash_weapon(current);
    if (!self hasweapon(weapon))
        self giveweapon(weapon);

    self switchtoweapon(weapon);

    if (istrue(do_wait))
        wait 0.05;

    self restore_weapon();
}

function instaswapto(weapon)
{
    if (!isdefined(weapon))
        return;

    current = self getcurrentweapon();

    self stash_weapon(current);
    if (!self hasweapon(weapon))
        self giveweapon(weapon);

    self setspawnweapon(weapon);
    wait 0.05;
    self restore_weapon();
}

function switchto(weapon)
{
    if (!isdefined(weapon))
        return;

    current = self getcurrentweapon();

    self stash_weapon(current);
    self switchtoweapon(weapon);
    wait 0.05;
    self restore_weapon();
}

function canswap()
{
    current = self getcurrentweapon();

    self stash_weapon(current);
    self restore_weapon();
    self switchtoweapon(current);
}

function illusion()
{
    self setspawnweapon(self getcurrentweapon());
}

function empty_clip()
{
    self setweaponammoclip(self getcurrentweapon(), 0);
}

function one_bullet()
{
    self setweaponammoclip(self getcurrentweapon(), 1);
}

function refill(weapon)
{
    self setweaponammoclip(weapon, 999);
    self setweaponammostock(weapon, 999);
}

function is_ads_weapon(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.basename))
        return false;

    weapon_class = weaponclass(weapon);
    if (weapon_class == "sniper" || weapon_class == "dmr")
        return true;

    return issubstr(weapon.basename, "throwingknife");
}
