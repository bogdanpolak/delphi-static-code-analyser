unit Calculators.ProjectMetrics;

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
  Metrics.UnitMethod,
  Metrics.UnitM,
  Metrics.Project;

type
  TUnitCalculator = class
  private
    function CalculateMethodLength(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    function CalculateMethodMaxIndent(slCode: TStringList;
      const aMethodNode: TCompoundSyntaxNode): Integer;
    procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
    function CalculateUnit(const aFileName: string; slUnitCode: TStringList;
      const aRootNode: TSyntaxNode): TUnitMetrics;
    function CalculateMethod(slUnitCode: TStringList;
      aMethodNode: TCompoundSyntaxNode): TUnitMethodMetrics;
  public
    class function Calculate(const aFileName: string;
      const aProjectMetrics: TProjectMetrics): TUnitMetrics; static;
  end;

implementation

uses
  Utils.IntegerArray;

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

function TUnitCalculator.CalculateMethodMaxIndent(slCode: TStringList;
  const aMethodNode: TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
  row1: Integer;
  row2: Integer;
  row: Integer;
  Line: string;
  indent: Integer;
  indentationList: TList<Integer>;
  indentations: TIntegerArray;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  if statements = nil then
    Exit(0);
  row1 := statements.Line;
  row2 := statements.EndLine;
  indentationList := TList<Integer>.Create;;
  try
    for row := row1 to row2 do
    begin
      Line := slCode[row - 1];
      indent := 0;
      while (indent < Length(Line)) and (Line[indent + 1] = ' ') do
        inc(indent);
      if indent > 0 then
        indentationList.Add(indent);
    end;
    indentations := indentationList.ToArray.GetDistinctArray();
    Result := Length(indentations);
  finally
    indentationList.Free;
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

function TUnitCalculator.CalculateMethod(slUnitCode: TStringList;
  aMethodNode: TCompoundSyntaxNode): TUnitMethodMetrics;
var
  methodKind: string;
  methodName: string;
  methodLength: Integer;
  methodComplexity: Integer;
begin
  methodKind := aMethodNode.GetAttribute(anKind);
  methodName := aMethodNode.GetAttribute(anName);
  methodLength := CalculateMethodLength(aMethodNode);
  methodComplexity := CalculateMethodMaxIndent(slUnitCode, aMethodNode);
  Result := TUnitMethodMetrics.Create(methodKind, methodName)
    .SetLenght(methodLength).SetComplexity(methodComplexity);
end;

// ---------------------------------------------------------------------

function TUnitCalculator.CalculateUnit(const aFileName: string;
  slUnitCode: TStringList; const aRootNode: TSyntaxNode): TUnitMetrics;
var
  implementationNode: TSyntaxNode;
  methodMetics: TUnitMethodMetrics;
  child: TSyntaxNode;
begin
  // ---- interfaceNode := rootNode.FindNode(ntInterface);
  Result := TUnitMetrics.Create(aFileName);
  implementationNode := aRootNode.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
    if child.Typ = ntMethod then
    begin
      methodMetics := CalculateMethod(slUnitCode, child as TCompoundSyntaxNode);
      Result.AddMethod(methodMetics);
    end;
end;

class function TUnitCalculator.Calculate(const aFileName: string;
  const aProjectMetrics: TProjectMetrics): TUnitMetrics;
var
  syntaxRootNode: TSyntaxNode;
  slUnitCode: TStringList;
  calculator: TUnitCalculator;
begin
  {
    if aIncludeFolder <> '' then
    begin
    fTreeBuilder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
  }
  syntaxRootNode := TPasSyntaxTreeBuilder.Run(aFileName);
  try
    slUnitCode := TStringList.Create;
    try
      slUnitCode.LoadFromFile(aFileName);
      calculator := TUnitCalculator.Create();
      try
        Result := calculator.CalculateUnit(aFileName, slUnitCode,
          syntaxRootNode);
        aProjectMetrics.AddUnit(Result);
      finally
        calculator.Free;
      end;
    finally
      slUnitCode.Free;
    end;
  finally
    syntaxRootNode.Free;
  end;
end;

end.
