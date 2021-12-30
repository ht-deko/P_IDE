{ ---------------------------------------------------------------------------- }
{ Pascal-P5 IDE Program File                                                   }
{ ---------------------------------------------------------------------------- }
program p5;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDETypes in 'uIDETypes.pas',
  uIDEMain in 'uIDEMain.pas',
  uP5 in 'uP5.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_P5, RunProc_P5);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

