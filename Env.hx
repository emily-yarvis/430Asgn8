import values.*;

class Env {
    var bindings:Map<String, Value>;

    public function new(){
        this.bindings = []; // Make the top-level env here
    }

    public function lookup(id) {
        return bindings[id];
    }

    public function add(id, value) {
        bindings[id] = value;
    }

   }