unit UFrmAreasLista;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ExtCtrls, Datasnap.DBClient;

type
  TFrmAreasLista = class(TForm)
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
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    procedure CarregarDados;
    procedure AbrirCadastro(AAreaID: Integer);
    function HexToColor(const HexColor: string): TColor;
  public
    { Public declarations }
  end;

var
  FrmAreasLista: TFrmAreasLista;

implementation

{$R *.dfm}

uses UFrmPrinc, UFrmAreasEdit;

procedure TFrmAreasLista.FormCreate(Sender: TObject);
begin
  FDQuery1.Connection := FrmPrinc.FDConnection1;
end;

procedure TFrmAreasLista.FormShow(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmAreasLista.CarregarDados;
var
  FiltroSQL: string;
begin
  FrmPrinc.LogDebug('Carregando lista de áreas de conhecimento...');

  FiltroSQL := 'SELECT id, ' +
               'CAST(nome AS VARCHAR(200)) as nome, ' +
               'CAST(SUBSTR(descricao, 1, 100) AS VARCHAR(100)) as descricao_resumo, ' +
               'CAST(cor_hex AS VARCHAR(7)) as cor_hex ' +
               'FROM areas_conhecimento ' +
               'WHERE 1=1 ';

  if Trim(edtBusca.Text) <> '' then
    FiltroSQL := FiltroSQL +
                 'AND LOWER(nome) LIKE ''%' + LowerCase(Trim(edtBusca.Text)) + '%'' ';

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

    DBGrid1.Columns[2].Title.Caption := 'Descrição';
    DBGrid1.Columns[2].Width := 300;

    DBGrid1.Columns[3].Title.Caption := 'Cor';
    DBGrid1.Columns[3].Width := 150;
  end;

  FrmPrinc.LogInfo('Áreas de conhecimento carregadas: %d registro(s)', [FDQuery1.RecordCount]);
end;

procedure TFrmAreasLista.edtBuscaChange(Sender: TObject);
begin
  CarregarDados;
end;

function TFrmAreasLista.HexToColor(const HexColor: string): TColor;
var
  R, G, B: Integer;
  Hex: string;
begin
  try
    // Remove # do início se existir
    if (Length(HexColor) > 0) and (HexColor[1] = '#') then
      Hex := Copy(HexColor, 2, Length(HexColor))
    else
      Hex := HexColor;

    // Extrair RGB do formato RRGGBB
    R := StrToInt('$' + Copy(Hex, 1, 2));
    G := StrToInt('$' + Copy(Hex, 3, 2));
    B := StrToInt('$' + Copy(Hex, 5, 2));

    // Delphi usa BGR, então inverter
    Result := RGB(R, G, B);
  except
    on E: Exception do
    begin
      FrmPrinc.LogDebug('Erro ao converter cor "%s": %s', [HexColor, E.Message]);
      Result := clWhite;
    end;
  end;
end;

procedure TFrmAreasLista.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  CorHex: string;
  Cor: TColor;
  TextColor: TColor;
begin
  // Desenhar célula padrão primeiro
  DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);

  // Se for a coluna de cor, sobrescrever com a cor
  if (Column.FieldName = 'cor_hex') and not FDQuery1.IsEmpty then
  begin
    CorHex := FDQuery1.FieldByName('cor_hex').AsString;

    if Trim(CorHex) <> '' then
    begin
      Cor := HexToColor(CorHex);

      // Preencher com a cor
      DBGrid1.Canvas.Brush.Color := Cor;
      DBGrid1.Canvas.FillRect(Rect);

      // Determinar cor do texto para contraste
      if (GetRValue(Cor) * 0.299 + GetGValue(Cor) * 0.587 + GetBValue(Cor) * 0.114) > 128 then
        TextColor := clBlack
      else
        TextColor := clWhite;

      DBGrid1.Canvas.Font.Color := TextColor;
      DBGrid1.Canvas.Font.Style := [fsBold];

      // Desenhar texto centralizado
      var R: TRect := Rect;
      Winapi.Windows.DrawText(DBGrid1.Canvas.Handle, PChar(CorHex), -1, R,
                              DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;
  end;
end;

procedure TFrmAreasLista.btnNovoClick(Sender: TObject);
begin
  AbrirCadastro(0);
end;

procedure TFrmAreasLista.btnEditarClick(Sender: TObject);
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma área para editar');
    Exit;
  end;

  AbrirCadastro(FDQuery1.FieldByName('id').AsInteger);
end;

procedure TFrmAreasLista.DBGrid1DblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFrmAreasLista.AbrirCadastro(AAreaID: Integer);
var
  Frm: TFrmAreasEdit;
begin
  Frm := TFrmAreasEdit.Create(Self);
  try
    Frm.AreaID := AAreaID;
    if Frm.ShowModal = mrOk then
      CarregarDados;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAreasLista.btnExcluirClick(Sender: TObject);
var
  AreaID: Integer;
  AreaNome: string;
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma área para excluir');
    Exit;
  end;

  AreaID := FDQuery1.FieldByName('id').AsInteger;
  AreaNome := FDQuery1.FieldByName('nome').AsString;

  if not FrmPrinc.Confirm('Deseja realmente excluir a área "%s"?', [AreaNome]) then
    Exit;

  try
    FrmPrinc.StartTransaction;
    try
      FrmPrinc.ExecSQL('DELETE FROM areas_conhecimento WHERE id = ?', [AreaID]);
      FrmPrinc.Commit;

      FrmPrinc.ShowSuccess('Área excluída com sucesso!');
      FrmPrinc.LogInfo('Área excluída: %s (ID: %d)', [AreaNome, AreaID]);

      CarregarDados;
    except
      FrmPrinc.Rollback;
      raise;
    end;
  except
    on E: Exception do
    begin
      FrmPrinc.LogException(E, 'Erro ao excluir área');
      FrmPrinc.ShowError('Erro ao excluir área: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmAreasLista.btnAtualizarClick(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmAreasLista.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
