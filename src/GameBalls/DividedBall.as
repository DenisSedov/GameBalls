package GameBalls {

    import flash.events.Event;

    // Класс шары после распада игрока
    public class DividedBall extends Ball
    {
        // Количество создаваемых шаров
        private static const CONST_COUNTBALL:int = 5;
        // Коэффициент уменьшения радиуса по сравнению с игроком
        private static const CONST_COEFRADIUS:Number = .5;
        // Коэффициент уменьшения скорости
        private static const CONST_COEFSPEED:Number = .5;
        private var _ParentPlayer:PlayerBall;
        private var _Number:int; // Номер шара (0..CONST_COUNTBALL)
        // Список всех подвижных шаров на поле
        public static var _dividedBall:Array = new Array();
        //public static var _dividedBall:Vector.<DividedBall> = new Vector.<DividedBall>();

        public var _Speed:Number; // Скорость шаров

        // Конструктор
        public function DividedBall(l_x:int, l_y:int)
        {
            super(l_x, l_y);
        }

        // Перекрытая функция создания обьекта
        override protected function create():void
        {
            // Добавляем в список обьектов
            _dividedBall.push(this);
        }

        //Удаление из списка
        override public function removeBall():Boolean
        {
            var res:Boolean = false;
            var index:int = _dividedBall.indexOf(this);
            if (index > -1)
            {
                _dividedBall.splice(index, 1);
                res = true;
            }
            return res;
        }

        // Устанавливаем игрока
        private function setPlayer(player:PlayerBall):void
        {
            _ParentPlayer = player;
            _Color = player._Color;
            _Radius = getRadius();
            _Speed = getSpeed();
            _Score = player._Score/CONST_COUNTBALL/2;
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }

        // Растановка шаров на поле
        public static function dotingBall(player:PlayerBall):void
        {
            var gm:GameMap = (GameMap)(player.parent);
            var px:Number = player.x;
            var py:Number = player.y;
            var R:Number = player.Radius;
            var db:DividedBall;

            for (var k:int = 0; k < CONST_COUNTBALL; k++)
            {
                // Создаем новые шары
                db = new DividedBall(0,0);
                db.setPlayer(player);
                db._Number = k;
                db.draw();
                //Вычисляем координаты по которым надо расставить шары
                db.x = db.getX(px);
                db.y = db.getY(py);
                gm.addChild(db);
            }
        }

        private function getX(px:Number):Number
        {
            return Math.cos(2*Math.PI*_Number/CONST_COUNTBALL) + px;
        }

        private function getY(py:Number):Number
        {
            return Math.sin(2*Math.PI*_Number/CONST_COUNTBALL) + py;
        }

        // Движение шаров по полю
        private function enterFrameHandler(e:Event):void
        {
            var nx:Number = getX(x);
            var ny:Number = getY(y);

            if (nx < 0) // Выезд за левый край
            {
                nx = _Radius;
                _Speed = 0;
            }
            else if (nx +_Radius*2 > GameMap._mapWidth+_Radius) // Выезд за правый край
            {
                nx = GameMap._mapWidth -_Radius;
                _Speed = 0;
            }
            if (ny < 0) // Выезд за верхний край
            {
                ny = _Radius;
                _Speed = 0;
            }
            else if (ny + _Radius*2 > GameMap._mapHeight+_Radius) // Выезд за нижний край
            {
                ny = GameMap._mapHeight -_Radius;
                _Speed = 0;
            }

            x = nx;
            y = ny;

            // Достигли края поля
            if (_Speed == 0)
                removeEventListener(Event.ENTER_FRAME, enterFrameHandler);

        }

        private function getRadius():Number
        {
            return _ParentPlayer.Radius * CONST_COEFRADIUS;
        }

        private function getSpeed():Number
        {
            return _ParentPlayer._Speed * CONST_COEFSPEED;
        }

        override public function getDistance(player:PlayerBall):Number
        {
            return Math.sqrt(Math.pow((player.x-x),2)+Math.pow((player.y-y),2)) + _Radius;
        }

    }
}
