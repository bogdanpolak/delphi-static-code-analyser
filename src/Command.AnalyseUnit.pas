unit Command.AnalyseUnit;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST,
  DelphiAST.Classes,
  DelphiAST.Writer,
  SimpleParser.Lexer.Types,
  DelphiAST.SimpleParserEx,
  IncludeHandler,
  {}
  Model.UnitMetrics,
  Model.MethodMetrics;

type
  TAnalyseUnitCommand = class
  private
    class function GenerateXml(const aStream: TStream): string; static;
  public
    class procedure Execute_CodeAnalysis(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateCsv(const aFileName: string;
      aDisplayLevelHigherThan: Integer = 0); static;
    class procedure Execute_GenerateXML(const aFileName: string); static;
  end;

implementation

uses Model.MetricsCalculator;

class function TAnalyseUnitCommand.GenerateXml(const aStream: TStream): string;
var
  treeBuilder: TPasSyntaxTreeBuilder;
  syntaxTree: TSyntaxNode;
begin
  Result := '';
  treeBuilder := TPasSyntaxTreeBuilder.Create;
  try
    try
      syntaxTree := treeBuilder.Run(aStream);
      Result := TSyntaxTreeWriter.ToXML(syntaxTree, True);
      syntaxTree.Free;
    except
      on E: ESyntaxTreeException do
      begin
        Result := Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak
          + sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True);
      end;
    end;
  finally
    treeBuilder.Free;
  end;
end;

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
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
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
  idx: Integer;
  MethodMetrics: TMethodMetrics;
  methods: TArray<TMethodMetrics>;
begin
  try
    UnitMetrics := TUnitCalculator.Calculate(aFileName);
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
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

class procedure TAnalyseUnitCommand.Execute_GenerateXML(const aFileName
  : string);
var
  stringStream: TStringStream;
  text: string;
begin
  stringStream := TStringStream.Create;
  try
    stringStream.LoadFromFile(aFileName);
    stringStream.Position := 0;
    text := GenerateXml(stringStream);
    writeln(text);
  finally
    stringStream.Free;
  end;

end;

end.
