unit Command.AnalyseProject;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  SimpleParser.Lexer.Types,
  DelphiAST.SimpleParserEx,
  IncludeHandler,
  {}
  Metrics.Project,
  Metrics.UnitM,
  Metrics.UnitMethod,
  Filters.Method;

type
  TAnalyseProjectCommand = class
  private
    fReport: TStringList;
    fProjectMetrics: TProjectMetrics;
    procedure GenerateCsv(const methods: TArray<TUnitMethodMetrics>);
    procedure GeneratePlainText(const methods: TArray<TUnitMethodMetrics>);
  public
    constructor Create;
    destructor Destory;
    procedure Execute(const aFiles: TArray<string>;
      aMethodFilters: TMethodFilters = nil);
    procedure SaveReportToFile(const aFileName: string);
  end;

implementation

uses
  Calculators.ProjectMetrics;

constructor TAnalyseProjectCommand.Create;
begin
  fReport := TStringList.Create;
  fProjectMetrics := TProjectMetrics.Create;
end;

destructor TAnalyseProjectCommand.Destory;
begin
  fProjectMetrics.Free;
  fReport.Free;
end;

procedure TAnalyseProjectCommand.SaveReportToFile(const aFileName: string);
begin
  fReport.SaveToFile(aFileName);
end;

procedure TAnalyseProjectCommand.GeneratePlainText(const methods
  : TArray<TUnitMethodMetrics>);
var
  Method: TUnitMethodMetrics;
  previousUnit: string;
begin
  previousUnit := '';
  for Method in methods do
  begin
    if Method.FullUnitName <> previousUnit then
      writeln(Method.FullUnitName);
    previousUnit := Method.FullUnitName;
    writeln(Format('  - %s %s  =  [Lenght: %d] [Level: %d]',
      [Method.Kind, Method.Name, Method.Lenght, Method.Complexity]));
  end;
end;

var
  CurrentOrderNumber: Integer = 1;

procedure TAnalyseProjectCommand.GenerateCsv(const methods
  : TArray<TUnitMethodMetrics>);
var
  Method: TUnitMethodMetrics;
begin
  fReport.Add(Format('"%s","%s","%s","%s","%s"', ['No', 'Unit location',
    'Method', 'Length', 'Complexity']));
  for Method in methods do
  begin
    fReport.Add(Format('%d,"%s","%s %s",%d,%d', [CurrentOrderNumber,
      Method.FullUnitName, Method.Kind, Method.Name, Method.Lenght,
      Method.Complexity]));
    inc(CurrentOrderNumber);
  end;
end;

procedure TAnalyseProjectCommand.Execute(const aFiles: TArray<string>;
  aMethodFilters: TMethodFilters = nil);
var
  idx: Integer;
  methods: TArray<TUnitMethodMetrics>;
begin
  fReport.Clear;
  for idx := 0 to High(aFiles) do
  begin
    Write(Format('Progress: %d. (files: %d/%d)'#13,
      [round(100 / Length(aFiles) * idx), idx, Length(aFiles)]));
    TProjectCalculator.Calculate(aFiles[idx], fProjectMetrics);
  end;
  methods := fProjectMetrics.FilterMethods(aMethodFilters);
  GeneratePlainText(methods);
  GenerateCsv(methods);
end;

end.
