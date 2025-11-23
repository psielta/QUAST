object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Login'
  ClientHeight = 180
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object lblEmail: TLabel
    Left = 24
    Top = 24
    Width = 30
    Height = 13
    Caption = 'Email'
  end
  object lblSenha: TLabel
    Left = 24
    Top = 72
    Width = 34
    Height = 13
    Caption = 'Senha'
  end
  object edtEmail: TEdit
    Left = 24
    Top = 40
    Width = 289
    Height = 21
    TabOrder = 0
  end
  object edtSenha: TEdit
    Left = 24
    Top = 88
    Width = 289
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object btnEntrar: TButton
    Left = 152
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Entrar'
    TabOrder = 2
    OnClick = btnEntrarClick
  end
  object btnCancelar: TButton
    Left = 238
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 3
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 24
    Top = 128
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 72
    Top = 128
  end
end
