unit Analytics.Generator;

interface

uses
  System.SysUtils,
  System.Classes,
  DelphiAST.Classes,
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
  fUnitMetrics: TUnitMetrics;
  fLineIndetation: TDictionary<Integer, Integer>;


procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  indentation: Integer;
begin
  if fLineIndetation.TryGetValue(aNode.Line,indentation) then
  begin
    if aNode.Col<indentation then
      fLineIndetation[aNode.Line] := aNode.Col-1;
  end
  else
    fLineIndetation.Add(aNode.Line, aNode.Col-1);
  for child in aNode.ChildNodes do
    MinIndetationNodeWalker(child);
end;

function CalcMethodComplexity(const aNode: TSyntaxNode): Integer;
var
  pair: TPair<Integer, Integer>; 
  indetation: Integer;
begin
  fLineIndetation := TDictionary<Integer, Integer>.Create();
  try
    MinIndetationNodeWalker(aNode);
    indetation := 0;
    for pair in fLineIndetation do
      if indetation<pair.Value then
        indetation := pair.Value;
    Result := indetation div 2;
  finally
    fLineIndetation.Free;
  end;
end;

procedure NodeTreeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  compound: TCompoundSyntaxNode;
  complexity: Integer;
  statements: TCompoundSyntaxNode;
begin
  if aNode.Typ = ntInterface then
    exit;
  if aNode.Typ = ntMethod then
  begin
    statements := aNode.FindNode(ntStatements) as TCompoundSyntaxNode;
    complexity := CalcMethodComplexity(aNode);
    fUnitMetrics.AddMethod(
      { } aNode.GetAttribute(anKind),
      { } aNode.GetAttribute(anName),
      { } statements.EndLine - aNode.Line + 1,
      { } complexity);
    exit;
  end;
  for child in aNode.ChildNodes do
    NodeTreeWalker(child);
end;

class function TAnalyticsGenerator.Build(const Root: TSyntaxNode): TUnitMetrics;
begin
  Result := TUnitMetrics.Create(Root.GetAttribute(anName));
  fUnitMetrics := Result;
  NodeTreeWalker(Root);
end;

end.
