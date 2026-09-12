#using custom_scripts\binds;
#using custom_scripts\catalog;
#using custom_scripts\mechanics;
#using custom_scripts\loadout;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\util;

#namespace cicada_afterhits;

function enabled()
{
    return istrue(self cicada_util::getpers("after_on"));
}

function delay_options()
{
    return cicada_util::list("0,0.1,0.25,0.5,0.75,1,1.5,2,3,5");
}

function delay_now()
{
    return self cicada_util::getpersfloat("after_delay");
}

function private part_on(key)
{
    return istrue(self cicada_util::getpers("after_" + key));
}

function part_count()
{
    total = 0;

    foreach (name in part_names())
        if (self part_on(name + "_on"))
            total++;

    return total;
}

function summary()
{
    if (!self enabled())
        return "^1off";

    wait_for = self delay_now();

    if (wait_for > 0)
        return "^:" + wait_for + "s ^7wait";

    return "^:" + (self part_count() + self extra_count()) + " ^7set";
}

function weapon_id()
{
    id = self cicada_util::getpers("after_weapon");

    return isdefined(id) ? id : "none";
}

function weapon_summary()
{
    id = self weapon_id();

    if (id == "none")
        return "^1nothing picked";

    return "^:" + cicada_catalog::label(id);
}

function set_weapon(id)
{
    self cicada_util::setpers("after_weapon", id);
    self cicada_util::message("afterhits weapon ^:" + cicada_catalog::label(id));
    self cicada_menu::update_menu();
}

function set_held_weapon()
{
    weapon = self getcurrentweapon();

    if (!isdefined(weapon) || isnullweapon(weapon))
    {
        self cicada_util::message(cicada_util::warn("hold the weapon you want"));
        return;
    }

    self set_weapon(cicada_loadout::weapon_root(weapon));
}

function clear_weapon()
{
    self cicada_util::setpers("after_weapon", "none");
    self cicada_util::message("afterhits weapon ^1cleared");
    self cicada_menu::update_menu();
}

function equipment_id()
{
    id = self cicada_util::getpers("after_equipment");

    return isdefined(id) ? id : "none";
}

function equipment_summary()
{
    id = self equipment_id();

    if (id == "none")
        return "^1nothing picked";

    return "^:" + cicada_catalog::label(id);
}

function set_equipment(id)
{
    self cicada_util::setpers("after_equipment", id);
    self cicada_util::message("afterhits equipment ^:" + cicada_catalog::label(id));
    self cicada_menu::update_menu();
}

function streak_id()
{
    id = self cicada_util::getpers("after_streak");

    return isdefined(id) ? id : "none";
}

function streak_summary()
{
    id = self streak_id();

    if (id == "none")
        return "^1nothing picked";

    return "^:" + id;
}

function set_streak(id)
{
    self cicada_util::setpers("after_streak", id);
    self cicada_util::message("afterhits support ^:" + id);
    self cicada_menu::update_menu();
}

function anim_summary()
{
    if (!self part_on("anim_on"))
        return "^1off";

    if (istrue(self cicada_util::getpers("after_anim_random")))
        return self cicada_mods::anim_range_summary("after_anim_random", "after_anim_range", "after_anim_min", "after_anim_max");

    return "^:anim " + self cicada_util::getpersint("after_anim_id");
}

function anim_id()
{
    return self cicada_mods::anim_pick("after_anim_id", "after_anim_random", "after_anim_range", "after_anim_min", "after_anim_max");
}

function preview_anim(id)
{
    self cicada_mods::play_anim_once(id, self cicada_util::getpers("after_anim_hands") == "both");
}

function spot_offset()
{
    return (self cicada_util::getpersint("after_x"), self cicada_util::getpersint("after_y"), self cicada_util::getpersint("after_z"));
}

function has_spot()
{
    return isdefined(self cicada_util::getmappers("after_spot"));
}

function spot_summary()
{
    if (!self has_spot())
        return "^1no spot saved";

    spot = self cicada_util::getmappers("after_spot");

    return "^:" + int(spot[0]) + " ^7/ ^:" + int(spot[1]) + " ^7/ ^:" + int(spot[2]);
}

function save_spot()
{
    if (!isalive(self))
        return;

    self cicada_util::setmappers("after_spot", self.origin);
    self cicada_util::setmappers("after_look", self getplayerangles());
    self cicada_util::message("afterhits spot ^2saved");
    self cicada_menu::update_menu();
}

function clear_spot()
{
    self cicada_util::setmappers("after_spot", undefined);
    self cicada_util::setmappers("after_look", undefined);
    self cicada_util::message("afterhits spot ^1cleared");
    self cicada_menu::update_menu();
}

function go_to_spot()
{
    if (!self has_spot() || !isalive(self))
        return;

    spot = self cicada_util::getmappers("after_spot") + self spot_offset();
    look = self cicada_util::getmappers("after_look");

    self setorigin(spot);

    if (isdefined(look))
        self setplayerangles(look);
}

function effect_spot()
{
    if (istrue(self cicada_util::getpers("after_effect_here")))
        return self.origin + self spot_offset();

    return self.origin + (0, 0, self cicada_util::getpersint("after_effect_lift"));
}

function extra_names()
{
    return cicada_util::list("canswap,instaswap,nac,instant tac,pull equipment,empty clip,one bullet,illusion,freeze anim,smooth anim,play gesture,third person,vision,flash,shellshock,damage,knockback,velocity,bounce,parachute");
}

function extra_key(name)
{
    return "after_do_" + name;
}

function extra_on(name)
{
    return istrue(self cicada_util::getpers(extra_key(name)));
}

function flip_extra(name)
{
    self cicada_util::setpers(extra_key(name), !self extra_on(name));
    self cicada_menu::update_menu();
}

function extra_count()
{
    total = 0;

    foreach (name in extra_names())
        if (self extra_on(name))
            total++;

    return total;
}

function clear_extras()
{
    foreach (name in extra_names())
        self cicada_util::setpers(extra_key(name), false);

    self cicada_util::message("afterhits extras ^1cleared");
    self cicada_menu::update_menu();
}

function extra_delay_key(name)
{
    return "after_do_" + name + "_delay";
}

function extra_delay(name)
{
    return self cicada_util::getpersfloat(extra_delay_key(name));
}

function extra_delay_summary(name)
{
    wait_for = self extra_delay(name);

    if (wait_for <= 0)
        return "^7fires right away";

    return "^:" + wait_for + "s ^7after the end";
}

function run_extra(name)
{
    self endon("disconnect");

    switch (name)
    {
        case "canswap":
            self cicada_binds::canswap();
            return;

        case "instaswap":
            self cicada_binds::instaswap();
            return;

        case "nac":
            self cicada_binds::nac();
            return;

        case "instant tac":
            self cicada_binds::instant_tac();
            return;

        case "pull equipment":
            self cicada_binds::pull_equipment();
            return;

        case "empty clip":
            self cicada_binds::empty_clip();
            return;

        case "one bullet":
            self cicada_binds::one_bullet();
            return;

        case "illusion":
            self cicada_binds::illusion();
            return;

        case "freeze anim":
            self cicada_binds::freeze_anim();
            return;

        case "smooth anim":
            self cicada_binds::smooth_anim();
            return;

        case "play gesture":
            self cicada_mods::play_gesture_once();
            return;

        case "third person":
            self cicada_binds::third_person();
            return;

        case "vision":
            self cicada_mods::toggle_vision();
            return;

        case "flash":
            self cicada_binds::flash();
            return;

        case "shellshock":
            self cicada_binds::shellshock_self();
            return;

        case "damage":
            self cicada_binds::self_damage();
            return;

        case "knockback":
            self cicada_mods::knockback_push();
            return;

        case "velocity":
            self cicada_binds::apply_velocity();
            return;

        case "bounce":
            self cicada_binds::bounce();
            return;

        case "parachute":
            self cicada_mechanics::chute_open();
            return;
    }
}

function part_names()
{
    return cicada_util::list("spot,weapon,equipment,streak,effect,sound,anim");
}

function part_label(name)
{
    switch (name)
    {
        case "spot":
            return "move to spot";

        case "streak":
            return "give support";

        case "effect":
            return "play effects";

        case "sound":
            return "play sounds";

        case "anim":
            return "play anim";
    }

    return "pull " + name;
}

function part_choice(name)
{
    switch (name)
    {
        case "spot":
            return "choose spot";

        case "streak":
            return "choose support";

        case "effect":
            return "choose effects";

        case "sound":
            return "choose sounds";

        case "anim":
            return "choose anim";
    }

    return "choose " + name;
}

function part_delay_key(name)
{
    return "after_" + name + "_delay";
}

function part_delay(name)
{
    return self cicada_util::getpersfloat(part_delay_key(name));
}

function private do_part(name)
{
    switch (name)
    {
        case "spot":
            self go_to_spot();
            return;

        case "weapon":
            if (self weapon_id() != "none")
                self cicada_loadout::give_weapon(self weapon_id());
            return;

        case "equipment":
            if (self equipment_id() != "none")
                self cicada_loadout::give_equipment(self equipment_id());
            return;

        case "streak":
            if (self streak_id() != "none")
                self cicada_loadout::give_streak(self streak_id());
            return;

        case "effect":
            self cicada_mods::play_stack("after_effect", self effect_spot());
            return;

        case "sound":
            self cicada_mods::play_sound_stack("after_sound");
            return;

        case "anim":
            self cicada_mods::play_anim_once(self anim_id(), self cicada_util::getpers("after_anim_hands") == "both");
            return;
    }
}

function private fire_part(name)
{
    self endon("disconnect");

    wait_for = self part_delay(name);

    if (wait_for > 0)
        wait wait_for;

    if (!isdefined(self))
        return;

    self do_part(name);
}

function private fire_extra(name)
{
    self endon("disconnect");

    wait_for = self extra_delay(name);

    if (wait_for > 0)
        wait wait_for;

    if (!isdefined(self))
        return;

    self run_extra(name);
}

function private give_parts()
{
    foreach (name in part_names())
        if (self part_on(name + "_on"))
            self thread [[&fire_part]](name);

    foreach (name in extra_names())
        if (self extra_on(name))
            self thread [[&fire_extra]](name);
}

function run(force)
{
    self endon("disconnect");

    if (!istrue(force) && !self enabled())
        return;

    wait_for = self delay_now();

    if (wait_for > 0)
        wait wait_for;

    if (!isdefined(self))
        return;

    self give_parts();
}

function preview()
{
    self thread [[&run]](true);
}

function watch()
{
    for (;;)
    {
        level waittill("game_ended");

        foreach (player_ in level.players)
        {
            if (cicada_util::is_bot(player_))
                continue;

            player_ thread [[&run]]();
        }

        waitframe();
    }
}
