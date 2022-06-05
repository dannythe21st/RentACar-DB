drop table particulares cascade constraints;
drop table empresariais cascade constraints;
drop table vendedores cascade constraints;
drop table clientes cascade constraints;
drop table pessoas cascade constraints;
drop table filiais cascade constraints;
drop table carros cascade constraints;
drop table categorias cascade constraints;
drop table alugueres cascade constraints;
drop table criticas cascade constraints;

drop table possui cascade constraints;

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

create table criticas(
    idCritica int,
    descricao varchar2(50),
    nota int,
    primary key (idCritica)
);

---------------------------------POSSUI---------------------------------

create table possui(
    referencia varchar2(20),
    idCritica int,
    foreign key (referencia) references alugueres(referencia),
    foreign key (idCritica) references criticas(idCritica)
);

---------------------------------VIEWS--------------------------------

        --------VIEW E TRIGGERS ALUGUERES--------

create or replace view v_alugueres as 
    select referencia, dataI, dataF, numCliente, matricula, numInterno, idCritica, descricao, nota
    from alugueres natural inner join possui
                    natural inner join criticas;
                
create or replace trigger ins_v_alugueres
    instead of insert on v_alugueres
    for each row
    begin
        insert into alugueres(referencia, dataI, dataF, numCliente, matricula, numInterno)
            values (null, :new.dataI, :new.dataF, :new.numCliente, :new.matricula, :new.numInterno);
        insert into criticas(idCritica, descricao, nota) values
            (null, :new.descricao, :new.nota);
        insert into possui(referencia, idCritica) values
            ((select max(referencia) from alugueres), (select max(idCritica) from criticas));
    end;
/    

create or replace trigger up_v_alugueres
    instead of update on v_alugueres
    for each row
    begin
        update criticas set
            descricao = :new.descricao,
            nota = :new.nota
            where idCritica = :new.idCritica;            
    end;
/   

create or replace trigger del_v_alugueres
    instead of delete on v_alugueres
    for each row
    begin
        delete from possui where referencia = :old.referencia and
        idCritica = :old.idCritica;
        delete from alugueres where referencia = :old.referencia; 
        delete from criticas where idCritica = :old.idCritica;
    end;
/


        --------VIEW  E TRIGGERS VENDEDORES--------

create or replace view v_vendedores as
    select nif, nomepessoa, morada, numInterno, salario, numVendas, nomeFilial
    from pessoas natural inner join vendedores;

create or replace trigger ins_v_vendedores
    instead of insert on v_vendedores
    for each row
    begin
        insert into pessoas(nif,nomepessoa,morada) values
            (:new.nif, :new.nomepessoa, :new.morada);
        insert into vendedores (nif, numInterno, salario, numVendas, nomeFilial) values 
            (:new.nif, null, null, null, :new.nomeFilial);
    end;
/ 

create or replace trigger up_v_vendedores
    instead of update on v_vendedores
    for each row
    begin
        update pessoas set
            morada = :new.morada
            where nif = :new.nif;
        update vendedores set
            salario = :new.salario,
            nomeFilial = :new.nomeFilial
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

        --------VIEW E TRIGGERS CLIENTES EMPRESARIAIS--------

create or replace view v_clientes_empresariais as
    select nif, nomepessoa, morada, numCliente, maxAlugueres, numAlugueres
    from pessoas natural inner join clientes
                 natural inner join empresariais;

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

        --------VIEW E TRIGGERS CLIENTES PARTICULARES--------

create or replace view v_clientes_particulares as
    select nif, nomepessoa, morada, numCliente, pontos
    from pessoas natural inner join clientes
                 natural inner join particulares;


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

---------------------------------SEQUENCIAS---------------------------------
drop sequence make_refer_aluguer;
drop sequence make_numcliente;
drop sequence make_numinterno;
drop sequence make_idCritica;


create sequence make_refer_aluguer
start with 1000
increment by 1;

create sequence make_numcliente
start with 00000
increment by 1
minvalue 00000;

create sequence make_numinterno
start with 0000
increment by 1
minvalue 0000;

create sequence make_idCritica
start with 0000
increment by 1
minvalue 0000;

---------------------------------TRIGGERS---------------------------------

        ----Triggers para as sequencias----

create or replace trigger new_numCliente
    before insert on clientes
    for each row
    declare numC int;
    begin
        if(:new.numCliente is null) then
            select make_numcliente.nextval
            into numC
            from dual;
           :new.numCliente := numC;
        end if;
    end;
/   


create or replace trigger new_referencia
    before insert on alugueres
    for each row
    declare refe int;
    begin
        if(:new.referencia is null) then 
        select make_refer_aluguer.nextval into refe
        from dual;
        :new.referencia := refe;
        end if;
    end;
/   

create or replace trigger new_numInterno
    before insert on vendedores
    for each row
    declare nI int;
    begin
       if(:new.numInterno is null) then
       select make_numInterno.nextval into nI
       from dual;
       :new.numInterno := nI;
        end if;
    end;
/   


create or replace trigger new_idCritica
    before insert on criticas
    for each row
    declare idC int;
    begin
       if(:new.idCritica is null) then
       select make_idCritica.nextval into idC
       from dual;
       :new.idCritica := idC;
        end if;
    end;
/   

        ----Triggers definir valores iniciais----

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

        ----TRIGGERS COMPUTACOES----

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
                (dataI = :new.dataI or dataF = :new.dataF)    or -- um dos dias coincide
                (dataI <= :new.dataI and :new.dataF <= dataF) or -- novo esta contido num ja existente
                (:new.dataI <= dataI and dataF <= :new.dataF) or -- novo contem um ja existente completamente
                (:new.dataI <= dataI and :new.dataF <= dataF) or -- o fim do novo calha a meio doutro aluguer existentes
                (dataI <= :new.dataI and dataF <= :new.dataF)    -- o inicio do novo esta a meio dum existente
                ));
            if(aux > 0)    
                then Raise_Application_Error (-20100, 'O carro nao esta disponivel nestes dias. Por favor escolha outro carro.');
            end if;
        end;
/     

create or replace trigger adiciona_numvendas
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
    begin
            update vendedores set salario = salario + (salario*0.05)
            where numInterno = :new.numInterno and numVendas > 0 and mod(numVendas,50) = 0;
    end;
/


-------------INSERTS-------------

delete from vendedores;
delete from empresariais;
delete from particulares;
delete from clientes;
delete from pessoas;
delete from carros;
delete from filiais;
delete from alugueres;



insert into filiais values ('CASCAIS');
insert into filiais values ('SINTRA');
insert into filiais values ('BENFICA');
insert into filiais values ('FUNCHAL');
insert into filiais values ('PORTIMAO');
insert into filiais values ('TAVIRA');
insert into filiais values ('COIMBRA');
insert into filiais values ('FAMALICAO');
insert into filiais values ('ESTORIL');
insert into filiais values ('MATOSINHOS');
insert into filiais values ('CASTELO BRANCO');
insert into filiais values ('BEJA');

---------------------------------CLIENTES PARTICULARES--------------------------

insert into v_clientes_particulares values (100000000, 'DANIEL', 'RUA SESAMO 1', null, null);
insert into v_clientes_particulares values (100000001, 'JOAO', 'RUA SESAMO 2', null, null);
insert into v_clientes_particulares values (100000002, 'TERESA', 'RUA SESAMO 3', null, null);
insert into v_clientes_particulares values (100000003, 'MIA', 'RUA SESAMO 4', null, null);
insert into v_clientes_particulares values (100000004, 'SARA', 'RUA SESAMO 5', null, null);
insert into v_clientes_particulares values (100000005, 'CARLOS', 'RUA SESAMO 6', null, null);
insert into v_clientes_particulares values (100000006, 'FERNANDO', 'RUA SESAMO 7', null, null);
insert into v_clientes_particulares values (100000007, 'CATARINA', 'RUA SESAMO 8', null, null);
insert into v_clientes_particulares values (100000008, 'ANA', 'RUA SESAMO 9', null, null);
insert into v_clientes_particulares values (100000009, 'SOFIA', 'RUA SESAMO 10', null, null);
insert into v_clientes_particulares values (100000010, 'PAULO', 'RUA SESAMO 11', null, null);
insert into v_clientes_particulares values (100000011, 'CLARA', 'RUA SESAMO 12', null, null);
insert into v_clientes_particulares values (100000012, 'FRANCISCO', 'RUA SESAMO 13', null, null);
insert into v_clientes_particulares values (100000013, 'PAULO', 'RUA SESAMO 14', null, null);
insert into v_clientes_particulares values (100000014, 'BEATRIZ', 'RUA SESAMO 15', null, null);
insert into v_clientes_particulares values (100000015, 'RUI', 'RUA SESAMO 16', null, null);
insert into v_clientes_particulares values (100000016, 'MIGUEL', 'RUA SESAMO 17', null, null);
insert into v_clientes_particulares values (100000017, 'MANEL', 'RUA SESAMO 18', null, null);
insert into v_clientes_particulares values (100000018, 'PAULO', 'RUA SESAMO 19', null, null);
insert into v_clientes_particulares values (100000019, 'SILVIA', 'RUA SESAMO 20', null, null);
insert into v_clientes_particulares values (100000020, 'FRANCISCO M', 'RUA SESAMO 21', null, null);
insert into v_clientes_particulares values (100000021, 'MARTIM', 'RUA SESAMO 22', null, null);
insert into v_clientes_particulares values (100000022, 'SALVADOR', 'RUA SESAMO 23', null, null);
insert into v_clientes_particulares values (100000023, 'ISAAC', 'RUA SESAMO 24', null, null);
insert into v_clientes_particulares values (100000024, 'CARLOTA', 'RUA SESAMO 25', null, null);
insert into v_clientes_particulares values (100000025, 'DIOGO', 'RUA SESAMO 26', null, null);
insert into v_clientes_particulares values (100000026, 'JOAO', 'RUA SESAMO 27', null, null);
insert into v_clientes_particulares values (100000027, 'VITOR', 'RUA SESAMO 28', null, null);
insert into v_clientes_particulares values (100000028, 'JORGE', 'RUA SESAMO 29', null, null);
insert into v_clientes_particulares values (100000029, 'MADALENA', 'RUA SESAMO 30', null, null);
insert into v_clientes_particulares values (100000030, 'MAFALDA', 'RUA SESAMO 31', null, null);
insert into v_clientes_particulares values (100000031, 'RITA', 'RUA SESAMO 32', null, null);
insert into v_clientes_particulares values (100000032, 'RICARDO', 'RUA SESAMO 33', null, null);
insert into v_clientes_particulares values (100000033, 'ANDREIA', 'RUA SESAMO 34', null, null);
insert into v_clientes_particulares values (100000034, 'ANDRE', 'RUA SESAMO 35', null, null);
insert into v_clientes_particulares values (100000035, 'DIANA', 'RUA SESAMO 36', null, null);
insert into v_clientes_particulares values (100000036, 'MARIA JOAO', 'RUA SESAMO 37', null, null);
insert into v_clientes_particulares values (100000037, 'JOAO MARIA', 'RUA SESAMO 38', null, null);
insert into v_clientes_particulares values (100000038, 'JOSE', 'RUA SESAMO 39', null, null);
insert into v_clientes_particulares values (100000039, 'HENRIQUE', 'RUA SESAMO 40', null, null);
insert into v_clientes_particulares values (100000040, 'JULIAO', 'RUA SESAMO 41', null, null);
insert into v_clientes_particulares values (100000041, 'VASCO', 'RUA SESAMO 42', null, null);
insert into v_clientes_particulares values (100000042, 'RODRIGO', 'RUA SESAMO 43', null, null);
insert into v_clientes_particulares values (100000043, 'DANILO', 'RUA SESAMO 44', null, null);
insert into v_clientes_particulares values (100000044, 'BERNARDO', 'RUA SESAMO 45', null, null);
insert into v_clientes_particulares values (100000045, 'JULIO', 'RUA SESAMO 46', null, null);
insert into v_clientes_particulares values (100000046, 'CAROLINA', 'RUA SESAMO 47', null, null);
insert into v_clientes_particulares values (100000047, 'ALICE', 'RUA SESAMO 48', null, null);
insert into v_clientes_particulares values (100000048, 'BARBARA', 'RUA SESAMO 49', null, null);
insert into v_clientes_particulares values (100000049, 'BENEDITA', 'RUA SESAMO 50', null, null);
insert into v_clientes_particulares values (100000050, 'CARMEN', 'RUA SESAMO 51', null, null);
insert into v_clientes_particulares values (100000051, 'GRACA', 'RUA SESAMO 52', null, null);
insert into v_clientes_particulares values (100000052, 'ISABEL', 'RUA SESAMO 53', null, null);
insert into v_clientes_particulares values (100000053, 'VERA', 'RUA SESAMO 54', null, null);
insert into v_clientes_particulares values (100000054, 'INES', 'RUA SESAMO 55', null, null);
insert into v_clientes_particulares values (100000055, 'LUISA', 'RUA SESAMO 56', null, null);
insert into v_clientes_particulares values (100000056, 'LUIS', 'RUA SESAMO 57', null, null);
insert into v_clientes_particulares values (100000057, 'LEONOR', 'RUA SESAMO 58', null, null);
insert into v_clientes_particulares values (100000058, 'OLIVIA', 'RUA SESAMO 59', null, null);
insert into v_clientes_particulares values (100000059, 'PATRICIA', 'RUA SESAMO 60', null, null);
insert into v_clientes_particulares values (100000060, 'EMILIA', 'RUA SESAMO 61', null, null);
insert into v_clientes_particulares values (100000061, 'ROSA', 'RUA SESAMO 62', null, null);
insert into v_clientes_particulares values (100000062, 'ANTONIO', 'RUA SESAMO 63', null, null);
insert into v_clientes_particulares values (100000063, 'BENJAMIM', 'RUA SESAMO 64', null, null);
insert into v_clientes_particulares values (100000064, 'CAETANO', 'RUA SESAMO 65', null, null);
insert into v_clientes_particulares values (100000065, 'DUARTE', 'RUA SESAMO 66', null, null);
insert into v_clientes_particulares values (100000066, 'GABRIEL', 'RUA SESAMO 67', null, null);
insert into v_clientes_particulares values (100000067, 'GONCALO', 'RUA SESAMO 68', null, null);
insert into v_clientes_particulares values (100000068, 'MARIO', 'RUA SESAMO 69', null, null);
insert into v_clientes_particulares values (100000069, 'PILAR', 'RUA SESAMO 70', null, null);
insert into v_clientes_particulares values (100000070, 'MARIANA', 'RUA SESAMO 71', null, null);
insert into v_clientes_particulares values (100000071, 'MERCEDES', 'RUA SESAMO 72', null, null);
insert into v_clientes_particulares values (100000072, 'MONICA', 'RUA SESAMO 73', null, null);
insert into v_clientes_particulares values (100000073, 'NUNO', 'RUA SESAMO 74', null, null);
insert into v_clientes_particulares values (100000074, 'FREDERICO', 'RUA SESAMO 75', null, null);
insert into v_clientes_particulares values (100000075, 'SIMAO', 'RUA SESAMO 75', null, null);

---------------------------------CLIENTES EMPRESARIAIS--------------------------

insert into v_clientes_empresariais values (100000076, 'JAIME', 'RUA SESAMO 76', null, null, null);
insert into v_clientes_empresariais values (100000077, 'ALEXANDRE', 'RUA SESAMO 77', null, null, null);
insert into v_clientes_empresariais values (100000078, 'DINIS', 'RUA SESAMO 78', null, null, null);
insert into v_clientes_empresariais values (100000079, 'GUILHERME', 'RUA SESAMO 79', null, null, null);
insert into v_clientes_empresariais values (100000080, 'PEDRO', 'RUA SESAMO 80', null, null, null);
insert into v_clientes_empresariais values (100000081, 'DORA', 'RUA SESAMO 81', null, null, null);
insert into v_clientes_empresariais values (100000082, 'RUTE', 'RUA SESAMO 82', null, null, null);
insert into v_clientes_empresariais values (100000083, 'SONIA', 'RUA SESAMO 83', null, null, null);
insert into v_clientes_empresariais values (100000084, 'ENZO', 'RUA SESAMO 84', null, null, null);
insert into v_clientes_empresariais values (100000085, 'CRISTAL', 'RUA SESAMO 85', null, null, null);
insert into v_clientes_empresariais values (100000086, 'ADOLFO', 'RUA SESAMO 86', null, null, null);
insert into v_clientes_empresariais values (100000087, 'SUSANA', 'RUA SESAMO 87', null, null, null);
insert into v_clientes_empresariais values (100000088, 'NAZARE', 'RUA SESAMO 88', null, null, null);
insert into v_clientes_empresariais values (100000089, 'FABIO', 'RUA SESAMO 89', null, null, null);
insert into v_clientes_empresariais values (100000090, 'TELMO', 'RUA SESAMO 90', null, null, null);

---------------------------------VENDEDORES---------------------------------

insert into v_vendedores values (100000091, 'LEANDRO', 'RUA SESAMO 91', null, null, null, 'SINTRA'); 
insert into v_vendedores values (100000092, 'CIDALIA', 'RUA SESAMO 92', 100, null, null, 'SINTRA');
insert into v_vendedores values (100000093, 'ROSALINA', 'RUA SESAMO 93', null, null, null, 'SINTRA');
insert into v_vendedores values (100000094, 'GEDSON', 'RUA SESAMO 94', null, null, null, 'SINTRA');
insert into v_vendedores values (100000095, 'AMILCAR', 'RUA SESAMO 95', null, null, null, 'SINTRA');
insert into v_vendedores values (100000096, 'BRUNO', 'RUA SESAMO 96', null, null, null, 'SINTRA');
insert into v_vendedores values (100000097, 'BRUNA', 'RUA SESAMO 97', null, null, null, 'SINTRA');
insert into v_vendedores values (100000098, 'TATIANA', 'RUA SESAMO 98', null, null, null, 'SINTRA');
insert into v_vendedores values (100000099, 'LILIANA', 'RUA SESAMO 99', null, null, null, 'SINTRA');
insert into v_vendedores values (100000100, 'VITORIA', 'RUA SESAMO 100', null, null, null, 'SINTRA');
insert into v_vendedores values (100000101, 'MARISOL', 'RUA SESAMO 101', null, null, null, 'SINTRA');
insert into v_vendedores values (100000102, 'ROGERIO', 'RUA SESAMO 102', null, null, null, 'SINTRA');
insert into v_vendedores values (100000103, 'SEBASTIAO', 'RUA SESAMO 103', null, null, null, 'SINTRA');
insert into v_vendedores values (100000104, 'ANGELO', 'RUA SESAMO 104', null, null, null, 'SINTRA');
insert into v_vendedores values (100000105, 'ANGELA', 'RUA SESAMO 105', null, null, null, 'SINTRA');
insert into v_vendedores values (100000106, 'SERGIO', 'RUA SESAMO 106', null, null, null, 'CASCAIS');
commit;

---------------------------------CATEGORIAS---------------------------------

insert into categorias values ('NORMAL', 365);
insert into categorias values ('LUXO', 550);
insert into categorias values ('ECONOMICO', 175);
insert into categorias values ('UTILITARIO', 395);

---------------------------------CARROS---------------------------------

    ------NORMAL------
    
insert into carros values ('12-AB-34', 2021, 'TOYOTA', 'YARIS GR', 'NORMAL', 'SINTRA');
insert into carros values ('12-RT-24', 2018, 'TOYOTA', 'YARIS GR', 'NORMAL', 'CASCAIS');
insert into carros values ('14-AB-34', 2020, 'TOYOTA', 'YARIS', 'NORMAL', 'CASCAIS');
insert into carros values ('17-AB-34', 2022, 'TOYOTA', 'MIRAI', 'NORMAL', 'FUNCHAL');
insert into carros values ('17-AH-34', 2022, 'TOYOTA', 'RAV4', 'NORMAL', 'ESTORIL');
insert into carros values ('14-VB-34', 2022, 'TOYOTA', 'HIGHLANDER', 'NORMAL', 'FUNCHAL');
insert into carros values ('17-AB-84', 2022, 'TOYOTA', 'C-HR', 'NORMAL', 'FUNCHAL');
insert into carros values ('18-AB-34', 2018, 'AUDI', 'A3', 'NORMAL', 'SINTRA');
insert into carros values ('19-AB-34', 2016, 'AUDI', 'A1', 'NORMAL', 'CASCAIS');
insert into carros values ('64-BM-35', 2006, 'AUDI', 'A6 AVANT', 'NORMAL', 'CASCAIS');
insert into carros values ('12-GG-24', 2019, 'FIAT', 'TIPO', 'NORMAL', 'PORTIMAO');
insert into carros values ('64-AR-35', 2018, 'FIAT', '500E', 'NORMAL', 'TAVIRA');
insert into carros values ('12-BD-24', 2020, 'RENAULT', 'SCENIC', 'NORMAL', 'CASCAIS');
insert into carros values ('12-CD-24', 2018, 'RENAULT', 'CLIO', 'NORMAL', 'SINTRA');
insert into carros values ('18-FH-83', 2019, 'RENAULT', 'MEGANE', 'NORMAL', 'PORTIMAO');
insert into carros values ('87-AB-38', 2020, 'SEAT', 'IBIZA', 'NORMAL', 'BENFICA');
insert into carros values ('31-AB-39', 2020, 'SEAT', 'ARONA', 'NORMAL', 'SINTRA');
insert into carros values ('12-PE-24', 2020, 'SEAT', 'LEON', 'NORMAL', 'TAVIRA');
insert into carros values ('12-ZB-24', 2022, 'VOLKSWAGEN', 'GOLF', 'NORMAL', 'FUNCHAL');
insert into carros values ('12-EQ-24', 2017, 'VOLKSWAGEN', 'PASSAT', 'NORMAL', 'FUNCHAL');
insert into carros values ('12-TB-24', 2020, 'VOLKSWAGEN', 'T-ROC', 'NORMAL', 'SINTRA');
insert into carros values ('12-TB-64', 2019, 'VOLKSWAGEN', 'TIGUAN', 'NORMAL', 'PORTIMAO');
insert into carros values ('12-AE-35', 2021, 'CITROEN', 'C3', 'NORMAL', 'BENFICA');
insert into carros values ('12-AE-76', 2017, 'CITROEN', 'C3 AIRCROSS', 'NORMAL', 'ESTORIL');
insert into carros values ('15-GE-76', 2020, 'CITROEN', 'C4', 'NORMAL', 'SINTRA');
insert into carros values ('18-HG-40', 2016, 'PEUGEOT', '208', 'NORMAL', 'ESTORIL');
insert into carros values ('68-AB-76', 2019, 'PEUGEOT', '308', 'NORMAL', 'ESTORIL');
insert into carros values ('68-AH-50', 2018, 'PEUGEOT', '508', 'NORMAL', 'SINTRA');
insert into carros values ('70-AY-41', 2016, 'PEUGEOT', '2008', 'NORMAL', 'ESTORIL');
insert into carros values ('68-AS-40', 2019, 'PEUGEOT', '3008', 'NORMAL', 'ESTORIL');
insert into carros values ('68-AB-40', 2017, 'PEUGEOT', '5008', 'NORMAL', 'SINTRA');
insert into carros values ('64-CZ-35', 2010, 'MINI', 'COOPER', 'NORMAL', 'FUNCHAL');
insert into carros values ('64-KJ-35', 2022, 'MINI', 'ONE 3P', 'NORMAL', 'SINTRA');
insert into carros values ('64-XS-35', 2018, 'FORD', 'FIESTA', 'NORMAL', 'ESTORIL');
insert into carros values ('12-GX-24', 2018, 'FORD', 'FOCUS', 'NORMAL', 'CASCAIS');
insert into carros values ('12-GB-12', 2016, 'FORD', 'FOCUS ST', 'NORMAL', 'CASCAIS');
insert into carros values ('12-LL-24', 2018, 'OPEL', 'ASTRA', 'NORMAL', 'CASCAIS');
insert into carros values ('11-FG-24', 2020, 'OPEL', 'MOKKA', 'NORMAL', 'CASCAIS');
insert into carros values ('12-LL-65', 2020, 'OPEL', 'INSIGNIA', 'NORMAL', 'CASCAIS');
insert into carros values ('11-HI-24', 2021, 'OPEL', 'CROSSLAND', 'NORMAL', 'CASCAIS');
insert into carros values ('64-KL-35', 2018, 'JEEP', 'GRAND CHEROKEE', 'NORMAL', 'SINTRA');
insert into carros values ('64-SR-35', 2018, 'JEEP', 'WRANGLER', 'NORMAL', 'CASCAIS');
insert into carros values ('64-WW-35', 2022, 'HONDA', 'E', 'NORMAL', 'PORTIMAO');
insert into carros values ('99-AR-35', 2007, 'BMW', '118 D', 'NORMAL', 'SINTRA');
insert into carros values ('86-AR-35', 2008, 'SKODA', 'OCTAVIA', 'NORMAL', 'TAVIRA');
insert into carros values ('13-AB-34', 2022, 'MERCEDES', 'CLASSE A', 'NORMAL', 'ESTORIL');
insert into carros values ('64-WW-35', 2017, 'VOLVO', 'V40', 'NORMAL', 'CASCAIS');
insert into carros values ('64-HH-35', 2018, 'MAZDA', '3', 'NORMAL', 'SINTRA');
insert into carros values ('19-SL-04', 2020, 'KIA', 'EV6', 'NORMAL', 'SINTRA');

    ------LUXO------

insert into carros values ('21-AC-35', 2021, 'BMW', 'Z4', 'LUXO', 'ESTORIL');
insert into carros values ('11-SH-35', 1987, 'BMW', 'M3 (E30)', 'LUXO', 'CASCAIS');
insert into carros values ('12-TT-24', 2022, 'BMW', 'M3', 'LUXO', 'CASCAIS');
insert into carros values ('12-VV-24', 2022, 'BMW', 'M4', 'LUXO', 'ESTORIL');
insert into carros values ('10-FD-34', 2021, 'PORSCHE', '911 CARRERA S', 'LUXO', 'ESTORIL');
insert into carros values ('10-BD-34', 2021, 'PORSCHE', '911 TURBO S', 'LUXO', 'BEJA');
insert into carros values ('10-MN-33', 2021, 'PORSCHE', 'PANAMERA', 'LUXO', 'SINTRA');
insert into carros values ('10-AS-34', 2021, 'PORSCHE', 'TAYCAN', 'LUXO', 'ESTORIL');
insert into carros values ('10-WE-34', 2021, 'PORSCHE', '911 GT3', 'LUXO', 'ESTORIL');
insert into carros values ('10-RR-34', 2021, 'PORSCHE', 'TARGA 4', 'LUXO', 'BEJA');
insert into carros values ('10-SE-34', 2021, 'PORSCHE', '718 SPYDER', 'LUXO', 'ESTORIL');
insert into carros values ('10-GA-34', 2021, 'PORSCHE', 'MACAN GTS', 'LUXO', 'ESTORIL');
insert into carros values ('10-AB-34', 2021, 'PORSCHE', '911 CARRERA S', 'LUXO', 'SINTRA');
insert into carros values ('12-AB-35', 2022, 'PORSCHE', 'PANAMERA', 'LUXO', 'PORTIMAO');
insert into carros values ('64-GU-56', 2017, 'PORSCHE', '718 CAYMAN', 'LUXO', 'ESTORIL');
insert into carros values ('10-MN-34', 2021, 'MERCEDES', 'AMG GT R', 'LUXO', 'ESTORIL');
insert into carros values ('64-YJ-12', 2019, 'MERCEDES', 'CLA 200 D', 'LUXO', 'ESTORIL');
insert into carros values ('12-AA-24', 2022, 'AUDI', 'R8', 'LUXO', 'CASCAIS');
insert into carros values ('11-WY-34', 2015, 'AUDI', 'E-TRON', 'LUXO', 'CASCAIS');
insert into carros values ('12-AB-14', 2022, 'ROLLS ROYCE', 'PHANTOM', 'LUXO', 'CASCAIS');
insert into carros values ('12-AB-14', 2022, 'ROLLS ROYCE', 'PHANTOM', 'LUXO', 'CASCAIS');
insert into carros values ('64-XC-89', 2019, 'FORD', 'MUSTANG', 'LUXO', 'ESTORIL');
insert into carros values ('64-XC-89', 1967, 'FORD', 'MUSTANG SHELBY', 'LUXO', 'ESTORIL');
insert into carros values ('10-VV-34', 2021, 'BENTLEY', 'CONTINETAL GT', 'LUXO', 'SINTRA');
insert into carros values ('10-JK-31', 2021, 'BENTLYEY', 'FLYING SPUR', 'LUXO', 'ESTORIL');
insert into carros values ('11-XB-34', 2022, 'LAMBORGHINI', 'HURACAN EVO', 'LUXO', 'BEJA');
insert into carros values ('31-XB-34', 2022, 'LAMBORGHINI', 'URUS', 'LUXO', 'ESTORIL');
insert into carros values ('11-XB-87', 2014, 'MASERATI', 'GHIBLI', 'LUXO', 'ESTORIL');
insert into carros values ('41-XB-87', 2014, 'MASERATI', 'QUATTROPORTE', 'LUXO', 'ESTORIL');
insert into carros values ('11-XB-87', 2017, 'MASERATI', 'LEVANTE', 'LUXO', 'ESTORIL');
insert into carros values ('11-XL-34', 2018, 'MCLAREN', 'P1', 'LUXO', 'ESTORIL');
insert into carros values ('01-XB-87', 2017, 'MCLAREN', '720', 'LUXO', 'ESTORIL');
insert into carros values ('19-XB-87', 2020, 'FERRARI', 'F8 TRIBUTO', 'LUXO', 'ESTORIL');
insert into carros values ('11-XL-87', 2021, 'FERRARI', 'ROMA', 'LUXO', 'ESTORIL');
insert into carros values ('12-AB-33', 2019, 'FERRARI', 'LAFERRARI', 'LUXO', 'CASCAIS');
insert into carros values ('15-AB-34', 2021, 'NISSAN', 'GT-R NISMO', 'LUXO', 'CASCAIS');
insert into carros values ('11-XG-57', 2016, 'BRABUS', 'G900', 'LUXO', 'ESTORIL');
insert into carros values ('12-HG-24', 2018, 'VOLKSWAGEN', 'GOLF R', 'LUXO', 'BENFICA');
insert into carros values ('10-RR-34', 2022, 'ASTON MARTIN', 'VULCAN', 'LUXO', 'ESTORIL');
insert into carros values ('64-XU-77', 2010, 'CHEVROLET', 'CAMARO', 'LUXO', 'SINTRA');
insert into carros values ('12-TW-24', 2020, 'CUPRA', 'FORMENTOR', 'LUXO', 'ESTORIL');
insert into carros values ('12-QQ-24', 2022, 'TESLA', 'MODEL 3 PERFORMANCE', 'LUXO', 'CASCAIS');
insert into carros values ('64-FD-78', 2022, 'MINI', 'CLUBMAN JCW', 'LUXO', 'ESTORIL');
insert into carros values ('17-AA-34', 2022, 'TOYOTA', 'SUPRA', 'LUXO', 'FUNCHAL');
insert into carros values ('12-HB-89', 2020, 'HONDA', 'NSX', 'NORMAL', 'BEJA');
insert into carros values ('21-AA-21', 2020, 'RIMAC', 'NEVERA', 'LUXO', 'CASCAIS');

    ------UTILITARIO------
    

insert into carros values ('76-AD-35', 2021, 'FORD', 'TRANSIT', 'UTILITARIO', 'CASCAIS');
insert into carros values ('31-AN-35', 2021, 'FORD', 'RANGER', 'UTILITARIO', 'SINTRA');
insert into carros values ('31-AS-35', 2021, 'NISSAN', 'NAVARA', 'UTILITARIO', 'CASCAIS');
insert into carros values ('31-FF-35', 2021, 'NISSAN', 'D22', 'UTILITARIO', 'CASCAIS');
insert into carros values ('12-EE-35', 2021, 'CITROEN', 'BERLINGO', 'UTILITARIO', 'BENFICA');
insert into carros values ('12-IO-35', 2018, 'CITROEN', 'SPACETOURER', 'UTILITARIO', 'BENFICA');
insert into carros values ('54-AF-35', 2021, 'FIAT', 'DOBLO', 'UTILITARIO', 'SINTRA');
insert into carros values ('31-LX-35', 2021, 'MERCEDES', 'SPRINTER', 'UTILITARIO', 'CASCAIS');
insert into carros values ('31-AY-35', 2005, 'TOYOTA', 'BASTAR', 'UTILITARIO', 'CASCAIS');
insert into carros values ('67-AJ-34', 2022, 'TOYOTA', 'PROACE CITY', 'UTILITARIO', 'BENFICA');
insert into carros values ('17-AT-34', 2022, 'TOYOTA', 'HILUX', 'UTILITARIO', 'FUNCHAL');
insert into carros values ('17-JY-34', 2022, 'TOYOTA', 'LANDCRUISER', 'UTILITARIO', 'TAVIRA');
insert into carros values ('12-TB-53', 2017, 'VOLKSWAGEN', 'CADDY CARGO', 'UTILITARIO', 'PORTIMAO');
insert into carros values ('12-AA-53', 2020, 'VOLKSWAGEN', 'TRANSPORTER', 'UTILITARIO', 'BENFICA');
insert into carros values ('87-TB-53', 2022, 'VOLKSWAGEN', 'CRAFTER CARGO', 'UTILITARIO', 'PORTIMAO');
insert into carros values ('68-MM-40', 2017, 'PEUGEOT', 'PARTNER', 'UTILITARIO', 'ESTORIL');
insert into carros values ('68-MM-47', 2014, 'PEUGEOT', 'BOXER', 'UTILITARIO', 'ESTORIL');

    ------ECONOMICO------

insert into carros values ('64-AG-35', 2002, 'FORD', 'FUSION', 'ECONOMICO', 'BEJA');
insert into carros values ('12-AH-35', 2007, 'FORD', 'FOCUS', 'ECONOMICO', 'TAVIRA');
insert into carros values ('12-YO-24', 1998, 'FORD', 'KA', 'ECONOMICO', 'CASCAIS');
insert into carros values ('12-SS-24', 1992, 'FIAT', 'UNO 45 S', 'ECONOMICO', 'BEJA');
insert into carros values ('12-AM-35', 2008, 'FIAT', 'PUNTO', 'ECONOMICO', 'TAVIRA');
insert into carros values ('12-AS-35', 2013, 'FIAT', 'PANDA', 'ECONOMICO', 'FUNCHAL');
insert into carros values ('64-YY-35', 2004, 'FIAT', 'STILO', 'ECONOMICO', 'CASCAIS');
insert into carros values ('64-AA-35', 2004, 'FIAT', 'IDEA', 'ECONOMICO', 'TAVIRA');
insert into carros values ('12-PK-24', 1976, 'FIAT', '127', 'ECONOMICO', 'CASCAIS');
insert into carros values ('21-DZ-12', 2005, 'FIAT', 'MULTIPLA', 'ECONOMICO', 'CASCAIS');
insert into carros values ('12-AZ-35', 2003, 'VOLKSWAGEN', 'POLO TDI', 'ECONOMICO', 'FUNCHAL');
insert into carros values ('12-WH-35', 2021, 'VOLKSWAGEN', 'LUPO', 'ECONOMICO', 'FUNCHAL');
insert into carros values ('12-MH-35', 2017, 'VOLKSWAGEN', 'UP', 'ECONOMICO', 'TAVIRA');
insert into carros values ('64-KA-35', 1988, 'OPEL', 'KADETT 1.3', 'ECONOMICO', 'MATOSINHOS');
insert into carros values ('12-AT-35', 1999, 'OPEL', 'CORSA 1.2', 'ECONOMICO', 'CASCAIS');
insert into carros values ('12-AL-35', 1999, 'OPEL', 'ZAFIRA', 'ECONOMICO', 'BEJA');
insert into carros values ('12-UH-35', 1998, 'CITROEN', 'SAXO', 'ECONOMICO', 'CASCAIS');
insert into carros values ('12-AB-37', 2016, 'CITROEN', 'C1', 'ECONOMICO', 'BEJA');
insert into carros values ('12-YH-35', 1998, 'NISSAN', 'MICRA', 'ECONOMICO', 'TAVIRA');
insert into carros values ('12-AY-35', 2001, 'NISSAN', 'PRIMERA', 'ECONOMICO', 'MATOSINHOS');
insert into carros values ('12-PP-24', 2006, 'SKODA', 'ROOMSTER', 'ECONOMICO', 'BENFICA');
insert into carros values ('12-AP-35', 2006, 'MITSUBISHI', 'COLT', 'ECONOMICO', 'MATOSINHOS');
insert into carros values ('12-PO-24', 1997, 'SUZUKI', 'BALENO', 'ECONOMICO', 'FUNCHAL');
insert into carros values ('16-AB-34', 1997, 'TOYOTA', 'COROLLA', 'ECONOMICO', 'BENFICA');
insert into carros values ('12-AR-35', 2003, 'PEUGEOT', '108', 'ECONOMICO', 'MATOSINHOS');
insert into carros values ('12-AX-35', 2005, 'SMART', 'FORTWO', 'ECONOMICO', 'MATOSINHOS');
insert into carros values ('12-AC-35', 2018, 'DACIA', 'DUSTER STEPWAY', 'ECONOMICO', 'CASCAIS');


----------------------------------ALUGUER---------------------------------

insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 01, '11-XG-57',1,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 01, '18-FH-83',1,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '12-AY-35',5,null,'otimo',9);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 03, '18-HG-40',0,null,'bom',7);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '31-FF-35',0,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 05, '12-YO-24',9,null,'bom',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '12-YH-35',8,null,'EXCELENTE',8);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 07, '31-LX-35',7,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '12-PO-24',8,null,'bom',7);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '19-XB-87',5,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 03, '64-AG-35',8,null,'bom',6);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '12-AL-35',5,null,'bom',7);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 05, '64-XS-35',8,null,'EXCELENTE',9);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '14-AB-34',12,null,'otimo',8);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 09, '64-YY-35',8,null,'bom',7);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '19-XB-87',8,null,'mediocre',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 00, '12-TT-24',5,null,'bom',8);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 13, '12-AC-3',8,null,'EXCELENTE',10);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '12-PE-24',6,null,'bom',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '10-MN-33',4,null,'otimo',5);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 65, '12-AM-35',7,null,'bom',7);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '10-GA-34',8,null,'mediocre',4);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 34, '11-XB-87',1,null,'EXCELENTE',9);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 08, '64-XC-89',8,null,'bom',6);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 21, '64-CZ-35',2,null,'otimo',8);
insert into v_alugueres values(null,to_date('29.11.2022', 'DD.MM.YYYY'), to_date('05.12.2022', 'DD.MM.YYYY'), 21, '64-KJ-35',2,null,'otimo',7);


