package GameBalls {
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class Server {

    private static const url:String = "https://serverballs.herokuapp.com/";//"http://localhost:3000/";
    private static const ballUrl:String = "balls";
    private static const playerUrl:String = "players";

    public function Server() {
    }

    private static function setRequest(urlRequest:String, method:String, variables:URLVariables, func:*, format:String="xml"):void {
        var request:URLRequest = new URLRequest();
        request.url = urlRequest;
        request.requestHeaders = [new URLRequestHeader("Content-Type", "application/"+ format)];
        request.method = method;
        variables.format = format;

        request.data = variables;
        var loader:URLLoader = new URLLoader();
        if (func == null)
            func = onComplete;
        loader.addEventListener(Event.COMPLETE, func);
        loader.load(request);
    }

    public static function onComplete(e:Event):void
    {
        trace (e);
    }

    private static function playerRequestVariables(player:PlayerBall):URLVariables
    {
        var variables:URLVariables = new URLVariables();
        variables.idplayer = player.ID;
        variables.Name = player.Name;
        variables.x = player.x;
        variables.y = player.y;
        variables.radius = player.Radius;
        return variables;
    }

    public static function getBall(func:*):void
    {
        var variables:URLVariables = new URLVariables();
        setRequest(url + ballUrl + "/getballdata", URLRequestMethod.GET, variables, func);
    }

    public static function removeBall(ball:Ball):void
    {
        var variables:URLVariables = new URLVariables();
        variables.id = ball.ID;
        setRequest(url + ballUrl + "/removeball", URLRequestMethod.GET, variables, null, 'json');
    }

    // Регистрация нового игрока
    public static function getPlayer(player:PlayerBall, func:*):void
    {
        var variables:URLVariables = playerRequestVariables(player);
        setRequest(url + playerUrl + "/getplayer", URLRequestMethod.GET, variables, func, 'json');
    }

    public static function removePlayer(player:PlayerBall):void
    {
        var variables:URLVariables = playerRequestVariables(player);
        setRequest(url + playerUrl + "/removeplayer", URLRequestMethod.GET, variables, null, 'json');
    }

    public static function removePlayerForID(id:int, func:*):void
    {
        var variables:URLVariables = new URLVariables();
        variables.idplayer = id;
        setRequest(url + playerUrl + "/removeplayer", URLRequestMethod.GET, variables, func, 'json');
    }

    public static function movePlayer(player:PlayerBall):void
    {
        var variables:URLVariables = playerRequestVariables(player);
        setRequest(url + playerUrl + "/moveplayer", URLRequestMethod.GET, variables, null, 'json');
    }

    public static function getPlayers(func:*):void
    {
        var variables:URLVariables = new URLVariables();
        setRequest(url + playerUrl + "/getplayersdata", URLRequestMethod.GET, variables, func);
    }

}
}
