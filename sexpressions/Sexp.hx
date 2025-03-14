package sexpressions;

enum Sexp {
    StringArray(arr: Array<String>);
    NestedArray(arr: Array<Sexp>);
}