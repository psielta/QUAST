unit UFrmUsuariosLista;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ExtCtrls;

type
  TFrmUsuariosLista = class(TForm)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    edtBusca: TEdit;
    lblBusca: TLabel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;
    btnAtualizar: TButton;
    btnFechar: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    FDQuery1: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtBuscaChange(Sender: TObject);
  private
    procedure CarregarDados;
    procedure AbrirCadastro(AUsuarioID: Integer);
  public
    { Public declarations }
  end;

var
  FrmUsuariosLista: TFrmUsuariosLista;

implementation

{$R *.dfm}

uses UFrmPrinc, UFrmUsuariosEdit;

procedure TFrmUsuariosLista.FormCreate(Sender: TObject);
begin
  FDQuery1.Connection := FrmPrinc.FDConnection1;
end;

procedure TFrmUsuariosLista.FormShow(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmUsuariosLista.CarregarDados;
var
  FiltroSQL: string;
begin
  FrmPrinc.LogDebug('Carregando lista de usuários...');

  FiltroSQL := 'SELECT id, CAST(nome AS VARCHAR(255)) AS nome, CAST(email AS VARCHAR(255)) AS email, ativo, criado_em FROM usuarios WHERE 1=1 ';

  if Trim(edtBusca.Text) <> '' then
    FiltroSQL := FiltroSQL +
      'AND (LOWER(nome) LIKE ''%' + LowerCase(Trim(edtBusca.Text)) +
      '%'' OR LOWER(email) LIKE ''%' + LowerCase(Trim(edtBusca.Text)) + '%'') ';

  FiltroSQL := FiltroSQL + 'ORDER BY nome';

  FDQuery1.Close;
  FDQuery1.SQL.Text := FiltroSQL;
  FDQuery1.Open;

  if FDQuery1.FieldCount > 0 then
  begin
    DBGrid1.Columns[0].Title.Caption := 'ID';
    DBGrid1.Columns[0].Width := 50;

    DBGrid1.Columns[1].Title.Caption := 'Nome';
    DBGrid1.Columns[1].Width := 200;

    DBGrid1.Columns[2].Title.Caption := 'Email';
    DBGrid1.Columns[2].Width := 200;

    DBGrid1.Columns[3].Title.Caption := 'Ativo';
    DBGrid1.Columns[3].Width := 50;

    DBGrid1.Columns[4].Title.Caption := 'Criado em';
    DBGrid1.Columns[4].Width := 120;
  end;

  FrmPrinc.LogInfo('Usuários carregados: %d registro(s)', [FDQuery1.RecordCount]);
end;

procedure TFrmUsuariosLista.edtBuscaChange(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmUsuariosLista.DBGrid1DblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFrmUsuariosLista.AbrirCadastro(AUsuarioID: Integer);
var
  Frm: TFrmUsuariosEdit;
begin
  Frm := TFrmUsuariosEdit.Create(Self);
  try
    Frm.UsuarioID := AUsuarioID;
    if Frm.ShowModal = mrOk then
      CarregarDados;
  finally
    Frm.Free;
  end;
end;

procedure TFrmUsuariosLista.btnNovoClick(Sender: TObject);
begin
  AbrirCadastro(0);
end;

procedure TFrmUsuariosLista.btnEditarClick(Sender: TObject);
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione um usuário para editar');
    Exit;
  end;

  AbrirCadastro(FDQuery1.FieldByName('id').AsInteger);
end;

procedure TFrmUsuariosLista.btnExcluirClick(Sender: TObject);
var
  UsuarioID: Integer;
  Nome: string;
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione um usuário para excluir');
    Exit;
  end;

  UsuarioID := FDQuery1.FieldByName('id').AsInteger;
  Nome := FDQuery1.FieldByName('nome').AsString;

  if not FrmPrinc.Confirm('Deseja realmente excluir o usuário "%s"?', [Nome]) then
    Exit;

  try
    FrmPrinc.StartTransaction;
    try
      FrmPrinc.ExecSQL('DELETE FROM usuarios WHERE id = ?', [UsuarioID]);
      FrmPrinc.Commit;

      FrmPrinc.ShowSuccess('Usuário excluído com sucesso!');
      FrmPrinc.LogInfo('Usuário excluído: %s (ID: %d)', [Nome, UsuarioID]);

      CarregarDados;
    except
      FrmPrinc.Rollback;
      raise;
    end;
  except
    on E: Exception do
    begin
      FrmPrinc.LogException(E, 'Erro ao excluir usuário');
      FrmPrinc.ShowError('Erro ao excluir usuário: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmUsuariosLista.btnAtualizarClick(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmUsuariosLista.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

