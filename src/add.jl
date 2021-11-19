
function addcast(a, b, ::Type{T})::T where {T}
    # By default, do the naive thing
    a + b
end
function addcast(a::T, b::T, ::Type{RT})::RT where {T,RT}
    # Covers the case where the return type is larger
    RT(a) + RT(b)
end
function addcast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Signed, TB<:Unsigned, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    if sizeof(RT) > sizeof(TB)
        if sizeof(RT) >= sizeof(TA)
            RT(a) + RT(b)
        else
            TA(a) + TA()
        end
    elseif sizeof(RT) < sizeof(TB)
        RT(a) + RT(b)
    else
        RT(a + b)
    end
end
function addcast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Unsigned, TB<:Signed, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    RT(a) + RT(b)
end

can_represent(T::DataType,L::Integer,U::Integer) = L >= typemin(T) && U <= typemax(T)
can_represent(T::DataType,::AutoInteger{L,U}) where {L,U} = can_represent(T, L, U)

import Base: +
function +(a::AutoInteger{LA,UA,TA}, b::AutoInteger{LB,UB,TB}) where {LA,UA,TA,LB,UB,TB} 
    LR = LA+LB
    UR = UA+UB
    TR = auto_integer_type(L,U)
    if can_represent(TR, a)
        if can_represent(TR, b)
            return AutoInteger{LR,UR}(TR(a) + TR(b))
        else
            error("")
        end
    else
        error("")
    end
end

function +(a::AutoInteger{LA,UA}, b::AutoInteger{LB,UB}) where {LA,UA,LB,UB} 
    L = LA+LB
    U = UA+UB
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(addcast(a.val, b.val, T))
end
function +(a::AutoInteger{LA,UA}, b::Integer) where {LA,UA}
    L = LA+b
    U = UA+b
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(addcast(a.val, b, T))
end
+(a::Integer, b::AutoInteger) = b + a
