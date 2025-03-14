/**
    Multi-line comments for documentation.
**/

import sexpressions.Sexp;
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
        trace(parse(["1"]));
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


    public static function parse(sexp : Sexp) : ExprC {
        if(sexp.sexp.length != 0) {
            if(sexp.sexp.length == 1){
                var arr = sexp.sexp[1].split("");
                //NumC Rule
                if(Math.isNaN(Std.parseFloat(sexp.sexp[0]))){
                    return new NumC(Std.parseFloat(sexp.sexp[0]));

                }
                //StringC Rule
                else if( arr[1] =="\""){
                    var result = sexp.sexp[1].substr(1, sexp.sexp[1].length - 2);
                    return new StringC(result);
                }
                //IdC Rule
                else {
                    return new IdC(sexp.sexp[1]);
                }
            }
            //IfC Rule
            else if (sexp.sexp.length == 4 && sexp.sexp[0] == 'if') {
                return new IfC(parse(sexp.sexp[1]), parse(sexp.sexp[2]), parse(sexp.sexp[3]));
            }
            //LamC Rule
            else if (sexp.sexp.length == 3 && sexp.sexp[0] == 'proc' && sexp.sexp[1].isOfType(Array) && sexp.sexp[1].every(function(item) return Std.isOfType(item, String))) {
                return new LamC(sexp.sexp[1], parse(sexp.sexp[2]));
            }
            //Declare Rule
            else if (sexp.sexp.length == 4 && sexp.sexp[0] == 'declare' && sexp.sexp[1].isOfType(Array) && sexp.sexp[1].every(function(item) return Std.isOfType(item, Array) && item.length == 3) && sexp.sexp[2] == 'in') {
                var variables : Array<String> = [];
                var values : Array<String> = [];
                for (item in sexp.sexp[1]) {
                    variables.push(item[0]);
                    values.push(item[1]);
                }
                return new AppC(new LamC(variables, parse(sexp.sexp[3])), values.map(val -> parse(val)));
            }
            //AppC Rule
            else{
                var first = sexp.sexp[0];
                sexp.sexp.shift();
                return new AppC (parse(first), sexp.sexp.map(arg -> parse(arg)));
            }
            
        }
        else{
            throw new Exception("Can't have Sexp of length 0");
        }
    }
}