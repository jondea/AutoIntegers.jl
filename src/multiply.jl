



function multiplycast(a, b, ::Type{T})::T where {T}
    # By default, do the naive thing
    T(a) * T(b)
end
function multiplycast(a::T, b::T, ::Type{RT})::RT where {T,RT}
    # Covers the case where the return type is larger
    RT(a) * RT(b)
end
function multiplycast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Signed, TB<:Unsigned, RT<:Signed}
    # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
    RT(a) * RT(b)
end
# function multiplycast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Unsigned, TB<:Signed, RT<:Signed}
#     # Julia will automatically cast the Signed to Unsigned, force it to be the signed return type
#     RT(a) + RT(b)
# end
function multiplycast(a::TA, b::TB, ::Type{RT})::RT where {TA<:Signed, TB<:Signed, RT<:Unsigned}
    # If a signed * signed = unsigned, then they must both be negative. Negate them both and cast
    RT(-a) * RT(-b)
end

import Base: *
function *(a::AutoInteger{LA,UA}, b::AutoInteger{LB,UB}) where {LA,UA,LB,UB} 
    L = min(UA*LB, LA*UB, LA*LB, UA*UB)
    U = max(UA*LB, LA*UB, LA*LB, UA*UB)
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(multiplycast(a.val, b.val, T))
end
function *(a::AutoInteger{LA,UA}, b::Integer) where {LA,UA}
    L = min(L*b,U*b)
    U = max(L*b,U*b)
    T = auto_integer_type(L,U)
    AutoInteger{L,U}(multiplycast(a.val, b, T))
end
*(a::Integer, b::AutoInteger) = b * a
# Handle the trivial cases
*(a::AutoInteger, b::AutoInteger{0,0}) = AutoInteger{0,0}(0)
*(a::AutoInteger{0,0}, b::AutoInteger) = AutoInteger{0,0}(0)
*(a::AutoInteger{0,0}, b::AutoInteger{0,0}) = AutoInteger{0,0}(0)
