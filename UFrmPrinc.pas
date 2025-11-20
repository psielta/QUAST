unit UFrmPrinc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.Skia,
  Vcl.Imaging.pngimage, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite,
  UMigrationManager;

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
    procedure VisualizarMigrations;
  private
    { Private declarations }
    FMigrationManager: TMigrationManager;
    procedure ConfigurarConexaoBanco;
    procedure ExecutarMigrations;
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

    // Executar sistema de migrations
    ExecutarMigrations;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TFrmPrinc.ExecutarMigrations;
begin
  try
    // Criar gerenciador de migrations
    FMigrationManager := TMigrationManager.Create(FDConnection1);
    try
      // Por enquanto, não configurar callback - logs vão apenas para arquivo
      // FMigrationManager.LogCallback := nil;

      // Inicializar sistema de migrations
      FMigrationManager.Initialize;

      // Validar integridade das migrations já aplicadas
      FMigrationManager.ValidateAppliedMigrations;

      // Executar todas as migrations pendentes
      FMigrationManager.RunAllPendingMigrations;
    finally
      FreeAndNil(FMigrationManager);
    end;
  except
    on E: EMigrationException do
    begin
      ShowMessage('Erro no sistema de migrations: ' + E.Message);
      Application.Terminate;
    end;
    on E: Exception do
    begin
      ShowMessage('Erro inesperado: ' + E.Message);
      Application.Terminate;
    end;
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

procedure TFrmPrinc.VisualizarMigrations;
var
  MigrationManager: TMigrationManager;
  AllMigrations: TArray<TMigrationInfo>;
  I: Integer;
  Status, Mensagem: string;
begin
  if not FDConnection1.Connected then
  begin
    ShowMessage('Banco de dados não está conectado.');
    Exit;
  end;

  MigrationManager := TMigrationManager.Create(FDConnection1);
  try
    MigrationManager.Initialize;
    AllMigrations := MigrationManager.GetAllMigrations;

    Mensagem := 'Status das Migrations:' + #13#10 + #13#10;

    if Length(AllMigrations) = 0 then
    begin
      Mensagem := Mensagem + 'Nenhuma migration encontrada.';
    end
    else
    begin
      for I := 0 to Length(AllMigrations) - 1 do
      begin
        if AllMigrations[I].Applied then
          Status := '✓ Aplicada em ' + DateTimeToStr(AllMigrations[I].AppliedAt)
        else
          Status := '⚠ Pendente';

        Mensagem := Mensagem + Format('V%3.3d - %s: %s',
          [AllMigrations[I].Version, AllMigrations[I].Filename, Status]
          ) + #13#10;
      end;
    end;

    ShowMessage(Mensagem);
  finally
    MigrationManager.Free;
  end;
end;

end.
