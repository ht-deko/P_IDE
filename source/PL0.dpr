{ ---------------------------------------------------------------------------- }
{ PL/0 IDE Program File                                                        }
{ ---------------------------------------------------------------------------- }
program PL0;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDEMain in 'uIDEMain.pas',
  uIDETypes in 'uIDETypes.pas',
  uPL0 in 'uPL0.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_PL0, RunProc_PL0);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
