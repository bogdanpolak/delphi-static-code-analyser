unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Diagnostics;

type
  TApplicationMode = (amFolderAnalysis, amFileAnalysis, amGenerateXml,
    amGenerateCsv);

const
  ApplicationMode: TApplicationMode = amGenerateCsv;

procedure ApplicationRun();

implementation

uses
  Command.AnalyseUnit,
  Command.GenerateXml;

const
  ConfigFileName = 'appconfig.json';

type
  TAppConfiguration = record
    DataFolder: string;
    TestSubFolder: string;
  end;

var
  AppConfiguration: TAppConfiguration;

function GetConfigValue(config: TJSONObject; const aKeyName: string): string;
var
  value: string;
begin
  if config.TryGetValue<string>(aKeyName, value) then
    Result := value
  else
    raise EAssertionFailed.Create
      (Format('Can''t find mandatory key in app config: %s', [aKeyName]));
end;

procedure ReadConfiguration();
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

function GetTestFolder(): string;
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

function IsDeveloperMode(): boolean;
var
  dprFileName: string;
begin
  dprFileName := ChangeFileExt(ExtractFileName(ParamStr(0)), '.dpr');
  Result := FileExists('..\src\' + dprFileName) or FileExists(dprFileName);
end;

function GetSampleFilePath(const aUnitFileName: string): string;
begin
  Result := TPath.Combine(GetTestFolder, aUnitFileName);
end;

procedure ConsoleApplicationHeader();
begin
  writeln('DelphiAST - Static Code Analyser');
  writeln('----------------------------------');
end;

function GetUnits(): TArray<string>;
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

procedure ApplicationRun();
const
  DISPLAY_LevelHigherThan = 8;
var
  files: TArray<string>;
  fname: string;
begin
  ReadConfiguration();
  if ApplicationMode in [amFolderAnalysis, amFileAnalysis] then
    ConsoleApplicationHeader();
  files := GetUnits();
  for fname in files do
  begin
    case ApplicationMode of
      amFolderAnalysis:
        TAnalyseUnitCommand.Execute_CodeAnalysis(fname,
          DISPLAY_LevelHigherThan);
      amGenerateCsv:
        TAnalyseUnitCommand.Execute_GenerateCsv(fname, DISPLAY_LevelHigherThan);
      amFileAnalysis:
        TAnalyseUnitCommand.Execute_CodeAnalysis(fname);
      amGenerateXml:
        TGenerateXmlCommand.Execute(fname);
    end;
  end;
  if IsDeveloperMode then
    readln;
end;

end.
