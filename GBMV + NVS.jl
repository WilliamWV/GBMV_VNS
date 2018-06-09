

srand(42)
#Projeto:

    #Instância:
        #Um grafo não-direcionado G = (V,A) com valores du,v>=0 
        #entre vértices u, v pertencentes a V com pesos pv para 
        #cada vértice v em V e limites L e U e um número g de 
        #grupos desejados
        #n = número de vértices
        #g = número de grupos
        #a = número de arestas
    #Solução:
        #Uma partição V = G1 U G2 U ... U Gg dos vértices dos g 
        #grupos, tal que
        
            #L<=p(Gk)<=U
        #onde p(G) é o peso total, somatório, de um grupo de 
        #vértices G
    #Objetivo : Maximizar o valor total das arestas entre vértices 
    #do mesmo grupo

    
# Code by : William Wilbert Vargas


#Ideias para vizinhança - Todas assumindo que a solução se mantém viável - em ordem crescente de número de vizinhos no caso médio:
    # 0) 
        #para cada possível dupla de grupos troca um dos
        #participantes da aresta compartilhada de maior valor
        #O(g*g) vizinhos 
    # 1) 
        #Para cada grupo, trocar o vértice v cujo aproveitamento precentual é menor, ou seja o vértice cuja soma das arestas 
        #que participa que são internas ao grupo divida pela soma total dos valores das arestas seja menor O(g*g)
    # 2) 
        #Para cada aresta compartilhada entre grupos trocar um dos elementos da aresta de grupo: O(a) vizinhos (percorre 
        #arestas e ve as são compartilhadas) 
    # 3)
        #escolher vértice e trocá-lo de grupo : O(n*g) vizinhos
    
    
#OBS sobre as vizinhanças : A vizinhança 0 está contida na vizinhança 2 assim como a vizinhança 1 está contida na vizinhança 3 elas foram separadas pois as vizinhanças 0 e 1 fazem considerações mais específicas em relação a função objetivo, logo tendem a poder melhorar o seu valor sem ter custos computacionais tão altos quanto a vizinhança 2 e 3, por esse motivo elas executarão antes e se usará a ideia de first improvement

#Uma instância do problema contém:
    # n = número de vértices
    # g = número de grupos
    # L[g] = limite inferior de cada grupo
    # U[g] = limite superior de cada grupo
    # P[n] = pesos de cada vértice
    # A[n,n] = peso da aresta entre o vértice os vértices

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

inst = Instance("gbmv240_01.ins")

#Uma solução para o problema é uma associação de cada um dos n vértices para um grupo do qual pertence

#Ideias para geração da solução inicial
  #1) Completamente aleatória : insere elementos nos grupos até 
    #passar L e depois insere os restantes nos grupos que ainda 
    #possuem espaço
  #2) Buscando uma solução inicial boa algoritmo guloso (Dúvida 
    #se posso usar e manter como VNS, já que é ideia do GRASP): 
    #insere em um grupo os elementos da melhor aresta disponível, 
    #em seguida de forma gulos adiciona elementos ao grupo até o 
    #que o peso inferior seja ultrapassado de modo que os 
    #elementos adicionados trazem consigo a maior aresta entre um 
    #elemento já no grupo e esse novo elemento.
    

type Solution
    G #Gvg 1 -> elemento v pertence ao grupo g ; 0 -> c.c.
    groupsVal #somatório dos pesos do grupo, adicionado como redundância para desempenho
    function Solution(instance)
        g = instance.g
        
        G = zeros(instance.n, instance.g)
        groupsVal = zeros(g)
        
        for i = 1:g
            
            currentVal = 0
            while(currentVal<instance.L[i])
                diced = rand(1:instance.n)
                if(sum(G[diced, j] for j =1:g) == 0)
                    G[diced, i] = 1
                    currentVal += instance.P[diced]
                end
            end
            groupsVal[i] = currentVal
            
        end
        
        currentGroup = 1
        i = 1
        while (i <=instance.n)
            if(sum(G[i, j] for j=1:g) == 0)
                if(groupsVal[currentGroup] + instance.P[i] 
                        <= instance.U[currentGroup])
                    G[i, currentGroup] = 1
                    groupsVal[currentGroup] += instance.P[i]
                    i+=1
                elseif(currentGroup > g)
                    println("Deu ruim, sem espaço nos grupos para criar disjunções dos vértices")
                else
                    currentGroup+=1
                end
            else
                i+=1
            end
        end
        new(G, groupsVal)
    end
end

S = Solution(inst)


function evaluate(instance, solution)
    #Objetivo : Maximizar o valor total das arestas entre vértices 
    #do mesmo grupo
    
    if solution == nothing
        return 0
    end
    
    sameGroup = zeros(instance.n, instance.n)
    
    for i =1:instance.n-1
        for j = i+1:instance.n
            sameGroup[i,j]=sum(solution.G[i,g]*solution.G[j, g] for g = 1:instance.g)#1-> i e j estão no mesmo grupo,0 ->c.c.
        end
    end
    return sum(instance.A[i,j] * sameGroup[i, j] for i =1:instance.n-1 for j=i+1:instance.n)
    
end

evaluate(inst, S)


function Movement(best, candidate, k)
    if (evaluate(inst, candidate) > evaluate(inst, best))
        best = candidate
        k = 1
    else
        k+=1
    end
    return (best,k)
end

function VertexIsOfGroup(vertex, group, solution)
    return solution.G[vertex, group] == 1
end

function getGroupOfVertex(vertex, solution)
    for i=1:size(solution.G[vertex,:])
        if(solution.G[vertex, i] == 1)
            return i
        end
        
    end
end

# 0) 
        #para cada possível dupla de grupos troca um dos
        #participantes da aresta compartilhada de maior valor
        #O(g*g) vizinhos 
    # 1) 
        #Para cada grupo, trocar o vértice v cujo aproveitamento precentual é menor, ou seja o vértice cuja soma das arestas 
        #que participa que são internas ao grupo divida pela soma total dos valores das arestas seja menor O(g*g)
     
    # 2)
        #escolher vértice e trocá-lo de grupo : O(n*g) vizinhos
    # 3) 
        #Para cada aresta compartilhada entre grupos trocar um dos elementos da aresta de grupo: O(n*n) vizinhos (percorre 
        #arestas e ve as são compartilhadas)

##UMA INSTANCIA NOVA DEVE SER CRIADA QUANDO A SOLUÇÃO É TROCADA
struct Neigh0 
    g1
    g2
end

function nextN0(N0, instance, solution)
    G1 = solution.G[:,N0.g1]
    G2 = solution.G[:,N0.g2]
    maxEdgeN1 = 0
    maxEdgeN2 = 0
    maxEdgeVal = 0
    direction = -1 # direction=0 : vértice sai de g1 para g2, direction=1 : oposto; direction=-1 sem trocas válidas
    for i = 1:instance.n-1
        for j = i+1:instance.n
            if (G1[i] * G2[j] * instance.A[i, j] > maxEdgeVal)
                if (solution.groupsVal[N0.g1]-instance.P[i]>=instance.L[N0.g1]&&solution.groupsVal[N0.g2]+instance.P[i]<=instance.U[N0.g2])
                    direction = 0
                    maxEdgeN1 = i
                    maxEdgeN2 = j
                    maxEdgeVal = instance.A[i,j]
                elseif(solution.groupsVal[N0.g1]+instance.P[j]<=instance.U[N0.g1]&&solution.groupsVal[N0.g2]-instance.P[j]>=instance.L[N0.g2])
                    direction = 1
                    maxEdgeN1 = i
                    maxEdgeN2 = j
                    maxEdgeVal = instance.A[i,j]
                end
            end
        end
    end
    
    
    NS = solution
    if (direction == 0)
        NS.G[maxEdgeN1, N0.g1] = 0
        NS.G[maxEdgeN1, N0.g2] = 1
        NS.groupsVal[N0.g1] -=instance.P[maxEdgeN1]
        NS.groupsVal[N0.g2] +=instance.P[maxEdgeN1]
    elseif (direction == 0)
        NS.G[maxEdgeN2, N0.g1] = 1
        NS.G[maxEdgeN2, N0.g2] = 0
        NS.groupsVal[N0.g1] +=instance.P[maxEdgeN1]
        NS.groupsVal[N0.g2] -=instance.P[maxEdgeN1]
    else
        NS = nothing
    end
    
    
    #Configure to next 
    if (N0.g2 < instance.g)
        Ng1 = N0.g1
        Ng2= N0.g2 + 1
    elseif(N0.g1 < instance.g - 1)
        Ng1= N0.g1 + 1
        Ng2 = N0.g1 + 2
    else
        #invalid
        Ng1 = 0
        Ng2 = 0
    end
    newN0 = Neigh0(Ng1, Ng2)
    if (NS != nothing)
        return (NS, newN0)
    elseif (Ng1 != 0)
        
        return nextN0(newN0, instance, solution)
    else
        return nothing
    end
end




function randomN0(instance, solution)
    g1 = rand(1:instance.g)
    g2 = rand(1:instance.g)
    while g2 == g1
        g2 = rand(1:instance.g)
    end
    
    G1 = solution.G[:,g1]
    G2 = solution.G[:,g2]
    maxEdgeN1 = 0
    maxEdgeN2 = 0
    maxEdgeVal = 0
    direction = -1 # direction=0 : vértice sai de g1 para g2, direction=1 : oposto; direction=-1 sem trocas válidas
    for i = 1:instance.n-1
        for j = i+1:instance.n
            if (G1[i] * G2[j] * instance.A[i, j] > maxEdgeVal)
                if (solution.groupsVal[g1]-instance.P[i]>=instance.L[g1]&&solution.groupsVal[g2]+instance.P[i]<=instance.U[g2])
                    direction = 0
                    maxEdgeN1 = i
                    maxEdgeN2 = j
                    maxEdgeVal = instance.A[i,j]
                elseif(solution.groupsVal[g1]+instance.P[j]<=instance.U[g1]&&solution.groupsVal[g2]-instance.P[j]>=instance.L[g2])
                    direction = 1
                    maxEdgeN1 = i
                    maxEdgeN2 = j
                    maxEdgeVal = instance.A[i,j]
                end
            end
        end
    end
    
    
    NS = solution
    if (direction == 0)
        NS.G[maxEdgeN1, g1] = 0
        NS.G[maxEdgeN1, g2] = 1
        NS.groupsVal[g1] -=instance.P[maxEdgeN1]
        NS.groupsVal[g2] +=instance.P[maxEdgeN1]
    elseif (direction == 0)
        NS.G[maxEdgeN2, g1] = 1
        NS.G[maxEdgeN2, g2] = 0
        NS.groupsVal[g1] +=instance.P[maxEdgeN1]
        NS.groupsVal[g2] -=instance.P[maxEdgeN1]
    else
        NS = nothing
    end
    
    if (NS != nothing)
        return NS
    else
        return randomN0(instance, solution)
    end
    
end

function randomN1(instance, solution)
    worstVertex = 0
    worstVal = 1.0
    gSrc = rand(1:instance.g)
    gDest = rand(1:instance.g)
    while gDest == gSrc
        gDest = rand(1:instance.g)
    end
    
    for i = 1:instance.n
        if(VertexIsOfGroup(i, gSrc, solution))
            #Calcula aproveitamento
            total = sum(instance.A[i,j] + instance.A[j,i] for j=1:instance.n) # A tabela de arestas é triangular, logo somar pela linha i e pela coluna i significa somar o valor de todas as arestas do vértice i
            inGroup = sum((instance.A[i,j] + instance.A[j,i]) * solution.G[j,N1.gSrc] for j = 1:instance.n)
            
            exploitation = inGroup/total
            if (exploitation < worstVal && solution.groupsVal[gSrc] - instance.P[i] >= instance.L[gSrc] && solution.grupsVal[gDest] + instance.P[i] <= instance.U[gDest])
                worstVertex = i
                worstVal = exploitation
            end
            
        end
        NS = solution
        if(worstVertex != 0)
            NS.G[worstVertex, N1.gSrc] = 0
            NS.G[worstVertex, N1.gDest] = 1
            NS.groupsVal[N1.gSrc] -= instance.P[worstVertex]
            NS.groupsVal[N1.gDest] += instance.P[worstVertex]
        else
            NS = nothing
        end
        
        if (NS!=nothing)
            return NS
        else
            return randomN1(instance, solution)
        end
        
    end
end

function randomN2(instance, solution)
    
    vertex = rand(instance.n)
    group = rand(instance.g)
    
NS = nothing
    if(!VertexIsOfGroup(vertex, group, solution))
        
        NS = solution
        gSrc = getGroupOfVertex(vertex)
        if (solution.groupsVal[gSrc] - instance.P[vertex] >= instance.L[gSrc] && solution.groupsVal[group] + instance.P[vertex] <= instance.U[group])
            NS.G[vertex, gSrc] = 0
            NS.G[vertex, group] = 1
            NS.gruopsVal[gSrc] -= instance.P[vertex]
            NS.gruopsVal[group] += instance.P[vertex]
        
        end
    end
    
    if(NS != nothing)
        return NS
    else
        return randomN2(instance, solution)
    end
end

function randomN3(instance, solution)
    v1 = rand(1:instance.n)
    v2 = rand(1:instance.n)
    g1 = getGroupOfVertex(v1)
    g2 = getGroupOfVertex(v2)
    
    direction = -1 # direction=0 : vértice sai de g1 para g2, direction=1 : oposto; direction=-1 sem trocas válidas
    NS = nothing
    if (g1 != g2)
        
        
        if (solution.groupsVal[g1] - instance.P[v1] >= instance.L[g1] && solution.groupsVal[g2] + instance.P[v1] <= instance.U[g2])
            NS = solution
            NS.G[v1, g1] = 0
            NS.G[v1, g2] = 1
            NS.groupsVal[g1] -= instance.P[v1]
            NS.groupsVal[g2] += instance.P[v1]
        elseif (solution.groupsVal[g2] - instance.P[v2] >= instance.L[g2] && solution.groupsVal[g1] + instance.P[v2] <= instance.U[g1])
            NS = solution
            NS.G[v2, g1] = 1
            NS.G[v2, g2] = 0
            NS.groupsVal[g1] += instance.P[v2]
            NS.groupsVal[g2] -= instance.P[v2]
        end
    end
    if (NS != nothing)
        return NS
    else
        return randomN3(instance, solution)
    end
end

RandomNeigh = [randomN0, randomN1, randomN2, randomN3]

        #Implementa Hill Climbing com first improvement usando vizinhança Neigh0
function LocalSearch(solution)
    N = Neigh0(1, 2) # first two groups
    
    Val = nextN0(N,inst, solution)

    if Val != nothing
        candidate = Val[1]
        N = Val[2]
    end
    while (candidate != nothing)
        if evaluate(inst, candidate) > evaluate(inst, solution)
            return LocalSearch(candidate)
        end
        Val = nextN0(N,inst, solution)

        if Val != nothing
            candidate = Val[1]
            N = Val[2]
        end 
    end
    return candidate
end

function VNS(init)
    beg = now()
    
    curr = now()
    while curr - beg < Base.Dates.Hour(1)
        
        k = 1
        bestSol = init

        while k <= 4
            println("Iter with k = $k")
            currentNeigh = RandomNeigh[k]
            randomSol = currentNeigh(inst, bestSol) # shake
            currentSol = LocalSearch(randomSol)
            (bestSol, k) = Movement(bestSol, currentSol, k)
            curr = now()
            if (curr - beg > Base.Dates.Hour(1))
                break
            end
        end
    end
    
end

    

VNS(S)


