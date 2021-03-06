package hkssprangers.server;

import react.*;
import react.Fragment;
import react.ReactMacro.jsx;
import haxe.io.Path;

class Index extends View {
    public var tgBotName(get, never):String;
    function get_tgBotName() return props.tgBotName;

    override public function description() return "深水埗區外賣團隊";
    override function canonical() return domain;
    override public function render() {
        return super.render();
    }

    override function ogMeta() return jsx('
        <Fragment>
            <meta name="twitter:card" content="summary_large_image" />
            ${super.ogMeta()}
            <meta property="og:type" content="website" />
            <meta property="og:image" content=${Path.join([domain, R("/images/ssprangers4-y.png")])} />
        </Fragment>
    ');

    override function bodyContent() {
        return jsx('
            <div>
                <div className="text-center">
                    <a href="/"><img id="logo" src=${R("/images/ssprangers4-y.png")} className="rounded-circle" alt="埗兵" /></a>
                </div>
                <div id="CustomerView"
                    data-tg-bot-name=${tgBotName}
                />
            </div>
        ');
    }
}