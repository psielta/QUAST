object FrmUsuariosLista: TFrmUsuariosLista
  Left = 0
  Top = 0
  Caption = 'Usuários'
  ClientHeight = 400
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 48
    Align = alTop
    TabOrder = 0
    object lblBusca: TLabel
      Left = 16
      Top = 16
      Width = 34
      Height = 13
      Caption = 'Buscar'
    end
    object edtBusca: TEdit
      Left = 56
      Top = 12
      Width = 240
      Height = 21
      TabOrder = 0
      OnChange = edtBuscaChange
    end
    object btnAtualizar: TButton
      Left = 312
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Atualizar'
      TabOrder = 1
      OnClick = btnAtualizarClick
    end
    object btnNovo: TButton
      Left = 408
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Novo'
      TabOrder = 2
      OnClick = btnNovoClick
    end
    object btnEditar: TButton
      Left = 488
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Editar'
      TabOrder = 3
      OnClick = btnEditarClick
    end
    object btnExcluir: TButton
      Left = 568
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Excluir'
      TabOrder = 4
      OnClick = btnExcluirClick
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 360
    Width = 680
    Height = 40
    Align = alBottom
    TabOrder = 2
    object btnFechar: TButton
      Left = 592
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 48
    Width = 680
    Height = 312
    Align = alClient
    TabOrder = 1
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 678
      Height = 310
      Align = alClient
      DataSource = DataSource1
      ReadOnly = True
      TabOrder = 0
      OnDblClick = DBGrid1DblClick
    end
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 24
    Top = 352
  end
  object FDQuery1: TFDQuery
    Left = 72
    Top = 352
  end
end
