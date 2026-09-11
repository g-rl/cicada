#using scripts\engine\trace;

#namespace cicada_util;

function getpers(key)
{
    if (!isdefined(self.pers) || !isdefined(self.pers["cicada"]))
        return undefined;

    return self.pers["cicada"][key];
}

function setpers(key, value)
{
    if (!isdefined(self.pers))
        self.pers = [];

    if (!isdefined(self.pers["cicada"]))
        self.pers["cicada"] = [];

    self.pers["cicada"][key] = value;
}

function initpers(key, value)
{
    if (!isdefined(self getpers(key)))
        self setpers(key, value);
}

function flippers(key)
{
    self setpers(key, !istrue(self getpers(key)));
    return self getpers(key);
}

function getpersint(key)
{
    value = self getpers(key);
    return isdefined(value) ? int(value) : 0;
}

function getpersfloat(key)
{
    value = self getpers(key);
    return isdefined(value) ? float(value) : 0;
}

function mapkey(key)
{
    return key + "@" + getdvar("g_mapname");
}

function getmappers(key)
{
    return self getpers(mapkey(key));
}

function setmappers(key, value)
{
    self setpers(mapkey(key), value);
}

function getmappersint(key)
{
    return self getpersint(mapkey(key));
}

function list(text)
{
    return strtok(text, ",");
}

function stop_event(key)
{
    return "cicada_stop_" + key;
}

function warn(text)
{
    return "ߨ " + text;
}

function message(text)
{
    if (!istrue(self getpers("messages")))
        return;

    self iprintln(text);
}

function message_bold(text)
{
    if (!istrue(self getpers("messages")))
        return;

    self iprintlnbold(text);
}

function sound(name)
{
    if (!istrue(self getpers("sounds")) || !soundexists(name))
        return;

    self playlocalsound(name);
}

function in_menu()
{
    return istrue(self.in_menu);
}

function is_bot(ent)
{
    return isdefined(ent) && (isbot(ent) || isai(ent));
}

function enemy_player()
{
    foreach (player in level.players)
        if (player != self && player.team != self.team && isalive(player))
            return player;

    return self;
}

function crosshair()
{
    eye = self geteye();
    return trace::_bullet_trace(eye, eye + anglestoforward(self getplayerangles()) * 100000, 0, self)["position"];
}

function player_name()
{
    name = self.name;
    if (name[0] != "[")
        return name;

    for (i = (name.size - 1); i >= 0; i--)
        if (name[i] == "]")
            break;

    return getsubstr(name, 0, (i + 1));
}

function prematch_done()
{
    return istrue(game["flags"]["prematch_done"]);
}

function wait_prematch()
{
    while (!self prematch_done())
        wait 0.05;
}

function get_current_build()
{
    return level._client + " ^7(^:" + level._client_version + "^7)";
}

function button_monitor(button)
{
    self endon("disconnect");
    level endon("game_ended");

    self.button_pressed[button] = false;
    self notifyonplayercommand("button_pressed_" + button, button);

    for (;;)
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

    self.button_actions = list("frag,smoke,special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,usereload,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");
    self.button_pressed = [];

    for (i = 0; i < self.button_actions.size; i++)
    {
        self thread [[&button_monitor]]("+" + self.button_actions[i]);
        self thread [[&button_monitor]]("-" + self.button_actions[i]);
    }
}

function isbuttonpressed(button)
{
    if (!isdefined(self.button_pressed) || !isdefined(self.button_pressed[button]))
        return false;

    return self.button_pressed[button];
}

function trim_start(text, prefix)
{
    if (!isstartstr(text, prefix))
        return text;

    return getsubstr(text, prefix.size, text.size);
}

function trim_end(text, tail)
{
    if (!isendstr(text, tail))
        return text;

    return getsubstr(text, 0, text.size - tail.size);
}

function before_mark(text, mark)
{
    if (!isdefined(text))
        return text;

    for (i = 0; i < text.size; i++)
        if (text[i] == mark)
            return getsubstr(text, 0, i);

    return text;
}

function after_mark(text, mark)
{
    if (!isdefined(text))
        return text;

    found = -1;

    for (i = 0; i < text.size; i++)
        if (text[i] == mark)
            found = i;

    if (found < 0 || found >= text.size - 1)
        return text;

    return getsubstr(text, found + 1, text.size);
}

function shorten(text, limit)
{
    if (!isdefined(limit))
        limit = 20;

    if (text.size <= limit)
        return text;

    return getsubstr(text, 0, limit);
}

function unique_in(taken, label)
{
    count = 0;

    foreach (used in taken)
        if (used == label)
            count++;

    if (!count)
        return label;

    return label + count;
}
