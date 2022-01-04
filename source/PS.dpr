{ ---------------------------------------------------------------------------- }
{ Pascal-S IDE Program File                                                    }
{ ---------------------------------------------------------------------------- }
program PS;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDEMain in 'uIDEMain.pas',
  uIDETypes in 'uIDETypes.pas',
  uPS in 'uPS.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_PS, RunProc_PS);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
