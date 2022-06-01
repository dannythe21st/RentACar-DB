-- TODO  
    -- DEFINIR CONSTANTES COMO NUMERO MAXIMO DE ALUGUERES, PONTOS INICIAIS (0)
    -- TABELAS FAZ E POSSUI
    -- EXTRAS
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
    nomepessoa varchar2(35) not null,
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
    nomeFilial varchar2(20) not null,
    unique (numInterno),
    foreign key (nif) references pessoas(nif),
    foreign key (nomeFilial) references filiais(nomeFilial)
);

---------------------------------CARROS---------------------------------

create table carros(
    matricula varchar2(8),
    anoProd smallint not null,
    marca varchar2(15) not null,
    modelo varchar2(30) not null,
    nomeCat varchar2(15) not null,
    nomeFilial varchar2(20) not null,
    primary key (matricula),
    foreign key (nomeCat) references categorias(nomeCat),
    foreign key (nomeFilial) references filiais(nomeFilial)
);

---------------------------------ALUGUERES---------------------------------

create table alugueres(
    referencia varchar2(20),
    dataI date not null,
    dataF date not null,
    numCliente int,
    matricula varchar2(8),
    numInterno int,
    primary key (referencia),
    foreign key (numCliente) references clientes(numCliente),
    foreign key (matricula) references carros(matricula),
    foreign key (numInterno) references vendedores(numInterno)
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

---------------------------------VIEWS---------------------------------

/*create or replace view v_clientes as
    select nif, nomepessoa, morada, numCliente 
    from pessoas natural inner join clientes;*/
    
    drop view v_clientes;

        ----VIEW VENDEDORES----
create or replace view v_vendedores as
    select nif, nomepessoa, morada, numInterno, salario, numVendas, nomeFilial
    from pessoas natural inner join vendedores;

        ----VIEW CLIENTES EMPRESARIAIS----

create or replace view v_clientes_empresariais as
    select nif, nomepessoa, morada, numCliente, maxAlugueres, numAlugueres
    from pessoas natural inner join clientes
                 natural inner join empresariais;

        ----VIEW CLIENTES PARTICULARES----

create or replace view v_clientes_particulares as
    select nif, nomepessoa, morada, numCliente, pontos
    from pessoas natural inner join clientes
                 natural inner join particulares;


        
        ----TRIGGERS CLIENTES EMPRESARIAIS----

create or replace trigger ins_v_clientes_empresariais
    instead of insert on v_clientes_empresariais
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
            (:new.nif, :new.nomepessoa, :new.morada);
        insert into clientes (nif,numCliente) values 
            (:new.nif, null);
        insert into empresariais(numCliente, maxAlugueres, numAlugueres) values
            ((select max(numCliente) from clientes), null, null);
    end;
/

create or replace trigger up_v_clientes_empresariais
    instead of update on v_clientes_empresariais
    for each row
    begin
        update pessoas set
            morada = :new.morada
            where nif = :new.nif;
        update empresariais set
            maxAlugueres = :new.maxAlugueres,
            numAlugueres = : new.numAlugueres
            where numCliente = :new.numCliente;
    end;
/

create or replace trigger del_v_clientes_empresariais
    instead of delete on v_clientes_empresariais
    for each row
    begin
        delete from pessoas where nif = :old.nif;
    end;
/

        ----TRIGGERS CLIENTES PARTICULARES----

create or replace trigger ins_v_clientes_particulares
    instead of insert on v_clientes_particulares
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
            (:new.nif, :new.nomepessoa, :new.morada);
        insert into clientes (nif,numCliente) values 
            (:new.nif, null);
        insert into particulares(numCliente, pontos) values
            ((select max(numCliente) from clientes), null);
    end;
/

create or replace trigger up_v_clientes_particulares
    instead of update on v_clientes_particulares
    for each row
    begin
        update pessoas set
            morada = :new.morada
            where nif = :new.nif;
    end;
/

create or replace trigger del_v_clientes_particulares
    instead of delete on v_clientes_particulares
    for each row
    begin
        delete from pessoas where nif = :old.nif;
    end;
/


/*create or replace trigger ins_v_clientes
    instead of insert on v_clientes
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
        (:new.nif, :new.nomepessoa, :new.morada);
        insert into clientes (nif,numCliente) values (:new.nif, null);
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

            ----triggers particulares----

create or replace trigger ins_v_particulares
    instead of insert on v_particulares
    for each row
    begin
        insert into ins_v_clientes(nif, numCliente) values
        (:new.nif, null);
        insert into particulares (numCliente, pontos) values (null, null);
    end;
/  

create or replace trigger del_v_particulares
    instead of delete on v_particulares
    for each row
    begin
        delete from clientes where numCliente = :old.numCliente;
    end;
/

            ----triggers empresariais----

create or replace trigger ins_v_pempresariais
    instead of insert on v_empresariais
    for each row
    begin
        insert into clientes(nif, numCliente) values
        (:new.nif, null);
        insert into empresariais (numCliente, maxAlugueres) values (null, null);
    end;
/  

create or replace trigger del_v_empresariais
    instead of delete on v_empresariais
    for each row
    begin
        delete from clientes where numCliente = :old.numCliente;
    end;
/   */         


            ----TRIGGERS VENDEDORES----

create or replace trigger ins_v_vendedores
    instead of insert on v_vendedores
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
        (:new.nif, :new.nomepessoa, :new.morada);
        insert into vendedores (nif,numInterno, salario, numVendas, nomeFilial) values 
        (:new.nif, null, null, null, :new.nomeFilial);
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

--Um cliente particular recebe 5% do valor total dos alugueres em pontos
create or replace trigger adiciona_pontos
    after insert on alugueres
    for each row
    begin
    update particulares set pontos = (pontos + ((:new.dataF - :new.dataI) * 0.05 * (select precoCat from categorias inner join carros using (nomeCat) where (matricula = :new.matricula))))
        where (numCliente = :new.numCliente);
    end;    
/    

-- Verifica se um carro ja esta alugado nuns dados dias 
create or replace trigger esta_alugado
    before insert on alugueres
        for each row
        declare aux number;
        begin
            select count (*) into aux 
            from alugueres where (matricula = :new.matricula and (
                (dataI <= :new.dataI and :new.dataF <= dataF) or -- novo esta contido num ja existente
                (:new.dataI <= dataI and dataF <= :new.dataF) or -- novo contem um ja existente completamente
                (:new.dataI <= dataI and dataF <= :new.dataF) or -- o fim do novo calha a meio doutro aluguer existentes
                (dataI <= :new.dataI and dataF <= :new.dataF)    -- o inicio do novo esta a meio dum existente
                ));
            if(aux > 0)    
                then Raise_Application_Error (-20100, 'O carro nao esta disponivel nestes dias :C Por favor escolha outro carro.');
            end if;
        end;
/     

create or replace trigger adiciona_numalugueres
    after insert on alugueres
    for each row
    begin
        update vendedores set numVendas = numVendas + 1 
        where (numInterno = :new.numInterno);
    end;     
/

create or replace trigger salary_bump
    after insert on alugueres
    for each row
    declare dummy int;
    begin
        select count(*) into dummy
        from alugueres
        where numInterno = :new.numInterno;
        if(dummy > 0 and mod(50, dummy) = 0) then
            update vendedores set salario = salario + (salario*0.05);
        end if;
    end;
/

create or replace trigger maxAlugueres_bumb


/


        ----Triggers para as sequencias----

create or replace trigger new_numCliente
    before insert on clientes
    for each row
    begin
        if(:new.numCliente is null) then
            :new.numCliente := make_numcliente.nextval;
        end if;
    end;
/   

create or replace trigger new_referencia
    before insert on alugueres
    for each row
    begin
        if(:new.referencia is null) then 
        :new.referencia := make_refer_aluguer.nextval;
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

--Triggers definir constantes

create or replace trigger set_salario
    before insert on vendedores
    for each row
    begin  
        if(:new.salario is null) then
        :new.salario := 1200;
        end if;
    end;
/

create or replace trigger set_numVendas
    before insert on vendedores
    for each row
    begin  
        if(:new.numVendas is null) then
        :new.numVendas := 0;
        end if;
    end;
/

create or replace trigger set_pontos
    before insert on particulares
    for each row
    begin  
        if(:new.pontos is null) then
        :new.pontos := 0;
        end if;
    end;
/

create or replace trigger set_maxAlugueres
    before insert on empresariais
    for each row
    begin  
        if(:new.maxAlugueres is null) then
        :new.maxAlugueres := 7;
        end if;
    end;
/   

create or replace trigger set_numAlugueres
    before insert on empresariais
    for each row
    begin  
        if(:new.numAlugueres is null) then
        :new.numAlugueres := 0;
        end if;
    end;
/ 