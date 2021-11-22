unit Test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Menus, Process, LCLIntf, BlowFish;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    MenuItem10: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    QTimer: TLabel;
    QNum: TLabel;
    Progress: TLabel;
    ProgressBar: TProgressBar;
    ScoreBoard: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    NextQ: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    OpenDialog1: TOpenDialog;
    Question: TLabel;
    Title: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure NextQClick();
    procedure TimerLoop();
  private

  public

  end;

var
  Form1: TForm1;
  i: byte=0;

  f:TextFile;
  fName:string[80];
  N:byte=0;{Кількість питань}
  A:array[1..10,1..7] of string;
  B:array[1..10,1..5] of string;
  P:array of string;
  q:byte=1;
  score:byte=0;
  Pic:array[1..10] of string;
  Wc:array[1..10] of string;
  W:array[1..10] of byte;
  Quest:array of byte;
  s:real;

  en: TBlowFishEncryptStream;
  de: TBlowFishDeCryptStream;
  s1,s2: TStringStream;
  key: String;

implementation

{$R *.lfm}

{ TForm1 }

procedure ShuffleArray(var List:array of string);
var Iter,rr: integer; tmp: string;
  begin
      Randomize;
      for Iter := 0 to high(List)-1 do
        begin
          rr := random(high(List)-1)+1;
          tmp := List[Iter];
          List[Iter] := List[rr];
          List[rr] := tmp;
        end;
  end;

procedure ShuffleArrayByte(var List:array of byte);
var Iter,rr: integer; tmp: byte;
  begin
      Randomize;
      for Iter := 0 to high(List)-1 do
        begin
          rr := random(high(List)-1)+1;
          tmp := List[Iter];
          List[Iter] := List[rr];
          List[rr] := tmp;
        end;
  end;

function IsInArray(const Answer: string;
  const AArray: array of string): Boolean;
var
  i: Integer;
begin
     isInArray:=false;
     for i := 0 to high(AArray) do begin
         if Answer = AArray[i] then begin IsInArray:=true; break; end;
     end;
end;

procedure TForm1.TimerLoop();
begin
     s:=200; {20 seconds}
     QTimer.Caption:=Concat('Time left: ',floattostr(s/10));
     Application.Processmessages;
     while s>1 do begin
         sleep(100);
         s:=s-1;
         QTimer.Caption:=Concat('Time left: ',floattostr(s/10));
         Application.Processmessages;
     end;
     NextQClick();
     s:=200;
     TimerLoop();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.MenuItem10Click(Sender: TObject);
var enc,temp:string; encout:textFile;
begin
     if  openDialog1.Execute then
    begin
     fName:=OpenDialog1.FileName;
     assignFile(f,fName);
     reset(f);
    end
   else exit;
   InputQuery('Encryption', 'Enter encryption key', key);
   enc:='';
    while not eof(f) do
    Begin
        readln(f,temp);
        enc:=enc+temp+#13#10;
    end;

  s1 := TStringStream.Create('');
  en := TBlowFishEncryptStream.Create(key,s1);
  en.WriteAnsiString(enc);
  en.Free;
  AssignFile(encout,Concat(fName,'_encrypted.testdata'));
  Rewrite(encout);
  write(encout, s1.DataString);
  CloseFile(encout);
  ShowMessage('Successfully encrypted!');
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var i,j:byte; sep,temp:string; strm: TFileStream;k: longint;txt: string;

begin
     i:=0;
   if  openDialog1.Execute then
    begin
     fName:=OpenDialog1.FileName;
     assignFile(f,fName);
     reset(f);
    end
   else exit;
   InputQuery('Decryption', 'Enter decryption key', key);

   txt := '';
  strm := TFileStream.Create(fName, fmOpenRead or fmShareDenyWrite);
  try
    k := strm.Size;
    SetLength(txt, k);
    strm.Read(txt[1], k);
  finally
    strm.Free;
  end;
  s2 := TStringStream.Create(txt);
  de := TBlowFishDeCryptStream.Create(key,s2);
  temp := de.ReadAnsiString;
  assignFile(f,'temp');
  rewrite(f);
  write(f,temp);
  closefile(f);
  assignFile(f,'temp');
  reset(f);
   while not eof(f) do
   Begin
     inc(i);
     readln(f,A[i,1]); {Question}
     readln(f,Pic[i]);
     readln(f,Wc[i]);
     W[i]:=strtoint(Wc[i]);

      for j:=2 to W[i]+2 do readln(f,A[i,j]); {Answers}
      for j:=1 to strtoint(A[i,W[i]+2]) do readln(f,B[i,j]); {Corrects}
     readln(f,sep) {Separator}
   end;
   N:=i;
   setLength(Quest,N);
   for i:=0 to N-1 do Quest[i]:=i+1;
   ShuffleArrayByte(Quest);
   ProgressBar.Max:=N;
   Progress.Caption:=Concat('1/',inttostr(N));

   setLength(P, W[Quest[0]]+1);
   for j:=2 to W[Quest[0]]+1 do P[j-2]:=A[Quest[0],j];
   ShuffleArray(P);

   QNum.Caption:=Concat('Question #',inttostr(Quest[0]));
   Question.Caption:=A[Quest[0],1];
   CheckBox1.Caption:=P[0];
   if W[Quest[0]]>1 then CheckBox2.Caption:=P[1];
   if W[Quest[0]]>2 then CheckBox3.Caption:=P[2];
   if W[Quest[0]]>3 then CheckBox4.Caption:=P[3];
   if W[Quest[0]]>4 then CheckBox5.Caption:=P[4];

   Image1.Visible:=True;
   Form1.Image1.Stretch:=True;
   Form1.Image1.Picture.Bitmap.LoadFromFile(GetCurrentDir+'\images\'+Pic[Quest[0]]);

   NextQ.Enabled:=true;

   TimerLoop();
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
var aProcess : TProcess;
begin
  aProcess := TProcess.Create(nil);
  aProcess.CommandLine := Application.ExeName;
  aProcess.Execute;
  aProcess.Free;
  Halt;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  Halt;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  OpenDocument('README.MD');
end;
procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  OpenDocument('README.txt');
end;

procedure TForm1.NextQClick();
var i:byte; Ans:array of string = ();sum:longint=0;
begin
   setLength(Ans, 10);
   for i:=0 to strtoint(A[Quest[q-1],W[Quest[q-1]]+2]) do Ans[i]:=B[Quest[q-1],i+1];
   ShowMessage(Concat('The correct answer is ',B[Quest[q-1],1],' ',B[Quest[q-1],2],' ',B[Quest[q-1],3]));
    if CheckBox1.Checked and (IsInArray(CheckBox1.Caption,Ans)) then inc(score);
    if CheckBox2.Checked and (IsInArray(CheckBox2.Caption,Ans)) then inc(score);
    if CheckBox3.Checked and (IsInArray(CheckBox3.Caption,Ans)) then inc(score);
    if CheckBox4.Checked and (IsInArray(CheckBox4.Caption,Ans)) then inc(score);
    if CheckBox5.Checked and (IsInArray(CheckBox5.Caption,Ans)) then inc(score);

    ScoreBoard.Caption:=Concat('Score:',inttostr(score));
    if q<N then begin
        inc(q);
        ProgressBar.Position:=q;
        Progress.Caption:=Concat(inttostr(q),'/',inttostr(N));

         setLength(P, W[Quest[q-1]]+1);
         for i:=2 to W[Quest[q-1]]+1 do P[i-2]:=A[Quest[q-1],i];
         ShuffleArray(P);

         Question.Caption:=A[Quest[q-1],1];

         CheckBox1.Caption:='';
         CheckBox2.Caption:='';
         CheckBox3.Caption:='';
         CheckBox4.Caption:='';
         CheckBox5.Caption:='';

         QNum.Caption:=Concat('Question #',inttostr(Quest[q-1]));
         CheckBox1.Caption:=P[0];
         if W[Quest[q-1]]>1 then CheckBox2.Caption:=P[1];
         if W[Quest[q-1]]>2 then CheckBox3.Caption:=P[2];
         if W[Quest[q-1]]>3 then CheckBox4.Caption:=P[3];
         if W[Quest[q-1]]>4 then CheckBox5.Caption:=P[4];

         Image1.Visible:=True;
         Form1.Image1.Stretch:=True;
         Form1.Image1.Picture.Bitmap.LoadFromFile(GetCurrentDir+'\images\'+Pic[Quest[q-1]]);

         s:=200;
    end
    else begin
        NextQ.Enabled:=false;
        MenuItem4.Enabled:=true;
        MenuItem5.Enabled:=true;
        for i:=0 to N-1 do sum:=sum+strtoint(A[Quest[i],W[Quest[i]]+2]);
        ShowMessage(Concat('Your Score is: ',inttostr(score),' out of ',inttostr(sum)));
        CloseFile(f);
        DeleteFile('temp.txt');
    end;
end;

end.

