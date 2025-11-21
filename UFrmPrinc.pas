unit UFrmPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.StrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.Skia,
  Vcl.Imaging.pngimage, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite,
  UMigrationManager, Datasnap.DBClient, FireDAC.Stan.Param, ULogger;

type
  TFrmPrinc = class(TForm)
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    Sobre1: TMenuItem;
    Image1: TImage;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    MenuBancas: TMenuItem;
    MenuAreas: TMenuItem;
    N1: TMenuItem;
    procedure Sobre1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VisualizarMigrations;
    procedure MenuBancasClick(Sender: TObject);
    procedure MenuAreasClick(Sender: TObject);
  private
    { Private declarations }
    FMigrationManager: TMigrationManager;
    procedure ConfigurarConexaoBanco;
    procedure ExecutarMigrations;
  public
    { Public declarations }
    // Métodos utilitários para trabalhar com banco de dados
    procedure ExecSQL(const ASQL: string); overload;
    procedure ExecSQL(const ASQL: string; const AParams: array of Variant); overload;
    function ExecuteScalar(const ASQL: string): Variant; overload;
    function ExecuteScalar(const ASQL: string; const AParams: array of Variant): Variant; overload;
    function ExecuteScalarInt(const ASQL: string): Integer; overload;
    function ExecuteScalarInt(const ASQL: string; const AParams: array of Variant): Integer; overload;
    function ExecuteScalarStr(const ASQL: string): string; overload;
    function ExecuteScalarStr(const ASQL: string; const AParams: array of Variant): string; overload;
    function InTransaction: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;

    // Métodos de log (atalhos para o Logger global)
    procedure LogDebug(const AMessage: string); overload;
    procedure LogDebug(const AFormat: string; const AArgs: array of const); overload;
    procedure LogInfo(const AMessage: string); overload;
    procedure LogInfo(const AFormat: string; const AArgs: array of const); overload;
    procedure LogWarning(const AMessage: string); overload;
    procedure LogWarning(const AFormat: string; const AArgs: array of const); overload;
    procedure LogError(const AMessage: string); overload;
    procedure LogError(const AFormat: string; const AArgs: array of const); overload;
    procedure LogException(E: Exception; const AContext: string = '');

    // Métodos para exibir mensagens
    procedure ShowInfo(const AMessage: string); overload;
    procedure ShowInfo(const AFormat: string; const AArgs: array of const); overload;
    procedure ShowWarning(const AMessage: string); overload;
    procedure ShowWarning(const AFormat: string; const AArgs: array of const); overload;
    procedure ShowError(const AMessage: string); overload;
    procedure ShowError(const AFormat: string; const AArgs: array of const); overload;
    procedure ShowSuccess(const AMessage: string); overload;
    procedure ShowSuccess(const AFormat: string; const AArgs: array of const); overload;
    function Confirm(const AMessage: string): Boolean; overload;
    function Confirm(const AFormat: string; const AArgs: array of const): Boolean; overload;
    function ConfirmYesNoCancel(const AMessage: string): Integer; overload;
    function ConfirmYesNoCancel(const AFormat: string; const AArgs: array of const): Integer; overload;
    procedure ShowMessage(const AMessage: string); overload;
    procedure ShowMessage(const AFormat: string; const AArgs: array of const); overload;
  end;

var
  FrmPrinc: TFrmPrinc;

implementation

{$R *.dfm}

uses UFrmSobre, UFrmBancasLista, UFrmAreasLista;

procedure TFrmPrinc.ConfigurarConexaoBanco;
var
  CaminhoBanco: string;
begin
  LogInfo('Iniciando configuração do banco de dados...');

  // Obter o caminho do executável e concatenar com o nome do banco
  CaminhoBanco := ExtractFilePath(ParamStr(0)) + 'quast_database.db';
  LogDebug('Caminho do banco: %s', [CaminhoBanco]);

  // Configurar a conexão
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Database=' + CaminhoBanco);
  FDConnection1.Params.Add('DriverID=SQLite');
  FDConnection1.LoginPrompt := False;

  try
    FDConnection1.Connected := True;
    LogInfo('Conexão com banco de dados estabelecida com sucesso');

    // Executar sistema de migrations
    ExecutarMigrations;
  except
    on E: Exception do
    begin
      LogException(E, 'Erro ao conectar ao banco de dados');
      ShowError('Erro ao conectar ao banco de dados: ' + E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TFrmPrinc.ExecutarMigrations;
begin
  try
    // Criar gerenciador de migrations
    FMigrationManager := TMigrationManager.Create(FDConnection1);
    try
      // Por enquanto, não configurar callback - logs vão apenas para arquivo
      // FMigrationManager.LogCallback := nil;

      // Inicializar sistema de migrations
      FMigrationManager.Initialize;

      // Validar integridade das migrations já aplicadas
      FMigrationManager.ValidateAppliedMigrations;

      // Executar todas as migrations pendentes
      FMigrationManager.RunAllPendingMigrations;
    finally
      FreeAndNil(FMigrationManager);
    end;
  except
    on E: EMigrationException do
    begin
      ShowError('Erro no sistema de migrations: ' + E.Message);
      Application.Terminate;
    end;
    on E: Exception do
    begin
      ShowError('Erro inesperado: ' + E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TFrmPrinc.FormCreate(Sender: TObject);
begin
  ConfigurarConexaoBanco;
end;

procedure TFrmPrinc.Sobre1Click(Sender: TObject);
begin
  FrmSobre := TFrmSobre.Create(Self);
  FrmSobre.ShowModal();
end;

procedure TFrmPrinc.MenuBancasClick(Sender: TObject);
var
  Frm: TFrmBancasLista;
begin
  Frm := TFrmBancasLista.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrinc.MenuAreasClick(Sender: TObject);
var
  Frm: TFrmAreasLista;
begin
  Frm := TFrmAreasLista.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmPrinc.VisualizarMigrations;
var
  MigrationManager: TMigrationManager;
  AllMigrations: TArray<TMigrationInfo>;
  I: Integer;
  Status, Mensagem: string;
begin
  if not FDConnection1.Connected then
  begin
    ShowMessage('Banco de dados não está conectado.');
    Exit;
  end;

  MigrationManager := TMigrationManager.Create(FDConnection1);
  try
    MigrationManager.Initialize;
    AllMigrations := MigrationManager.GetAllMigrations;

    Mensagem := 'Status das Migrations:' + #13#10 + #13#10;

    if Length(AllMigrations) = 0 then
    begin
      Mensagem := Mensagem + 'Nenhuma migration encontrada.';
    end
    else
    begin
      for I := 0 to Length(AllMigrations) - 1 do
      begin
        if AllMigrations[I].Applied then
          Status := '✓ Aplicada em ' + DateTimeToStr(AllMigrations[I].AppliedAt)
        else
          Status := '⚠ Pendente';

        Mensagem := Mensagem + Format('V%3.3d - %s: %s',
          [AllMigrations[I].Version, AllMigrations[I].Filename, Status]
          ) + #13#10;
      end;
    end;

    ShowMessage(Mensagem);
  finally
    MigrationManager.Free;
  end;
end;

{ Métodos utilitários de banco de dados }

procedure TFrmPrinc.ExecSQL(const ASQL: string);
var
  Query: TFDQuery;
begin
  LogDebug('ExecSQL: %s', [ASQL]);
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := ASQL;
    Query.ExecSQL;
  except
    on E: Exception do
    begin
      LogException(E, 'Erro ao executar SQL: ' + ASQL);
      raise;
    end;
  end;
  Query.Free;
end;

procedure TFrmPrinc.ExecSQL(const ASQL: string; const AParams: array of Variant);
var
  Query: TFDQuery;
  I: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := ASQL;

    for I := 0 to High(AParams) do
      Query.Params[I].Value := AParams[I];

    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TFrmPrinc.ExecuteScalar(const ASQL: string): Variant;
var
  Query: TFDQuery;
begin
  Result := Null;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := ASQL;
    Query.Open;

    if not Query.IsEmpty then
      Result := Query.Fields[0].Value;
  finally
    Query.Free;
  end;
end;

function TFrmPrinc.ExecuteScalar(const ASQL: string; const AParams: array of Variant): Variant;
var
  Query: TFDQuery;
  I: Integer;
begin
  Result := Null;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection1;
    Query.SQL.Text := ASQL;

    for I := 0 to High(AParams) do
      Query.Params[I].Value := AParams[I];

    Query.Open;

    if not Query.IsEmpty then
      Result := Query.Fields[0].Value;
  finally
    Query.Free;
  end;
end;

function TFrmPrinc.ExecuteScalarInt(const ASQL: string): Integer;
var
  Value: Variant;
begin
  Value := ExecuteScalar(ASQL);
  if VarIsNull(Value) then
    Result := 0
  else
    Result := Value;
end;

function TFrmPrinc.ExecuteScalarInt(const ASQL: string; const AParams: array of Variant): Integer;
var
  Value: Variant;
begin
  Value := ExecuteScalar(ASQL, AParams);
  if VarIsNull(Value) then
    Result := 0
  else
    Result := Value;
end;

function TFrmPrinc.ExecuteScalarStr(const ASQL: string): string;
var
  Value: Variant;
begin
  Value := ExecuteScalar(ASQL);
  if VarIsNull(Value) then
    Result := ''
  else
    Result := VarToStr(Value);
end;

function TFrmPrinc.ExecuteScalarStr(const ASQL: string; const AParams: array of Variant): string;
var
  Value: Variant;
begin
  Value := ExecuteScalar(ASQL, AParams);
  if VarIsNull(Value) then
    Result := ''
  else
    Result := VarToStr(Value);
end;

function TFrmPrinc.InTransaction: Boolean;
begin
  Result := FDConnection1.InTransaction;
end;

procedure TFrmPrinc.StartTransaction;
begin
  if not FDConnection1.InTransaction then
    FDConnection1.StartTransaction;
end;

procedure TFrmPrinc.Commit;
begin
  if FDConnection1.InTransaction then
    FDConnection1.Commit;
end;

procedure TFrmPrinc.Rollback;
begin
  if FDConnection1.InTransaction then
    FDConnection1.Rollback;
end;

{ Métodos de log }

procedure TFrmPrinc.LogDebug(const AMessage: string);
begin
  Logger.Debug(AMessage);
end;

procedure TFrmPrinc.LogDebug(const AFormat: string; const AArgs: array of const);
begin
  Logger.Debug(AFormat, AArgs);
end;

procedure TFrmPrinc.LogInfo(const AMessage: string);
begin
  Logger.Info(AMessage);
end;

procedure TFrmPrinc.LogInfo(const AFormat: string; const AArgs: array of const);
begin
  Logger.Info(AFormat, AArgs);
end;

procedure TFrmPrinc.LogWarning(const AMessage: string);
begin
  Logger.Warning(AMessage);
end;

procedure TFrmPrinc.LogWarning(const AFormat: string; const AArgs: array of const);
begin
  Logger.Warning(AFormat, AArgs);
end;

procedure TFrmPrinc.LogError(const AMessage: string);
begin
  Logger.Error(AMessage);
end;

procedure TFrmPrinc.LogError(const AFormat: string; const AArgs: array of const);
begin
  Logger.Error(AFormat, AArgs);
end;

procedure TFrmPrinc.LogException(E: Exception; const AContext: string);
begin
  Logger.LogException(E, AContext);
end;

{ Métodos para exibir mensagens }

procedure TFrmPrinc.ShowInfo(const AMessage: string);
begin
  LogInfo(AMessage);
  MessageBox(Handle, PChar(AMessage), 'Informação', MB_OK or MB_ICONINFORMATION);
end;

procedure TFrmPrinc.ShowInfo(const AFormat: string; const AArgs: array of const);
begin
  ShowInfo(Format(AFormat, AArgs));
end;

procedure TFrmPrinc.ShowWarning(const AMessage: string);
begin
  LogWarning(AMessage);
  MessageBox(Handle, PChar(AMessage), 'Atenção', MB_OK or MB_ICONWARNING);
end;

procedure TFrmPrinc.ShowWarning(const AFormat: string; const AArgs: array of const);
begin
  ShowWarning(Format(AFormat, AArgs));
end;

procedure TFrmPrinc.ShowError(const AMessage: string);
begin
  LogError(AMessage);
  MessageBox(Handle, PChar(AMessage), 'Erro', MB_OK or MB_ICONERROR);
end;

procedure TFrmPrinc.ShowError(const AFormat: string; const AArgs: array of const);
begin
  ShowError(Format(AFormat, AArgs));
end;

procedure TFrmPrinc.ShowSuccess(const AMessage: string);
begin
  LogInfo('Sucesso: ' + AMessage);
  MessageBox(Handle, PChar(AMessage), 'Sucesso', MB_OK or MB_ICONINFORMATION);
end;

procedure TFrmPrinc.ShowSuccess(const AFormat: string; const AArgs: array of const);
begin
  ShowSuccess(Format(AFormat, AArgs));
end;

function TFrmPrinc.Confirm(const AMessage: string): Boolean;
var
  Response: Integer;
begin
  LogDebug('Solicitando confirmação: ' + AMessage);
  Response := MessageBox(Handle, PChar(AMessage), 'Confirmação',
    MB_YESNO or MB_ICONQUESTION);
  Result := Response = IDYES;
  LogDebug('Resposta da confirmação: ' + IfThen(Result, 'Sim', 'Não'));
end;

function TFrmPrinc.Confirm(const AFormat: string; const AArgs: array of const): Boolean;
begin
  Result := Confirm(Format(AFormat, AArgs));
end;

function TFrmPrinc.ConfirmYesNoCancel(const AMessage: string): Integer;
begin
  LogDebug('Solicitando confirmação (Sim/Não/Cancelar): ' + AMessage);
  Result := MessageBox(Handle, PChar(AMessage), 'Confirmação',
    MB_YESNOCANCEL or MB_ICONQUESTION);
  case Result of
    IDYES: LogDebug('Resposta: Sim');
    IDNO: LogDebug('Resposta: Não');
    IDCANCEL: LogDebug('Resposta: Cancelar');
  end;
end;

function TFrmPrinc.ConfirmYesNoCancel(const AFormat: string; const AArgs: array of const): Integer;
begin
  Result := ConfirmYesNoCancel(Format(AFormat, AArgs));
end;

procedure TFrmPrinc.ShowMessage(const AMessage: string);
begin
  LogInfo(AMessage);
  Vcl.Dialogs.ShowMessage(AMessage);
end;

procedure TFrmPrinc.ShowMessage(const AFormat: string; const AArgs: array of const);
begin
  ShowMessage(Format(AFormat, AArgs));
end;

end.
