object FrmBancasLista: TFrmBancasLista
  Left = 0
  Top = 0
  Caption = 'Cadastro de Bancas'
  ClientHeight = 500
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 65
    Align = alTop
    TabOrder = 0
    object lblBusca: TLabel
      Left = 16
      Top = 16
      Width = 36
      Height = 15
      Caption = 'Buscar:'
    end
    object edtBusca: TEdit
      Left = 16
      Top = 34
      Width = 400
      Height = 23
      TabOrder = 0
      TextHint = 'Digite o nome ou sigla da banca...'
      OnChange = edtBuscaChange
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 455
    Width = 800
    Height = 45
    Align = alBottom
    TabOrder = 1
    object btnNovo: TButton
      Left = 16
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnEditar: TButton
      Left = 122
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Editar'
      TabOrder = 1
      OnClick = btnEditarClick
    end
    object btnExcluir: TButton
      Left = 228
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnAtualizar: TButton
      Left = 334
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 3
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 684
      Top = 8
      Width = 100
      Height = 30
      Caption = 'Fechar'
      TabOrder = 4
      OnClick = btnFecharClick
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 65
    Width = 800
    Height = 390
    Align = alClient
    TabOrder = 2
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 798
      Height = 388
      Align = alClient
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnDblClick = DBGrid1DblClick
    end
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 720
    Top = 96
  end
  object FDQuery1: TFDQuery
    Left = 720
    Top = 144
  end
end
