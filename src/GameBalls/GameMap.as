package GameBalls {

import GameBalls.MoveBall;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class GameMap extends Sprite {
    public static const SCR_WIDTH:int = 50;
    public static const SCR_HEIGHT:int = 50;

    public static const CELL_SIZE:int = 10;
    public static const DECAY:Number = .1;
    public static const MAP_W:int = 70;
    public static const MAP_H:int = 70;

    public static const COUNT_GOODBALL:int = 100;

    public var Scene:Sprite = new Sprite();
    private var _speedX:Number = 0;
    private var _speedY:Number = 0;

    /* Размер карты */
    public static var _mapWidth:int = MAP_W * CELL_SIZE;
    public static var _mapHeight:int = MAP_H * CELL_SIZE;

    private var moveTimer:Timer = new Timer(1000);

    /* Конструктор */
    public function GameMap()
    {
        super();
        addChild(Scene);
        /* Создаем игровую сетку */
        Server.getBall(onGetBall);
        grid(MAP_W, MAP_H);

        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        moveTimer.start();
        moveTimer.addEventListener(TimerEvent.TIMER, timerHandler);
        //MoveBall._PlayerBalls = new Dictionary();
        //MoveBall._gameMap = this;
    }

    // Загрузка шаров с сервера
    private function onGetBall(e:Event):void
    {
        var xml:XML = new XML(e.target.data);
        setBallonMap(xml);
    }

    // Загрузка игроков с сервера
    private function onGetPlayers(e:Event):void
    {
        var xml:XML = new XML(e.target.data);
        setPlayerMap(xml);

    }

    // Расстановка шаров на карту
    private function setBallonMap(xml:XML):void
    {
        var len:int = xml.ball.length();
        var circle:Ball;

        var typeball:int;
        var id:int;
        var pos_x:Number;
        var pos_y:Number;
        var color:int;

        for (var i:int = 0; i < len; i++)
        {
            typeball = xml.ball[i].typeball;
            id = xml.ball[i].id;
            pos_x = xml.ball[i].x;
            pos_y = xml.ball[i].y;
            color = xml.ball[i].color;

            // Создаем обьекты
            switch (typeball){
                case 1:
                    circle = new GoodBall(((pos_x+1) * CELL_SIZE)-(CELL_SIZE/2), ((pos_y+1) * CELL_SIZE)-(CELL_SIZE/2));
                    break;
                case 2:
                    circle = new BadBall(((pos_x+1) * CELL_SIZE)-(CELL_SIZE/2), ((pos_y+1) * CELL_SIZE)-(CELL_SIZE/2));
                    break;
                default:
                    circle = null;
            }
            if (circle != null)
            {
                circle.ID = id;
                circle.Color = color;
                circle.draw();
                Scene.addChild(circle);
            }
        }
    }

    // Функция обновления данных по игрокам
    public function setPlayerMap(xml:XML):void
    {
        var len:int = xml.player.length();
        var mb:MoveBall;
        var idplayers:Array = new Array();
        var idplayer:int;
        var name:String;
        var pos_x:Number;
        var pos_y:Number;
        var color:int;
        var score:int;
        var radius:Number;

        for (var i:int = 0; i < len; i++)
        {
            idplayer = xml.player[i].idplayer;
            name = xml.player[i].name;
            pos_x = xml.player[i].x;
            pos_y = xml.player[i].y;
            color = xml.player[i].color;
            score = xml.player[i].score;
            radius = xml.player[i].radius;

            idplayers.push(idplayer);

            if (PlayerBall._Player.ID == idplayer) break;

            if (MoveBall._RemovePlayer != null && MoveBall._RemovePlayer.ID == idplayer) break;



            // Проверяем списки игроков
            if (MoveBall._PlayerBalls[idplayer] == null)
            {
                // Появился новый игрок, добавляем его на карту
                mb = new MoveBall(pos_x, pos_y);
                mb.ID = idplayer;
                mb.Name = name;
                mb.Color = color;
                mb.Radius = radius;
                mb.Score = score;
                mb.draw();
                MoveBall._PlayerBalls[idplayer] = mb;
                this.addChild(mb);
            } else // Игрок уже на поле
                mb = MoveBall._PlayerBalls[idplayer];
            // Перемещаем игрока
            mb.movePlayer(pos_x, pos_y);
        }

        /*
        // Удаляем из списка игроков которых больше нет
        for each(var item:MoveBall in MoveBall._PlayerBalls)
        {
            if (idplayers.indexOf(item.ID) == -1)
            {
                delete MoveBall._PlayerBalls[item.ID];
                this.removeChild(item);
            }

        }
        */

    }

    // Функция масштабирования карты для игрока
    public function scaleFromPlayer(scale:Number):void
    {
        // Устанавливаем масштаб
        scaleX = scale;
        scaleY = scale;
    }


    public function hScroll(val:Number):void
    {
        _speedX += val;
    }

    public function vScroll(val:Number):void
    {
        _speedY += val;
    }

    public function get mapWidth():int
    {
        return _mapWidth;
    }

    public function get mapHeight():int
    {
        return _mapHeight;
    }

    // Движение камеры следящей за игроком
    private function enterFrameHandler(e:Event):void
    {
        /* Прибавляем скорость к положению карты */
        x += int(_speedX);
        y += int(_speedY);

        /* Горизонтальная прокрутка */
        if (x > 0) // Выезд за левый край
        {
            x = 0;
            _speedX = 0;
        }
        else if (x - stage.stageWidth < -_mapWidth * scaleX) // Выезд за правый край
        {
            x = -_mapWidth * scaleX + stage.stageWidth ;
            _speedX = 0;
        }

        /* Вертикальная прокрутка */
        if (y > 0) // Выезд за верхний край
        {
            y = 0;
            _speedY = 0;
        }
        else if (y - stage.stageHeight < -_mapHeight * scaleY) // Выезд за нижний край
        {
            y = -_mapHeight * scaleY + stage.stageHeight;
            _speedY = 0;
        }

        /* Применяем торможение к скорости */
        _speedX *= DECAY;
        _speedY *= DECAY;

        // Запрашиваем положение игроков
        //Server.getPlayers(onGetPlayers);
    }

    private function timerHandler(e:TimerEvent):void
    {
        Server.getPlayers(onGetPlayers);
    }


    private function grid(w:int, h:int):void
    {
        /* Создание игровой сетки */
        //var circle:Ball;
        //var color:int;
        for (var y:int = 0; y < h; y++)
        {
            for (var x:int = 0; x < w; x++)
            {
                Scene.graphics.lineStyle(0.1, 0x413731);
                Scene.graphics.beginFill(25468, 1);
                Scene.graphics.drawRect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);

                /*
                 var rand:Number = Math.random();

                 // Устанавливаем хорошие шары
                 if (rand < 0.5)  // 0.7
                 {
                 //color = int((rand * 10) + 1);
                 circle = new GoodBall(((x+1) * CELL_SIZE)-(CELL_SIZE/2), ((y+1) * CELL_SIZE)-(CELL_SIZE/2));
                 }

                 // Устанавливаем плохие шары
                 if (rand > 0.99)
                 {
                 circle = new  BadBall(((x+1) * CELL_SIZE)-(CELL_SIZE/2), ((y+1) * CELL_SIZE)-(CELL_SIZE/2));
                 }

                 if (circle != null)
                 {
                 circle.draw();
                 Scene.addChild(circle);
                 }
                 */
            }
        }
        this.addChild(Scene);
    }





    }
}
