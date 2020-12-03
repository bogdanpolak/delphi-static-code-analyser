unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  {}
  Configuration.AppConfig,
  Command.AnalyseUnit;

type
  TApplicationMode = (amComplexityAnalysis, amFileAnalysis, amGenerateXml);

  TMain = class
  public const
    ApplicationMode: TApplicationMode = amComplexityAnalysis;
  private
    fAppConfiguration: IAppConfiguration;
    fAnalyseUnitCommand: TAnalyseUnitCommand;
    fReport: TStringList;
    function GetUnits: TArray<string>;
    procedure WriteApplicationTitle;
    procedure ApplicationRun;
  public
    constructor Create(const aAppConfiguration: IAppConfiguration);
    destructor Destory;
    class procedure Run(const aAppConfiguration: IAppConfiguration); static;
  end;

implementation

uses
  Command.GenerateXml;

constructor TMain.Create(const aAppConfiguration: IAppConfiguration);
begin
  Assert(aAppConfiguration <> nil);
  fAppConfiguration := aAppConfiguration;
  fAnalyseUnitCommand := TAnalyseUnitCommand.Create;
  fReport := TStringList.Create;
end;

destructor TMain.Destory;
begin
  fReport.Free;
  fAnalyseUnitCommand.Free;
end;

procedure TMain.WriteApplicationTitle();
begin
  if ApplicationMode in [amComplexityAnalysis, amFileAnalysis] then
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
  unitReport: TStrings;
begin
  fAppConfiguration.Initialize;
  files := GetUnits();
  WriteApplicationTitle();
  fReport.Clear;
  fReport.Add(Format('"%s","%s","%s","%s","%s"', ['No', 'Unit location',
    'Method', 'Length', 'Complexity']));
  for fname in files do
  begin
    case ApplicationMode of
      amComplexityAnalysis:
        begin
          fAnalyseUnitCommand.Execute(fname, DISPLAY_LevelHigherThan);
          unitReport := fAnalyseUnitCommand.GetUnitReport();
          fReport.AddStrings(unitReport);
        end;
      amFileAnalysis:
        fAnalyseUnitCommand.Execute(fname);
      amGenerateXml:
        TGenerateXmlCommand.Execute(fname);
    end;
  end;
  fname := fAppConfiguration.GetOutputFile();
  fReport.SaveToFile(fname);
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
