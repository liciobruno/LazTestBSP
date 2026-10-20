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
    procedure SplitNode(ANode: PBSPNode, Depth: Integer);
    procedure CreateRooms(ANode: PBSPNode);
    procedure DrawDungeon(ACanvas: TCanvas; ANode: PBSPNode);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnGenerateClick(Sender: TObject);
begin

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin

end;

end.

