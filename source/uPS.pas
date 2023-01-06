{ ---------------------------------------------------------------------------- }
{ Pascal-S Unit                                                                }
{ ---------------------------------------------------------------------------- }
unit uPS;

{$define UseModVersion}

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_PS;
procedure RunProc_PS;

implementation

// Compile
procedure CompileProc_PS;
begin
  RunProc_PS;
end;

// Run
procedure RunProc_PS;
begin
  if IdeRec.WorkFile = '' then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
{$ifdef UseModVersion}
  if not TFile.Exists(IdeRec.WorkFile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pascals_mod.exe ' + IdeRec.WorkFile + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
{$else}
  var pasfile := IdeRec.WorkFile;
  var srcFile := CombinedPath(IdeRec.ExePath, 'srcfil');
  if not TFile.Exists(pasfile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  DeleteFile(srcFile);
  TFile.Copy(pasfile, srcFile);
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pascals.exe' + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
  DeleteFile(srcFile);
{$endif}
end;

initialization
  IdeRec.Title1Str   := 'Pascal-S IDE';
  IdeRec.Title2Str   := 'Subset of Standard Pascal';
  IdeRec.VersionStr  := 'Version 1.10';
  IdeRec.PlatformStr := 'for Win32';

end.
