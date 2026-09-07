#using custom_scripts\util;

#namespace cicada_killcam;

function clean()
{
    self endon("disconnect");

    for (;;)
    {
        if (istrue(self cicada_util::getpers("hide_weapon")))
        {
            self setclientomnvar("ui_killcam_killedby_item_type", -1);
            self setclientomnvar("ui_killcam_killedby_item_id", -1);
            self setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
            self setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);
        }

        if (istrue(self cicada_util::getpers("hide_victim")))
            self setclientomnvar("ui_killcam_victim_id", -1);

        if (istrue(self cicada_util::getpers("hide_perks")))
            for (i = 0; i < 7; i++)
                self setclientomnvar("ui_killcam_killedby_perk" + i, "none");

        if (istrue(self cicada_util::getpers("hide_attachments")))
            for (i = 0; i < 8; i++)
                self setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);

        if (istrue(self cicada_util::getpers("hide_equipment")))
        {
            self setclientomnvar("ui_killcam_killedby_equipment_primary", "none");
            self setclientomnvar("ui_killcam_killedby_equipment_secondary", "none");
        }

        if (istrue(self cicada_util::getpers("hide_field_upgrade")) && !isalive(self))
        {
            self setclientomnvar("ui_killcam_killedby_super1", "none");
            self setclientomnvar("ui_killcam_killedby_super2", "none");
            self setclientomnvar("ui_super_ref", "none");
            self setclientomnvar("ui_super_progress", 0);
        }

        wait 0.05;
    }
}

function skip_final()
{
    self endon("disconnect");

    self waittill("showing_final_killcam");
    self thread [[&wait_for_skip]]();
}

function wait_for_skip()
{
    self endon("disconnect");
    self endon("stop_waiting_killcam");

    self waittill("button_pressed_+gostand");

    foreach (player in level.players)
        skip(player);
}

function skip(player)
{
    player setclientomnvar("ui_killcam_end_milliseconds", 0);
    player setclientomnvar("ui_killcam_killedby_id", -1);
    player setclientomnvar("ui_killcam_victim_id", -1);
    player setclientomnvar("ui_killcam_killedby_item_type", -1);
    player setclientomnvar("ui_killcam_killedby_item_id", -1);
    player setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
    player setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);

    for (i = 0; i < 8; i++)
        player setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);

    for (i = 0; i < 7; i++)
        player setclientomnvar("ui_killcam_killedby_perk" + i, "none");

    player.killcam = undefined;
    player.forcespectatorclient = -1;
    player.killcamentity = -1;
    player.archivetime = 0;
    player.archiveusepotg = 0;
    player.psoffsettime = 0;
    player.spectatekillcam = 0;

    player allowspectateteam("freelook", 0);
    player allowspectateteam("none", 1);
    player setclientomnvar("ui_session_state", "dead");
    player.sessionstate = "dead";

    player setclientomnvar("cam_scene_name", "unknown");
    player setclientomnvar("cam_scene_lead", -1);
    player setclientomnvar("cam_scene_support", -1);

    player notify("abort_killcam");
    player notify("killcam_ended");
    player notify("stop_waiting_killcam");
    player setclientomnvar("post_game_state", 1);
}

function set_time(value)
{
    setdvar("scr_killcam_time", float(value));
}
