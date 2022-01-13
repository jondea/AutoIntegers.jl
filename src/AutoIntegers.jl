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

auto_integer_type(bounds)::DataType = auto_integer_type(bounds[1],bounds[2])

struct AutoInteger{L,U,T<:Integer} <: Integer
    val::T
    function AutoInteger{L,U}(v) where {L,U}
        T = auto_integer_type(L,U)
        # # To make AutoIntegers no overhead, we probably need to remove this check
        # # Perhaps have no inner constructor, an unsafe outer constructor and a safe obviously named constructor?
        # Can't get the above approach working, I have just commented the check out, although this isn't very user friendly...
        # if !(L <= v <= U) throw(DomainError(v, "v must be $L <= v <= $U")) end
        new{L,U,T}(T(v))
    end
end

import Base: show
show(io::IO, a::AutoInteger{L,U}) where {L,U} = print(io, "AutoInteger{$L,$U}($(string(a.val,base=10)))")

import Base: rand
function rand(::Type{AutoInteger{L,U}}) where {L,U} 
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(rand(T(L):T(U)))
end

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

bound_union(bound1, bound2) = (min(bound1[1], bound2[1]), max(bound1[2], bound2[2]))
bound_union(bound1, bound2, bound3) = bound_union(bound1, bound_union(bound2, bound3))
# bound_union((L1,U1), (L2,U2)) = (min(L1, L2), max(U1, U2))

bound_union_type(bounds...) = auto_integer_type(bound_union(bounds...))

bigger_type(::Type{UInt8}) = UInt16
bigger_type(::Type{UInt16}) = UInt32
bigger_type(::Type{UInt32}) = UInt64
bigger_type(::Type{UInt64}) = UInt128
bigger_type(::Type{UInt128}) = BigInt
bigger_type(::Type{Int8}) = Int16
bigger_type(::Type{Int16}) = Int32
bigger_type(::Type{Int32}) = Int64
bigger_type(::Type{Int64}) = Int128
bigger_type(::Type{Int128}) = BigInt

include("add.jl")
include("subtract.jl")
include("multiply.jl")

export AutoInteger
export auto_integer_type

end # module
