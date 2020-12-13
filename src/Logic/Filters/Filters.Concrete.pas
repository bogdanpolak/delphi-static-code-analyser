unit Filters.Concrete;

interface

uses
  {--}
  Metrics.UnitMethod,
  Filters.Method;

type
  TComplexityGreaterEqual = class(TMethodFilter)
  public
    constructor Create( aMinimalComlexityLevel: Integer);
    function IsMatching(const aMethodMetrics: TUnitMethod): boolean;
      override;
  private
    fMinimalComlexityLevel: Integer;
  end;

  TLengthGreaterEqual = class(TMethodFilter)
  public
    constructor Create( aMinimalMethodLength: Integer);
    function IsMatching(const aMethodMetrics: TUnitMethod): boolean;
      override;
  private
    fMinimalMethodLength: Integer;
  end;

implementation

{ TComplexityGreaterThen }

constructor TComplexityGreaterEqual.Create(aMinimalComlexityLevel: Integer);
begin
  fMinimalComlexityLevel := aMinimalComlexityLevel;
end;

function TComplexityGreaterEqual.IsMatching(
  const aMethodMetrics: TUnitMethod): boolean;
begin
  Result := aMethodMetrics.Complexity >= fMinimalComlexityLevel;
end;

{ TLengthGreaterThen }

constructor TLengthGreaterEqual.Create(aMinimalMethodLength: Integer);
begin
  fMinimalMethodLength := aMinimalMethodLength;
end;

function TLengthGreaterEqual.IsMatching(
  const aMethodMetrics: TUnitMethod): boolean;
begin
  Result := aMethodMetrics.Lenght >= fMinimalMethodLength;
end;

end.
