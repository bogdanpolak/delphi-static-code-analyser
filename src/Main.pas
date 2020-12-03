unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Generics.Collections,
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
    function GetConfigValue(config: TJSONObject; const aKey: string)
      : TJSONValue;
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
    sourceFolders: TArray<string>;
  end;

var
  AppConfiguration: TAppConfiguration;

function TMain.GetConfigValue(config: TJSONObject; const aKey: string)
  : TJSONValue;
var
  value: TJSONValue;
begin
  if config.TryGetValue(aKey, value) then
    Result := value
  else
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Expected key "%s" not found.', [aKey]));
end;

procedure TMain.ReadConfiguration();
var
  content: string;
  jsAppConfig: TJSONObject;
  key: string;
  jsonValue: TJSONValue;
  jsonScrFolders: TJSONArray;
  idx: Integer;
  foldername: string;
begin
  Assert(FileExists(ConfigFileName),
    Format('[AppConfig Error] Missing config file: %s', [ConfigFileName]));
  content := TFile.ReadAllText(ConfigFileName);
  jsAppConfig := TJSONObject.ParseJSONValue(content) as TJSONObject;
  if jsAppConfig = nil then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Invalid JSON format of file %s',
      [ConfigFileName]));
  key := 'SourceFolders';
  jsonValue := GetConfigValue(jsAppConfig, key);
  if not(jsonValue is TJSONArray) then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Key %s has invalid value, expected array.',
      [key]));
  jsonScrFolders := jsonValue as TJSONArray;
  if jsonScrFolders.Count = 0 then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Key %s has no values', [key]));
  SetLength(AppConfiguration.sourceFolders, jsonScrFolders.Count);
  for idx := 0 to jsonScrFolders.Count - 1 do
  begin
    foldername := jsonScrFolders[idx].value;
    if not DirectoryExists(foldername) then
      raise EAssertionFailed.Create
        (Format('[AppConfig Error] One of values "%s" is not existing folder',
        [foldername]));
    AppConfiguration.sourceFolders[idx] := foldername;
  end;
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
  rootFolder: string;
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
  try
    for rootFolder in AppConfiguration.sourceFolders do
    begin
      strList.AddRange(TDirectory.GetFiles(rootFolder, '*.pas',
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
