object FrmBancasEdit: TFrmBancasEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Cadastro de Banca'
  ClientHeight = 380
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
    Top = 335
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
    Height = 335
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
    object lblSigla: TLabel
      Left = 16
      Top = 72
      Width = 29
      Height = 15
      Caption = 'Sigla:'
    end
    object lblDescricao: TLabel
      Left = 16
      Top = 128
      Width = 55
      Height = 15
      Caption = 'Descri'#231#227'o:'
    end
    object lblSite: TLabel
      Left = 16
      Top = 240
      Width = 24
      Height = 15
      Caption = 'Site:'
    end
    object edtNome: TEdit
      Left = 16
      Top = 37
      Width = 468
      Height = 23
      MaxLength = 200
      TabOrder = 0
    end
    object edtSigla: TEdit
      Left = 16
      Top = 93
      Width = 200
      Height = 23
      CharCase = ecUpperCase
      MaxLength = 50
      TabOrder = 1
    end
    object memoDescricao: TMemo
      Left = 16
      Top = 149
      Width = 468
      Height = 73
      MaxLength = 500
      ScrollBars = ssVertical
      TabOrder = 2
    end
    object edtSite: TEdit
      Left = 16
      Top = 261
      Width = 468
      Height = 23
      MaxLength = 200
      TabOrder = 3
      TextHint = 'https://exemplo.com.br'
    end
    object chkAtivo: TCheckBox
      Left = 16
      Top = 298
      Width = 97
      Height = 17
      Caption = 'Ativo'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
end
