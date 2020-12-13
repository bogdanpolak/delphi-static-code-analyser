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
  Metrics.UnitM,
  Metrics.UnitMethod,
  Filters.Method;

type
  TAnalyseProjectCommand = class
  private
    fReport: TStringList;

    procedure GenerateCsv(const aUnitName: string;
      const methods: TArray<TUnitMethodMetrics>);
    procedure GeneratePlainText(const aUnitName: string;
      const methods: TArray<TUnitMethodMetrics>);
  public
    constructor Create;
    destructor Destory;
    procedure Execute(const aFiles: TArray<string>;
      aMethodFilters: TMethodFilters = nil);
    procedure SaveReportToFile(const aFileName: string);
  end;

implementation

uses
  Calculators.UnitMetrics;

constructor TAnalyseProjectCommand.Create;
begin
  fReport := TStringList.Create;
end;

destructor TAnalyseProjectCommand.Destory;
begin
  fReport.Free;
end;

procedure TAnalyseProjectCommand.SaveReportToFile(const aFileName: string);
begin
  fReport.SaveToFile(aFileName);
end;

procedure TAnalyseProjectCommand.GeneratePlainText(const aUnitName: string;
  const methods: TArray<TUnitMethodMetrics>);
var
  Method: TUnitMethodMetrics;
  isFirst: Boolean;
begin
  isFirst := True;
  for Method in methods do
  begin
    if isFirst then
      writeln(aUnitName);
    isFirst := False;
    writeln(Format('  - %s %s  =  [Lenght: %d] [Level: %d]',
      [Method.Kind, Method.FullName, Method.Lenght, Method.Complexity]));
  end;
end;

var
  CurrentOrderNumber: Integer = 1;

procedure TAnalyseProjectCommand.GenerateCsv(const aUnitName: string;
  const methods: TArray<TUnitMethodMetrics>);
var
  Method: TUnitMethodMetrics;
begin
  for Method in methods do
  begin
    fReport.Add(Format('%d,"%s","%s %s",%d,%d', [CurrentOrderNumber, aUnitName,
      Method.Kind, Method.FullName, Method.Lenght, Method.Complexity]));
    inc(CurrentOrderNumber);
  end;
end;

procedure TAnalyseProjectCommand.Execute(const aFiles: TArray<string>;
  aMethodFilters: TMethodFilters = nil);
var
  unitFileName: string;
  UnitMetrics: TUnitMetrics;
  methods: TArray<TUnitMethodMetrics>;
begin
  fReport.Clear;
  fReport.Add(Format('"%s","%s","%s","%s","%s"', ['No', 'Unit location',
    'Method', 'Length', 'Complexity']));
  for unitFileName in aFiles do
  begin
    try
      UnitMetrics := TUnitCalculator.Calculate(unitFileName);
    except
      on E: ESyntaxTreeException do
      begin
        writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]));
        raise;
      end;
    end;
    methods := UnitMetrics.FilterMethods(aMethodFilters);
    GeneratePlainText(UnitMetrics.Name, methods);
    GenerateCsv(UnitMetrics.Name, methods);
    UnitMetrics.Free;
  end;
end;

end.
