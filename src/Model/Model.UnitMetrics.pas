unit Model.UnitMetrics;

interface

uses
  System.Generics.Collections,
  Model.MethodMetrics,
  Utils.IntegerArray,
  {--}
  Model.Filters.MethodFiltes;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TMethodMetrics>;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TMethodMetrics;
    procedure AddMethod(const aMethodMetics: TMethodMetrics);
    function FilterMethods(aMethodFilters: TMethodFilters)
  : TArray<TMethodMetrics>;
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

function TUnitMetrics.FilterMethods(aMethodFilters: TMethodFilters)
  : TArray<TMethodMetrics>;
var
  list: TList<TMethodMetrics>;
  method: TMethodMetrics;
begin
  if aMethodFilters.Count=0 then
    Exit(fMethods.ToArray);
  Result := nil;
  list := TList<TMethodMetrics>.Create;
  try
    for method in fMethods do
      if aMethodFilters.IsMatching(method) then
        list.Add(method);
    Result := list.ToArray;
  finally
    list.Free;
  end;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

procedure TUnitMetrics.AddMethod(const aMethodMetics: TMethodMetrics);
begin
  fMethods.Add(aMethodMetics);
end;

end.
