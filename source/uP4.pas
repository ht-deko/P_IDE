{ ---------------------------------------------------------------------------- }
{ Pascal-P4 Unit                                                               }
{ ---------------------------------------------------------------------------- }
unit uP4;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, uIDEUtils;

procedure CompileProc_P4;
procedure RunProc_P4;

implementation

// Compile
procedure CompileProc_P4;
begin
  if IdeRec.WorkFile = '' then
    begin
      WorkFileProc;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  var pasfile := IdeRec.WorkFile;
  var p4file := TPath.ChangeExtension(pasfile, '.p4');
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
  DeleteFile(p4file);
  CRT.ClearScreen;
  CRT.EndHighlighting;
//Exec('CMD.EXE /C pcom.exe < ' + pasfile, IdeRec.ExePath);
  Exec('CMD.EXE /C pcom.exe < ' + pasfile + ' | MORE', IdeRec.ExePath);
  if TFile.Exists(prrFile) then
    begin
      TFile.Copy(prrFile, p4file);
      TFile.Delete(prrFile);
    end;
  DeleteFile(prdFile);
end;

// Run
procedure RunProc_P4;
begin
  var pasfile := IdeRec.WorkFile;
  var p4file := TPath.ChangeExtension(pasfile, '.p4');
  var outfile := TPath.ChangeExtension(pasfile, '.prr');
  var prdFile := CombinedPath(IdeRec.ExePath, 'prd');
  var prrFile := CombinedPath(IdeRec.ExePath, 'prr');
  if not TFile.Exists(p4file) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  DeleteFile(prdFile);
  DeleteFile(prrFile);
  TFile.Copy(p4file, prdFile);
  CRT.ClearScreen;
  CRT.EndHighlighting;
//Exec('CMD.EXE /C pint.exe < NUL', IdeRec.ExePath);
  Exec('CMD.EXE /C pint.exe < NUL | MORE', IdeRec.ExePath);
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
  IdeRec.Title1Str   := 'Pascal-P4 IDE';
  IdeRec.Title2Str   := 'Standard Pascal Subset';
  IdeRec.VersionStr  := 'Version 1.00';
  IdeRec.PlatformStr := 'for Win32';

end.
