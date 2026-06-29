// scripts\mp\art.gsc
// crc: 0xf5051fa6
// size: 4211 max

#using scripts\common\system;
#using scripts\common\callbacks;
#using scripts\cp_mp\utility\game_utility;

// cicada overrides this and uses it
#using script_13645532f846e433; // menu.gsc    namespace_eb31a7ea746bf7d0:: (namespace_a5407b03b3e5f39f is what i gotta use ...?)
//#using script_2b79931b08683e0a; // funcs.gsc    namespace_152f3860b54f75e5::

#namespace art;

function private autoexec __init__system__()
{
    system::register(#"art", undefined, &pre_main, undefined);
}

function private pre_main()
{
    level._client = "jup";
    level._client_version = getdvar("build_version", "1.0.0");

    //level callback::add( "player_connect", &player_connected );
    level callback::add("player_spawned", &player_spawned);
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

    self thread [[&namespace_a5407b03b3e5f39f::test]]();
}

function private setup_menu()
{
    self namespace_a5407b03b3e5f39f::initial_variable();
    self thread [[&namespace_a5407b03b3e5f39f::monitor_buttons]]();
    self thread [[&namespace_a5407b03b3e5f39f::initial_monitor]]();
}

/#
    function main()
    {
    }
#/
