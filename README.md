# AutoIntegers

Pick a range and let the compiler do the rest. No underflows, no overflows, no overheads.

## Usage

Just pick your range, then use like any other integer type
```
T = AutoInteger{-10,10}
a = rand(T)
b = rand(T)
@show a*b
```
