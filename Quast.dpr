program Quast;

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.StrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
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
  UFrmUsuariosLista in 'Cadastros\Usuarios\UFrmUsuariosLista.pas' {FrmUsuariosLista},
  UFrmUsuariosEdit in 'Cadastros\Usuarios\UFrmUsuariosEdit.pas' {FrmUsuariosEdit},
  UFrmLogin in 'UFrmLogin.pas' {FrmLogin},
  UAuthManager in 'UAuthManager.pas',
  UAuthUtils in 'UAuthUtils.pas',
  FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Def;

{$R *.res}

var
  LoginResult: Integer;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');

  FrmLogin := TFrmLogin.Create(nil);
  try
    LoginResult := FrmLogin.ShowModal;
    if LoginResult = mrOk then
    begin
      Application.CreateForm(TFrmPrinc, FrmPrinc);
      FrmPrinc.ApplyAuthenticatedUser(FrmLogin.LoggedUser);
      Application.Run;
    end;
  finally
    FrmLogin.Free;
  end;
end.
