package sexpressions;

abstract class Sexp {
    public var sexp : Array<Sexp>;
    
    public function new(sexp){
        this.sexp = sexp;

    }
   
}

abstract class SexpBase extends Sexp {    
    public function new(sexp : Array<String>){
        super(sexp);
    }
}

abstract class SexpList extends Sexp {    
    public function new(sexp : Array<Sexp>){
        super(sexp);
    }
}