unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  {}
  Configuration.AppConfig;

type
  TApplicationMode = (amFolderAnalysis, amGenerateCsv, amFileAnalysis,
    amGenerateXml);

  TMain = class
  public const
    ApplicationMode: TApplicationMode = amGenerateCsv;
  private
    fAppConfiguration: IAppConfiguration;
    function GetUnits: TArray<string>;
    function IsDeveloperMode: boolean;
    procedure WriteApplicationTitle;
    procedure ApplicationRun;
  public
    constructor Create(const aAppConfiguration: IAppConfiguration);
    class procedure Run(const aAppConfiguration: IAppConfiguration); static;
  end;

implementation

uses
  Command.AnalyseUnit,
  Command.GenerateXml;

constructor TMain.Create(const aAppConfiguration: IAppConfiguration);
begin
  Assert(aAppConfiguration<>nil);
  fAppConfiguration := aAppConfiguration;
end;

function TMain.IsDeveloperMode(): boolean;
var
  dprFileName: string;
begin
  dprFileName := ChangeFileExt(ExtractFileName(ParamStr(0)), '.dpr');
  Result := FileExists('..\src\' + dprFileName) or FileExists(dprFileName);
end;

procedure TMain.WriteApplicationTitle();
begin
  if ApplicationMode in [amFolderAnalysis, amFileAnalysis] then
  begin
    writeln('DelphiAST - Static Code Analyser');
    writeln('----------------------------------');
  end;
end;

function TMain.GetUnits(): TArray<string>;
var
  folders: TArray<string>;
  folder: string;
  strList: TList<string>;
begin
  if ApplicationMode = amGenerateXml then
  begin
    Result := ['..\test\data\testunit.pas'];
    Exit;
  end
  else if ApplicationMode = amFileAnalysis then
  begin
    Result := ['..\test\data\test02.pas'];
    Exit;
  end;
  strList := TList<string>.Create();
  folders := fAppConfiguration.GetSourceFolders();
  try
    for folder in folders do
    begin
      strList.AddRange(TDirectory.GetFiles(folder, '*.pas',
        TSearchOption.soAllDirectories));
    end;
    Result := strList.ToArray;
  finally
    strList.Free;
  end;
end;

procedure TMain.ApplicationRun();
const
  DISPLAY_LevelHigherThan = 8;
var
  files: TArray<string>;
  fname: string;
begin
  fAppConfiguration.Initialize;
  files := GetUnits();
  WriteApplicationTitle();
  for fname in files do
  begin
    case ApplicationMode of
      amFolderAnalysis:
        TAnalyseUnitCommand.Execute(fname, rFormatPlainText,
          DISPLAY_LevelHigherThan);
      amGenerateCsv:
        TAnalyseUnitCommand.Execute(fname, rFormatCsv, DISPLAY_LevelHigherThan);
      amFileAnalysis:
        TAnalyseUnitCommand.Execute(fname, rFormatPlainText);
      amGenerateXml:
        TGenerateXmlCommand.Execute(fname);
    end;
  end;
  if IsDeveloperMode then
    readln;
end;

class procedure TMain.Run(const aAppConfiguration: IAppConfiguration);
var
  Main: TMain;
begin
  Main := TMain.Create(aAppConfiguration);
  try
    try
      Main.ApplicationRun();
    finally
      Main.Free;
    end
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end;

end.
