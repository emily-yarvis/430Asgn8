import values.*;

class Env {
    var bindings:Map<String, Value>;

    public function new(bindings){
        this.bindings = bindings;
    }

   }