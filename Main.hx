/**
    Multi-line comments for documentation.
**/

import haxe.Exception;
import haxe.ds.EnumValueMap;
import values.*;
import expressions.*;
import sexpressions.*;

class Main {
    static public function main():Void {
        // Single line comment
        trace("Hello World");

        var e = new IdC("this is my id");
        trace(e.id);

        var env = new Env();
        env.add("id", new NumV(3));
        trace(env);
        trace(env.lookup("id"));

        //interp testing
        trace(interp( new NumC(4), new Env()));
    }
    

    
    public static function interp(expr : ExprC, env : Env ) : Value{
        if(Std.isOfType(expr, NumC)){
            var n: NumC = cast expr;
            return new NumV(n.num);
        }
        else if(Std.isOfType(expr, StringC)){
            var s: StringC = cast expr;
            return new StringV(s.str);
        }
        else if(Std.isOfType(expr, IdC)){
            var i: IdC = cast expr;
            if(env.lookup(i.id) != null) {
                return env.lookup(i.id) ;
            }
            else{
                throw(new Exception("Can't find varin env"));
            }
        }
        else if(Std.isOfType(expr, IfC)){
            var i: IfC = cast expr;
            var test: Value = interp(i.test, env);
            if(Std.isOfType(test, BoolV)){
                var t: BoolV = cast test;
                if(t.bool){
                    return interp(i.then, env);
                }
                else{
                    return interp(i.otherwise, env);
                }
            }
            else{
                throw new Exception("Invalid ifC, first arg must evaluate to a boolean");
            }
            
        }
        else if(Std.isOfType(expr, LamC)){
            var l: LamC = cast expr;
            return new CloV(l.params, l.body, env);
        }
        else if(Std.isOfType(expr, AppC)) {
            var a: AppC = cast expr;
            var func = a.name;
            var args = a.args;
            var funval = interp(func, env);
            var interped_args:List<Value> = args.map(arg -> interp(arg, env));
            var iter = interped_args.iterator();

            if (Std.isOfType(func, CloV)) {
                var f: CloV = cast func;
                var new_env = new Env();
                var i:Int = 0;
                var params:List<String> = cast f.args;
                for (param in params ) {
                    if(iter.hasNext()){
                        new_env.add(param, iter.next());
                    }
                }
                for (key in env.bindings.keys()) {
                    new_env.add(key, env.bindings[key]);
                }
                return interp(f.body, new_env);
            } 
            else if (Std.isOfType(func, PrimV)) {
                return new NumV(0); // Call the primitive interp function here
            }
            else {
                throw "Function is of invalid type";
            }
        }
        else{
            throw(new Exception("Invalid ExprC"));
        }
        
    }


    

}