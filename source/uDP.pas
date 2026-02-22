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
  if (IdeRec.MainFile = '') and (IdeRec.WorkFile = '') then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  var pasfile := IdeRec.WorkFile;
  if IdeRec.MainFile <> '' then
    pasfile := IdeRec.MainFile;
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

  {$IFDEF Win32}
  var cc := 'dcc32';
  {$ELSE}
  var cc := 'dcc64';
  {$ENDIF}
  var cl := cc + '.exe -CC ';
  if UseDebugger then
    cl := cl + '-V ';
  Exec(cl + pasfile + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

// Run
procedure RunProc_DP;
begin
  var pasfile := IdeRec.WorkFile;
  if IdeRec.MainFile <> '' then
    pasfile := IdeRec.MainFile;
  var exefile := TPath.ChangeExtension(pasfile, '.exe');
  if not TFile.Exists(exefile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  if UseDebugger then
    Exec('TD32.EXE -P ' + exefile, IdeRec.ExePath, True)
  else
    Exec(exefile + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
end;

initialization
  IdeRec.Title1Str   := 'Delphi CC IDE';
  IdeRec.Title2Str   := 'Object Pascal';
  IdeRec.VersionStr  := 'Version 1.10';
  IdeRec.PlatformStr := 'for Win32';
  IdeRec.DefaultExt  := '.dpr';
  IdeRec.UseMainFile := True;
  {$IFDEF Win32}
  IdeRec.HasDebugger := True;
  {$ELSE}
  IdeRec.HasDebugger := False;
  {$ENDIF}

end.
