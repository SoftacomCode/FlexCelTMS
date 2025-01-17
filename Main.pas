unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FlexCel.Core, FlexCel.XlsAdapter, FMX.Controls.Presentation, FlexCel.FMXSupport,
  FMX.StdCtrls,FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FlexCel.Render,
  FMXTee.Series, Math, System.IOUtils, ShellAPI;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Chart: TChart;
    ToolBar1: TToolBar;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FChartPicturePath: string;
    FFlexCelPath: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.Button1Click(Sender: TObject);
var
  Xls: TXlsFile;
  ImProps: IImageProperties;
  Stream: TFileStream;
  Img: TUIImage;
  Sl: TLineSeries;
  X, Y, XStart, XFinish, Step: Double;
  I: Integer;
  EChart : IExcelChart;
  ChartOptions1: IShapeProperties;
  Series: IChartSeries;
begin
  Xls := TXlsFile.Create(FFlexCelPath, True);
  try
    Sl := TLineSeries.Create(Chart);
    Sl.SeriesColor := TAlphaColors.Red;
    Sl.Pen.Width := 4;
    I := 1;
    XStart := 0;
    XFinish := 2 * PI;
    Step := 0.01;
    X := XStart;
    while X < XFinish do
    begin
      Y := Sin(X);
      Sl.AddXY(X, Y, '', TAlphaColors.Blue);
      Xls.SetCellValue(I, 1, X);
      Xls.SetCellValue(I, 2, Y);
      X := X + Step;
      Inc(I);
    end;
    Chart.AddSeries(Sl);
    Chart.SaveToBitmapFile(FChartPicturePath);
    Stream := nil;
    Img := nil;
    try
      Stream := TFileStream.Create(FChartPicturePath, fmOpenRead or fmShareDenyNone);
      Img := TUIImage.FromStream(Stream);
      ImProps := TImageProperties_Create();
      ImProps.Anchor := TClientAnchor.Create(TFlxAnchorType.MoveAndDontResize,
        4, 0, 4, 0, Trunc(Img.Height), Trunc(Img.Width), Xls);
      ImProps.ShapeName := 'Picture 1';
      Stream.Position := 0;
      Xls.AddImage(Stream, ImProps);
      Xls.Save(FFlexCelPath);
    finally
      Img.Free;
      Stream.Free;
      DeleteFile(FChartPicturePath);
    end;
  finally
    Xls.Free;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Chart.Legend.Visible := False;
  Chart.View3D := False;
  Chart.Title.Text.Clear;
  Chart.Title.Text.Add('SIN');
  FChartPicturePath := TPath.Combine(TPath.GetDocumentsPath, 'chart.bmp');
  FFlexCelPath := TPath.Combine(TPath.GetDocumentsPath, 'MyFlexCelSample.xls');
end;

end.
