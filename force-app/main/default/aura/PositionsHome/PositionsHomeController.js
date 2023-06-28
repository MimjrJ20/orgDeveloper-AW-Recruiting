({
    //doInit - de inicialização do componente. É chamada quando o componente é carregado pela primeira vez.
    //component e event - parâmetros passados para a função que representam o componente e o evento disparado
    //helper - referência ao objeto de ajuda associado ao componente, que contém funções auxiliares
    doInit: function(component, event, helper){
        //o prefixo "c." é usado para se referir a um método definido no controlador JavaScript
        var action = component.get("c.getPositionsAndAccount");
        action.setCallback(this, function(response){
            //obtendo o estado da resposta da chamada Apex
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.positions", response.getReturnValue());
                component.set("v.allPositions", response.getReturnValue()); 
            }
        });
        //enfileirando a ação para ser executada
        $A.enqueueAction(action);
    },
    
    searchTable: function(component, event, helper) {
        //prefixo "v." é usado para se referir a um atributo ou variável definido no controlador ou componente JavaScript
        var searchTerm = component.get("v.searchTerm").toUpperCase();
        var allPositions = component.get("v.allPositions");
        
        if (searchTerm === "") {
            component.set("v.positions", allPositions); // Retorna a tabela completa se o campo de pesquisa estiver vazio
        } else {
            //método filter do JavaScript para filtrar os elementos do array "allPositions" com base em uma condição
            var filteredPositions = allPositions.filter(function(position) {
                //verificando se o nome da posição convertido para letras maiúsculas contém o valor do campo de pesquisa convertido para letras maiúsculas
                return position.Name.toUpperCase().includes(searchTerm);
            });
            component.set("v.positions", filteredPositions);
        }
    },
    
    clearSearch: function(component, event, helper) {
        component.set("v.searchTerm", ""); // Limpa o campo de pesquisa
        component.set("v.positions", component.get("v.allPositions")); // Retorna a tabela completa
    }
})

