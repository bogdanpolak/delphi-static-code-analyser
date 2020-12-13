program DelphiCodeAnalyser;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DelphiAST.Classes in '..\components\DelphiAST\DelphiAST.Classes.pas',
  DelphiAST.Consts in '..\components\DelphiAST\DelphiAST.Consts.pas',
  DelphiAST in '..\components\DelphiAST\DelphiAST.pas',
  DelphiAST.ProjectIndexer in '..\components\DelphiAST\DelphiAST.ProjectIndexer.pas',
  DelphiAST.Serialize.Binary in '..\components\DelphiAST\DelphiAST.Serialize.Binary.pas',
  DelphiAST.SimpleParserEx in '..\components\DelphiAST\DelphiAST.SimpleParserEx.pas',
  DelphiAST.Writer in '..\components\DelphiAST\DelphiAST.Writer.pas',
  StringPool in '..\components\DelphiAST\StringPool.pas',
  SimpleParser.Lexer in '..\components\DelphiAST\SimpleParser\SimpleParser.Lexer.pas',
  SimpleParser.Lexer.Types in '..\components\DelphiAST\SimpleParser\SimpleParser.Lexer.Types.pas',
  SimpleParser in '..\components\DelphiAST\SimpleParser\SimpleParser.pas',
  SimpleParser.Types in '..\components\DelphiAST\SimpleParser\SimpleParser.Types.pas',
  IncludeHandler in 'IncludeHandler.pas',
  {}
  Utils.IntegerArray in 'Utils\Utils.IntegerArray.pas',
  Metrics.UnitMethod in 'Logic\Metrics\Metrics.UnitMethod.pas',
  Metrics.UnitM in 'Logic\Metrics\Metrics.UnitM.pas',
  Metrics.ClassM in 'Logic\Metrics\Metrics.ClassM.pas',
  Metrics.Project in 'Logic\Metrics\Metrics.Project.pas',
  Metrics.ClassMethod in 'Logic\Metrics\Metrics.ClassMethod.pas',
  Filters.Method in 'Logic\Filters\Filters.Method.pas',
  Filters.Concrete in 'Logic\Filters\Filters.Concrete.pas',
  Calculators.UnitMetrics in 'Logic\Calculators\Calculators.UnitMetrics.pas',
  {}
  Main in 'Main.pas',
  Command.AnalyseUnit in 'Command.AnalyseUnit.pas',
  Command.GenerateXml in 'Command.GenerateXml.pas',
  Configuration.AppConfig in 'Configuration\Configuration.AppConfig.pas',
  Configuration.JsonAppConfig in 'Configuration\Configuration.JsonAppConfig.pas';

var
  appConfiguration: IAppConfiguration;
begin
  appConfiguration := BuildAppConfiguration();
  TMain.Run(appConfiguration);
end.
