import values.*;

class Env {
    public var bindings:Map<String, Value>;

    public function new(){
        this.bindings = []; // Make the top-level env here
    }

    public function lookup(id) {
        return bindings[id];
    }

    public function add(id, value:Value) {
        bindings[id] = value;
    }

   }