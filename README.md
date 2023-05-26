# Project AW Recruiting

## AW é uma empresa que gerência oportunidades, contratos e vagas, no qual possui atividades relacionadas aos diversos objetos.

#### Objetos Padrões e Objetos Customizados, sendo eles:

Objetos Padrões: Account, Contract, Opportunity

Objetos Customizados: Position__c, Interview__c, Job_Application__c, Candidate__c

### O qual possui diversas regras de negócios, como:

- O CPF do candidato é validado;
- O CEP do cadastro para o candidato, caso sua localidade seja no Brasil, haverá uma consulta no ViaCEP;
- Toda vez que uma vaga é aplicada ao candidato ou atualizada é criado um post no Chatter com um resumo da vaga;
- Toda oportunidade fechada como ganha é convertido em um contrato;
- As oportunidades fechadas não podem ser alteradas;
- As oportunidades terão a data de ínicio do contrato limitado a data de hoje em diante;
- As oportunidades fechadas tem campos a serem preenchidos obrigatoriamente;
- A quantidade de posições devem respeitar o que foi definido em contrato.



# --------------------------------------------------------
##### Observação Importante!!!

###### Este projeto é fruto de auto-estudo.
###### Este projeto foi desconsiderado qualquer ferramenta do Salesforce, utilizando unicamente Class e Trigger.

