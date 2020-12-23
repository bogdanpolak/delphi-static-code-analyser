unit Metrics.Project;

interface

uses
  System.Generics.Collections,
  {--}
  Metrics.ClassM,
  Metrics.UnitM,
  Metrics.UnitMethod,
  Filters.Method;

type
  TProjectMetrics = class
  private
    fClasses: TObjectList<TClassMetrics>;
    fUnits: TObjectList<TUnitMetrics>;
  public
    constructor Create();
    destructor Destroy; override;
    { }
    function ClassCount(): Integer;
    function GetClass(aIdx: Integer): TClassMetrics;
    function GetClassesAll(): TArray<TClassMetrics>;
    function AddClass(const aClassMetrics: TClassMetrics): TProjectMetrics;
    function AddClassRange(const aClassMetrics: TArray<TClassMetrics>)
      : TProjectMetrics;
    { }
    function UnitCount(): Integer;
    function GetUnit(aIdx: Integer): TUnitMetrics;
    function AddUnit(const aUnitMetrics: TUnitMetrics): TProjectMetrics;
    { }
    function FilterMethods(aMethodFilters: TMethodFilters)
      : TArray<TUnitMethodMetrics>;
  end;

implementation

constructor TProjectMetrics.Create;
begin
  fClasses := TObjectList<TClassMetrics>.Create();
  fUnits := TObjectList<TUnitMetrics>.Create();
end;

destructor TProjectMetrics.Destroy;
begin
  fUnits.Free;
  fClasses.Free;
  inherited;
end;

function TProjectMetrics.AddClass(const aClassMetrics: TClassMetrics)
  : TProjectMetrics;
begin
  Result := self;
  fClasses.Add(aClassMetrics);
end;

function TProjectMetrics.AddClassRange(const aClassMetrics
  : TArray<TClassMetrics>): TProjectMetrics;
begin
  Result := self;
  fClasses.AddRange(aClassMetrics);
end;

function TProjectMetrics.ClassCount: Integer;
begin
  Result := fClasses.Count;
end;

function TProjectMetrics.GetClass(aIdx: Integer): TClassMetrics;
begin
  Result := fClasses.Items[aIdx];
end;

function TProjectMetrics.GetClassesAll: TArray<TClassMetrics>;
begin
  Result := fClasses.ToArray;
end;

function TProjectMetrics.AddUnit(const aUnitMetrics: TUnitMetrics)
  : TProjectMetrics;
begin
  Result := self;
  fUnits.Add(aUnitMetrics);
end;

function TProjectMetrics.GetUnit(aIdx: Integer): TUnitMetrics;
begin
  Result := fUnits[aIdx];
end;

function TProjectMetrics.UnitCount: Integer;
begin
  Result := fUnits.Count;
end;

function TProjectMetrics.FilterMethods(aMethodFilters: TMethodFilters)
  : TArray<TUnitMethodMetrics>;
var
  unitMetrics: TUnitMetrics;
  filteredMethods: TList<TUnitMethodMetrics>;
  methods: TList<TUnitMethodMetrics>;
  Method: TUnitMethodMetrics;
begin
  filteredMethods := TList<TUnitMethodMetrics>.Create;
  try
    for unitMetrics in fUnits do
    begin
      methods := unitMetrics.GetMethods();
      if (aMethodFilters = nil) or (aMethodFilters.Count = 0) then
      begin
        filteredMethods.AddRange(methods);
      end
      else
      begin
        for Method in methods do
          if aMethodFilters.IsMatching(Method) then
            filteredMethods.Add(Method);
      end;
    end;
    Result := filteredMethods.ToArray;
  finally
    filteredMethods.Free;
  end;
end;

end.
