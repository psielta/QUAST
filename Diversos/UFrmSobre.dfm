object FrmSobre: TFrmSobre
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Sobre o Quast'
  ClientHeight = 550
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 16
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    Color = 16750402
    ParentBackground = False
    TabOrder = 0
    StyleElements = []
    object lblTitulo: TLabel
      Left = 24
      Top = 20
      Width = 80
      Height = 36
      Caption = 'QUAST'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 24
      Top = 63
      Width = 350
      Height = 21
      Caption = 'Sistema de Gest'#227'o de Estudos com IA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlContent: TPanel
    Left = 0
    Top = 100
    Width = 600
    Height = 360
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object memoDescricao: TMemo
      Left = 16
      Top = 16
      Width = 568
      Height = 328
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 460
    Width = 600
    Height = 90
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblVersao: TLabel
      Left = 24
      Top = 12
      Width = 133
      Height = 16
      Caption = 'Vers'#227'o: 1.0.0-alpha'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAutor: TLabel
      Left = 24
      Top = 33
      Width = 112
      Height = 16
      Caption = 'Mateus Salgueiro'
    end
    object lblGitHub: TLabel
      Left = 24
      Top = 54
      Width = 112
      Height = 16
      Cursor = crHandPoint
      Caption = 'GitHub: @psielta'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3447003
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = lblGitHubClick
      OnMouseEnter = lblGitHubMouseEnter
      OnMouseLeave = lblGitHubMouseLeave
    end
    object lblLinkedIn: TLabel
      Left = 200
      Top = 54
      Width = 182
      Height = 16
      Cursor = crHandPoint
      Caption = 'LinkedIn: Mateus Salgueiro'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3447003
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = lblLinkedInClick
      OnMouseEnter = lblLinkedInMouseEnter
      OnMouseLeave = lblLinkedInMouseLeave
    end
    object btnFechar: TButton
      Left = 494
      Top = 48
      Width = 90
      Height = 30
      Cancel = True
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
end
