unit UBTrees;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  m = 2;
  q = 2*m+1;
  delta = 30;
type
  tipkey = integer;
  uzl = record
    s: integer;
    key: array[0..q-1] of tipkey;
    p: array[0..q] of integer;
  end;
  zap = record
    key: tipkey;
  end;
  zapf = file of zap;
  uzlf = file of uzl;

{const
  b: array[0..9] of uzl = (
    (s:2; key:(0,0,0,0,0); p:(10,14,0,0,0,0)),
    (s:1; key:(5,0,0,0,0); p:(8,9,0,0,0,0)),
    (s:3; key:(-1,0,1,0,0); p:(-1,-1,-1,0,0,0)),
    (s:3; key:(7,9,10,0,0); p:(-1,-1,-1,0,0,0)),
    (s:2; key:(4,5,0,0,0); p:(-1,-1,0,0,0,0)),
    (s:2; key:(2,3,0,0,0); p:(-1,-1,0,0,0,0)),
    (s:2; key:(15,17,0,0,0); p:(-1,-1,0,0,0,0)),
    (s:2; key:(11,12,0,0,0); p:(-1,-1,0,0,0,0)),
    (s:2; key:(1,3,0,0,0); p:(2,5,4,0,0,0)),
    (s:2; key:(10,12,0,0,0); p:(3,7,6,0,0,0)));
}
var
  Form1: TForm1;
  s: string;
  b: array of uzl;
  rec: array of zap;

implementation

{$R *.dfm}
function zkey(const w:zap):tipkey;
begin
  zkey:=w.key;
end;

function InsB(var B: array of uzl; var rec:array of zap; const z: array of zap;
  const kl:array of tipkey):integer;
const
  q =2*m+1;
var
  arg:tipkey;
  c, ct, hz, i, j, k, nt, r, t, u, v: integer;
  st: array[0..7] of record k,v :integer; end;
begin
  if b[0].p[1] = 0 then
  begin
    b[0].p[0] := 2;
    b[0].s := 0;
    b[1].s := 0;
  end;
  ct := 0;
  hz := high(z);
  if hz < 0 then
    nt := high(kl)
  else
    nt := hz;
  for t := 0 to nt do
  begin
    u:=0;
    v:=1;
    if hz < 0 then
      arg := kl[t]
    else
      arg := zkey(z[t]);

    repeat
      i:= 0;
      k:= b[v].s;
      while i < k do
      begin
        j:= (i+k) div 2;
        if b[v].key[j] < arg then
          i := j+1
        else
          k:=j;
      end;
      st[u].v:=v;
      st[u].k:= k;
      if u = b[0].s then
        break;
      inc(u);
      v:= b[v].p[k];
    until false;
    if k < b[v].s then
      if b[v].key[k] = arg then
      begin
        inc(ct);
        result := b[v].p[k];
        continue;
      end;
    if hz < 0 then
      continue;
    with b[v] do
    begin
      for j:= s downto k+1 do
      begin
        key[j]:=key[j-1];
        p[j]:=p[j-1];
      end;
      inc(s);
      key[k]:=arg;
      p[k]:=b[0].p[1];
      rec[p[k]]:=z[t];
      inc(b[0].p[1]);
      if s < q then
        continue
      else
        s:=m+1;
    end;

    repeat
      arg:=b[v].key[m];
      if u = 0 then
      begin
        r:=b[0].p[0];
        b[r]:=b[1];
        inc(b[0].p[0]);
        inc(b[0].s);
        with b[1] do
        begin
          s:=1;
          key[0]:=arg;
          p[0]:=r;
          p[1]:=r+1;
        end;
      end;
      r:=b[0].p[0];
      b[r]:=b[v];
      inc(b[0].p[0]);
      if(b[0].p[0] = Length(b)) then
        setlength(b,length(b) + delta);
      with b[r] do
      begin
        s:=m;
        p[m]:=p[q];
        for j:=1 to m do
        begin
          key[j-1]:=key[j+m];
          p[j-1]:=p[j+m];
        end;
      end;
      if u =0 then
        break;
      dec(u);
      v:= st[u].v;
      with b[v] do
      begin
        k:=st[u].k;
        for j:= s-1 downto k do
        begin
          key[j+1]:=key[j];
          p[j+2]:=p[j+1];
        end;
        key[k]:= arg;
        p[k+1]:=r;
        inc(s);
        c:=s;
        if s= q then
          s:=m;
      end;
    until c < q;
  end;
  if ct <= nt then
    result:= -1;
end;

procedure delb(var  b: array of uzl; var rec: array of zap; const kl: array of tipkey);
var
  d,g,i,j,k,k0,u,v,n,r,t,v0,v1,x,y,z: integer;
  arg: tipkey;
  st: array[0..7] of record k,v :integer; end;
  w: array[-1..7] of integer;
  function search: integer;
  begin
    u:=0;
    v:=1;
    result:=-1;
    repeat
      i:= 0;
      k:= b[v].s;
      while i < k do
      begin
        j:= (i+k) div 2;
        if b[v].key[j] < arg then
          i := j+1
        else
          k:=j;
      end;
      st[u].v:=v;
      st[u].k:= k;
      if u = b[0].s then
        break;
      inc(u);
      v:= b[v].p[k];
    until false;
    if k < b[v].s then
      if b[v].key[k] = arg then
        result := b[v].p[k];
  end;
begin
  for t := 0 to high(kl) do
  begin
    if b[0].p[1] = 0 then
      exit;
    for g := low(w) to high(w) do
      w[g] := 0;
    arg := kl[t];
    x:=search;
    if x < 0 then
      continue;
    y := 0;
    g := 0;
    with b[v] do
      for j:= k+1 to s do
      begin
        key[j-1]:=key[j];
        p[j-1]:=p[j];
      end;
    v1:=v;
    dec(b[v].s);
    if (b[v].s < m) and (u >0) then
    repeat
      v:=v1;
      dec(u);
      k:=st[u].k;
      v1:=st[u].v;
      if(k = b[v1].s) then
        k0 := k-1
      else
        k0:=k+1;
      v0 := b[v1].p[k0];
      if b[v0].s = m then
      begin
        d:=y;
        r:=m;
        g:=u+1;
        w[g]:=v0;
      end
      else
      begin
        d:=0;
        r:=(b[v0].s-b[v].s) div 2;
      end;
      with b[v] do
        if k0 < k then
        begin
          z:=r+d;
          i:= b[v0].s + y - z;
          arg:=b[v0].key[i-1];
          dec(k);
          for j:=s downto 0 do
          begin
            key[j+z]:= key[j];
            p[j+z]:=p[j];
          end;
          if y = 1 then
          begin
            key[z-1]:=b[v1].key[k0];
            p[z-1] := b[v0].p[b[v0].s];
          end;
          for j:=0 to z-y-1 do
          begin
            key[j]:=b[v0].key[i+j];
            p[j] := b[v0].p[i+j];
          end;
        end
        else
        begin
          arg:=b[v0].key[r-1];
          if y=1 then
            key[s]:=b[v1].key[k];
          for j:= 0 to r do
          begin
            key[s+j+y]:=b[v0].key[j];
            p[s+j+y]:= b[v0].p[j];
          end;
          for j:= 0 to b[v0].s do
          begin
            b[v0].key[j] := b[v0].key[j+r];
            b[v0].p[j]:= b[v0].p[j+r];
          end;
        end;
      dec(b[v0].s,r);
      inc(b[v].s,r);
      with b[v1] do
        if b[v0].s > 0 then
          key[k]:=arg
        else
        begin
          inc(b[v].s,y);
          for j:=k to s-1 do
            key[j]:=key[j+1];
          for j:= k0 to s do
            p[j]:=p[j+1];
          dec(s);
          y:=1
        end;
    until (b[v1].s >= m) or (u = 0);
    dec(b[0].p[1]);
    if(b[0].p[1]=0) then
      exit;
    r:=b[0].s;
    if(b[1].s = 0) then
    begin
      dec(b[0].s);
      b[1]:=b[v];
      b[v].s := 0;
      w[0]:=v;
    end;
    n:= b[0].p[0];
    inc(r);
    if(g>0)then
      repeat
        repeat
          dec(n);
        until b[n].s > 0;
        repeat
          dec(r);
        until w[r] < n;
        if w[r] = 0 then
          break;
        arg := b[n].key[0];
        search;
        u:=0;
        repeat
          inc(u);
        until st[u].v = n;
        b[w[r]] := b[n];
        b[st[u-1].v].p[st[u-1].k] := w[r];
      until false;
    with b[0] do
    begin
      if g > 0 then
        p[0]:=n+1;
      if x= p[1] then
        continue;
      arg:=zkey(rec[p[1]]);
      search;
      rec[x]:= rec[p[1]];
      b[st[u].v].p[st[u].k]:=x;
    end;
  end;
end;

function InsBdisk(var b: uzlf;var rec: zapf; const z: array of zap):integer;
const
  q =2*m+1;
var
  a:uzl;
  w:array[0..5] of uzl;
  arg:tipkey;
  c, ct, i, j, k, r, t, u, v, hz: integer;
  st: array[0..7] of integer;

  procedure rost(var k: integer;u: integer);
  begin
    k:=a.p[0];
    seek(b,k);
    write(b,w[u]);
    inc(a.p[0]);
  end;
begin
  seek(b,0);
  read(b,a,w[0]);
  ct := 0;
  hz := high(z);
  for t := 0 to hz do
  begin
    u:=0;
    v:=1;
    arg := zkey(z[t]);

    repeat
      i:= 0;
      k:= w[u].s;
      while i < k do
      begin
        j:= (i+k) div 2;
        if w[u].key[j] < arg then
          i := j+1
        else
          k:=j;
      end;
      st[u]:= k;
      if u = a.s then
        break;
      inc(u);
      v:= w[u].p[k];
      seek(b,v);
      inc(u);
      read(b,w[u]);
    until false;
    if k < w[u].s then
      if w[u].key[k] = arg then
      begin
        inc(ct);
        result := w[u].p[k];
        continue;
      end;
    for j := w[u].s downto k+1 do
    begin
      w[u].key[j]:=w[u].key[j-1];
      w[u].p[j]:=w[u].p[j-1];
    end;
    inc(w[u].s);
    w[u].key[k]:=arg;
    w[u].p[k]:=a.p[1];
    inc(a.p[1]);
    c:=w[u].s;
    seek(rec,w[u].p[k]);
    write(rec,z[t]);
    if w[u].s < q then
      continue;

    repeat
      arg:=w[u].key[m];
      if u = 0 then
      begin
        rost(k,0);
        inc(a.s);
        {r:=b[0].p[0];
        b[r]:=b[1];
        inc(b[0].p[0]);
        inc(b[0].s);}
        with w[0] do
        begin
          s:=1;
          key[0]:=arg;
          p[0]:=k;
          p[1]:=k+1;
        end;
        seek(b,1);
        write(b,w[0]);
      end;
      w[u+1].s:=m;
      w[u+1].p[m]:=w[u].p[q];
      for j:=1 to m do
      begin
        w[u+1].key[j-1]:=w[u].key[j+m];
        w[u+1].p[j-1]:=w[u].p[j+m];
      end;
      rost(r,u+1);
      if u =0 then
        break;
      dec(u);
{      v:= st[u];}
      with w[u] do
      begin
        for j:= s-1 downto st[u] do
        begin
          key[j+1]:=key[j];
          p[j+2]:=p[j+1];
        end;
        key[st[u]]:= arg;
        p[st[u]+1]:=r;
        inc(s);
        c:=s;
        if(u = 0) then
          seek(b,1)
        else
          seek(b,w[u-1].p[st[u-1]]);
        if w[u].s = q then
          w[u].s:=m;
        write(b,w[u])
      end;
    until c < q;
  end;
  seek(b,0);
  write(b,a);
  if ct <= length(z) then
    result:= -1;
end;

procedure saveb(s1,s2:string);
var
  f1:file of uzl;
  f2:file of zap;
  j:integer;
begin
  assign(f1,s1);
  assign(f2,s2);
  rewrite(f1);
  rewrite(f2);
  setlength(b,b[0].p[1]);
  for j:=0 to high(b) do
    write(f1,b[j]);
  for j:= 0 to high(rec) do
    write(f2,rec[j]);
  close(f1);
  close(f2);
end;

procedure restb(s1, s2 :string; db:integer =0; dr: integer = 0);
var
  f1:file of uzl;
  f2:file of zap;
  j:integer;
begin
  assign(f1,s1);
  assign(f2,s2);
  reset(f1);
  reset(f2);
  setlength(b,filesize(f1)+db);
  setlength(rec,filesize(f2)+dr);
  for j:=0 to filesize(f1)-1 do
    read(f1,b[j]);
  for j:= 0 to filesize(f2)-1 do
    read(f2,rec[j]);
  close(f1);
  close(f2);
end;

procedure initb(s1,s2:string; var f1:uzlf; var f2:zapf);
var
  w:uzl;
begin
  assign(f1,s1);
  assign(f2,s2);
  rewrite(f1);
  rewrite(f2);
  w.s := 0;
  w.p[0] := 0;
  w.p[1] := 0;
  write(f1,w);
  close(f1);
  close(f2);
end;

function ObrB(const key: tipkey; p:Integer):boolean;
begin
  result := false;
  s:=s + IntToStr(key) + ' ';
end;

procedure ObhodB(const b: array of uzl);
var
  k, u , v:Integer;
  st :array[0..5] of record k,v :Integer; end;
begin
  if b[0].p[1] = 0 then
    exit;
  u:=-1;
  v:=1;
  repeat
    inc(u);
    if u>0 then
      v:=b[v].p[0];
    st[u].k := 0;
    st[u].v := v;
  until u = b[0].s;

  repeat
    with b[v] do
      for k:= st[u].k to s-1 do
        if ObrB(key[k], p[k]) then
          exit;

    if u = 0 then
      exit;
    repeat
      st[u].k :=0;
      dec(u);
      if u < 0 then
        exit;
      v:= st[u].v;
    until st[u].k < b[v].s;
    inc(st[u].k);
    repeat
      v := b[v].p[st[u].k];
      inc(u);
      st[u].v := v;
    until u = b[0].s;
  until false;
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  z: array[1..14] of zap = (
    (key:7),(key:1),(key:5),(key:9),(key:3),(key:4),
    (key:0),(key:-1),(key:2),(key:15),(key:12),(key:17),
    (key:10),(key:11));
begin
  setlength(b,20);
  setlength(rec,100);
  b[0].p[1] := 0;
  insb(b,rec,z,[]);
  s:= '';
  if(insb(b,rec,[],[5,1,7,9,3,0,4,2,-1,12,15,17,10,11]) <> -1) then
    ObhodB(b);
  Memo1.Text := s;
  delb(b,rec,[3,7,1,5,9,4,0,-1,2,15,12,10,11]);
  s:='';
  ObhodB(b);
  Memo1.Lines.Add(s);
end;

end.
