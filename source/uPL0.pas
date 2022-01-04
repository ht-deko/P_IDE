{ ---------------------------------------------------------------------------- }
{ PL/0 Unit                                                                    }
{ ---------------------------------------------------------------------------- }
unit uPL0;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_PL0;
procedure RunProc_PL0;

implementation

// Compile
procedure CompileProc_PL0;
begin
  RunProc_PL0;
end;

// Run
procedure RunProc_PL0;
begin
  if not TFile.Exists(IdeRec.WorkFile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
//Exec('CMD.EXE /C pl0_mod.exe ' + IdeRec.WorkFile, IdeRec.ExePath);
  Exec('CMD.EXE /C pl0_mod.exe ' + IdeRec.WorkFile + ' | MORE', IdeRec.ExePath);
end;

initialization
  IdeRec.Title1Str   := 'PL/0 IDE';
  IdeRec.Title2Str   := 'Subset of Standard Pascal';
  IdeRec.VersionStr  := 'Version 1.00';
  IdeRec.PlatformStr := 'for Win32';
  IdeRec.DefaultExt  := '.pl0';

end.
