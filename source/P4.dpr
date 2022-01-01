{ ---------------------------------------------------------------------------- }
{ Pascal-P4 IDE Program File                                                   }
{ ---------------------------------------------------------------------------- }
program P4;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDEMain in 'uIDEMain.pas',
  uIDETypes in 'uIDETypes.pas',
  uP4 in 'uP4.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_P4, RunProc_P4);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
