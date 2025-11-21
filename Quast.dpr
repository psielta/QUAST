program Quast;

uses
  Vcl.Forms,
  UFrmPrinc in 'UFrmPrinc.pas' {FrmPrinc},
  Vcl.Themes,
  Vcl.Styles,
  UFrmSobre in 'Diversos\UFrmSobre.pas' {FrmSobre},
  UMigrationManager in 'Migrations\UMigrationManager.pas',
  ULogger in 'ULogger.pas',
  UFrmBancasLista in 'Cadastros\Bancas\UFrmBancasLista.pas' {FrmBancasLista},
  UFrmBancasEdit in 'Cadastros\Bancas\UFrmBancasEdit.pas' {FrmBancasEdit},
  UFrmAreasLista in 'Cadastros\AreasConhecimento\UFrmAreasLista.pas' {FrmAreasLista},
  UFrmAreasEdit in 'Cadastros\AreasConhecimento\UFrmAreasEdit.pas' {FrmAreasEdit},
  FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Def;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TFrmPrinc, FrmPrinc);
  Application.Run;
end.
