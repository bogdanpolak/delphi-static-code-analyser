unit Configuration.JsonAppConfig;

interface

uses
  System.SysUtils,
  System.JSON,
  System.IOUtils,
  System.Generics.Collections,
  Configuration.AppConfig;

type
  TJsonAppConfiguration = class(TInterfacedObject, IAppConfiguration)
  private const
    DefaultConfigFileName = 'appconfig.json';
  private
    fConfigFileName: string;
    fLoaded: boolean;
    fSourceFolders: TArray<string>;
    fOutputFile: string;
    fComplexityLevel: Integer;
    fMethodLength: Integer;
    function GetConfigValue(config: TJSONObject;
      const aKey: string): TJSONValue;
    procedure ReadConfiguration;
  public
    constructor Create;
    procedure Initialize;
    function GetSourceFolders: TArray<string>;
    function GetOutputFile: string;
    function GetFilterComplexityLevel: integer;
    function GetFilterMethodLength: integer;
  end;

function BuildAppConfiguration(): IAppConfiguration;

implementation

function BuildAppConfiguration(): IAppConfiguration;
begin
  Result := TJsonAppConfiguration.Create;
end;

constructor TJsonAppConfiguration.Create;
begin
  fConfigFileName := DefaultConfigFileName;
  fLoaded := False;
end;

function TJsonAppConfiguration.GetConfigValue(config: TJSONObject; const aKey: string)
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

function TJsonAppConfiguration.GetOutputFile: string;
begin
  Initialize;
  Result := fOutputFile;
end;

function TJsonAppConfiguration.GetSourceFolders: TArray<string>;
begin
  Initialize;
  Result := fSourceFolders;
end;

function TJsonAppConfiguration.GetFilterComplexityLevel: integer;
begin
  Initialize;
  Result := fComplexityLevel;
end;

function TJsonAppConfiguration.GetFilterMethodLength: integer;
begin
  Initialize;
  Result := fMethodLength;
end;

procedure TJsonAppConfiguration.Initialize;
begin
  if fLoaded then
    exit;
  ReadConfiguration();
  fLoaded := True;
end;

procedure TJsonAppConfiguration.ReadConfiguration();
var
  content: string;
  jsAppConfig: TJSONObject;
  key: string;
  jsonValue: TJSONValue;
  jsonScrFolders: TJSONArray;
  idx: Integer;
  foldername: string;
  jsonFilters: TJSONObject;
begin
  Assert(FileExists(fConfigFileName),
    Format('[AppConfig Error] Missing config file: %s', [fConfigFileName]));
  content := TFile.ReadAllText(fConfigFileName);
  jsAppConfig := TJSONObject.ParseJSONValue(content) as TJSONObject;
  if jsAppConfig = nil then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Invalid JSON format of file %s',
      [fConfigFileName]));
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
  SetLength(fSourceFolders, jsonScrFolders.Count);
  for idx := 0 to jsonScrFolders.Count - 1 do
  begin
    foldername := jsonScrFolders[idx].value;
    if not DirectoryExists(foldername) then
      raise EAssertionFailed.Create
        (Format('[AppConfig Error] One of values "%s" is not existing folder',
        [foldername]));
    fSourceFolders[idx] := foldername;
  end;
  // --
  key := 'OutputFile';
  fOutputFile := GetConfigValue(jsAppConfig, key).Value;
  if fOutputFile='' then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Expected output file path in "%s".',
      [key]));
  // --
  key := 'Filters';
  jsonValue := GetConfigValue(jsAppConfig, key);
  if fOutputFile='' then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Expected output file path in "%s".',
      [key]));
  if not(jsonValue is TJSONObject) then
    raise EAssertionFailed.Create
      (Format('[AppConfig Error] Key %s has invalid value, expected object.',
      [key]));
  jsonFilters := jsonValue as TJSONObject;
  fComplexityLevel := 0;
  fMethodLength := 0;
  jsonFilters.TryGetValue<Integer>('ComplexityLevel',fComplexityLevel);
  jsonFilters.TryGetValue<Integer>('MethodLength',fMethodLength);
end;

end.
