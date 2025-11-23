# Quast - Sistema de Gestão de Estudos com IA

## Sobre o Projeto

**Quast** é um sistema desktop desenvolvido em Delphi para auxiliar estudantes no
gerenciamento e na resolução de questões de provas e concursos. O sistema combina
organização de conteúdo com inteligência artificial para proporcionar uma experiência
de aprendizado personalizada e eficiente.

### Objetivo

Fornecer uma ferramenta completa para estudantes que desejam:
- Organizar suas questões de estudo
- Armazenar provas anteriores
- Receber auxílio inteligente na resolução de problemas
- Acompanhar seu progresso de aprendizado

## Tecnologias Utilizadas

- **Linguagem:** Delphi (Object Pascal)
- **Banco de Dados:** SQLite
- **Acesso a Dados:** FireDAC
- **Interface:** VCL (Visual Component Library)
- **Arquitetura:** Sistema de migrations para versionamento do banco

## Funcionalidades Atuais

### Sistema de Migrations
- Gerenciamento automático de versões do banco de dados
- Criação automática da estrutura inicial
- Backup automático antes de aplicar migrations
- Validação de integridade via checksum
- Log detalhado de todas as operações

### Estrutura Base
- Conexão robusta com SQLite
- Tabelas de usuários e configurações
- Sistema de auditoria integrado
- Interface principal com menu de navegação
- Estrutura base de provas e questões
- Sistema de resolução com rastreamento de IA

### Autenticação e Usuários

- Login por **email + senha**, usando hash SHA-256 armazenado em `usuarios.senha_hash`
- Auditoria de login (sucesso/falha) registrada na tabela `auditoria`
- Usuário padrão inicial criado automaticamente quando a tabela `usuarios` está vazia:
  - Email: `admin@quast.local`
  - Senha: `admin123`
  - Recomenda-se trocar a senha no primeiro acesso
- Cadastro de usuários (menu **Cadastros → Usuários**):
  - Listar, criar, editar (troca opcional de senha) e excluir
  - Campo `ativo` controla permissão de login
- Fluxo de inicialização:
  - App exibe a tela de login antes do form principal
  - As migrations são executadas e o admin padrão é garantido antes do login

## Roadmap - Próximas Implementações

### Fase 1: Gestão de Conteúdo

- [x] **Estrutura de Banco de Dados Completa**
  - Tabelas de provas com bancas e áreas
  - Tabelas de questões com disciplinas e tags
  - Sistema de migrations implementado

- [ ] **Interface de Cadastro de Provas**
  - Formulário para adicionar/editar provas
  - Seleção de banca e área de conhecimento
  - Upload de PDF da prova

- [ ] **Interface de Cadastro de Questões**
  - Formulário para adicionar/editar questões
  - Vinculação automática com provas
  - Sistema de tags
  - Upload de imagens no enunciado

### Fase 2: Integração com IA

- [ ] **Assistente Inteligente de Resolução**
  - Análise passo a passo de questões
  - Dicas contextualizadas
  - Explicações adaptativas ao nível do estudante

- [ ] **Geração de Conteúdo**
  - Questões similares para prática
  - Resumos automáticos de matérias
  - Flashcards inteligentes

### Fase 3: Análise e Progresso

- [ ] **Dashboard de Desempenho**
  - Taxa de acertos por matéria
  - Evolução temporal
  - Identificação de pontos fracos

- [ ] **Plano de Estudos Personalizado**
  - Recomendações baseadas em desempenho
  - Cronograma adaptativo
  - Metas e objetivos

### Fase 4: Recursos Avançados

- [ ] **Simulados Personalizados**
  - Geração automática baseada em pontos fracos
  - Cronômetro e simulação de condições reais de prova
  - Correção instantânea com explicações

- [ ] **Modo Colaborativo**
  - Compartilhamento de questões
  - Grupos de estudo
  - Ranking e gamificação

## Arquitetura do Sistema

Estrutura principal do projeto:

```text
D:\R2\
├── Quast.dpr                     # Projeto principal
├── UFrmPrinc.pas                 # Form principal
├── Migrations\                   # Sistema de versionamento do DB
│   ├── SQL\                      # Scripts de migrations
│   └── UMigrationManager.pas     # Gerenciador de migrations
├── Cadastros\                    # Forms de cadastro (bancas, áreas, usuários, etc.)
├── Diversos\                     # Forms auxiliares (Sobre, etc.)
└── Win32/Win64\                  # Builds compiladas
```

## Estrutura do Banco de Dados

### Visão Geral

O banco foi projetado para suportar:
- Gestão de usuários e configurações
- Cadastro de bancas, áreas, provas e questões
- Registro de resoluções e interações com IA
- Views para análise de desempenho

### Tabelas do Sistema

#### Gestão de Usuários e Sistema

- `usuarios`  
  - Armazena usuários do sistema (login)
  - Campos principais:
    - `nome`, `email` (único), `senha_hash`, `ativo`
    - `criado_em`, `atualizado_em`
- `configuracoes`  
  - Configurações globais do sistema
- `auditoria`  
  - Log de ações para rastreabilidade (inclui login/logout)
- `schema_migrations`  
  - Controle automático de versões do banco

#### Cadastro de Provas

- `bancas`  
  - Organizadoras de concursos (CESPE, FCC, FGV, etc.)
  - Contém dados pré-cadastrados
- `areas_conhecimento`  
  - Grandes áreas (Matemática, Português, etc.)
  - Inclui cor associada para visualização
- `provas`  
  - Provas completas
  - Relacionamentos:
    - `banca_id` → `bancas`
    - `area_conhecimento_id` → `areas_conhecimento`

#### Banco de Questões

- `disciplinas`  
  - Subdivisões das áreas (ex.: Álgebra, Geometria)
  - Relacionadas a `areas_conhecimento`
- `tags`  
  - Sistema flexível de categorização (Fácil, Médio, Difícil, Revisar, etc.)
- `questoes`  
  - Questões de provas
  - Relacionamentos:
    - `prova_id` → `provas`
    - `disciplina_id` → `disciplinas`
  - Campos:
    - Enunciado, alternativas (A–E), gabarito, tipo, dificuldade estimada (1–5)
    - Suporte a mídias (imagens, explicações, vídeos de resolução) na modelagem
- `questoes_tags`  
  - Relacionamento N:N entre questões e tags

#### Sistema de Resolução e IA

- `resolucoes`  
  - Histórico de tentativas do usuário
  - Relacionamentos:
    - `questao_id` → `questoes`
    - `usuario_id` → `usuarios`
  - Campos: resposta, se acertou, tempo gasto, uso de ajuda de IA
- `ia_interacoes`  
  - Registro de interações com IA
  - Relacionamentos:
    - `resolucao_id` → `resolucoes`
    - `questao_id` → `questoes`
  - Campos: tipo de ajuda (dica, conceito, passo a passo, explicação), prompt e resposta da IA, feedback do usuário

#### Views de Análise

- `v_provas_completas` – Listagem de provas com todos os relacionamentos
- `v_questoes_estatisticas` – Estatísticas por questão  
  (total de tentativas, percentual de acerto, tempo médio, uso de IA)
- `v_desempenho_disciplina` – Performance por disciplina
- `v_questoes_revisar` – Questões erradas ou não resolvidas
- `v_usuarios_ativos` – Usuários ativos do sistema

## Características Técnicas

- **Integridade Referencial:** FKs com CASCADE onde apropriado
- **Constraints:** CHECK para validar valores (dificuldade 1–5, gabarito A–E, etc.)
- **Índices:** Criados para otimizar consultas em campos críticos
- **Timestamps:** Praticamente todas as tabelas possuem `criado_em` e `atualizado_em`
- **Soft Delete:** Campo `ativo` em diversas tabelas (incluindo `usuarios`)
- **Migrations:** Sistema automático de versionamento incremental

## Dados Pré-Cadastrados

O sistema já vem com dados iniciais para facilitar o uso:
- Bancas de concursos e vestibulares
- Áreas de conhecimento com cores
- Disciplinas específicas
- Tags de categorização
- Configurações padrão do sistema

## Migrations Disponíveis

Atualmente o projeto conta com 3 migrations principais:

1. **V001_initial_schema.sql** – Estrutura base
   - Tabelas de usuários, configurações e auditoria
   - View de usuários ativos

2. **V002_create_provas_table.sql** – Sistema de provas
   - Tabelas de bancas e áreas de conhecimento
   - Tabela principal de provas
   - Views de provas completas
   - Dados pré-cadastrados de bancas e áreas

3. **V003_create_questoes_table.sql** – Sistema de questões
   - Tabelas de disciplinas, tags e questões
   - Sistema de resoluções e interações com IA
   - Views de estatísticas e desempenho
   - Dados pré-cadastrados de disciplinas e tags

## Instalação e Configuração

### Pré-requisitos

- Delphi RAD Studio (10.3 ou superior)
- Windows 7/8/10/11
- ~100 MB de espaço em disco

### Como Compilar

1. **Clone o repositório**

   ```bash
   git clone git@github.com:psielta/QUAST.git
   cd Quast
   ```

2. **IMPORTANTE: Copie as migrations antes de compilar**

   Execute o script `copy_migrations.bat` para copiar os arquivos SQL para os diretórios
   de build:

   ```batch
   copy_migrations.bat
   ```

   Este script copia automaticamente as migrations para:
   - `Win32\Debug\Migrations\SQL\`
   - `Win32\Release\Migrations\SQL\`
   - `Win64\Debug\Migrations\SQL\`
   - `Win64\Release\Migrations\SQL\`

   Sempre que criar uma nova migration (`.sql`), execute este script novamente.

3. **Compile o projeto**

   - Abra `Quast.dpr` no Delphi
   - Pressione F9 ou use o menu **Build → Build Quast**
   - O executável será gerado em `Win32\Debug\` ou `Win64\Debug\`

### Primeira Execução

- O banco de dados `quast_database.db` será criado automaticamente na pasta do executável
- As migrations serão detectadas e aplicadas automaticamente
- Um usuário **admin** padrão será criado se não houver nenhum usuário:
  - Email: `admin@quast.local`
  - Senha: `admin123`
- Na primeira inicialização é exibida a tela de login:
  - Após autenticação, o formulário principal é aberto
  - Recomenda-se alterar a senha do admin pelo cadastro de usuários

### Adicionando Novas Migrations

1. Adicione o arquivo em `Migrations\SQL\` seguindo o padrão `VXXX_descricao.sql`
2. Execute `copy_migrations.bat` para copiar para os diretórios de build
3. Compile e execute normalmente
4. A nova migration será aplicada automaticamente na próxima execução

## Contribuindo

Projeto de portfólio pessoal, mas feedbacks são bem-vindos!  
Abra uma issue ou envie um PR.

## Licença

Projeto sob licença MIT.

## Autor

Mateus Salgueiro  
- GitHub: [@psielta](https://github.com/psielta)  
- LinkedIn: [Mateus Salgueiro](https://www.linkedin.com/in/mateus-salgueiro-525717205/)

---

Desenvolvido como parte do meu portfólio de desenvolvimento desktop Delphi.

