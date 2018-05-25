
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

#Construção de solução inicial:
#para cada grupo g:
    #currentVal = 0
    #Adiciona aleatóriamente até passar Lg
    #enquanto currentVal<Lg:
        #adiciona em G algum vértice aleatório v não atribuído
        #currentVal+= Pv
    #Remove excesso se houver
    #enquanto currentVal>Ug:
        #remove vértice u de G com menor valor
        #currentVal-= Pu
    #Tenta de novo se agora o valor é muito pequeno 
    #adicionando em ordem e não mais aleatóriamente
    #se currentVal<Lg
        #remove todos os vértices de G
        # adiciona dos restantes em ordem crescente até que
        # currentVal>=Lg
    #Se mesmo assim não funciona recomeça tudo
    #se currentVal>Ug
        #Falha de criação 
        #reinicia todo o processo para todos os grupos

# Para os vértices v restantes:
    #insere em um grupo g qualquer tal que o valor de g somado a Pv seja menor que Uv
    

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

Instance("gbmv240_01.ins")
