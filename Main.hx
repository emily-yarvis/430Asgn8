/**
    Multi-line comments for documentation.
**/

import haxe.Exception;
import haxe.ds.EnumValueMap;
import values.*;
import expressions.*;

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
    }

    public function interp(expr : ExprC, env : Env ) : Value{
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
        else{
            throw(new Exception("Invalid ExprC"));
        }
        
    }

}