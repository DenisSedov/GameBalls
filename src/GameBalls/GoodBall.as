package GameBalls {

    // Класс шариков для поедания
    public class GoodBall extends Ball
    {
        public static const CONST_RADIUS:int = 2;
        private static const CONST_SCORE:int = 1;

        public function GoodBall(send_x:Number, send_y:Number)
        {
            super(send_x, send_y);
            // Устанавливаем случайные цвета
            //_Color = Math.random() * (uint.MAX_VALUE - uint.MIN_VALUE + 1);
            _Radius = CONST_RADIUS;
            _Score = CONST_SCORE;
        }

        override public function getDistance(player:PlayerBall):Number
        {
            return Math.sqrt(Math.pow((player.x-x),2)+Math.pow((player.y-y),2)) + _Radius;
        }

    }
}
