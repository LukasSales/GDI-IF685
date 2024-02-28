-- Criação de tipos
CREATE OR REPLACE TYPE tp_endereco AS OBJECT
(
    cidade VARCHAR2(50),
    estado CHAR(2), -- Só permitido siglas de estado
    
    MEMBER PROCEDURE atualizar_endereco(novo_cep NUMBER, nova_cidade VARCHAR2, nova_rua VARCHAR2, novo_numero NUMBER, novo_complemento VARCHAR2)
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY tp_endereco AS
    MEMBER PROCEDURE atualizar_endereco(novo_cep NUMBER, nova_cidade VARCHAR2, nova_rua VARCHAR2, novo_numero NUMBER, novo_complemento VARCHAR2) IS
    BEGIN
        -- Implementação da MEMBER PROCEDURE
        NULL; -- Adicione a lógica de atualização aqui conforme necessário
    END atualizar_endereco;
END;
/

-- Agora você pode criar o subtipo tp_enderecoOperador
CREATE OR REPLACE TYPE tp_enderecoOperador UNDER tp_endereco (
    cep NUMBER,
    rua VARCHAR2(40),
    numero NUMBER,
    complemento VARCHAR2(50),

    OVERRIDING MEMBER PROCEDURE atualizar_endereco(novo_cep NUMBER, nova_cidade VARCHAR2, nova_rua VARCHAR2, novo_numero NUMBER, novo_complemento VARCHAR2)
);
/

CREATE OR REPLACE TYPE BODY tp_enderecoOperador AS
    OVERRIDING MEMBER PROCEDURE atualizar_endereco(novo_cep NUMBER, nova_cidade VARCHAR2, nova_rua VARCHAR2, novo_numero NUMBER, novo_complemento VARCHAR2) IS
    BEGIN
        -- Implementação da OVERRIDING MEMBER PROCEDURE
        -- Pode chamar o método na superclasse usando o seguinte
        SELF AS tp_endereco.MEMBER PROCEDURE atualizar_endereco(novo_cep, nova_cidade, nova_rua, novo_numero, novo_complemento);
        -- Adicione a lógica específica do subtipo aqui
    END atualizar_endereco;
END;
/

CREATE OR REPLACE TYPE tp_localizacao AS OBJECT
(
    latitude NUMBER,
    longitude NUMBER
);
/

CREATE OR REPLACE TYPE tp_id_sistema AS OBJECT
(
    nome_parque VARCHAR2(40),
    pot_nom NUMBER
);
/

CREATE OR REPLACE TYPE tp_identificacaoSistema AS OBJECT
(
    nome VARCHAR2(40),
    pot_nome VARCHAR2(40)
);
/

CREATE OR REPLACE TYPE tp_telefone AS OBJECT 
(
    cod_area VARCHAR2(2),
    fone VARCHAR2(10),

    -- ORDER MEMBER FUNCTION
    ORDER MEMBER FUNCTION compare(another_telefone tp_telefone) RETURN NUMBER
);
/

CREATE TYPE BODY tp_telefone AS
    -- ORDER MEMBER FUNCTION Implementation
    ORDER MEMBER FUNCTION compare(another_telefone tp_telefone) RETURN NUMBER IS
    BEGIN
        -- Implemente a lógica de comparação aqui e retorne -1, 0 ou 1
        -- dependendo da relação de ordem entre o telefone atual e outro_telefone.
        -- Exemplo simples:
        IF SELF.cod_area < another_telefone.cod_area THEN
            RETURN -1;
        ELSIF SELF.cod_area > another_telefone.cod_area THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END compare;
END;
/

CREATE TYPE lista_tp_fone AS VARRAY(2) OF tp_telefone;
/

CREATE OR REPLACE TYPE tp_pessoa AS OBJECT
(
    id NUMBER,
    nome VARCHAR2(50),
    telefones lista_tp_fone,

    CONSTRUCTOR FUNCTION tp_pessoa(SELF IN OUT NOCOPY tp_pessoa, ID NUMBER, Nome VARCHAR2, Telefones lista_tp_fone) RETURN SELF AS RESULT,
    MAP MEMBER FUNCTION obter_cod_area RETURN VARCHAR2
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY tp_pessoa AS
    CONSTRUCTOR FUNCTION tp_pessoa(SELF IN OUT tp_pessoa, ID NUMBER, Nome VARCHAR2, Telefones lista_tp_fone) RETURN SELF AS RESULT IS
    BEGIN
        SELF.id := ID;
        SELF.nome := Nome; 
        SELF.telefones := Telefones;
        RETURN;

    MAP MEMBER FUNCTION obter_cod_area RETURN VARCHAR2 IS
        result VARCHAR2(4000);
    BEGIN
        result := '';
        FOR i IN 1..self.telefones.COUNT LOOP
            result := result || self.telefones(i).cod_area || ', ';
        END LOOP;
        RETURN RTRIM(result, ', '); -- Remover a última vírgula e espaço
    END obter_cod_area;
END;
/
    
CREATE OR REPLACE TYPE tp_pessoaFisica UNDER tp_pessoa
(
    cpf NUMBER
) NOT FINAL NOT INSTANTIABLE;
/ 
-- caso fosse criar clientes.

CREATE OR REPLACE TYPE tp_pessoaJuridica UNDER tp_pessoa
(
    cnpj VARCHAR2(14),
    nome_fantasia VARCHAR2(20)
) FINAL;
/

CREATE OR REPLACE TYPE tp_produtoEnergia AS OBJECT
(
    id_produto NUMBER,
    quantidade_kw INTEGER,
    data_venda DATE,
    prazo_entrega NUMBER
);
/

CREATE OR REPLACE TYPE tp_pontoConexao AS OBJECT
(
    id NUMBER,
    endereco tp_endereco,
    localizacao tp_localizacao,
    identificacao_sistema tp_identificacaoSistema
);
/

CREATE OR REPLACE TYPE tp_modeloEletrocentro AS OBJECT
(
    modelo VARCHAR2(40),
    fabricante VARCHAR2(40),
    tensao_nom NUMBER,
    autonomia_baterias VARCHAR2(40),
    corr_max_baterias NUMBER,
    pont_nom NUMBER
);
/

CREATE OR REPLACE TYPE tp_seColetora AS OBJECT
(
    id NUMBER,
    tensao_nom NUMBER,
    taxa_de_conversao NUMBER,
    localizacao tp_localizacao,
    id_sistema tp_id_sistema,
    seConecta REF tp_pontoConexao
);
/

CREATE OR REPLACE TYPE tp_eletrocentro AS OBJECT
(
    id_eletrocentro NUMBER,
    localizacao tp_localizacao,
    eletrocentro REF tp_modeloEletrocentro,
    eletrocentroseconectacoletora REF tp_secoletora
);
/

CREATE OR REPLACE TYPE tp_medidorPontoDeConexao AS OBJECT
(
    id_medidor NUMBER,
    num_de_serie NUMBER,
    num_prioridade NUMBER,
    pontoConexao REF tp_pontoConexao
);
/

CREATE OR REPLACE TYPE tp_MedidorseColetora AS OBJECT
(
    id_medidor NUMBER,
    num_prioridade NUMBER,
    num_serie NUMBER,
    geracaoSeColetora REF tp_seColetora
);
/

CREATE OR REPLACE TYPE tp_medidorEletrocentro AS OBJECT
(
    id_medidor NUMBER,
    num_serie NUMBER,
    num_prioridade NUMBER,
    eletrocentro REF tp_eletrocentro
);
/

CREATE OR REPLACE TYPE tp_negocia AS OBJECT
(
    idNegociacao NUMBER,
    pessoaNegocia REF tp_pessoa,
    produtoEnergiaNegocia REF tp_produtoEnergia,
    pontoConexaoNegocia REF tp_pontoConexao
);
/

CREATE OR REPLACE TYPE tp_modeloinversor AS OBJECT
(
    modelo varchar2(40),
    pot_nom_ca number,
    num_entradas_cc number,
    pot_max_ca number,
    pot_max_cc number,
    tensao_max_cc number,
    fabricante varchar2(40)
);
/

CREATE OR REPLACE TYPE tp_temp_operacao AS OBJECT
(
    temp_max number,
    temp_min number
);
/

CREATE OR REPLACE TYPE tb_modelopainel AS OBJECT
(
    modelo varchar2(40),
    fabricante varchar2(40),
    pot_max number,
    tensao_max_func number,
    corrente_pico number,
    temp_operacao tp_temp_operacao
);
/

CREATE OR REPLACE TYPE tp_instalacao AS OBJECT
(
    id_instalacao number,
    localizacao tp_localizacao,
    seconectaeletrocentro REF tp_eletrocentro
);
/

CREATE OR REPLACE TYPE tp_conjunto AS OBJECT
(
    id number,
    seconectaModeloinversor REF tp_modeloinversor,
    possuimodelopainel REF tb_modelopainel,
    conjuntoproduz REF tp_instalacao
);
/

CREATE OR REPLACE TYPE tp_medidorinstalacao AS OBJECT
(
    id_medidor number,
    num_serie number,
    num_prioridade number,
    geracaoinstalacao REF tp_instalacao
);
/
    
CREATE OR REPLACE TYPE tp_operador AS OBJECT
(
    matricula number,
    nome varchar2(40),
    cpf number,
    endereco tp_enderecoOperador,
    supervisor REF tp_operador,
    atuaemeletrocentro REF tp_eletrocentro,
    atuaemInstalacao REF tp_instalacao
);
/

CREATE TYPE tp_lista_negociacoes AS TABLE OF tp_negocia;
/

CREATE TYPE tp_lista_medidorPontoDeConexao AS TABLE OF tp_medidorPontoDeConexao;
/

CREATE TYPE tp_lista_medidorEletrocentro AS TABLE OF tp_medidorEletrocentro;
/

CREATE TYPE tp_lista_MedidorseColetora AS TABLE OF tp_MedidorseColetora;
/

CREATE TYPE tp_lista_medidorinstalacao AS TABLE OF tp_medidorinstalacao;
/

--Criando tabelas:

CREATE TABLE tb_pessoa OF tp_pessoa
(
    id PRIMARY KEY
);
/

CREATE TABLE tb_possuiGeracaoPontoDeConexao
(
    timestamp_geracao DATE,
    potencia NUMBER,
    GeracaoPontoConexao tp_lista_medidorPontoDeConexao
) NESTED TABLE GeracaoPontoConexao STORE AS tb_pontoConexao;
/
    
CREATE TABLE tb_seColetora OF tp_seColetora
(
    PRIMARY KEY (id)
);
/

CREATE TABLE tb_geracaoEletrocentro
(
    potencia NUMBER,
    timestamp_geracao DATE,
    medidorEletrocentro tp_lista_medidorEletrocentro
) NESTED TABLE medidorEletrocentro STORE AS tb_medidorEletrocentro;
/

CREATE TABLE tb_geracaoinstalacao
(
    timestamp_geracaoInstalacao date,
    potencia number,
    medidoresinstalacao tp_lista_medidorinstalacao
) NESTED TABLE medidoresinstalacao STORE AS tb_medidorgeracaoinstalacao;
/

CREATE TABLE tb_geracaoSEColetora
(
    potencia NUMBER,
    timestamp_medidor DATE,
    geracaoMedidor tp_lista_MedidorseColetora
) NESTED TABLE geracaoMedidor STORE AS tb_medidorseColetora;
/

CREATE TABLE tb_lista_negociacoes 
(
    idNegociacao NUMBER PRIMARY KEY,
    negociacoes tp_lista_negociacoes
) NESTED TABLE negociacoes STORE AS tb_negociacoes;
/

-- Tabela para tp_produtoEnergia
CREATE TABLE tb_produtoEnergia OF tp_produtoEnergia
(
    id_produto PRIMARY KEY
);
/

-- Tabela para tp_modeloEletrocentro
CREATE TABLE tb_modeloEletrocentro OF tp_modeloEletrocentro
(
    modelo PRIMARY KEY
);
/

-- Tabela para tp_eletrocentro
CREATE TABLE tb_eletrocentro OF tp_eletrocentro
(
    id_eletrocentro PRIMARY KEY
);
/
-- Tabela para tp_medidorPontoDeConexao
CREATE TABLE tb_medidorPontoDeConexao OF tp_medidorPontoDeConexao
(
    id_medidor PRIMARY KEY
);
/

-- Tabela para tp_negocia
CREATE TABLE tb_negocia OF tp_negocia
(
    idNegociacao PRIMARY KEY
);
/
-- Tabela para tb_modeloinversor
CREATE TABLE tb_modeloinversor OF tp_modeloinversor
(
    modelo PRIMARY KEY
);
/

-- Tabela para tp_instalacao
CREATE TABLE tb_instalacao OF tp_instalacao
(
    id_instalacao PRIMARY KEY
);
/
-- Tabela para tp_conjunto
CREATE TABLE tb_conjunto OF tp_conjunto
(
    id PRIMARY KEY
);
/
-- Tabela para tp_medidorinstalacao
CREATE TABLE tb_medidorinstalacao OF tp_medidorinstalacao
(
    id_medidor PRIMARY KEY
);
/
-- Tabela para tp_operador
CREATE TABLE tb_operador OF tp_operador
(
    matricula PRIMARY KEY
);
/

--Alteração:
ALTER TYPE tp_modeloinversor DROP ATTRIBUTE pot_max_cc CASCADE;


--Inserindo valores

-- Inserindo dados na tb_pessoa
INSERT INTO tb_pessoa VALUES (1, 'João', lista_tp_fone(tp_telefone('11', '123456789'), tp_telefone('22', '987654321')));

-- Inserindo dados na tb_modeloEletrocentro
INSERT INTO tb_modeloEletrocentro VALUES ('ModeloX', 'FabricanteX', 220, '4 horas', 100, 50);

-- Inserindo dados na tb_eletrocentro
INSERT INTO tb_eletrocentro VALUES (1, tp_localizacao(12.9714, 77.5946), (SELECT REF(me) FROM tb_modeloEletrocentro me WHERE me.modelo = 'ModeloX'), (SELECT REF(sc) FROM tb_seColetora sc WHERE sc.id = 1));

-- Inserindo dados na tb_instalacao
INSERT INTO tb_instalacao VALUES (1, tp_localizacao(12.9714, 77.5946), (SELECT REF(ec) FROM tb_eletrocentro ec WHERE ec.id_eletrocentro = 1));

-- Inserindo dados na tb_medidorPontoDeConexao
INSERT INTO tb_medidorinstalacao VALUES (1, 456, 2, (SELECT REF(i) FROM tb_instalacao i WHERE i.id_instalacao = 1));

-- Inserindo dados na tb_conjunto
INSERT INTO tb_conjunto VALUES (1, (SELECT REF(mi) FROM tb_modeloinversor mi WHERE mi.modelo = 'ModeloInv1'), NULL, (SELECT REF(i) FROM tb_instalacao i WHERE i.id_instalacao = 1));
