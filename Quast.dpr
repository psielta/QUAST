program Quast;

uses
  Vcl.Forms,
  UFrmPrinc in 'UFrmPrinc.pas' {FrmPrinc},
  Vcl.Themes,
  Vcl.Styles,
  UFrmSobre in 'Diversos\UFrmSobre.pas' {FrmSobre},
  UMigrationManager in 'Migrations\UMigrationManager.pas',
  ULogger in 'ULogger.pas',
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
