# AutoIntegers

Pick a range and let the compiler do the rest.
No underflows, no overflows, (probably mostly) no overheads.

The central idea is that the underlying primitive integer type can be determined
from the range, which is a type parameter, and therefore known at compile time.
The range can be propagated using elementary operations within the type.
The overhead of this, if done correctly, should disappear at runtime.

One downside is that it will probably increase compile times.
Also, some operations will not allow propagation of range, for example, summing
a vector of AutoIntegers.
Some programming patterns may also be inefficient, for example, accumulating
over a loop will cause type instability.

## Usage

Just pick your range, then use like any other integer type
```
T = AutoInteger{-10,10}
a = rand(T)
b = rand(T)
@show a*b
```
