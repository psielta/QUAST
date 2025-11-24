object FrmProvasLista: TFrmProvasLista
  Left = 0
  Top = 0
  Caption = 'Cadastro de Provas'
  ClientHeight = 520
  ClientWidth = 950
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 16
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 950
    Height = 65
    Align = alTop
    TabOrder = 0
    object lblBusca: TLabel
      Left = 16
      Top = 16
      Width = 42
      Height = 16
      Caption = 'Buscar'
    end
    object lblFiltroBanca: TLabel
      Left = 440
      Top = 16
      Width = 35
      Height = 16
      Caption = 'Banca'
    end
    object lblFiltroArea: TLabel
      Left = 640
      Top = 16
      Width = 28
      Height = 16
      Caption = #193'rea'
    end
    object edtBusca: TEdit
      Left = 16
      Top = 34
      Width = 400
      Height = 24
      TabOrder = 0
      TextHint = 'Digite t'#237'tulo, banca, '#225'rea ou cargo...'
      OnChange = edtBuscaChange
    end
    object cmbFiltroBanca: TComboBox
      Left = 440
      Top = 34
      Width = 180
      Height = 24
      Style = csDropDownList
      TabOrder = 1
      OnChange = cmbFiltroBancaChange
    end
    object cmbFiltroArea: TComboBox
      Left = 640
      Top = 34
      Width = 180
      Height = 24
      Style = csDropDownList
      TabOrder = 2
      OnChange = cmbFiltroAreaChange
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 475
    Width = 950
    Height = 45
    Align = alBottom
    TabOrder = 2
    object btnNovo: TButton
      Left = 16
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnEditar: TButton
      Left = 122
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Editar'
      TabOrder = 1
      OnClick = btnEditarClick
    end
    object btnExcluir: TButton
      Left = 228
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnAtualizar: TButton
      Left = 334
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Atualizar'
      TabOrder = 3
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 834
      Top = 8
      Width = 100
      Height = 29
      Caption = 'Fechar'
      TabOrder = 4
      OnClick = btnFecharClick
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 65
    Width = 950
    Height = 410
    Align = alClient
    TabOrder = 1
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 948
      Height = 408
      Align = alClient
      DataSource = DataSource1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnDrawColumnCell = DBGrid1DrawColumnCell
      OnDblClick = DBGrid1DblClick
    end
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 872
    Top = 104
  end
  object FDQuery1: TFDQuery
    Left = 872
    Top = 152
  end
end
