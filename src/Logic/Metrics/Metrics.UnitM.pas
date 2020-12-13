unit Metrics.UnitM;

interface

uses
  System.Generics.Collections,
  {--}
  Utils.IntegerArray,
  Metrics.UnitMethod;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TUnitMethodMetrics>;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    function GetMethod(aIdx: Integer): TUnitMethodMetrics;
    function GetMethods: TList<TUnitMethodMetrics>;
    procedure AddMethod(const aMethodMetics: TUnitMethodMetrics);
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TUnitMethodMetrics>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TUnitMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.GetMethods: TList<TUnitMethodMetrics>;
begin
  Result := fMethods;
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

procedure TUnitMetrics.AddMethod(const aMethodMetics: TUnitMethodMetrics);
begin
  fMethods.Add(aMethodMetics);
end;

end.
