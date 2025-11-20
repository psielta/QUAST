# Sistema de Migrations SQLite

## ⚠️ IMPORTANTE - Workflow de Desenvolvimento

**Antes de compilar/executar o projeto, sempre execute:**
```batch
D:\R2\copy_migrations.bat
```

Este script copia os arquivos `.sql` desta pasta para os diretórios de build (`Win32/Win64, Debug/Release`).

## Visão Geral
Sistema robusto de migrations para gerenciar a evolução do banco de dados SQLite no aplicativo Delphi.

## Estrutura
```
Migrations/
├── SQL/                    # Scripts SQL das migrations
│   ├── V001_initial_schema.sql
│   ├── V002_add_products_table.sql
│   └── ...
├── UMigrationManager.pas   # Classe gerenciadora
└── README.md              # Esta documentação
```

## Como Funciona

### Execução Automática
- Quando o aplicativo inicia, verifica automaticamente por migrations pendentes
- Se o banco não existir, cria e aplica todas as migrations
- Cada migration é executada em uma transação isolada
- Em caso de erro, faz rollback automático

### Tabela de Controle
O sistema cria automaticamente a tabela `schema_migrations` que armazena:
- `version`: Número da versão da migration
- `filename`: Nome do arquivo SQL
- `checksum`: Hash MD5 para validar integridade
- `applied_at`: Data/hora de aplicação
- `execution_time_ms`: Tempo de execução em milissegundos

## Criando Novas Migrations

### 1. Nomenclatura
Use o formato: `VXXX_descricao.sql`

Exemplos:
- `V003_add_orders_table.sql`
- `V004_update_user_permissions.sql`
- `V005_create_indexes.sql`

### 2. Conteúdo
```sql
-- Migration VXXX: Descrição
-- Autor: Seu Nome
-- Data: YYYY-MM-DD

-- Seus comandos SQL aqui
CREATE TABLE exemplo (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL
);

-- Sempre use IF NOT EXISTS para evitar erros
CREATE INDEX IF NOT EXISTS idx_exemplo_nome ON exemplo(nome);
```

### 3. Boas Práticas
- **Sempre** use `IF NOT EXISTS` para CREATE TABLE/INDEX
- **Nunca** modifique migrations já aplicadas
- **Teste** migrations em ambiente de desenvolvimento primeiro
- **Documente** o propósito de cada migration com comentários
- **Incremente** sempre o número da versão

## Funcionalidades

### 1. Backup Automático
Antes de aplicar migrations, o sistema cria um backup do banco:
```
quast_database.backup_20240120_143022.db
```

### 2. Validação de Integridade
- Verifica checksum de migrations já aplicadas
- Detecta se alguma migration foi modificada após aplicação
- Previne aplicação duplicada

### 3. Log Detalhado
Todas as operações são registradas em `migrations.log`:
- Início e fim de cada migration
- Tempo de execução
- Erros encontrados
- Backup criado

### 4. Transações
Cada migration é executada em transação:
- Sucesso = COMMIT
- Erro = ROLLBACK automático

## Visualizando Status

### Via Código
```delphi
procedure VisualizarStatus;
var
  Manager: TMigrationManager;
  Migrations: TArray<TMigrationInfo>;
begin
  Manager := TMigrationManager.Create(FDConnection1);
  try
    Manager.Initialize;
    Migrations := Manager.GetPendingMigrations;
    // Processar lista...
  finally
    Manager.Free;
  end;
end;
```

### Via Menu
Adicione um item de menu que chame `TFrmPrinc.VisualizarMigrations`

## Troubleshooting

### Migration Falhou
1. Verifique o arquivo `migrations.log`
2. Corrija o erro no SQL
3. Crie uma NOVA migration com a correção (não modifique a existente)

### Checksum Inválido
Se receber erro de checksum:
1. **NUNCA** modifique migrations já aplicadas
2. Crie uma nova migration com as alterações necessárias

### Banco Corrompido
1. Restaure do backup mais recente
2. Re-execute as migrations pendentes

## Exemplo de Uso em Produção

### Deploy Inicial
1. Coloque todos os arquivos `.sql` em `Migrations\SQL\`
2. Execute o aplicativo - migrations serão aplicadas automaticamente

### Atualizações
1. Adicione novos arquivos `.sql` com versões incrementais
2. Distribua os novos arquivos com a atualização
3. Migrations serão aplicadas automaticamente no primeiro start

## Segurança
- Migrations são executadas com os privilégios da conexão
- Backup automático antes de mudanças
- Validação de integridade via checksum
- Log completo de todas as operações