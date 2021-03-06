package hkssprangers.server;

import react.*;
import react.Fragment;
import react.ReactMacro.jsx;
import haxe.io.Path;
import js.npm.express.*;
import hkssprangers.server.ServerMain.*;
using Lambda;
using StringTools;
using hkssprangers.server.ExpressTools;

class LogIn extends View {
    public var tgBotName(get, never):String;
    function get_tgBotName() return props.tgBotName;

    override function title():String return "登入";
    override public function description() return "登入";
    override function canonical() return Path.join([domain, "login"]);
    override public function render() {
        return super.render();
    }

    override function bodyContent() {
        return jsx('
            <div>
                <div className="text-center">
                    <a href="/"><img id="logo" src=${R("/images/ssprangers4-y.png")} className="rounded-circle" alt="埗兵" /></a>
                </div>
                <div id="LogInView"
                    data-tg-bot-name=${tgBotName}
                />
            </div>
        ');
    }

    static public function middleware(req:Request, res:Response) {
        var tgBotInfo = tgBot.telegram.getMe();
        tgBotInfo.then(tgBotInfo ->
            res.sendView(LogIn, {
                tgBotName: tgBotInfo.username,
            }))
            .catchError(err -> res.status(500).json(err));
    }
}