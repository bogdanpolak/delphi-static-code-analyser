unit Metrics.ClassMethod;

interface

uses
  {--}
  Metrics.UnitMethod;

type
  TVisibility = (visPrivate, visProtected, visPublic);

type
  TClassMethod = class
  private
    fVisibility: TVisibility;
    fName: string;
    fUnitMethod: TUnitMethod;
  public
    constructor Create(aVisibility: TVisibility; const aName: string;
      const aUnitMethod: TUnitMethod);
    property Visibility: TVisibility read fVisibility;
    property Name: string read fName;
    property UnitMethod: TUnitMethod read fUnitMethod;
  end;

implementation

constructor TClassMethod.Create(aVisibility: TVisibility; const aName: string;
  const aUnitMethod: TUnitMethod);
begin
  fVisibility := aVisibility;
  fName := aName;
  fUnitMethod := aUnitMethod;
end;

end.
