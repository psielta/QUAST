unit UFrmBancasEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Math;

type
  TFrmBancasEdit = class(TForm)
    pnlButtons: TPanel;
    btnSalvar: TButton;
    btnCancelar: TButton;
    pnlContent: TPanel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblSigla: TLabel;
    edtSigla: TEdit;
    lblDescricao: TLabel;
    memoDescricao: TMemo;
    lblSite: TLabel;
    edtSite: TEdit;
    chkAtivo: TCheckBox;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FBancaID: Integer;
    procedure CarregarDados;
    function ValidarDados: Boolean;
    procedure Salvar;
  public
    property BancaID: Integer read FBancaID write FBancaID;
  end;

var
  FrmBancasEdit: TFrmBancasEdit;

implementation

{$R *.dfm}

uses UFrmPrinc, FireDAC.Comp.Client;

procedure TFrmBancasEdit.FormShow(Sender: TObject);
begin
  if FBancaID > 0 then
  begin
    Caption := 'Editar Banca';
    CarregarDados;
  end
  else
  begin
    Caption := 'Nova Banca';
    chkAtivo.Checked := True;
  end;

  edtNome.SetFocus;
end;

procedure TFrmBancasEdit.CarregarDados;
var
  Query: TFDQuery;
begin
  FrmPrinc.LogDebug('Carregando dados da banca ID: %d', [FBancaID]);

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FrmPrinc.FDConnection1;
    Query.SQL.Text := 'SELECT * FROM bancas WHERE id = :id';
    Query.ParamByName('id').AsInteger := FBancaID;
    Query.Open;

    if not Query.IsEmpty then
    begin
      edtNome.Text := Query.FieldByName('nome').AsString;
      edtSigla.Text := Query.FieldByName('sigla').AsString;
      memoDescricao.Text := Query.FieldByName('descricao').AsString;
      edtSite.Text := Query.FieldByName('site').AsString;
      chkAtivo.Checked := Query.FieldByName('ativo').AsInteger = 1;
    end;
  finally
    Query.Free;
  end;
end;

function TFrmBancasEdit.ValidarDados: Boolean;
var
  Count: Integer;
begin
  Result := False;

  // Validar nome obrigatório
  if Trim(edtNome.Text) = '' then
  begin
    FrmPrinc.ShowWarning('O nome da banca é obrigatório');
    edtNome.SetFocus;
    Exit;
  end;

  // Validar duplicidade de nome
  if FBancaID > 0 then
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM bancas WHERE LOWER(nome) = ? AND id <> ?',
      [LowerCase(Trim(edtNome.Text)), FBancaID])
  else
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM bancas WHERE LOWER(nome) = ?',
      [LowerCase(Trim(edtNome.Text))]);

  if Count > 0 then
  begin
    FrmPrinc.ShowWarning('Já existe uma banca cadastrada com este nome');
    edtNome.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TFrmBancasEdit.Salvar;
var
  Ativo: Integer;
begin
  Ativo := IfThen(chkAtivo.Checked, 1, 0);

  FrmPrinc.StartTransaction;
  try
    if FBancaID > 0 then
    begin
      // Atualizar
      FrmPrinc.ExecSQL(
        'UPDATE bancas SET nome = ?, sigla = ?, descricao = ?, site = ?, ativo = ? WHERE id = ?',
        [Trim(edtNome.Text), Trim(edtSigla.Text), Trim(memoDescricao.Text),
         Trim(edtSite.Text), Ativo, FBancaID]);

      FrmPrinc.LogInfo('Banca atualizada: %s (ID: %d)', [edtNome.Text, FBancaID]);
      FrmPrinc.ShowSuccess('Banca atualizada com sucesso!');
    end
    else
    begin
      // Inserir
      FrmPrinc.ExecSQL(
        'INSERT INTO bancas (nome, sigla, descricao, site, ativo) VALUES (?, ?, ?, ?, ?)',
        [Trim(edtNome.Text), Trim(edtSigla.Text), Trim(memoDescricao.Text),
         Trim(edtSite.Text), Ativo]);

      FrmPrinc.LogInfo('Nova banca cadastrada: %s', [edtNome.Text]);
      FrmPrinc.ShowSuccess('Banca cadastrada com sucesso!');
    end;

    FrmPrinc.Commit;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      FrmPrinc.Rollback;
      FrmPrinc.LogException(E, 'Erro ao salvar banca');
      FrmPrinc.ShowError('Erro ao salvar: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmBancasEdit.btnSalvarClick(Sender: TObject);
begin
  if ValidarDados then
    Salvar;
end;

procedure TFrmBancasEdit.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
