unit Analytics.Generator;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST.Classes,
  System.Generics.Defaults,
  Analytics.UnitMetrics;

type
  TAnalyticsGenerator = class
  public
    class function Build(const Root: TSyntaxNode): TUnitMetrics; static;
  end;

implementation

uses
  Generics.Collections,
  DelphiAST.Consts;

var
  fLineIndetation: TDictionary<Integer, Integer>;

procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  indentation: Integer;
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

function CalculateMethodComplexity(const aMethodNode
  : TCompoundSyntaxNode): Integer;
var
  statements: TSyntaxNode;
  current: Integer;
  indetation: Integer;
  indentations: TArray<Integer>;
begin
  fLineIndetation := TDictionary<Integer, Integer>.Create();
  try
    statements := aMethodNode.FindNode(ntStatements);
    MinIndetationNodeWalker(statements);
    indentations := fLineIndetation.Values.ToArray;
    indetation := 0;
    for current in indentations do
      if indetation < current then
        indetation := current;
    Result := indetation div 2;
  finally
    fLineIndetation.Free;
  end;
end;

function CalculateMethodLength(const aMethodNode: TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  Result := statements.EndLine - aMethodNode.Line + 1;
end;

class function TAnalyticsGenerator.Build(const Root: TSyntaxNode): TUnitMetrics;
var
  unitname: string;
  implementationNode: TSyntaxNode;
  child: TSyntaxNode;
  UnitMetrics: TUnitMetrics;
begin
  unitname := Root.GetAttribute(anName);
  UnitMetrics := TUnitMetrics.Create(unitname);
  // interfaceNode := Root.FindNode(ntInterface);
  implementationNode := Root.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
  begin
    if child.Typ = ntMethod then
    begin
      UnitMetrics.AddMethod(child.GetAttribute(anKind),
        child.GetAttribute(anName),
        CalculateMethodLength(child as TCompoundSyntaxNode),
        CalculateMethodComplexity(child as TCompoundSyntaxNode));
    end;
  end;
  Result := unitMetrics;
end;

end.
