{ ---------------------------------------------------------------------------- }
{ Pascal-P5 Unit                                                               }
{ ---------------------------------------------------------------------------- }
unit uP5;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_P5;
procedure RunProc_P5;

implementation

// Compile
procedure CompileProc_P5;
begin
  if IdeRec.WorkFile = '' then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  var pasfile := IdeRec.WorkFile;
  var p5file := TPath.ChangeExtension(pasfile, '.p5');
  var prdFile := CombinedPath(IdeRec.ExePath, 'prd');
  var prrFile := CombinedPath(IdeRec.ExePath, 'prr');
  if not TFile.Exists(pasfile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  DeleteFile(prdFile);
  DeleteFile(prrFile);
  DeleteFile(p5file);
  TFile.Copy(pasfile, prdFile);
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pcom.exe' + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
  if TFile.Exists(prrFile) then
    begin
      TFile.Copy(prrFile, p5file);
      TFile.Delete(prrFile);
    end;
  DeleteFile(prdFile);
end;

// Run
procedure RunProc_P5;
begin
  var pasfile := IdeRec.WorkFile;
  var p5file := TPath.ChangeExtension(pasfile, '.p5');
  var outfile := TPath.ChangeExtension(pasfile, '.prr');
  var prdFile := CombinedPath(IdeRec.ExePath, 'prd');
  var prrFile := CombinedPath(IdeRec.ExePath, 'prr');
  if not TFile.Exists(p5file) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  DeleteFile(prdFile);
  DeleteFile(prrFile);
  TFile.Copy(p5file, prdFile);
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('pint.exe' + MORECMD_STR[UseMoreCmd], IdeRec.ExePath, True);
  if TFile.Exists(prrFile) then
    begin
      if TFile.GetSize(prrFile) <> 0 then
        begin
          TFile.Delete(outfile);
          TFile.Copy(prrFile, outfile);
        end;
      TFile.Delete(prrFile);
    end;
  DeleteFile(prdFile);
end;

initialization
  IdeRec.Title1Str   := 'Pascal-P5 IDE';
  IdeRec.Title2Str   := 'Standard Pascal Level 0';
  IdeRec.VersionStr  := 'Version 1.10';
  IdeRec.PlatformStr := 'for Win32';

end.
