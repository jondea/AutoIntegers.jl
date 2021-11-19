
function subtractcast(a, b, ::Type{T})::T where {T}
    # By default, do the naive thing
    a - b
end
function subtractcast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Signed, TB<:Unsigned, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    RT(a) - RT(b)
end
function subtractcast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Unsigned, TB<:Signed, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    RT(a) - RT(b)
end
function subtractcast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Unsigned, TB<:Unsigned, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    RT(a) - RT(b)
end

function negatecast(a::T, ::Type{RT}) where {T<:Unsigned,RT<:Signed}
    # Check for the special case where we can't cast directly to signed
    # For example -(UInt8(128)),
    if (a >= typemax(RT))
        return typemin(RT)
    else    
        return -RT(a)
    end
end
function negatecast(a::T, ::Type{RT}) where {T<:Signed,RT}
    return RT(-a)
end
function negatecast(::T, ::Type{RT}) where {T<:Unsigned,RT<:Unsigned}
    # Special case where a must be 0
    return 0
end

import Base: -
-(a::AutoInteger{0,0,UInt8}) = AutoInteger{0,0}(0)
function -(a::AutoInteger{LA,UA}) where {LA,UA}
    L = -UA
    U = -LA
    T = auto_integer_type(L,U)
    # Implement logic using template parameters, as these are consts which
    # could be elided

    # Not sure exactly what the logic needs to be here, but basically
    # we have to be careful whether we negate before or after casting,
    # and we need to be careful what happens to the top bits
    # Because -(Int8(128)) is invalid, we need to do reinterpret(Int8, UInt8(128))
    # but -reinterpret(Int8, UInt8(127)) for all the rest
    if typeof(a.val) <: Unsigned && UA > typemax(T)
        # Essentially check top bit
        if a.val == typemax # <= Runtime check!! This should be the only one
            return AutoInteger{L,U}(reinterpret(T, a.val))
        else
            return AutoInteger{L,U}(-reinterpret(T,a.val))
        end
    elseif L == 0 && U == 0
        return AutoInteger{L,U}(0)
    elseif sizeof(T) == sizeof(a.val)
        if T <: Unsigned
            return AutoInteger{L,U}(reinterpret(T, -a.val))
        elseif T <: Signed
            return AutoInteger{L,U}(-reinterpret(T, a.val))
        end
    else
        if T <: Unsigned
            return AutoInteger{L,U}(T(-a.val))
        elseif T <: Signed
            if sizeof(T) < sizeof(typeof(a))
                return AutoInteger{L,U}(T(-a.val))
            else
                return AutoInteger{L,U}(-T(a.val))
            end
        end
    end
end

function -(a::AutoInteger{LA,UA}, b::AutoInteger{LB,UB}) where {LA,UA,LB,UB}
    L = LA-UB
    U = UA-LB
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(subtractcast(a.val, b.val, T))
end
function -(a::AutoInteger{LA,UA}, b::Integer) where {LA,UA}
    L = LA-b
    U = UA-b
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(subtractcast(a.val, b, T))
end
function -(a::Integer, b::AutoInteger{LB,UB}) where {LB,UB}
    L = a-UBs
    U = a-LB
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(subtractcast(a, b.val, T))
end
