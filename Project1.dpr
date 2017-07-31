program Project1;

uses
  FastMm4,
  madExcept,
  madLinkDisAsm,
  Vcl.Forms,
  Windows,
  uCEFApplication, uCefTypes,
  uForm in 'uForm.pas' {Form1},
  uFrame in 'uFrame.pas' {Frame2: TFrame},
  uAppConst in 'uAppConst.pas';

{$R *.res}
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

begin
  GlobalCEFApp := TCefApplication.Create;

  GlobalCEFApp.WindowlessRenderingEnabled := True;

  //GlobalCEFApp.LogFile := 'cef.log';
  //GlobalCEFApp.LogSeverity := LOGSEVERITY_VERBOSE;

  GlobalCEFApp.FrameworkDirPath     := 'cef\';
  GlobalCEFApp.ResourcesDirPath     := 'cef\';
  GlobalCEFApp.LocalesDirPath       := 'cef\locales\';
  GlobalCEFApp.Cache                := '';
  GlobalCEFApp.Cookies              := '';
  GlobalCEFApp.UserDataPath         := '';
  GlobalCEFApp.Locale               := 'en';

  if GlobalCEFApp.StartMainProcess then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end;
  GlobalCEFApp.Free;
end.
