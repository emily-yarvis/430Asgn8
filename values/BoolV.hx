package values;

class BoolV extends Value {
    public var bool:Bool;

    public function new(bool){
        super();
        this.bool = bool;
    }

    public override function toString() : String{
        return bool? "true": "false";
    }
}