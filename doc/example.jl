
using AutoIntegers

function normal_ints(a_str::UInt8, b_str::Int8)
    return Int16(a) * Int16(b)
end

function auto_ints(a_str::AutoInteger{1,100}, b_str::AutoInteger{-10,5})
    return a * b
end

println("Give me a number 1-100")
a = parse(AutoInteger{1,100}, readline())

println("Give me a number 1-10")
b = parse(AutoInteger{-10,5}, readline())

ab = a*b

println("a*b = $(ab)")
println("and is of type $(typeof(ab))")
