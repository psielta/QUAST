unit UFrmLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs, UMigrationManager, UAuthManager,
  UAuthUtils, ULogger;

type
  TFrmLogin = class(TForm)
    lblEmail: TLabel;
    lblSenha: TLabel;
    edtEmail: TEdit;
    edtSenha: TEdit;
    btnEntrar: TButton;
    btnCancelar: TButton;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FormShow(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
  private
    FLoggedUser: TAuthUser;
    procedure ConfigurarConexaoBanco;
    procedure ExecutarMigrations;
  public
    property LoggedUser: TAuthUser read FLoggedUser;
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

procedure TFrmLogin.ConfigurarConexaoBanco;
var
  CaminhoBanco: string;
begin
  Logger.Info('Login: configurando banco de dados...');
  CaminhoBanco := ExtractFilePath(ParamStr(0)) + 'quast_database.db';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Database=' + CaminhoBanco);
  FDConnection1.Params.Add('DriverID=SQLite');
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;
end;

procedure TFrmLogin.ExecutarMigrations;
var
  MigrationManager: TMigrationManager;
begin
  MigrationManager := TMigrationManager.Create(FDConnection1);
  try
    MigrationManager.Initialize;
    MigrationManager.ValidateAppliedMigrations;
    MigrationManager.RunAllPendingMigrations;
  finally
    MigrationManager.Free;
  end;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
var
  AuthMgr: TAuthManager;
begin
  edtEmail.Clear;
  edtSenha.Clear;
  edtEmail.SetFocus;

  ConfigurarConexaoBanco;
  ExecutarMigrations;

  AuthMgr := TAuthManager.Create(FDConnection1);
  try
    AuthMgr.EnsureDefaultAdminExists;
  finally
    AuthMgr.Free;
  end;
end;

procedure TFrmLogin.btnEntrarClick(Sender: TObject);
var
  AuthMgr: TAuthManager;
begin
  if Trim(edtEmail.Text) = '' then
  begin
    MessageDlg('Informe o email.', mtWarning, [mbOK], 0);
    edtEmail.SetFocus;
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    MessageDlg('Informe a senha.', mtWarning, [mbOK], 0);
    edtSenha.SetFocus;
    Exit;
  end;

  AuthMgr := TAuthManager.Create(FDConnection1);
  try
    if AuthMgr.Authenticate(Trim(edtEmail.Text), edtSenha.Text) then
    begin
      FLoggedUser := AuthMgr.CurrentUser;
      ModalResult := mrOk;
    end
    else
    begin
      MessageDlg('Usuário ou senha inválidos.', mtError, [mbOK], 0);
      edtSenha.SelectAll;
      edtSenha.SetFocus;
    end;
  finally
    AuthMgr.Free;
  end;
end;

end.
