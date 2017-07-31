unit uFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  uCEFChromium, uCefInterfaces, uCEFTypes, uCEFMiscFunctions, uCEFConstants,
  uCEFApplication,
  uAppConst, GR32_Image;

type
  TFrame2 = class(TFrame)
    Chromium1: TChromium;
    Panel1: TPanel;
    Button1: TButton;
    PaintBox: TPaintBox32;
    Timer1: TTimer;
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Chromium1CursorChange(Sender: TObject; const browser: ICefBrowser;
      cursor: HICON; cursorType: TCefCursorType;
      const customCursorInfo: PCefCursorInfo);
    procedure Chromium1GetScreenInfo(Sender: TObject;
      const browser: ICefBrowser; screenInfo: PCefScreenInfo; Result: Boolean);
    procedure Chromium1GetScreenPoint(Sender: TObject;
      const browser: ICefBrowser; viewX, viewY: Integer; screenX,
      screenY: PInteger; out Result: Boolean);
    procedure Chromium1GetViewRect(Sender: TObject; const browser: ICefBrowser;
      rect: PCefRect; out Result: Boolean);
    procedure Chromium1Paint(Sender: TObject; const browser: ICefBrowser;
      kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
      const dirtyRects: PCefRectArray; const buffer: Pointer; width,
      height: Integer);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure PaintBoxResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure Timer1Timer(Sender: TObject);
  private
    function getModifiers(Shift: TShiftState): TCefEventFlags;
    function GetButton(Button: TMouseButton): TCefMouseButtonType;

    procedure WmCreateBrowser(var AMessage: TMessage); message WM_CREATE_BROWSER;
    procedure WmCloseBrowser(var AMessage: TMessage); message WM_CLOSE_BROWSER;

    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;
    procedure WMCaptureChanged(var aMessage : TMessage); message WM_CAPTURECHANGED;
    procedure WMCancelMode(var aMessage : TMessage); message WM_CANCELMODE;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
  public
    procedure AfterConstruction; override;
  end;

implementation

{$R *.dfm}

{ TFrame2 }

procedure TFrame2.AfterConstruction;
begin
  inherited;
  //PostMessage(Handle, WM_CREATE_BROWSER, 0, 0);

end;

procedure TFrame2.Button1Click(Sender: TObject);
begin
  PostMessage(Handle, WM_CLOSE_BROWSER, 0, 0)
end;

procedure TFrame2.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  PostMessage(Application.MainFormHandle, WM_CLOSE_TAB, 0, 0)
end;

procedure TFrame2.Chromium1CursorChange(Sender: TObject;
  const browser: ICefBrowser; cursor: HICON; cursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin
  PaintBox.Cursor := GefCursorToWindowsCursor(cursorType);
end;

procedure TFrame2.Chromium1GetScreenInfo(Sender: TObject;
  const browser: ICefBrowser; screenInfo: PCefScreenInfo; Result: Boolean);
var
  TempRect : TCEFRect;
begin
  if (GlobalCEFApp <> nil) then
    begin
      TempRect.x      := 0;
      TempRect.y      := 0;
      TempRect.width  := DeviceToLogical(PaintBox.Width,  GlobalCEFApp.DeviceScaleFactor);
      TempRect.height := DeviceToLogical(PaintBox.Height, GlobalCEFApp.DeviceScaleFactor);

      screenInfo.device_scale_factor := GlobalCEFApp.DeviceScaleFactor;
      screenInfo.depth               := 0;
      screenInfo.depth_per_component := 0;
      screenInfo.is_monochrome       := Ord(False);
      screenInfo.rect                := TempRect;
      screenInfo.available_rect      := TempRect;

      Result := True;
    end
   else
    Result := False;
end;

procedure TFrame2.Chromium1GetScreenPoint(Sender: TObject;
  const browser: ICefBrowser; viewX, viewY: Integer; screenX, screenY: PInteger;
  out Result: Boolean);
var
  TempScreenPt, TempViewPt : TPoint;
begin
  if (GlobalCEFApp <> nil) then
    begin
      TempViewPt.x := LogicalToDevice(viewX, GlobalCEFApp.DeviceScaleFactor);
      TempViewPt.y := LogicalToDevice(viewY, GlobalCEFApp.DeviceScaleFactor);
      TempScreenPt := PaintBox.ClientToScreen(TempViewPt);
      screenX^     := TempScreenPt.x;
      screenY^     := TempScreenPt.y;
      Result       := True;
    end
   else
    Result := False;
end;

procedure TFrame2.Chromium1GetViewRect(Sender: TObject;
  const browser: ICefBrowser; rect: PCefRect; out Result: Boolean);
begin
  if (GlobalCEFApp <> nil) then
    begin
      rect.x      := 0;
      rect.y      := 0;
      rect.width  := DeviceToLogical(PaintBox.Width,  GlobalCEFApp.DeviceScaleFactor);
      rect.height := DeviceToLogical(PaintBox.Height, GlobalCEFApp.DeviceScaleFactor);
      Result      := True;
    end
   else
    Result := False;
end;

procedure TFrame2.Chromium1Paint(Sender: TObject; const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width,
  height: Integer);
var
  src, dst: PByte;
  offset, i, j, w: Integer;
begin
  if (Self.Parent as TTabSheet).PageControl.ActivePageIndex <>
  (Self.Parent as TTabSheet).TabIndex then
    Exit;
  
  if (width <> PaintBox.Width) or (height <> PaintBox.Height) then Exit;

  // ====================
  // === WARNING !!!! ===
  // ====================
  // This is a simple and basic function that copies the buffer passed from
  // CEF into the PaintBox canvas. If you have a high DPI monitor you may
  // have rounding problems resulting in a black screen.
  // CEF and this demo use a device_scale_factor to calculate screen logical
  // and real sizes. If there's a rounding error CEF and this demo will have
  // slightly different sizes and this function will exit.
  // If you need to support high DPI, you'll have to use a better function
  // to copy the buffer.

  with PaintBox.Buffer do
    begin
      PaintBox.Canvas.Lock;
      Lock;
      try
        for j := 0 to dirtyRectsCount - 1 do
        begin
          w := Width * 4;
          offset := ((dirtyRects[j].y * Width) + dirtyRects[j].x) * 4;
          src := @PByte(buffer)[offset];
          dst := @PByte(Bits)[offset];
          offset := dirtyRects[j].width * 4;
          for i := 0 to dirtyRects[j].height - 1 do
          begin
            Move(src^, dst^, offset);
            Inc(dst, w);
            Inc(src, w);
          end;
          PaintBox.Flush(Rect(dirtyRects[j].x, dirtyRects[j].y,
            dirtyRects[j].x + dirtyRects[j].width,  dirtyRects[j].y + dirtyRects[j].height));
        end;
      finally
        Unlock;
        PaintBox.Canvas.Unlock;
      end;
    end;
end;

procedure TFrame2.CMShowingChanged(var M: TMessage);
begin
  inherited;
  //PostMessage(Handle, WM_CREATE_BROWSER, 0, 0);
end;

function TFrame2.GetButton(Button: TMouseButton): TCefMouseButtonType;
begin
  case Button of
    TMouseButton.mbRight  : Result := MBT_RIGHT;
    TMouseButton.mbMiddle : Result := MBT_MIDDLE;
    else                    Result := MBT_LEFT;
  end;
end;

function TFrame2.getModifiers(Shift: TShiftState): TCefEventFlags;
begin
  Result := EVENTFLAG_NONE;

  if (ssShift  in Shift) then Result := Result or EVENTFLAG_SHIFT_DOWN;
  if (ssAlt    in Shift) then Result := Result or EVENTFLAG_ALT_DOWN;
  if (ssCtrl   in Shift) then Result := Result or EVENTFLAG_CONTROL_DOWN;
  if (ssLeft   in Shift) then Result := Result or EVENTFLAG_LEFT_MOUSE_BUTTON;
  if (ssRight  in Shift) then Result := Result or EVENTFLAG_RIGHT_MOUSE_BUTTON;
  if (ssMiddle in Shift) then Result := Result or EVENTFLAG_MIDDLE_MOUSE_BUTTON;
end;

procedure TFrame2.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  event: TCefMouseEvent;
begin
  event.x := X;
  event.y := Y;
  event.modifiers := getModifiers(Shift);
  Chromium1.SendMouseClickEvent(@event, GetButton(Button), False, 1);
end;

procedure TFrame2.PaintBoxMouseLeave(Sender: TObject);
var
  TempEvent : TCefMouseEvent;
  TempPoint : TPoint;
begin
  if (GlobalCEFApp <> nil) then
    begin
      GetCursorPos(TempPoint);
      TempPoint           := PaintBox.ScreenToclient(TempPoint);
      TempEvent.x         := TempPoint.x;
      TempEvent.y         := TempPoint.y;
      TempEvent.modifiers := GetCefMouseModifiers;
      DeviceToLogical(TempEvent, GlobalCEFApp.DeviceScaleFactor);
      Chromium1.SendMouseMoveEvent(@TempEvent, not PaintBox.MouseInControl);
    end;
end;

procedure TFrame2.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  TempEvent : TCefMouseEvent;
begin
  if (GlobalCEFApp <> nil) then
    begin
      TempEvent.x         := X;
      TempEvent.y         := Y;
      TempEvent.modifiers := getModifiers(Shift);
      DeviceToLogical(TempEvent, GlobalCEFApp.DeviceScaleFactor);
      Chromium1.SendMouseMoveEvent(@TempEvent, not PaintBox.MouseInControl);
    end;
end;

procedure TFrame2.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TempEvent : TCefMouseEvent;
begin
  if (GlobalCEFApp <> nil) then
    begin
      TempEvent.x         := X;
      TempEvent.y         := Y;
      TempEvent.modifiers := getModifiers(Shift);
      DeviceToLogical(TempEvent, GlobalCEFApp.DeviceScaleFactor);
      Chromium1.SendMouseClickEvent(@TempEvent, GetButton(Button), True, 1);
    end;
end;

procedure TFrame2.PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  TempEvent : TCefMouseEvent;
begin
  if (GlobalCEFApp <> nil) then
    begin
      TempEvent.x         := MousePos.X;
      TempEvent.y         := MousePos.Y;
      TempEvent.modifiers := getModifiers(Shift);
      DeviceToLogical(TempEvent, GlobalCEFApp.DeviceScaleFactor);
      Chromium1.SendMouseWheelEvent(@TempEvent, 0, WheelDelta);
    end;
end;

procedure TFrame2.PaintBoxResize(Sender: TObject);
begin
  PaintBox.Buffer.SetSize(PaintBox.Width, PaintBox.Height);
  Chromium1.WasResized;
end;

procedure TFrame2.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Timer1.OnTimer := nil;
  PostMessage(Handle, WM_CREATE_BROWSER, 0, 0);
end;

procedure TFrame2.WMCancelMode(var aMessage: TMessage);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.SendCaptureLostEvent;
end;

procedure TFrame2.WMCaptureChanged(var aMessage: TMessage);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.SendCaptureLostEvent;
end;

procedure TFrame2.WmCloseBrowser(var AMessage: TMessage);
begin
  Chromium1.CloseBrowser(True);
end;

procedure TFrame2.WmCreateBrowser(var AMessage: TMessage);
begin
  Chromium1.DefaultUrl := 'https://inet.ya.ru';
  Chromium1.CreateBrowser()
end;

procedure TFrame2.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TFrame2.WMMoving(var aMessage: TMessage);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

end.
