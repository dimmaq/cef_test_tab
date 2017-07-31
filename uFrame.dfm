object Frame2: TFrame2
  Left = 0
  Top = 0
  Width = 451
  Height = 305
  Align = alClient
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 81
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 24
      Top = 29
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object PaintBox: TPaintBox32
    Left = 0
    Top = 81
    Width = 451
    Height = 224
    Align = alClient
    TabOrder = 1
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnMouseUp = PaintBoxMouseUp
    OnMouseWheel = PaintBoxMouseWheel
    OnMouseLeave = PaintBoxMouseLeave
    OnResize = PaintBoxResize
    ExplicitLeft = 192
    ExplicitTop = 152
    ExplicitWidth = 192
    ExplicitHeight = 192
  end
  object Chromium1: TChromium
    OnBeforeClose = Chromium1BeforeClose
    OnGetViewRect = Chromium1GetViewRect
    OnGetScreenPoint = Chromium1GetScreenPoint
    OnGetScreenInfo = Chromium1GetScreenInfo
    OnPaint = Chromium1Paint
    OnCursorChange = Chromium1CursorChange
    Left = 408
    Top = 136
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 344
    Top = 184
  end
end
