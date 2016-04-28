package GameBalls {

import flash.display.Loader;
import flash.display.Sprite;
import flash.utils.Dictionary;
import flash.utils.*;
import flash.events.*;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.net.URLRequest;

    // Общий класс шариков
    public class Ball extends Sprite
    {
        private static const IMG_EXPANSION:String = ".png";
        private var _Loader:Loader = null;

        // Атрибуты свойств класса
        protected var _ID:int; // Идентификатор объекта
        protected var _Name:String; // Наименование
        protected var _Color:uint; // Цвет обьекта
        protected var _Radius:Number; // Размер объекта
        protected var _Score:int;


        // Список всех неподвижных шаров на поле
        public static var _Balls:Dictionary = new Dictionary();
        //private static var _dividedBall:Vector.<DividedBall> = new Vector.<DividedBall>();
        // Список всех Loader с текстурами
        //public static var _TextureLoader:Dictionary = new Dictionary();

        /* Свойства */

        public function get ID():int
        {
            return _ID;
        }

        public function set ID(value:int):void
        {
            _ID = value;
        }

        public function get Name():String
        {
            return _Name;
        }

        public function set Name(value:String):void
        {
            _Name = value;
        }

        public function get Color():uint
        {
            return _Color;
        }

        public function set Color(value:uint):void
        {
            _Color = value;
        }

        public function get Radius():Number
        {
            return _Radius;
        }

        public function set Radius(value:Number):void
        {
            _Radius = value;
        }

        public function get Score():int
        {
            return _Score;
        }

        public function set Score(value:int):void
        {
            _Score = value;
        }

        /* конец свойств */

        /* Конструктор */
        public function Ball(send_x:Number, send_y:Number)
        {
            x = send_x;
            y = send_y;

            create();
        }

        // Функция создания обьекта
        protected function create():void
        {
            if (_Name == null)
                _Name = Cell.getNameCell(x, y);
            _Balls[_Name] = this;

        }

        // Загрузка текстур
        public function onLoadComplete(e:Event):void
        {
            _Loader.removeEventListener(Event.COMPLETE, onLoadComplete);
            // Отрисовываем изображение
            draw();
        }
        /*
        private function pushBall(ball:Ball):void
        {
            var keyvalue:String = Math.round(ball.x/ball._Radius).toString() + '_' + Math.round(ball.y/ball._Radius).toString();
            if (_Balls.hasOwnProperty(keyvalue))
                _Balls[keyvalue] = ball;
        }
          */
        // Удаляет шарик из словаря и возвращает результат успешного удаления
        public function removeBall():Boolean
        {
            var res:Boolean = false;
            if (_Balls.hasOwnProperty(_Name))
            {
                delete _Balls[_Name];
                parent.removeChild(this);
                Server.removeBall(this);
                res = true;
            }
            return res;
        }
        /*
        // Загрузка текстур в обьект
        private function loadTexture():BitmapData
        {
            var image:Bitmap = null;
            var loader:Loader = null;
            var name:String = getURLTexture();
            // Если есть в атрибуте
            if (_Loader != null)
            {
                image = _Loader.contentLoaderInfo.content as Bitmap;
                if (image != null)
                    return image.bitmapData;
            }
            // Проверяем в общем кэше
            else if (_TextureLoader.hasOwnProperty(name))
            {
                // Есть в общем кэше
                //Назначаем обработчик
                loader = _TextureLoader[name];
                _Loader = loader;
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            }
            // В кэше нет, надо загружать с сервера
            else
            {
                // Создаем загрузчик и назначаем обработчик
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
                // Записываем в кэш
                _TextureLoader[name] = loader;
                _Loader = loader;
                // Загружаем
                loader.load(new URLRequest(name + IMG_EXPANSION));
            }
            // Загружаем с сервера, придет в обработчик
            return null;
        }
         */
        // Отрисовка
        public function draw():void
        {
            graphics.beginFill(_Color, 1);
            graphics.lineStyle(0, _Color);
            graphics.drawCircle(0,0, _Radius);
        }

        public static function getMaxBallChecker():int
        {
            return Math.max(BadBall.CONST_RADIUS, GoodBall.CONST_RADIUS);
        }

        // Функция расчета расстояний между центрами
        public function getDistance(player:PlayerBall):Number
        {
            return 0;
        }
        /*
        public function getURLTexture():String
        {
            return  'd:\\img\\' + getQualifiedClassName(this);
        }
        */

    }
}
