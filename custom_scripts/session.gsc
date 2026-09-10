#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\util;

#namespace cicada_session;

function private tracked_dvars()
{
    return cicada_util::list("pan_instashoots,pan_alwayscanswap,pan_sprintswaps,pan_freezeanim,pan_canzooms,pan_alwaysaltswap,scr_killcam_time");
}

function private store_dvars()
{
    foreach (name in tracked_dvars())
    {
        value = getdvar(name);

        if (value != "")
            nengine_store_set_dvar("sessions", name, value);
    }
}

function private apply_dvars()
{
    foreach (name in tracked_dvars())
    {
        value = nengine_store_dvar("sessions", name);

        if (value != "")
            setdvar(name, value);
    }
}

function private bot_slot_prefix()
{
    return "bot_slot_";
}

function private bot_slot_key(index, field)
{
    return cicada_util::mapkey(bot_slot_prefix() + index + "_" + field);
}

function private is_bot_slot_key(key)
{
    return isstartstr(key, bot_slot_prefix());
}

function private stored_vector(key)
{
    if (nengine_store_type("sessions", key) != 4)
        return undefined;

    return (nengine_store_component("sessions", key, 0), nengine_store_component("sessions", key, 1), nengine_store_component("sessions", key, 2));
}

function private store_bots()
{
    total = 0;

    foreach (player_ in level.players)
    {
        if (!cicada_util::is_bot(player_) || !player_ cicada_mods::has_position())
            continue;

        nengine_store_set("sessions", bot_slot_key(total, "position"), player_ cicada_util::getmappers("position"));

        angles = player_ cicada_util::getmappers("angles");
        if (isdefined(angles))
            nengine_store_set("sessions", bot_slot_key(total, "angles"), angles);

        total++;
    }

    nengine_store_set("sessions", cicada_util::mapkey(bot_slot_prefix() + "count"), total);
    return total;
}

function private apply_bots()
{
    key = cicada_util::mapkey(bot_slot_prefix() + "count");

    if (nengine_store_type("sessions", key) == 0)
        return 0;

    total = int(nengine_store_get("sessions", key));
    index = 0;

    foreach (player_ in level.players)
    {
        if (index >= total)
            break;

        if (!cicada_util::is_bot(player_))
            continue;

        origin = stored_vector(bot_slot_key(index, "position"));
        angles = stored_vector(bot_slot_key(index, "angles"));
        index++;

        if (!isdefined(origin))
            continue;

        player_ cicada_util::setmappers("position", origin);

        if (isdefined(angles))
            player_ cicada_util::setmappers("angles", angles);
    }

    return index;
}

function private store_values()
{
    nengine_store_clear("sessions");
    store_dvars();

    if (!isdefined(self.pers) || !isdefined(self.pers["cicada"]))
        return store_bots();

    sent = 0;
    foreach (key, value in self.pers["cicada"])
    {
        if (!isdefined(value) || is_bot_slot_key(key))
            continue;

        nengine_store_set("sessions", key, value);
        sent++;
    }

    store_bots();
    return sent;
}

function private apply_values()
{
    total = nengine_store_count("sessions");
    for (i = 0; i < total; i++)
    {
        key = nengine_store_key("sessions", i);
        type = nengine_store_type("sessions", key);

        if (is_bot_slot_key(key))
            continue;

        if (type == 4)
            value = (nengine_store_component("sessions", key, 0), nengine_store_component("sessions", key, 1), nengine_store_component("sessions", key, 2));
        else if (type != 0)
            value = nengine_store_get("sessions", key);
        else
            continue;

        self cicada_util::setpers(key, value);
    }

    apply_bots();
    apply_dvars();
    return total;
}

function private free_name()
{
    used = [];
    total = nengine_store_list_count("sessions");
    for (i = 0; i < total; i++)
        used[nengine_store_list_name("sessions", i)] = true;

    for (i = 1; i <= 32; i++)
        if (!isdefined(used["session_" + i]))
            return "session_" + i;

    return undefined;
}

function count()
{
    return nengine_store_list_count("sessions");
}

function name_at(index)
{
    if (index < 0 || index >= nengine_store_list_count("sessions"))
        return undefined;

    return nengine_store_list_name("sessions", index);
}

function default_name()
{
    name = nengine_store_default("sessions");
    return name.size > 0 ? name : undefined;
}

function is_default(name)
{
    if (!isdefined(name) || name.size == 0)
        return false;

    return nengine_store_default("sessions") == name;
}

function summary(name)
{
    return is_default(name) ? "^:default session" : "^7saved session";
}

function save(name)
{
    self store_values();

    if (nengine_store_save("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not save ^:" + name));
        return false;
    }

    self cicada_util::message("session ^:" + name + " ^7saved");
    return true;
}

function private restore_positions()
{
    if (self cicada_mods::has_position())
        self cicada_mods::load_position();

    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_) && player_ cicada_mods::has_position())
            player_ cicada_mods::load_position();
}

function load(name)
{
    if (nengine_store_load("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not load ^:" + name));
        return false;
    }

    self apply_values();
    self restore_positions();
    self cicada_util::message("session ^:" + name + " ^7loaded");
    return true;
}

function load_default()
{
    name = default_name();
    if (!isdefined(name))
        return false;

    return self load(name);
}

function save_new()
{
    name = free_name();
    if (!isdefined(name))
    {
        self cicada_util::message(cicada_util::warn("no free session slots"));
        return;
    }

    self save(name);
    self cicada_menu::update_menu();
}

function save_selected()
{
    if (!isdefined(self.select_session))
        return;

    self save(self.select_session);
    self cicada_menu::update_menu();
}

function load_selected()
{
    if (!isdefined(self.select_session))
        return;

    self load(self.select_session);
    self cicada_menu::update_menu();
}

function toggle_default()
{
    if (!isdefined(self.select_session))
        return;

    name = is_default(self.select_session) ? "" : self.select_session;
    if (nengine_store_set_default("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not change the default session"));
        return;
    }

    self cicada_util::message(name == "" ? "default session cleared" : ("session ^:" + name + " ^7set as default"));
    self cicada_menu::update_menu();
}

function delete_selected()
{
    if (!isdefined(self.select_session))
        return;

    if (nengine_store_delete("sessions", self.select_session) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not delete ^:" + self.select_session));
        return;
    }

    self cicada_util::message("session ^:" + self.select_session + " ^7deleted");
    self.select_session = undefined;
    self cicada_menu::new_menu();
}
