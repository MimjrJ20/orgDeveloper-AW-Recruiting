# **Project AW Recruiting**

## AW é uma empresa que gerencia oportunidades, contratos e vagas. No qual as atividades estão relacionadas aos diversos objetos.

### Objetos Padrões e Objetos Customizados, sendo eles:
- Objetos Padrões: Account, Contract, Opportunity
- Objetos Customizados: Position__c, Interview__c, Job_Application__c, Candidate__c

### Regras de negócios:
#### Candidatos (validações CPF e CEP)
- O CPF do candidato é validado;
- O CEP do cadastro para o candidato, caso sua localidade seja no Brasil, haverá uma consulta na api ViaCEP;
- Toda vez que uma vaga é aplicada ao candidato ou atualizada é criado um post no Chatter com um resumo da vaga.

#### Oportunidades
- As oportunidades fechadas não podem ser alteradas;
- As oportunidades terão a data de ínicio do contrato limitado a data de hoje em diante;
- As oportunidades fechadas tem campos a serem preenchidos obrigatoriamente;
- As oportunidades do tipo Contract ao ser dadas como Ganho, será criado um contrato relacionado;
- As oportunidades do tipo Position ao ser dadas como Ganho, será criado uma posição.

#### Contratos
- Os contratos que tiver data de início vigente será ativado automaticamente;
- Os contratos que tiver data de término ultrapassado será fechado automaticamente.

#### Vagas
- A quantidade de posições devem respeitar o que foi definido em contrato;
- As posições que tiverem contas com contratos fechados serão canceladas.


### Trello:

![Quadro do trello](https://github.com/MimjrJ20/orgDeveloper-AW-Recruiting/blob/main/img/trello-1.jpg)
<sub> Utilizado ferramenta ágil </sub>



### Observação importante!!!

###### Este projeto é fruto de auto-estudo.
###### Este projeto foi desconsiderado qualquer ferramenta do Salesforce, utilizando unicamente o modo programático com *Class* e *Trigger*.

