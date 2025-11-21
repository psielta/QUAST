unit UFrmBancasLista;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ExtCtrls, Datasnap.DBClient;

type
  TFrmBancasLista = class(TForm)
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
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtBuscaChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure CarregarDados;
    procedure AbrirCadastro(ABancaID: Integer);
  public
    { Public declarations }
  end;

var
  FrmBancasLista: TFrmBancasLista;

implementation

{$R *.dfm}

uses UFrmPrinc, UFrmBancasEdit;

procedure TFrmBancasLista.FormCreate(Sender: TObject);
begin
  FDQuery1.Connection := FrmPrinc.FDConnection1;
end;

procedure TFrmBancasLista.FormShow(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmBancasLista.CarregarDados;
var
  FiltroSQL: string;
begin
  FrmPrinc.LogDebug('Carregando lista de bancas...');

  FiltroSQL := 'SELECT id, ' +
               'CAST(nome AS VARCHAR(200)) as nome, ' +
               'CAST(sigla AS VARCHAR(50)) as sigla, ' +
               'CAST(SUBSTR(descricao, 1, 100) AS VARCHAR(100)) as descricao_resumo, ' +
               'CAST(site AS VARCHAR(200)) as site, ' +
               'CASE WHEN ativo = 1 THEN ''Sim'' ELSE ''Não'' END as ativo_desc ' +
               'FROM bancas ' +
               'WHERE ativo = 1 ';

  if Trim(edtBusca.Text) <> '' then
    FiltroSQL := FiltroSQL +
                 'AND (LOWER(nome) LIKE ''%' + LowerCase(Trim(edtBusca.Text)) + '%'' ' +
                 'OR LOWER(sigla) LIKE ''%' + LowerCase(Trim(edtBusca.Text)) + '%'') ';

  FiltroSQL := FiltroSQL + 'ORDER BY nome';

  FDQuery1.Close;
  FDQuery1.SQL.Text := FiltroSQL;
  FDQuery1.Open;

  // Configurar títulos e largura das colunas
  if FDQuery1.FieldCount > 0 then
  begin
    DBGrid1.Columns[0].Title.Caption := 'ID';
    DBGrid1.Columns[0].Width := 50;

    DBGrid1.Columns[1].Title.Caption := 'Nome';
    DBGrid1.Columns[1].Width := 250;

    DBGrid1.Columns[2].Title.Caption := 'Sigla';
    DBGrid1.Columns[2].Width := 80;

    DBGrid1.Columns[3].Title.Caption := 'Descrição';
    DBGrid1.Columns[3].Width := 200;

    DBGrid1.Columns[4].Title.Caption := 'Site';
    DBGrid1.Columns[4].Width := 150;

    DBGrid1.Columns[5].Title.Caption := 'Ativo';
    DBGrid1.Columns[5].Width := 60;
  end;

  FrmPrinc.LogInfo('Bancas carregadas: %d registro(s)', [FDQuery1.RecordCount]);
end;

procedure TFrmBancasLista.edtBuscaChange(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmBancasLista.btnNovoClick(Sender: TObject);
begin
  AbrirCadastro(0);
end;

procedure TFrmBancasLista.btnEditarClick(Sender: TObject);
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma banca para editar');
    Exit;
  end;

  AbrirCadastro(FDQuery1.FieldByName('id').AsInteger);
end;

procedure TFrmBancasLista.DBGrid1DblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFrmBancasLista.AbrirCadastro(ABancaID: Integer);
var
  Frm: TFrmBancasEdit;
begin
  Frm := TFrmBancasEdit.Create(Self);
  try
    Frm.BancaID := ABancaID;
    if Frm.ShowModal = mrOk then
      CarregarDados;
  finally
    Frm.Free;
  end;
end;

procedure TFrmBancasLista.btnExcluirClick(Sender: TObject);
var
  BancaID: Integer;
  BancaNome: string;
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma banca para excluir');
    Exit;
  end;

  BancaID := FDQuery1.FieldByName('id').AsInteger;
  BancaNome := FDQuery1.FieldByName('nome').AsString;

  if not FrmPrinc.Confirm('Deseja realmente excluir a banca "%s"?', [BancaNome]) then
    Exit;

  try
    FrmPrinc.StartTransaction;
    try
      FrmPrinc.ExecSQL('UPDATE bancas SET ativo = 0 WHERE id = ?', [BancaID]);
      FrmPrinc.Commit;

      FrmPrinc.ShowSuccess('Banca excluída com sucesso!');
      FrmPrinc.LogInfo('Banca excluída: %s (ID: %d)', [BancaNome, BancaID]);

      CarregarDados;
    except
      FrmPrinc.Rollback;
      raise;
    end;
  except
    on E: Exception do
    begin
      FrmPrinc.LogException(E, 'Erro ao excluir banca');
      FrmPrinc.ShowError('Erro ao excluir banca: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmBancasLista.btnAtualizarClick(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmBancasLista.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
