package expressions;

class AppC extends ExprC {
    public var name:ExprC;
    public var args:List<ExprC>;

    public function new(name, args) {
        super();
        this.name = name;
        this.args = args;
    }
}