// 22000 < 23533 max bytes
#using scripts\mp\hud_util;

#namespace namespace_eb31a7ea746bf7d0;

function test()
{
    a = "^:cicada";
	self iprintln(a);
    self iprintlnbold(a);
}

function initial_variable()
{
    // menu variables
    self.font            = "default";
    self.font_scale      = 0.95;
    self.option_limit    = 10;
    self.option_spacing  = 16;
    self.option_summary  = true;
    self.x_offset        = -110;
    self.y_offset        = 80;
    self.element_count   = 0;
    self.element_list    = list("text,submenu,toggle,category,slider");

    self.color[0] = (1,1,1); // when cursor is over a option, this is the color. this is white for now
    self.color[1] = (0.0, 0.0, 0.0);
    self.color[2] = (0.05, 0.0, 0.0);
    self.color[3] = (0.45, 0.455, 0.45); // idk
    self.color[4] = self.color[0]; // this is normal color for option whenever cursor isn't over it

    // main accent being used
    self.current_menu_color = (1.0, 0.0, 0.10);

    self.cursor   = [];
    self.previous = [];
    self set_menu("cicada");
    self set_title(self get_menu());
}

function structure()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";
    
    increment_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider (^5no jump^7)";
    slider_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to select";
    credits = "made with ^1<3^7 by ^:nyli^7 & ^:mikey";
    title = "cicada";

    switch(menu)
    {
    case "cicada":
        //self.bind_index = false;
        self add_menu(title);
        self add_option("mods & toggles", credits, &new_menu, "mods & toggles");
        self add_option("binds & glitches", credits, &new_menu, "binds & glitches");
        self add_option("effects & misc", credits, &new_menu, "effects & misc");
        self add_option("position", credits, &new_menu, "position manager");
        self add_option("ai", credits, &new_menu, "ai manager");
        self add_option("game profile", credits, &new_menu, "game profile");
        self add_option("aimbot", credits, &new_menu, "aimbot manager");
        self add_option("clients", credits, &new_menu, "client manager");

        //self add_option("position", credits, &new_menu, "position");
        //self add_option("game", credits, &new_menu, "game settings");
        //self add_option("clients", credits, &new_menu, "manage clients");
        //if (istrue(level.is_debug)) self add_option("debug settings", credits, &new_menu, "debug settings");
        break;
    case "mods & toggles":
        //self.bind_index = false;
        self add_menu(menu);

        self add_option("test", undefined, &test);

        // engine toggles
        //self add_dvar_toggle("instashoots", undefined, "pan_instashoots");
        //self add_dvar_toggle("always canswap", undefined, "pan_alwayscanswap");
        //self add_dvar_toggle("sprint swaps", undefined, "pan_sprintswaps");
        //self add_dvar_toggle("freeze anim", undefined, "pan_freezeanim");
        //self add_dvar_toggle("canzooms", undefined, "pan_canzooms");
        //self add_dvar_toggle("always altswap", undefined, "pan_alwaysaltswap");

        break;
    case "binds & glitches":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "effects & misc":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "position manager":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "ai manager":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "game profile":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "aimbot manager":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    case "client manager":
        //self.bind_index = false;
        self add_menu(menu);
        self add_option("test", undefined, &test);
        break;
    default:
        //if (istrue(self.bind_index))
        //    self bind_index(menu, increment_controls);
        //else 
        //    self player_index(menu, self.select_player);
        //self add_option("huh", undefined, &void);
        break;
    }
}

function void()
{}

function get_cursor()
{
    return self.cursor[self get_menu()];
}

function set_cursor(cursor)
{
    if (isdefined(cursor))
        self.cursor[self get_menu()] = cursor;
}

function get_menu()
{
    return self.menu["menu"];
}

function set_menu(menu)
{
    //if (isdefined(menu))
    self.menu["menu"] = menu;
}

function set_title(title)
{
    if (isdefined(title))
        self.menu["title"] = title;
}

function get_title()
{
    return self.menu["title"];
}

function in_menu()
{
    return istrue(self.in_menu);
}

function set_procedure()
{
    self.in_menu = !istrue(self.in_menu);
}

function add_option(text, summary, func, argument_1, argument_2, argument_3, argument_4, argument_5)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = func;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;
    option["argument_4"] = argument_4;
    option["argument_5"] = argument_5;
    self.structure[self.structure.size] = option;
}

function initial_monitor()
{
    self endon("disconnect");
    level endon("game_ended");

    //self thread [[ &monitor_menu_close ]]();

    for(;;)
    {
        if (isalive(self))
        {
            if (!self in_menu())
            {
                if (self adsbuttonpressed() && self isbuttonpressed("-actionslot 1"))
                {
                    self open_menu();
                    wait 0.15;
                }
            }
            else
            {
                menu   = self get_menu();
                cursor = self get_cursor();

                // force close if melee pressed
                if (self isbuttonpressed("+melee_zoom"))
                {
                    //self thread [[ &play_sound ]]("recondrone_tag");
                    self close_menu();
                }
                else if (self usebuttonpressed()) // back
                {
                    // self sfx("zmb_powerup_activate");

                    if (isdefined(self.previous[(self.previous.size - 1)]))
                    {
                        self new_menu(self.previous[menu]);
                    }
                    else
                    {
                        //self thread [[ &play_sound ]]("deadsilence_end");
                        self close_menu();
                    }

                    wait 0.15;
                }
                else if (self isbuttonpressed("-actionslot 2") && !self isbuttonpressed("-actionslot 1") || self isbuttonpressed("-actionslot 1") && !self isbuttonpressed("-actionslot 2")) // up & down
                {
                    if (isdefined(self.structure) && self.structure.size >= 2)
                    {
                        // self thread [[ &play_sound ]]("attachment_pickup");
                        scrolling = self isbuttonpressed("-actionslot 2") ? 1 : -1;
                        self set_cursor((cursor + scrolling));
                        
                        res = self update_scrolling(scrolling);
                        while (!res)
                        {
                            res = self update_scrolling(scrolling);
                        }
                    }
                    wait 0.07;
                }
                else if (self isbuttonpressed("-actionslot 4") && !self isbuttonpressed("-actionslot 3") || self isbuttonpressed("-actionslot 3") && !self isbuttonpressed("-actionslot 4"))
                {
                    if (istrue(self.structure[cursor]["slider"]))
                    {
                        //self thread [[ &play_sound ]]("scavenger_pack_pickup");
                        scrolling = self isbuttonpressed("-actionslot 3") ? 1 : -1;
                        self set_slider(scrolling);

                        if (istrue(self.structure[cursor]["is_increment"]))
                        {
                            self thread [[ &execute_function ]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            //self thread [[ &play_sound ]]("ui_mp_weapon_pickup");
                            self update_menu(menu, cursor);
                        }
                    }
                    wait 0.07;
                }
                else if (self isbuttonpressed("+gostand"))
                {
                    if (isdefined(self.structure[cursor]["function"]))
                    {
                        if (istrue(self.structure[cursor]["slider"]))
                        {
                            if (istrue(self.structure[cursor]["is_array"]))
                            {
                                self thread [[ &execute_function ]](self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                                //self thread [[ &play_sound ]]("recondrone_tag");
                            }
                            else
                            {
                                self iprintlnbold("use the ^2slider controls^7, not the jump button!");
                                //self thread [[ &play_sound ]]("ammo_crate_use");
                            }
                        }
                        else
                            self thread [[ &execute_function ]](self.structure[cursor]["function"], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"], self.structure[cursor]["argument_4"], self.structure[cursor]["argument_5"]);

                        // self update_menu(menu, cursor); 
                        // only update the menu visually if not a array (?)
                        
                        cursor_struct = self.structure[cursor];
                        if (isdefined(cursor_struct))
                        {
                            if (isdefined(cursor_struct["toggle"]) || !istrue(cursor_struct["is_array"]))
                            {
                                self update_menu(menu, cursor);
                            }
                        }
                        
                    }
                    wait 0.18;
                }
            }
        }

        wait 0.05;
    }
}

function set_slider(scrolling, index)
{
    menu    = self get_menu();
    index   = isdefined(index) ? index : self get_cursor();
    storage = ( menu + "_" + index );

    if (isdefined(self.structure[index]["array"]))
    {
        self notify("slider_array");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage]++;
            if (scrolling == 1)
                self.slider[storage]--;
        }

        if (self.slider[storage] > (self.structure[index]["array"].size - 1))
            self.slider[storage] = 0;

        if (self.slider[storage] < 0)
            self.slider[storage] = (self.structure[index]["array"].size - 1);

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_ADDITIONAL_" + self.structure[index]["array"][self.slider[storage]]);
        }
    }
    else
    {
        self notify("slider_increment");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage] += self.structure[index]["increment"];
            if (scrolling == 1)
                self.slider[storage] -= self.structure[index]["increment"];
        }

        if (self.slider[storage] > self.structure[index]["maximum"])
            self.slider[storage] = self.structure[index]["minimum"];

        if (self.slider[storage] < self.structure[index]["minimum"])
            self.slider[storage] = self.structure[index]["maximum"];

        position = abs((self.structure[index]["maximum"] - self.structure[index]["minimum"])) / ((50 - 8));
        self.structure["current_index"] = self.structure[storage];

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            // TODO: sliders
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_STR12_" + slider_value);
        }

        self.menu["hud"]["slider"][2][index].x = (self.menu["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index]["minimum"])) / position) - 42);
    }
}

function clear_option()
{
    for (i = 0; i < self.element_list.size; i++)
    {
        clear_all(self.menu["hud"][self.element_list[i]]);
        self.menu["hud"][self.element_list[i]] = [];
    }
}

function clear_all(array)
{
    if (!isdefined(array))
        return;

    keys = getarraykeys(array);
    for (i = 0; i < keys.size; i++)
    {
        if (isarray(array[keys[i]]))
        {
            foreach (key in array[keys[i]])
                if (isdefined(key))
                    key destroy_element();
        }
        else if (isdefined(array[keys[i]]))
            array[keys[i]] destroy_element();
    }
}

function close_menu()
{
    self set_procedure();
    self clear_option();
    self clear_all(self.menu["hud"]);
    
    //is_prematch_done = game["flags"]["prematch_done"];
    //if (is_prematch_done)
    //    setslowmotion_wrapper(self custom_scripts\_util::getpers("slow_motion"), self custom_scripts\_util::getpers("slow_motion"), 0);

    self notify("exit_menu");
}

function update_scrolling(scrolling)
{
    cursor_index = self get_cursor();
    structure = self.structure[cursor_index];

    if (isdefined(structure) && istrue(structure["category"]))
    {
        self set_cursor((self get_cursor() + scrolling));
        return false;
    }

    if ((self.structure.size > self.option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0))
    {
        if ((self get_cursor() >= self.structure.size) || (self get_cursor() < 0))
            self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));

        self create_option();
    }

    self update_resize();

    return true;
}

function update_resize()
{
    limit    = min(self.structure.size, self.option_limit);
    height   = int((limit * self.option_spacing));
    adjust   = (self.structure.size > self.option_limit) ? int(((112 / self.structure.size) * limit)) : height;

    if ((height - adjust) > 0)
        position = (self.structure.size - 1) / (height - adjust);
    else
        position = 0;

    if (istrue(self.shader_option[self get_menu()]))
    {
        self.menu["hud"]["foreground"][1].y = (self.y_offset + 46);
        self.menu["hud"]["foreground"][1].x = (self.menu["hud"]["text"][self get_cursor()].x - 10);

        if (!isdefined(self.menu["hud"]["arrow"][0]))
            self.menu["hud"]["arrow"][0] = self create_shader("ui_scrollbar_arrow_left", "TOP_LEFT", "TOPCENTER", (self.x_offset + 10), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        if (!isdefined(self.menu["hud"]["arrow"][1]))
            self.menu["hud"]["arrow"][1] = self create_shader("ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 211), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        self.menu["hud"]["foreground"][2] destroy_element();
    }
    else
    {
        self.menu["hud"]["foreground"][1].y = (self.menu["hud"]["text"][self get_cursor()].y - 3);
        self.menu["hud"]["foreground"][1].x = (self.x_offset + 1);

        if (!isdefined(self.menu["hud"]["foreground"][2]))
            self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.6, 4);

        if (isdefined(self.menu["hud"]["arrow"][0])) self.menu["hud"]["arrow"][0] destroy_element();
        if (isdefined(self.menu["hud"]["arrow"][1])) self.menu["hud"]["arrow"][1] destroy_element();
    }

    self.menu["hud"]["background"][0] set_shader(self.menu["hud"]["background"][0].shader, self.menu["hud"]["background"][0].width, istrue(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? 66 : 50) : (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? (height + 34) : (height + 18)));
    self.menu["hud"]["background"][1] set_shader(self.menu["hud"]["background"][1].shader, self.menu["hud"]["background"][1].width, istrue(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? 64 : 48) : (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary) ? (height + 32) : (height + 16)));
    self.menu["hud"]["foreground"][0] set_shader(self.menu["hud"]["foreground"][0].shader, self.menu["hud"]["foreground"][0].width, istrue(self.shader_option[self get_menu()]) ? 32 : height);
    self.menu["hud"]["foreground"][1] set_shader(self.menu["hud"]["foreground"][1].shader, istrue(self.shader_option[self get_menu()]) ? 20 : 214, istrue(self.shader_option[self get_menu()]) ? 2 : 16);
    self.menu["hud"]["foreground"][2] set_shader(self.menu["hud"]["foreground"][2].shader, self.menu["hud"]["foreground"][2].width, adjust);

    if (isdefined(self.menu["hud"]["foreground"][2]))
    {
        self.menu["hud"]["foreground"][2].y = (self.y_offset + 16);
        if (self.structure.size > self.option_limit)
            self.menu["hud"]["foreground"][2].y += (self get_cursor() / position);
    }

    if (isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"].y = istrue(self.shader_option[self get_menu()]) ? (self.y_offset + 51) : (self.y_offset + ((limit * self.option_spacing) + 19));
}

function new_menu(menu)
{
    //if (self get_menu() == "manage clients")
    //{
    //    players = level.players;
    //    player = players[(self get_cursor())];
    //    self.select_player = player;
    //}

    if (!isdefined(menu))
    {
        menu = self.previous[(self.previous.size - 1)];
        self.previous[(self.previous.size - 1)] = undefined;
    }
    else
        self.previous[self.previous.size] = self get_menu();

    self set_menu(menu);
    self clear_option();
    self create_option();
}

function open_menu(menu)
{
    if (!isdefined(menu))
        menu = isdefined(self get_menu()) && self get_menu() != "cicada" ? self get_menu() : "cicada";

    // setup menu hud arrays
    if (!isdefined(self.menu["hud"]))
    {
        self.menu["hud"] = [];
        self.menu["hud"]["background"] = [];
        self.menu["hud"]["foreground"] = [];
        self.menu["hud"]["submenu"] = [];
        self.menu["hud"]["toggle"] = [];
        self.menu["hud"]["slider"] = [];
        self.menu["hud"]["category"] = [];
        // category indexes need init too tbh but wtv for now
        self.menu["hud"]["text"] = [];
        self.menu["hud"]["arrow"] = [];
    }

    if (!isdefined(self.slider))
        self.slider = [];

    self.menu["hud"]["title"]        = self create_text("MP/NEURA_TITLE_" + self get_title(), "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 1.75), self.color[4], 1, 10);
    // outline
    self.menu["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), 222, 34, self.current_menu_color, 0.6, 1);
    // top bar
    self.menu["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, 220, 32, self.color[1], 0.8, 2);
    // toggle box
    self.menu["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 220, 16, self.color[1], 0.05, 3);
    // cursor - use these for flickershaders?
    self.menu["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 214, 16, self.current_menu_color, 0.6, 4);
    // scrolling bar on the side
    //self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.4, 4);

    self set_menu(menu);
    self set_procedure();
    self create_option();

    //self thread [[ &flicker_shaders ]]();

    //is_prematch_done = game["flags"]["prematch_done"];
    //if (is_prematch_done)
    //    setslowmotion_wrapper(1, 1, 0);
}

function destroy_element()
{
    if (!isdefined(self))
        return;

    self destroy();
    if (isdefined(self.player))
        self.player.element_count--;
}

function set_text( text ) 
{
    if ( !isdefined( self ) || !isdefined( text ) )
        return;

    self.text = text;
    self settext( text );
}

function create_text(text, override, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sort)
{
    element                = self scripts\mp\hud_util::createfontstring(font, font_scale);
    if (isdefined(element))
    {
        element.color          = color;
        element.alpha          = alpha;
        element.sort           = sort;
        element.player         = self;
        element.archived       = false; // should_archive

        element.foreground     = true;
        element.hidewheninmenu = false;
        element.showinkillcam = 0;

        element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
        element set_text(text);

        self.element_count++;
    }

    return element;
}

function create_shader(shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sort)
{
    element                = newclienthudelem(self);
    element.elemtype       = "icon";
    element.children       = [];
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = false; //self should_archive();
    element.foreground     = true;
    element.hidden         = false;
    element.hidewheninmenu = true;

    element scripts\mp\hud_util::setparent(level.uiparent);
    element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
    element set_shader(shader, width, height);
    
    self.element_count++;

    return element;
}

function update_menu(menu, cursor, force)
{
    if (isdefined(menu) && !isdefined(cursor) || !isdefined(menu) && isdefined(cursor))
        return;

    if (isdefined(menu) && isdefined(cursor))
    {
        foreach (player in level.players)
        {
            if (!isdefined(player) || !player in_menu())
                continue;

            if (player get_menu() == menu || self != player && player is_option(menu, cursor, self))
                if (isdefined(player.menu["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isdefined(player.menu["hud"]["text"][cursor]) || self != player && player is_option(menu, cursor, self) || istrue(force))
                    player create_option();
        }
    }
    else
    {
        if (isdefined(self) && self in_menu())
            self create_option();
    }
}

function is_option(menu, cursor, player)
{
    if (isdefined(self.structure) && self.structure.size)
        for (i = 0; i < self.structure.size; i++)
            if (player.structure[cursor]["text"] == self.structure[i]["text"] && self get_menu() == menu)
                return true;

    return false;
}

function add_menu(title, shader)
{
    if (isdefined(title))
        self set_title(title);

    if (!isdefined(self.shader_option)) // shader_option needs to be defined before you try to add stuff to it
        self.shader_option = [];

    if (isdefined(shader))
        self.shader_option[self get_menu()] = true;

    self.structure = [];
}

function execute_function(func, argument_1, argument_2, argument_3, argument_4, argument_5)
{
    if (!isdefined(func))
        return;

    if (isdefined(argument_5))
        return self thread [[func]](argument_1, argument_2, argument_3, argument_4, argument_5);

    if (isdefined(argument_4))
        return self thread [[func]](argument_1, argument_2, argument_3, argument_4);

    if (isdefined(argument_3))
        return self thread [[func]](argument_1, argument_2, argument_3);

    if (isdefined(argument_2))
        return self thread [[func]](argument_1, argument_2);

    if (isdefined(argument_1))
        return self thread [[func]](argument_1);

    return self thread [[func]]();
}

function set_shader(shader, width, height)
{
    self.shader = shader;
    self.width  = width;
    self.height = height;
    self setshader(shader, width, height);
}

function override_string_for_index(index)
{
    switch(index)
    {
        case 1:
            return "MP_INGAME_ONLY/HOLD_TO_START_GAME";
        case 2:
            return "MP_INGAME_ONLY/HQ_NEXT_IN";
        case 3:
            return "MP_INGAME_ONLY/HQ_NO_RESPAWN";
        case 4:
            return "MP_INGAME_ONLY/HQ_REINFORCEMENTS_IN";
        case 5:
            return "MP_INGAME_ONLY/HQ_TIME_REMAINING";
        case 6:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_1";
        case 7:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_10";
        case 8:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_11";
        case 9:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_12";
        case 10:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_13";
        case 11:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_14";
        case 12:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_15";
        case 13:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_16";
        case 14:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_17";
        default:
            return undefined;
    }
}

sym()
{
    symbols = ["߽"]; // array for rn
    symbol = symbols[randomint(symbols.size)];
    return symbol + " ";
}

function create_title(title)
{
    title_ = isdefined(title) ? title : self get_title();
    self.menu["hud"]["title"] set_text("MP/NEURA_TITLE_" + sym() + title_);
}

function create_summary(summary)
{
    if (isdefined(self.menu["hud"]["summary"]) && !istrue(self.option_summary) || !isdefined(self.structure[self get_cursor()]["summary"]) && isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"] destroy_element();

    if (isdefined(self.structure[self get_cursor()]["summary"]) && istrue(self.option_summary))
    {
        summary_ = tolower(isdefined(summary) ? summary : self.structure[self get_cursor()]["summary"]);
        lol_ = "MP/NEURA_INFO_" + "ߵ " + summary_;
        if (!isdefined(self.menu["hud"]["summary"]))
            self.menu["hud"]["summary"] = self create_text(lol_, "MP_INGAME_ONLY/HQ_AVAILABLE_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 35), self.color[4], 1, 10);
        else
            self.menu["hud"]["summary"] set_text(lol_);
    }
}

function create_option()
{
    self clear_option();
    structure();

    if (!isdefined(self.structure) || !self.structure.size)
        self add_option("nothing to display..");

    if (!isdefined(self get_cursor()))
        self set_cursor(0);

    start = 0;
    if ((self get_cursor() > int(((self.option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.option_limit + 1) / 2)))) && (self.structure.size > self.option_limit))
        start = (self get_cursor() - int((self.option_limit - 1) / 2));

    if ((self get_cursor() > (self.structure.size - (int(((self.option_limit + 1) / 2)) + 1))) && (self.structure.size > self.option_limit))
        start = (self.structure.size - self.option_limit);

    self create_title();
    if (istrue(self.option_summary))
        self create_summary();

    if (isdefined(self.structure) && self.structure.size)
    {
        limit = min(self.structure.size, self.option_limit);
        for (i = 0; i < limit; i++)
        {
            index      = (i + start);
            cursor     = (self get_cursor() == index);
            color[0] = cursor ? self.color[0] : self.color[4];
            color[1] = istrue(self.structure[index]["toggle"]) ? cursor ? self.color[0] : (1,1,1) : cursor ? self.color[2] : self.color[1];

            // new menu text
            if (isdefined(self.structure[index]["function"]) && self.structure[index]["function"] == &new_menu)
                self.menu["hud"]["submenu"][index] = self create_text("MP/NEURA_STR14_>", "MP_INGAME_ONLY/OBJ_HVT_CAPS_17", self.font, 0.65, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), color[0], 1, 10);
            if (isdefined(self.structure[index]["toggle"]))
            {
                self.menu["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 204), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, color[1], .65, 10);
                // self.menu["hud"]["current_toggle_index"] = self.menu["hud"]["toggle"][index];
            }

            if (istrue(self.structure[index]["slider"]))
            {
                storage = (self get_menu() + "_" + index);
                self.slider[storage] = isdefined(self.structure[index]["array"]) ? 0 : self.structure[index]["start"];

                if (isdefined(self.structure[index]["array"]))
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.structure[index]["array"][ self.slider[storage] ], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 210), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                    }
                }
                else
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.slider[storage], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, (self.font_scale), "CENTER", "TOPCENTER", (self.x_offset + 187), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[4], 1, 10);
                    }

                    self.menu["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), 50, 8, cursor ? self.color[2] : self.color[1], 1, 8);
                    self.menu["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 170), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, cursor ? self.color[0] : self.color[3], 1, 9);
                }

                // idek what this does but Ok
                self set_slider(undefined, index);
            }

            if (istrue(self.structure[index]["category"]))
            {
                og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                override_string = override_string_for_index(i + 1);

                self.menu["hud"]["category"][0][index] = self create_text(og_string, override_string, self.font, self.font_scale, "CENTER", "TOPCENTER", (self.x_offset + 102), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[0], 1, 10);
                self.menu["hud"]["category"][1][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
                self.menu["hud"]["category"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
            }
            else
            {
                menu = self get_menu();
                shader_option = self.shader_option[menu];
                if (istrue(shader_option))
                {
                    shader = isdefined(self.structure[index]["text"]) ? self.structure[index]["text"] : "white";
                    color  = isdefined(self.structure[index]["argument_1"]) ? self.structure[index]["argument_1"] : (1, 1, 1); // come back
                    width  = isdefined(self.structure[index]["argument_2"]) ? self.structure[index]["argument_2"] : 20;
                    height = isdefined(self.structure[index]["argument_3"]) ? self.structure[index]["argument_3"] : 20;
                    self.menu["hud"]["text"][index] = self create_shader(shader, "CENTER", "TOPCENTER", (self.x_offset + ((i * 24) - ((limit * 10) - 109))), (self.y_offset + 32), width, height, color, 1, 10);
                }
                else
                {
                    menu_text = (istrue(self.structure[index]["slider"]) ? self.structure[index]["text"]/*+":"*/ : self.structure[index]["text"]);
                    if (self get_menu() != "manage clients")
                        menu_text = tolower(menu_text);

                    og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                    override_string = override_string_for_index(i + 1);

                    self.menu["hud"]["text"][index] = self create_text(og_string, override_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isdefined(self.structure[index]["toggle"]) ? (self.x_offset + 4) : (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                }
            }
        }

        if (!isdefined(self.menu["hud"]["text"][self get_cursor()]))
            self set_cursor((self.structure.size - 1));
    }

    self update_resize();
}

function button_monitor(button)
{
    self endon("disconnect");
    level endon("game_ended");

    self.button_pressed[button] = false;
    self notifyonplayercommand("button_pressed_" + button, button);

    while (true)
    {
        self waittill("button_pressed_" + button);
        self.button_pressed[button] = true;
        wait 0.05;
        self.button_pressed[button] = false;
    }
}

function monitor_buttons() 
{
    self endon("disconnect");
    level endon("game_ended");

    self.button_actions = list("frag,smoke,special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");
    self.button_pressed = [];

    for (a = 0; a < self.button_actions.size; a++)
    {
        self thread [[ &button_monitor ]]("+" + self.button_actions[a]);
        self thread [[ &button_monitor ]]("-" + self.button_actions[a]); // this usually works as a fallback to many of these, this is the release bind
    }
}

function isButtonPressed(button)
{
    if (!isdefined(self.button_pressed))
        self.button_pressed = [];
    if (!isdefined(self.button_pressed[button]))
        self.button_pressed[button] = false;
    return self.button_pressed[button];
}

function list(key)
{
    token = strtok(key, ",");
    return token;
}

// og leftover
function main()
{

}
