package GameBalls {

    // Класс разрушающих шаров
    public class BadBall extends Ball
    {
        public static const CONST_RADIUS:int = 5;

        public function BadBall(l_x:int, l_y:int)
        {
            super(l_x, l_y);
            //_Color = 0x261a15;
            _Radius = CONST_RADIUS;
        }

        override public function getDistance(player:PlayerBall):Number
        {
            return Math.sqrt(Math.pow((player.x-x),2)+Math.pow((player.y-y),2)) - _Radius;
        }

    }

}
