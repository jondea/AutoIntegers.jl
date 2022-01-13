function normal_ints()
    a = rand(Int8(-1):Int8(100))
    b = rand(Int8(-10):Int8(5))
    return Int16(a) * Int16(b)
end
@code_typed normal_ints()

import AutoIntegers: AutoInteger
function auto_ints()
    a = rand(AutoInteger{-1,100})
    b = rand(AutoInteger{-10,5})
    return (a * b).val
end
@code_typed auto_ints()

println("Give me a number 1-100")
a = parse(AutoInteger{1,100}, readline())

println("Give me a number 1-10")
b = parse(AutoInteger{-10,5}, readline())

ab = a*b

println("a*b = $(ab)")
println("and is of type $(typeof(ab))")
