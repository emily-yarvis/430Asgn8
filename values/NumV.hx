package values;

class NumV extends Value{
    public var num:Float;

    public function new(num:Float){
        super();
        this.num = num;
    }

    public override function toString() : String{
        return Std.string(num);
    }
}