-- Migration V002: Criar tabela de provas
-- Autor: Sistema de Migrations
-- Data: 2024
-- Descrição: Armazena informações sobre provas e exames

-- Tabela de bancas/instituições
CREATE TABLE IF NOT EXISTS bancas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    sigla TEXT,
    descricao TEXT,
    site TEXT,
    ativo INTEGER DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir bancas comuns
INSERT OR IGNORE INTO bancas (nome, sigla, descricao) VALUES
    ('Fundação Cesgranrio', 'CESGRANRIO', 'Banca organizadora de concursos públicos'),
    ('Fundação Carlos Chagas', 'FCC', 'Banca organizadora de concursos públicos'),
    ('Centro de Seleção e Promoção de Eventos', 'CESPE/CEBRASPE', 'Banca da UnB'),
    ('Fundação Getúlio Vargas', 'FGV', 'Banca organizadora de concursos'),
    ('Instituto Brasileiro de Formação e Capacitação', 'IBFC', 'Banca organizadora'),
    ('Fundação para o Vestibular da UNESP', 'VUNESP', 'Banca do estado de SP'),
    ('ENEM', 'ENEM', 'Exame Nacional do Ensino Médio'),
    ('Universidade Federal do Paraná', 'UFPR', 'Banca universitária'),
    ('Outra', 'OUTRA', 'Outras bancas ou provas personalizadas');

-- Tabela de áreas de conhecimento
CREATE TABLE IF NOT EXISTS areas_conhecimento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    descricao TEXT,
    cor_hex TEXT DEFAULT '#3498db',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir áreas comuns
INSERT OR IGNORE INTO areas_conhecimento (nome, descricao, cor_hex) VALUES
    ('Matemática', 'Matemática e suas tecnologias', '#e74c3c'),
    ('Português', 'Língua Portuguesa e Literatura', '#3498db'),
    ('Física', 'Física e suas aplicações', '#9b59b6'),
    ('Química', 'Química e suas tecnologias', '#1abc9c'),
    ('Biologia', 'Biologia e Ciências da Natureza', '#2ecc71'),
    ('História', 'História Geral e do Brasil', '#f39c12'),
    ('Geografia', 'Geografia e Geopolítica', '#e67e22'),
    ('Filosofia', 'Filosofia e Ética', '#34495e'),
    ('Sociologia', 'Sociologia e Sociedade', '#95a5a6'),
    ('Inglês', 'Língua Inglesa', '#16a085'),
    ('Espanhol', 'Língua Espanhola', '#d35400'),
    ('Redação', 'Produção Textual', '#c0392b'),
    ('Informática', 'Tecnologia da Informação', '#2c3e50'),
    ('Direito', 'Direito e Legislação', '#8e44ad'),
    ('Administração', 'Administração Pública e Privada', '#27ae60'),
    ('Economia', 'Economia e Finanças', '#16a085'),
    ('Atualidades', 'Atualidades e Conhecimentos Gerais', '#f1c40f');

-- Tabela principal de provas
CREATE TABLE IF NOT EXISTS provas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT NOT NULL,
    banca_id INTEGER,
    ano INTEGER NOT NULL,
    area_conhecimento_id INTEGER,
    nivel TEXT CHECK(nivel IN ('Fundamental', 'Médio', 'Superior', 'Pós-Graduação', 'Concurso', 'Outro')),
    tipo TEXT CHECK(tipo IN ('ENEM', 'Vestibular', 'Concurso', 'Simulado', 'Prova Escolar', 'Outro')),
    cargo TEXT,
    duracao_minutos INTEGER,
    data_aplicacao DATE,
    numero_questoes INTEGER DEFAULT 0,
    observacoes TEXT,
    dificuldade INTEGER CHECK(dificuldade BETWEEN 1 AND 5),
    arquivo_pdf TEXT,
    ativo INTEGER DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (banca_id) REFERENCES bancas(id),
    FOREIGN KEY (area_conhecimento_id) REFERENCES areas_conhecimento(id)
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_provas_banca ON provas(banca_id);
CREATE INDEX IF NOT EXISTS idx_provas_ano ON provas(ano DESC);
CREATE INDEX IF NOT EXISTS idx_provas_area ON provas(area_conhecimento_id);
CREATE INDEX IF NOT EXISTS idx_provas_tipo ON provas(tipo);
CREATE INDEX IF NOT EXISTS idx_provas_nivel ON provas(nivel);
CREATE INDEX IF NOT EXISTS idx_provas_ativo ON provas(ativo);

-- View para facilitar consultas de provas com informações completas
CREATE VIEW IF NOT EXISTS v_provas_completas AS
SELECT
    p.id,
    p.titulo,
    b.nome AS banca_nome,
    b.sigla AS banca_sigla,
    p.ano,
    a.nome AS area_nome,
    a.cor_hex AS area_cor,
    p.nivel,
    p.tipo,
    p.cargo,
    p.duracao_minutos,
    p.data_aplicacao,
    p.numero_questoes,
    p.dificuldade,
    p.criado_em
FROM provas p
LEFT JOIN bancas b ON p.banca_id = b.id
LEFT JOIN areas_conhecimento a ON p.area_conhecimento_id = a.id
WHERE p.ativo = 1
ORDER BY p.ano DESC, p.titulo;

-- Atualizar configuração de versão
UPDATE configuracoes
SET valor = '1.2.0', atualizado_em = CURRENT_TIMESTAMP
WHERE chave = 'versao_sistema';