
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
        #para grupos adjacentes(grupos com aresta compartilhada) troca um dos participantes da aresta de maior valor
        #compartilhada entre os grupos : O(g*g) vizinhos (grupos compartilhados -> g*(g-1)/2 com grupos totalmente conexos)
    # 1) 
        #Para cada grupo, trocar o vértice v cujo aproveitamento precentual é menor, ou seja o vértice cuja soma das arestas 
        #que participa que são internas ao grupo divida pela soma total dos valores das arestas seja menor O(g*g)
    # 2) 
        #Para cada aresta compartilhada entre grupos trocar um dos elementos da aresta de grupo: O(a) vizinhos (percorre 
        #arestas e ve as são compartilhadas) 
    # 3)
        #escolher vértice e trocá-lo de grupo : O(n*g) vizinhos
    
    
#OBS sobre as vizinhanças : A vizinhança 0 está contida na vizinhança 2 assim como a vizinhança 1 está contida na vizinhança 3 elas foram separadas pois as vizinhanças 0 e 1 fazem considerações mais específicas em relação a função objetivo, logo tendem a poder melhorar o seu valor sem ter custos computacionais tão altos quanto a vizinhança 2 e 3, por esse motivo elas executarão antes e se usará a ideia de first improvement



