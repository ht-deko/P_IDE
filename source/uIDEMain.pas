{ ---------------------------------------------------------------------------- }
{ IDE Main Unit                                                                }
{ ---------------------------------------------------------------------------- }
unit uIDEMain;

interface

uses
  System.SysUtils, System.IOUtils, System.StrUtils, WinApi.Windows,
  uIDETypes, uIDEUtils, Crt32;

procedure RunIDE(Command_C, Command_R: TProc);

implementation

{ Routines }

procedure SetPath(aPath: string); forward;
procedure Command_W; forward;

// Intialize Program
procedure InitPG;
begin
  IdeRec.ExePath := TPath.GetDirectoryName(ParamStr(0));
  SetPath(GetCurrentDir);
  IdeRec.WorkFile := '';
  var FilePath := StrAlloc(1024);
  var FilePart: PChar;
  try
    IdeRec.HasEditor := SearchPath(nil, EDITOR_NAME, nil, 1024, FilePath, FilePart) > 0;
    IdeRec.HasDownloader := SearchPath(nil, DOWNLOADER_NAME, nil, 1024, FilePath, FilePart) > 0;
  finally
    StrDispose(FilePath);
  end;
  WorkFileProc := Command_W;
end;

// Invalid Path
procedure InvalidPath;
begin
  TextBackground(Red);
  WriteAndErase('Invalid directory', True);
  TextBackground(DEFAULT_BACK_COLOR);
end;

// Prompt
function Prompt: AnsiChar;
begin
  CRT.StartHighlighting;
  WriteAndErase('>');
  Result := UpCase(ReadKey);
end;

// Set Path
procedure SetPath;
begin
  IdeRec.FullPath := ExcludeTrailingPathDelimiter(aPath);
  IdeRec.LoggedDrive := UpCase(ExtractFileDrive(IdeRec.FullPath)[1]);
  IdeRec.ActiveDirectory := Copy(IdeRec.FullPath, 3, Length(IdeRec.FullPath));
  if IdeRec.ActiveDirectory = '' then
    IdeRec.ActiveDirectory := PathDelim;
end;

{ Menus }

// Splash
procedure Splash;
const
  MAXCOL = 40;
begin
  CRT.ClearScreen;
  WriteTextXY(1, 1, '----------------------------------------', True);
  WriteTextXY(1, 2, IdeRec.Title1Str, True);
  var s := IdeRec.VersionStr;
  WriteTextXY(Succ(MAXCOL - Length(s)), 2, s);
  WriteTextXY(1, 3, IdeRec.Title2Str, True);
  s := IdeRec.PlatformStr;
  WriteTextXY(Succ(MAXCOL - Length(s)), 3, s);
  WriteTextXY(1, 4, '----------------------------------------', True);
  // Caption
  WriteTextXY(1, 6, Format('Color display %dx%d', [SCREEN_WIDTH, SCREEN_HEIGHT]), True);
  // Check Editor
  var LinePos := 8;
  if not IdeRec.HasEditor then
    begin
      WriteTextXY(1, LinePos, ' - Editor not installed', True);
      Inc(LinePos);
    end;
  // Check DownLoader
  if not IdeRec.HasDownloader then
    begin
      WriteTextXY(1, LinePos, ' - Downloader not installed', True);
      Inc(LinePos);
    end;
  // Prompt
  Inc(LinePos, 3);
  WriteTextXY(1, LinePos, 'Press any key to start ', True);
  Readkey;
end; { Splash }

// Menu
procedure Menu;
const
  USE_STR: array [Boolean] of string = ('Not use', 'Use');
begin
  TextBackground(DEFAULT_BACK_COLOR);
  TextColor(DEFAULT_FORE_COLOR);
  CRT.ClearScreen;
  // Logged drive:
  LabeledTextXY( 1, 1, 'Logged drive: '    , IdeRec.LoggedDrive    );
  // Active directory:
  LabeledTextXY( 1, 2, 'Active directory: ', IdeRec.ActiveDirectory);
  // Work file:
  LabeledTextXY( 1, 4, 'Work file: '       , IdeRec.WorkFile       );
  // Command
  LabeledTextXY( 1, 6, 'Edit'   ); LabeledTextXY(10, 6, 'Compile'); LabeledTextXY(19, 6, 'Run'    ); LabeledTextXY(28, 6, 'More: ' , USE_STR[UseMoreCmd]);
  LabeledTextXY( 1, 7, 'Dir'    ); LabeledTextXY(10, 7, 'Get'    ); LabeledTextXY(19, 7, 'Type'   ); LabeledTextXY(28, 7, 'Quit'   );
  CRT.CursorPosition(1, 9);
end; { Menu }

{ Functions }

// Logged drive
procedure Command_L;
var
  Path: string;
begin
  LineBreak;
  WriteAndErase('New drive: ');
  Readln(Path);
  LineBreak;
  if Trim(Path) = '' then
    Exit;
  Path := ExcludeTrailingPathDelimiter(Path);
  var Drive := Upcase(Path[1]) + DriveDelim + PathDelim;
  if not MatchStr(Drive, TDirectory.GetLogicalDrives) then
    Exit;
  if (Length(Path) <= 3) then
    SetPath(Drive)
  else if (not TDirectory.Exists(Path)) then
    InvalidPath
  else
    begin
      Path := NormalizedPathName(Path);
      SetPath(Path);
    end;
end;

// Active directory:
procedure Command_A;
var
  Path: string;
begin
  LineBreak;
  WriteAndErase('New directory: ');
  Readln(Path);
  LineBreak;
  if Trim(Path) = '' then
    Exit;
  Path := ExcludeTrailingPathDelimiter(Path);
  var Drive := Upcase(Path[1]) + DriveDelim + PathDelim;
  if not MatchStr(Drive, TDirectory.GetLogicalDrives) then
    Exit;
  if (Length(Path) <= 3) then
    SetPath(Drive)
  else if (not TDirectory.Exists(Path)) then
    InvalidPath
  else
    begin
      Path := NormalizedPathName(Path);
      SetPath(Path);
    end;
end;

// Work file:
procedure Command_W;
var
  s: string;
begin
  LineBreak;
  WriteAndErase('Work file name: ');
  ReadLn(s);
  if Trim(s) = '' then
    Exit;
  if TPath.GetExtension(s) = '' then
    s := s + IdeRec.DefaultExt;
  IdeRec.WorkFile := s;
  if TPath.GetDirectoryName(IdeRec.WorkFile) = '' then
    IdeRec.WorkFile := CombinedPath(IdeRec.FullPath, IdeRec.WorkFile)
  else
    IdeRec.WorkFile := s;
   IdeRec.WorkFile := NormalizedFileName(IdeRec.WorkFile);
  LineBreak;
  Write('Loading ', IdeRec.WorkFile);
  WriteAndErase('', True);
  CRT.EndHighlighting;
  if TDirectory.Exists(TPath.GetDirectoryName(IdeRec.WorkFile)) then
    begin
      if not TFile.Exists(IdeRec.WorkFile) then
        WriteAndErase('New File', True);
    end
  else
    begin
      InvalidPath;
      IdeRec.WorkFile := '';
    end;
end;

// Edit
procedure Command_E;
begin
  if IdeRec.WorkFile = '' then
    Command_W;
  if IdeRec.WorkFile = '' then
    Exit;
  if IdeRec.HasEditor then
    Exec(EDITOR_NAME + ' ' + IdeRec.WorkFile)
  else
    begin
      CRT.ClearScreen;
      Exec('COPY CON ' + IdeRec.WorkFile, '', True);
    end;
end;

// MORE Command
procedure Command_M;
begin
  UseMoreCmd := not UseMoreCmd;
end;

// Dir
procedure Command_D;
begin
  var FileMask: string;
  LineBreak;
  WriteAndErase('Dir Mask: ');
  Readln(FileMask);
  if Trim(FileMask) = '' then
    FileMask:= '*.*';
  CRT.EraseToEOL;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('DIR ' + CombinedPath(IdeRec.FullPath, FileMask) + MORECMD_STR[UseMoreCmd], '', True);
end;

// Get
procedure Command_G;
begin
  if not IdeRec.HasDownloader then
    begin
      LineBreak;
      WriteAndErase('This feature is not available.', True);
      Exit;
    end;

  var FileURL: string;
  LineBreak;
  WriteAndErase('File URL: ');
  Readln(FileURL);
  if Trim(FileURL) = '' then
    Exit;
  CRT.EndHighlighting;
  Exec(DOWNLOADER_NAME + ' ' + Format(DOWNLOADER_PARAM, [FileURL]), IdeRec.FullPath);
end;

// Type
procedure Command_T;
begin
  if IdeRec.WorkFile = '' then
    begin
      Command_W;
      if IdeRec.WorkFile = '' then
        Exit;
    end;
  if not TFile.Exists(IdeRec.WorkFile) then
    begin
      LineBreak;
      WriteAndErase('File not found.', True);
      Exit;
    end;
  CRT.ClearScreen;
  CRT.EndHighlighting;
  Exec('TYPE ' + IdeRec.WorkFile + MORECMD_STR[UseMoreCmd], '', True);
end;

// Quit
function Command_Q: Boolean;
begin
  Result := True;
end;

// RunIDE
procedure RunIDE(Command_C, Command_R: TProc);
begin
  InitPG;
  Splash;
  while True do
  begin
    Menu;
    while True do
      begin
        case Prompt of
          'L': Command_L;
          'A': Command_A;
          'W': Command_W;
          'E': begin
                 Command_E;
                 Break;
               end;
          'C': Command_C;
          'R': Command_R;
          'M': begin
                 Command_M;
                 Break;
               end;
          'D': Command_D;
          'G': Command_G;
          'T': Command_T;
          'Q': begin
                 if Command_Q then
                   Exit;
               end;
        else
          Break;
        end;
        WriteAndErase('', True);
        WriteAndErase('', False);
      end;
  end;
end; { RunIDE }

end.
