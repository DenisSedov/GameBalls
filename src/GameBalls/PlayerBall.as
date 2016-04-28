package GameBalls {

import GameBalls.MoveBall;

import flash.display.MovieClip;
    import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.Timer;

import json.JSON;

    // Класс игрока
    public class PlayerBall extends MovieClip
    {
        // Начальный радиус игрока
        private const CONST_RADIUS:int = 10;
        // Коэффициент начальной скорости
        private const CONST_GROWTHRATE:Number = 1;
        // Коэффициент уменьшения игрока при разрушении
        private const CONST_COEFDISTROY:Number = .5;
        // Коэффициент масштаба игрока
        private const CONST_SCALE:Number = 5;

        private var _Radius:Number = CONST_RADIUS;
        private var _Name:String = 'test';
        private var _Scale:Number = CONST_SCALE;
        private var _ID:int; // Идентификатор игрока
        public var _Speed:Number = 1; // Скорость игрока
        public var _Score:int = 0;
        public var _Color:int = -1;

        private var _gameMap:GameMap; // Ссылка на карту
        private var _textfield:TextField = new TextField();
        private var removeTimer:Timer = new Timer(1000);

        // Список всех неподвижных шаров на поле
        public static var _Player:PlayerBall;

        public function get ID():int
        {
            return _ID;
        }

        public function get Name():String
        {
            return _Name;
        }

        public function set Name(value:String):void
        {
            _Name = value;
        }

        /* Свойства класса */
        public function get Scale():Number
        {
            return _Scale;
        }

        public function set Scale(value:Number):void
        {
            _Scale = value;
            // При резком изменении размера, плавно меняем масштаб
            _gameMap.scaleFromPlayer(value);
        }

        public function PlayerBall(gm:GameMap, idplayer:int, nameplayer:String)
        {
            _gameMap = gm;
            _ID = idplayer;
            _Name = nameplayer;
            setPlayer();
        }

        private function setPlayer():void
        {
            _gameMap.addChild(this); // Добавляем объект в игровую карту
            _gameMap.scaleFromPlayer(Scale);
            _Player = this;
            Server.getPlayer(this, onCompletePlayer);
            removeTimer.start();
            removeTimer.addEventListener(TimerEvent.TIMER, timerHandler);
        }

        private function onCompletePlayer(e:Event):void
        {
            // Установка данных
            var variables:Object =  json.JSON.decode(e.target.data);
            _Color = variables.color;
            _Score = variables.score;
            x = variables.x;
            y = variables.y;
            addChild(_textfield);
            draw();
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }

        public function removePlayer():void
        {
            Server.removePlayer(this);
        }

        // Отрисовка
        public function draw():void
        {
            graphics.clear();
            graphics.beginFill(_Color);
            graphics.drawCircle(0,0, _Radius);
            graphics.endFill();

            // Надписи
            _textfield.text = _Name + ' ' + _Score.toString();
            _textfield.x = (_Radius - _textfield.textWidth)/2; // center it horizontally
            _textfield.y = (_Radius - _textfield.textHeight)/2; // center it vertically
        }

        // Функция получения радиуса
        public function get Radius():Number
        {
            return _Radius;
        }

        public function set Radius(value:Number):void
        {
            if (value < CONST_RADIUS)
                value = CONST_RADIUS;
            _Radius = value;
            // Изменяем скорость
            _Speed = CONST_RADIUS/_Radius;
            resizePlayer();
        }

        // Функция изменение размера игрока и сопутствующие изменения
        public function resizePlayer():void
        {
            // Изменяем масштаб относительно размера игрока
            Scale = Math.sqrt(Math.pow(CONST_SCALE,2)-_Radius*0.5);
        }

        // Функция поедания шариков
        public function eatBall(b:Ball):void
        {
            //Убираем шарик из списка
            b.removeBall();
            //Изменяем значение
            _Score += b.Score;
            //Делаем приращение
           // var R:Number = Math.sqrt(Math.pow(CONST_RADIUS,2)+_score)*0.1;
            Radius += b.Score*0.05;
            draw();
        }

        // Разбиение шарика
        public function destroyBall(b:Ball):void
        {
            //Убираем шарик из списка
            b.removeBall();
            // Уменьшаем радиус игрока
            Radius *= CONST_COEFDISTROY;
            _Score *= CONST_COEFDISTROY;
            draw();
            // Создаем новые шарики игрока
            DividedBall.dotingBall(this);
        }

        // Проверяет наложение шаров и возвращает которые перекрыли
        public function getImposition():Array
        {
            // Получаем списов шаров для проверки
            var balls:Array = getEnvironment();
            var res:Array = new Array();
            var R:int = _Radius;
            for each(var item:Ball in balls)
            {
                // Проверяем полное перекрытие
                if (R > item.getDistance(this))
                    res.push(item);
            }
            // Проверяем оторвавшиеся части
            for each(var item2:DividedBall in DividedBall._dividedBall)
            {
                if (R > item2.getDistance(this))
                    res.push(item2);
            }
            // Проверяем других игроков
            var indexPlayer:int;
            var indexMoveBall:int;
            for each(var item3:MoveBall in MoveBall._PlayerBalls)
            {
                // Расставляем слои
                if (item3.Radius <= Radius)
                {
                    indexPlayer = parent.getChildIndex(this);
                    indexMoveBall = item3.parent.getChildIndex(item3);
                    if (indexMoveBall >= indexPlayer)
                    {
                        parent.setChildIndex(this,  indexMoveBall);
                        item3.parent.setChildIndex(item3, indexPlayer)
                    }
                }
                // Проверяем полное перекрытие
                if (R > item3.getDistance(this))
                    res.push(item3);
            }
            return res;

        }

        // Получить ближайшее окружение для поиска ближайших шаров
        public function getEnvironment():Array
        {
            // Зависит от текущего радиуса игрока и величены ячейки
            var res:Array = new Array();
            // Дополнительно проверяем движущиеся шары от игрока
            res = res.concat(DividedBall._dividedBall);
            // Получаем список ячеек в доступном окружении
            var cells:Array = Cell.getEnvironmentCell(Cell.getCell(x,y), Radius);
            var namecell:String;
            // Проверяем ячейки на наличие в них искомых шаров
            for	each(var item:Cell in cells)
            {
                namecell = item.getName();
                if (Ball._Balls[namecell] != undefined)
                    res.push(Ball._Balls[namecell]);
            }
            return res;
        }

        public function hScroll(val:Number):void
        {
            if (x + val < _gameMap.mapWidth - _Radius && x + val - _Radius > 0)
                x += val*_Speed;
        }

        public function vScroll(val:Number):void
        {
            if (y + val < _gameMap.mapHeight - _Radius && y + val - _Radius > 0)
                y += val*_Speed;
        }

        public function enterFrameHandler(e:Event):void
        {
            // Обновление положения карты
            updMapPos();
            // Отслеживание наезда на шарики
            updImposition();
            // Обновление данных на сервере
            //Server.movePlayer(this);
        }

        private function timerHandler(e:TimerEvent):void
        {
            Server.movePlayer(this);
        }

        // Слежение за наездом
        private function updImposition():void
        {
            var balls:Array = getImposition();
            for each(var item:Ball in balls)
            {
                // Поедание шара
                if (item is GoodBall)
                    eatBall(item);
                // Разрушение игрока
                if (item is BadBall)
                    destroyBall(item);
                // Поедание подвижных шаров
                if (item is DividedBall)
                    eatBall(item);
                // Поедание других игроков
                if (item is MoveBall)
                {
                    if (item.Radius < Radius)
                        eatBall(item);
                    else
                        gameOwer();
                }
            }
        }

        // Окончание игры, игрока съели
        private function gameOwer():void
        {

        }

        private function sceneWidth():Number
        {
          return stage.stageWidth/Scale;
        }

        private function sceneHeight():Number
        {
            return stage.stageHeight/Scale;
        }

        // Слежение за игроком
        private function updMapPos():void
        {
            var delta:Number = 1;
            var dx:Number = Math.abs(Math.abs((x -  sceneWidth()/2)) - Math.abs(_gameMap.x/Scale));
            var dy:Number = Math.abs(Math.abs(y - sceneHeight()/2) - Math.abs(_gameMap. y/Scale));

            // Держим шар в центре экрана
            if (dx > delta)
            {
            if (x -  sceneWidth()/2 < Math.abs(_gameMap.x/Scale))
                _gameMap.hScroll(_Speed*Scale); // Вправо
            else if (x > Math.abs(_gameMap.x/Scale) + sceneWidth()/1.95)
                _gameMap.hScroll(-_Speed*Scale); // Влево
            }
            if (dy > delta)
            {
            if (y - sceneHeight()/2 < Math.abs(_gameMap. y/Scale))
                _gameMap.vScroll(_Speed*Scale); // Вниз
            else if (y > Math.abs(_gameMap.y/Scale) + sceneHeight()/1.95)
                _gameMap.vScroll(-_Speed*Scale); // Вверх
            }
        }

    }
}
