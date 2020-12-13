unit Metrics.ClassMethod;

interface

uses
  {--}
  Metrics.UnitMethod;

type
  TVisibility = (visPrivate, visProtected, visPublic);

type
  TClassMethodMetrics = class
  private
    fVisibility: TVisibility;
    fName: string;
    fUnitMethod: TUnitMethodMetrics;
  public
    constructor Create(aVisibility: TVisibility; const aName: string;
      const aUnitMethod: TUnitMethodMetrics);
    property Visibility: TVisibility read fVisibility;
    property Name: string read fName;
    property UnitMethod: TUnitMethodMetrics read fUnitMethod;
  end;

implementation

constructor TClassMethodMetrics.Create(aVisibility: TVisibility;
  const aName: string; const aUnitMethod: TUnitMethodMetrics);
begin
  fVisibility := aVisibility;
  fName := aName;
  fUnitMethod := aUnitMethod;
end;

end.
