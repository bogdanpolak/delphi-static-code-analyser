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
    function ExtractAllClasses(const aUnitName: string;
      const aTypeNode: TSyntaxNode): TArray<TClassMetrics>;
    procedure AddClassMethods(const aClassMetrics: TClassMetrics;
      const aPublishedSectionNode: TSyntaxNode);
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

type
  TSyntaxNodeExtention = class helper for TSyntaxNode
  public
    function HasClassChildNode(): boolean;
    function IsTypeDeclaration(): boolean;
  end;

function TSyntaxNodeExtention.HasClassChildNode(): boolean;
begin
  Result := (Self.HasChildren) and (Self.ChildNodes[0].typ = ntType) and
    (Self.ChildNodes[0].GetAttribute(anType) = 'class');
end;

function TSyntaxNodeExtention.IsTypeDeclaration(): boolean;
begin
  Result := (Self.typ = ntTypeDecl);
end;

procedure TProjectCalculator.AddClassMethods(const aClassMetrics: TClassMetrics;
  const aPublishedSectionNode: TSyntaxNode);

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
        aClassMetrics.AddClassMethod(aVisibilty, node.GetAttribute(anName));
    end;
  end;

begin
  AddClassSectionMethods(visPublic, [aPublishedSectionNode]);
  AddClassSectionMethods(visPrivate,
    aPublishedSectionNode.FindNodes(ntPrivate));
  AddClassSectionMethods(visPrivate,
    aPublishedSectionNode.FindNodes(ntStrictPrivate));
  AddClassSectionMethods(visProtected,
    aPublishedSectionNode.FindNodes(ntProtected));
  AddClassSectionMethods(visProtected,
    aPublishedSectionNode.FindNodes(ntStrictProtected));
  AddClassSectionMethods(visPublic, aPublishedSectionNode.FindNodes(ntPublic));
  AddClassSectionMethods(visPublic,
    aPublishedSectionNode.FindNodes(ntPublished));
end;

function TProjectCalculator.ExtractAllClasses(const aUnitName: string;
  const aTypeNode: TSyntaxNode): TArray<TClassMetrics>;
var
  classMetricsList: TList<TClassMetrics>;
  children: TArray<TSyntaxNode>;
  childNode: TSyntaxNode;
  IsClassNode: boolean;
  nameofClass: string;
  classMetrics: TClassMetrics;
  publishedSectionNode: TSyntaxNode;
begin
  Result := nil;
  classMetricsList := TList<TClassMetrics>.Create();
  try
    children := aTypeNode.ChildNodes;
    for childNode in children do
    begin
      IsClassNode := (childNode.IsTypeDeclaration()) and
        (childNode.HasClassChildNode());
      if IsClassNode then
      begin
        publishedSectionNode := childNode.ChildNodes[0];
        nameofClass := childNode.GetAttribute(anName);
        classMetrics := TClassMetrics.Create(aUnitName, nameofClass);
        AddClassMethods(classMetrics, publishedSectionNode);
        classMetricsList.Add(classMetrics);
      end;
    end;
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
    classMetrics := ExtractAllClasses(aUnitName, node);
    aProjectMetrics.AddClassRange(classMetrics);
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
