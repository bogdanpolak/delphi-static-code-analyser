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

procedure NodeTreeWalker(const aNode: TSyntaxNode);
var
  child: TSyntaxNode;
  compound: TCompoundSyntaxNode;
begin
  if aNode.Typ = ntInterface then
    exit;
  if aNode.Typ = ntMethod then
  begin
    compound := aNode as TCompoundSyntaxNode;
    fUnitMetrics.AddMethod(
      { } aNode.GetAttribute(anKind),
      { } aNode.GetAttribute(anName),
      { } compound.EndLine - compound.Line + 1);
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
