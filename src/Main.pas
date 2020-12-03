unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Diagnostics;

type
  TApplicationMode = (amFolderAnalysis, amGenerateCsv, amFileAnalysis,
    amGenerateXml);

  TMain = class
  public const
    ApplicationMode: TApplicationMode = amGenerateCsv;
  public const
    ConfigFileName = 'appconfig.json';
  private
    function GetUnits: TArray<string>;
    function GetConfigValue(config: TJSONObject;
      const aKeyName: string): string;
    function GetSampleFilePath(const aUnitFileName: string): string;
    function GetTestFolder: string;
    function IsDeveloperMode: boolean;
    procedure ReadConfiguration;
    procedure WriteApplicationTitle;
    procedure ApplicationRun;
  public
    class procedure Run; static;
  end;

implementation

uses
  Command.AnalyseUnit,
  Command.GenerateXml;

type
  TAppConfiguration = record
    DataFolder: string;
    TestSubFolder: string;
  end;

var
  AppConfiguration: TAppConfiguration;

function TMain.GetConfigValue(config: TJSONObject;
  const aKeyName: string): string;
var
  value: string;
begin
  if config.TryGetValue<string>(aKeyName, value) then
    Result := value
  else
    raise EAssertionFailed.Create
      (Format('Can''t find mandatory key in app config: %s', [aKeyName]));
end;

procedure TMain.ReadConfiguration();
var
  jsAppConfig: TJSONObject;
  configFilePath: string;
begin
  if FileExists(ConfigFileName) then
    configFilePath := ConfigFileName
  else if FileExists(TPath.Combine('../src/', ConfigFileName)) then
    configFilePath := TPath.Combine('../src/', ConfigFileName)
  else
    configFilePath := '';
  Assert(configFilePath <> '',
    Format('Can''t run application, missing config file: %s',
    [ConfigFileName]));
  jsAppConfig := TJSONObject.ParseJSONValue(TFile.ReadAllText(configFilePath))
    as TJSONObject;
  AppConfiguration.DataFolder := GetConfigValue(jsAppConfig, 'dataFolder');
  AppConfiguration.TestSubFolder := GetConfigValue(jsAppConfig,
    'testSubFolder');
end;

function TMain.GetTestFolder(): string;
var
  path2: string;
begin
  path2 := TPath.Combine('..\..\', AppConfiguration.DataFolder);
  if DirectoryExists(AppConfiguration.DataFolder) then
    Exit(AppConfiguration.DataFolder);
  if DirectoryExists(path2) then
    Exit(path2);
  raise Exception.Create('Can''t find test data folder.');
end;

function TMain.IsDeveloperMode(): boolean;
var
  dprFileName: string;
begin
  dprFileName := ChangeFileExt(ExtractFileName(ParamStr(0)), '.dpr');
  Result := FileExists('..\src\' + dprFileName) or FileExists(dprFileName);
end;

function TMain.GetSampleFilePath(const aUnitFileName: string): string;
begin
  Result := TPath.Combine(GetTestFolder, aUnitFileName);
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
  folderPath: string;
begin
  if ApplicationMode = amGenerateXml then
  begin
    Result := [GetSampleFilePath('testunit.pas')];
    Exit;
  end
  else if ApplicationMode = amFileAnalysis then
  begin
    Result := [GetSampleFilePath('test02.pas')];
    Exit;
  end;
  folderPath := TPath.Combine(GetTestFolder, AppConfiguration.TestSubFolder);
  if TDirectory.Exists(folderPath) then
  begin
    Result := TDirectory.GetFiles(folderPath, '*.pas',
      TSearchOption.soAllDirectories);
  end
end;

procedure TMain.ApplicationRun();
const
  DISPLAY_LevelHigherThan = 8;
var
  files: TArray<string>;
  fname: string;
begin
  ReadConfiguration();
  WriteApplicationTitle();
  files := GetUnits();
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

class procedure TMain.Run;
var
  Main: TMain;
begin
  Main := TMain.Create;
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
