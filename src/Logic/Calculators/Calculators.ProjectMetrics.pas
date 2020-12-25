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
  Metrics.Project,
  Metrics.ClassM,
  Metrics.ClassMethod;

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
    function AnalyseClassesInUnit(const aUnitName: string;
      const aTypeNode: TSyntaxNode): TArray<TClassMetrics>;
    function BuildClassMetrics(const aUnitName: string;
      const aClassNode: TSyntaxNode): TClassMetrics;
  public
    class procedure Calculate(const aFileName: string;
      const aProjectMetrics: TProjectMetrics); static;
  end;

implementation

uses
  Utils.IntegerArray,
  Helper.TSyntaxNode;

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

function TProjectCalculator.BuildClassMetrics(const aUnitName: string;
  const aClassNode: TSyntaxNode): TClassMetrics;
var
  classMetrics: TClassMetrics;
  nameofClass: string;
  publishedSectionNode: TSyntaxNode;

  procedure AddClassSectionMethods(const aVisibilty: TVisibility;
    const aSectionRootNodes: TArray<TSyntaxNode>);
  var
    sectionRootNode: TSyntaxNode;
    methodNodes: TArray<TSyntaxNode>;
    node: TSyntaxNode;
  begin
    for sectionRootNode in aSectionRootNodes do
    begin
      methodNodes := sectionRootNode.FindNodes(ntMethod);
      for node in methodNodes do
        classMetrics.AddClassMethod(aVisibilty, node.GetAttribute(anName));
    end;
  end;

begin
  nameofClass := aClassNode.GetAttribute(anName);
  publishedSectionNode := aClassNode.ChildNodes[0];
  classMetrics := TClassMetrics.Create(aUnitName, nameofClass);
  { private sections - methods }
  AddClassSectionMethods(visPrivate, publishedSectionNode.FindNodes(ntPrivate) +
    publishedSectionNode.FindNodes(ntStrictPrivate));
  { protected sections - methods }
  AddClassSectionMethods(visProtected,
    publishedSectionNode.FindNodes(ntProtected) + publishedSectionNode.FindNodes
    (ntStrictProtected));
  { public sections - methods }
  AddClassSectionMethods(visPublic, [publishedSectionNode] +
    publishedSectionNode.FindNodes(ntPublic) + publishedSectionNode.FindNodes
    (ntPublished));
  { ---- }
  Result := classMetrics;
end;

function TProjectCalculator.AnalyseClassesInUnit(const aUnitName: string;
  const aTypeNode: TSyntaxNode): TArray<TClassMetrics>;
var
  classMetricsList: TList<TClassMetrics>;
  childNode: TSyntaxNode;
begin
  Result := nil;
  classMetricsList := TList<TClassMetrics>.Create();
  try
    for childNode in aTypeNode.ChildNodes do
      if childNode.IsClassNode() then
        classMetricsList.Add(BuildClassMetrics(aUnitName, childNode));
    Result := classMetricsList.ToArray;
  finally
    classMetricsList.Free;
  end;
end;

procedure TProjectCalculator.CalculateUnit(const aUnitName: string;
  const slUnitCode: TStringList; const aRootNode: TSyntaxNode;
  const aProjectMetrics: TProjectMetrics);
var
  unitMetrics: TUnitMetrics;
  implementationNode: TSyntaxNode;
  methodMetics: TUnitMethodMetrics;
  node: TSyntaxNode;
  interfaceNode: TSyntaxNode;
  publicTypeNodes: TArray<TSyntaxNode>;
  classMetrics: TArray<TClassMetrics>;
begin
  unitMetrics := TUnitMetrics.Create(aUnitName);
  // --- Extract metrics: classes
  interfaceNode := aRootNode.FindNode(ntInterface);
  publicTypeNodes := interfaceNode.FindNodes(ntTypeSection);
  for node in publicTypeNodes do
  begin
    classMetrics := AnalyseClassesInUnit(aUnitName, node);
    aProjectMetrics.AddClasses(classMetrics);
  end;
  // --- Extract metrics: methods (implemented in unit)
  implementationNode := aRootNode.FindNode(ntImplementation);
  for node in implementationNode.ChildNodes do
  begin
    if node.typ = ntMethod then
    begin
      methodMetics := CalculateMethod(aUnitName, slUnitCode,
        node as TCompoundSyntaxNode);
      unitMetrics.AddMethod(methodMetics);
    end;
  end;
  aProjectMetrics.AddUnit(unitMetrics);
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
