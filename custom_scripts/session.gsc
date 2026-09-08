#using custom_scripts\menu;
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

function private store_values()
{
    nengine_store_clear("sessions");
    store_dvars();

    if (!isdefined(self.pers) || !isdefined(self.pers["cicada"]))
        return 0;

    sent = 0;
    foreach (key, value in self.pers["cicada"])
    {
        if (!isdefined(value))
            continue;

        nengine_store_set("sessions", key, value);
        sent++;
    }
    return sent;
}

function private apply_values()
{
    total = nengine_store_count("sessions");
    for (i = 0; i < total; i++)
    {
        key = nengine_store_key("sessions", i);
        type = nengine_store_type("sessions", key);

        if (type == 4)
            value = (nengine_store_component("sessions", key, 0), nengine_store_component("sessions", key, 1), nengine_store_component("sessions", key, 2));
        else if (type != 0)
            value = nengine_store_get("sessions", key);
        else
            continue;

        self cicada_util::setpers(key, value);
    }

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

function load(name)
{
    if (nengine_store_load("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not load ^:" + name));
        return false;
    }

    self apply_values();
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
