--TODO DEFINIR CONSTANTES COMO NUMERO MAXIMO DE ALUGUERES, PONTOS INICIAIS (0)

drop table pessoas cascade constraints;
drop table clientes cascade constraints;
drop table particulares cascade constraints;
drop table empresariais cascade constraints;
drop table vendedores cascade constraints;
drop table gerentes cascade constraints;
drop table filiais cascade constraints;
drop table carros cascade constraints;
drop table categorias cascade constraints;
drop table alugueres cascade constraints;
drop table extras cascade constraints;

drop table faz cascade constraints;
drop table possui cascade constraints;

drop sequence refer_aluguer;
drop sequence make_numcliente;

---------------------------------CRIACAO TABELAS---------------------------------

---------------------------------PESSOAS---------------------------------

create table pessoas(
    nif varchar2(9),
    nomepessoa varchar2(35),
    morada varchar2(50)
);
alter table pessoas add constraint pk_pess primary key(nif);


---------------------------------CLIENTES---------------------------------

create table clientes(
    nif varchar2(9),
    numCliente int  
);
alter table clientes add constraint un_clientes unique (numCliente);
alter table clientes add constraint fk_clientespess foreign key (nif) references pessoas(nif);


---------------------------------PARTICULARES---------------------------------
        
create table particulares(
    numCliente int,
    pontos int
);
alter table particulares add constraint un_part unique(numCliente);
alter table particulares add constraint fk_partclientes foreign key (numCliente) references clientes(numCliente);


---------------------------------EMPRESARIAIS---------------------------------
    
create table empresariais(
    numCliente int,
    maxAlugueres int,
    numAlugueres int
);
alter table empresariais add constraint un_empre unique(numCliente);
alter table empresariais add constraint fk_empresclientes foreign key (numCliente) references clientes(numCliente);
    
    
---------------------------------VENDEDORES---------------------------------

create table vendedores(
    nif varchar2(9),
    numInterno int,
    contacto varchar2(9),
    nomeFilial varchar2(20)
);
alter table vendedores add constraint un_vendedores unique (numInterno);
alter table vendedores add constraint fk_vendedoresPessoas foreign key (nif) references pessoas(nif);
alter table vendedores add constraint fk_vendedoresFilial foreign key (nomeFilial) references filiais(nomeFilial);

---------------------------------FILIAIS---------------------------------

create table filiais(
    nomeFilial varchar2(20)
);
alter table filiais add constraint pk_filiais primary key (nomeFilial);

---------------------------------CARROS---------------------------------

create table carros(
    matricula varchar2(8),
    anoProd smallint,
    marca varchar2(15),
    modelo varchar2(30),
    nomeCat varchar2(15),
    nomeFilial varchar2(20)
);
alter table carros add constraint pk_carros primary key (matricula);
alter table carros add constraint fk_carroscat foreign key (nomeCat) references categorias(nomeCat);
alter table carros add constraint fk_carrosfiliais foreign key (nomeFilial) references filiais(nomeFilial);

---------------------------------CATEGORIAS---------------------------------

create table categorias(
    nomeCat varchar2(15),
    precoCat int 
);
alter table categorias add constraint pk_categ primary key (nomeCat);

---------------------------------ALUGUERES---------------------------------

create table alugueres(
    referencia varchar2(20),
    dataI date,
    dataF date,
    numCliente int,
    matricula varchar2(8)
);
alter table alugueres add constraint pk_alugueres primary key (referencia);
alter table alugueres add constraint fk_alugueresclientes foreign key (numCliente) references clientes(numCliente);
alter table alugueres add constraint fk_aluguerescarros foreign key (matricula) references carros(matricula);

---------------------------------EXTRAS---------------------------------

create table extras(
    nomeExtra varchar2(30),
    precoExtra float
);
alter table extras add constraint pk_extras primary key (nomeExtra);

---------------------------------POSSUI---------------------------------

create table possui(
    referencia int,
    nomeExtra varchar2(20)
);
alter table possui add constraint pk_possui primary key (referencia, nomeExtra);

---------------------------------FAZ---------------------------------

create table faz(
    nif varchar2(9),
    referencia int
);
alter table faz add constraint pk_faz primary key (nif, referencia);


---------------------------------SEQUENCIAS---------------------------------

create sequence refer_aluguer
start with 00000
increment by 1
minvalue 0;

create sequence make_numcliente
start with 1000
increment by 1;

---------------------------------TRIGGERS---------------------------------

--verifica se um cliente empresarial pode alugar mais 1 carro ou se ja chegou ao limite
create or replace trigger verifica_limite_alugueres
  before insert on alugueres
  declare exceded int;
  begin
    select count(*) from empresariais where (numCliente = new.numCliente and maxAlugueres +1 > numAlugueres) into exceded
    if (exceded > 1)
      then Raise_Application_Error (-20100, 'Atingiu o limite de carros alugados. Tera de esperar que um dos alugueres ativos termine.');
    end if;
  end;
/

drop trigger verifica_limite_alugueres;




