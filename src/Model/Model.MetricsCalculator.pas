unit Model.MetricsCalculator;

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
  Model.MethodMetrics,
  Model.UnitMetrics;

type
  TUnitCalculator = class
  private
    fStringStream: TStringStream;
    fTreeBuilder: TPasSyntaxTreeBuilder;
    fUnitMetrics: TUnitMetrics;
    procedure LoadUnit(const aFileName: string);
    function CalculateMethodLength(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    function CalculateMethodMaxIndent(const aMethodNode
      : TCompoundSyntaxNode): Integer;
    procedure MinIndetationNodeWalker(const aNode: TSyntaxNode);
    procedure CalculateUnit(const aRootNode: TSyntaxNode);
    procedure CalculateMethod(aMethodNode: TCompoundSyntaxNode);
  public
    constructor Create(const aUnitMetrics: TUnitMetrics);
    destructor Destroy; override;
    class function Calculate(const aFileName: string): TUnitMetrics; static;
  end;

implementation

uses
  Utils.IntegerArray;

constructor TUnitCalculator.Create(const aUnitMetrics: TUnitMetrics);
begin
  fStringStream := TStringStream.Create;
  fTreeBuilder := TPasSyntaxTreeBuilder.Create;
  fUnitMetrics := aUnitMetrics;
  {
    if aIncludeFolder <> '' then
    begin
    fTreeBuilder.IncludeHandler := TIncludeHandler.Create(aIncludeFolder);
    end;
  }
end;

destructor TUnitCalculator.Destroy;
begin
  fTreeBuilder.Free;
  fStringStream.Free;
  inherited;
end;

procedure TUnitCalculator.LoadUnit(const aFileName: string);
begin
  fStringStream.Clear;
  fStringStream.LoadFromFile(aFileName);
  fStringStream.Position := 0;
end;

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

function TUnitCalculator.CalculateMethodMaxIndent(const aMethodNode
  : TCompoundSyntaxNode): Integer;
var
  statements: TCompoundSyntaxNode;
  sl: TStringList;
  row1: Integer;
  row2: Integer;
  row: Integer;
  Line: string;
  maxIndent: Integer;
  indent: Integer;
  indentationList: TList<Integer>;
  indentations: TIntegerArray;
  step: Integer;
begin
  statements := aMethodNode.FindNode(ntStatements) as TCompoundSyntaxNode;
  if statements=nil then
    Exit(0);
  row1 := statements.Line;
  row2 := statements.EndLine;
  sl := TStringList.Create;
  indentationList := TList<Integer>.Create;;
  try
    fStringStream.Position := 0;
    sl.LoadFromStream(fStringStream);
    fStringStream.Position := 0;
    maxIndent := 0;
    for row := row1 to row2 do
    begin
      Line := sl[row - 1];
      indent := 0;
      while (indent < Length(Line)) and (Line[indent + 1] = ' ') do
        inc(indent);
      if indent > 0 then
        indentationList.Add(indent);
    end;
    indentations := indentationList.ToArray.GetDistinctArray();
    Result := Length(indentations);
  finally
    sl.Free;
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

procedure TUnitCalculator.CalculateMethod(aMethodNode: TCompoundSyntaxNode);
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
  fUnitMetrics.AddMethod(methodMetics);
end;

// ---------------------------------------------------------------------

procedure TUnitCalculator.CalculateUnit(const aRootNode: TSyntaxNode);
var
  implementationNode: TSyntaxNode;
  child: TSyntaxNode;
begin
  // ---- interfaceNode := rootNode.FindNode(ntInterface);
  implementationNode := aRootNode.FindNode(ntImplementation);
  for child in implementationNode.ChildNodes do
    if child.Typ = ntMethod then
    begin
      CalculateMethod(child as TCompoundSyntaxNode);
    end;
end;

class function TUnitCalculator.Calculate(const aFileName: string): TUnitMetrics;
var
  UnitMetrics: TUnitMetrics;
  calculator: TUnitCalculator;
  syntaxRootNode: TSyntaxNode;
begin
  UnitMetrics := TUnitMetrics.Create(aFileName);
  try
    calculator := TUnitCalculator.Create(UnitMetrics);
    try
      calculator.LoadUnit(aFileName);
      syntaxRootNode := calculator.fTreeBuilder.Run(calculator.fStringStream);
      try
        calculator.CalculateUnit(syntaxRootNode);
        Result := UnitMetrics;
      finally
        syntaxRootNode.Free;
      end;
    finally
      calculator.Free;
    end;
  except
    on E: Exception do
    begin
      UnitMetrics.Free;
      raise;
    end;
  end;
end;

end.
