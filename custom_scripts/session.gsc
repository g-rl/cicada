#using custom_scripts\binds;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\util;

#namespace cicada_session;

function private tracked_dvars()
{
    return cicada_util::list("pan_instashoots,pan_alwayscanswap,pan_sprintswaps,pan_freezeanim,pan_canzooms,pan_alwaysaltswap,scr_killcam_time,cicada_autosave,cicada_autoload");
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

function private read_bot_slots()
{
    slots = [];
    key = cicada_util::mapkey(bot_slot_prefix() + "count");

    if (nengine_store_type("sessions", key) == 0)
        return slots;

    total = int(nengine_store_get("sessions", key));

    for (i = 0; i < total; i++)
    {
        origin = stored_vector(bot_slot_key(i, "position"));

        if (!isdefined(origin))
            continue;

        slot = spawnstruct();
        slot.origin = origin;
        slot.angles = stored_vector(bot_slot_key(i, "angles"));

        slots[slots.size] = slot;
    }

    return slots;
}

function private free_bot()
{
    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_) && !istrue(player_.cicada_session_spot))
            return player_;

    return undefined;
}

function private place_bot_slots()
{
    if (!isdefined(self.cicada_bot_slots) || !self.cicada_bot_slots.size)
        return 0;

    left = [];
    used = 0;

    foreach (slot in self.cicada_bot_slots)
    {
        bot = free_bot();

        if (!isdefined(bot))
        {
            left[left.size] = slot;
            continue;
        }

        bot.cicada_session_spot = true;
        bot cicada_util::setmappers("position", slot.origin);

        if (isdefined(slot.angles))
            bot cicada_util::setmappers("angles", slot.angles);

        bot cicada_mods::load_position();
        used++;
    }

    self.cicada_bot_slots = left;
    return used;
}

function private settle_bots()
{
    self endon("disconnect");
    self endon("cicada_bot_slots");
    level endon("game_ended");

    for (i = 0; i < 90; i++)
    {
        wait 1;

        self place_bot_slots();

        if (!self.cicada_bot_slots.size)
            return;
    }
}

function private apply_bots()
{
    self notify("cicada_bot_slots");

    foreach (player_ in level.players)
        if (cicada_util::is_bot(player_))
            player_.cicada_session_spot = false;

    self.cicada_bot_slots = read_bot_slots();
    used = self place_bot_slots();

    if (self.cicada_bot_slots.size)
        self thread [[&settle_bots]]();

    return used;
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

function store_version()
{
    return 2;
}

function private point_bases()
{
    return cicada_util::list("bolt,bot_bolt,agent_bolt,zombie_bolt,path,zombie_path,record");
}

function private numbered_bases()
{
    return cicada_util::list("bounce,crate,crate_angles");
}

function private dead_keys()
{
    return cicada_util::list("always_nac,gesture_mode,gesture_type,selected_gesture,selected_raw_gesture,selected_vm_gesture,selected_viewmodel");
}

function private all_digits(text)
{
    if (!isdefined(text) || text.size == 0)
        return false;

    for (i = 0; i < text.size; i++)
        if (text[i] < "0" || text[i] > "9")
            return false;

    return true;
}

function private old_map_key(key)
{
    if (issubstr(key, "@"))
        return false;

    if (key == "position" || key == "angles")
        return true;

    if (isstartstr(key, "pve_state_"))
        return true;

    foreach (stem in point_bases())
    {
        if (key == stem + "_count")
            return true;

        if (isstartstr(key, stem + "_point_") && all_digits(cicada_util::trim_start(key, stem + "_point_")))
            return true;
    }

    foreach (stem in numbered_bases())
    {
        if (key == stem + "_count")
            return true;

        if (isstartstr(key, stem + "_") && all_digits(cicada_util::trim_start(key, stem + "_")))
            return true;
    }

    return false;
}

function private old_dead_key(key)
{
    foreach (dead in dead_keys())
        if (key == dead)
            return true;

    return isendstr(key, "_gesture_type");
}

function private old_bind_key(key)
{
    return isstartstr(key, "bind_") && key != "bind_names";
}

function private bind_alive(name)
{
    if (!isdefined(level.cicada_bind_names))
        return false;

    foreach (known in level.cicada_bind_names)
        if (known == name)
            return true;

    return false;
}

function private carry_bind(key, value)
{
    name = cicada_util::trim_start(key, "bind_");

    if (!bind_alive(name))
        return 0;

    slot = cicada_binds::slot_key(name);
    held = self cicada_util::getpers(slot);

    if (isdefined(held) && held != "off")
        return 0;

    names = cicada_binds::slot_names();
    index = int(value);

    if (index < 1 || index >= names.size)
        return 0;

    self cicada_util::setpers(slot, names[index]);
    return 1;
}

function private scrub_pers()
{
    if (!isdefined(self.pers) || !isdefined(self.pers["cicada"]))
        return;

    stale = [];

    foreach (key, value in self.pers["cicada"])
        if (old_map_key(key) || old_dead_key(key) || old_bind_key(key))
            stale[stale.size] = key;

    foreach (key in stale)
        self cicada_util::setpers(key, undefined);
}

function private migrate_report(moved, dropped)
{
    if (!moved && !dropped)
        return;

    self cicada_util::message("old session ^:updated ^7- ^:" + moved + " ^7binds kept, ^:" + dropped + " ^7dead keys dropped");
}

function private apply_values()
{
    total = nengine_store_count("sessions");
    moved = 0;
    dropped = 0;

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

        if (old_map_key(key) || old_dead_key(key))
        {
            dropped++;
            continue;
        }

        if (old_bind_key(key))
        {
            moved = moved + self carry_bind(key, value);
            dropped++;
            continue;
        }

        self cicada_util::setpers(key, value);
    }

    self scrub_pers();
    self cicada_util::setpers("store_version", store_version());
    self migrate_report(moved, dropped);

    apply_bots();
    apply_dvars();
    self sync_auto();
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

function autosave_on()
{
    return istrue(getdvarint("cicada_autosave", 0));
}

function locked(name)
{
    if (!autosave_on())
        return false;

    if (isdefined(name) && name == autosave_name())
        return false;

    self cicada_util::message(cicada_util::warn("turn autosave off to touch other sessions"));
    return true;
}

function save(name)
{
    if (self locked(name))
        return false;

    self store_values();

    if (nengine_store_save("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not save ^:" + name));
        return false;
    }

    self.cicada_session = name;
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
    if (self locked(name))
        return false;

    if (nengine_store_load("sessions", name) != 1)
    {
        self cicada_util::message(cicada_util::warn("could not load ^:" + name));
        return false;
    }

    self apply_values();
    self restore_positions();
    self.cicada_session = name;
    self cicada_util::message("session ^:" + name + " ^7loaded");
    return true;
}

function autosave_name()
{
    return "autosave";
}

function private auto_dvar(key)
{
    return (key == "session_autosave") ? "cicada_autosave" : "cicada_autoload";
}

function private sync_auto()
{
    setdvar("cicada_autosave", istrue(self cicada_util::getpers("session_autosave")) ? 1 : 0);
    setdvar("cicada_autoload", istrue(self cicada_util::getpers("session_autoload")) ? 1 : 0);
}

function flip_auto(key)
{
    state = self cicada_util::flippers(key);

    setdvar(auto_dvar(key), state ? 1 : 0);

    if (key == "session_autosave" && state)
        self autosave();

    self cicada_menu::update_menu();
}

function private autosave_wait()
{
    self endon("disconnect");
    self endon("cicada_autosave");
    level endon("game_ended");

    wait 0.5;

    self store_values();
    nengine_store_save("sessions", autosave_name());
}

function autosave()
{
    if (!getdvarint("cicada_autosave", 0))
        return;

    self notify("cicada_autosave");
    self thread [[&autosave_wait]]();
}

function autoload()
{
    if (!getdvarint("cicada_autoload", 1))
        return false;

    if (nengine_store_load("sessions", autosave_name()) != 1)
        return false;

    self apply_values();
    self restore_positions();
    self cicada_util::message("session ^:" + autosave_name() + " ^7loaded");
    return true;
}

function restore_on_join()
{
    if (self autoload())
        return true;

    if (getdvarint("cicada_autosave", 0) || getdvarint("cicada_autoload", 1))
        return false;

    return self load_default();
}

function load_default()
{
    name = default_name();
    if (!isdefined(name))
        return false;

    return self load(name);
}

function current_name()
{
    if (autosave_on())
        return autosave_name();

    if (isdefined(self.cicada_session))
        return self.cicada_session;

    return default_name();
}

function save_current()
{
    name = self current_name();

    if (!isdefined(name))
    {
        self cicada_util::message(cicada_util::warn("no session loaded, save a new one first"));
        return;
    }

    self save(name);
    self cicada_menu::update_menu();
}

function reset_current()
{
    name = self current_name();

    if (!isdefined(name))
    {
        self cicada_util::message(cicada_util::warn("no session loaded to reset"));
        return;
    }

    self load(name);
    self cicada_menu::update_menu();
}

function clear_sessions()
{
    keep = autosave_on();

    for (i = count() - 1; i >= 0; i--)
    {
        name = name_at(i);

        if (!isdefined(name))
            continue;

        if (keep && name == autosave_name())
            continue;

        nengine_store_delete("sessions", name);
    }

    self.select_session = undefined;

    if (!keep)
        self.cicada_session = undefined;

    self cicada_util::message(keep ? ("all sessions ^1deleted ^7but ^:" + autosave_name()) : "all sessions ^1deleted");
    self cicada_menu::update_menu();
}

function private stored_count(name)
{
    total = nengine_store_count("sessions");
    counts = [];
    counts["values"] = 0;
    counts["binds"] = 0;
    counts["spots"] = 0;
    counts["bots"] = 0;

    for (i = 0; i < total; i++)
    {
        key = nengine_store_key("sessions", i);

        if (is_bot_slot_key(key))
        {
            if (issubstr(key, "_position"))
                counts["bots"]++;

            continue;
        }

        counts["values"]++;

        if (isstartstr(key, "slot_"))
            counts["binds"]++;
        else if (isstartstr(key, "position@") || isstartstr(key, "bounce_") || isstartstr(key, "crate_"))
            counts["spots"]++;
    }

    return counts;
}

function private key_map(key)
{
    if (!issubstr(key, "@"))
        return undefined;

    parts = strtok(key, "@");

    if (parts.size < 2)
        return undefined;

    return parts[parts.size - 1];
}

function private key_body(key)
{
    parts = strtok(key, "@");

    if (parts.size < 2)
        return key;

    return parts[0];
}

function private open_store(name)
{
    return isdefined(name) && nengine_store_load("sessions", name) == 1;
}

function map_list(name)
{
    maps = [];

    if (!open_store(name))
        return maps;

    seen = [];
    total = nengine_store_count("sessions");

    for (i = 0; i < total; i++)
    {
        map = key_map(nengine_store_key("sessions", i));

        if (!isdefined(map) || istrue(seen[map]))
            continue;

        seen[map] = true;
        maps[maps.size] = map;
    }

    return maps;
}

function map_count(name)
{
    return map_list(name).size;
}

function map_at(name, index)
{
    maps = map_list(name);

    if (index < 0 || index >= maps.size)
        return undefined;

    return maps[index];
}

function map_label(map)
{
    if (!isdefined(map))
        return "none";

    return cicada_util::trim_start(map, "mp_");
}

function is_current_map(map)
{
    return isdefined(map) && map == getdvar("g_mapname");
}

function map_counts(name, map)
{
    counts = [];
    counts["total"] = 0;
    counts["spots"] = 0;
    counts["crates"] = 0;
    counts["bounces"] = 0;
    counts["points"] = 0;
    counts["actors"] = 0;
    counts["bots"] = 0;

    if (!isdefined(map) || !open_store(name))
        return counts;

    total = nengine_store_count("sessions");

    for (i = 0; i < total; i++)
    {
        key = nengine_store_key("sessions", i);

        if (key_map(key) != map)
            continue;

        counts["total"]++;
        body = key_body(key);

        if (is_bot_slot_key(body))
        {
            if (issubstr(body, "_position"))
                counts["bots"]++;

            continue;
        }

        if (isstartstr(body, "position") || isstartstr(body, "angles"))
            counts["spots"]++;
        else if (isstartstr(body, "crate_"))
            counts["crates"]++;
        else if (isstartstr(body, "bounce_"))
            counts["bounces"]++;
        else if (issubstr(body, "_point_"))
            counts["points"]++;
        else if (isstartstr(body, "pve_state_"))
            counts["actors"]++;
    }

    return counts;
}

function map_summary(name, map)
{
    counts = map_counts(name, map);

    return "^:" + counts["total"] + " ^7keys" + (is_current_map(map) ? " ^2- this map" : "");
}

function private read_store(name)
{
    if (nengine_store_load("sessions", name) == 1)
        return true;

    waitframe();

    return nengine_store_load("sessions", name) == 1;
}

function private reload_store()
{
    name = self current_name();

    if (isdefined(name))
        nengine_store_load("sessions", name);
}

function preview_map(name, map)
{
    if (!isdefined(map))
    {
        self cicada_util::message(cicada_util::warn("no map settings to read"));
        return;
    }

    counts = map_counts(name, map);

    self cicada_util::message_bold("^:" + map_label(map) + " ^7- " + counts["total"] + " keys in ^:" + name);
    self cicada_util::message("spots ^:" + counts["spots"] + " ^7| crates ^:" + counts["crates"] + " ^7| bounce pads ^:" + counts["bounces"]);
    self cicada_util::message("path points ^:" + counts["points"] + " ^7| saved actors ^:" + counts["actors"] + " ^7| bot spots ^:" + counts["bots"]);
}

function private rewrite_store(name, drop, copy_from)
{
    if (!open_store(name))
        return -1;

    total = nengine_store_count("sessions");

    keys = [];
    values = [];
    changed = 0;

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

        map = key_map(key);

        if (isdefined(drop) && map == drop)
        {
            changed++;
            continue;
        }

        keys[keys.size] = key;
        values[values.size] = value;

        if (isdefined(copy_from) && map == copy_from)
        {
            keys[keys.size] = key_body(key) + "@" + getdvar("g_mapname");
            values[values.size] = value;
            changed++;
        }
    }

    nengine_store_clear("sessions");

    for (i = 0; i < keys.size; i++)
        nengine_store_set("sessions", keys[i], values[i]);

    if (nengine_store_save("sessions", name) != 1)
        return -1;

    return changed;
}

function delete_map(name, map)
{
    if (self locked(name) || !isdefined(map))
        return;

    changed = rewrite_store(name, map, undefined);

    if (changed < 0)
    {
        self cicada_util::message(cicada_util::warn("could not write ^:" + name));
        return;
    }

    self cicada_util::message("^1removed ^:" + changed + " ^7keys for " + map_label(map));
    self cicada_menu::update_menu();
}

function copy_map(name, map)
{
    if (self locked(name) || !isdefined(map))
        return;

    if (is_current_map(map))
    {
        self cicada_util::message(cicada_util::warn("already the map you are on"));
        return;
    }

    changed = rewrite_store(name, undefined, map);

    if (changed < 0)
    {
        self cicada_util::message(cicada_util::warn("could not write ^:" + name));
        return;
    }

    self cicada_util::message("copied ^:" + changed + " ^7keys onto " + map_label(getdvar("g_mapname")));
    self cicada_menu::update_menu();
}

function preview_selected_map()
{
    self preview_map(self.select_session, self.select_map);
}

function delete_selected_map()
{
    self delete_map(self.select_session, self.select_map);
}

function copy_selected_map()
{
    self copy_map(self.select_session, self.select_map);
}

function preview(name)
{
    if (!isdefined(name))
    {
        self cicada_util::message(cicada_util::warn("no session to preview"));
        return;
    }

    if (!self read_store(name))
    {
        self cicada_util::message(cicada_util::warn("could not read ^:" + name));
        return;
    }

    counts = stored_count(name);
    was_default = is_default(name);

    self reload_store();

    self cicada_util::message_bold("^:" + name + " ^7- " + counts["values"] + " settings");
    self cicada_util::message("binds ^:" + counts["binds"] + " ^7| saved spots ^:" + counts["spots"] + " ^7| bot spots ^:" + counts["bots"]);
    self cicada_util::message("dvars ^:" + tracked_dvars().size + " ^7| " + (was_default ? "^:default session" : "^7saved session"));
}

function preview_on_join()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isdefined(self.cicada_session))
        return;

    wait 3;

    self cicada_util::message_bold("session ^:" + self.cicada_session + " ^7is loaded");
    self preview(self.cicada_session);
}

function preview_selected()
{
    self preview(self.select_session);
}

function manage(action)
{
    switch (action)
    {
        case "save new":
            self save_new();
            break;

        case "save current":
            self save_current();
            break;

        case "reset current":
            self reset_current();
            break;

        case "clear all":
            self clear_sessions();
            break;

        case "preview":
            self preview(self current_name());
            break;
    }
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

    if (self locked(self.select_session))
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

    if (self locked(self.select_session))
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
