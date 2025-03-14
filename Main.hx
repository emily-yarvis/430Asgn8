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

        //create top level env
        var top_level_env: Env = createTopLevelEnv();


        //interp testing
        runTests();
        
        var testExp = new AppC(new IdC("+"), Lambda.array([new NumC(3), new NumC(4)]).map(x -> cast(x, ExprC)));
        var testEnv = new Env();
        testEnv.add("+", new PrimV("+"));
        trace(interp(testExp, testEnv));
    }

    public static function createTopLevelEnv(): Env{
        var env = new Env();
        env.add("true",new BoolV(true));
        env.add("false",new BoolV(false));
        env.add("<=", new PrimV("<="));
        env.add(">=",new PrimV(">="));
        env.add("equal?", new PrimV("equal?"));
        env.add("-",new PrimV("-"));
        env.add("+",new PrimV("+"));
        env.add("*",new PrimV("*"));
        env.add("/",new PrimV("/"));
        return env;
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
            var interped_args:Array<Value> = args.map(arg -> interp(arg, env));
            var iter = interped_args.iterator();

            if (Std.isOfType(funval, CloV)) {
                var f: CloV = cast funval;
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
            else if (Std.isOfType(funval, PrimV)) {
                var p: PrimV = cast funval;
                return applyPrimV(p.op, Lambda.array(interped_args));
                //return new NumV(0); // Call the primitive interp function here
            }
            else {
                throw "Function is of invalid type";
            }
        }
        else{
            throw(new Exception("Invalid ExprC"));
        }
        
    }
    
   


    public static function applyPrimV(op: String, vals: Array<Value>): Value {
        switch(op) {
            case "+":
                return new NumV(cast(vals[0], NumV).num + cast(vals[1], NumV).num);
            case "-":
                return new NumV(cast(vals[0], NumV).num - cast(vals[1], NumV).num);
            case "*":
                return new NumV(cast(vals[0], NumV).num * cast(vals[1], NumV).num);
            case "/":
                return new NumV(cast(vals[0], NumV).num / cast(vals[1], NumV).num);
            case "<=":
                return new BoolV(cast(vals[0], NumV).num <= cast(vals[1], NumV).num);
            case ">=":
                return new BoolV(cast(vals[0], NumV).num >= cast(vals[1], NumV).num);
            case "equal?":
                return new BoolV(cast(vals[0], NumV).num == cast(vals[1], NumV).num);
            default:
                throw new Exception("Invalid operator: " + op);
        }
    }

        


    public static function parse(s : Sexp) : ExprC {
        var sexp : Array<Dynamic>;
        switch (s) {
            case StringArray(strings):
                sexp = strings;
            case NestedArray(nested):
                sexp = nested;
        }
        if(sexp.length != 0) {
            if(sexp.length == 1) {
                var arr = sexp[0].split("");
                //NumC Rule
                if(!Math.isNaN(Std.parseFloat(sexp[0]))){
                    return new NumC(Std.parseFloat(sexp[0]));
                }
                //StringC Rule
                else if(arr[1] =="\""){
                    var result = sexp[1].substr(1, sexp[1].length - 2);
                    return new StringC(result);
                }
                //IdC Rule
                else {
                    return new IdC(sexp[1]);
                }
            }
            //IfC Rule
            else if (sexp.length == 4 && sexp[0] == 'if') {
                return new IfC(parse(sexp[1]), parse(sexp[2]), parse(sexp[3]));
            }
            //LamC Rule
            else if (sexp.length == 3 && sexp[0] == 'proc' && sexp[1].isOfType(Array) && sexp[1].every(function(item) return Std.isOfType(item, String))) {
                return new LamC(sexp[1], parse(sexp[2]));
            }
            //Declare Rule (skipped for now)
            // else if (sexp.length == 4 && sexp[0] == 'declare' && 
            //     sexp[1].isOfType(Array) && 
            //     sexp[1].every(function(item) return Std.isOfType(item, Array) && item.length == 3) &&
            //     sexp[2] == 'in') {
            //     var variables : List<String> = new List<String>();
            //     var values : Array<Sexp> = [];
            //     var first : Array<Array<String>> = cast sexp[1];
            //     for (item in first) {
            //         variables.push(item[0]);
            //         values.push(item[1]);
            //     }
            //     return new AppC(new LamC(variables, parse(sexp[3])), values.map(val -> parse(val)));
            // }
            //AppC Rule
            else{
                var first = sexp[0];
                sexp.shift();
                return new AppC(parse(first), sexp.map(arg -> parse(arg)));
            }
            
        }
        else{
            throw new Exception("Can't have Sexp of length 0");
        }
    }

    
    static function runTests(){
        testInterpNumC();
        testInterpStringC();
        testInterpIdC();
        testAppC();
        testIfC();


        //parse testing
        testParseNum();
        testParseString();

        //testing applyPrimv
        testAddition();
        testSubtraction(); 
        testLessThan();
    }
//Interp test cases
     // Addition
     static function testInterpNumC() {
        trace("Test Interp of 4: " + interp( new NumC(4), new Env()));
    }

    static function testInterpStringC() {
        trace("Test Interp of \"Hello\": " + interp( new StringC("Hello"), new Env()));
    }

    static function testInterpIdC() {
        var env = createTopLevelEnv();
        env.add("x", new NumV(3));
        trace("Test Interp of 'x: " + interp( new IdC("x"), env));
    }

    static function testAppC(){
        var env = createTopLevelEnv();
        trace("Test add AppC: "+ interp(new AppC(new IdC("+"), [new NumC(3), new NumC(4)]), env));
    }

    static function testIfC(){
        var env = createTopLevelEnv();
        var appc:ExprC = new AppC(new IdC("equal?"), [new NumC(3), new NumC(3)]);
        trace("Test ifC: "+ (interp(new IfC(appc, new StringC("Yay"), new StringC("Booo")), env)));

    }

    // Addition
    static function testAddition() {
        var expr = new AppC(new IdC("+"), Lambda.array([new NumC(3), new NumC(4)]).map(x -> cast(x, ExprC)));
        var env = new Env();
        env.add("+", new PrimV("+"));
        var result = interp(expr, env);
        trace("Test Addition Result: " + result);
        // Expected: NumV(7)
    }

    //Subtraction
    static function testSubtraction() {
        var expr = new AppC(new IdC("-"), Lambda.array([new NumC(9), new NumC(3)]).map(x -> cast(x, ExprC)));
        var env = new Env();
        env.add("-", new PrimV("-"));
        var result = interp(expr, env);
        trace("Test Subtraction Result: " + result);
        // Expected: NumV(6)
    }

    //Less than or equal to
    static function testLessThan() {
        var expr = new AppC(new IdC("<="), Lambda.array([new NumC(1), new NumC(3)]).map(x -> cast(x, ExprC)));
        var env = new Env();
        env.add("<=", new PrimV("<="));
        var result = interp(expr, env);
        trace("Test Comparison Result: " + result);
        // Expected: BoolV(true)
    }


    //parse tests
    static function testParseNum(){
        trace("Test parse 4: "+ parse(StringArray(["4"])));

    }
    static function testParseString(){
        trace("Test parse Hello: "+ parse(StringArray(["Hello"])));
    }

    
}
