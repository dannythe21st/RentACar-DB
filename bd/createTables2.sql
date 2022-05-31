-- TODO  
    -- DEFINIR CONSTANTES COMO NUMERO MAXIMO DE ALUGUERES, PONTOS INICIAIS (0)
    -- TABELAS FAZ E POSSUI
    -- EXTRAS
    -- VIEWS
    -- TESTAR

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

drop sequence make_refer_aluguer;
drop sequence make_numcliente;
drop sequence make_numinterno;


---------------------------------CRIACAO TABELAS---------------------------------

---------------------------------PESSOAS---------------------------------

create table pessoas(
    nif varchar2(9),
    nomepessoa varchar2(35),
    morada varchar2(50),
    primary key (nif)
);

---------------------------------CLIENTES---------------------------------

create table clientes(
    nif varchar2(9),
    numCliente int,
    unique (numCliente),
    foreign key (nif) references pessoas(nif)
);

---------------------------------PARTICULARES---------------------------------
        
create table particulares(
    numCliente int,
    pontos int,
    unique (numCliente),
    foreign key (numCliente) references clientes(numCliente)
);

---------------------------------EMPRESARIAIS---------------------------------
    
create table empresariais(
    numCliente int,
    maxAlugueres int,
    numAlugueres int,
    unique(numCliente),
    foreign key (numCliente) references clientes(numCliente)
);
      
---------------------------------CATEGORIAS---------------------------------

create table categorias(
    nomeCat varchar2(15),
    precoCat int,
    primary key (nomeCat)
);

---------------------------------FILIAIS---------------------------------

create table filiais(
    nomeFilial varchar2(20),
    primary key (nomeFilial)
);
      
---------------------------------VENDEDORES---------------------------------

create table vendedores(
    nif varchar2(9),
    numInterno int,
    salario int,
    numVendas int,
    nomeFilial varchar2(20),
    unique (numInterno),
    foreign key (nif) references pessoas(nif),
    foreign key (nomeFilial) references filiais(nomeFilial)
);

---------------------------------CARROS---------------------------------

create table carros(
    matricula varchar2(8),
    anoProd smallint,
    marca varchar2(15),
    modelo varchar2(30),
    nomeCat varchar2(15),
    nomeFilial varchar2(20),
    primary key (matricula),
    foreign key (nomeCat) references categorias(nomeCat),
    foreign key (nomeFilial) references filiais(nomeFilial)
);

---------------------------------ALUGUERES---------------------------------

create table alugueres(
    referencia varchar2(20),
    dataI date,
    dataF date,
    numCliente int,
    matricula varchar2(8),
    primary key (referencia),
    foreign key (numCliente) references clientes(numCliente),
    foreign key (matricula) references carros(matricula)
);

---------------------------------EXTRAS---------------------------------

create table extras(
    nomeExtra varchar2(30),
    precoExtra float,
    primary key (nomeExtra)
);

---------------------------------POSSUI---------------------------------

create table possui(
    referencia int,
    nomeExtra varchar2(20),
    primary key (referencia, nomeExtra)
);

---------------------------------FAZ---------------------------------

create table faz(
    nif varchar2(9),
    referencia int,
    primary key (nif, referencia)
);

---------------------------------VIEWS---------------------------------

create or replace view v_clientes as
    select nif, nomepessoa, morada, numCliente 
    from pessoas natural inner join clientes;


create or replace view v_vendedores as
    select nif, nomepessoa, morada, numInterno 
    from pessoas natural inner join vendedores;

        ----triggers clientes----

create or replace trigger ins_v_clientes
    instead of insert on v_clientes
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
        (:new.nif, :new.nomepessoa, :new.morada);
        insert into clientes (nif,numCliente) values (:new.nif, :new.numCliente);
    end;
/    

create or replace trigger up_v_clientes
    instead of update on v_clientes
    for each row
    begin
        update pessoas set
            nomepessoa = :new.nomepessoa,
            morada = :new.morada
            where nif = :new.nif;
        update clientes set
            numCliente = :new.numCliente
            where nif = :new.nif;
    end;
/

create or replace trigger del_v_clientes
    instead of delete on v_clientes
    for each row
    begin
        delete from pessoas where nif = :old.nif;
    end;
/
            
            ----triggers vendedores----

create or replace trigger ins_v_vendedores
    instead of insert on v_vendedores
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
        (:new.nif, :new.nomepessoa, :new.morada);
        insert into vendedores (nif,numInterno) values 
        (:new.nif, :new.numInterno);
    end;
/ 

create or replace trigger up_v_vendedores
    instead of update on v_vendedores
    for each row
    begin
        update pessoas set
            nomepessoa = :new.nomepessoa,
            morada = :new.morada
            where nif = :new.nif;
        update vendedores set
            numInterno = :new.numInterno
            where nif = :new.nif;
    end;
/

create or replace trigger del_v_vendedores
    instead of delete on v_vendedores
    for each row
    begin
        delete from pessoas where nif = :new.nif;
    end;
/



---------------------------------SEQUENCIAS---------------------------------

create sequence make_refer_aluguer
start with 1000
increment by 1;

drop sequence make_refer_aluguer;

create sequence make_numcliente
start with 00000
increment by 1
minvalue 00000;

drop sequence make_numcliente;

create sequence make_numinterno
start with 0000
increment by 1
minvalue 0000;

---------------------------------TRIGGERS---------------------------------

--verifica se um cliente empresarial pode alugar mais 1 carro ou se ja chegou ao limite
create or replace trigger verifica_limite_alugueres
  before insert on alugueres
  for each row
  declare exceeded number;
  begin
    select count(*) into exceeded 
    from empresariais where (numCliente = :new.numCliente and numAlugueres+1 > maxAlugueres); 
    if (exceeded > 0)
      then Raise_Application_Error (-20100, 'Atingiu o limite de carros alugados. Tera de esperar que um dos alugueres ativos termine.');
    end if;
  end;
/

drop trigger verifica_limite_alugueres;

--Acrescenta um novo aluguer ativo ao counter dum cliente empresarial
create or replace trigger adiciona_aluguer_ativo
    after insert on alugueres
    for each row
    declare numAlugueres number;
    begin
        update empresariais set numAlugueres = numAlugueres+1 
        where (numCliente = :new.numCliente);
    end;    
/        

drop trigger adiciona_aluguer_ativo;

--Um cliente particular recebe 5% do valor total dos alugueres em pontos
create or replace trigger adiciona_pontos
    after insert on alugueres
    for each row
    begin
    update particulares set pontos = (pontos + ((:new.dataF - :new.dataI) * 0.05 * (select precoCat from categorias inner join carros using (nomeCat) where (matricula = :new.matricula))))
        where (numCliente = :new.numCliente);
    end;    
/    
drop trigger adiciona_pontos; 

--Um cliente particular recebe 5% de desconto a cada 1500 pontos
create or replace trigger aplica_desconto
        



drop trigger aplica_desconto;

--Triggers para as sequencias

create or replace trigger new_numCliente
    before insert on alugueres
    for each row
    begin
        if(:new.numCliente is null) then
            select make_numcliente.nextval
            into :new.numcliente
            from dual;
        end if;
    end;
/   

create or replace trigger new_referencia
    before insert on alugueres
    for each row
    begin
        if(:new.referencia is null) then 
        select make_refer_aluguer.nextval
        into :new.referencia
        from dual;
        end if;
    end;
/   

create or replace trigger new_numInterno
    before insert on vendedores
    for each row
    begin
        if(:new.numInterno is null) then 
        select make_numinterno.nextval
        into :new.numInterno
        from dual;
        end if;
    end;
/   

drop trigger new_numInterno;