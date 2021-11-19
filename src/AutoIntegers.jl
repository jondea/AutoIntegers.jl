module AutoIntegers

function auto_integer_type(l,u)::DataType
    if l >= 0
        if u <= typemax(UInt8)   return UInt8 end
        if u <= typemax(UInt16)  return UInt16 end
        if u <= typemax(UInt32)  return UInt32 end
        if u <= typemax(UInt64)  return UInt64 end
        if u <= typemax(UInt128) return UInt128 end
    end
    if l >= typemin(Int8)   && u <= typemax(Int8)   return Int8 end
    if l >= typemin(Int16)  && u <= typemax(Int16)  return Int16 end
    if l >= typemin(Int32)  && u <= typemax(Int32)  return Int32 end
    if l >= typemin(Int64)  && u <= typemax(Int64)  return Int64 end
    if l >= typemin(Int128) && u <= typemax(Int128) return Int128 end

    # All else fails, stop here. We would use a BigInt as the type parameter but
    # it is not allowed
    throw(DomainError((l,u), "l and u must both be representable as Int128 or UInt128"))
end

struct AutoInteger{L,U,T<:Integer} <: Integer
    val::T
    function AutoInteger{L,U}(v) where {L,U}
        T = auto_integer_type(L,U)
        # To make AutoIntegers no overhead, we probably need to remove this check
        # Perhaps have no inner constructor, an unsafe outer constructor and a safe obviously named constructor?
        if !(L <= v <= U) throw(DomainError(v, "v must be $L <= v <= $U")) end
        new{L,U,T}(T(v))
    end
end

import Base: show
show(io::IO, a::AutoInteger{L,U}) where {L,U} = print(io, "AutoInteger{$L,$U}($(string(a.val,base=10)))")

import Base: rand
rand(::Type{AutoInteger{L,U,T}}) where {L,U,T} = AutoInteger{L,U}(rand(L:U))

import Base: tryparse
function tryparse(::Type{AutoInteger{L,U}}, str::String) where {L,U}
    v = tryparse(auto_integer_type(L,U), str)
    if isnothing(v) || !(L <= v <= U)
        return nothing
    end
    return AutoInteger{L,U}(v)
end

import Base: parse
function parse(::Type{AutoInteger{L,U}}, str::String) where {L,U}
    v = parse(auto_integer_type(L,U), str)
    return AutoInteger{L,U}(v)
end

import Base.typemin
typemin(::Type{AutoInteger{L,U,T}}) where {L,U,T} = AutoInteger{L,U}(L)
import Base.typemax
typemax(::Type{AutoInteger{L,U,T}}) where {L,U,T} = AutoInteger{L,U}(U)

import Base.==
# We might be able to do a compile time comparison to see if the types have any overlap
# but we would need to check there is definitely no runtime overhead for other cases
==(a::AutoInteger,b::AutoInteger) = a.val == b.val
==(a::AutoInteger,b::Number) = a.val == b

include("add.jl")
include("subtract.jl")
include("multiply.jl")

export AutoInteger
export auto_integer_type

end # module