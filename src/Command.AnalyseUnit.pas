unit Command.AnalyseUnit;

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
  Model.UnitMetrics,
  Model.MethodMetrics;

type
  TAnalyseUnitCommand = class
  private
    fUnitReport: TStringList;
    procedure GenerateCsv(const aUnitName: string;
      const methods: TArray<TMethodMetrics>);
    procedure GeneratePlainText(const aUnitName: string;
      const methods: TArray<TMethodMetrics>);
  public
    constructor Create;
    destructor Destory;
    procedure Execute(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0);
    function GetUnitReport: TStrings;
  end;

implementation

uses
  Model.MetricsCalculator;

constructor TAnalyseUnitCommand.Create;
begin
  fUnitReport := TStringList.Create;
end;

destructor TAnalyseUnitCommand.Destory;
begin
  fUnitReport.Free;
end;

function TAnalyseUnitCommand.GetUnitReport: TStrings;
begin
  Result := fUnitReport
end;

procedure TAnalyseUnitCommand.GeneratePlainText(const aUnitName: string;
  const methods: TArray<TMethodMetrics>);
var
  method: TMethodMetrics;
  isFirst: Boolean;
begin
  isFirst := True;
  for method in methods do
  begin
    if isFirst then
      writeln(aUnitName);
    isFirst := False;
    writeln(Format('  - %s %s  =  [Lenght: %d] [Level: %d]',
      [method.Kind, method.FullName, method.Lenght, method.Complexity]));
  end;
end;

var
  CurrentOrderNumber: Integer = 1;

procedure TAnalyseUnitCommand.GenerateCsv(const aUnitName: string;
  const methods: TArray<TMethodMetrics>);
var
  method: TMethodMetrics;
begin
  for method in methods do
  begin
    fUnitReport.Add(Format('%d,"%s","%s %s",%d,%d', [CurrentOrderNumber,
      aUnitName, method.Kind, method.FullName, method.Lenght,
      method.Complexity]));
    inc(CurrentOrderNumber);
  end;
end;

procedure TAnalyseUnitCommand.Execute(const aFileName: string;
  aDisplayLevelHigherThan: Integer = 0);
var
  unitMetrics1: TUnitMetrics;
  methods: TArray<TMethodMetrics>;
begin
  fUnitReport.Clear;
  try
    unitMetrics1 := TUnitCalculator.Calculate(aFileName);
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]));
      raise;
    end;
  end;
  methods := unitMetrics1.FilterMethods(aDisplayLevelHigherThan);
  GeneratePlainText(unitMetrics1.Name, methods);
  GenerateCsv(unitMetrics1.Name, methods);
  unitMetrics1.Free;
end;

end.
