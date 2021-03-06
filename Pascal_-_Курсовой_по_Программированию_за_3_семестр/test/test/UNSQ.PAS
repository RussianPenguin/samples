
(*
 DEARC.PAS - Program to extract all files from an archive created by version
             5.12 or earlier of the ARC utility.

   *** ORIGINAL AUTHOR UNKNOWN ***
*)

Program DearcSQ;

{$R-}
{$U-}
{$C-}
{$K-}

const 
      BLOCKSIZE = 128;
      arcmarc   = 26;              { special archive marker }
      arcver    = 9;               { max archive header version code }
      strlen    = 100;             { standard string length }
      fnlen     = 12;              { file name length - 1 }

const 
  crctab : array [0..255] of integer =
  ( $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040 );

type 
     longtype    = record           { used to simulate long (4 byte) integers }
                 l, h : integer
               end;

     strtype = string[strlen];
     fntype  = array [0..fnlen] of char;
     buftype = array [1..BLOCKSIZE] of byte;
     heads   = record
                 name   : fntype;
                 size   : longtype;
                 date   : integer;
                 time   : integer;
                 crc    : integer;
                 length : longtype
               end;

var 
    hdrver   : byte;
    arcfile  : file;
    arcbuf   : buftype;
    arcptr   : integer;
    arcname  : strtype;
    endfile  : boolean;
    extfile  : file;
    extbuf   : buftype;
    extptr   : integer;
    extname  : strtype;

{ definitions for unpack }

Const
   DLE = $90;

Var
   state  : (NOHIST, INREP);
   crcval : integer;
   size   : real;
   lastc  : integer;

{ definitions for unsqueeze }

Const
   ERROR   = -1;
   SPEOF   = 256;
   NUMVALS = 256;               { 1 less than the number of values }

Type
   nd = record
           child : array [0..1] of integer
        end;

Var
   node     : array [0..NUMVALS] of nd;
   bpos     : integer;
   curin    : integer;
   numnodes : integer;

{ definitions for uncrunch }

Const
   TABSIZE   = 4096;
   TABSIZEM1 = 4095;
   NO_PRED   = $FFFF;
   EMPTY     = $FFFF;

Type
   entry = record
              used         : boolean;
              next         : integer;
              predecessor  : integer;
              follower     : byte
           end;

Var
   stack       : array [0..TABSIZEM1] of byte;
   sp          : integer;
   string_tab  : array [0..TABSIZEM1] of entry;

Var
   code_count : integer;
   code       : integer;
   firstc     : boolean;
   oldcode    : integer;
   finchar    : integer;
   inbuf      : integer;
   outbuf     : integer;
   newhash    : boolean;

{ definitions for dynamic uncrunch }

Const
  Crunch_BITS = 12;
  Squash_BITS = 13;
  HSIZE = 8192;
  INIT_BITS = 9;
  FIRST = 257;
  CLEAR = 256;
  HSIZEM1 = 8191;
  BITSM1 = 12;

  RMASK : array[0..8] of byte =
  ($00, $01, $03, $07, $0f, $1f, $3f, $7f, $ff);

Var
  bits,
  n_bits,
  maxcode    : integer;
  prefix     : array[0..HSIZEM1] of integer;
  suffix     : array[0..HSIZEM1] of byte;
  buf        : array[0..BITSM1]  of byte;
  clear_flg  : integer;
  stack1     : array[0..HSIZEM1] of byte;
  free_ent   : integer;
  maxcodemax : integer;
  offset,
  sizex      : integer;
  firstch    : boolean;

procedure abortme(s : strtype);
{ terminate the program with an error message }
begin
  writeln('ABORT: ', s);
  halt;
end; (* proc abortme *)

function fn_to_str(var fn : fntype) : strtype;
{ convert strings from C format (trailing 0) to Turbo Pascal format (leading
    length byte). }
var s : strtype;
    i : integer;
begin
  s := '';
  i := 0;
  while fn[i] <> #0 do begin
    s := s + fn[i];
    i := i + 1
    end;
  fn_to_str := s
end; (* func fn_to_str *)

function unsigned_to_real(u : integer) : real;
{ convert unsigned integer to real }
{ note: INT is a function that returns a REAL!!!}
begin
  if u >= 0 then
    unsigned_to_real := Int(u)
  else
  if u = $8000 then
    unsigned_to_real := 32768.0
  else
    unsigned_to_real := 65536.0 + u
end; (* func unsigned_to_real *)

function long_to_real(l : longtype) : real;
{ convert longtype integer to a real }
{ note: INT is a function that returns a REAL!!! }
var r : real;
    s : (posit, NEG);
const rcon = 65536.0;
begin
  if l.h >= 0 then begin
    r := Int(l.h) * rcon;
    s := posit          {notice: no ";" here}
    end
  else begin
    s := NEG;
    if l.h = $8000 then
      r := rcon * rcon
    else
      r := Int(-l.h) * rcon
    end;
  r := r + unsigned_to_real(l.l);
  if s = NEG then
    long_to_real := -r
  else
    long_to_real := r
end; (* func long_to_real *)

procedure Read_Block;
{ read a block from the archive file }
begin
  if EOF(arcfile) then
    endfile := TRUE
  else
    BlockRead(arcfile, arcbuf, 1);
  arcptr := 1
end; (* proc read_block *)

procedure Write_Block;
{ write a block to the extracted file }
begin
  BlockWrite(extfile, extbuf, 1);
  extptr := 1
end; (* proc write_block *)

procedure open_arc;
{ open the archive file for input processing }
begin
  {$I-} assign(arcfile, arcname); {$I+}
  if ioresult <> 0 then
    abortme('Cannot open archive file.');
  {$I-} reset(arcfile); {$I+}
  if ioresult <> 0 then
    abortme('Cannot open archive file.');
  endfile := FALSE;
  Read_Block
end; (* proc open_arc *)

procedure open_ext;
{ open the extracted file for writing }
begin
  {$I-} assign(extfile, extname); {$I+}
  if ioresult <> 0 then
    abortme('Cannot open extract file.');
  {$I-} rewrite(extfile); {$I+}
  if ioresult <> 0 then
    abortme('Cannot open extract file.');
  extptr := 1;
end; (* proc open_ext *)

function get_arc : byte;
{ read 1 character from the archive file }
begin
  if endfile then
    get_arc := 0
  else begin
    get_arc := arcbuf[arcptr];
    if arcptr = BLOCKSIZE then
      Read_Block
    else
      arcptr := arcptr + 1
    end
end; (* func get_arc *)

procedure put_ext(c : byte);
{ write 1 character to the extracted file }
begin
  extbuf[extptr] := c;
  if extptr = BLOCKSIZE then
    Write_Block
  else
    extptr := extptr + 1
end; (* proc put_ext *)

procedure close_arc;
{ close the archive file }
begin
  close(arcfile)
end; (* proc close_arc *)

procedure close_ext;
{ close the extracted file }
begin
  while extptr <> 1 do
    put_ext(Ord(^Z));          { pad last block w/ Ctrl-Z (EOF) }
  close(extfile)
end; (* proc close_ext *)

procedure fseek(offset : real; base : integer);
{ re-position the current pointer in the archive file }
var b           : real;
    i, ofs, rec : integer;
    c           : byte;
begin
  case base of
    0 : b := offset;
    1 : b := offset + (unsigned_to_real(FilePos(arcfile)) - 1.0) * BLOCKSIZE
              + arcptr - 1.0;
    2 : b := offset + unsigned_to_real(FileSize(arcfile)) * BLOCKSIZE - 1.0
    else
      abortme('Invalid parameters to fseek')
    end;
  rec := Trunc(b / BLOCKSIZE);
  ofs := Trunc(b - (Int(rec) * BLOCKSIZE));  { Int converts to Real }
  seek(arcfile, rec);
  Read_Block;
  for i := 1 to ofs do
    c := get_arc
end; (* proc fseek *)

procedure fread(var buf; reclen : integer);
{ read a record from the archive file }
var i : integer;
    b : array [1..MaxInt] of byte absolute buf;
begin
  for i := 1 to reclen do
    b[i] := get_arc
end; (* proc fread *)

procedure GetArcName;
{ get the name of the archive file }
var i : integer;
begin
  if ParamCount > 1 then
    abortme('Too many parameters');
  if ParamCount = 1 then
    arcname := ParamStr(1)
  else begin
    write('Enter archive filename: ');
    readln(arcname);
    if arcname = '' then
      abortme('No file name entered');
    writeln;
    writeln;
    end;
  for i := 1 to length(arcname) do
    arcname[i] := UpCase(arcname[i]);
  if pos('.', arcname) = 0 then
    arcname := arcname + '.ARC'
end; (* proc GetArcName *)

function readhdr(var hdr : heads) : boolean;
{ read a file header from the archive file }
{ FALSE = eof found; TRUE = header found }
var name : fntype;
    try  : integer;
begin
  try := 10;
  if endfile then begin
    readhdr := FALSE;
    exit;
    end;
  while get_arc <> arcmarc do begin
    if try = 0 then
      abortme(arcname + ' is not an archive');
    try := try - 1;
    writeln(arcname, ' is not an archive, or is out of sync');
    if endfile then
      abortme('Archive length error')
    end; (* while *)
  hdrver := get_arc;
  if hdrver < 0 then
    abortme('Invalid header in archive ' + arcname);
  if hdrver = 0 then begin   { special end of file marker }
    readhdr := FALSE;
    exit;
    end;
  if hdrver > arcver then begin
    fread(name, fnlen);
    writeln('I dont know how to handle file ', fn_to_str(name),
            ' in archive ', arcname);
    writeln('I think you need a newer version of DEARC.');
    halt;
    end;
  if hdrver = 1 then begin
    fread(hdr, sizeof(heads) - sizeof(longtype));
    hdrver := 2;
    hdr.length := hdr.size
    end
  else
    fread(hdr, sizeof(heads));
  readhdr := TRUE;
end; (* func readhdr *)

procedure putc_unp(c : integer);
begin
  crcval := ((crcval shr 8) and $00FF) xor crctab[(crcval xor c) and $00FF];
  put_ext(c)
end; (* proc putc_unp *)

procedure putc_ncr(c : integer);
begin
  case state of
    NOHIST : if c = DLE then
               state := INREP
             else begin
               lastc := c;
               putc_unp(c)
               end;
    INREP  : begin
             if c = 0 then
               putc_unp(DLE)
             else begin
               c := c - 1;
               while (c <> 0) do begin
                 putc_unp(lastc);
                 c := c - 1
                 end
               end;
             state := NOHIST
             end;
    end; (* case *)
end; (* proc putc_ncr *)

function getc_unp : integer;
begin
  if size = 0.0 then
    getc_unp := -1
  else begin
    size := size - 1.0;
    getc_unp := get_arc
    end;
end; (* func getc_unp *)

procedure init_usq;
{ initialize for unsqueeze }
var i : integer;
begin
  bpos := 99;
  fread(numnodes, sizeof(numnodes));
  if (numnodes < 0) or (numnodes > NUMVALS) then
    abortme('File has an invalid decode tree');
  node[0].child[0] := -(SPEOF + 1);
  node[0].child[1] := -(SPEOF + 1);
  for i := 0 to numnodes-1 do begin
    fread(node[i].child[0], sizeof(integer));
    fread(node[i].child[1], sizeof(integer))
    end;
end; (* proc init_usq; *)

function getc_usq : integer;
{ unsqueeze }
var i : integer;
begin
  i := 0;
  while i >= 0 do begin
    bpos := bpos + 1;
    if bpos > 7 then begin
      curin := getc_unp;
      if curin = ERROR then begin
        getc_usq := ERROR;
        exit;
        end;
      bpos := 0;
      i := node[i].child[1 and curin]
      end
    else begin
      curin := curin shr 1;
      i := node[i].child[1 and curin]
      end
    end; (* while *)
  i := - (i + 1);
  if i = SPEOF then
    getc_usq := -1
  else
    getc_usq := i;
end; (* func getc_usq *)

function h(pred, foll : integer) : integer;
{ calculate hash value }
{ thanks to Bela Lubkin }
var Local : Real;
    S     : String[20];
    I, V  : integer;
    C     : char;
begin
if not newhash then
begin
  Local := (pred + foll) or $0800;
  if Local < 0.0 then
    Local := Local + 65536.0;
  Local := (Local * Local) / 64.0;
{ convert Local to an integer, truncating high order bits. }
{ there ***MUST*** be a better way to do this!!! }
  Str(Local:15:5, S);
  V := 0;
  I := 1;
  C := S[1];
  while C <> '.' do begin
    if (C >= '0') and (C <= '9') then
      V := V * 10 + (Ord(C) - Ord('0'));
    I := I + 1;
    C := S[I]
    end;
  h := V and $0FFF
end (* func h *)
else
begin
  Local := (pred + foll) * 15073;
{ convert Local to an integer, truncating high order bits. }
{ there ***MUST*** be a better way to do this!!! }
  Str(Local:15:5, S);
  V := 0;
  I := 1;
  C := S[1];
  while C <> '.' do begin
    if (C >= '0') and (C <= '9') then
      V := V * 10 + (Ord(C) - Ord('0'));
    I := I + 1;
    C := S[I]
    end;
  h := V and $0FFF
end;
end;

function eolist(index : integer) : integer;
var temp : integer;
begin
  temp := string_tab[index].next;
  while temp <> 0 do begin
    index := temp;
    temp := string_tab[index].next
    end;
  eolist := index
end; (* func eolist *)

function hash(pred, foll : integer) : integer;
var local     : integer;
    tempnext  : integer;
begin
  local := h(pred, foll);
  if not string_tab[local].used then
    hash := local
  else begin
    local := eolist(local);
    tempnext := (local + 101) and $0FFF;
    while string_tab[tempnext].used do begin
      tempnext := tempnext + 1;
      if tempnext = TABSIZE then
        tempnext := 0
      end;
    string_tab[local].next := tempnext;
    hash := tempnext
    end;
end; (* func hash *)

procedure upd_tab(pred, foll : integer);
begin
  with string_tab[hash(pred, foll)] do begin
    used := TRUE;
    next := 0;
    predecessor := pred;
    follower := foll
    end
end; (* proc upd_tab *)

function gocode : integer;
var localbuf  : integer;
    returnval : integer;
begin
  if inbuf = EMPTY then begin
    localbuf := getc_unp;
    if localbuf = -1 then begin
      gocode := -1;
      exit;
      end;
    localbuf := localbuf and $00FF;
    inbuf := getc_unp;
    if inbuf = -1 then begin
      gocode := -1;
      exit;
      end;
    inbuf := inbuf and $00FF;
    returnval := ((localbuf shl 4) and $0FF0) + ((inbuf shr 4) and $000F);
    inbuf := inbuf and $000F
    end
  else begin
    localbuf := getc_unp;
    if localbuf = -1 then begin
      gocode := -1;
      exit;
      end;
    localbuf := localbuf and $00FF;
    returnval := localbuf + ((inbuf shl 8) and $0F00);
    inbuf := EMPTY
    end;
  gocode := returnval;
end; (* func gocode *)

procedure push(c : integer);
begin
  stack[sp] := c;
  sp := sp + 1;
  if sp >= TABSIZE then
    abortme('Stack overflow')
end; (* proc push *)

function pop : integer;
begin
  if sp > 0 then begin
    sp := sp - 1;
    pop := stack[sp]
  end else
    pop := EMPTY
end; (* func pop *)

procedure init_tab;
var i : integer;
begin
  FillChar(string_tab, sizeof(string_tab), 0);
  for i := 0 to 255 do
    upd_tab(NO_PRED, i);
  inbuf := EMPTY;
  { outbuf := EMPTY }
end; (* proc init_tab *)

procedure init_ucr(i:integer);
begin
  newhash := i = 1;
  sp := 0;
  init_tab;
  code_count := TABSIZE - 256;
  firstc := TRUE
end; (* proc init_ucr *)

function getc_ucr : integer;
var c       : integer;
    code    : integer;
    newcode : integer;
begin
  if firstc then begin
    firstc := FALSE;
    oldcode := gocode;
    finchar := string_tab[oldcode].follower;
    getc_ucr := finchar;
    exit;
    end;
  if sp = 0 then begin
    newcode := gocode;
    code := newcode;
    if code = -1 then begin
      getc_ucr := -1;
      exit;
      end;
    if not string_tab[code].used then begin
      code := oldcode;
      push(finchar)
      end;
    while string_tab[code].predecessor <> NO_PRED do
      with string_tab[code] do begin
        push(follower);
        code := predecessor
        end;
    finchar := string_tab[code].follower;
    push(finchar);
    if code_count <> 0 then begin
      upd_tab(oldcode, finchar);
      code_count := code_count - 1
      end;
    oldcode := newcode
    end;
  getc_ucr := pop;
end; (* func getc_ucr *)

function getcode : integer;
label
  next;
var
  code, r_off, bitsx : integer;
  bp : byte;
begin
  if firstch then
  begin
    offset := 0;
    sizex := 0;
    firstch := false;
  end;
  bp := 0;
  if (clear_flg > 0) or (offset >= sizex) or (free_ent > maxcode) then
  begin
    if free_ent > maxcode then
    begin
      n_bits := n_bits + 1;
      if n_bits = BITS then
        maxcode := maxcodemax
      else
        maxcode := (1 shl n_bits) - 1;
    end;
    if clear_flg > 0 then
    begin
      n_bits := INIT_BITS;
      maxcode := (1 shl n_bits) - 1;
      clear_flg := 0;
    end;
    for sizex := 0 to n_bits-1 do
    begin
      code := getc_unp;
      if code = -1 then
        goto next
      else
        buf[sizex] := code;
    end;
    sizex := sizex + 1;
next:
    if sizex <= 0 then
    begin
      getcode := -1;
      exit;
    end;
    offset := 0;
    sizex := (sizex shl 3) - (n_bits - 1);
  end;
  r_off := offset;
  bitsx := n_bits;

  { get first byte }
  bp := bp + (r_off shr 3);
  r_off := r_off and 7;

  { get first parft (low order bits) }
  code := buf[bp] shr r_off;
  bp := bp + 1;
  bitsx := bitsx - (8 - r_off);
  r_off := 8 - r_off;

  if bitsx >= 8 then
  begin
    code := code or (buf[bp] shl r_off);
    bp := bp + 1;
    r_off := r_off + 8;
    bitsx := bitsx - 8;
  end;

  code := code or ((buf[bp] and rmask[bitsx]) shl r_off);
  offset := offset + n_bits;
  getcode := code;
end;

procedure decomp(    SquashFlag : Integer);
label
  next;
var
  stackp,
  finchar :integer;
  code, oldcode, incode : integer;

begin
  { INIT var }
  if SquashFlag = 0 then
     Bits := crunch_BITS
  else
     Bits := squash_BITS;

  if firstch then
    maxcodemax := 1 shl bits;

  If SquashFlag = 0 then begin
     code := getc_unp;
     if code <> BITS then
     begin
       Writeln('File packed with ', Code, ' bits, I can only handle ', Bits);
       Halt;
     end;
  end {if};
  clear_flg := 0;
  n_bits := INIT_BITS;
  maxcode := (1 shl n_bits ) - 1;
  for code := 255 downto 0 do
  begin
    prefix[code] := 0;
    suffix[code] := code;
  end;

  free_ent := FIRST;
  oldcode := getcode;
  finchar := oldcode;
  if oldcode = -1 then
    exit;
  if SquashFlag = 0 then
     putc_ncr(finchar)
  else
     putc_unp(finchar);
  stackp := 0;

  code := getcode;
  while (code  > -1) do begin
    if code = CLEAR then
    begin
      for code := 255 downto 0 do
        prefix[code] := 0;
      clear_flg := 1;
      free_ent := FIRST - 1;
      code := getcode;
      if code = -1 then
        goto next;
    end;
next:
    incode := code;
    if code >= free_ent then
    begin
      stack1[stackp] := finchar;
      stackp := stackp + 1;
      code := oldcode;
    end;
    while (code >= 256) do begin
      stack1[stackp] := suffix[code];
      stackp := stackp + 1;
      code := prefix[code];
    end;
    finchar := suffix[code];
    stack1[stackp] := finchar;
    stackp := stackp + 1;
    repeat
      stackp := stackp - 1;
      If SquashFlag = 0 then
         putc_ncr(stack1[stackp])
      else
         putc_unp(stack1[stackp]);
    until stackp <= 0;
    code := free_ent;
    if code < maxcodemax then
    begin
      prefix[code] := oldcode;
      suffix[code] := finchar;
      free_ent := code + 1;
    end;
    oldcode := incode;
    code := getcode;
  end;
end;

procedure unpack(var hdr : heads);
var c : integer;
begin
  crcval  := 0;
  size    := long_to_real(hdr.size);
  state   := NOHIST;
  FirstCh := TRUE;
  case hdrver of
    1, 2 : begin
           c := getc_unp;
           while c <> -1 do begin
             putc_unp(c);
             c := getc_unp
             end
           end;
    3    : begin
           c := getc_unp;
           while c <> -1 do begin
             putc_ncr(c);
             c := getc_unp
             end
           end;
    4    : begin
           init_usq;
           c := getc_usq;
           while c <> -1 do begin
             putc_ncr(c);
             c := getc_usq
             end
           end;
    5    : begin
           init_ucr(0);
           c := getc_ucr;
           while c <> -1 do begin
             putc_unp(c);
             c := getc_ucr
             end
           end;
    6    : begin
           init_ucr(0);
           c := getc_ucr;
           while c <> -1 do begin
             putc_ncr(c);
             c := getc_ucr
             end
           end;
    7    : begin
           init_ucr(1);
           c := getc_ucr;
           while c <> -1 do begin
             putc_ncr(c);
             c := getc_ucr
             end
           end;
    8    : begin
             decomp(0);
           end;
    9    : begin
             decomp(1);
           end;
    else
           writeln('I dont know how to unpack file ', fn_to_str(hdr.name));
           writeln('I think you need a newer version of DEARC');
           fseek(long_to_real(hdr.size), 1);
           exit;
    end; (* case *)
  if crcval <> hdr.crc then
    writeln('WARNING: File ', fn_to_str(hdr.name), ' fails CRC check');
end; (* proc unpack *)

procedure extract_file(var hdr : heads);
begin
  extname := fn_to_str(hdr.name);
  writeln('Extracting file : ', extname);
  open_ext;
  unpack(hdr);
  close_ext
end; (* proc extract *)

procedure extarc;
var hdr : heads;
begin
  open_arc;
  while readhdr(hdr) do
    extract_file(hdr);
  close_arc
end; (* proc extarc *)

procedure PrintHeading;
begin
  writeln;
  writeln('Turbo Pascal DEARC Utility');
  writeln('Version 3.01, 8/8/87');
  writeln('Supports Phil Katz "squashed" files');
  writeln;
end; (* proc PrintHeading *)

begin
  PrintHeading; { print a heading }
  GetArcName;   { get the archive file name }
  extarc;       { extract all files from the archive }
end.
                                                                                    


