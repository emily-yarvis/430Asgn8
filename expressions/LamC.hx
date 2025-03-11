package expressions;

class LamC extends ExprC {
    public var params:List<String>;
    public var body:ExprC;

    public function new(params, body) {
        super();
        this.params = params;
        this.body = body;
    }
}