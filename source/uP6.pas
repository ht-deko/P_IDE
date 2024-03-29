{ ---------------------------------------------------------------------------- }
{ Pascal-P6 Unit                                                               }
{ ---------------------------------------------------------------------------- }
unit uP6;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_P6;
procedure RunProc_P6;

implementation

// Compile
procedure CompileProc_P6;
begin
  if IdeRec.WorkFile = '' then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  var pasfile := IdeRec.WorkFile;
  var p6file := TPath.ChangeExtension(pasfile, '.p6');
  if not TFile.Exists(pasfile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pcom.exe < ' + pasfile + ' ' + p6file + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

// Run
procedure RunProc_P6;
begin
  var pasfile := IdeRec.WorkFile;
  var p6file := TPath.ChangeExtension(pasfile, '.p6');
  if not TFile.Exists(p6file) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pint.exe ' + p6file + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

initialization
  IdeRec.Title1Str   := 'Pascal-P6 IDE';
  IdeRec.Title2Str   := 'Standard Pascal Level 1';
  IdeRec.VersionStr  := 'Version 1.10';
  IdeRec.PlatformStr := 'for Win32';

end.
