unit UAuthManager;

interface

uses
  System.SysUtils, System.Variants, FireDAC.Comp.Client, FireDAC.Stan.Param,
  UAuthUtils, ULogger;

type
  TAuthUser = record
    Id: Integer;
    Nome: string;
    Email: string;
    Ativo: Boolean;
    CriadoEm: TDateTime;
  end;

  TAuthManager = class
  private
    FConn: TFDConnection;
    FCurrentUser: TAuthUser;
    FAuthenticated: Boolean;
  public
    constructor Create(AConnection: TFDConnection);
    function Authenticate(const AEmail, ASenha: string): Boolean;
    procedure Logout;
    procedure EnsureDefaultAdminExists;
    property CurrentUser: TAuthUser read FCurrentUser;
    property IsAuthenticated: Boolean read FAuthenticated;
  end;

implementation

{ TAuthManager }

constructor TAuthManager.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConn := AConnection;
  FAuthenticated := False;
  FillChar(FCurrentUser, SizeOf(FCurrentUser), 0);
end;

procedure TAuthManager.EnsureDefaultAdminExists;
var
  Query: TFDQuery;
  CountUsers: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    try
      Query.Connection := FConn;
      Query.SQL.Text := 'SELECT COUNT(1) FROM usuarios';
      Query.Open;
      CountUsers := Query.Fields[0].AsInteger;
      Query.Close;

      if CountUsers = 0 then
      begin
        Logger.Info('Nenhum usuario encontrado. Criando admin padrao.');
        Query.SQL.Text :=
          'INSERT INTO usuarios (nome, email, senha_hash, ativo) VALUES (:n, :e, :s, 1)';
        Query.ParamByName('n').AsString := 'Administrador';
        Query.ParamByName('e').AsString := 'admin@quast.local';
        Query.ParamByName('s').AsString := HashPassword('admin123');
        Query.ExecSQL;
      end;
    except
      on E: Exception do
      begin
        Logger.LogException(E, 'EnsureDefaultAdminExists');
        raise;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TAuthManager.Authenticate(const AEmail, ASenha: string): Boolean;
var
  Query: TFDQuery;
  Hash: string;
begin
  Result := False;
  Hash := HashPassword(ASenha);

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT id, nome, email, ativo, criado_em FROM usuarios '
      + 'WHERE email = :email AND senha_hash = :senha AND ativo = 1';
    Query.ParamByName('email').AsString := AEmail;
    Query.ParamByName('senha').AsString := Hash;
    Query.Open;

    if not Query.IsEmpty then
    begin
      FCurrentUser.Id := Query.FieldByName('id').AsInteger;
      FCurrentUser.Nome := Query.FieldByName('nome').AsString;
      FCurrentUser.Email := Query.FieldByName('email').AsString;
      FCurrentUser.Ativo := Query.FieldByName('ativo').AsInteger = 1;
      FCurrentUser.CriadoEm := Query.FieldByName('criado_em').AsDateTime;
      FAuthenticated := True;
      Result := True;

      // log auditoria de sucesso
      try
        Query.Close;
        Query.SQL.Text :=
          'INSERT INTO auditoria (usuario_id, acao, tabela, registro_id, dados_anteriores, dados_novos) '
          + 'VALUES (:uid, :acao, :tab, :rid, NULL, NULL)';
        Query.ParamByName('uid').AsInteger := FCurrentUser.Id;
        Query.ParamByName('acao').AsString := 'LOGIN_SUCESSO';
        Query.ParamByName('tab').AsString := 'usuarios';
        Query.ParamByName('rid').AsInteger := FCurrentUser.Id;
        Query.ExecSQL;
      except
        on E: Exception do
          Logger.LogException(E, 'Auditoria login sucesso');
      end;
    end
    else
    begin
      // log auditoria de falha (sem usuario_id conhecido)
      try
        Query.Close;
        Query.SQL.Text :=
          'INSERT INTO auditoria (acao, tabela, registro_id, dados_anteriores, dados_novos) '
          + 'VALUES (:acao, :tab, NULL, NULL, NULL)';
        Query.ParamByName('acao').AsString := 'LOGIN_FALHA';
        Query.ParamByName('tab').AsString := 'usuarios';
        Query.ExecSQL;
      except
        on E: Exception do
          Logger.LogException(E, 'Auditoria login falha');
      end;
    end;
  finally
    Query.Free;
  end;
end;

procedure TAuthManager.Logout;
begin
  FAuthenticated := False;
  FillChar(FCurrentUser, SizeOf(FCurrentUser), 0);
end;

end.
