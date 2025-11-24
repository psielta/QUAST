object FrmProvasEdit: TFrmProvasEdit
  Left = 0
  Top = 0
  Caption = 'Cadastro de Provas'
  ClientHeight = 620
  ClientWidth = 780
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object pnlButtons: TPanel
    Left = 0
    Top = 575
    Width = 780
    Height = 45
    Align = alBottom
    TabOrder = 1
    object btnSalvar: TButton
      Left = 16
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TButton
      Left = 122
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 780
    Height = 575
    Align = alClient
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 16
      Width = 32
      Height = 15
      Caption = 'T'#237'tulo'
    end
    object lblBanca: TLabel
      Left = 16
      Top = 76
      Width = 34
      Height = 15
      Caption = 'Banca'
    end
    object lblArea: TLabel
      Left = 400
      Top = 76
      Width = 113
      Height = 15
      Caption = #193'rea de Conhecimento'
    end
    object lblAno: TLabel
      Left = 16
      Top = 136
      Width = 23
      Height = 15
      Caption = 'Ano'
    end
    object lblNivel: TLabel
      Left = 136
      Top = 136
      Width = 28
      Height = 15
      Caption = 'N'#237'vel'
    end
    object lblTipo: TLabel
      Left = 296
      Top = 136
      Width = 26
      Height = 15
      Caption = 'Tipo'
    end
    object lblCargo: TLabel
      Left = 520
      Top = 136
      Width = 33
      Height = 15
      Caption = 'Cargo'
    end
    object lblDuracao: TLabel
      Left = 16
      Top = 196
      Width = 114
      Height = 15
      Caption = 'Dura'#231#227'o (minutos)'
    end
    object lblDataAplicacao: TLabel
      Left = 176
      Top = 196
      Width = 97
      Height = 15
      Caption = 'Data de aplica'#231#227'o'
    end
    object lblNumQuestoes: TLabel
      Left = 360
      Top = 196
      Width = 111
      Height = 15
      Caption = 'N'#250'mero de quest'#245'es'
    end
    object lblDificuldade: TLabel
      Left = 520
      Top = 196
      Width = 63
      Height = 15
      Caption = 'Dificuldade'
    end
    object lblObservacoes: TLabel
      Left = 16
      Top = 316
      Width = 76
      Height = 15
      Caption = 'Observa'#231#245'es'
    end
    object lblArquivoPdf: TLabel
      Left = 16
      Top = 256
      Width = 62
      Height = 15
      Caption = 'Arquivo PDF'
    end
    object edtTitulo: TEdit
      Left = 16
      Top = 36
      Width = 728
      Height = 23
      TabOrder = 0
    end
    object cmbBanca: TComboBox
      Left = 16
      Top = 96
      Width = 320
      Height = 23
      Style = csDropDownList
      TabOrder = 1
    end
    object cmbArea: TComboBox
      Left = 400
      Top = 96
      Width = 304
      Height = 23
      Style = csDropDownList
      TabOrder = 2
      OnChange = cmbAreaChange
    end
    object pnlCorArea: TPanel
      Left = 708
      Top = 96
      Width = 36
      Height = 23
      BevelOuter = bvLowered
      ParentColor = False
      ParentBackground = False
      StyleElements = []
      Caption = ''
      TabOrder = 15
    end
    object edtAno: TEdit
      Left = 16
      Top = 156
      Width = 100
      Height = 23
      TabOrder = 3
    end
    object cmbNivel: TComboBox
      Left = 136
      Top = 156
      Width = 140
      Height = 23
      Style = csDropDownList
      TabOrder = 4
    end
    object cmbTipo: TComboBox
      Left = 296
      Top = 156
      Width = 200
      Height = 23
      Style = csDropDownList
      TabOrder = 5
    end
    object edtCargo: TEdit
      Left = 520
      Top = 156
      Width = 224
      Height = 23
      TabOrder = 6
    end
    object edtDuracao: TEdit
      Left = 16
      Top = 216
      Width = 120
      Height = 23
      TabOrder = 7
    end
    object dtpDataAplicacao: TDateTimePicker
      Left = 176
      Top = 216
      Width = 160
      Height = 23
      Date = 45565.000000000000000000
      Time = 0.571924097224589100
      ShowCheckbox = True
      Checked = False
      TabOrder = 8
    end
    object edtNumQuestoes: TEdit
      Left = 360
      Top = 216
      Width = 136
      Height = 23
      TabOrder = 9
    end
    object cmbDificuldade: TComboBox
      Left = 520
      Top = 216
      Width = 120
      Height = 23
      Style = csDropDownList
      TabOrder = 10
    end
    object edtPdfPath: TEdit
      Left = 16
      Top = 276
      Width = 600
      Height = 23
      TabOrder = 11
    end
    object btnSelecionarPdf: TButton
      Left = 624
      Top = 274
      Width = 120
      Height = 27
      Caption = 'Selecionar PDF'
      TabOrder = 12
      OnClick = btnSelecionarPdfClick
    end
    object memoObservacoes: TMemo
      Left = 16
      Top = 336
      Width = 728
      Height = 185
      TabOrder = 14
      ScrollBars = ssVertical
    end
    object chkAtivo: TCheckBox
      Left = 656
      Top = 218
      Width = 88
      Height = 17
      Caption = 'Ativo'
      TabOrder = 13
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Arquivos PDF (*.pdf)|*.pdf'
    Left = 712
    Top = 520
  end
end
