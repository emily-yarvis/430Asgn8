package values;

class StringV extends Value {
    public var str:String;

    public function new(str){
        super();
        this.str = str;
    }

    public override function toString() : String {
        return str;        
    }
    
}