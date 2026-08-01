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

function list(text)
{
    return strtok(text, ",");
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

    self.button_actions = list("frag,smoke,special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");
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
