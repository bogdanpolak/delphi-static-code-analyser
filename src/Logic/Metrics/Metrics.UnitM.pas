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
    fMethods: TObjectList<TUnitMethod>;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TUnitMethod;
    procedure AddMethod(const aMethodMetics: TUnitMethod);
    function FilterMethods(aMethodFilters: TMethodFilters)
      : TArray<TUnitMethod>;
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TUnitMethod>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

function TUnitMetrics.FilterMethods(aMethodFilters: TMethodFilters)
  : TArray<TUnitMethod>;
var
  list: TList<TUnitMethod>;
  method: TUnitMethod;
begin
  if aMethodFilters.Count = 0 then
    Exit(fMethods.ToArray);
  Result := nil;
  list := TList<TUnitMethod>.Create;
  try
    for method in fMethods do
      if aMethodFilters.IsMatching(method) then
        list.Add(method);
    Result := list.ToArray;
  finally
    list.Free;
  end;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TUnitMethod;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

procedure TUnitMetrics.AddMethod(const aMethodMetics: TUnitMethod);
begin
  fMethods.Add(aMethodMetics);
end;

end.
