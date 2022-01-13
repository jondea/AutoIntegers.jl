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
This package is very much a work in progress and very incomplete.
PRs, suggestions and bug reports are very much appreciated.

## Examples

Just pick your range, then use like any other integer type
```julia
T = AutoInteger{-10,10}
a = rand(T)
b = rand(T)
@show a*b
```

To demonstrate that there is indeed no overhead, consider the following examples
```julia
function normal_ints()
    a = rand(Int8(-1):Int8(100))
    b = rand(Int8(-10):Int8(5))
    return Int16(a) * Int16(b)
end
@code_typed normal_ints()
```
produces
```julia
CodeInfo(
1 ─ %1 = invoke Random.rand($(QuoteNode(Random.TaskLocalRNG()))::Random.TaskLocalRNG, $(QuoteNode(Random.SamplerRangeNDL{UInt32, Int8}(-1, 0x00000066)))::Random.SamplerRangeNDL{UInt32, Int8})::Int8
│   %2 = invoke Random.rand($(QuoteNode(Random.TaskLocalRNG()))::Random.TaskLocalRNG, $(QuoteNode(Random.SamplerRangeNDL{UInt32, Int8}(-10, 0x00000010)))::Random.SamplerRangeNDL{UInt32, Int8})::Int8
│   %3 = Core.sext_int(Core.Int16, %1)::Int16
│   %4 = Core.sext_int(Core.Int16, %2)::Int16
│   %5 = Base.mul_int(%3, %4)::Int16
└──      return %5
) => Int16
```

A similar (and I would argue slightly more elegant) example using `AutoIntegers`
```julia
import AutoIntegers: AutoInteger
function auto_ints()
    a = rand(AutoInteger{-1,100})
    b = rand(AutoInteger{-10,5})
    return (a * b).val
end
@code_typed auto_ints()
```
produces the same typed code, and therefore the same binary
```julia
CodeInfo(
1 ─ %1 = invoke Random.rand($(QuoteNode(Random.TaskLocalRNG()))::Random.TaskLocalRNG, $(QuoteNode(Random.SamplerRangeNDL{UInt32, Int8}(-1, 0x00000066)))::Random.SamplerRangeNDL{UInt32, Int8})::Int8
│   %2 = invoke Random.rand($(QuoteNode(Random.TaskLocalRNG()))::Random.TaskLocalRNG, $(QuoteNode(Random.SamplerRangeNDL{UInt32, Int8}(-10, 0x00000010)))::Random.SamplerRangeNDL{UInt32, Int8})::Int8
│   %3 = Core.sext_int(Core.Int16, %1)::Int16
│   %4 = Core.sext_int(Core.Int16, %2)::Int16
│   %5 = Base.mul_int(%3, %4)::Int16
└──      return %5
) => Int16
```

Of course, this is a simple example.
I can't guarantee it will work in more complex ones, but it *should*.