object FrmAreasEdit: TFrmAreasEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Cadastro de '#193'rea de Conhecimento'
  ClientHeight = 400
  ClientWidth = 500
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
    Top = 355
    Width = 500
    Height = 45
    Align = alBottom
    TabOrder = 0
    object btnSalvar: TButton
      Left = 308
      Top = 8
      Width = 90
      Height = 30
      Caption = 'Salvar'
      Default = True
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TButton
      Left = 404
      Top = 8
      Width = 90
      Height = 30
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 355
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lblNome: TLabel
      Left = 16
      Top = 16
      Width = 41
      Height = 15
      Caption = 'Nome:*'
    end
    object lblDescricao: TLabel
      Left = 16
      Top = 72
      Width = 55
      Height = 15
      Caption = 'Descri'#231#227'o:'
    end
    object lblCorHex: TLabel
      Left = 16
      Top = 184
      Width = 61
      Height = 15
      Caption = 'Cor (Hex):*'
    end
    object edtNome: TEdit
      Left = 16
      Top = 37
      Width = 468
      Height = 23
      MaxLength = 200
      TabOrder = 0
    end
    object memoDescricao: TMemo
      Left = 16
      Top = 93
      Width = 468
      Height = 73
      MaxLength = 500
      ScrollBars = ssVertical
      TabOrder = 1
    end
    object edtCorHex: TEdit
      Left = 16
      Top = 205
      Width = 150
      Height = 23
      CharCase = ecLowerCase
      MaxLength = 7
      TabOrder = 2
      Text = '#3498db'
      TextHint = '#3498db'
      OnChange = edtCorHexChange
    end
    object pnlCorPreview: TPanel
      Left = 16
      Top = 242
      Width = 150
      Height = 60
      BevelOuter = bvLowered
      Caption = ''
      Color = 3447003
      ParentBackground = False
      ParentColor = False
      StyleElements = []
      TabOrder = 5
    end
    object btnEscolherCor: TButton
      Left = 180
      Top = 205
      Width = 120
      Height = 23
      Caption = 'Escolher Cor...'
      TabOrder = 3
      OnClick = btnEscolherCorClick
    end
  end
  object ColorDialog1: TColorDialog
    Left = 424
    Top = 24
  end
end
