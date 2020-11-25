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
  ApplicationMode: TApplicationMode = amFolderAnalysis;

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
    TestFile: string;
    TestFolder: string;
  end;

var
  AppConfiguration: TAppConfiguration;

function GetConfigValue(config: TJSONObject; const aKeyName: string): string;
var
  value: string;
begin
  if config.TryGetValue<string>('dataFolder', value) then
    Result := value
  else
    raise EAssertionFailed.Create
      (Format('Can''t find mandatory key in app config: %s', [aKeyName]));
end;

procedure ReadConfiguration();
var
  jsAppConfig: TJSONObject;
begin
  Assert(FileExists(ConfigFileName),
    Format('Can''t run. Missing mandatory config file: %s', [ConfigFileName]));
  jsAppConfig := TJSONObject.ParseJSONValue(TFile.ReadAllText(ConfigFileName))
    as TJSONObject;
  AppConfiguration.DataFolder := GetConfigValue(jsAppConfig, 'dataFolder');
  AppConfiguration.TestFile := GetConfigValue(jsAppConfig, 'testFile');
  AppConfiguration.TestFolder := GetConfigValue(jsAppConfig, 'testSubFolder');
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
  Result := FileExists('..\..\' + dprFileName) or FileExists(dprFileName);
end;

function GetSampleFilePath(): string;
begin
  Result := TPath.Combine(GetTestFolder, 'testunit.pas');
end;

procedure ConsoleApplicationHeader();
begin
  writeln('DelphiAST - Static Code Analyser');
  writeln('----------------------------------');
end;

procedure ApplicationRun();
begin
  ReadConfiguration();
  case ApplicationMode of
    amFolderAnalysis:
      begin
        ConsoleApplicationHeader();
        TAnalyseFolderCommand.Execute(TPath.Combine(GetTestFolder,
          AppConfiguration.TestSubFolder));
      end;
    amFileAnalysis:
      begin
        ConsoleApplicationHeader();
        TAnalyseUnitCommand.Execute(GetSampleFilePath());
      end;
    amGenerateXml:
      TAnalyseUnitCommand.Execute_GenerateXML(GetSampleFilePath());
  end;
  if IsDeveloperMode then
    readln;
end;

end.
