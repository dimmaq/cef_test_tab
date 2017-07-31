unit uForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, uAppConst, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure WmNewTab(var AMessage: TMessage); message WM_NEW_TAB;
    procedure WmCloseTab(var AMessage: TMessage); message WM_CLOSE_TAB;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


uses uFrame;

procedure TForm1.Button1Click(Sender: TObject);
begin
  PostMessage(Handle, WM_NEW_TAB, 0, 0)
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PostMessage(Handle, WM_NEW_TAB, 0, 0)
end;

procedure TForm1.WmCloseTab(var AMessage: TMessage);
begin
  PageControl1.ActivePage.Controls[0].Free;
end;

procedure TForm1.WmNewTab(var AMessage: TMessage);
var
  tab: TTabSheet;
  frame: TFrame2;
begin
  tab := TTabSheet.Create(PageControl1);
  tab.PageControl := PageControl1;
  tab.TabVisible := True;
  tab.Caption := 'tab' + tab.TabIndex.ToString;

  frame := TFrame2.Create(tab);
  frame.Parent := tab;

end;

end.
