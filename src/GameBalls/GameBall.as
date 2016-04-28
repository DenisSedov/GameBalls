package GameBalls {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Point;
import vk.APIConnection;

[SWF(width="600", height="600", frameRate="31", backgroundColor="#FFFFFF")]
public class GameBall extends Sprite {

    private var _gameMap:GameMap;
    private var _playerBall:PlayerBall;

    private var nKeyDown:Array = [];

    private var flashVars:Object;
    private var VK: APIConnection;

    private function fetchUserInfo(data: Object): void
    {
        _playerBall.Name = data[0]['first_name'];
    }

    private function onApiRequestFail(data: Object): void
    {
        // Example of fetching fail from API request
        //tf.appendText("Error: "+data.error_msg+"\n");
    }

    public function GameBall()
    {
        if (stage)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e: Event = null): void
    {
        if (e)
            removeEventListener(e.type, init);

        flashVars = stage.loaderInfo.parameters as Object;

        if (flashVars.api_id == null)
        {
            flashVars['api_id'] = 5436929;
            flashVars['viewer_id'] = 29421457;
            flashVars['sid'] = "e2e37ce1b9c4eceac2215f0fcde5e7e31905436fde20e5c7a5a5b95c333600553b466957807c522579c84";
            flashVars['secret'] = "4721d0d3b4";
        }


        VK = new APIConnection(flashVars);

        VK.api('getProfiles', { uids: flashVars['viewer_id'] }, fetchUserInfo, onApiRequestFail);

        //MoveBall.testInit();
        //MoveBall.loadPlayers(null);

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP;
        trace("добро пожаловать в игру");

        /* Создание игровой карты */
        _gameMap = new GameMap();
        addChild(_gameMap);
        /* Создаем игровой объект */
        _playerBall = new PlayerBall(_gameMap, flashVars['viewer_id'], flashVars['viewer_id']);


        /* Перехватчик нажатия кнопок */
        //stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        //stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);

        stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        stage.nativeWindow.addEventListener(Event.CLOSING, onClosing);
    }

    private function onClosing(e:Event):void
    {
        trace("Exit");
        _playerBall.removePlayer();
    }

    // Добавить новый код клавиши
    private function pushKey(key:int):void
    {
        var pos:int = nKeyDown.indexOf(key);
        if (pos >= 0) return;
        nKeyDown.push(key);
    }

    private function enterFrameHandler(e:Event):void
    {
        moveToMouse();
    }

    private function moveToMouse():void
    {
        var p:Point = globalToLocal(new Point(_playerBall.x, _playerBall.y));

        var delta:Number = 2;
        var dx:Number = Math.abs(_gameMap.mouseX - p.x);
        var dy:Number = Math.abs(_gameMap.mouseY - p.y);

        if (dx > delta)
        {
            if (_gameMap.mouseX > p.x)
                _playerBall.hScroll(1); // Влево
            else
                _playerBall.hScroll(-1); // Вправо
        }

        if (dy > delta)
        {
            if (_gameMap.mouseY > p.y)
                _playerBall.vScroll(1); // Вверх
            else
                _playerBall.vScroll(-1); // Вниз
        }
    }

    private function keyUpHandler(e:KeyboardEvent):void
    {
        var pos:int = nKeyDown.indexOf(e.keyCode);
        if (pos < 0) return;
        // Удаляем элемент
        nKeyDown.splice(pos, 1);
    }

    private function keyDownHandler(e:KeyboardEvent):void
    {
        pushKey(e.keyCode);
        for each(var value:int in nKeyDown)
        {
            switch (value)
            {
                case 39 : _playerBall.hScroll(1); break; // Влево
                case 37 : _playerBall.hScroll(-1); break; // Вправо
                case 40 : _playerBall.vScroll(1); break; // Вверх
                case 38 : _playerBall.vScroll(-1); break; // Вниз
            }
        }
    }

}

}
