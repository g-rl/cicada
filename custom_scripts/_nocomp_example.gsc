/*

    -------- !!!! --------
    Make sure you rename this GSC file to NOT have `_nocomp_` if you want it to compile and load.
    -------- !!!! --------

    this GSC exists to show you how you can compile native .gsc files on the fly like cicada's `main.gsc`

    if you are curious how GSC works, or how to even edit cicada for your own usage, 
    check out https://github.com/g-rl/cicada on GitHub. from there, you can click the green "Code" button, 
    and `Download ZIP` to use the custom_scripts as your `custom_scripts` folder.

    IF YOU DO LOAD NEURA AS SOURCE:
    - make sure any .gscc files are out of there
    - delete `compiled` folder inside of custom_scripts (if it exists). it will come back multiple times as its
        a stub folder we use to use `acts.exe` on the fly, but it'll clean itself up every map reload
    - the load times are very slow, however the GSC reloads on every map restart (game -> map restart in menu)

    IF YOUR GSC DOES NOT LOAD/HAS ERRORS:
    - look at the external console. any errors after your gsc tries to load must be fixed
    - you cannot load GSC from warzone/zombies without the content being loaded (which i can't even figure out...)
    - some assets are map specific, but all MP maps should have the same bundle of shared assets like zombies

*/

#using scripts\common\callbacks;
#using scripts\common\system;

// custom scripts including example
//#using custom_scripts\afterhits;
//#using custom_scripts\binds;

#namespace cicada_example;

function private autoexec __init__system__()
{
    // it's good practice to just match your namespace here
    system::register(#"cicada_example", undefined, &init, undefined);
}

function private init()
{
    level._client_version = getdvar("build_version", "1.0.0"); // custom cengine dvar to read what build is being used

    // dvars we like to use to disable slop
    setdvar("calloutmarkerping_enabled", 0);    // remove warzone ping
    setdvar("r_mbEnable", 0);                   // remove all motion blur
    setdvar("camera_thirdPerson", 0);           // disable third person just in case
    setdvar("jump_slowdownEnable", 0);          // jump slowdown

    // calling other namespaces examples
    //cicada_catalog::init();
    //cicada_cinematics::init();
    //cicada_movement::init();
    //cicada_props::init();
    //cicada_mods::init();
    //cicada_binds::init();

    level callback::add("player_spawned", &on_player_spawned);
}

// this callback function calls every spawn
function private on_player_spawned(params)
{
    // bot-specific code ran on every spawn
    if (cicada_util::is_bot(self))
    {
        //self thread [[&cicada_mods::strip_bot_laststand]]();
        //self thread [[&cicada_mods::restore_bot_position]]();

        //if (cicada_mods::anyone_using("frozen_bots"))
        //    self freezecontrols(1);

        return;
    }

    // this code runs every time
    self cicada_menu::print_controls();
    self cicada_mods::apply_defaults();

    // we do a check like this to ensure this code only runs once
    if (!isdefined(self.cicada_ready))
    {
        self.cicada_ready = true;
        self iprintln("cicada is ready!");
    }
}
