unit UMigrationManager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.Generics.Defaults, System.Types, System.DateUtils, System.UITypes,
  System.Hash, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Script,
  Vcl.Dialogs, Winapi.Windows;

type
  TMigrationInfo = record
    Version: Integer;
    Filename: string;
    Checksum: string;
    Applied: Boolean;
    AppliedAt: TDateTime;
  end;

  TMigrationManager = class
  private
    FConnection: TFDConnection;
    FMigrationsPath: string;
    FLogCallback: TProc<string>;
    FBackupBeforeMigration: Boolean;

    procedure Log(const AMessage: string);
    procedure CreateMigrationTable;
    function GetMigrationChecksum(const AFilePath: string): string;
    function IsMigrationApplied(const AFilename: string): Boolean;
    function ExtractVersionFromFilename(const AFilename: string): Integer;
    procedure RecordMigration(const AVersion: Integer; const AFilename, AChecksum: string;
      const AExecutionTime: Integer);
    function BackupDatabase: Boolean;
    function GetDatabasePath: string;
    procedure ValidateMigrationChecksum(const AFilename, AStoredChecksum: string);
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;

    procedure Initialize;
    function GetAllMigrations: TArray<TMigrationInfo>;
    function GetPendingMigrations: TArray<TMigrationInfo>;
    function GetAppliedMigrations: TArray<TMigrationInfo>;
    procedure ApplyMigration(const AMigrationFile: string);
    procedure RunAllPendingMigrations;
    procedure ValidateAppliedMigrations;

    property Connection: TFDConnection read FConnection write FConnection;
    property MigrationsPath: string read FMigrationsPath write FMigrationsPath;
    property LogCallback: TProc<string> read FLogCallback write FLogCallback;
    property BackupBeforeMigration: Boolean read FBackupBeforeMigration write FBackupBeforeMigration;
  end;

  EMigrationException = class(Exception);

implementation

{ TMigrationManager }

constructor TMigrationManager.Create(AConnection: TFDConnection);
var
  ExePath, MigrationsDir: string;
begin
  inherited Create;
  FConnection := AConnection;

  // Tenta encontrar o diretório de migrations
  ExePath := ExtractFilePath(ParamStr(0));

  // Primeiro tenta no diretório do executável
  MigrationsDir := ExePath + 'Migrations\SQL\';

  // Se não existir, tenta 2 níveis acima (para quando está em Win64\Debug)
  if not DirectoryExists(MigrationsDir) then
    MigrationsDir := ExtractFilePath(ExcludeTrailingPathDelimiter(
                      ExtractFilePath(ExcludeTrailingPathDelimiter(ExePath)))) + 'Migrations\SQL\';

  // Se ainda não existir, tenta 1 nível acima
  if not DirectoryExists(MigrationsDir) then
    MigrationsDir := ExtractFilePath(ExcludeTrailingPathDelimiter(ExePath)) + 'Migrations\SQL\';

  FMigrationsPath := MigrationsDir;
  FBackupBeforeMigration := True;
end;

destructor TMigrationManager.Destroy;
begin
  inherited;
end;

procedure TMigrationManager.Log(const AMessage: string);
var
  LogFile: TextFile;
  LogPath: string;
begin
  // Chama callback se definido
  if Assigned(FLogCallback) then
    FLogCallback('[' + DateTimeToStr(Now) + '] ' + AMessage);

  // Também grava em arquivo de log
  LogPath := ExtractFilePath(ParamStr(0)) + 'migrations.log';
  AssignFile(LogFile, LogPath);
  try
    if FileExists(LogPath) then
      Append(LogFile)
    else
      Rewrite(LogFile);
    WriteLn(LogFile, '[' + DateTimeToStr(Now) + '] ' + AMessage);
  finally
    CloseFile(LogFile);
  end;
end;

procedure TMigrationManager.Initialize;
begin
  Log('Inicializando sistema de migrations...');

  if not FConnection.Connected then
    raise EMigrationException.Create('Conexão com banco de dados não está ativa');

  CreateMigrationTable;

  // Verifica se encontrou o diretório de migrations
  if not DirectoryExists(FMigrationsPath) then
  begin
    Log('AVISO: Diretório de migrations não encontrado: ' + FMigrationsPath);
    ForceDirectories(FMigrationsPath);
    Log('Diretório de migrations criado: ' + FMigrationsPath);
  end
  else
  begin
    Log('Diretório de migrations encontrado: ' + FMigrationsPath);
  end;

  Log('Sistema de migrations inicializado com sucesso');
end;

procedure TMigrationManager.CreateMigrationTable;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS schema_migrations (' +
      '  version INTEGER PRIMARY KEY,' +
      '  filename TEXT NOT NULL UNIQUE,' +
      '  checksum TEXT NOT NULL,' +
      '  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
      '  execution_time_ms INTEGER' +
      ');';
    Query.ExecSQL;
    Log('Tabela de controle de migrations verificada/criada');
  finally
    Query.Free;
  end;
end;

function TMigrationManager.GetMigrationChecksum(const AFilePath: string): string;
var
  FileContent: TStringList;
begin
  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(AFilePath);
    Result := THashMD5.GetHashString(FileContent.Text);
  finally
    FileContent.Free;
  end;
end;

function TMigrationManager.IsMigrationApplied(const AFilename: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT COUNT(*) FROM schema_migrations WHERE filename = :filename';
    Query.ParamByName('filename').AsString := AFilename;
    Query.Open;
    Result := Query.Fields[0].AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TMigrationManager.ExtractVersionFromFilename(const AFilename: string): Integer;
var
  VersionStr: string;
  I: Integer;
begin
  // Extrai número da versão do formato VXXX_description.sql
  Result := -1;

  if not AFilename.StartsWith('V', True) then
    raise EMigrationException.Create('Nome de migration inválido: ' + AFilename +
      '. Use o formato VXXX_description.sql');

  VersionStr := '';
  for I := 2 to Length(AFilename) do
  begin
    if CharInSet(AFilename[I], ['0'..'9']) then
      VersionStr := VersionStr + AFilename[I]
    else if AFilename[I] = '_' then
      Break
    else
      raise EMigrationException.Create('Nome de migration inválido: ' + AFilename);
  end;

  if not TryStrToInt(VersionStr, Result) then
    raise EMigrationException.Create('Não foi possível extrair versão de: ' + AFilename);
end;

procedure TMigrationManager.RecordMigration(const AVersion: Integer;
  const AFilename, AChecksum: string; const AExecutionTime: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'INSERT INTO schema_migrations (version, filename, checksum, execution_time_ms) ' +
      'VALUES (:version, :filename, :checksum, :execution_time)';
    Query.ParamByName('version').AsInteger := AVersion;
    Query.ParamByName('filename').AsString := AFilename;
    Query.ParamByName('checksum').AsString := AChecksum;
    Query.ParamByName('execution_time').AsInteger := AExecutionTime;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TMigrationManager.GetDatabasePath: string;
var
  DBParam: string;
begin
  DBParam := FConnection.Params.Values['Database'];
  if DBParam = '' then
    raise EMigrationException.Create('Caminho do banco de dados não encontrado');
  Result := DBParam;
end;

function TMigrationManager.BackupDatabase: Boolean;
var
  SourcePath, BackupPath: string;
begin
  Result := False;
  try
    SourcePath := GetDatabasePath;
    BackupPath := ChangeFileExt(SourcePath, '.backup_' +
      FormatDateTime('yyyymmdd_hhnnss', Now) + ExtractFileExt(SourcePath));

    // Fecha conexão temporariamente para fazer backup
    FConnection.Connected := False;
    try
      TFile.Copy(SourcePath, BackupPath, True);
      Log('Backup do banco criado: ' + BackupPath);
      Result := True;
    finally
      FConnection.Connected := True;
    end;
  except
    on E: Exception do
      Log('Erro ao criar backup: ' + E.Message);
  end;
end;

procedure TMigrationManager.ValidateMigrationChecksum(const AFilename, AStoredChecksum: string);
var
  CurrentChecksum: string;
  FilePath: string;
begin
  FilePath := TPath.Combine(FMigrationsPath, AFilename);
  if not FileExists(FilePath) then
  begin
    Log('AVISO: Arquivo de migration não encontrado: ' + AFilename);
    Exit;
  end;

  CurrentChecksum := GetMigrationChecksum(FilePath);
  if CurrentChecksum <> AStoredChecksum then
    raise EMigrationException.Create(
      'Checksum da migration ' + AFilename + ' foi alterado! ' +
      'Original: ' + AStoredChecksum + ', Atual: ' + CurrentChecksum);
end;

function TMigrationManager.GetAllMigrations: TArray<TMigrationInfo>;
var
  Files: TStringDynArray;
  Migration: TMigrationInfo;
  I: Integer;
  List: TList<TMigrationInfo>;
begin
  List := TList<TMigrationInfo>.Create;
  try
    // Busca arquivos SQL no diretório
    if DirectoryExists(FMigrationsPath) then
    begin
      Files := TDirectory.GetFiles(FMigrationsPath, '*.sql');
      Log(Format('Encontrados %d arquivo(s) de migration em: %s', [Length(Files), FMigrationsPath]));

      for I := 0 to Length(Files) - 1 do
      begin
        Migration.Filename := ExtractFileName(Files[I]);
        Log('Processando migration: ' + Migration.Filename);
        Migration.Version := ExtractVersionFromFilename(Migration.Filename);
        Migration.Checksum := GetMigrationChecksum(Files[I]);
        Migration.Applied := IsMigrationApplied(Migration.Filename);

        if Migration.Applied then
        begin
          // Busca data de aplicação
          var Query := TFDQuery.Create(nil);
          try
            Query.Connection := FConnection;
            Query.SQL.Text := 'SELECT applied_at FROM schema_migrations WHERE filename = :filename';
            Query.ParamByName('filename').AsString := Migration.Filename;
            Query.Open;
            if not Query.IsEmpty then
              Migration.AppliedAt := Query.Fields[0].AsDateTime;
          finally
            Query.Free;
          end;
        end;

        List.Add(Migration);
      end;
    end;

    // Ordena por versão
    List.Sort(TComparer<TMigrationInfo>.Construct(
      function(const Left, Right: TMigrationInfo): Integer
      begin
        Result := Left.Version - Right.Version;
      end));

    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function TMigrationManager.GetPendingMigrations: TArray<TMigrationInfo>;
var
  AllMigrations: TArray<TMigrationInfo>;
  PendingList: TList<TMigrationInfo>;
  I: Integer;
begin
  PendingList := TList<TMigrationInfo>.Create;
  try
    AllMigrations := GetAllMigrations;

    for I := 0 to Length(AllMigrations) - 1 do
    begin
      if not AllMigrations[I].Applied then
        PendingList.Add(AllMigrations[I]);
    end;

    Result := PendingList.ToArray;
  finally
    PendingList.Free;
  end;
end;

function TMigrationManager.GetAppliedMigrations: TArray<TMigrationInfo>;
var
  AllMigrations: TArray<TMigrationInfo>;
  AppliedList: TList<TMigrationInfo>;
  I: Integer;
begin
  AppliedList := TList<TMigrationInfo>.Create;
  try
    AllMigrations := GetAllMigrations;

    for I := 0 to Length(AllMigrations) - 1 do
    begin
      if AllMigrations[I].Applied then
        AppliedList.Add(AllMigrations[I]);
    end;

    Result := AppliedList.ToArray;
  finally
    AppliedList.Free;
  end;
end;

procedure TMigrationManager.ApplyMigration(const AMigrationFile: string);
var
  FilePath: string;
  Script: TFDScript;
  StartTime, EndTime: TDateTime;
  ExecutionTime: Integer;
  Version: Integer;
  Checksum: string;
begin
  FilePath := TPath.Combine(FMigrationsPath, AMigrationFile);

  if not FileExists(FilePath) then
    raise EMigrationException.Create('Arquivo de migration não encontrado: ' + FilePath);

  if IsMigrationApplied(AMigrationFile) then
  begin
    Log('Migration já aplicada: ' + AMigrationFile);
    Exit;
  end;

  Version := ExtractVersionFromFilename(AMigrationFile);
  Checksum := GetMigrationChecksum(FilePath);

  Log('Aplicando migration: ' + AMigrationFile);

  Script := TFDScript.Create(nil);
  try
    Script.Connection := FConnection;
    Script.ScriptOptions.CommandSeparator := ';';
    Script.ScriptOptions.CommitEachNCommands := 0;
    Script.ScriptOptions.RaisePLSQLErrors := True;

    // Carrega o script
    Script.SQLScripts.Clear;
    Script.SQLScripts.Add.SQL.LoadFromFile(FilePath);

    // Inicia transação
    FConnection.StartTransaction;
    try
      StartTime := Now;

      // Executa o script
      Script.ValidateAll;
      Script.ExecuteAll;

      EndTime := Now;
      ExecutionTime := Round((EndTime - StartTime) * 24 * 60 * 60 * 1000); // Converte para milissegundos

      // Registra a migration
      RecordMigration(Version, AMigrationFile, Checksum, ExecutionTime);

      // Confirma transação
      FConnection.Commit;

      Log(Format('Migration aplicada com sucesso: %s (Tempo: %d ms)',
        [AMigrationFile, ExecutionTime]));
    except
      on E: Exception do
      begin
        FConnection.Rollback;
        Log('Erro ao aplicar migration ' + AMigrationFile + ': ' + E.Message);
        raise EMigrationException.Create('Falha ao aplicar migration ' +
          AMigrationFile + ': ' + E.Message);
      end;
    end;
  finally
    Script.Free;
  end;
end;

procedure TMigrationManager.RunAllPendingMigrations;
var
  PendingMigrations: TArray<TMigrationInfo>;
  I: Integer;
  TotalMigrations: Integer;
begin
  Log('Verificando migrations pendentes...');

  PendingMigrations := GetPendingMigrations;
  TotalMigrations := Length(PendingMigrations);

  if TotalMigrations = 0 then
  begin
    Log('Nenhuma migration pendente');
    Exit;
  end;

  Log(Format('Encontradas %d migrations pendentes', [TotalMigrations]));

  // Faz backup antes de aplicar migrations
  if FBackupBeforeMigration and (TotalMigrations > 0) then
  begin
    if not BackupDatabase then
    begin
      if MessageDlg('Não foi possível criar backup do banco. Continuar mesmo assim?',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrNo then
      begin
        Log('Processo de migration cancelado pelo usuário');
        Exit;
      end;
    end;
  end;

  // Aplica cada migration pendente
  for I := 0 to TotalMigrations - 1 do
  begin
    Log(Format('Aplicando migration %d de %d: %s',
      [I + 1, TotalMigrations, PendingMigrations[I].Filename]));

    try
      ApplyMigration(PendingMigrations[I].Filename);
    except
      on E: EMigrationException do
      begin
        Log('Processo de migration interrompido devido a erro');
        raise;
      end;
    end;
  end;

  Log('Todas as migrations foram aplicadas com sucesso');
end;

procedure TMigrationManager.ValidateAppliedMigrations;
var
  Query: TFDQuery;
begin
  Log('Validando integridade das migrations aplicadas...');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT filename, checksum FROM schema_migrations ORDER BY version';
    Query.Open;

    while not Query.Eof do
    begin
      ValidateMigrationChecksum(
        Query.FieldByName('filename').AsString,
        Query.FieldByName('checksum').AsString
      );
      Query.Next;
    end;

    Log('Validação de migrations concluída com sucesso');
  finally
    Query.Free;
  end;
end;

end.