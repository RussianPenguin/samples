Uses Crt,Graph;
var 
  gr, gr1 :integer;
  k, color:integer;
  newx,newy,x,y :Real;
  a,b,r,c,d,e,f :Real;
begin
  gr1:=6;
  gr:=InstalluserDriver('svga256',nil);
  Initgraph(gr,gr1,'');
  randomize;
  repeat
    r:=random;
    If r <= 0.1 then
    begin
      a:=0;
      B:=0;
      c:=0;
      d:=0.16;
      f:=0;
    end
    else
    begin
      if (r > 0.1) and (r <= 0.86) then
      begin
        a:=0.85;
        b:=0.04;
        c:=-0.04;
        d:=0.85;
        f:=1.6;
      end
      else
      begin
        if (r > 0.86) and (r <= 0.93) then
        begin
          a:=0.2;
          b:=-0.26;
          c:=0.23;
          d:=0.22;
          f:=1.6;
        end
        else
        begin
          a:=-0.15;
          b:=0.28;
          c:=0.26;
          d:=0.24;
          f:=0.44;
        end;
      end;
    end;

    newx:=(a*x)+(b*y);
    newy:=(c*x)+(d*y)+f;

    x:=newx;
    y:=newy;

    putpixel(round(x*100+590),round(1000-y*100),Random(256));
    {Delay(10);}
  until keypressed;

  ReadKey;

  CloseGraph;

  WriteLn('Current Resolution: ',GetMaxX+1,'x',GetMaxY+1);
  WriteLn('Press any key');
  ReadKey;
end.