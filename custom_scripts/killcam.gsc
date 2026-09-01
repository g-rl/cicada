#using custom_scripts\util;

#namespace cicada_killcam;

// scripts\mp\killcam writes the attachment slots as attachment + index + 1
function clean(key)
{
    self endon("disconnect");
    self endon(cicada_util::stop_event(key));
    level endon("game_ended");

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
            for (i = 0; i < 6; i++)
                self setclientomnvar("ui_killcam_killedby_perk" + i, "none");

        if (istrue(self cicada_util::getpers("hide_attachments")))
        {
            for (i = 0; i < 8; i++)
            {
                self setclientomnvar("ui_killcam_killedby_attachment" + i + 1, -1);
                self setclientomnvar("ui_killcam_killedby_attachment" + (i + 1), -1);
            }
        }

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

function set_time(value)
{
    setdvar("scr_killcam_time", float(value));
}
