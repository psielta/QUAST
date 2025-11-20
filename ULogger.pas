unit ULogger;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.SyncObjs, System.Types,
  System.Generics.Collections, System.Generics.Defaults;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llFatal);

  TLogger = class
  private
    FLogPath: string;
    FMaxLogSizeKB: Integer;
    FMaxLogFiles: Integer;
    FMinLogLevel: TLogLevel;
    FCriticalSection: TCriticalSection;
    FEnabled: Boolean;

    function GetLogFileName: string;
    function GetLogFilePath: string;
    function GetCurrentLogSize: Int64;
    procedure RotateLogsIfNeeded;
    procedure RotateLogs;
    function LogLevelToString(ALevel: TLogLevel): string;
    function ShouldLog(ALevel: TLogLevel): Boolean;
    procedure WriteToFile(const AMessage: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Log(const AMessage: string; ALevel: TLogLevel = llInfo); overload;
    procedure Log(const AFormat: string; const AArgs: array of const; ALevel: TLogLevel = llInfo); overload;
    procedure Debug(const AMessage: string); overload;
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure Warning(const AMessage: string); overload;
    procedure Warning(const AFormat: string; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure Fatal(const AMessage: string); overload;
    procedure Fatal(const AFormat: string; const AArgs: array of const); overload;
    procedure LogException(E: Exception; const AContext: string = '');

    property LogPath: string read FLogPath write FLogPath;
    property MaxLogSizeKB: Integer read FMaxLogSizeKB write FMaxLogSizeKB;
    property MaxLogFiles: Integer read FMaxLogFiles write FMaxLogFiles;
    property MinLogLevel: TLogLevel read FMinLogLevel write FMinLogLevel;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  // Instância global do logger
  function Logger: TLogger;

implementation

var
  FLoggerInstance: TLogger;

function Logger: TLogger;
begin
  if not Assigned(FLoggerInstance) then
    FLoggerInstance := TLogger.Create;
  Result := FLoggerInstance;
end;

{ TLogger }

constructor TLogger.Create;
begin
  inherited Create;
  FCriticalSection := TCriticalSection.Create;
  FLogPath := ExtractFilePath(ParamStr(0)) + 'Logs\';
  FMaxLogSizeKB := 1024; // 1MB por padrão
  FMaxLogFiles := 10; // Mantém os últimos 10 arquivos
  FMinLogLevel := llDebug; // Registra tudo por padrão
  FEnabled := True;

  // Cria diretório de logs se não existir
  if not DirectoryExists(FLogPath) then
    ForceDirectories(FLogPath);
end;

destructor TLogger.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

function TLogger.GetLogFileName: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', Now) + '.log';
end;

function TLogger.GetLogFilePath: string;
begin
  Result := TPath.Combine(FLogPath, GetLogFileName);
end;

function TLogger.GetCurrentLogSize: Int64;
var
  FilePath: string;
begin
  FilePath := GetLogFilePath;
  if FileExists(FilePath) then
    Result := TFile.GetSize(FilePath)
  else
    Result := 0;
end;

procedure TLogger.RotateLogsIfNeeded;
begin
  // Verifica se o arquivo atual excedeu o tamanho máximo
  if GetCurrentLogSize > (FMaxLogSizeKB * 1024) then
    RotateLogs;
end;

procedure TLogger.RotateLogs;
var
  BaseFileName, NewFileName: string;
  Counter: Integer;
  Files: TArray<string>;
  I: Integer;
begin
  BaseFileName := GetLogFilePath;
  Counter := 1;

  // Renomeia o arquivo atual
  while FileExists(BaseFileName + '.' + IntToStr(Counter)) do
    Inc(Counter);

  if FileExists(BaseFileName) then
    TFile.Move(BaseFileName, BaseFileName + '.' + IntToStr(Counter));

  // Remove arquivos antigos se exceder o limite
  Files := TDirectory.GetFiles(FLogPath, '*.log*');
  if Length(Files) > FMaxLogFiles then
  begin
    // Ordena por data de modificação (mais antigo primeiro)
    TArray.Sort<string>(Files, TComparer<string>.Construct(
      function(const Left, Right: string): Integer
      var
        LeftTime, RightTime: TDateTime;
      begin
        LeftTime := TFile.GetLastWriteTime(Left);
        RightTime := TFile.GetLastWriteTime(Right);
        if LeftTime < RightTime then
          Result := -1
        else if LeftTime > RightTime then
          Result := 1
        else
          Result := 0;
      end));

    // Remove os mais antigos
    for I := 0 to Length(Files) - FMaxLogFiles - 1 do
    begin
      if FileExists(Files[I]) then
        TFile.Delete(Files[I]);
    end;
  end;
end;

function TLogger.LogLevelToString(ALevel: TLogLevel): string;
begin
  case ALevel of
    llDebug:   Result := 'DEBUG';
    llInfo:    Result := 'INFO ';
    llWarning: Result := 'WARN ';
    llError:   Result := 'ERROR';
    llFatal:   Result := 'FATAL';
  else
    Result := 'UNKN ';
  end;
end;

function TLogger.ShouldLog(ALevel: TLogLevel): Boolean;
begin
  Result := FEnabled and (ALevel >= FMinLogLevel);
end;

procedure TLogger.WriteToFile(const AMessage: string);
var
  LogFile: TextFile;
  FilePath: string;
begin
  FCriticalSection.Enter;
  try
    RotateLogsIfNeeded;

    FilePath := GetLogFilePath;
    AssignFile(LogFile, FilePath);
    try
      if FileExists(FilePath) then
        Append(LogFile)
      else
        Rewrite(LogFile);

      WriteLn(LogFile, AMessage);
    finally
      CloseFile(LogFile);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLogger.Log(const AMessage: string; ALevel: TLogLevel);
var
  LogMessage: string;
begin
  if not ShouldLog(ALevel) then
    Exit;

  LogMessage := Format('[%s] [%s] %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
     LogLevelToString(ALevel),
     AMessage]);

  WriteToFile(LogMessage);
end;

procedure TLogger.Log(const AFormat: string; const AArgs: array of const; ALevel: TLogLevel);
begin
  Log(Format(AFormat, AArgs), ALevel);
end;

procedure TLogger.Debug(const AMessage: string);
begin
  Log(AMessage, llDebug);
end;

procedure TLogger.Debug(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llDebug);
end;

procedure TLogger.Info(const AMessage: string);
begin
  Log(AMessage, llInfo);
end;

procedure TLogger.Info(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llInfo);
end;

procedure TLogger.Warning(const AMessage: string);
begin
  Log(AMessage, llWarning);
end;

procedure TLogger.Warning(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llWarning);
end;

procedure TLogger.Error(const AMessage: string);
begin
  Log(AMessage, llError);
end;

procedure TLogger.Error(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llError);
end;

procedure TLogger.Fatal(const AMessage: string);
begin
  Log(AMessage, llFatal);
end;

procedure TLogger.Fatal(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llFatal);
end;

procedure TLogger.LogException(E: Exception; const AContext: string);
var
  Message: string;
begin
  if AContext <> '' then
    Message := Format('%s - %s: %s', [AContext, E.ClassName, E.Message])
  else
    Message := Format('%s: %s', [E.ClassName, E.Message]);

  Error(Message);
end;

initialization

finalization
  if Assigned(FLoggerInstance) then
    FreeAndNil(FLoggerInstance);

end.
