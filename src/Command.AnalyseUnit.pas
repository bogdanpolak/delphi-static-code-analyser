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
  TReportFormat = (rFormatPlainText, rFormatCsv);

  TAnalyseUnitCommand = class
  private
    class procedure GenerateCsv(const aUnitName: string;
      const methods: TArray<TMethodMetrics>); static;
    class procedure GeneratePlainText(const aUnitName: string;
      const methods: TArray<TMethodMetrics>); static;
  public
    class procedure Execute(const aFileName: string;
      aReportFormat: TReportFormat;
      aDisplayLevelHigherThan: Integer = 0); static;
  end;

implementation

uses
  Model.MetricsCalculator;

class procedure TAnalyseUnitCommand.GeneratePlainText(const aUnitName: string;
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
      [method.Kind, method.FullName, method.Lenght, method.IndentationLevel]));
  end;
end;

var
  CurrentOrderNumber: Integer = 1;

class procedure TAnalyseUnitCommand.GenerateCsv(const aUnitName: string;
  const methods: TArray<TMethodMetrics>);
var
  method: TMethodMetrics;
begin
  for method in methods do
  begin
    writeln(Format('%d,"%s","%s %s",%d,%d', [CurrentOrderNumber, aUnitName,
      method.Kind, method.FullName, method.Lenght, method.IndentationLevel]));
    inc(CurrentOrderNumber);
  end;
end;

class procedure TAnalyseUnitCommand.Execute(const aFileName: string;
  aReportFormat: TReportFormat; aDisplayLevelHigherThan: Integer = 0);
var
  unitMetrics1: TUnitMetrics;
  methods: TArray<TMethodMetrics>;
begin
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
  case aReportFormat of
    rFormatPlainText:
      GeneratePlainText(unitMetrics1.Name, methods);
    rFormatCsv:
      GenerateCsv(unitMetrics1.Name, methods);
  end;
  unitMetrics1.Free;
end;

end.
