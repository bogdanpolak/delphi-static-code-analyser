unit Metrics.UnitM;

interface

uses
  System.Generics.Collections,
  {--}
  Utils.IntegerArray,
  Metrics.UnitMethod,
  Filters.Method;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TUnitMethodMetrics>;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TUnitMethodMetrics;
    procedure AddMethod(const aMethodMetics: TUnitMethodMetrics);
    function FilterMethods(aMethodFilters: TMethodFilters)
      : TArray<TUnitMethodMetrics>;
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TUnitMethodMetrics>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

function TUnitMetrics.FilterMethods(aMethodFilters: TMethodFilters)
  : TArray<TUnitMethodMetrics>;
var
  list: TList<TUnitMethodMetrics>;
  method: TUnitMethodMetrics;
begin
  if (aMethodFilters=nil) or (aMethodFilters.Count = 0) then
    Exit(fMethods.ToArray);
  Result := nil;
  list := TList<TUnitMethodMetrics>.Create;
  try
    for method in fMethods do
      if aMethodFilters.IsMatching(method) then
        list.Add(method);
    Result := list.ToArray;
  finally
    list.Free;
  end;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TUnitMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

procedure TUnitMetrics.AddMethod(const aMethodMetics: TUnitMethodMetrics);
begin
  fMethods.Add(aMethodMetics);
end;

end.
