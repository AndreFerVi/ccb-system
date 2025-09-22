
-- Converter para sintaxe PostgreSQL
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    adm BOOLEAN DEFAULT FALSE,
    uf VARCHAR(2) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    cargo_funcao VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE equipamentos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    mac_address VARCHAR(17) NOT NULL UNIQUE,
    tipo_equipamento VARCHAR(50) DEFAULT 'Computador',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarios_login (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados
INSERT INTO usuarios (id, nome_completo, data_nascimento, cpf, adm, uf, departamento, cargo_funcao, created_at, updated_at) VALUES
(1, 'João Silva Santos', '1985-03-15', '123.456.789-01', TRUE, 'SP', 'TI', 'Gerente de TI', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(2, 'Maria Oliveira Costa', '1990-07-22', '987.654.321-02', FALSE, 'RJ', 'RH', 'Analista de RH', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(3, 'Pedro Souza Lima', '1988-12-10', '456.789.123-03', FALSE, 'MG', 'Vendas', 'Vendedor', '2025-09-19 23:41:10', '2025-09-19 23:41:10');

INSERT INTO equipamentos (id, usuario_id, mac_address, tipo_equipamento, created_at, updated_at) VALUES
(1, 1, '00:1B:44:11:3A:B7', 'Desktop', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(2, 1, '00:1B:44:11:3A:B8', 'Notebook', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(3, 2, '00:1B:44:11:3A:C1', 'Desktop', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(4, 3, '00:1B:44:11:3A:D2', 'Notebook', '2025-09-19 23:41:10', '2025-09-19 23:41:10'),
(5, 3, '00:1B:44:11:3A:D3', 'Tablet', '2025-09-19 23:41:10', '2025-09-19 23:41:10');

INSERT INTO usuarios_login (id, username, password_hash, created_at, updated_at) VALUES
(2, 'admin', '$2b$10$yS7g0cZAtq6Y/v5haWztSusOrec1fpXoNJ0nLDHFrr.zyq6ogvG/e', '2025-09-19 23:49:27', '2025-09-20 00:01:21');

-- Criar índices
CREATE INDEX idx_usuario ON equipamentos(usuario_id);
CREATE INDEX idx_mac ON equipamentos(mac_address);
CREATE INDEX idx_cpf ON usuarios(cpf);
CREATE INDEX idx_departamento ON usuarios(departamento);
CREATE INDEX idx_cargo ON usuarios(cargo_funcao);

-- Criar view
CREATE OR REPLACE VIEW usuarios_com_equipamentos AS
SELECT
    u.id,
    u.nome_completo,
    u.data_nascimento,
    u.cpf,
    u.adm,
    u.uf,
    u.departamento,
    u.cargo_funcao,
    COUNT(e.id) AS total_equipamentos,
    STRING_AGG(e.mac_address, ', ') AS mac_addresses
FROM usuarios u
LEFT JOIN equipamentos e ON u.id = e.usuario_id
GROUP BY u.id;

-- Criar função e trigger para limite de equipamentos
CREATE OR REPLACE FUNCTION check_max_equipamentos()
RETURNS TRIGGER AS $$
DECLARE
    equip_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO equip_count
    FROM equipamentos
    WHERE usuario_id = NEW.usuario_id;

    IF equip_count >= 3 THEN
        RAISE EXCEPTION 'Máximo de 3 equipamentos por usuário permitido';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_max_equipamentos_trigger
    BEFORE INSERT ON equipamentos
    FOR EACH ROW
    EXECUTE FUNCTION check_max_equipamentos();

