unit Model.Filters.Concrete;

interface

uses
  {DelphiCodeAnalyser}
  Model.MethodMetrics,
  Model.Filters.MethodFiltes;

type
  TComplexityGreaterThen = class(TMethodFilter)
  public
    constructor Create( aMinimalComlexityLevel: Integer);
    function IsMatching(const aMethodMetrics: TMethodMetrics): boolean;
      override;
  private
    fMinimalComlexityLevel: Integer;
  end;

  TLengthGreaterThen = class(TMethodFilter)
  public
    constructor Create( aMinimalMethodLength: Integer);
    function IsMatching(const aMethodMetrics: TMethodMetrics): boolean;
      override;
  private
    fMinimalMethodLength: Integer;
  end;

implementation

{ TComplexityGreaterThen }

constructor TComplexityGreaterThen.Create(aMinimalComlexityLevel: Integer);
begin
  fMinimalComlexityLevel := aMinimalComlexityLevel;
end;

function TComplexityGreaterThen.IsMatching(
  const aMethodMetrics: TMethodMetrics): boolean;
begin
  Result := aMethodMetrics.Complexity >= fMinimalComlexityLevel;
end;

{ TLengthGreaterThen }

constructor TLengthGreaterThen.Create(aMinimalMethodLength: Integer);
begin
  fMinimalMethodLength := aMinimalMethodLength;
end;

function TLengthGreaterThen.IsMatching(
  const aMethodMetrics: TMethodMetrics): boolean;
begin
  Result := aMethodMetrics.Lenght >= fMinimalMethodLength;
end;

end.
