# 📚 Quast - Sistema de Gestão de Estudos com IA

## 📋 Sobre o Projeto

**Quast** é um sistema desktop desenvolvido em Delphi para auxiliar estudantes no gerenciamento e resolução de questões de provas e concursos. O sistema combina organização de conteúdo com inteligência artificial para proporcionar uma experiência de aprendizado personalizada e eficiente.

### 🎯 Objetivo
Fornecer uma ferramenta completa para estudantes que desejam:
- Organizar suas questões de estudo
- Armazenar provas anteriores
- Receber auxílio inteligente na resolução de problemas
- Acompanhar seu progresso de aprendizado

## 🚀 Tecnologias Utilizadas

- **Linguagem:** Delphi (Object Pascal)
- **Banco de Dados:** SQLite
- **Componentes:** FireDAC para acesso a dados
- **Interface:** VCL (Visual Component Library)
- **Arquitetura:** Sistema de Migrations para versionamento do banco

## ✨ Funcionalidades Atuais

### Sistema de Migrations
- ✅ Gerenciamento automático de versões do banco de dados
- ✅ Criação automática de estrutura inicial
- ✅ Sistema de backup antes de atualizações
- ✅ Validação de integridade via checksum
- ✅ Log detalhado de todas as operações

### Estrutura Base
- ✅ Conexão robusta com SQLite
- ✅ Tabelas de usuários e configurações
- ✅ Sistema de auditoria integrado
- ✅ Interface principal com menu de navegação
- ✅ Estrutura completa de provas e questões
- ✅ Sistema de resolução com rastreamento de IA

## 🗺️ Roadmap - Próximas Implementações

### Fase 1: Gestão de Conteúdo 📝
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

### Fase 2: Integração com IA 🤖
- [ ] **Assistente Inteligente de Resolução**
  - Análise passo a passo de questões
  - Dicas contextualizadas
  - Explicações adaptativas ao nível do estudante

- [ ] **Geração de Conteúdo**
  - Questões similares para prática
  - Resumos automáticos de matérias
  - Flashcards inteligentes

### Fase 3: Análise e Progresso 📊
- [ ] **Dashboard de Desempenho**
  - Taxa de acertos por matéria
  - Evolução temporal
  - Identificação de pontos fracos

- [ ] **Plano de Estudos Personalizado**
  - Recomendações baseadas em desempenho
  - Cronograma adaptativo
  - Metas e objetivos

### Fase 4: Recursos Avançados 🎓
- [ ] **Simulados Personalizados**
  - Criação automática baseada em weakpoints
  - Cronômetro e condições reais de prova
  - Correção instantânea com explicações

- [ ] **Modo Colaborativo**
  - Compartilhamento de questões
  - Grupos de estudo
  - Ranking e gamificação

## 🏗️ Arquitetura do Sistema

```
D:\R2\
├── Quast.dpr                 # Projeto principal
├── UFrmPrinc.pas             # Form principal
├── Migrations/               # Sistema de versionamento DB
│   ├── SQL/                  # Scripts de migrations
│   └── UMigrationManager.pas # Gerenciador de migrations
├── Cadastros/                # (Futuros) Forms de cadastro
├── Diversos/                 # Forms auxiliares
│   └── UFrmSobre.pas        # Tela sobre
└── Win32/Win64/             # Builds compiladas
```

## 💾 Estrutura do Banco de Dados

### Diagrama de Relacionamentos

```
┌─────────────────┐
│ schema_migrations│  (Controle de versões)
└─────────────────┘

┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│  usuarios    │      │   configuracoes │      │  auditoria   │
└──────────────┘      └─────────────────┘      └──────────────┘

┌──────────────┐      ┌─────────────────┐
│   bancas     │      │ areas_conhecimento│
└──────┬───────┘      └────────┬────────┘
       │                       │
       │    ┌─────────────┐    │
       └───>│   provas    │<───┘
            └──────┬──────┘
                   │ 1
                   │
                   │ N
            ┌──────▼──────┐
            │  questoes   │
            └──────┬──────┘
                   │ 1
                   │
                   │ N
            ┌──────▼──────┐      ┌─────────────────┐
            │ resolucoes  │─────>│ ia_interacoes   │
            └─────────────┘      └─────────────────┘

┌──────────────┐      ┌──────────────┐
│ disciplinas  │      │     tags     │
└──────────────┘      └──────────────┘
       │                     │
       └─────────┬───────────┘
                 │ N:N
         ┌───────▼────────┐
         │ questoes_tags  │
         └────────────────┘
```

### 📊 Tabelas do Sistema

#### **Gestão de Usuários e Sistema**
- `usuarios` - Cadastro de usuários do sistema
- `configuracoes` - Configurações globais
- `auditoria` - Log de ações para rastreabilidade
- `schema_migrations` - Controle automático de versões do banco

#### **Cadastro de Provas**
- `bancas` - Organizadoras de concursos (CESPE, FCC, FGV, etc.)
  - 9 bancas pré-cadastradas
- `areas_conhecimento` - Grandes áreas (Matemática, Português, etc.)
  - 17 áreas pré-cadastradas com cores
- `provas` - Armazenamento de provas completas
  - Relacionamento: `banca_id` → `bancas`
  - Relacionamento: `area_conhecimento_id` → `areas_conhecimento`
  - Campos: título, ano, tipo, nível, duração, dificuldade
  - Suporte para anexar PDF da prova

#### **Banco de Questões**
- `disciplinas` - Subdivisões das áreas (ex: Álgebra, Geometria)
  - 21 disciplinas pré-cadastradas
  - Relacionamento: `area_conhecimento_id` → `areas_conhecimento`
- `tags` - Sistema flexível de categorização
  - Tags: Fácil, Médio, Difícil, Importante, Revisar, etc.
- `questoes` - **Questões de provas (1:N com provas)**
  - Relacionamento: `prova_id` → `provas` (CASCADE)
  - Relacionamento: `disciplina_id` → `disciplinas`
  - Campos: enunciado, alternativas (A-E), gabarito, tipo
  - Suporte para: imagens, explicações, vídeos de resolução
  - Dificuldade estimada (1-5)
- `questoes_tags` - Relacionamento N:N entre questões e tags

#### **Sistema de Resolução e IA** 🤖
- `resolucoes` - Histórico de tentativas do usuário
  - Relacionamento: `questao_id` → `questoes` (CASCADE)
  - Relacionamento: `usuario_id` → `usuarios`
  - Campos: resposta, acertou, tempo gasto
  - Controle de uso de ajuda IA (sim/não, nível de ajuda)
- `ia_interacoes` - **Registro de interações com IA**
  - Relacionamento: `resolucao_id` → `resolucoes` (CASCADE)
  - Relacionamento: `questao_id` → `questoes` (CASCADE)
  - Tipos de ajuda: Dica, Conceito, Passo a Passo, Explicação
  - Armazena: prompt do usuário, resposta da IA
  - Feedback: se a ajuda foi útil

#### **Views de Análise** 📈
- `v_provas_completas` - Listagem de provas com todos os relacionamentos
- `v_questoes_estatisticas` - Estatísticas por questão
  - Total de tentativas, percentual de acerto, tempo médio
  - Quantas vezes usou IA
- `v_desempenho_disciplina` - Performance por disciplina
  - Questões respondidas vs disponíveis
  - Percentual de acerto, tempo médio
- `v_questoes_revisar` - Questões erradas ou não resolvidas
  - Prioriza questões com mais erros
- `v_usuarios_ativos` - Usuários ativos do sistema

### 🔑 Características Técnicas

- **Integridade Referencial:** FKs com CASCADE onde apropriado
- **Constraints:** CHECK para validar valores (dificuldade 1-5, gabarito A-E, etc.)
- **Índices:** Criados automaticamente para otimizar consultas
- **Timestamps:** Todas tabelas possuem `criado_em` e `atualizado_em`
- **Soft Delete:** Campo `ativo` para manter histórico
- **Migrations:** Sistema automático de versionamento incremental

### 📦 Dados Pré-Cadastrados

O sistema já vem com dados iniciais para facilitar o uso:
- ✅ 9 bancas de concursos e vestibulares
- ✅ 17 áreas de conhecimento com cores
- ✅ 21 disciplinas específicas
- ✅ 13 tags de categorização
- ✅ Configurações padrão do sistema

### 📜 Migrations Disponíveis

O sistema possui 3 migrations que configuram toda a estrutura:

1. **V001_initial_schema.sql** - Estrutura base
   - Tabelas de usuários e configurações
   - Sistema de auditoria
   - Views de usuários ativos

2. **V002_create_provas_table.sql** - Sistema de provas
   - Tabelas de bancas e áreas de conhecimento
   - Tabela principal de provas
   - Views de provas completas
   - 9 bancas e 17 áreas pré-cadastradas

3. **V003_create_questoes_table.sql** - Sistema de questões
   - Tabelas de disciplinas, tags e questões
   - Sistema de resoluções e interações com IA
   - Views de estatísticas e desempenho
   - 21 disciplinas e 13 tags pré-cadastradas

## 🔧 Instalação e Configuração

### Pré-requisitos
- Delphi RAD Studio (10.3 ou superior)
- Windows 7/8/10/11
- 100MB de espaço em disco

### Como Compilar

1. **Clone o repositório**
   ```bash
   git clone git@github.com:psielta/QUAST.git
   cd Quast
   ```

2. **⚠️ IMPORTANTE: Copie as migrations antes de compilar**

   Execute o script `copy_migrations.bat` para copiar os arquivos SQL para os diretórios de build:
   ```batch
   copy_migrations.bat
   ```

   Este script copia automaticamente as migrations para:
   - `Win32\Debug\Migrations\SQL\`
   - `Win32\Release\Migrations\SQL\`
   - `Win64\Debug\Migrations\SQL\`
   - `Win64\Release\Migrations\SQL\`

   **📝 Nota:** Sempre que criar uma nova migration (arquivos `.sql`), execute este script novamente antes de compilar/executar!

3. **Compile o projeto**
   - Abra `Quast.dpr` no Delphi
   - Pressione F9 ou Build → Build Quast
   - O executável será gerado em `Win32\Debug\` ou `Win64\Debug\`

### Primeira Execução
- O banco de dados será criado automaticamente em `quast_database.db`
- As migrations serão detectadas e aplicadas automaticamente
- A estrutura completa do banco será configurada
- Verifique o arquivo `migrations.log` para detalhes da execução

### Adicionando Novas Migrations

Quando criar novas migrations SQL:

1. Adicione o arquivo em `Migrations\SQL\` seguindo o padrão `VXXX_descricao.sql`
2. **Execute `copy_migrations.bat`** para copiar para os diretórios de build
3. Compile e execute normalmente
4. A nova migration será aplicada automaticamente

## Contribuindo

Projeto de portfolio pessoal, mas feedbacks sao bem-vindos! Abra uma issue ou envie um PR.

## Licenca

Projeto sob licenca MIT.

## Autor

Mateus Salgueiro  
- GitHub: [@psielta](https://github.com/psielta)  
- LinkedIn: [Mateus Salgueiro](https://www.linkedin.com/in/mateus-salgueiro-525717205/)

---

Desenvolvido como parte do meu portfolio de desenvolvimento desktop Delphi.

## Autentica\u00e7\u00e3o e Usu\u00e1rios

- Login por email + senha usando hash SHA-256 armazenado em `usuarios.senha_hash`.
- Auditoria de login (sucesso/falha) registrada na tabela `auditoria`.
- Usu\u00e1rio padr\u00e3o inicial criado automaticamente quando a tabela `usuarios` est\u00e1 vazia:
  - Email: `admin@quast.local`
  - Senha: `admin123`
  - Recomenda\u00e7\u00e3o: trocar a senha no primeiro acesso.
- Cadastro de usu\u00e1rios (menu Cadastros \u2192 Usu\u00e1rios):
  - Listar, criar, editar (troca opcional de senha) e excluir.
  - Campo `ativo` controla permiss\u00e3o de login.
- Fluxo de inicializa\u00e7\u00e3o:
  - App exibe tela de login antes do form principal.
  - Migrations s\u00e3o executadas e o admin padr\u00e3o \u00e9 garantido antes do login.
