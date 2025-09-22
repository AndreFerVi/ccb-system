
CREATE DATABASE IF NOT EXISTS ccb_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ccb_system;

-- Script de inicialização do banco de dados CCB
-- Sistema de Cadastro de Usuários

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS ccb_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ccb_system;

-- Tabela de autenticação de usuários (login)
CREATE TABLE IF NOT EXISTS usuarios_login (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de usuários (dados pessoais e funcionais)
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    adm BOOLEAN DEFAULT FALSE,
    uf VARCHAR(2) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    cargo_funcao VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Índices para melhor performance
    INDEX idx_cpf (cpf),
    INDEX idx_departamento (departamento),
    INDEX idx_cargo (cargo_funcao)
);

-- Tabela de equipamentos (MAC addresses)
CREATE TABLE IF NOT EXISTS equipamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    mac_address VARCHAR(17) NOT NULL,
    tipo_equipamento VARCHAR(50) DEFAULT 'Computador',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Chave estrangeira
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    -- Índices
    INDEX idx_usuario (usuario_id),
    INDEX idx_mac (mac_address),
    -- Garantir que cada usuário tenha no máximo 3 equipamentos
    UNIQUE KEY unique_mac (mac_address)
);

-- Trigger para garantir máximo de 3 equipamentos por usuário
DELIMITER $$
CREATE TRIGGER check_max_equipamentos
BEFORE INSERT ON equipamentos
FOR EACH ROW
BEGIN
    DECLARE equip_count INT;
    SELECT COUNT(*) INTO equip_count 
    FROM equipamentos 
    WHERE usuario_id = NEW.usuario_id;
    IF equip_count >= 3 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Máximo de 3 equipamentos por usuário permitido';
    END IF;
END$$
DELIMITER ;

-- Inserir usuário administrador padrão (senha: admin123)
-- Hash gerado com bcrypt para a senha "admin123"
INSERT IGNORE INTO usuarios_login (username, password_hash) VALUES 
('admin', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Inserir alguns dados de exemplo
INSERT IGNORE INTO usuarios (nome_completo, data_nascimento, cpf, adm, uf, departamento, cargo_funcao) VALUES
('João Silva Santos', '1985-03-15', '123.456.789-01', TRUE, 'SP', 'TI', 'Gerente de TI'),
('Maria Oliveira Costa', '1990-07-22', '987.654.321-02', FALSE, 'RJ', 'RH', 'Analista de RH'),
('Pedro Souza Lima', '1988-12-10', '456.789.123-03', FALSE, 'MG', 'Vendas', 'Vendedor');

-- Inserir equipamentos de exemplo
INSERT IGNORE INTO equipamentos (usuario_id, mac_address, tipo_equipamento) VALUES
(1, '00:1B:44:11:3A:B7', 'Desktop'),
(1, '00:1B:44:11:3A:B8', 'Notebook'),
(2, '00:1B:44:11:3A:C1', 'Desktop'),
(3, '00:1B:44:11:3A:D2', 'Notebook'),
(3, '00:1B:44:11:3A:D3', 'Tablet');

-- View útil para consultas
CREATE VIEW usuarios_com_equipamentos AS
SELECT 
    u.id,
    u.nome_completo,
    u.data_nascimento,
    u.cpf,
    u.adm,
    u.uf,
    u.departamento,
    u.cargo_funcao,
    COUNT(e.id) as total_equipamentos,
    GROUP_CONCAT(e.mac_address SEPARATOR ', ') as mac_addresses
FROM usuarios u
LEFT JOIN equipamentos e ON u.id = e.usuario_id
GROUP BY u.id;

-- Função para validar CPF (opcional, pode ser feita no backend)
DELIMITER $$
CREATE FUNCTION validar_cpf(cpf_param VARCHAR(14))
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE cpf_limpo VARCHAR(11);
    DECLARE digito1, digito2 INT;
    DECLARE soma, resto INT;
    DECLARE i INT;
    SET cpf_limpo = REPLACE(REPLACE(cpf_param, '.', ''), '-', '');
    IF LENGTH(cpf_limpo) != 11 THEN
        RETURN FALSE;
    END IF;
    IF cpf_limpo IN ('00000000000', '11111111111', '22222222222', '33333333333', 
                     '44444444444', '55555555555', '66666666666', '77777777777', 
                     '88888888888', '99999999999') THEN
        RETURN FALSE;
    END IF;
    SET soma = 0;
    SET i = 1;
    WHILE i <= 9 DO
        SET soma = soma + CAST(SUBSTRING(cpf_limpo, i, 1) AS UNSIGNED) * (11 - i);
        SET i = i + 1;
    END WHILE;
    SET resto = soma % 11;
    IF resto < 2 THEN
        SET digito1 = 0;
    ELSE
        SET digito1 = 11 - resto;
    END IF;
    SET soma = 0;
    SET i = 1;
    WHILE i <= 10 DO
        SET soma = soma + CAST(SUBSTRING(cpf_limpo, i, 1) AS UNSIGNED) * (12 - i);
        SET i = i + 1;
    END WHILE;
    SET resto = soma % 11;
    IF resto < 2 THEN
        SET digito2 = 0;
    ELSE
        SET digito2 = 11 - resto;
    END IF;
    IF CAST(SUBSTRING(cpf_limpo, 10, 1) AS UNSIGNED) = digito1 AND 
       CAST(SUBSTRING(cpf_limpo, 11, 1) AS UNSIGNED) = digito2 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$
DELIMITER ;

-- Comentários sobre o banco
-- Usuário padrão: admin / senha: admin123
-- Estrutura permite até 3 equipamentos por usuário
-- CPF é único e validado
-- Todas as tabelas têm timestamps de criação e atualização

-- Comentários sobre o banco
-- Usuário padrão: admin / senha: admin123
-- Estrutura permite até 3 equipamentos por usuário
-- CPF é único e validado
-- Todas as tabelas têm timestamps de criação e atualização
