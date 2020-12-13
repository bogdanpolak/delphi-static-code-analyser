unit Model.ClassMethod;

interface

uses
  {--}
  Model.MethodMetrics;

type
  TVisibility = (visPrivate, visProtected, visPublic);

type
  TClassMethod = class
  private
    fVisibility: TVisibility;
    fName: string;
    fUnitMethod: TMethodMetrics;
  public
    constructor Create(aVisibility: TVisibility; const aName: string;
      const aUnitMethod: TMethodMetrics);
    property Visibility: TVisibility read fVisibility;
    property Name: string read fName;
    property UnitMethod: TMethodMetrics read fUnitMethod;
  end;

implementation

constructor TClassMethod.Create(aVisibility: TVisibility; const aName: string;
  const aUnitMethod: TMethodMetrics);
begin
  fVisibility := aVisibility;
  fName := aName;
  fUnitMethod := aUnitMethod;
end;

end.
