# Project AW Recruiting

## AW é uma empresa que gerencia oportunidades, contratos e vagas, no qual possui atividades relacionadas aos diversos objetos.

#### Objetos Padrões e Objetos Customizados, sendo eles:

Objetos Padrões: Account, Contract, Opportunity

Objetos Customizados: Position__c, Interview__c, Job_Application__c, Candidate__c


### O qual possui diversas regras de negócios, como:
#### Validações (CPF e CEP)
- O CPF do candidato é validado;
- O CEP do cadastro para o candidato, caso sua localidade seja no Brasil, haverá uma consulta na api ViaCEP;
- Toda vez que uma vaga é aplicada ao candidato ou atualizada é criado um post no Chatter com um resumo da vaga;

#### Oportunidades
- As oportunidades fechadas não podem ser alteradas;
- As oportunidades terão a data de ínicio do contrato limitado a data de hoje em diante;
- As oportunidades fechadas tem campos a serem preenchidos obrigatoriamente;
- As oportunidades do tipo Contract ao ser dadas como Ganho, será criado um contrato relacionado;
- As oportunidades do tipo Position ao ser dadas como Ganho, será criado uma posição;

#### Contratos
- Os contratos que tiver data de início vigente será ativado automaticamente;
- Os contratos que tiver data de término ultrapassado será fechado automaticamente;

#### Vagas
- A quantidade de posições devem respeitar o que foi definido em contrato;
- As posições que tiverem contas com contratos fechados serão canceladas.


### Trello

![alt text](https://github.com/MimjrJ20/orgDeveloper-AW-Recruiting/blob/main/img/trello-1.jpg)

# --------------------------------------------------------
##### Observação Importante!!!

###### Este projeto é fruto de auto-estudo.
###### Este projeto foi desconsiderado qualquer ferramenta do Salesforce, utilizando unicamente Class e Trigger.

