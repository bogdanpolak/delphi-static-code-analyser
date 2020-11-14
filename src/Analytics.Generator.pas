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

procedure NodeTreeWalker(const Node: TSyntaxNode);
var
  ChildNode: TSyntaxNode;
  cnode: TCompoundSyntaxNode;
begin
  if Node.Typ = ntInterface then
    exit;
  if Node.Typ = ntMethod then
  begin
    cnode := Node as TCompoundSyntaxNode;
    fUnitMetrics.AddMethod(
      { } cnode.GetAttribute(anKind),
      { } cnode.GetAttribute(anName),
      { } cnode.EndLine - cnode.Line + 1);
    exit;
  end;
  for ChildNode in Node.ChildNodes do
    NodeTreeWalker(ChildNode);
end;

class function TAnalyticsGenerator.Build(const Root: TSyntaxNode): TUnitMetrics;
begin
  Result := TUnitMetrics.Create(Root.GetAttribute(anName));
  fUnitMetrics := Result;
  NodeTreeWalker(Root);
end;

end.
