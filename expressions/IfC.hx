package expressions;

class IfC extends ExprC {
    public var test:ExprC;
    public var then:ExprC;
    public var otherwise:ExprC;

    public function new(test, then, otherwise) {
        super();
        this.test = test;
        this.then = then;
        this.otherwise = otherwise;
    }
}