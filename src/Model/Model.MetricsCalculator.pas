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
    fUnitMetrics: TUnitMetrics;
    procedure LoadUnit(const aFileName: string);
    function CalculateMethodLength(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    function CalculateMethodMaxIndent(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
    procedure CalculateUnit(const aRootNode: TSyntaxNode);
    procedure CalculateMethod(aMethodNode: TCompoundSyntaxNode);
  public
    constructor Create(const aUnitMetrics: TUnitMetrics);
    destructor Destroy; override;
    class function Calculate(const aFileName: string): TUnitMetrics; static;
  end;

implementation

uses
  Utils.IntegerArray;

constructor TUnitCalculator.Create(const aUnitMetrics: TUnitMetrics);
begin
  fStringStream := TStringStream.Create;
  fTreeBuilder := TPasSyntaxTreeBuilder.Create;
  fUnitMetrics := aUnitMetrics;
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

procedure TUnitCalculator.MinIndetationNodeWalker(const aNode: TSyntaxNode);
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

function TUnitCalculator.CalculateMethodMaxIndent(const aMethodNode
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

function TUnitCalculator.CalculateMethodLength(const aMethodNode
  : TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  if statements <> nil then
    Result := statements.EndLine - aMethodNode.Line + 1
  else
    Result := 1;
end;

procedure TUnitCalculator.CalculateMethod(aMethodNode: TCompoundSyntaxNode);
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
  fUnitMetrics.AddMethod(methodMetics);
end;

// ---------------------------------------------------------------------

procedure TUnitCalculator.CalculateUnit(const aRootNode: TSyntaxNode);
var
  implementationNode: TSyntaxNode;
  child: TSyntaxNode;
begin
  // ---- interfaceNode := rootNode.FindNode(ntInterface);
  implementationNode := aRootNode.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
    if child.Typ = ntMethod then
    begin
      CalculateMethod(child as TCompoundSyntaxNode);
    end;
end;

class function TUnitCalculator.Calculate(const aFileName: string): TUnitMetrics;
var
  unitMetrics: TUnitMetrics;
  calculator: TUnitCalculator;
  syntaxRootNode: TSyntaxNode;
begin
  unitMetrics := TUnitMetrics.Create(aFileName);
  try
    calculator := TUnitCalculator.Create(unitMetrics);
    try
      calculator.LoadUnit(aFileName);
      syntaxRootNode := calculator.fTreeBuilder.Run(calculator.fStringStream);
      try
        calculator.CalculateUnit(syntaxRootNode);
        Result := UnitMetrics;
      finally
        syntaxRootNode.Free;
      end;
    finally
      calculator.Free;
    end;
  except
    on E: Exception do
    begin
      unitMetrics.Free;
      raise;
    end;
  end;
end;

end.
