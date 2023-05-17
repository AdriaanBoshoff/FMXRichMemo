unit Unit5;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.TextLayout,
  ChatGPT.Code, FMX.Effects, FMX.Filter.Effects;

type
  TForm5 = class(TForm)
    Memo1: TMemo;
    StyleBook: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure Memo1ChangeTracking(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Memo1ApplyStyleLookup(Sender: TObject);
  private
    FCodeSyntax: TCodeSyntax;
    FMemoMarginsLeft: Single;
    procedure UpdateLayout(Sender: TObject; Layout: TTextLayout; const Index: Integer);
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses
  FMX.Memo.Style, ChatGPT.Code.Pascal, System.Math, FMX.BehaviorManager;

{$R *.fmx}

{ TForm5 }

procedure TForm5.FormCreate(Sender: TObject);
begin
  FCodeSyntax := TCodeSyntaxPascal.Create(Memo1.TextSettings.Font, Memo1.TextSettings.FontColor);
  Memo1.ScrollAnimation := TBehaviorBoolean.True;
  (Memo1.Presentation as TStyledMemo).OnUpdateLayoutParams := UpdateLayout;
end;

procedure TForm5.FormDestroy(Sender: TObject);
begin
  FCodeSyntax.Free;
end;

procedure TForm5.Memo1ApplyStyleLookup(Sender: TObject);
begin
  Memo1ChangeTracking(nil);
end;

procedure TForm5.Memo1ChangeTracking(Sender: TObject);
begin
  var Memo :=(Memo1.Presentation as TStyledMemo);
  Memo1.Canvas.Font.Assign(Memo1.TextSettings.Font);
  var W := Ceil(Memo1.Canvas.TextWidth(Memo1.Lines.Count.ToString) + 20);
  Memo1.StylesData['content_client.Padding.Left'] := W;
  FMemoMarginsLeft := W;
  Memo.UpdateVisibleLayoutParams;
  Memo.RealignContent;
end;

procedure TForm5.Memo1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  // Line number
  var BRect := Memo1.BoundsRect;
  var Memo :=(Memo1.Presentation as TStyledMemo);
  for var i := 0 to Memo.LineObjects.Count - 1 do
    if Memo.LineObjects.Items[i].SizeValid then
    begin
      var Rect := Memo.LineObjects.Items[i].Rect;
      Rect.Left := 0;
      Rect.Width := FMemoMarginsLeft - 10;
      if Rect.Top < BRect.Height then
        Rect.Bottom := Min(Rect.Bottom, Memo.Content.Height);
      Rect.Offset(2, 0);
      Rect.NormalizeRect;
      if (Rect.Top < 0) and (Rect.Bottom < 0) then
        Continue;
      if (Rect.Top > BRect.Height) and (Rect.Bottom > BRect.Height) then
        Continue;
      Canvas.Fill.Color := TAlphaColorRec.White;
      Canvas.Font.Assign(Memo1.TextSettings.Font);
      var HDelta: Single :=(100 / Memo.LineObjects.Items[i].Rect.Height * Rect.Height) / 100;
      if i = Memo.CaretPosition.Line then
      begin
        Canvas.FillRect(Rect, 0.1);
        HDelta := 300;
      end;
      Canvas.FillText(Rect, (i + 1).ToString, False, 0.3 * HDelta, [], TTextAlign.Trailing, TTextAlign.Leading);
    end;
end;

procedure TForm5.UpdateLayout(Sender: TObject; Layout: TTextLayout; const Index: Integer);
begin
  // set attributes
  if not Assigned(Layout) then
    Exit;
  Layout.ClearAttributes;
  Layout.Padding.Top := 0;
  Layout.Padding.Bottom := 0;
  if Assigned(FCodeSyntax) then
  try
    for var Attr in FCodeSyntax.GetAttributesForLine(Memo1.Lines[Index]) do
      Layout.AddAttribute(Attr.Range, Attr.Attribute);
  except
    //
  end;
end;

end.

