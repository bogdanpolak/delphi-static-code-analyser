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

function CalcMethodComplexity(const aNode: TSyntaxNode): Integer;
var
  child: TSyntaxNode;
  complex: Integer;
begin
  Result := 0;
  if aNode.Typ = ntParameter then
    exit;
  case aNode.Typ of
    ntAssign,
    ntIf,
      Exit(aNode.Col);
    ntAnonymousMethod,
    ntCall,
    ntCase,
    ntElse,
    ntFor,
    ntGoto,
    ntRepeat,
    ntStatement,
    ntStatements,
    ntThen,
    ntWhile,
    ntWith:
      Result := aNode.Col;
  end;
  for child in aNode.ChildNodes do
  begin
    complex := CalcMethodComplexity(child);
    if complex>Result then
      Result := complex;
  end;
end;

procedure NodeTreeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  compound: TCompoundSyntaxNode;
  complexity: Integer;
begin
  if aNode.Typ = ntInterface then
    exit;
  if aNode.Typ = ntMethod then
  begin
    compound := aNode as TCompoundSyntaxNode;
    complexity := CalcMethodComplexity(aNode);
    fUnitMetrics.AddMethod(
      { } aNode.GetAttribute(anKind),
      { } aNode.GetAttribute(anName),
      { } compound.EndLine - compound.Line + 1,
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
