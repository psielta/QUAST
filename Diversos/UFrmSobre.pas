unit UFrmSobre;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.ShellAPI;

type
  TFrmSobre = class(TForm)
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlContent: TPanel;
    memoDescricao: TMemo;
    pnlFooter: TPanel;
    btnFechar: TButton;
    lblVersao: TLabel;
    lblAutor: TLabel;
    lblGitHub: TLabel;
    lblLinkedIn: TLabel;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblGitHubClick(Sender: TObject);
    procedure lblLinkedInClick(Sender: TObject);
    procedure lblGitHubMouseEnter(Sender: TObject);
    procedure lblGitHubMouseLeave(Sender: TObject);
    procedure lblLinkedInMouseEnter(Sender: TObject);
    procedure lblLinkedInMouseLeave(Sender: TObject);
  private
    procedure AbrirURL(const URL: string);
  public
    { Public declarations }
  end;

var
  FrmSobre: TFrmSobre;

implementation

{$R *.dfm}

procedure TFrmSobre.FormCreate(Sender: TObject);
begin
  memoDescricao.Lines.Clear;
  memoDescricao.Lines.Add('Quast é um sistema desktop desenvolvido em Delphi para auxiliar estudantes');
  memoDescricao.Lines.Add('no gerenciamento e resolução de questões de provas e concursos.');
  memoDescricao.Lines.Add('');
  memoDescricao.Lines.Add('O sistema combina organização de conteúdo com inteligência artificial');
  memoDescricao.Lines.Add('para proporcionar uma experiência de aprendizado personalizada e eficiente.');
  memoDescricao.Lines.Add('');
  memoDescricao.Lines.Add('OBJETIVOS:');
  memoDescricao.Lines.Add('  • Organizar questões de estudo');
  memoDescricao.Lines.Add('  • Armazenar provas anteriores');
  memoDescricao.Lines.Add('  • Receber auxílio inteligente na resolução de problemas');
  memoDescricao.Lines.Add('  • Acompanhar progresso de aprendizado');
  memoDescricao.Lines.Add('');
  memoDescricao.Lines.Add('TECNOLOGIAS:');
  memoDescricao.Lines.Add('  • Linguagem: Delphi (Object Pascal)');
  memoDescricao.Lines.Add('  • Banco de Dados: SQLite com sistema de Migrations');
  memoDescricao.Lines.Add('  • Componentes: FireDAC para acesso a dados');
  memoDescricao.Lines.Add('  • Interface: VCL (Visual Component Library)');
end;

procedure TFrmSobre.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSobre.AbrirURL(const URL: string);
begin
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmSobre.lblGitHubClick(Sender: TObject);
begin
  AbrirURL('https://github.com/psielta');
end;

procedure TFrmSobre.lblLinkedInClick(Sender: TObject);
begin
  AbrirURL('https://www.linkedin.com/in/mateus-salgueiro-525717205/');
end;

procedure TFrmSobre.lblGitHubMouseEnter(Sender: TObject);
begin
  lblGitHub.Font.Style := [fsUnderline];
  Screen.Cursor := crHandPoint;
end;

procedure TFrmSobre.lblGitHubMouseLeave(Sender: TObject);
begin
  lblGitHub.Font.Style := [];
  Screen.Cursor := crDefault;
end;

procedure TFrmSobre.lblLinkedInMouseEnter(Sender: TObject);
begin
  lblLinkedIn.Font.Style := [fsUnderline];
  Screen.Cursor := crHandPoint;
end;

procedure TFrmSobre.lblLinkedInMouseLeave(Sender: TObject);
begin
  lblLinkedIn.Font.Style := [];
  Screen.Cursor := crDefault;
end;

end.
