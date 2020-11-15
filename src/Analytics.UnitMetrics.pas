unit Analytics.UnitMetrics;

interface

uses
  System.Generics.Collections,
  Analytics.MethodMetrics;

type
  TUnitMetrics = class
  private
    fName: string;
    fMethods: TObjectList<TMethodMetrics>;
    function GetMethod(aIdx: Integer): TMethodMetrics;
  public
    constructor Create(const aUnitName: string);
    destructor Destroy; override;
    property Name: string read fName;
    function MethodsCount(): Integer;
    procedure AddMethod(const aKind: string; const aFullName: string;
      aLength: Integer; aComplexity: Integer);
    property Method[aIdx: Integer]: TMethodMetrics read GetMethod;
  end;

implementation

constructor TUnitMetrics.Create(const aUnitName: string);
begin
  self.fName := aUnitName;
  fMethods := TObjectList<TMethodMetrics>.Create();
end;

destructor TUnitMetrics.Destroy;
begin
  fMethods.Free;
  inherited;
end;

procedure TUnitMetrics.AddMethod(const aKind: string; const aFullName: string;
  aLength: Integer; aComplexity: Integer);
begin
  fMethods.Add(TMethodMetrics.Create(aKind, aFullName, aLength, aComplexity));
end;

function TUnitMetrics.GetMethod(aIdx: Integer): TMethodMetrics;
begin
  Result := fMethods[aIdx];
end;

function TUnitMetrics.MethodsCount: Integer;
begin
  Result := fMethods.Count;
end;

end.
