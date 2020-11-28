unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Diagnostics;

type
  TApplicationMode = (amFolderAnalysis, amFileAnalysis, amGenerateXml);

const
  ApplicationMode: TApplicationMode = amFileAnalysis;

procedure ApplicationRun();

implementation

uses
  Command.AnalyseUnit,
  Command.AnalyseFolder;

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

procedure ApplicationRun();
const
  DISPLAY_LevelHigherThan = 8;
begin
  ReadConfiguration();
  case ApplicationMode of
    amFolderAnalysis:
      begin
        ConsoleApplicationHeader();
        TAnalyseFolderCommand.Execute(TPath.Combine(GetTestFolder,
          AppConfiguration.TestSubFolder), DISPLAY_LevelHigherThan);
      end;
    amFileAnalysis:
      begin
        ConsoleApplicationHeader();
        // TAnalyseUnitCommand.Execute(GetSampleFilePath('testunit.pas'));
        TAnalyseUnitCommand.Execute(GetSampleFilePath('test01.pas'));
      end;
    amGenerateXml:
      TAnalyseUnitCommand.Execute_GenerateXML
        (GetSampleFilePath('testunit.pas'));
  end;
  if IsDeveloperMode then
    readln;
end;

end.
