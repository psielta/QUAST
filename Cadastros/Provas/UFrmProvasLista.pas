unit UFrmProvasLista;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.ExtCtrls;

type
  TFrmProvasLista = class(TForm)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    edtBusca: TEdit;
    lblBusca: TLabel;
    lblFiltroBanca: TLabel;
    cmbFiltroBanca: TComboBox;
    lblFiltroArea: TLabel;
    cmbFiltroArea: TComboBox;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;
    btnAtualizar: TButton;
    btnFechar: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    FDQuery1: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject); overload;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtBuscaChange(Sender: TObject);
    procedure cmbFiltroBancaChange(Sender: TObject);
    procedure cmbFiltroAreaChange(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);
  procedure FormResize(Sender: TObject);
  private
    procedure CarregarDados;
    procedure AbrirCadastro(AProvaID: Integer);
    procedure CarregarFiltros;
    function HexToColor(const HexColor: string): TColor;
    procedure ReposicionarBotaoFechar;
  public
    { Public declarations }
  end;

var
  FrmProvasLista: TFrmProvasLista;

implementation

{$R *.dfm}

uses UFrmPrinc, UFrmProvasEdit;

procedure TFrmProvasLista.FormCreate(Sender: TObject);
begin
  FDQuery1.Connection := FrmPrinc.FDConnection1;
end;

procedure TFrmProvasLista.FormShow(Sender: TObject);
var
  DesiredWidth, DesiredHeight: Integer;
begin
  // Tamanho inicial proporcional (apenas na abertura)
  DesiredWidth := Round(Screen.Width * 0.85);
  DesiredHeight := Round(Screen.Height * 0.75);
  SetBounds((Screen.Width - DesiredWidth) div 2,
            (Screen.Height - DesiredHeight) div 2,
            DesiredWidth, DesiredHeight);

  CarregarFiltros;
  CarregarDados;
  ReposicionarBotaoFechar;
end;

procedure TFrmProvasLista.CarregarDados;
var
  FiltroSQL: string;
  Busca: string;
  FiltroBanca, FiltroArea: string;
begin
  FrmPrinc.LogDebug('Carregando lista de provas...');

  Busca := Trim(edtBusca.Text);
  FiltroBanca := '';
  FiltroArea := '';

  if (cmbFiltroBanca.ItemIndex > 0) then
    FiltroBanca := Format('AND p.banca_id = %d ', [Integer(cmbFiltroBanca.Items.Objects[cmbFiltroBanca.ItemIndex])]);

  if (cmbFiltroArea.ItemIndex > 0) then
    FiltroArea := Format('AND p.area_conhecimento_id = %d ', [Integer(cmbFiltroArea.Items.Objects[cmbFiltroArea.ItemIndex])]);

  FiltroSQL := 'SELECT p.id, ' +
               'CAST(p.titulo AS VARCHAR(200)) as titulo, ' +
               'CAST(IFNULL(b.nome, ''-'' ) AS VARCHAR(200)) as banca, ' +
               'p.ano, ' +
               'CAST(IFNULL(a.nome, ''-'' ) AS VARCHAR(200)) as area, ' +
               'CAST(IFNULL(a.cor_hex, ''#ffffff'') AS VARCHAR(7)) as area_cor, ' +
               'CAST(p.nivel AS VARCHAR(50)) as nivel, ' +
               'CAST(p.tipo AS VARCHAR(50)) as tipo, ' +
               'CAST(IFNULL(p.cargo, '''') AS VARCHAR(200)) as cargo, ' +
               'p.numero_questoes, ' +
               'p.dificuldade, ' +
               'p.data_aplicacao ' +
               'FROM provas p ' +
               'LEFT JOIN bancas b ON p.banca_id = b.id ' +
               'LEFT JOIN areas_conhecimento a ON p.area_conhecimento_id = a.id ' +
               'WHERE p.ativo = 1 ';

  if Busca <> '' then
    FiltroSQL := FiltroSQL +
      'AND (LOWER(p.titulo) LIKE ''%' + LowerCase(Busca) + '%'' ' +
      'OR LOWER(IFNULL(b.nome, '''')) LIKE ''%' + LowerCase(Busca) + '%'' ' +
      'OR LOWER(IFNULL(a.nome, '''')) LIKE ''%' + LowerCase(Busca) + '%'' ' +
      'OR LOWER(IFNULL(p.cargo, '''')) LIKE ''%' + LowerCase(Busca) + '%'') ';

  FiltroSQL := FiltroSQL + FiltroBanca + FiltroArea;

  FiltroSQL := FiltroSQL + 'ORDER BY p.ano DESC, p.titulo';

  FDQuery1.Close;
  FDQuery1.SQL.Text := FiltroSQL;
  FDQuery1.Open;

  if FDQuery1.FieldCount > 0 then
  begin
    DBGrid1.Columns[0].Title.Caption := 'ID';
    DBGrid1.Columns[0].Width := 50;

    DBGrid1.Columns[1].Title.Caption := 'T'#237'tulo';
    DBGrid1.Columns[1].Width := 260;

    DBGrid1.Columns[2].Title.Caption := 'Banca';
    DBGrid1.Columns[2].Width := 140;

    DBGrid1.Columns[3].Title.Caption := 'Ano';
    DBGrid1.Columns[3].Width := 60;

    DBGrid1.Columns[4].Title.Caption := #193'rea';
    DBGrid1.Columns[4].Width := 140;

    // coluna area_cor fica oculta (só para colorir)
    DBGrid1.Columns[5].Visible := False;

    DBGrid1.Columns[6].Title.Caption := 'N'#237'vel';
    DBGrid1.Columns[6].Width := 100;

    DBGrid1.Columns[7].Title.Caption := 'Tipo';
    DBGrid1.Columns[7].Width := 100;

    DBGrid1.Columns[8].Title.Caption := 'Cargo';
    DBGrid1.Columns[8].Width := 140;

    DBGrid1.Columns[9].Title.Caption := 'Quest'#245'es';
    DBGrid1.Columns[9].Width := 70;

    DBGrid1.Columns[10].Title.Caption := 'Dif.';
    DBGrid1.Columns[10].Width := 50;

    DBGrid1.Columns[11].Title.Caption := 'Data aplica'#231#227'o';
    DBGrid1.Columns[11].Width := 110;
  end;

  FrmPrinc.LogInfo('Provas carregadas: %d registro(s)', [FDQuery1.RecordCount]);
end;

procedure TFrmProvasLista.edtBuscaChange(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmProvasLista.cmbFiltroAreaChange(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmProvasLista.cmbFiltroBancaChange(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmProvasLista.btnNovoClick(Sender: TObject);
begin
  AbrirCadastro(0);
end;

procedure TFrmProvasLista.btnEditarClick(Sender: TObject);
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma prova para editar');
    Exit;
  end;

  AbrirCadastro(FDQuery1.FieldByName('id').AsInteger);
end;

procedure TFrmProvasLista.DBGrid1DblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFrmProvasLista.AbrirCadastro(AProvaID: Integer);
var
  Frm: TFrmProvasEdit;
begin
  Frm := TFrmProvasEdit.Create(Self);
  try
    Frm.ProvaID := AProvaID;
    if Frm.ShowModal = mrOk then
      CarregarDados;
  finally
    Frm.Free;
  end;
end;

procedure TFrmProvasLista.btnExcluirClick(Sender: TObject);
var
  ProvaID: Integer;
  ProvaTitulo: string;
begin
  if FDQuery1.IsEmpty then
  begin
    FrmPrinc.ShowWarning('Selecione uma prova para excluir');
    Exit;
  end;

  ProvaID := FDQuery1.FieldByName('id').AsInteger;
  ProvaTitulo := FDQuery1.FieldByName('titulo').AsString;

  if not FrmPrinc.Confirm('Deseja realmente excluir a prova "%s"?', [ProvaTitulo]) then
    Exit;

  try
    FrmPrinc.StartTransaction;
    try
      FrmPrinc.ExecSQL('UPDATE provas SET ativo = 0, atualizado_em = CURRENT_TIMESTAMP WHERE id = ?',
        [ProvaID]);
      FrmPrinc.Commit;

      FrmPrinc.ShowSuccess('Prova exclu'#237'da com sucesso!');
      FrmPrinc.LogInfo('Prova exclu'#237'da: %s (ID: %d)', [ProvaTitulo, ProvaID]);

      CarregarDados;
    except
      FrmPrinc.Rollback;
      raise;
    end;
  except
    on E: Exception do
    begin
      FrmPrinc.LogException(E, 'Erro ao excluir prova');
      FrmPrinc.ShowError('Erro ao excluir prova: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmProvasLista.btnAtualizarClick(Sender: TObject);
begin
  CarregarDados;
end;

procedure TFrmProvasLista.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmProvasLista.FormResize(Sender: TObject);
begin
  ReposicionarBotaoFechar;
end;

function TFrmProvasLista.HexToColor(const HexColor: string): TColor;
var
  R, G, B: Integer;
  Hex: string;
begin
  try
    Hex := Trim(HexColor);
    if (Length(Hex) > 0) and (Hex[1] = '#') then
      Hex := Copy(Hex, 2, Length(Hex));

    if Length(Hex) <> 6 then
      Exit(clWhite);

    R := StrToInt('$' + Copy(Hex, 1, 2));
    G := StrToInt('$' + Copy(Hex, 3, 2));
    B := StrToInt('$' + Copy(Hex, 5, 2));

    Result := RGB(R, G, B);
  except
    Result := clWhite;
  end;
end;

procedure TFrmProvasLista.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  CorHex: string;
  Cor: TColor;
  TextColor: TColor;
  R: TRect;
begin
  if FDQuery1.IsEmpty then
  begin
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    Exit;
  end;

  if (Column.FieldName = 'area') then
  begin
    CorHex := FDQuery1.FieldByName('area_cor').AsString;
    if Trim(FDQuery1.FieldByName('area').AsString) = '' then
      Cor := clWhite
    else
      Cor := HexToColor(CorHex);

    // Base: sempre cor da área (mesmo selecionado, para manter identificação)
    DBGrid1.Canvas.Brush.Color := Cor;
    DBGrid1.Canvas.FillRect(Rect);

    // Contraste de texto
    if (GetRValue(Cor) * 0.299 + GetGValue(Cor) * 0.587 + GetBValue(Cor) * 0.114) > 128 then
      TextColor := clBlack
    else
      TextColor := clWhite;

    DBGrid1.Canvas.Font.Color := TextColor;
    DBGrid1.Canvas.Font.Style := [fsBold];

    R := Rect;
    InflateRect(R, -4, 0);
    Winapi.Windows.DrawText(DBGrid1.Canvas.Handle, PChar(Column.Field.AsString), -1, R,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  end
  else
  begin
    DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TFrmProvasLista.CarregarFiltros;
var
  Q: TFDQuery;
begin
  // Banca
  cmbFiltroBanca.Items.Clear;
  cmbFiltroBanca.Items.AddObject('Todas as bancas', TObject(0));

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    Q.SQL.Text := 'SELECT id, nome FROM bancas WHERE ativo = 1 ORDER BY nome';
    Q.Open;
    while not Q.Eof do
    begin
      cmbFiltroBanca.Items.AddObject(Q.FieldByName('nome').AsString,
        TObject(Q.FieldByName('id').AsInteger));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  cmbFiltroBanca.ItemIndex := 0;

  // Área
  cmbFiltroArea.Items.Clear;
  cmbFiltroArea.Items.AddObject('Todas as áreas', TObject(0));
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    Q.SQL.Text := 'SELECT id, nome FROM areas_conhecimento ORDER BY nome';
    Q.Open;
    while not Q.Eof do
    begin
      cmbFiltroArea.Items.AddObject(Q.FieldByName('nome').AsString,
        TObject(Q.FieldByName('id').AsInteger));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  cmbFiltroArea.ItemIndex := 0;
end;

procedure TFrmProvasLista.ReposicionarBotaoFechar;
begin
  // Botão Fechar alinhado à direita
  if Assigned(btnFechar) and Assigned(pnlBottom) then
    btnFechar.Left := pnlBottom.Width - btnFechar.Width - 16;
end;

end.
