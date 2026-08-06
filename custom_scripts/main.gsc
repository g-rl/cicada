#using scripts\common\callbacks;
#using scripts\common\system;

#using custom_scripts\binds;
#using custom_scripts\catalog;
#using custom_scripts\cinematics;
#using custom_scripts\menu;
#using custom_scripts\mods;
#using custom_scripts\movement;
#using custom_scripts\util;

#namespace cicada;

function private autoexec __init__system__()
{
    system::register(#"cicada", undefined, &pre_main, undefined);
}

function private pre_main()
{
    setdvar("calloutmarkerping_enabled", 0);

    level._client = "jup";
    level._client_version = getdvar("build_version", "1.0.0");

    cicada_catalog::init();
    cicada_cinematics::init();
    cicada_movement::init();
    cicada_mods::init();
    cicada_binds::init();

    level thread [[&cicada_mods::skip_prematch]]();

    level callback::add("player_spawned", &on_player_spawned);
}

function private on_player_spawned(params)
{
    if (cicada_util::is_bot(self))
        return;

    // a fast restart kills the level thread started in pre_main without re-running it
    level thread [[&cicada_mods::skip_prematch]]();

    self cicada_menu::print_controls();

    self cicada_mods::apply_defaults();

    if (!isdefined(self.cicada_ready))
    {
        self.cicada_ready = true;
        self.menu = [];

        self cicada_menu::initial_variable();
        self thread [[&cicada_menu::initial_monitor]]();
        self thread [[&cicada_util::monitor_buttons]]();

        self thread [[&cicada_binds::start_monitors]]();
        self thread [[&cicada_mods::restore_features]]();
        self thread [[&cicada_mods::restore_timescale]]();

        self thread [[&cicada_mods::monitor_class]]();
    }

    self thread [[&cicada_menu::close_menu_on_death]]();
    self thread [[&cicada_mods::refresh_on_spawn]]();
}
