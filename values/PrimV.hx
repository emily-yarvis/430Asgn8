package values;

class PrimV extends Value {
    public var op:String;

    public function new(op){
        super();
        this.op = op;
    }

    public override function toString() : String {
        return "";
    }
}