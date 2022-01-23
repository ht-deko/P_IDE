{ ---------------------------------------------------------------------------- }
{ Delphi IDE Program File                                                      }
{ ---------------------------------------------------------------------------- }
program DP;

{$APPTYPE CONSOLE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$R *.res}

uses
  System.SysUtils,
  crt32 in 'crt32.pas',
  uIDEMain in 'uIDEMain.pas',
  uIDETypes in 'uIDETypes.pas',
  uDP in 'uDP.pas',
  uIDEUtils in 'uIDEUtils.pas';

begin
  try
    RunIDE(CompileProc_DP, RunProc_DP);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
