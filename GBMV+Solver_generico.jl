
using JuMP
using GLPKMathProgInterface

m = Model(solver=GLPKSolverMIP(msg_lev=GLPK.MSG_ON))

type Instance
    n :: Int64
    g :: Int64
    L
    U
    P
    A
    function Instance(filename)
        open(filename) do f
            lines = readlines(f)
            first_line = split(lines[1])
            n = parse(Int64, first_line[1])
            g = parse(Int64, first_line[2])
            second_line = split(lines[2])
            L = zeros(g)
            U = zeros(g)
            for i=1:g
                L[i] = parse(Float64, second_line[i*2-1])
                U[i] = parse(Float64, second_line[i*2])
            end
            P = zeros(n)
            third_line = split(lines[3])
            for i=1:n
                P[i] = parse(Float64, third_line[i])
            end
            A = zeros(n,n)
            for i =4:first(size(lines))
                line = split(lines[i])
                u = parse(Int64,line[1])
                v = parse(Int64,line[2])
                value = parse(Float64, line[3])
                A[u+1,v+1] = value
            end
            
            new(n, g, L, U, P, A)
        end
    end
end

inst = Instance("instanciaTeste5.ins")

n = inst.n
g = inst.g
A = inst.A
P = inst.P
L = inst.L
U = inst.U

@variable(m, G[1:n, 1:g], Bin)
@variable(m, S[1:n, 1:n, 1:g], Bin)
@variable(m, St[1:n, 1:n], Bin)

@objective(m, Max, sum(A[i, j] * St[i, j] for i=1:n, j=1:n))
@constraint(m, [i=1:n], sum(G[i, j] for j=1:g)== 1)
@constraint(m, [i=1:n, j=1:n, k=1:g], S[i,j,k] <= (G[i, k] + G[j,k])/2)
@constraint(m, [i=1:n, j=1:n, k=1:g], S[i,j,k] >= G[i, k] + G[j,k] - 1)
@constraint(m, [i=1:n, j=1:n], St[i,j] <= sum(S[i, j, k] for k=1:g))
@constraint(m, [i=1:n, j=1:n], St[i,j] >= sum(S[i, j, k] for k=1:g)/g)
@constraint(m, [j=1:g] , L[j] <= sum(P[i] * G[i,j] for i =1:n) <= U[j])


solve(m)


getobjectivevalue(m)


getValue(G)


println(m)


