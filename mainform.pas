unit MainForm;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Math;

type
  {Struttura che rappresenta un nodo dell'albero BSP}
  PBSPNode = ^TBSPNode;

  TBSPNode = record
    X, Y, W, H: Integer;    //Posizione e dimensioni dell'area
    RoomX, RoomY, RoomW, RoomH: Integer;   //Posizione e dimensioni della stanza
    Left, Right: PBSPNode;   //Figli generati dalla divisione
  end;

  {TForm1}
  TForm1 = class(TForm)
    btnGenerate: TButton;
    PaintBox1: TPaintBox;
    procedure btnGenerateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    FRoot: PBSPNode;
    const MIN_SIZE = 60;   // Dimensione minima sotto la quale non si divide più
    function CreateNode(AX, AY, AW, AH: Integer): PBSPNode;
    procedure SplitNode(ANode: PBSPNode; Depth: Integer);
    procedure CreateRooms(ANode: PBSPNode);
    procedure DrawDungeon(ACanvas: TCanvas; ANode: PBSPNode);
    procedure FreeTree(ANode: PBSPNode);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
function TForm1.CreateNode(AX, AY, AW, AH: Integer): PBSPNode;
begin
  New(Result);
  Result^.X := AX;
  Result^.Y := AY;
  Result^.W := AW;
  Result^.H := AH;
  Result^.RoomW := 0; // 0 significa nessuna stanza ancora creata
  Result^.Left := nil;
  Result^.Right := nil;
end;

procedure TForm1.SplitNode(ANode: PBSPNode; Depth: Integer);
var
  SplitHorizontal: Boolean;
  SplitPos: Integer;
begin
  // Ferma la divisione se si è raggiunta una profondità eccessiva (es. 4 o 5 livelli)
  if Depth > 4 then Exit;

  // Decide la direzione del taglio in base alle proporzioni o casualmente
  if (ANode^.W > ANode^.H) and (ANode^.W / ANode^.H >= 1.25) then
    SplitHorizontal := False
  else if (ANode^.H > ANode^.W) and (ANode^.H / ANode^.W >= 1.25) then
    SplitHorizontal := True
  else
    SplitHorizontal := Random(2) = 0;

  // Verifica se l'area è abbastanza grande per essere divisa
  if SplitHorizontal then
  begin
    if ANode^.H < (MIN_SIZE * 2) then Exit;
    // Calcola una posizione di taglio valida
    SplitPos := RandomRange(MIN_SIZE, ANode^.H - MIN_SIZE);
    ANode^.Left := CreateNode(ANode^.X, ANode^.Y, ANode^.W, SplitPos);
    ANode^.Right := CreateNode(ANode^.X, ANode^.Y + SplitPos, ANode^.W, ANode^.H - SplitPos);
  end
  else
  begin
    if ANode^.W < (MIN_SIZE * 2) then Exit;
    SplitPos := RandomRange(MIN_SIZE, ANode^.W - MIN_SIZE);
    ANode^.Left := CreateNode(ANode^.X, ANode^.Y, SplitPos, ANode^.H);
    ANode^.Right := CreateNode(ANode^.X + SplitPos, ANode^.Y, ANode^.W - SplitPos, ANode^.H);
  end;

  // Continua la divisione ricorsiva sui figli
  SplitNode(ANode^.Left, Depth + 1);
  SplitNode(ANode^.Right, Depth + 1);
end;

procedure TForm1.CreateRooms(ANode: PBSPNode);
begin
  if ANode = nil then Exit;

  // Se è un nodo foglia (non ha figli), crea la stanza
  if (ANode^.Left = nil) and (ANode^.Right = nil) then
  begin
    // La stanza sarà leggermente più piccola del contenitore (margine di almeno 5 pixel)
    ANode^.RoomW := RandomRange(MIN_SIZE - 20, ANode^.W - 10);
    ANode^.RoomH := RandomRange(MIN_SIZE - 20, ANode^.H - 10);
    ANode^.RoomX := ANode^.X + RandomRange(5, ANode^.W - ANode^.RoomW - 5);
    ANode^.RoomY := ANode^.Y + RandomRange(5, ANode^.H - ANode^.RoomH - 5);
  end
  else
  begin
    // Altrimenti scendi ricorsivamente
    CreateRooms(ANode^.Left);
    CreateRooms(ANode^.Right);
  end;
end;

procedure TForm1.DrawDungeon(ACanvas: TCanvas; ANode: PBSPNode);
var
  CenterX1, CenterY1, CenterX2, CenterY2: Integer;
begin
  if ANode = nil then Exit;

  // Se è una foglia ed ha una stanza, la disegna
  if (ANode^.Left = nil) and (ANode^.Right = nil) then
  begin
    if ANode^.RoomW > 0 then
    begin
      ACanvas.Brush.Color := clDkGray;
      ACanvas.Pen.Color := clWhite;
      ACanvas.Rectangle(ANode^.RoomX, ANode^.RoomY, ANode^.RoomX + ANode^.RoomW, ANode^.RoomY + ANode^.RoomH);
    end;
  end;

  // Disegna i figli e traccia i corridoi tra di loro
  if (ANode^.Left <> nil) and (ANode^.Right <> nil) then
  begin
    DrawDungeon(ACanvas, ANode^.Left);
    DrawDungeon(ACanvas, ANode^.Right);

    // Trova i centri dei due nodi figli per collegarli
    CenterX1 := ANode^.Left^.X + (ANode^.Left^.W div 2);
    CenterY1 := ANode^.Left^.Y + (ANode^.Left^.H div 2);
    CenterX2 := ANode^.Right^.X + (ANode^.Right^.W div 2);
    CenterY2 := ANode^.Right^.Y + (ANode^.Right^.H div 2);

    // Disegna il corridoio (linea spessa per simulare il passaggio)
    ACanvas.Pen.Color := clDkGray;
    ACanvas.Pen.Width := 4;
    ACanvas.MoveTo(CenterX1, CenterY1);
    ACanvas.LineTo(CenterX2, CenterY2);
    ACanvas.Pen.Width := 1; // Ripristina lo spessore
  end;
end;

procedure TForm1.BtnGenerateClick(Sender: TObject);
begin
  Randomize;

  // Pulisce l'albero precedente se esistente
  if FRoot <> nil then
    FreeTree(FRoot);

  // Inizializza il rettangolo radice basandosi sulle dimensioni del PaintBox
  FRoot := CreateNode(10, 10, PaintBox1.Width - 20, PaintBox1.Height - 20);

  // Avvia l'algoritmo
  SplitNode(FRoot, 0);
  CreateRooms(FRoot);

  // Forza il PaintBox a ridisegnarsi
  PaintBox1.Invalidate;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  // Sfondo nero per il dungeon
  PaintBox1.Canvas.Brush.Color := clBlack;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width, PaintBox1.Height);

  if FRoot <> nil then
    DrawDungeon(PaintBox1.Canvas, FRoot);
end;

procedure TForm1.FreeTree(ANode: PBSPNode);
begin
  if ANode = nil then Exit;
  FreeTree(ANode^.Left);
  FreeTree(ANode^.Right);
  Dispose(ANode);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if FRoot <> nil then
    FreeTree(FRoot);
end;

end.

