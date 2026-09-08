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
            nengine_session_set_dvar(name, value);
    }
}

function private apply_dvars()
{
    foreach (name in tracked_dvars())
    {
        value = nengine_session_dvar(name);

        if (value != "")
            setdvar(name, value);
    }
}

function private store_values()
{
    nengine_session_clear();
    store_dvars();

    if (!isdefined(self.pers) || !isdefined(self.pers["cicada"]))
        return 0;

    sent = 0;
    foreach (key, value in self.pers["cicada"])
    {
        if (!isdefined(value))
            continue;

        nengine_session_set(key, value);
        sent++;
    }
    return sent;
}

function private apply_values()
{
    total = nengine_session_count();
    for (i = 0; i < total; i++)
    {
        key = nengine_session_key(i);
        type = nengine_session_type(key);

        if (type == 4)
            value = (nengine_session_component(key, 0), nengine_session_component(key, 1), nengine_session_component(key, 2));
        else if (type != 0)
            value = nengine_session_get(key);
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
    total = nengine_session_list_count();
    for (i = 0; i < total; i++)
        used[nengine_session_list_name(i)] = true;

    for (i = 1; i <= 32; i++)
        if (!isdefined(used["session_" + i]))
            return "session_" + i;

    return undefined;
}

function count()
{
    return nengine_session_list_count();
}

function name_at(index)
{
    if (index < 0 || index >= nengine_session_list_count())
        return undefined;

    return nengine_session_list_name(index);
}

function default_name()
{
    name = nengine_session_default();
    return name.size > 0 ? name : undefined;
}

function is_default(name)
{
    if (!isdefined(name) || name.size == 0)
        return false;

    return nengine_session_default() == name;
}

function summary(name)
{
    return is_default(name) ? "^:default session" : "^7saved session";
}

function save(name)
{
    self store_values();

    if (nengine_session_save(name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not save ^:" + name));
        return false;
    }

    self cicada_util::message("session ^:" + name + " ^7saved");
    return true;
}

function load(name)
{
    if (nengine_session_load(name) != 1)
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
    if (nengine_session_set_default(name) != 1)
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

    if (nengine_session_delete(self.select_session) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not delete ^:" + self.select_session));
        return;
    }

    self cicada_util::message("session ^:" + self.select_session + " ^7deleted");
    self.select_session = undefined;
    self cicada_menu::new_menu();
}
