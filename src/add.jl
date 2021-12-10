
import Base.+
+(a::Integer, ::AutoInteger{0,0,T}) where T<:Integer = a
+(::AutoInteger{0,0,<:Integer}, b::Integer) = b
+(::AutoInteger{0,0,<:Integer}, ::AutoInteger{0,0,<:Integer}) = AutoInteger{0,0}(0)

function +(a::AutoInteger{LA,UA}, b::AutoInteger{LB,UB}) where {LA,UA,LB,UB} 
    L = LA+LB
    U = UA+UB
    T = auto_integer_type(L,U)
    TW = bound_union_type((LA,UA), (LB,UB), (L,U))
    AutoInteger{L,U}(T(TW(a.val) + TW(b.val)))
end
function +(a::AutoInteger{LA,UA}, b::Integer) where {LA,UA}
    L = LA+b
    U = UA+b
    T = auto_integer_type(L,U)
    # We assume b has the range of its type so that this function is type stable.
    # To do this while retaining the tight bounds, the value of b would need to be known at compile time
    # Or the user could just define AutoInteger{b,b}(b), maybe a macro for this?
    TW = bound_union_type((LA,UA), (typemin(b),typemax(b)), (L,U))
    AutoInteger{L,U}(T(TW(a.val) + TW(bl)))
end
+(a::Integer, b::AutoInteger) = b + a
