{ ---------------------------------------------------------------------------- }
{ Pascal-P6 IDE Program File                                                   }
{ ---------------------------------------------------------------------------- }
program P6;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDEMain in 'uIDEMain.pas',
  uIDETypes in 'uIDETypes.pas',
  uP6 in 'uP6.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_P6, RunProc_P6);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
