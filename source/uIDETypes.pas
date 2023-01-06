{ ---------------------------------------------------------------------------- }
{ IDE Types Unit                                                               }
{ ---------------------------------------------------------------------------- }
unit uIDETypes;

interface

uses
  System.SysUtils, WinApi.Windows, System.IOUtils, crt32;

const
  EDITOR_NAME = 'MICRO.EXE';
  DOWNLOADER_NAME = 'CURL.EXE';
  DOWNLOADER_PARAM = '-OL %s';
  SCREEN_WIDTH = 80;
  SCREEN_HEIGHT = 25;
  HIGHLIGHT_COLOR = Yellow;
  DEFAULT_FORE_COLOR = White;
  DEFAULT_BACK_COLOR = Black;

  MORECMD_STR: array [Boolean] of string = (' ', ' | MORE');

type
  TCRTColor = Black..White;

  TCRT = record
    FBackColor: TCRTColor;
    FForeColor: TCRTColor;
  public
    procedure ClearScreen;
    procedure CursorPosition(X, Y: Integer);
    procedure Delay(ms: Word; Alertable: Boolean = False);
    procedure DeleteLine;
    procedure EndHighlighting;
    procedure EraseToEOL;
    procedure Home;
    procedure Init(ForeColor: TCRTColor = White; BackColor: TCRTColor = Black);
    procedure InsertLine;
    procedure ResetColor;
    procedure StartHighlighting;
  end;

  TIdeRec = record
    LoggedDrive: Char;
    ActiveDirectory: string;
    FullPath: string;
    WorkFile: string;
    UseMainFile: Boolean;
    MainFile: string;
    ExePath: string;
    HasEditor: Boolean;
    HasDownloader: Boolean;
    Title1Str: String;
    Title2Str: String;
    VersionStr: String;
    PlatformStr: String;
    DefaultExt: String;
  end;

implementation

{ TCRT }

procedure TCRT.ClearScreen;
begin
  ClrScr;
end;

procedure TCRT.CursorPosition(X, Y: Integer);
begin
  GotoXY(X, Y);
end;

procedure TCRT.Delay(ms: Word; Alertable: Boolean);
begin
  SleepEx(MS, Alertable);
end;

procedure TCRT.DeleteLine;
begin
  DelLine;
end;

procedure TCRT.EndHighlighting;
begin
  TextColor(White);
end;

procedure TCRT.EraseToEOL;
begin
  ClrEol;
end;

procedure TCRT.Home;
begin
  GotoXY(0, 0);
end;

procedure TCRT.Init(ForeColor: TCRTColor; BackColor: TCRTColor);
begin
  FForeColor := ForeColor;
  FBackColor := BackColor;
  TextBackground(FBackColor);
  TextColor(FForeColor);
  ClrScr;
end;

procedure TCRT.InsertLine;
begin
  InsLine;
end;

procedure TCRT.ResetColor;
begin
  TextColor(White);
  TextBackground(Black);
end;

procedure TCRT.StartHighlighting;
begin
  TextColor(HIGHLIGHT_COLOR);
end;

end.
