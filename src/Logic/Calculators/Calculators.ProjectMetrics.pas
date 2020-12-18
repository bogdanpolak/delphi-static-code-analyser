unit Calculators.ProjectMetrics;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.StrUtils,
  System.TypInfo,
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
  TProjectCalculator = class
  private
    function CalculateMethodLength(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    function CalculateMethodMaxIndent(slCode: TStringList;
      const aMethodNode: TCompoundSyntaxNode): Integer;
    procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
    procedure CalculateUnit(const aUnitName: string;
      const slUnitCode: TStringList; const aRootNode: TSyntaxNode;
      const aProjectMetrics: TProjectMetrics);
    function CalculateMethod(const aNameOfUnit: string; slUnitCode: TStringList;
      aMethodNode: TCompoundSyntaxNode): TUnitMethodMetrics;
  public
    class procedure Calculate(const aFileName: string;
      const aProjectMetrics: TProjectMetrics); static;
  end;

implementation

uses
  Utils.IntegerArray;

// ---------------------------------------------------------------------
// calculators
// ---------------------------------------------------------------------

var
  fLineIndetation: TDictionary<Integer, Integer>;

procedure TProjectCalculator.MinIndetationNodeWalker(const aNode: TSyntaxNode);
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

function TProjectCalculator.CalculateMethodMaxIndent(slCode: TStringList;
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

function TProjectCalculator.CalculateMethodLength(const aMethodNode
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

function TProjectCalculator.CalculateMethod(const aNameOfUnit: string;
  slUnitCode: TStringList; aMethodNode: TCompoundSyntaxNode)
  : TUnitMethodMetrics;
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
  Result := TUnitMethodMetrics.Create(aNameOfUnit, methodKind, methodName)
    .SetLenght(methodLength).SetComplexity(methodComplexity);
end;

// ---------------------------------------------------------------------

function AttributeNameToStr(aAttributeName: TAttributeName): string;
begin
  Result := GetEnumName(TypeInfo(TAttributeName), integer(aAttributeName));
end;

procedure InterfaceWalker(const aNode: TSyntaxNode; aLevel: Integer = 0);
var
  node: TSyntaxNode;
  t: TSyntaxNodeType;
  arr: TArray<string>;
  pair :TPair<TAttributeName, string>;
  s: string;
  idx: Integer;
  value: string;
begin
  t := aNode.Typ;
  arr := [];
  SetLength(arr, Length(aNode.Attributes));
  for idx := 0 to High(aNode.Attributes) do
  begin
    pair := aNode.Attributes[idx];
    arr[idx] := Format('%s=%s', [AttributeNameToStr(pair.Key), pair.value]);
  end;
  // value := IfThen(aNode is TValuedSyntaxNode, (aNode as TValuedSyntaxNode).Value, '')
  if aNode is TValuedSyntaxNode then
    value := (aNode as TValuedSyntaxNode).Value
  else
    value := '';
  s := String.Join(';', arr);
  if s = '' then
    s := '';
  for node in aNode.ChildNodes do
    InterfaceWalker(node, aLevel + 1);
end;

procedure TProjectCalculator.CalculateUnit(const aUnitName: string;
  const slUnitCode: TStringList; const aRootNode: TSyntaxNode;
  const aProjectMetrics: TProjectMetrics);
var
  um: TUnitMetrics;
  implementationNode: TSyntaxNode;
  methodMetics: TUnitMethodMetrics;
  child: TSyntaxNode;
  interfaceNode: TSyntaxNode;
begin
  um := TUnitMetrics.Create(aUnitName);
  interfaceNode := aRootNode.FindNode(ntInterface);
  InterfaceWalker(interfaceNode);
  implementationNode := aRootNode.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
  begin
    if child.Typ = ntMethod then
    begin
      methodMetics := CalculateMethod(aUnitName, slUnitCode,
        child as TCompoundSyntaxNode);
      um.AddMethod(methodMetics);
    end;
  end;
  aProjectMetrics.AddUnit(um);
end;

class procedure TProjectCalculator.Calculate(const aFileName: string;
  const aProjectMetrics: TProjectMetrics);
var
  syntaxRootNode: TSyntaxNode;
  slUnitCode: TStringList;
  calculator: TProjectCalculator;
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
      calculator := TProjectCalculator.Create();
      try
        calculator.CalculateUnit(aFileName, slUnitCode, syntaxRootNode,
          aProjectMetrics);
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
