-- Migration V001: Schema inicial do sistema
-- Autor: Sistema de Migrations
-- Data: 2024

-- Tabela de exemplo para usuários
CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    senha_hash TEXT NOT NULL,
    ativo INTEGER DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para melhorar performance de busca por email
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);

-- Tabela de configurações do sistema
CREATE TABLE IF NOT EXISTS configuracoes (
    chave TEXT PRIMARY KEY,
    valor TEXT,
    descricao TEXT,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insere configurações padrão
INSERT OR IGNORE INTO configuracoes (chave, valor, descricao)
VALUES
    ('versao_sistema', '1.0.0', 'Versão atual do sistema'),
    ('nome_empresa', 'Minha Empresa', 'Nome da empresa'),
    ('email_suporte', 'suporte@exemplo.com', 'Email de suporte');

-- Tabela de logs de auditoria
CREATE TABLE IF NOT EXISTS auditoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER,
    acao TEXT NOT NULL,
    tabela TEXT,
    registro_id INTEGER,
    dados_anteriores TEXT,
    dados_novos TEXT,
    ip TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Índice para melhorar performance de busca por data
CREATE INDEX IF NOT EXISTS idx_auditoria_data ON auditoria(data_hora DESC);

-- View para facilitar consultas de usuários ativos
CREATE VIEW IF NOT EXISTS v_usuarios_ativos AS
SELECT
    id,
    nome,
    email,
    criado_em,
    atualizado_em
FROM usuarios
WHERE ativo = 1;