program Quast;

uses
  Vcl.Forms,
  UFrmPrinc in 'UFrmPrinc.pas' {FrmPrinc},
  Vcl.Themes,
  Vcl.Styles,
  UFrmSobre in 'Diversos\UFrmSobre.pas' {FrmSobre};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TFrmPrinc, FrmPrinc);
  Application.Run;
end.
