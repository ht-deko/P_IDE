{ ---------------------------------------------------------------------------- }
{ IDE Utils Unit                                                               }
{ ---------------------------------------------------------------------------- }
unit uIDEUtils;

interface

uses
  System.SysUtils, System.IOUtils, WinApi.Windows, uIDETypes, Crt32;

function CombinedPath(Path1, Path2: string): string;
procedure DeleteFile(FileName: string);
procedure Exec(Cmd: string; Path: string = '');
procedure LabeledTextXY(x, y: Byte; aLabel: string; aData: string = '');
procedure LineBreak;
function NormalizedFileName(aFileName: string): string;
function NormalizedPathName(aPathName: string): string;
procedure WriteAndErase(s: string; aLineBreak: Boolean = False);
procedure WriteText(aText: string; Highlighting: Boolean = False);
procedure WriteTextXY(x, y: Byte; aText: string; Highlighting: Boolean = False);

var
  CRT: TCRT;
  IdeRec: TIdeRec;
  WorkFileProc: TProc;

implementation

// Combined Path
function CombinedPath(Path1, Path2: string): string;
begin
  // https://quality.embarcadero.com/browse/RSP-36700
  Result := TPath.Combine(IncludeTrailingPathDelimiter(Path1), Path2);
end;

// Delete File
procedure DeleteFile(FileName: string);
begin
  if TFile.Exists(FileName) then
    TFile.Delete(FileName);
end;

// Exec
procedure Exec(Cmd: string; Path: string);
var
  CommandLine, CurrentPath: string;
  SI: TStartupInfo;
  PI: TProcessInformation;
  CP: PChar;
begin
  CommandLine := Cmd;
  UniqueString(CommandLine);
  if Path = '' then
    CP := nil
  else
    begin
      CurrentPath := Path;
      UniqueString(CurrentPath);
      CP := PChar(CurrentPath);
    end;
  try
    FillChar(SI, SizeOf(SI), 0);
    FillChar(PI, SizeOf(PI), 0);
    SI.cb := SizeOf(SI);
    if not CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, CP, SI, PI) then
      RaiseLastOSError;
    WaitForSingleObject(PI.hProcess, INFINITE);
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;

// Labeled Text XY
procedure LabeledTextXY(x, y: Byte; aLabel: string; aData: string = '');
begin
  WriteTextXY(x, y, aLabel[1], True);
  WriteText(Copy(aLabel, 2, Length(aLabel)));
  if aData <> '' then
    WriteText(aData, True);
end;

// Line break
procedure LineBreak;
begin
  CRT.EraseToEOL;
  Writeln;
  var X := WhereX;
  var Y := WhereY;
  CRT.EraseToEOL;
  CRT.CursorPosition(X, Y);
end;

// Normalized File name
function NormalizedFileName(aFileName: string): string;
begin
  result := aFileName;
  for var FileName in TDirectory.GetFiles(TPath.GetDirectoryName(aFileName), TPath.GetFileName(aFileName), TSearchOption.soTopDirectoryOnly) do
    begin
      if SameText(FileName, aFileName) then
        begin
          result := FileName;
          result[1] := UpCase(result[1]);
          Break;
        end;
    end;
end;

// Normalized Path name
function NormalizedPathName(aPathName: string): string;
begin
  result := aPathName;
  for var PathName in TDirectory.GetDirectories(TPath.GetDirectoryName(aPathName), TPath.GetFileName(aPathName), TSearchOption.soTopDirectoryOnly) do
    begin
      if SameText(PathName, aPathName) then
        begin
          result := PathName;
          result[1] := UpCase(result[1]);
          Break;
        end;
    end;
end;

// Write and Erase
procedure WriteAndErase(s: string; aLineBreak: Boolean);
begin
  var X := WhereX;
  var Y := WhereY;
  CRT.EraseToEOL;
  CRT.CursorPosition(X, Y);
  Write(s);
  if aLineBreak then
    LineBreak;
end;

// Write Text
procedure WriteText(aText: string; Highlighting: Boolean);
begin
  if Highlighting then
    CRT.StartHighlighting
  else
    CRT.EndHighlighting;
  Write(aText);
end;

// Write Text XY
procedure WriteTextXY(x, y: Byte; aText: string; Highlighting: Boolean);
begin
  CRT.CursorPosition(x, y);
  WriteText(aText, Highlighting);
end;

initialization
  CRT.Init(DEFAULT_FORE_COLOR, DEFAULT_BACK_COLOR);
  IdeRec.DefaultExt := '.pas';

finalization
  CRT.ResetColor;

end.
