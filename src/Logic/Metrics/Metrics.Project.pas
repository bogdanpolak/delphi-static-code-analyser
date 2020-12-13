unit Metrics.Project;

interface

uses
  System.Generics.Collections,
  {--}
  Metrics.ClassM;

type
  TProjectMetrics = class
  private
    fClasses: TObjectList<TClassMetrics>;
  public
    constructor Create();
    destructor Destroy; override;
    function ClassCount(): Integer;
    function GetClass(aIdx: Integer): TClassMetrics;
    procedure AddClass(const aClassMetrics: TClassMetrics);
  end;

implementation

constructor TProjectMetrics.Create;
begin
  fClasses := TObjectList<TClassMetrics>.Create();
end;

destructor TProjectMetrics.Destroy;
begin
  fClasses.Free;
  inherited;
end;

procedure TProjectMetrics.AddClass(const aClassMetrics: TClassMetrics);
begin
  fClasses.Add(aClassMetrics);
end;

function TProjectMetrics.ClassCount: Integer;
begin
  Result := fClasses.Count;
end;

function TProjectMetrics.GetClass(aIdx: Integer): TClassMetrics;
begin
  Result := fClasses.Items[aIdx];
end;

end.
