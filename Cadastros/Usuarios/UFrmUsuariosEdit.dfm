object FrmUsuariosEdit: TFrmUsuariosEdit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Usuário'
  ClientHeight = 280
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 240
    Width = 420
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnSalvar: TButton
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TButton
      Left = 336
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 240
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblNome: TLabel
      Left = 16
      Top = 16
      Width = 31
      Height = 13
      Caption = 'Nome'
    end
    object lblEmail: TLabel
      Left = 16
      Top = 64
      Width = 30
      Height = 13
      Caption = 'Email'
    end
    object lblSenha: TLabel
      Left = 16
      Top = 112
      Width = 34
      Height = 13
      Caption = 'Senha'
    end
    object lblConfSenha: TLabel
      Left = 216
      Top = 112
      Width = 86
      Height = 13
      Caption = 'Confirmar senha'
    end
    object edtNome: TEdit
      Left = 16
      Top = 32
      Width = 376
      Height = 21
      TabOrder = 0
    end
    object edtEmail: TEdit
      Left = 16
      Top = 80
      Width = 376
      Height = 21
      TabOrder = 1
    end
    object edtSenha: TEdit
      Left = 16
      Top = 128
      Width = 177
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object edtConfSenha: TEdit
      Left = 216
      Top = 128
      Width = 176
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
    end
    object chkAtivo: TCheckBox
      Left = 16
      Top = 168
      Width = 97
      Height = 17
      Caption = 'Ativo'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
end
