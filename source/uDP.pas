{ ---------------------------------------------------------------------------- }
{ Delphi Unit                                                                  }
{ ---------------------------------------------------------------------------- }
unit uDP;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_DP;
procedure RunProc_DP;

implementation

// Compile
procedure CompileProc_DP;
begin
  if IdeRec.WorkFile = '' then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  var pasfile := IdeRec.WorkFile;
  var exefile := TPath.ChangeExtension(pasfile, '.exe');
  if not TFile.Exists(pasfile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  DeleteFile(exefile);
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('dcc32.exe -CC ' + pasfile + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

// Run
procedure RunProc_DP;
begin
  var pasfile := IdeRec.WorkFile;
  var exefile := TPath.ChangeExtension(pasfile, '.exe');
  if not TFile.Exists(exefile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec(exefile + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

initialization
  IdeRec.Title1Str   := 'Delphi CC IDE';
  IdeRec.Title2Str   := 'Object Pascal';
  IdeRec.VersionStr  := 'Version 1.00';
  IdeRec.PlatformStr := 'for Win32';
  IdeRec.DefaultExt  := '.dpr';

end.
