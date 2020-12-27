unit Metrics.ClassMethod;

interface

uses
  {--}
  Metrics.UnitMethod;

type
  TVisibility = (visPrivate, visProtected, visPublic);

  TVisibilityHelper = record helper for TVisibility
    function ToString(): string;
    function ToSymbol(): string;
  end;

type
  TClassMethodMetrics = class
  private
    fVisibility: TVisibility;
    fName: string;
    fUnitMethod: TUnitMethodMetrics;
  public
    constructor Create(aVisibility: TVisibility; const aName: string);
    function WithCorrespondingUnitMethod(const aUnitMethod: TUnitMethodMetrics)
      : TClassMethodMetrics;
    property Visibility: TVisibility read fVisibility;
    property Name: string read fName;
    property UnitMethod: TUnitMethodMetrics read fUnitMethod;
  end;

implementation

constructor TClassMethodMetrics.Create(aVisibility: TVisibility;
  const aName: string);
begin
  fVisibility := aVisibility;
  fName := aName;
  fUnitMethod := nil;
end;

function TClassMethodMetrics.WithCorrespondingUnitMethod(const aUnitMethod
  : TUnitMethodMetrics): TClassMethodMetrics;
begin
  fUnitMethod := aUnitMethod;
  Result := Self;
end;

{ TVisibilityHelper }

function TVisibilityHelper.ToString: string;
begin
  case Self of
    visPrivate:
      Result := 'private';
    visProtected:
      Result := 'protected';
    visPublic:
      Result := 'public';
  else
    Result := 'unknown-visibility';
  end;
end;

function TVisibilityHelper.ToSymbol: string;
begin
  case Self of
    visPrivate:
      Result := '-';
    visProtected:
      Result := '/';
    visPublic:
      Result := '+';
  else
    Result := '?';
  end;
end;

end.
