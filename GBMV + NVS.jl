
#Projeto:

    #Instância:
        #Um grafo não-direcionado G = (V,A) com valores du,v>=0 
        #entre vértices u, v pertencentes a V com pesos pv para 
        #cada vértice v em V e limites L e U e um número g de 
        #grupos desejados
        #n = número de vértices
        #g = número de grupos
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
    

#Ideias para vizinhança - Todas assumindo que a solução se mantém viável:
    # 0) 
        #para grupos adjacentes(grupos com aresta compartilhada) troca um dos participantes da aresta de maior valor compartilhada de grupo O(g*g)
    # 1)
        #escolher vértice e trocá-lo de grupo O(n*g)
    # 2)
        #agrupar os grupos em duplas com critério de maior valor total de aresta entre as duplas e trocar x vértices de um componente da dupla por y do outro componente O(g*g*n) : para cada grupo deve calcular a soma das arestas compartilhadas com outro grupo o que custa O(g*g*n) a troca entre as dupla é constante uma vez que depende dos parâmetros x e y que devem ser ajustados
    
