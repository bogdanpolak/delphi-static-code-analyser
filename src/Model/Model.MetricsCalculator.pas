unit Model.MetricsCalculator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  DelphiAST,
  DelphiAST.Consts,
  DelphiAST.Classes,
  DelphiAST.Writer,
  SimpleParser.Lexer.Types,
  DelphiAST.SimpleParserEx,
  IncludeHandler,
  {}
  Model.MethodMetrics,
  Model.UnitMetrics;

type
  TUnitCalculator = class
  private
    fStringStream: TStringStream;
    fTreeBuilder: TPasSyntaxTreeBuilder;
    procedure LoadUnit(const aFileName: string);
    procedure CalculateMetrics(var aUnitMetrics: TUnitMetrics);
  public
    constructor Create();
    destructor Destroy; override;
    class procedure Calculate(var aUnitMetrics: TUnitMetrics); static;
  end;

implementation

uses
  Utils.IntegerArray;

constructor TUnitCalculator.Create();
begin
  fStringStream := TStringStream.Create;
  fTreeBuilder := TPasSyntaxTreeBuilder.Create;
  {
    if aIncludeFolder <> '' then
    begin
    fTreeBuilder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
  }
end;

destructor TUnitCalculator.Destroy;
begin
  fTreeBuilder.Free;
  fStringStream.Free;
  inherited;
end;

procedure TUnitCalculator.LoadUnit(const aFileName: string);
begin
  fStringStream.Clear;
  fStringStream.LoadFromFile(aFileName);
  fStringStream.Position := 0;
end;

// ---------------------------------------------------------------------
// calculators
// ---------------------------------------------------------------------

var
  fLineIndetation: TDictionary<Integer, Integer>;

procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  indentation: Integer;
begin
  if aNode <> nil then
  begin
    if fLineIndetation.TryGetValue(aNode.Line, indentation) then
    begin
      if aNode.Col < indentation then
        fLineIndetation[aNode.Line] := aNode.Col - 1;
    end
    else
      fLineIndetation.Add(aNode.Line, aNode.Col - 1);
    for child in aNode.ChildNodes do
      MinIndetationNodeWalker(child);
  end;
end;

function CalculateMethodMaxIndent(const aMethodNode
  : TCompoundSyntaxNode): Integer;
var
  statements: TSyntaxNode;
  step: Integer;
  indentations: TIntegerArray;
begin
  Result := 0;
  fLineIndetation := TDictionary<Integer, Integer>.Create();
  try
    statements := aMethodNode.FindNode(ntStatements);
    MinIndetationNodeWalker(statements);
    indentations := fLineIndetation.Values.ToArray.GetDistinctArray();
    if Length(indentations) >= 2 then
    begin
      step := indentations[1] - indentations[0];
      Result := (indentations[High(indentations)] - indentations[0]) div step;
    end;
  finally
    fLineIndetation.Free;
  end;
end;

function CalculateMethodLength(const aMethodNode: TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  if statements <> nil then
    Result := statements.EndLine - aMethodNode.Line + 1
  else
    Result := 1;
end;

procedure CalculateMethod(aMethodNode: TCompoundSyntaxNode;
  var aUnitMetrics: TUnitMetrics);
var
  methodKind: string;
  methodName: string;
  methodMetics: TMethodMetrics;
begin
  methodKind := aMethodNode.GetAttribute(anKind);
  methodName := aMethodNode.GetAttribute(anName);
  methodMetics := TMethodMetrics.Create(methodKind, methodName);
  with methodMetics do
  begin
    SetLenght(CalculateMethodLength(aMethodNode));
    SetMaxIndentation(CalculateMethodMaxIndent(aMethodNode));
  end;
  aUnitMetrics.AddMethod(methodMetics);
end;

// ---------------------------------------------------------------------

procedure TUnitCalculator.CalculateMetrics(var aUnitMetrics: TUnitMetrics);
var
  rootNode: TSyntaxNode;
  implementationNode: TSyntaxNode;
  child: TSyntaxNode;
begin
  try
    rootNode := fTreeBuilder.Run(fStringStream);
    try
      // ---- interfaceNode := rootNode.FindNode(ntInterface);
      implementationNode := rootNode.FindNode(ntImplementation);
      for child in implementationNode.ChildNodes do
        if child.Typ = ntMethod then
        begin
          CalculateMethod(child as TCompoundSyntaxNode, aUnitMetrics);
        end;
    finally
      rootNode.Free;
    end;
  except
    on E: ESyntaxTreeException do
    begin
      writeln(Format('[%d, %d] %s', [E.Line, E.Col, E.Message]) + sLineBreak +
        sLineBreak + TSyntaxTreeWriter.ToXML(E.syntaxTree, True));
      raise;
    end;
  end;
end;

class procedure TUnitCalculator.Calculate(var aUnitMetrics: TUnitMetrics);
var
  calculator: TUnitCalculator;
begin
  calculator := TUnitCalculator.Create();
  try
    calculator.LoadUnit(aUnitMetrics.Name);
    calculator.CalculateMetrics(aUnitMetrics);
  finally
    calculator.Free;
  end;
end;

end.
