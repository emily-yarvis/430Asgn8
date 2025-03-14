package values;


import expressions.*;

class CloV extends Value {

    public var args:List<String>;

    public var body:ExprC;

    public var env:Env;

    public function new(args, body, env){
        super();
        this.args = args;
        this.env = env;
        this.body = body;
    }

    
}