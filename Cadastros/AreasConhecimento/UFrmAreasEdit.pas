unit UFrmAreasEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Math;

type
  TFrmAreasEdit = class(TForm)
    pnlButtons: TPanel;
    btnSalvar: TButton;
    btnCancelar: TButton;
    pnlContent: TPanel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblDescricao: TLabel;
    memoDescricao: TMemo;
    lblCorHex: TLabel;
    edtCorHex: TEdit;
    pnlCorPreview: TPanel;
    btnEscolherCor: TButton;
    ColorDialog1: TColorDialog;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCorHexChange(Sender: TObject);
    procedure btnEscolherCorClick(Sender: TObject);
  private
    FAreaID: Integer;
    procedure CarregarDados;
    function ValidarDados: Boolean;
    procedure Salvar;
    function HexToColor(const HexColor: string): TColor;
    function ColorToHex(Color: TColor): string;
    procedure AtualizarPreviewCor;
  public
    property AreaID: Integer read FAreaID write FAreaID;
  end;

var
  FrmAreasEdit: TFrmAreasEdit;

implementation

{$R *.dfm}

uses UFrmPrinc, FireDAC.Comp.Client;

procedure TFrmAreasEdit.FormShow(Sender: TObject);
begin
  if FAreaID > 0 then
  begin
    Caption := 'Editar Área de Conhecimento';
    CarregarDados;
  end
  else
  begin
    Caption := 'Nova Área de Conhecimento';
    edtCorHex.Text := '#3498db';
  end;

  AtualizarPreviewCor;
  edtNome.SetFocus;
end;

procedure TFrmAreasEdit.CarregarDados;
var
  Query: TFDQuery;
begin
  FrmPrinc.LogDebug('Carregando dados da área ID: %d', [FAreaID]);

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FrmPrinc.FDConnection1;
    Query.SQL.Text := 'SELECT * FROM areas_conhecimento WHERE id = :id';
    Query.ParamByName('id').AsInteger := FAreaID;
    Query.Open;

    if not Query.IsEmpty then
    begin
      edtNome.Text := Query.FieldByName('nome').AsString;
      memoDescricao.Text := Query.FieldByName('descricao').AsString;
      edtCorHex.Text := Query.FieldByName('cor_hex').AsString;
    end;
  finally
    Query.Free;
  end;
end;

function TFrmAreasEdit.HexToColor(const HexColor: string): TColor;
var
  R, G, B: Integer;
  Hex: string;
begin
  try
    // Remove # do início se existir
    Hex := Trim(HexColor);
    if (Length(Hex) > 0) and (Hex[1] = '#') then
      Hex := Copy(Hex, 2, Length(Hex));

    // Validar tamanho
    if Length(Hex) <> 6 then
    begin
      FrmPrinc.LogDebug('Cor hex inválida (tamanho): "%s"', [HexColor]);
      Result := clWhite;
      Exit;
    end;

    // Extrair RGB do formato RRGGBB
    R := StrToInt('$' + Copy(Hex, 1, 2));
    G := StrToInt('$' + Copy(Hex, 3, 2));
    B := StrToInt('$' + Copy(Hex, 5, 2));

    // RGB do Windows já retorna no formato correto para TColor
    Result := RGB(R, G, B);

    FrmPrinc.LogDebug('Cor convertida: %s -> R:%d G:%d B:%d -> TColor:%d',
                      [HexColor, R, G, B, Result]);
  except
    on E: Exception do
    begin
      FrmPrinc.LogDebug('Erro ao converter cor "%s": %s', [HexColor, E.Message]);
      Result := clWhite;
    end;
  end;
end;

function TFrmAreasEdit.ColorToHex(Color: TColor): string;
var
  R, G, B: Byte;
begin
  Color := ColorToRGB(Color);
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  Result := Format('#%.2x%.2x%.2x', [R, G, B]);
end;

procedure TFrmAreasEdit.AtualizarPreviewCor;
var
  Cor: TColor;
begin
  try
    Cor := HexToColor(edtCorHex.Text);
    pnlCorPreview.Color := Cor;
    pnlCorPreview.ParentBackground := False;
    pnlCorPreview.Repaint;
    FrmPrinc.LogDebug('Preview atualizado para cor: %s (TColor: %d)', [edtCorHex.Text, Cor]);
  except
    on E: Exception do
    begin
      pnlCorPreview.Color := clWhite;
      FrmPrinc.LogDebug('Erro ao atualizar preview: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmAreasEdit.edtCorHexChange(Sender: TObject);
begin
  AtualizarPreviewCor;
end;

procedure TFrmAreasEdit.btnEscolherCorClick(Sender: TObject);
begin
  ColorDialog1.Color := HexToColor(edtCorHex.Text);
  if ColorDialog1.Execute then
  begin
    edtCorHex.Text := ColorToHex(ColorDialog1.Color);
    AtualizarPreviewCor;
  end;
end;

function TFrmAreasEdit.ValidarDados: Boolean;
var
  Count: Integer;
  CorTest: TColor;
begin
  Result := False;

  // Validar nome obrigatório
  if Trim(edtNome.Text) = '' then
  begin
    FrmPrinc.ShowWarning('O nome da área é obrigatório');
    edtNome.SetFocus;
    Exit;
  end;

  // Validar cor hex
  if Trim(edtCorHex.Text) = '' then
  begin
    FrmPrinc.ShowWarning('A cor é obrigatória');
    edtCorHex.SetFocus;
    Exit;
  end;

  try
    CorTest := HexToColor(edtCorHex.Text);
  except
    FrmPrinc.ShowWarning('Cor inválida. Use o formato #RRGGBB (ex: #3498db)');
    edtCorHex.SetFocus;
    Exit;
  end;

  // Validar duplicidade de nome
  if FAreaID > 0 then
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM areas_conhecimento WHERE LOWER(nome) = ? AND id <> ?',
      [LowerCase(Trim(edtNome.Text)), FAreaID])
  else
    Count := FrmPrinc.ExecuteScalarInt(
      'SELECT COUNT(*) FROM areas_conhecimento WHERE LOWER(nome) = ?',
      [LowerCase(Trim(edtNome.Text))]);

  if Count > 0 then
  begin
    FrmPrinc.ShowWarning('Já existe uma área cadastrada com este nome');
    edtNome.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TFrmAreasEdit.Salvar;
begin
  FrmPrinc.StartTransaction;
  try
    if FAreaID > 0 then
    begin
      // Atualizar
      FrmPrinc.ExecSQL(
        'UPDATE areas_conhecimento SET nome = ?, descricao = ?, cor_hex = ? WHERE id = ?',
        [Trim(edtNome.Text), Trim(memoDescricao.Text), Trim(edtCorHex.Text), FAreaID]);

      FrmPrinc.LogInfo('Área atualizada: %s (ID: %d)', [edtNome.Text, FAreaID]);
      FrmPrinc.ShowSuccess('Área atualizada com sucesso!');
    end
    else
    begin
      // Inserir
      FrmPrinc.ExecSQL(
        'INSERT INTO areas_conhecimento (nome, descricao, cor_hex) VALUES (?, ?, ?)',
        [Trim(edtNome.Text), Trim(memoDescricao.Text), Trim(edtCorHex.Text)]);

      FrmPrinc.LogInfo('Nova área cadastrada: %s', [edtNome.Text]);
      FrmPrinc.ShowSuccess('Área cadastrada com sucesso!');
    end;

    FrmPrinc.Commit;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      FrmPrinc.Rollback;
      FrmPrinc.LogException(E, 'Erro ao salvar área');
      FrmPrinc.ShowError('Erro ao salvar: %s', [E.Message]);
    end;
  end;
end;

procedure TFrmAreasEdit.btnSalvarClick(Sender: TObject);
begin
  if ValidarDados then
    Salvar;
end;

procedure TFrmAreasEdit.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
