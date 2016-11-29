function FindProxyForURL(url, host) {
    /*
chrome://net-internals/proxyservice.config#proxy
chrome://settings/searchEngines
    */
    var jsquid = "PROXY 127.0.0.1:23131";
    var ntlsmap = "PROXY 127.0.0.1:23132";

    var direct = "DIRECT";
    if (false) // network ly down
    {    jsquid = direct;
        ntlsmap = direct;
    }
    if (shExpMatch(host, "(*.google.com|google.com|google.ch|*.google.ch|gmail.com|*.gmail.com|gstatic.com|*.gstatic.com|*.googleusercontent.com|googleusercontent.com)"))
    {    return jsquid;
    }
    if (shExpMatch(host, "(jzoneminder)"))
    {    return jsquid;
    }
    if (shExpMatch(host, "(*.dtdg.co)")) // datadog registration
    {    return jsquid;
    }
    if (shExpMatch(host, "(*.deezer.com|deezer.com|deezer.ch|*.deezer.ch|deezer.fr|*.deezer.fr)"))
    {    return ntlsmap;
        return direct;
    }
    return direct;
}
