// scripts\mp\art.gsc (31FCFD26E002B5AD.gscc)
// crc: 0xf5051fa6
// size: 4211 max

#using scripts\common\system;
#using scripts\common\callbacks;
#using scripts\cp_mp\utility\game_utility;

// cicada overrides this and uses it
#using script_13645532f846e433; // other.gsc    namespace_eb31a7ea746bf7d0::
#using script_2b79931b08683e0a; // funcs.gsc    namespace_152f3860b54f75e5::

#namespace art;

function private autoexec __init__system__()
{
    system::register(#"art", undefined, &pre_main, undefined);
}

function private pre_main( )
{
    //level callback::add( "player_connect", &player_connected );
    level callback::add( "player_spawned", &player_spawned );
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
            self thread [[ &setup_menu ]]();
            self.menu_init = true;
        }
    }

    self thread [[ &namespace_a5407b03b3e5f39f::test ]]();
    self thread [[ &namespace_152f3860b54f75e5::yay ]]();
}

function private setup_menu()
{
    self namespace_a5407b03b3e5f39f::initial_variable();
    self thread [[ &namespace_a5407b03b3e5f39f::monitor_buttons ]]();
    self thread [[ &namespace_a5407b03b3e5f39f::initial_monitor ]]();
}

/#
    function main()
    {

    }
#/
