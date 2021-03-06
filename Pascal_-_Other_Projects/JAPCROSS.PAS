{$N+}
program JaponaCrosswords;
uses
  crt;
const
  MAX = 100;{������������ ������ �� ��������� ��� �����������}
  COLVO = 15;{���������, ��� ������� �� ������������ ����� ��������� � ������ ��� �������}
  UNREAL = 254;{���������, ����������� �� ������, ������� �� ����� ���� ���������}
  THINK  = 255;{���������, ����������� �� ������������ ������}
var
  SetkaH,SetkaV   :array[0..MAX,0..MAX] of Byte;
  {SetkaH - ����� �����, SetkaV - ����� ��������}
  Matrix          :array[0..MAX,0..MAX] of Char;
  {�������, ������� �������� �������� ���������}
  Hor,Vert        :array[0..MAX,0..COLVO] of Integer;
  {�������� ������������ � ����������}
  HorR, VertR     :Byte;{������ ���������� �� ����������� � ���������}
  St1,St2,St3,St4 :array[0..MAX] of Integer;
  {����� ����������, �������� � ������ ������}

procedure Error(number :Byte); {����� ��������� �� �������}
begin
  case number of
    0 :
    begin
      WriteLn('I''m sorry. You have to many horizontales');
      Halt;
    end;
    1 :
    begin
      WriteLn('I''m sorry. You have to many downs');
      Halt;
    end;
  end;
end;

procedure Load; {�������� ����������}
var
  in_file     :Text;
  Porciya     :Integer;
  i,j         :Integer;
  path        :String[255];{���� � ����� � �����������}
begin
  Write('Please, enter path for file with crosswords: ');
  ReadLn(Path);{������ ����}
  Assign(in_file,path);
  ReadLn(in_file,HorR);{��������� ������ �� �����������}
  if (HorR > MAX) or (HorR < 0) then Error(0);{���������}
  ReadLn(in_file,VertR);{��������� ������ �� ���������}
  if (VertR > MAX) or (VertR < 0) then Error(1);{���������}
  for i := 0 to HorR do {��������� ������ � ��������� �� �����}
  begin
    j := 0;
    do
    begin
      Hor[i,j] := Porciya;
      Read(in_file,Porciya);
      j := j + 1;
    While(Porciya <> 0);
    ReadLn(in_file,Porciya);
  end;
  for i := 0 to VertR do {��������� ������� � ��������� �� �����}
  begin
    j := 0;
    do
    begin
      Vert[i,j] := Porciya;
      Read(in_file,Porciya);
      j := j + 1;
    While(Porciya <> 0);
    ReadLn(in_file,Porciya);
  end;
end;

procedure Save;{���������� ������� �������}
var
  out_file :Text;
  i,j      :Integer;
  path     :String[255];
begin
  Write('Please, enter path for saving file: ');
  ReadLn(Path);
  Assign(out_file,path);
  for i := 0 to VertR do {����������� ����������� � ������� ���������}
  begin
    for j := 0 to HorR do
    begin
      Write(out_file,Matrix[i,j]);
      WriteLn(out_file);
    end;
  end;
end;

function Analise(): Byte;
{��� ������� ����������� ������� ��������� ��� �����������}
{� ������ ������� ��������� ������, ������������ ��� ���������}
{�����}
var
  Lenght :Byte;
  i      :Byte;
begin
  if HOV then Length := HorR; else Length := VertR;
  for i := 0 to Lenght do
  begin

  end;
end:

procedure LoadMatrix(HOV :Boolean);
{������������� ��������� ���������� ������������ ��� ���������� �������}
var
  i,j,k,l,p,s,tempsc,tempsc1,temp0,temp1 :Integer;
  problema                               :Boolean;
begin
  if HOV then{���� ��������� ���������, �� temp0 ����� ����� ������������, � temp1 - ������������}
  begin
    temp0 := HorR;
    temp1 := VertR;
  end
  else{����� - ��������}
  begin
    temp0 := VertR;
    temp1 := HorR;
  end;
  for i := 0 to temp0 do{���� ���������� ���������� �� ������� ���������}
  begin
    if HOV then j := Hor[i,0] else j := Vert[i,0];{���� ��������� ���������,}
                                                  {�� j - ����� ���������� �}
                                                  {������ ���������,}
                                                  {����� - � ������ �����������}
    if j = 0 then
    begin
      for k := 0 to temp1 do{��������� �������� ���������� ����������� UNREAL}
      begin
         if HOV then SetkaH[i,k] := UNREAL; else SetkaV[i,k] := UNREAL;
      end;
      continue;{��������� � ��������� ����������� (���������)}
    end;
    for k := 0 to temp1 do
    begin
      if HOV then St3[k] := SetkaH[i,k] else St3[k] := SetkaV[i,k];
    end;
    p := 0;
    for k := 1 to j do{���� ���������� St1 �� ������ �� �����}
    begin
      if HOV then l := Hor[i,k] else l := Vert[i,k];
      tempsc := 1;
      for s := p to l do{�������� �� ��������� ������}
      begin
        if St3[p] <> UNREAL then Inc(tempsc)
        else Break;
      end;
      if tempsc < l then{����� ����� �� �������}
                        {������� � �������� ��������� �����}
      begin
        p := p + tempsc;
        k := k - 1;
        Continue;
      end;
      for s := p to l do{��������� �����}
      begin
        St1[p] := k;
        p := p + 1;
      end;
      p := p + 1;
    end;{����� ���� ���������� St1 �� ������ �� �����}
    if HOV then p := HorR else p := VertR;
    for k := j downto 1 do{���� ���������� St2 �� ����� �� ������}
    begin
      if HOV then l := Hor[i,k] else l := Vert[i,k];
      tempsc := 1;
      for s := p downto 0 do
      begin
        if (St3[p] <> UNREAL) then Inc(tempsc)
        else Break;
      end;
      if tempsc < l then{����� ����� �� �������,}
                        {��������� � �������� ��������� �����}
      begin
        p := p - tempsc;
        k := k + 1;
        Continue;
      end;
      for s := p downto 0 do{��������� �����}
      begin
        St2[p] := k;
        p := p - 1;
      end;
    end;{����� ����� ���������� St2 �� ����� �� ������}
    if HOV then p := HorR else p := VertR;
    for l := 0 to p do
    begin
      if St1[l] = St2[p] then St4[p] := St1[p];
      {���� � St1 � St2 ���� ���������� �������, �� ������ �� � St4}
      if (St3[l] = THINK) then problema := true;
    end;
    if problema then{���� ������� �������� � ���� THINK,}
                    {�� ���������� ������� ��������������� ������� �����}
      Insert(Analise);
  end;{����� ����� ����������}
end;

procedure Solving; {������� ����������}
begin
  While(TestMatrix = false){���� ������� ������������}
                           {������� ������ false "���������" ���������� �������}
  begin
    LoadMatrix(true);{�������� ������������}
    LoadMatrix(false);{�������� ����������}
    Unite;{����������� ���������� � �������������}
  end:
  ToChar;{������� ��������� ���������� � ����������� ����}
  Print;{����� �� �����}
end;

{int main()}
var
  i :Char;
begin{Main �������: �������� ����� � �������� ������ �������}
  ClrScr;
  WriteLn('*--------------------------------------------*');
  WriteLn('|  Program for solving Japenese crosswords   |');
  WriteLn('|     This program was create by Stalker     |');
  WriteLn('|          All rights reserved ;-P           |');
  WriteLn('*--------------------------------------------*');
  WriteLn;
  WriteLn;
  Load;
  Solving;
  Write('Save results Yes[Y] or No[N]: ');
  ReadLn(i);
  if (i = 'y') or (i = 'Y') then Save;
  WriteLn('!Program is complete!');
  WriteLn('Press <Enter>');
end.
