package values;

class ClosV extends Value {
    var args:List<String>;

    var body:Value;

    var env:Env;

    public function new(args, body, env){
        super();
        this.args = args;
        this.env = env;
        this.body = body;
    }
}