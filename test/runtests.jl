import AutoIntegers: AutoInteger, auto_integer_type
import Test: @test, @testset, @test_throws

function test_values(T)
    vcat(
        [typemin(T), typemax(T)],
        [rand(T) for i in 1:2]
    )
end

Ls = [0, -1, 1, -725, 9736, 571427049, 9223372036854775808]
Ls = [0, -1, 1, 126, 127, 128, 255, 256, 257, -126, -127, -128, -255, -256, -257, -725, 9736, 571427049, 9223372036854775808]
Us = Ls

LUs = filter(LU-> LU[1] <= LU[2], [(L,U) for L in Ls, U in Us])

# @testset "AutoInteger construction" begin
#     # Number is too big and BigInts are not allowed to be used as template params
#     @test_throws TypeError AutoInteger{-1,170141183460469231731687303715884105729}(0)
#     # auto_integer_type should also throw
#     @test_throws DomainError auto_integer_type(-1,170141183460469231731687303715884105729)
# end

# for op in [-]
#     @testset "Unary operator: $(op)" begin
#         for (L, U) in LUs
#             T = AutoInteger{L,U,auto_integer_type(L,U)}
#             for a in test_values(T)
#                 @test op(a).val == op(BigInt(a.val))
#             end
#         end
#     end
# end

for op in [+,-,*]
    # @testset "Binary operator: $(op)"
    begin
        for (L1, U1) in LUs, (L2, U2) in LUs
            T1 = AutoInteger{L1,U1,auto_integer_type(L1,U1)}
            T2 = AutoInteger{L2,U2,auto_integer_type(L2,U2)}
            for a in test_values(T1), b in test_values(T2)
                try
                    op(a,b).val == op(BigInt(a.val), BigInt(b.val))
                catch
                    @show a,b
                    op(a,b).val == op(BigInt(a.val), BigInt(b.val))
                end
                @test op(a,b).val == op(BigInt(a.val), BigInt(b.val))
            end
        end
    end
end

@testset "typemin/max" begin
    T = typeof(AutoInteger{-1,10}(4))

    @test typemin(T) === AutoInteger{-1,10}(-1)
    @test typemin(T) == -1

    @test typemax(T) === AutoInteger{-1,10}(10)
    @test typemax(T) == 10
end

@testset "equality" begin
    @test AutoInteger{-5,6}(3) === AutoInteger{-5,6}(3)
    @test AutoInteger{-5,6}(3) !== AutoInteger{-5,9}(3)
    @test AutoInteger{-5,6}(3) !== AutoInteger{-4,6}(3)

    @test AutoInteger{-5,6}(3) == AutoInteger{-5,6}(3)
    @test AutoInteger{-5,6}(3) == AutoInteger{-1,9}(3)
    @test AutoInteger{-5,6}(3) != AutoInteger{-5,6}(5)
end

@testset "parse" begin
    @testset "Success" begin
        a = parse(AutoInteger{1,100}, "3")
        @test a.val == 3
        @test typeof(a) <: AutoInteger{1,100}
        @test a === AutoInteger{1,100}(3)
    end

    @testset "Error" begin
        @test_throws ArgumentError parse(AutoInteger{1,100}, "abc")
    end
end

@testset "tryparse" begin
    @testset "Success" begin
        a = tryparse(AutoInteger{1,100}, "3")
        @test a.val == 3
        @test typeof(a) <: AutoInteger{1,100}
        @test a === AutoInteger{1,100}(3)
    end

    @testset "Failuer" begin
        @test isnothing(tryparse(AutoInteger{1,100}, "abc"))
    end
end
