unit Model.Filters.ComplexityGreater;

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

end.
