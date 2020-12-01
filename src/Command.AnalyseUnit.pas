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
  public
    class procedure Execute_CodeAnalysis(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateCsv(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
  end;

implementation

uses
  Model.MetricsCalculator;

class procedure TAnalyseUnitCommand.Execute_CodeAnalysis(const aFileName
  : string; aDisplayLevelHigherThan: Integer = 0);
var
  UnitMetrics: TUnitMetrics;
  idx: Integer;
  MethodMetrics: TMethodMetrics;
  isFirst: Boolean;
begin
  try
    UnitMetrics := TUnitCalculator.Calculate(aFileName);
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]));
      raise;
    end;
  end;
  isFirst := True;
  for idx := 0 to UnitMetrics.MethodsCount - 1 do
  begin
    MethodMetrics := UnitMetrics.GetMethod(idx);
    if MethodMetrics.IndentationLevel >= aDisplayLevelHigherThan then
    begin
      if isFirst then
        writeln(UnitMetrics.Name);
      isFirst := False;
      writeln('  - ', MethodMetrics.ToString);
    end;
  end;
  UnitMetrics.Free;
end;

class procedure TAnalyseUnitCommand.Execute_GenerateCsv(const aFileName: string;
  aDisplayLevelHigherThan: Integer);
var
  UnitMetrics: TUnitMetrics;
  MethodMetrics: TMethodMetrics;
  methods: TArray<TMethodMetrics>;
begin
  try
    UnitMetrics := TUnitCalculator.Calculate(aFileName);
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]));
      raise;
    end;
  end;
  methods := UnitMetrics.FilterMethods(aDisplayLevelHigherThan);
  for MethodMetrics in methods do
    writeln(Format('"%s"'#9'"%s %s"'#9'%d'#9'%d', [UnitMetrics.Name,
      MethodMetrics.Kind, MethodMetrics.FullName, MethodMetrics.Lenght,
      MethodMetrics.IndentationLevel]));
  UnitMetrics.Free;
end;

end.
