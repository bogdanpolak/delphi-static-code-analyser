unit Filters.Method;

interface

uses
  System.Generics.Collections,
  {--}
  Metrics.UnitMethod;

type
  TMethodFilter = class abstract
  public
    function IsMatching(const aMethodMetrics: TUnitMethodMetrics): boolean;
      virtual; abstract;
  end;

  TMethodFilters = class
  public
    constructor Create();
    destructor Destroy; override;
    procedure Add(aMethodFilter: TMethodFilter);
    procedure AddRange(aMethodFilters: TArray<TMethodFilter>);
    function IsMatching(const aMethodMetrics: TUnitMethodMetrics): boolean;
    procedure Clear;
    function Count: Integer;
  private
    fFilters: TObjectList<TMethodFilter>;
  end;

implementation

{ TMethodFiltes }

constructor TMethodFilters.Create;
begin
  fFilters := TObjectList<TMethodFilter>.Create;
end;

destructor TMethodFilters.Destroy;
begin
  fFilters.Free;
  inherited;
end;

procedure TMethodFilters.Add(aMethodFilter: TMethodFilter);
begin
  fFilters.Add(aMethodFilter);
end;

procedure TMethodFilters.AddRange(aMethodFilters: TArray<TMethodFilter>);
begin
  fFilters.AddRange(aMethodFilters);
end;

procedure TMethodFilters.Clear;
begin
  fFilters.Clear;
end;

function TMethodFilters.Count: Integer;
begin
  Result := fFilters.Count;
end;

function TMethodFilters.IsMatching(
  const aMethodMetrics: TUnitMethodMetrics): boolean;
var
  filter: TMethodFilter;
begin
  for filter in fFilters do begin
    if not filter.IsMatching(aMethodMetrics) then
      exit( False);
  end;
  Result := True;
end;

end.
