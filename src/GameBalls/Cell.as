package GameBalls {
    // Вспомогательный класс представление ячейки на поле
    public class Cell
    {
        // Количество строк и колонок
        public static const CELL_C:int = 70; // y
        public static const CELL_R:int = 70; // x
        // Размер ячейки
        public static const CELL_SIZE:int = 10;
        // Позиция ячейки
        public var _posX:int;
        public var _posY:int;

        public function Cell(px:int, py:int)
        {
            _posX = px;
            _posY = py;
        }

        // Возвращает имя ячейки по заданным координатам
        public static function getNameCell(ax:int, ay:int):String
        {
            var x:int = getPosX(ax);
            var y:int = getPosY(ay);
            return x.toString() + '_' + y.toString();
        }

        public function getName():String
        {
            return _posX.toString() + '_' + _posY.toString();
        }

        public static function getPosX(ax:int):int
        {
            return Math.floor(ax/CELL_SIZE);
        }

        public static function getPosY(ay:int):int
        {
            return Math.floor(ay/CELL_SIZE);
        }

        public static function getCell(ax:int, ay:int):Cell
        {
            return new Cell(getPosX(ax), getPosY(ay));
        }

        // Возвращает набор ячеек, с учетом глубины
        // value глубина поиска
        public static function getEnvironmentCell(cell:Cell, value:int):Array
        {
            var deep:int = Math.ceil(value/CELL_SIZE); // Количество ячеек для поиска
            if (deep == 0)
                deep = 1;
            var res:Array = new Array();
            // по х и y
            for (var row:int = cell._posX - deep; row <=  cell._posX + deep; row++)
                for (var column:int = cell._posY - deep; column <=  cell._posY + deep; column++)
                {
                    //Проверяем границы
                    if (column >= 0 && column <= CELL_C && row >= 0 && row <= CELL_R)
                        res.push(new Cell(row,column));
                }
            return res;
        }
    }
}
