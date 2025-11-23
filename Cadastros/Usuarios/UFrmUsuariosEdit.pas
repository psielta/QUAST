unit UFrmUsuariosEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Comp.Client, UAuthUtils;

type
  TFrmUsuariosEdit = class(TForm)
    pnlButtons: TPanel;
    btnSalvar: TButton;
    btnCancelar: TButton;
    pnlContent: TPanel;
    lblNome: TLabel;
    lblEmail: TLabel;
    lblSenha: TLabel;
    lblConfSenha: TLabel;
    edtNome: TEdit;
    edtEmail: TEdit;
    edtSenha: TEdit;
    edtConfSenha: TEdit;
    chkAtivo: TCheckBox;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FUsuarioID: Integer;
    procedure CarregarDados;
    function ValidarDados: Boolean;
    procedure Salvar;
  public
    property UsuarioID: Integer read FUsuarioID write FUsuarioID;
  end;

var
  FrmUsuariosEdit: TFrmUsuariosEdit;

implementation

{$R *.dfm}

uses UFrmPrinc;

procedure TFrmUsuariosEdit.FormShow(Sender: TObject);
begin
  if FUsuarioID > 0 then
  begin
    Caption := 'Editar Usuário';
    CarregarDados;
  end
  else
  begin
    Caption := 'Novo Usuário';
    chkAtivo.Checked := True;
  end;

  edtNome.SetFocus;
end;

procedure TFrmUsuariosEdit.CarregarDados;
var
  Query: TFDQuery;
begin
  FrmPrinc.LogDebug('Carregando usuário ID: %d', [FUsuarioID]);

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FrmPrinc.FDConnection1;
    Query.SQL.Text := 'SELECT nome, email, ativo FROM usuarios WHERE id = :id';
    Query.ParamByName('id').AsInteger := FUsuarioID;
    Query.Open;

    if not Query.IsEmpty then
    begin
      edtNome.Text := Query.FieldByName('nome').AsString;
      edtEmail.Text := Query.FieldByName('email').AsString;
      chkAtivo.Checked := Query.FieldByName('ativo').AsInteger = 1;
    end;
  finally
    Query.Free;
  end;
end;

function TFrmUsuariosEdit.ValidarDados: Boolean;
var
  Count: Integer;
begin
  Result := False;

  if Trim(edtNome.Text) = '' then
  begin
    FrmPrinc.ShowWarning('O nome é obrigatório.');
    edtNome.SetFocus;
    Exit;
  end;

  if Trim(edtEmail.Text) = '' then
  begin
    FrmPrinc.ShowWarning('O email é obrigatório.');
    edtEmail.SetFocus;
    Exit;
  end;

  // Email único
  if FUsuarioID > 0 then
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM usuarios WHERE LOWER(email) = ? AND id <> ?',
      [LowerCase(Trim(edtEmail.Text)), FUsuarioID])
  else
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM usuarios WHERE LOWER(email) = ?',
      [LowerCase(Trim(edtEmail.Text))]);

  if Count > 0 then
  begin
    FrmPrinc.ShowWarning('Já existe um usuário com este email.');
    edtEmail.SetFocus;
    Exit;
  end;

  // Senha obrigatória no novo cadastro
  if FUsuarioID = 0 then
  begin
    if Trim(edtSenha.Text) = '' then
    begin
      FrmPrinc.ShowWarning('A senha é obrigatória para novo usuário.');
      edtSenha.SetFocus;
      Exit;
    end;
  end;

  // Se informou senha, confirmar
  if Trim(edtSenha.Text) <> '' then
  begin
    if edtSenha.Text <> edtConfSenha.Text then
    begin
      FrmPrinc.ShowWarning('A confirmação de senha não confere.');
      edtConfSenha.SetFocus;
      Exit;
    end;
  end;

  Result := True;
end;

procedure TFrmUsuariosEdit.Salvar;
var
  Params: array of Variant;
  SQL: string;
  Hash: string;
begin
  FrmPrinc.StartTransaction;
  try
    if FUsuarioID > 0 then
    begin
      // Atualizar
      if Trim(edtSenha.Text) <> '' then
      begin
        Hash := HashPassword(edtSenha.Text);
        SQL := 'UPDATE usuarios SET nome = ?, email = ?, senha_hash = ?, ativo = ? WHERE id = ?';
        SetLength(Params, 5);
        Params[0] := Trim(edtNome.Text);
        Params[1] := Trim(edtEmail.Text);
        Params[2] := Hash;
        Params[3] := Ord(chkAtivo.Checked);
        Params[4] := FUsuarioID;
      end
      else
      begin
        SQL := 'UPDATE usuarios SET nome = ?, email = ?, ativo = ? WHERE id = ?';
        SetLength(Params, 4);
        Params[0] := Trim(edtNome.Text);
        Params[1] := Trim(edtEmail.Text);
        Params[2] := Ord(chkAtivo.Checked);
        Params[3] := FUsuarioID;
      end;

      FrmPrinc.ExecSQL(SQL, Params);
      FrmPrinc.LogInfo('Usuário atualizado: %s (ID: %d)', [edtNome.Text, FUsuarioID]);
      FrmPrinc.ShowSuccess('Usuário atualizado com sucesso!');
    end
    else
    begin
      // Inserir
      Hash := HashPassword(edtSenha.Text);
      SQL := 'INSERT INTO usuarios (nome, email, senha_hash, ativo) VALUES (?, ?, ?, ?)';
      SetLength(Params, 4);
      Params[0] := Trim(edtNome.Text);
      Params[1] := Trim(edtEmail.Text);
      Params[2] := Hash;
      Params[3] := Ord(chkAtivo.Checked);

      FrmPrinc.ExecSQL(SQL, Params);
      FrmPrinc.LogInfo('Usuário cadastrado: %s', [edtNome.Text]);
      FrmPrinc.ShowSuccess('Usuário cadastrado com sucesso!');
    end;

    FrmPrinc.Commit;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      FrmPrinc.Rollback;
      FrmPrinc.LogException(E, 'Erro ao salvar usuário');
      FrmPrinc.ShowError('Erro ao salvar: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmUsuariosEdit.btnSalvarClick(Sender: TObject);
begin
  if ValidarDados then
    Salvar;
end;

procedure TFrmUsuariosEdit.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
