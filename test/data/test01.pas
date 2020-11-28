unit test01;

interface

type
  TDDDEmailValidation = class
    procedure SetDefaultValuesIfVoid(
      const aSenderEmail,aApplication,
      aRedirectionURIPublicRoot,aRedirectionURISuccess: RawUTF8);
  end;

implementation

procedure TDDDEmailValidation.SetDefaultValuesIfVoid(
  const aSenderEmail,aApplication,
  aRedirectionURIPublicRoot,aRedirectionURISuccess: RawUTF8);
begin
  if Template.SenderEmail='' then
    Template.SenderEmail := aSenderEmail;
  if Template.Application='' then
    Template.Application := aApplication;
  if Template.FileName='' then
    Template.FileName := 'EmailValidate.txt';
  if (TemplateFolder='') and
     not FileExists(string(Template.FileName)) then
    FileFromString('Welcome to {{Application}}!'#13#10#13#10+
      'You have registered as "{{Logon}}", using {{EMail}} as contact address.'#13#10#13#10+
      'Please click on the following link to validate your email:'#13#10+
      '{{ValidationUri}}'#13#10#13#10'Best regards from the clouds'#13#10#13#10+
      '(please do not respond to this email)',
      UTF8ToString(Template.FileName));
  if Template.Subject='' then
    Template.Subject := 'Please Validate Your Email';
  if Redirection.RestServerPublicRootURI='' then
    Redirection.RestServerPublicRootURI := aRedirectionURIPublicRoot;
  if Redirection.SuccessRedirectURI='' then
    Redirection.SuccessRedirectURI := aRedirectionURISuccess;
end;

end.
