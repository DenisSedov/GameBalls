package GameBalls {
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.xml.XMLDocument;

import org.osmf.elements.compositeClasses.ParallelSeekTrait;

// Класс игроков соперников
public class MoveBall extends Ball {

    public static var _PlayerBalls:Dictionary = new Dictionary(); // Список всех игроков на карте
    public static var _RemovePlayer:MoveBall;

    private var _textfield:TextField = new TextField();

    public function MoveBall(send_x:Number, send_y:Number)
    {
        super(send_x, send_y)
    }

    override protected function create():void {}

    // Отрисовка
    override public function draw():void
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

    /* Перемещение игрока */
    public function movePlayer(pos_x:Number, pos_y:Number):void
    {
        if (x == pos_x && y == pos_y) return;
        x = pos_x;
        y = pos_y;
        draw();
    }

    // Удаление игрока
    private function onRemovePlayer(e:Event):void
    {
        _RemovePlayer = null;
    }

    // Удаляет шарик из словаря и возвращает результат успешного удаления
    override public function removeBall():Boolean
    {
        var res:Boolean = false;
        if (_PlayerBalls.hasOwnProperty(ID.toString()))
        {
            delete _PlayerBalls[ID];
            parent.removeChild(this);
            _RemovePlayer = this;
            Server.removePlayerForID(ID, onRemovePlayer);
            res = true;
        }
        return res;
    }

    override public function getDistance(player:PlayerBall):Number
    {
        return Math.sqrt(Math.pow((player.x-x),2)+Math.pow((player.y-y),2)) + _Radius;
    }
}
}
