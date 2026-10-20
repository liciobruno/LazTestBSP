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
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

