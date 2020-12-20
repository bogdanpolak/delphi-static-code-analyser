unit test05.Support;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client;

type
  TDataSetProxy = class
  end;

  TPurchasesDBProxy = class(TDataSetProxy)
  end;

  TInventoryDBProxy = class(TDataSetProxy)
  end;

  InjectDBProviderAttribute = class(TCustomAttribute)
    constructor Create(const aSQLStatmentName: string);
  end;

  TLoggingMode = (lmLoggingDisable, lmLoggingActive);

  EDataProcessorError = class(Exception)
  end;

  ILogger = interface
    ['{4A8D64B3-49E8-4A47-B11C-69F33C4A57C5}']
    procedure LogCriticalError(const aMessage: string; aParams: array of const);
    procedure LogError(const aMessage: string; aParams: array of const);
    procedure LogHint(const aMessage: string; aParams: array of const);
    procedure LogInfo(const aMessage: string; aParams: array of const);
  end;

  IStringProvider = interface
    ['{4A8D64B3-49E8-4A47-B11C-69F33C4A57C5}']
    function TryGetString(const aKey: string; out Content: string): Boolean;
  end;

  TDatabaseJsonProvider = class(TInterfacedObject, IStringProvider)
  private
    fConnection: TFDConnection;
    fSQL: string;
    fParams: TArray<Variant>;
  public
    constructor Create(const aConnection: TFDConnection; const aSQL: string;
      const aParams: TArray<Variant>);
    function TryGetString(const aKey: string; out aContent: string): Boolean;
  end;

implementation

{ ---------------------------------------------------------------------- }
{ InjectDBProviderAttribute }
{ ---------------------------------------------------------------------- }

constructor InjectDBProviderAttribute.Create(const aSQLStatmentName: string);
begin
end;

{ ---------------------------------------------------------------------- }
{ TDatabaseDataProvider }
{ ---------------------------------------------------------------------- }

constructor TDatabaseJsonProvider.Create(const aConnection: TFDConnection;
  const aSQL: string; const aParams: TArray<Variant>);
begin
  inherited Create;
  fConnection := aConnection;
  fSQL := aSQL;
  fParams := aParams;
end;

function TDatabaseJsonProvider.TryGetString(const aKey: string;
  out aContent: string): Boolean;
var
  res: Variant;
begin
  res := fConnection.ExecSQLScalar(fSQL, fParams);
  aContent := '';
  Result := not res.IsNull and Trim(aContent) <> '';
end;

end.
