unit Metrics.Project;

interface

uses
  System.Generics.Collections,
  {--}
  Metrics.ClassM,
  Metrics.UnitM;

type
  TProjectMetrics = class
  private
    fClasses: TObjectList<TClassMetrics>;
    fUnits: TObjectList<TUnitMetrics>;
  public
    constructor Create();
    destructor Destroy; override;
    function ClassCount(): Integer;
    function GetClass(aIdx: Integer): TClassMetrics;
    function AddClass(const aClassMetrics: TClassMetrics): TProjectMetrics;
    function UnitCount(): Integer;
    function GetUnit(aIdx: Integer): TUnitMetrics;
    function AddUnit(const aUnitMetrics: TUnitMetrics): TProjectMetrics;
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

function TProjectMetrics.ClassCount: Integer;
begin
  Result := fClasses.Count;
end;

function TProjectMetrics.GetClass(aIdx: Integer): TClassMetrics;
begin
  Result := fClasses.Items[aIdx];
end;

function TProjectMetrics.AddUnit(const aUnitMetrics: TUnitMetrics): TProjectMetrics;
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

end.
