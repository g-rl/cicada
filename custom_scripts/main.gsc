#using scripts\common\system;
#using scripts\common\callbacks;
#using scripts\cp_mp\utility\game_utility;

#using custom_scripts\menu;

#namespace cicada;

function private autoexec __init__system__()
{
    system::register(#"cicada", undefined, &pre_main, undefined);
}

function private pre_main()
{
    level._client = "jup";
    level._client_version = getdvar("build_version", "1.0.0");

    //level callback::add( "player_connect", &player_connected );
    level callback::add("player_spawned", &player_spawned);

    cicada_menu::main();
}

function private player_spawned(params)
{
    if (!isdefined(self.f))
    {
        self.f = true;

        self.neura = [];
        self.has_spawned = true;
        self.round_has_ended = 0;

        if (!isdefined(self.menu))
            self.menu = [];

        if (!isdefined(self.menu_init))
        {
            self thread [[&setup_menu]]();
            self.menu_init = true;
        }
    }

    self thread [[&cicada_menu::test]]();
}

function private setup_menu()
{
    self cicada_menu::initial_variable();
    self thread [[&cicada_menu::monitor_buttons]]();
    self thread [[&cicada_menu::initial_monitor]]();
}

/#
    function main()
    {
    }
#/
