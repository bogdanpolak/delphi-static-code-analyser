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
  Command.AnalyseProject,
  Filters.Method;

type
  TApplicationMode = (amComplexityAnalysis, amFileAnalysis, amGenerateXml);

const
  ApplicationMode: TApplicationMode = amFileAnalysis;
  SINGLE_FileName ='..\test\data\test05.UnitWithClass.pas';
  XML_FileName = '..\test\data\testunit.pas';

type
  TMain = class
  private
    fAppConfiguration: IAppConfiguration;
    cmdAnalyseProject: TAnalyseProjectCommand;
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
  cmdAnalyseProject := TAnalyseProjectCommand.Create;
  fMethodFilters := TMethodFilters.Create;
end;

destructor TMain.Destory;
begin
  fMethodFilters.Free;
  cmdAnalyseProject.Free;
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
begin
  fAppConfiguration.Initialize;
  case ApplicationMode of
    amComplexityAnalysis:
      begin
        WriteApplicationTitle();
        files := GetUnits();
        DefineFiltersUsingConfiguration();
        cmdAnalyseProject.Execute(files, fMethodFilters);
        cmdAnalyseProject.SaveReportToFile(fAppConfiguration.GetOutputFile());
      end;
    amFileAnalysis:
      begin
        cmdAnalyseProject.Execute([SINGLE_FileName]);
      end;
    amGenerateXml:
      begin
        fMethodFilters.Clear;
        TGenerateXmlCommand.Generate(XML_FileName);
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
{$IFDEF DEBUG}
  Write('... [press enter to close]');
  readln;
{$ENDIF}
end;

end.
