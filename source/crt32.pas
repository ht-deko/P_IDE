{ *********************************************************************** }
{                                                                         }
{ Delphi Runtime Library                                                  }
{ Crt Interface Unit                                                      }
{                                                                         }
{ *********************************************************************** }

unit Crt32;

{$Define NEW_STYLES}
{ ..$Define HARD_CRT }      { Redirect STD_... }
{ ..$Define CRT_EVENT }     { CTRL-C,... }
{$Define MOUSE_IS_USED}     { Handle mouse or not }
{ ..$Define OneByOne }      { Block or byte style write }

interface

{$IFDEF MSWINDOWS}

const
  { CRT modes of original CRT unit }
  BW40               =   0; { 40x25 B/W on Color Adapter }
  CO40               =   1; { 40x25 Color on Color Adapter }
  BW80               =   2; { 80x25 B/W on Color Adapter }
  CO80               =   3; { 80x25 Color on Color Adapter }
  Mono               =   7; { 80x25 on Monochrome Adapter }
  Font8x8            = 256; { Add-in for ROM font }

  { Mode constants for 3.0 compatibility of original CRT unit }
  C40                = CO40;
  C80                = CO80;

  { Foreground and background color constants of original CRT unit }
  Black              = 0;
  Blue               = 1;
  Green              = 2;
  Cyan               = 3;
  Red                = 4;
  Magenta            = 5;
  Brown              = 6;
  LightGray          = 7;

  { Foreground color constants of original CRT unit }
  DarkGray           = 8;
  LightBlue          = 9;
  LightGreen         = 10;
  LightCyan          = 11;
  LightRed           = 12;
  LightMagenta       = 13;
  Yellow             = 14;
  White              = 15;

  { Add-in for blinking of original CRT unit }
  Blink              = 128;

  { New constans there are not in original CRT unit }
  MouseLeftButton    = 1;
  MouseRightButton   = 2;
  MouseCenterButton  = 4;

  { Console output codepage }
  ConsoleOutputCP    = 65001; // UTF-8

var
  { Interface variables of original CRT unit }
  CheckBreak: Boolean;      { Enable Ctrl-Break }
  CheckEOF: Boolean;        { Enable Ctrl-Z }
  CheckSnow: Boolean;       { Enable snow filtering }
  DirectVideo: Boolean;     { Enable direct video addressing }
  LastMode: Word;           { Current text mode }
  TextAttr: Byte;           { Current text attribute }
  WindMax: Word;            { Window lower right coordinates }
  WindMin: Word;            { Window upper left coordinates }

  { New variables there are not in original CRT unit }
  MouseInstalled: Boolean;
  MousePressedButtons: Word;

  { Interface functions & procedures of original CRT unit }
  procedure AssignCrt(var F: Text);
  procedure ClrEol;
  procedure ClrScr;
  procedure CursorTo(X, Y: Byte);
  procedure Delay(MS: Word);
  procedure DelLine;
  procedure GotoXY(X, Y: Byte);
  procedure HighVideo;
  procedure InsLine;
  function KeyPressed: Boolean;
  procedure LowVideo;
  procedure NormVideo;
  procedure NoSound;
  function ReadKey: AnsiChar;
  procedure Sound(Hz: Word);
  procedure TextBackground(Color: Byte);
  procedure TextColor(Color: Byte);
  procedure TextMode(Mode: Integer);
  function WhereX: Byte;
  function WhereY: Byte;
  procedure Window(X1, Y1, X2, Y2: Byte);

  { New functions & procedures there are not in original CRT unit }
  procedure FillerScreen(FillChar: Char);
  procedure FlushInputBuffer;
  function GetCursor: Word;
  procedure MouseGotoXY(X, Y: Integer);
  procedure MouseHideCursor;
  function MouseKeyPressed: Boolean;
  procedure MouseShowCursor;
  function MouseWhereX: Integer;
  function MouseWhereY: Integer;
  function ScreenHeight: Integer;
  function ScreenWidth: Integer;
  procedure SetCursor(NewCursor: Word);
  function WriteText(s: string; LineBreak: Boolean = False): UInt32;
  function WriteLineText(s: string = ''): UInt32;

{$ENDIF MSWINDOWS}

implementation

{$IFDEF MSWINDOWS}

uses
  AnsiStrings, Windows, SysUtils;

type
  POpenText = ^TOpenText;
  TOpenText = function(var F: Text; Mode: Word): Integer; far;

var
  IsWinNT: Boolean;
  PtrOpenText: POpenText;
  hConsoleInput: THandle;
  hConsoleOutput: THandle;
  ConsoleScreenRect: TSmallRect;
  StartAttr: Word;
  LastX, LastY: Byte;
  SoundDuration: Integer;
  SoundFrequency: Integer;
  OldCP: Integer;
  MouseRowWidth, MouseColWidth: Word;
  MousePosX, MousePosY: smallInt;
  MouseButtonPressed: Boolean;
  MouseEventTime: TDateTime;

{ --- Begin of functions & procedures are for inside use only --- }

{ Write string into the X,Y position }
procedure WriteStrXY(X, Y: Byte; Str: PAnsiChar; dwSize: Integer);
{$IFDEF OneByOne}
var
  dwCount: Integer;
{$ELSE}
var
  I: Integer;
  LineSize, dwCharCount, dwCount, dwWait: DWORD;
  WidthHeight: TCoord;
  OneLine: packed array [0 .. 131] of AnsiChar;
  Line, TempStr: PAnsiChar;

  procedure NewLine;
  begin
    LastX := 1;
    Inc(LastY);
    if (LastY + ConsoleScreenRect.Top) > (ConsoleScreenRect.Bottom + 1) then
    begin
      Dec(LastY);
      GotoXY(1, 1);
      DelLine;
    end;
    GotoXY(LastX, LastY);
  end;

{$ENDIF}

begin
  if dwSize > 0 then
  begin
{$IFDEF OneByOne}
    LastX := X;
    LastY := Y;
    dwCount := 0;
    while dwCount < dwSize do
    begin
      WriteChrXY(LastX, LastY, Str[dwCount]);
      Inc(dwCount);
    end;
{$ELSE}
    LastX := X;
    LastY := Y;
    GotoXY(LastX, LastY);
    dwWait := dwSize;
    TempStr := Str;
    while (dwWait > 0) and
      (Pos(#13#10, String(AnsiStrings.StrPas(TempStr))) = 1) do
    begin
      Dec(dwWait, 2);
      Inc(TempStr, 2);
      NewLine;
    end;
    while (dwWait > 0) and
      (Pos(#10, String(AnsiStrings.StrPas(TempStr))) = 1) do
    begin
      Dec(dwWait);
      Inc(TempStr);
      NewLine;
    end;
    if dwWait > 0 then
    begin
      if dwSize <= (ConsoleScreenRect.Right - ConsoleScreenRect.Left - LastX + 1)
      then
      begin
        WidthHeight.X := dwSize + LastX - 1;
        WidthHeight.Y := 1;
      end
      else
      begin
        WidthHeight.X := ConsoleScreenRect.Right - ConsoleScreenRect.Left + 1;
        WidthHeight.Y := dwSize div WidthHeight.X;
        if (dwSize mod WidthHeight.X) > 0 then
          Inc(WidthHeight.Y);
      end;
      for I := 1 to WidthHeight.Y do
      begin
        FillChar(OneLine, SizeOf(OneLine), #0);
        Line := @OneLine;
        LineSize := WidthHeight.X - LastX + 1;
        if LineSize > dwWait then
          LineSize := dwWait;
        Dec(dwWait, LineSize);
        AnsiStrings.StrLCopy(Line, TempStr, LineSize);
        Inc(TempStr, LineSize);
        dwCharCount := Pos(#13#10, String(AnsiStrings.StrPas(Line)));
        if dwCharCount > 0 then
        begin
          OneLine[dwCharCount - 1] := #0;
          OneLine[dwCharCount] := #0;
          WriteConsoleA(hConsoleOutput, Line, dwCharCount - 1, dwCount, nil);
          Inc(Line, dwCharCount + 1);
          NewLine;
          LineSize := LineSize - (dwCharCount + 1);
        end
        else
        begin
          dwCharCount := Pos(#10, String(AnsiStrings.StrPas(Line)));
          if dwCharCount > 0 then
          begin
            OneLine[dwCharCount - 1] := #0;
            WriteConsoleA(hConsoleOutput, Line, dwCharCount - 1, dwCount, nil);
            Inc(Line, dwCharCount);
            NewLine;
            LineSize := LineSize - dwCharCount;
          end;
        end;
        if LineSize <> 0 then
        begin
          WriteConsoleA(hConsoleOutput, Line, LineSize, dwCount, nil);
        end;
        if dwWait > 0 then
        begin
          NewLine;
        end;
      end;
    end;
{$ENDIF}
  end;
end;

{ Console Event Handler }
{$IFDEF CRT_EVENT}
function ConsoleEventProc(CtrlType: DWORD): Bool; stdcall; far;
var
  S: {$IFDEF MSWINDOWS}ShortString{$ELSE}String{$ENDIF};
  Message: PAnsiChar;
begin
  case CtrlType of
    CTRL_C_EVENT:
      S := 'CTRL_C_EVENT';
    CTRL_BREAK_EVENT:
      S := 'CTRL_BREAK_EVENT';
    CTRL_CLOSE_EVENT:
      S := 'CTRL_CLOSE_EVENT';
    CTRL_LOGOFF_EVENT:
      S := 'CTRL_LOGOFF_EVENT';
    CTRL_SHUTDOWN_EVENT:
      S := 'CTRL_SHUTDOWN_EVENT';
  else
    S := 'UNKNOWN_EVENT';
  end;
  S := S + ' detected, but not handled.';
  Message := @S;
  Inc(Message);
  MessageBox(0, Message, 'Win32 Console', MB_OK);
  Result := True;
end;
{$ENDIF}

{ This function handles the exchanging of Input or Output }
function OpenText(var F: Text; Mode: Word): Integer; far;
var
  OpenResult: Integer;
begin
  OpenResult := 102; { Text not assigned }
  if Assigned(PtrOpenText) then
  begin
    TTextRec(F).OpenFunc := PtrOpenText;
    OpenResult := PtrOpenText^(F, Mode);
    if OpenResult = 0 then
    begin
      if Mode = fmInput then
        hConsoleInput := TTextRec(F).Handle
      else
      begin
        hConsoleOutput := TTextRec(F).Handle;
        TTextRec(Output).InOutFunc := @TextOut;
        TTextRec(Output).FlushFunc := @TextOut;
      end;
    end;
  end;
  Result := OpenResult;
end;

{ This function handles the Write and WriteLn commands }
function TextOut(var F: Text): Integer; far;
{$IFDEF OneByOne}
var
  dwSize: DWORD;
{$ENDIF}
begin
  with TTextRec(F) do
  begin
    if BufPos > 0 then
    begin
      LastX := WhereX;
      LastY := WhereY;
{$IFDEF OneByOne}
      dwSize := 0;
      while (dwSize < BufPos) do
      begin
        WriteChrXY(LastX, LastY, BufPtr[dwSize]);
        Inc(dwSize);
      end;
{$ELSE}
      WriteStrXY(LastX, LastY, BufPtr, BufPos);
      FillChar(BufPtr^, BufPos + 1, #0);
{$ENDIF}
      BufPos := 0;
    end;
  end;
  Result := 0;
end;

function MouseReset: Boolean;
begin
  MouseColWidth := 1;
  MouseRowWidth := 1;
  Result := True;
end;

procedure Init;
const
  ExtInpConsoleMode = ENABLE_WINDOW_INPUT or ENABLE_PROCESSED_INPUT or
    ENABLE_MOUSE_INPUT;
  ExtOutConsoleMode = ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT;
var
  cMode: DWORD;
  Coord: TCoord;
  OSVersion: TOSVersionInfo;
  CBI: TConsoleScreenBufferInfo;
begin
  OSVersion.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OSVersion);
  if OSVersion.dwPlatformId = VER_PLATFORM_WIN32_NT then
    IsWinNT := True
  else
    IsWinNT := False;
  PtrOpenText := TTextRec(Output).OpenFunc;
  OldCP := GetConsoleOutputCP;
  SetConsoleOutputCP(ConsoleOutputCP);
{$IFDEF HARD_CRT}
  AllocConsole;
  Reset(Input);
  hConsoleInput := GetStdHandle(STD_INPUT_HANDLE);
  TTextRec(Input).Handle := hConsoleInput;
  ReWrite(Output);
  hConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  TTextRec(Output).Handle := hConsoleOutput;
{$ELSE}
  Reset(Input);
  hConsoleInput := TTextRec(Input).Handle;
  ReWrite(Output);
  hConsoleOutput := TTextRec(Output).Handle;
{$ENDIF}
  GetConsoleMode(hConsoleInput, cMode);
  if (cMode and ExtInpConsoleMode) <> ExtInpConsoleMode then
  begin
    cMode := cMode or ExtInpConsoleMode;
    SetConsoleMode(hConsoleInput, cMode);
  end;

  TTextRec(Output).InOutFunc := @TextOut;
  TTextRec(Output).FlushFunc := @TextOut;
  GetConsoleScreenBufferInfo(hConsoleOutput, CBI);
  GetConsoleMode(hConsoleOutput, cMode);
  if (cMode and ExtOutConsoleMode) <> ExtOutConsoleMode then
  begin
    cMode := cMode or ExtOutConsoleMode;
    SetConsoleMode(hConsoleOutput, cMode);
  end;
  TextAttr := CBI.wAttributes;
  StartAttr := CBI.wAttributes;
  LastMode := CBI.wAttributes;

  Coord.X := CBI.srWindow.Left;
  Coord.Y := CBI.srWindow.Top;
  WindMin := (Coord.Y shl 8) or Coord.X;
  Coord.X := CBI.srWindow.Right;
  Coord.Y := CBI.srWindow.Bottom;
  WindMax := (Coord.Y shl 8) or Coord.X;
  ConsoleScreenRect := CBI.srWindow;

  SoundDuration := -1;
{$IFDEF CRT_EVENT}
  SetConsoleCtrlHandler(@ConsoleEventProc, True);
{$ENDIF}
{$IFDEF MOUSE_IS_USED}
  SetCapture(hConsoleInput);
  KeyPressed;
{$ENDIF}
  MouseInstalled := MouseReset;
  Window(1, 1, 80, 25);
  ClrScr;
end;

procedure Done;
begin
{$IFDEF CRT_EVENT}
  SetConsoleCtrlHandler(@ConsoleEventProc, False);
{$ENDIF}
  SetConsoleOutputCP(OldCP);
  TextAttr := StartAttr;
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
  ClrScr;
  FlushInputBuffer;
{$IFDEF HARD_CRT}
  TTextRec(Input).Mode := fmClosed;
  TTextRec(Output).Mode := fmClosed;
  FreeConsole;
{$ELSE}
  Close(Input);
  Close(Output);
{$ENDIF}
end;

procedure OverwriteChrXY(X, Y: Byte; Chr: AnsiChar);
var
  Coord: TCoord;
  dwSize, dwCount: DWORD;
begin
  LastX := X;
  LastY := Y;
  Coord.X := LastX - 1 + ConsoleScreenRect.Left;
  Coord.Y := LastY - 1 + ConsoleScreenRect.Top;
  dwSize := 1;
  FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize, Coord, dwCount);
  FillConsoleOutputCharacterA(hConsoleOutput, Chr, dwSize, Coord, dwCount);
  GotoXY(LastX, LastY);
end;

{ Write one character at the X,Y position }
procedure WriteChrXY(X, Y: Byte; Chr: AnsiChar);
var
  Coord: TCoord;
  dwSize, dwCount: DWORD;
begin
  LastX := X;
  LastY := Y;
  case Chr of
    #13:
      LastX := 1;
    #10:
      begin
        LastX := 1;
        Inc(LastY);
      end;
  else
    begin
      Coord.X := LastX - 1 + ConsoleScreenRect.Left;
      Coord.Y := LastY - 1 + ConsoleScreenRect.Top;
      dwSize := 1;
      FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize,
        Coord, dwCount);
      FillConsoleOutputCharacterA(hConsoleOutput, Chr, dwSize, Coord, dwCount);
      Inc(LastX);
    end;
  end;
  if (LastX + ConsoleScreenRect.Left) > (ConsoleScreenRect.Right + 1) then
  begin
    LastX := 1;
    Inc(LastY);
  end;
  if (LastY + ConsoleScreenRect.Top) > (ConsoleScreenRect.Bottom + 1) then
  begin
    Dec(LastY);
    GotoXY(1, 1);
    DelLine;
  end;
  GotoXY(LastX, LastY);
end;

{ --- Begin of functions & procedures of original CRT unit --- }

procedure AssignCrt(var F: Text);
begin
  Assign(F, '');
  TTextRec(F).OpenFunc := @OpenText;
end;

procedure ClrScr;
begin
  FillerScreen(' ');
end;

procedure ClrEol;
var
  Coord: TCoord;
  dwSize, dwCount: DWORD;
begin
  Coord.X := WhereX - 1 + ConsoleScreenRect.Left;
  Coord.Y := WhereY - 1 + ConsoleScreenRect.Top;
  dwSize := ConsoleScreenRect.Right - Coord.X + 1;
  FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize, Coord, dwCount);
  FillConsoleOutputCharacter(hConsoleOutput, ' ', dwSize, Coord, dwCount);
end;

procedure CursorTo(X, Y: Byte);
begin
  GotoXY(X + 1, Y + 1);
end;

procedure Delay(MS: Word);
begin
  Windows.SleepEx(MS, False); // Windows.Sleep(MS);
end;

procedure DelLine;
var
  SourceScreenRect: TSmallRect;
  Coord: TCoord;
  CI: TCharinfo;
  dwSize, dwCount: DWORD;
begin
  SourceScreenRect := ConsoleScreenRect;
  SourceScreenRect.Top := WhereY + ConsoleScreenRect.Top;
  CI.AsciiChar := ' ';
  CI.Attributes := TextAttr;
  Coord.X := SourceScreenRect.Left;
  Coord.Y := SourceScreenRect.Top - 1;
  dwSize := SourceScreenRect.Right - SourceScreenRect.Left + 1;
  ScrollConsoleScreenBuffer(hConsoleOutput, SourceScreenRect, nil, Coord, CI);
  FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize, Coord, dwCount);
end;

procedure GotoXY(X, Y: Byte);
var
  Coord: TCoord;
begin
  Coord.X := X - 1 + ConsoleScreenRect.Left;
  Coord.Y := Y - 1 + ConsoleScreenRect.Top;
  if not SetConsoleCursorPosition(hConsoleOutput, Coord) then
  begin
    GotoXY(1, 1);
    DelLine;
  end;
end;

procedure HighVideo;
begin
  LastMode := TextAttr;
  TextAttr := TextAttr or $08;
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
end;

procedure InsLine;
var
  SourceScreenRect: TSmallRect;
  Coord: TCoord;
  CI: TCharinfo;
  dwSize, dwCount: DWORD;
begin
  SourceScreenRect := ConsoleScreenRect;
  SourceScreenRect.Top := WhereY - 1 + ConsoleScreenRect.Top;
  SourceScreenRect.Bottom := ConsoleScreenRect.Bottom - 1;
  CI.AsciiChar := ' ';
  CI.Attributes := TextAttr;
  Coord.X := SourceScreenRect.Left;
  Coord.Y := SourceScreenRect.Top + 1;
  dwSize := SourceScreenRect.Right - SourceScreenRect.Left + 1;
  ScrollConsoleScreenBuffer(hConsoleOutput, SourceScreenRect, nil, Coord, CI);
  Dec(Coord.Y);
  FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize, Coord, dwCount);
end;

function KeyPressed: Boolean;
var
  NumberOfEvents: DWORD;
  NumRead: DWORD;
  InputRec: TInputRecord;
  Pressed: Boolean;
begin
  Pressed := False;
  GetNumberOfConsoleInputEvents(hConsoleInput, NumberOfEvents);
  if NumberOfEvents > 0 then
  begin
    if PeekConsoleInput(hConsoleInput, InputRec, 1, NumRead) then
    begin
      if (InputRec.EventType = KEY_EVENT) and
        (InputRec{$IFDEF NEW_STYLES}.Event{$ENDIF}.KeyEvent.bKeyDown) then
      begin
        Pressed := True;
{$IFDEF MOUSE_IS_USED}
        MouseButtonPressed := False;
{$ENDIF}
      end
      else
      begin
{$IFDEF MOUSE_IS_USED}
        if (InputRec.EventType = _MOUSE_EVENT) then
        begin
          with InputRec{$IFDEF NEW_STYLES}.Event{$ENDIF}.MouseEvent do
          begin
            MousePosX := dwMousePosition.X;
            MousePosY := dwMousePosition.Y;
            if dwButtonState = FROM_LEFT_1ST_BUTTON_PRESSED then
            begin
              MouseEventTime := Now;
              MouseButtonPressed := True;
              { If (dwEventFlags AND DOUBLE_CLICK)<>0 Then Begin }
              { End; }
            end;
          end;
        end;
        ReadConsoleInput(hConsoleInput, InputRec, 1, NumRead);
{$ELSE}
          ReadConsoleInput(hConsoleInput, InputRec, 1, NumRead);
{$ENDIF}
      end;
    end;
  end;
  Result := Pressed;
end;

procedure LowVideo;
begin
  LastMode := TextAttr;
  TextAttr := TextAttr and $F7;
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
end;

procedure NormVideo;
begin
  LastMode := TextAttr;
  TextAttr := StartAttr;
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
end;

procedure NoSound;
  procedure _NoSound;
  begin
    {$IFDEF Win32}
    asm
      { Set Sound On }
      in   Al,$61
      and  Al,$FC
      out  $61,Al
    end;
    {$ENDIF}
  end;
begin
  if IsWinNT then
    Windows.Beep(SoundFrequency, 0)
  else
    _NoSound;
end;

function ReadKey: AnsiChar;
var
  NumRead: DWORD;
  InputRec: TInputRecord;
begin
  repeat
    repeat
    until KeyPressed;
    ReadConsoleInput(hConsoleInput, InputRec, 1, NumRead);
  until InputRec{$IFDEF NEW_STYLES}.Event{$ENDIF}.KeyEvent.AsciiChar > #0;
  Result := InputRec{$IFDEF NEW_STYLES}.Event{$ENDIF}.KeyEvent.AsciiChar;
end;

procedure Sound(Hz: Word);
  procedure _Sound(Hz: Word);
  begin
    {$IFDEF Win32}
    asm
      mov  BX,Hz
      cmp  BX,0
      jz   @2
      mov  AX,$34DD
      mov  DX,$0012
      cmp  DX,BX
      jnb  @2
      div  BX
      mov  BX,AX
      { Sound is On ? }
      in   Al,$61
      test Al,$03
      jnz  @1
      { Set Sound On }
      or   Al,03
      out  $61,Al
      { Timer Command }
      mov  Al,$B6
      out  $43,Al
      { Set Frequency }
    @1: mov  Al,Bl
      out  $42,Al
      mov  Al,Bh
      out  $42,Al
    @2:
    end;
    {$ENDIF}
  end;
begin
  { SetSoundIOPermissionMap(LocalIOPermission_ON); }
  SoundFrequency := Hz;
  if IsWinNT then
    Windows.Beep(SoundFrequency, SoundDuration)
  else
    _Sound(Hz);
end;

procedure TextBackground(Color: Byte);
begin
  LastMode := TextAttr;
  TextAttr := (Color shl 4) or (TextAttr and $0F);
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
end;

procedure TextColor(Color: Byte);
begin
  LastMode := TextAttr;
  TextAttr := (Color and $0F) or (TextAttr and $F0);
  SetConsoleTextAttribute(hConsoleOutput, TextAttr);
end;

procedure TextMode(Mode: Integer);
begin
end;

function WhereX: Byte;
var
  CBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hConsoleOutput, CBI);
  Result := TCoord(CBI.dwCursorPosition).X + 1 - ConsoleScreenRect.Left;
end;

function WhereY: Byte;
var
  CBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(hConsoleOutput, CBI);
  try
    Result := TCoord(CBI.dwCursorPosition).Y + 1 - ConsoleScreenRect.Top;
  except
    on E: Exception do
      Result := 1;
  end;
end;

procedure Window(X1, Y1, X2, Y2: Byte);
begin
  ConsoleScreenRect.Left := X1 - 1;
  ConsoleScreenRect.Top := Y1 - 1;
  ConsoleScreenRect.Right := X2 - 1;
  ConsoleScreenRect.Bottom := Y2 - 1;
  WindMin := (ConsoleScreenRect.Top shl 8) or ConsoleScreenRect.Left;
  WindMax := (ConsoleScreenRect.Bottom shl 8) or ConsoleScreenRect.Right;
{$IFDEF WindowFrameToo}
  SetConsoleWindowInfo(hConsoleOutput, True, ConsoleScreenRect);
{$ENDIF}
  GotoXY(1, 1);
end;

{ --- Begin of New functions & procedures --- }

{ Fills the current window with special character }
procedure FillerScreen(FillChar: Char);
var
  Coord: TCoord;
  dwSize, dwCount: DWORD;
  Y: Integer;
begin
  Coord.X := ConsoleScreenRect.Left;
  dwSize := ConsoleScreenRect.Right - ConsoleScreenRect.Left + 1;
  for Y := ConsoleScreenRect.Top to ConsoleScreenRect.Bottom do
  begin
    Coord.Y := Y;
    FillConsoleOutputAttribute(hConsoleOutput, TextAttr, dwSize, Coord,
      dwCount);
    FillConsoleOutputCharacter(hConsoleOutput, FillChar, dwSize, Coord,
      dwCount);
  end;
  GotoXY(1, 1);
end;

{ Empty the buffer }
procedure FlushInputBuffer;
begin
  FlushConsoleInputBuffer(hConsoleInput);
end;

{ Get size of current cursor }
function GetCursor: Word;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(hConsoleOutput, CCI);
  GetCursor := CCI.dwSize;
end;

procedure MouseGotoXY(X, Y: Integer);
begin
{$IFDEF MOUSE_IS_USED}
  mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, X - 1, Y - 1,
    WHEEL_DELTA, GetMessageExtraInfo());
  MousePosY := (Y - 1) * MouseRowWidth;
  MousePosX := (X - 1) * MouseColWidth;
{$ENDIF}
end;

procedure MouseHideCursor;
const
  ShowMouseConsoleMode = ENABLE_MOUSE_INPUT;
var
  cMode: DWORD;
begin
  GetConsoleMode(hConsoleInput, cMode);
  if (cMode and ShowMouseConsoleMode) = ShowMouseConsoleMode then
  begin
    cMode := cMode and ($FFFFFFFF xor ShowMouseConsoleMode);
    SetConsoleMode(hConsoleInput, cMode);
  end;
end;

function MouseKeyPressed: Boolean;
{$IFDEF MOUSE_IS_USED}
const
  MouseDeltaTime = 200;
var
  ActualTime: TDateTime;
  HourA, HourM, MinA, MinM, SecA, SecM, MSecA, MSecM: Word;
  MSecTimeA, MSecTimeM: longInt;
  MSecDelta: longInt;
{$ENDIF}
begin
  MousePressedButtons := 0;
{$IFDEF MOUSE_IS_USED}
  Result := False;
  if MouseButtonPressed then
  begin
    ActualTime := Now;
    DecodeTime(ActualTime, HourA, MinA, SecA, MSecA);
    DecodeTime(MouseEventTime, HourM, MinM, SecM, MSecM);
    MSecTimeA := (3600 * HourA + 60 * MinA + SecA) * 100 + MSecA;
    MSecTimeM := (3600 * HourM + 60 * MinM + SecM) * 100 + MSecM;
    MSecDelta := Abs(MSecTimeM - MSecTimeA);
    if (MSecDelta < MouseDeltaTime) or (MSecDelta > (8784000 - MouseDeltaTime))
    then
    begin
      MousePressedButtons := MouseLeftButton;
      MouseButtonPressed := False;
      Result := True;
    end;
  end;
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure MouseShowCursor;
const
  ShowMouseConsoleMode = ENABLE_MOUSE_INPUT;
var
  cMode: DWORD;
begin
  GetConsoleMode(hConsoleInput, cMode);
  if (cMode and ShowMouseConsoleMode) <> ShowMouseConsoleMode then
  begin
    cMode := cMode or ShowMouseConsoleMode;
    SetConsoleMode(hConsoleInput, cMode);
  end;
end;

function MouseWhereX: Integer;
begin
{$IFDEF MOUSE_IS_USED}
  Result := (MousePosX div MouseColWidth) + 1;
{$ELSE}
  Result := -1;
{$ENDIF}
end;

function MouseWhereY: Integer;
begin
{$IFDEF MOUSE_IS_USED}
  Result := (MousePosY div MouseRowWidth) + 1;
{$ELSE}
  Result := -1;
{$ENDIF}
end;

function ScreenHeight: Integer;
begin
  Result := Hi(WindMax) - Hi(WindMin) + 1;
end;

function ScreenWidth: Integer;
begin
  Result := Lo(WindMax) - Hi(WindMin) + 1;
end;

{ Set size of current cursor }
procedure SetCursor(NewCursor: Word);
var
  CCI: TConsoleCursorInfo;
begin
  if NewCursor = $0000 then
  begin
    CCI.dwSize := GetCursor;
    CCI.bVisible := False;
  end
  else
  begin
    CCI.dwSize := NewCursor;
    CCI.bVisible := True;
  end;
  SetConsoleCursorInfo(hConsoleOutput, CCI);
end;

function WriteText(s: string; LineBreak: Boolean): UInt32;
var
  NumWritten: DWORD;
  Buf: String;
begin
  Buf := s;
  if LineBreak then
    Buf := Buf + sLineBreak;
  WriteConsole(GetStdHandle(STD_OUTPUT_HANDLE), PChar(Buf), Length(Buf), NumWritten,  nil);
  Result := NumWritten;
end;

function WriteLineText(s: string): UInt32;
begin
  result := WriteText(s, True);
end;

initialization

Init;

finalization

Done;
{$ENDIF MSWINDOWS}

end.
