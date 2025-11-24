unit UFrmProvasEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.Math, System.DateUtils, Data.DB, FireDAC.Stan.Param;

type
  TFrmProvasEdit = class(TForm)
    pnlButtons: TPanel;
    btnSalvar: TButton;
    btnCancelar: TButton;
    pnlContent: TPanel;
    lblTitulo: TLabel;
    edtTitulo: TEdit;
    lblBanca: TLabel;
    cmbBanca: TComboBox;
    lblArea: TLabel;
    cmbArea: TComboBox;
    lblAno: TLabel;
    edtAno: TEdit;
    lblNivel: TLabel;
    cmbNivel: TComboBox;
    lblTipo: TLabel;
    cmbTipo: TComboBox;
    lblCargo: TLabel;
    edtCargo: TEdit;
    lblDuracao: TLabel;
    edtDuracao: TEdit;
    lblDataAplicacao: TLabel;
    dtpDataAplicacao: TDateTimePicker;
    lblNumQuestoes: TLabel;
    edtNumQuestoes: TEdit;
    lblDificuldade: TLabel;
    cmbDificuldade: TComboBox;
    lblObservacoes: TLabel;
    memoObservacoes: TMemo;
    lblArquivoPdf: TLabel;
    edtPdfPath: TEdit;
    btnSelecionarPdf: TButton;
    OpenDialog1: TOpenDialog;
    chkAtivo: TCheckBox;
    pnlCorArea: TPanel;
    procedure FormShow(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnSelecionarPdfClick(Sender: TObject);
    procedure cmbAreaChange(Sender: TObject);
  private
    FProvaID: Integer;
    procedure CarregarCombos;
    procedure CarregarDados;
    function ValidarDados: Boolean;
    procedure Salvar;
    function ComboSelecionadoID(ACombo: TComboBox): Integer;
    procedure SelecionarComboPorID(ACombo: TComboBox; AID: Integer);
    procedure AtualizarCorArea;
    function HexToColor(const HexColor: string): TColor;
  public
    property ProvaID: Integer read FProvaID write FProvaID;
  end;

var
  FrmProvasEdit: TFrmProvasEdit;

implementation

{$R *.dfm}

uses UFrmPrinc, FireDAC.Comp.Client;

const
  NIVEL_OPCOES: array[0..5] of string = ('Fundamental', 'Médio', 'Superior',
    'Pós-Graduação', 'Concurso', 'Outro');
  TIPO_OPCOES: array[0..5] of string = ('ENEM', 'Vestibular', 'Concurso',
    'Simulado', 'Prova Escolar', 'Outro');

procedure TFrmProvasEdit.FormShow(Sender: TObject);
begin
  CarregarCombos;

  if FProvaID > 0 then
  begin
    Caption := 'Editar Prova';
    CarregarDados;
  end
  else
  begin
    Caption := 'Nova Prova';
    edtAno.Text := IntToStr(YearOf(Date));
    cmbNivel.ItemIndex := cmbNivel.Items.IndexOf('Concurso');
    cmbTipo.ItemIndex := cmbTipo.Items.IndexOf('Concurso');
    cmbDificuldade.ItemIndex := 2; // default dificuldade 3
    chkAtivo.Checked := True;
    dtpDataAplicacao.Checked := False;
  end;

  AtualizarCorArea;
  edtTitulo.SetFocus;
end;

procedure TFrmProvasEdit.CarregarCombos;
var
  Q: TFDQuery;
  CorPadrao: string;
begin
  // Bancas
  cmbBanca.Items.Clear;
  cmbBanca.Items.AddObject('Selecione...', TObject(0));

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    Q.SQL.Text := 'SELECT id, nome FROM bancas WHERE ativo = 1 ORDER BY nome';
    Q.Open;
    while not Q.Eof do
    begin
      cmbBanca.Items.AddObject(Q.FieldByName('nome').AsString,
        TObject(Q.FieldByName('id').AsInteger));
      Q.Next;
    end;
  finally
    Q.Free;
  end;

  // Áreas de conhecimento
  cmbArea.Items.Clear;
  cmbArea.Items.AddObject('Selecione...', TObject(0));
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    Q.SQL.Text := 'SELECT id, nome FROM areas_conhecimento ORDER BY nome';
    Q.Open;
    while not Q.Eof do
    begin
      cmbArea.Items.AddObject(Q.FieldByName('nome').AsString,
        TObject(Q.FieldByName('id').AsInteger));
      Q.Next;
    end;
  finally
    Q.Free;
  end;

  // Cor inicial (quando vazio, branca)
  CorPadrao := '#ffffff';
  pnlCorArea.ParentBackground := False;
  pnlCorArea.ParentColor := False;
  pnlCorArea.StyleElements := [];
  pnlCorArea.Color := HexToColor(CorPadrao);

  // Nível
  cmbNivel.Items.Clear;
  cmbNivel.Items.AddStrings(NIVEL_OPCOES);
  cmbNivel.Style := csDropDownList;

  // Tipo
  cmbTipo.Items.Clear;
  cmbTipo.Items.AddStrings(TIPO_OPCOES);
  cmbTipo.Style := csDropDownList;

  // Dificuldade
  cmbDificuldade.Items.Clear;
  cmbDificuldade.Items.AddStrings(['1', '2', '3', '4', '5']);
  cmbDificuldade.Style := csDropDownList;
end;

procedure TFrmProvasEdit.CarregarDados;
var
  Q: TFDQuery;
begin
  FrmPrinc.LogDebug('Carregando dados da prova ID: %d', [FProvaID]);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    Q.SQL.Text := 'SELECT * FROM provas WHERE id = :id';
    Q.ParamByName('id').AsInteger := FProvaID;
    Q.Open;

    if not Q.IsEmpty then
    begin
      edtTitulo.Text := Q.FieldByName('titulo').AsString;
      SelecionarComboPorID(cmbBanca, Q.FieldByName('banca_id').AsInteger);
      SelecionarComboPorID(cmbArea, Q.FieldByName('area_conhecimento_id').AsInteger);
      edtAno.Text := Q.FieldByName('ano').AsString;
      cmbNivel.ItemIndex := cmbNivel.Items.IndexOf(Q.FieldByName('nivel').AsString);
      cmbTipo.ItemIndex := cmbTipo.Items.IndexOf(Q.FieldByName('tipo').AsString);
      edtCargo.Text := Q.FieldByName('cargo').AsString;
      edtDuracao.Text := Q.FieldByName('duracao_minutos').AsString;
      if not Q.FieldByName('data_aplicacao').IsNull then
      begin
        dtpDataAplicacao.Checked := True;
        dtpDataAplicacao.Date := Q.FieldByName('data_aplicacao').AsDateTime;
      end
      else
        dtpDataAplicacao.Checked := False;

      edtNumQuestoes.Text := Q.FieldByName('numero_questoes').AsString;
      cmbDificuldade.ItemIndex := IfThen(Q.FieldByName('dificuldade').IsNull, 2,
        Q.FieldByName('dificuldade').AsInteger - 1);
      memoObservacoes.Text := Q.FieldByName('observacoes').AsString;
      edtPdfPath.Text := Q.FieldByName('arquivo_pdf').AsString;
      chkAtivo.Checked := Q.FieldByName('ativo').AsInteger = 1;

      AtualizarCorArea;
    end;
  finally
    Q.Free;
  end;
end;

function TFrmProvasEdit.ComboSelecionadoID(ACombo: TComboBox): Integer;
begin
  if (ACombo.ItemIndex <= 0) or (ACombo.ItemIndex >= ACombo.Items.Count) then
    Exit(0);

  Result := Integer(ACombo.Items.Objects[ACombo.ItemIndex]);
end;

function TFrmProvasEdit.HexToColor(const HexColor: string): TColor;
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

procedure TFrmProvasEdit.AtualizarCorArea;
var
  CorHex: string;
begin
  if ComboSelecionadoID(cmbArea) > 0 then
    CorHex := FrmPrinc.ExecuteScalarStr('SELECT cor_hex FROM areas_conhecimento WHERE id = ?', [ComboSelecionadoID(cmbArea)])
  else
    CorHex := '#ffffff';

  pnlCorArea.ParentBackground := False;
  pnlCorArea.ParentColor := False;
  pnlCorArea.StyleElements := [];
  pnlCorArea.Color := HexToColor(CorHex);
  pnlCorArea.Repaint;
end;

procedure TFrmProvasEdit.SelecionarComboPorID(ACombo: TComboBox; AID: Integer);
var
  I: Integer;
begin
  for I := 0 to ACombo.Items.Count - 1 do
  begin
    if Integer(ACombo.Items.Objects[I]) = AID then
    begin
      ACombo.ItemIndex := I;
      Exit;
    end;
  end;
end;

function TFrmProvasEdit.ValidarDados: Boolean;
var
  Ano, Duracao, NumQuestoes, Dificuldade: Integer;
  Arquivo: string;
begin
  Result := False;

  if Trim(edtTitulo.Text) = '' then
  begin
    FrmPrinc.ShowWarning('O t'#237'tulo da prova '#233' obrigat'#243'rio');
    edtTitulo.SetFocus;
    Exit;
  end;

  if not TryStrToInt(Trim(edtAno.Text), Ano) or (Ano < 1900) or (Ano > 2100) then
  begin
    FrmPrinc.ShowWarning('Informe um ano v'#225'lido (entre 1900 e 2100)');
    edtAno.SetFocus;
    Exit;
  end;

  if cmbNivel.ItemIndex < 0 then
  begin
    FrmPrinc.ShowWarning('Selecione o n'#237'vel da prova');
    cmbNivel.SetFocus;
    Exit;
  end;

  if cmbTipo.ItemIndex < 0 then
  begin
    FrmPrinc.ShowWarning('Selecione o tipo da prova');
    cmbTipo.SetFocus;
    Exit;
  end;

  if (Trim(edtDuracao.Text) <> '') and (not TryStrToInt(Trim(edtDuracao.Text), Duracao) or (Duracao < 0)) then
  begin
    FrmPrinc.ShowWarning('Dura'#231#227'o deve ser um n'#250'mero inteiro maior ou igual a zero');
    edtDuracao.SetFocus;
    Exit;
  end;

  if (Trim(edtNumQuestoes.Text) <> '') and
     (not TryStrToInt(Trim(edtNumQuestoes.Text), NumQuestoes) or (NumQuestoes < 0)) then
  begin
    FrmPrinc.ShowWarning('N'#250'mero de quest'#245'es deve ser um inteiro maior ou igual a zero');
    edtNumQuestoes.SetFocus;
    Exit;
  end;

  if cmbDificuldade.ItemIndex < 0 then
  begin
    FrmPrinc.ShowWarning('Selecione a dificuldade (1 a 5)');
    cmbDificuldade.SetFocus;
    Exit;
  end;

  Arquivo := Trim(edtPdfPath.Text);
  if (Arquivo <> '') then
  begin
    if not FileExists(Arquivo) then
    begin
      FrmPrinc.ShowWarning('O arquivo PDF informado n'#227'o foi encontrado');
      edtPdfPath.SetFocus;
      Exit;
    end;

    if not SameText(ExtractFileExt(Arquivo), '.pdf') then
    begin
      FrmPrinc.ShowWarning('Selecione um arquivo PDF v'#225'lido (*.pdf)');
      edtPdfPath.SetFocus;
      Exit;
    end;
  end;

  Result := True;
end;

procedure TFrmProvasEdit.Salvar;
var
  Ano, Duracao, NumQuestoes, Dificuldade: Integer;
  BancaID, AreaID: Integer;
  TemBanca, TemArea: Boolean;
  Arquivo: string;
  Ativo: Integer;
  Q: TFDQuery;
begin
  Ano := StrToIntDef(Trim(edtAno.Text), YearOf(Date));
  Duracao := StrToIntDef(Trim(edtDuracao.Text), -1);
  NumQuestoes := StrToIntDef(Trim(edtNumQuestoes.Text), -1);
  Dificuldade := cmbDificuldade.ItemIndex + 1;
  Arquivo := Trim(edtPdfPath.Text);
  Ativo := IfThen(chkAtivo.Checked, 1, 0);

  TemBanca := ComboSelecionadoID(cmbBanca) <> 0;
  BancaID := ComboSelecionadoID(cmbBanca);

  TemArea := ComboSelecionadoID(cmbArea) <> 0;
  AreaID := ComboSelecionadoID(cmbArea);

  if Duracao < 0 then
    Duracao := 0;

  if NumQuestoes < 0 then
    NumQuestoes := 0;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FrmPrinc.FDConnection1;
    FrmPrinc.StartTransaction;
    try
      if FProvaID > 0 then
      begin
        Q.SQL.Text :=
          'UPDATE provas SET titulo = :titulo, banca_id = :banca_id, ano = :ano, area_conhecimento_id = :area_id, ' +
          'nivel = :nivel, tipo = :tipo, cargo = :cargo, duracao_minutos = :duracao, data_aplicacao = :data_aplicacao, ' +
          'numero_questoes = :num_q, observacoes = :obs, dificuldade = :dif, arquivo_pdf = :pdf, ativo = :ativo, ' +
          'atualizado_em = CURRENT_TIMESTAMP WHERE id = :id';
        Q.ParamByName('id').AsInteger := FProvaID;
      end
      else
      begin
        Q.SQL.Text :=
          'INSERT INTO provas (titulo, banca_id, ano, area_conhecimento_id, nivel, tipo, cargo, duracao_minutos, ' +
          'data_aplicacao, numero_questoes, observacoes, dificuldade, arquivo_pdf, ativo) ' +
          'VALUES (:titulo, :banca_id, :ano, :area_id, :nivel, :tipo, :cargo, :duracao, :data_aplicacao, :num_q, :obs, :dif, :pdf, :ativo)';
      end;

      Q.ParamByName('titulo').AsString := Trim(edtTitulo.Text);

      Q.ParamByName('banca_id').DataType := ftInteger;
      if TemBanca then
        Q.ParamByName('banca_id').AsInteger := BancaID
      else
        Q.ParamByName('banca_id').Clear;

      Q.ParamByName('ano').AsInteger := Ano;

      Q.ParamByName('area_id').DataType := ftInteger;
      if TemArea then
        Q.ParamByName('area_id').AsInteger := AreaID
      else
        Q.ParamByName('area_id').Clear;

      Q.ParamByName('nivel').AsString := cmbNivel.Text;
      Q.ParamByName('tipo').AsString := cmbTipo.Text;
      Q.ParamByName('cargo').AsString := Trim(edtCargo.Text);
      Q.ParamByName('duracao').AsInteger := Duracao;

      Q.ParamByName('data_aplicacao').DataType := ftDate;
      if dtpDataAplicacao.Checked then
        Q.ParamByName('data_aplicacao').AsDate := dtpDataAplicacao.Date
      else
        Q.ParamByName('data_aplicacao').Clear;

      Q.ParamByName('num_q').AsInteger := NumQuestoes;
      Q.ParamByName('obs').AsString := Trim(memoObservacoes.Text);
      Q.ParamByName('dif').AsInteger := Dificuldade;

      Q.ParamByName('pdf').DataType := ftString;
      if Arquivo <> '' then
        Q.ParamByName('pdf').AsString := Arquivo
      else
        Q.ParamByName('pdf').Clear;

      Q.ParamByName('ativo').AsInteger := Ativo;

      Q.ExecSQL;

      if FProvaID > 0 then
      begin
        FrmPrinc.LogInfo('Prova atualizada: %s (ID: %d)', [edtTitulo.Text, FProvaID]);
        FrmPrinc.ShowSuccess('Prova atualizada com sucesso!');
      end
      else
      begin
        FrmPrinc.LogInfo('Nova prova cadastrada: %s', [edtTitulo.Text]);
        FrmPrinc.ShowSuccess('Prova cadastrada com sucesso!');
      end;

      FrmPrinc.Commit;
      ModalResult := mrOk;
    except
      on E: Exception do
      begin
        FrmPrinc.Rollback;
        FrmPrinc.LogException(E, 'Erro ao salvar prova');
        FrmPrinc.ShowError('Erro ao salvar: %s', [E.Message]);
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFrmProvasEdit.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFrmProvasEdit.btnSalvarClick(Sender: TObject);
begin
  if ValidarDados then
    Salvar;
end;

procedure TFrmProvasEdit.btnSelecionarPdfClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'Arquivos PDF (*.pdf)|*.pdf';
  OpenDialog1.Options := OpenDialog1.Options + [ofFileMustExist];
  if OpenDialog1.Execute then
    edtPdfPath.Text := OpenDialog1.FileName;
end;

procedure TFrmProvasEdit.cmbAreaChange(Sender: TObject);
begin
  AtualizarCorArea;
end;

end.
