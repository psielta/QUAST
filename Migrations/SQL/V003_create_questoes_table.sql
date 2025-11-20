-- Migration V003: Criar tabela de questões
-- Autor: Sistema de Migrations
-- Data: 2024
-- Descrição: Armazena questões de provas com relacionamento 1:N com provas

-- Tabela de disciplinas (mais específico que área de conhecimento)
CREATE TABLE IF NOT EXISTS disciplinas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    area_conhecimento_id INTEGER NOT NULL,
    nome TEXT NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_conhecimento_id) REFERENCES areas_conhecimento(id)
);

-- Inserir disciplinas por área
INSERT OR IGNORE INTO disciplinas (area_conhecimento_id, nome, descricao) VALUES
    -- Matemática (id 1)
    (1, 'Álgebra', 'Equações, funções, progressões'),
    (1, 'Geometria', 'Geometria plana e espacial'),
    (1, 'Trigonometria', 'Funções trigonométricas'),
    (1, 'Estatística', 'Probabilidade e análise de dados'),
    (1, 'Matemática Financeira', 'Juros, porcentagem, investimentos'),
    -- Português (id 2)
    (2, 'Gramática', 'Sintaxe, morfologia, ortografia'),
    (2, 'Interpretação de Texto', 'Compreensão e análise textual'),
    (2, 'Literatura', 'Movimentos literários e obras'),
    (2, 'Redação', 'Produção textual e argumentação'),
    -- Física (id 3)
    (3, 'Mecânica', 'Cinemática, dinâmica, estática'),
    (3, 'Termodinâmica', 'Calor e temperatura'),
    (3, 'Óptica', 'Luz e fenômenos ópticos'),
    (3, 'Eletricidade', 'Eletrostática e eletrodinâmica'),
    (3, 'Ondulatória', 'Ondas e som'),
    -- Química (id 4)
    (4, 'Química Geral', 'Propriedades da matéria'),
    (4, 'Química Orgânica', 'Compostos de carbono'),
    (4, 'Físico-Química', 'Termodinâmica química'),
    -- Biologia (id 5)
    (5, 'Citologia', 'Células e organelas'),
    (5, 'Genética', 'Hereditariedade e DNA'),
    (5, 'Ecologia', 'Meio ambiente e ecossistemas'),
    (5, 'Evolução', 'Teorias evolutivas');

-- Tabela de tags para categorização flexível
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    cor_hex TEXT DEFAULT '#95a5a6',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tags comuns
INSERT OR IGNORE INTO tags (nome, cor_hex) VALUES
    ('Fácil', '#2ecc71'),
    ('Médio', '#f39c12'),
    ('Difícil', '#e74c3c'),
    ('Muito Difícil', '#c0392b'),
    ('Importante', '#e67e22'),
    ('Revisar', '#9b59b6'),
    ('Dúvida', '#3498db'),
    ('Favorita', '#f1c40f'),
    ('Errei', '#e74c3c'),
    ('Acertei', '#2ecc71'),
    ('Cálculo', '#16a085'),
    ('Conceitual', '#8e44ad'),
    ('Contextualizada', '#2980b9');

-- Tabela principal de questões
CREATE TABLE IF NOT EXISTS questoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    prova_id INTEGER NOT NULL,
    numero_questao INTEGER,
    disciplina_id INTEGER,
    enunciado TEXT NOT NULL,
    alternativa_a TEXT,
    alternativa_b TEXT,
    alternativa_c TEXT,
    alternativa_d TEXT,
    alternativa_e TEXT,
    gabarito_oficial TEXT CHECK(gabarito_oficial IN ('A', 'B', 'C', 'D', 'E', 'Discursiva', NULL)),
    tipo_questao TEXT CHECK(tipo_questao IN ('Múltipla Escolha', 'Verdadeiro/Falso', 'Discursiva', 'Certo/Errado')) DEFAULT 'Múltipla Escolha',
    pontuacao DECIMAL(5,2),
    tempo_medio_minutos INTEGER,
    imagem_enunciado TEXT,
    explicacao_detalhada TEXT,
    video_resolucao_url TEXT,
    dificuldade_estimada INTEGER CHECK(dificuldade_estimada BETWEEN 1 AND 5),
    observacoes TEXT,
    ativo INTEGER DEFAULT 1,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prova_id) REFERENCES provas(id) ON DELETE CASCADE,
    FOREIGN KEY (disciplina_id) REFERENCES disciplinas(id)
);

-- Tabela de relacionamento questões x tags (N:N)
CREATE TABLE IF NOT EXISTS questoes_tags (
    questao_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (questao_id, tag_id),
    FOREIGN KEY (questao_id) REFERENCES questoes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Tabela de tentativas/resoluções do usuário
CREATE TABLE IF NOT EXISTS resolucoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    questao_id INTEGER NOT NULL,
    usuario_id INTEGER,
    resposta_usuario TEXT,
    acertou INTEGER CHECK(acertou IN (0, 1)),
    tempo_gasto_segundos INTEGER,
    usou_ajuda_ia INTEGER DEFAULT 0,
    nivel_ajuda TEXT CHECK(nivel_ajuda IN ('Nenhuma', 'Dica', 'Passo a Passo', 'Solução Completa')),
    notas_usuario TEXT,
    data_resolucao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (questao_id) REFERENCES questoes(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabela de interações com IA
CREATE TABLE IF NOT EXISTS ia_interacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    resolucao_id INTEGER NOT NULL,
    questao_id INTEGER NOT NULL,
    tipo_ajuda TEXT CHECK(tipo_ajuda IN ('Dica', 'Conceito', 'Passo a Passo', 'Explicação', 'Exemplo Similar')),
    prompt_usuario TEXT NOT NULL,
    resposta_ia TEXT NOT NULL,
    util INTEGER CHECK(util IN (0, 1)),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resolucao_id) REFERENCES resolucoes(id) ON DELETE CASCADE,
    FOREIGN KEY (questao_id) REFERENCES questoes(id) ON DELETE CASCADE
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_questoes_prova ON questoes(prova_id);
CREATE INDEX IF NOT EXISTS idx_questoes_disciplina ON questoes(disciplina_id);
CREATE INDEX IF NOT EXISTS idx_questoes_numero ON questoes(numero_questao);
CREATE INDEX IF NOT EXISTS idx_questoes_tipo ON questoes(tipo_questao);
CREATE INDEX IF NOT EXISTS idx_questoes_ativo ON questoes(ativo);

CREATE INDEX IF NOT EXISTS idx_resolucoes_questao ON resolucoes(questao_id);
CREATE INDEX IF NOT EXISTS idx_resolucoes_usuario ON resolucoes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_resolucoes_data ON resolucoes(data_resolucao DESC);
CREATE INDEX IF NOT EXISTS idx_resolucoes_acertou ON resolucoes(acertou);

CREATE INDEX IF NOT EXISTS idx_ia_interacoes_resolucao ON ia_interacoes(resolucao_id);
CREATE INDEX IF NOT EXISTS idx_ia_interacoes_questao ON ia_interacoes(questao_id);
CREATE INDEX IF NOT EXISTS idx_ia_interacoes_tipo ON ia_interacoes(tipo_ajuda);

-- View para estatísticas de questões
CREATE VIEW IF NOT EXISTS v_questoes_estatisticas AS
SELECT
    q.id,
    q.numero_questao,
    p.titulo AS prova_titulo,
    p.ano AS prova_ano,
    d.nome AS disciplina_nome,
    q.tipo_questao,
    q.dificuldade_estimada,
    COUNT(DISTINCT r.id) AS total_tentativas,
    SUM(CASE WHEN r.acertou = 1 THEN 1 ELSE 0 END) AS total_acertos,
    CASE
        WHEN COUNT(DISTINCT r.id) > 0 THEN
            ROUND(CAST(SUM(CASE WHEN r.acertou = 1 THEN 1 ELSE 0 END) AS REAL) / COUNT(DISTINCT r.id) * 100, 2)
        ELSE 0
    END AS percentual_acerto,
    AVG(r.tempo_gasto_segundos) AS tempo_medio_segundos,
    SUM(r.usou_ajuda_ia) AS vezes_usou_ia
FROM questoes q
LEFT JOIN provas p ON q.prova_id = p.id
LEFT JOIN disciplinas d ON q.disciplina_id = d.id
LEFT JOIN resolucoes r ON q.id = r.questao_id
WHERE q.ativo = 1
GROUP BY q.id;

-- View para desempenho do usuário por disciplina
CREATE VIEW IF NOT EXISTS v_desempenho_disciplina AS
SELECT
    d.id AS disciplina_id,
    d.nome AS disciplina_nome,
    a.nome AS area_nome,
    COUNT(DISTINCT q.id) AS total_questoes_disponiveis,
    COUNT(DISTINCT r.questao_id) AS questoes_respondidas,
    SUM(CASE WHEN r.acertou = 1 THEN 1 ELSE 0 END) AS total_acertos,
    CASE
        WHEN COUNT(DISTINCT r.questao_id) > 0 THEN
            ROUND(CAST(SUM(CASE WHEN r.acertou = 1 THEN 1 ELSE 0 END) AS REAL) / COUNT(DISTINCT r.questao_id) * 100, 2)
        ELSE 0
    END AS percentual_acerto,
    AVG(r.tempo_gasto_segundos) AS tempo_medio_segundos
FROM disciplinas d
INNER JOIN areas_conhecimento a ON d.area_conhecimento_id = a.id
LEFT JOIN questoes q ON d.id = q.disciplina_id AND q.ativo = 1
LEFT JOIN resolucoes r ON q.id = r.questao_id
GROUP BY d.id, d.nome, a.nome;

-- View para questões que precisam de revisão (erradas ou não resolvidas)
CREATE VIEW IF NOT EXISTS v_questoes_revisar AS
SELECT
    q.id,
    q.numero_questao,
    q.enunciado,
    p.titulo AS prova_titulo,
    p.ano AS prova_ano,
    d.nome AS disciplina_nome,
    q.dificuldade_estimada,
    COUNT(r.id) AS tentativas,
    SUM(CASE WHEN r.acertou = 0 THEN 1 ELSE 0 END) AS erros,
    MAX(r.data_resolucao) AS ultima_tentativa
FROM questoes q
INNER JOIN provas p ON q.prova_id = p.id
LEFT JOIN disciplinas d ON q.disciplina_id = d.id
LEFT JOIN resolucoes r ON q.id = r.questao_id
WHERE q.ativo = 1
  AND (r.id IS NULL OR r.acertou = 0)
GROUP BY q.id
ORDER BY erros DESC, ultima_tentativa DESC;

-- Atualizar configuração de versão
UPDATE configuracoes
SET valor = '1.3.0', atualizado_em = CURRENT_TIMESTAMP
WHERE chave = 'versao_sistema';