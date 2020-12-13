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
  Filters.Method;

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
    procedure DefineFiltersUsingConfiguration;
    procedure ApplicationRun;
  public
    constructor Create(const aAppConfiguration: IAppConfiguration);
    destructor Destory;
    class procedure Run(const aAppConfiguration: IAppConfiguration); static;
  end;

implementation

uses
  Command.GenerateXml,
  Filters.Concrete;

constructor TMain.Create(const aAppConfiguration: IAppConfiguration);
begin
  Assert(aAppConfiguration <> nil);
  fAppConfiguration := aAppConfiguration;
  cmdAnalyseUnit := TAnalyseUnitCommand.Create;
  fReport := TStringList.Create;
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

procedure TMain.DefineFiltersUsingConfiguration();
var
  complexityLevel: Integer;
  methodLength: Integer;
begin
  fMethodFilters.Clear;
  complexityLevel := fAppConfiguration.GetFilterComplexityLevel();
  methodLength := fAppConfiguration.GetFilterMethodLength();
  if fAppConfiguration.HasFilters() then
  begin
    fMethodFilters.AddRange([
      { } TComplexityGreaterEqual.Create(complexityLevel),
      { } TLengthGreaterEqual.Create(methodLength)]);
  end;
end;

procedure TMain.ApplicationRun();
var
  files: TArray<string>;
  fname: string;
  unitReport: TStrings;
begin
  fAppConfiguration.Initialize;
  DefineFiltersUsingConfiguration();
  WriteApplicationTitle();
  case ApplicationMode of
    amComplexityAnalysis:
      begin
        fReport.Clear;
        fReport.Add(Format('"%s","%s","%s","%s","%s"', ['No', 'Unit location',
          'Method', 'Length', 'Complexity']));
        files := GetUnits();
        for fname in files do
        begin
          cmdAnalyseUnit.Execute(fname, fMethodFilters);
          unitReport := cmdAnalyseUnit.GetUnitReport();
          fReport.AddStrings(unitReport);
        end;
        fname := fAppConfiguration.GetOutputFile();
        fReport.SaveToFile(fname);
      end;
    amFileAnalysis:
      begin
        fMethodFilters.Clear;
        cmdAnalyseUnit.Execute('..\test\data\test04.pas', fMethodFilters);
      end;
    amGenerateXml:
      begin
        fMethodFilters.Clear;
        TGenerateXmlCommand.Generate('..\test\data\testunit.pas');
      end;
  end;
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
  readln;
end;

end.
