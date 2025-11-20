unit UFrmPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.Skia,
  Vcl.Imaging.pngimage, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite;

type
  TFrmPrinc = class(TForm)
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    Sobre1: TMenuItem;
    Image1: TImage;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure Sobre1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ConfigurarConexaoBanco;
  public
    { Public declarations }
  end;

var
  FrmPrinc: TFrmPrinc;

implementation

{$R *.dfm}

uses UFrmSobre;

procedure TFrmPrinc.ConfigurarConexaoBanco;
var
  CaminhoBanco: string;
begin
  // Obter o caminho do executável e concatenar com o nome do banco
  CaminhoBanco := ExtractFilePath(ParamStr(0)) + 'quast_database.db';

  // Configurar a conexão
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('Database=' + CaminhoBanco);
  FDConnection1.Params.Add('DriverID=SQLite');
  FDConnection1.LoginPrompt := False;

  try
    FDConnection1.Connected := True;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message);
  end;
end;

procedure TFrmPrinc.FormCreate(Sender: TObject);
begin
  ConfigurarConexaoBanco;
end;

procedure TFrmPrinc.Sobre1Click(Sender: TObject);
begin
  FrmSobre := TFrmSobre.Create(Self);
  FrmSobre.ShowModal();
end;

end.
