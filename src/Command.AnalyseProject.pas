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
  Metrics.ClassM,
  Metrics.ClassMethod,
  Filters.Method;

type
  TAnalyseProjectCommand = class
  private
    fReport: TStringList;
    fProjectMetrics: TProjectMetrics;
    procedure GenerateCsv(const methods: TArray<TUnitMethodMetrics>);
    procedure GenerateMethodReportConsole(const methods
      : TArray<TUnitMethodMetrics>);
    procedure GenerateClassReportConsole(const aClassMetrics: TClassMetrics);
  public
    constructor Create;
    destructor Destroy; override;
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

destructor TAnalyseProjectCommand.Destroy;
begin
  fProjectMetrics.Free;
  fReport.Free;
  inherited;
end;

procedure TAnalyseProjectCommand.SaveReportToFile(const aFileName: string);
begin
  fReport.SaveToFile(aFileName);
end;

procedure TAnalyseProjectCommand.GenerateClassReportConsole(const aClassMetrics
  : TClassMetrics);
var
  method: TClassMethodMetrics;
  prefix: string;
begin
  writeln(Format('%s = class',[aClassMetrics.NameOfClass]));
  for method in aClassMetrics.GetMethods do
  begin
    case method.Visibility of
      visPrivate: prefix := '-';
      visProtected: prefix := '!';
      visPublic: prefix := '+';
    end;
    writeln(Format('    %s %s',[prefix, method.Name]));
  end;
end;

procedure TAnalyseProjectCommand.GenerateMethodReportConsole
  (const methods: TArray<TUnitMethodMetrics>);
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
  classMetricsList: TArray<TClassMetrics>;
  classMetrics: TClassMetrics;
begin
  fReport.Clear;
  for idx := 0 to High(aFiles) do
  begin
    Write(Format('Progress: %d. (files: %d/%d)'#13,
      [round(100 / Length(aFiles) * idx), idx, Length(aFiles)]));
    TProjectCalculator.Calculate(aFiles[idx], fProjectMetrics);
  end;
  classMetricsList := fProjectMetrics.GetClassesAll();
  methods := fProjectMetrics.FilterMethods(aMethodFilters);
  // ---- console report -----
  for classMetrics in classMetricsList do
    GenerateClassReportConsole(classMetrics);
  writeln;
  GenerateMethodReportConsole(methods);
  // --------
  GenerateCsv(methods);
end;

end.
