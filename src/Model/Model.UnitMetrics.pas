unit Model.UnitMetrics;

interface

uses
  System.Generics.Collections,
  DelphiAST.Classes,
  DelphiAST.Consts,
  Model.MethodMetrics,
  Utils.IntegerArray;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TMethodMetrics>;
    procedure AddMethod(aMethodNode: TCompoundSyntaxNode);
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    procedure CalculateMetrics(aRootNode: TSyntaxNode);
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TMethodMetrics;
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TMethodMetrics>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

// --------------------------------------------------

var
  fLineIndetation: TDictionary<Integer, Integer>;

procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
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

function CalculateMethodMaxIndent(const aMethodNode
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

function CalculateMethodLength(const aMethodNode: TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  if statements <> nil then
    Result := statements.EndLine - aMethodNode.Line + 1
  else
    Result := 1;
end;

procedure TUnitMetrics.AddMethod(aMethodNode: TCompoundSyntaxNode);
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
  fMethods.Add(methodMetics);
end;

procedure TUnitMetrics.CalculateMetrics(aRootNode: TSyntaxNode);
var
  implementationNode: TSyntaxNode;
  child: TSyntaxNode;
begin
  // ---- interfaceNode := aRootNode.FindNode(ntInterface);
  implementationNode := aRootNode.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
    if child.Typ = ntMethod then
      AddMethod(child as TCompoundSyntaxNode);
end;

end.
