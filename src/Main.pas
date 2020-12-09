unit Main;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Math,
  System.Generics.Collections,
  {}
  Configuration.AppConfig,
  Command.AnalyseUnit,
  Model.Filters.MethodFiltes;

type
  TApplicationMode = (amComplexityAnalysis, amFileAnalysis, amGenerateXml);

  TMain = class
  public const
    ApplicationMode: TApplicationMode = amComplexityAnalysis;
  private
    fAppConfiguration: IAppConfiguration;
    cmdAnalyseUnit: TAnalyseUnitCommand;
    fReport: TStringList;
    fMethodFilters: TMethodFilters;
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
  Command.GenerateXml,
  Model.Filters.Concrete;

constructor TMain.Create(const aAppConfiguration: IAppConfiguration);
begin
  Assert(aAppConfiguration <> nil);
  fAppConfiguration := aAppConfiguration;
  cmdAnalyseUnit := TAnalyseUnitCommand.Create;
  fReport := TStringList.Create;
  fMethodFilters := TMethodFilters.Create;
  fMethodFilters := TMethodFilters.Create;
end;

destructor TMain.Destory;
begin
  fMethodFilters.Free;
  fReport.Free;
  cmdAnalyseUnit.Free;
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
    Result := ['..\test\data\test04.pas'];
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
var
  files: TArray<string>;
  fname: string;
  unitReport: TStrings;
begin
  fAppConfiguration.Initialize;
  fMethodFilters.Clear;
  files := GetUnits();
  WriteApplicationTitle();
  fReport.Clear;
  fReport.Add(Format('"%s","%s","%s","%s","%s"', ['No', 'Unit location',
    'Method', 'Length', 'Complexity']));
  for fname in files do
  begin
    case ApplicationMode of
      amComplexityAnalysis, amFileAnalysis:
        begin
          if ApplicationMode = amComplexityAnalysis then
            fMethodFilters.AddRange([
              { } TComplexityGreaterThen.Create(7),
              { } TLengthGreaterThen.Create(200)]);
          cmdAnalyseUnit.Execute(fname, fMethodFilters);
          unitReport := cmdAnalyseUnit.GetUnitReport();
          fReport.AddStrings(unitReport);
        end;
      amGenerateXml:
        TGenerateXmlCommand.Generate(fname);
    end;
  end;
  fname := fAppConfiguration.GetOutputFile();
  fReport.SaveToFile(fname);
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
