Unit RS232Int;

INTERFACE
uses crt;

{��� ��� call-back �㭪樨, ��뢠���� ��}
{����祭�� ������ ����. �ணࠬ�� �����  }
{ॣ����஢��� ᢮� �㭪樨 ��ࠡ�⪨.   }
Type
 TCallBackRS = Procedure(Status : Byte; b : Byte);

{              �������� �������                 }

{���樠������ ����                            }
{  ComIndex - ����� ����                       }
{  Proc     - ���� callback �㭪樨 ��� nil    }
{  Speed    - ᪮���� ࠡ��� ����             }
{  ComPar   - ����ன�� ����                   }
Procedure InitRS232(ComIndex : Byte; Proc : TCallBackRS; Speed : Longint; COMPar : Byte);
{�����⨥ ����, ����⠭������� ��ࠡ��稪�� INT}
procedure CloseRS232;
{��।�� ���� � ���� }
procedure OutByteToRS232(b:Byte);

{              ���������� �������               }
{���稪 �맮��� ���뢠���}
function  GetIntRSCount : Longint;

{           �������������� �������              }
{�������� �������� call-back ���� ������ }
procedure SetCallBackRS(Proc : TCallBackRS);
{����蠥� IRQ-���뢠��� }
Procedure EnableIRQ;
{����頥� IRQ-���뢠��� }
Procedure DisableIRQ;
{���⪠ ����. ���� 宫��⮥ �⥭��}
Procedure ClearRSPort;
{������� ��ࠬ��஢ ����}
Procedure SetPortState(Speed : Longint; COMPar : Byte);

IMPLEMENTATION

Uses Dos;

Var { ���� ���� Int 0Ch/0BH }
 SerOldVec: Pointer;

Const { �㦥��� ��६���� }
 Save_ds  : Word = 0;
 Int_sts  : Byte = 0;
 Count    : Word = 0;
 Src_ptr  : Word = 0;
 AddrPr   : Word = 0;
 tmp      : Word = 0;

Var
 BaseAdr  : Word;
 EOI      : Byte;
 IRQ      : Byte;
 IRQMask  : Byte;
 INTVect  : Byte;

Const { �᫮ �室�� � Int }
 CountInt : Longint = 0;

Const { ���� call-back �㭪樨 }
 CallBackPtr : TCallBackRS = nil;

{ ����ணࠬ�� ��ࠡ�⪨ ���뢠��� �� COM-���� }
Procedure Ser_Int; interrupt;
Var B : Byte; COMStatus : Byte;
Begin
  Inc(CountInt); {���稪 �宦����� � INT }

  B:= 0;
  Asm
   mov  dx, BaseAdr { ॣ���� �����䨪�樨 ���뢠��� }
   add  dx, 2       { BaseAdr+2                        }
   in   al,dx
   mov  Int_Sts,al { ��࠭�� ��� ᮤ�ন���       }
   test al,1       { ���� �⫮����� ���뢠���?   }
   jz   @Is_Int    { ��                            }
   pushf           { ���, ��।��� �ࠢ�����      }
   call SerOldVec  { ��஬� ��ࠡ��稪� Int       }
@Is_Int:
   mov  al,EOI     { ��᫠�� EOI ��� IRQ           }
   out  20h,al     { � 1-� ����஫��� ���뢠���   }
   test Int_Sts,4  { ���뢠��� �� �ਥ��?         }
   jnz  @Read_Char { ��                            }
   mov  B, 1
@Read_Char:
   inc  B
  End;

  if (B <> 2) then begin

   Asm
    mov  dx, BaseAdr { ॣ���� ���ﭨ� ����� }
    add  dx, 5       { BaseAdr + 5}
    in   al,dx
    and  al, 1EH
    mov  COMStatus,al { COMStatus<>0, �᫨ �뫠 �訡�� �ਥ�� }
   End;

   Asm
    mov  dx, BaseAdr { ॣ���� ������ }
    in   al, dx      { ������ ᨬ���  }
    mov  B , al
   End;

   {�맮� callback, �᫨ ��� ������}
   If @CallBackPtr<>nil then CallBackPtr(COMStatus, B);
  End;
End;

{����饭�� IRQ ���뢠���}
Procedure DisableIRQ;
Begin
 Asm
  in   al,21h     { IMR 1-�� ����஫�� ���뢠���  }
  or   al,IRQMask { ������� ���뢠��� IRQ �� COM }
  out  21h,al
 End;
End;

{����襭�� IRQ ���뢠���}
Procedure EnableIRQ;
var NIRQMask : Byte;
Begin
 NIRQMask:= not IRQMask;
 Asm
  in   al,21h    { IMR 1-�� ����஫��� ���뢠��� }
  and  al,NIRQMask
  out  21h,al    { ࠧ���� ���뢠��� �� COM }
 End;
End;

{ �����頥� ������ ���� ���� � ����஬ PortIndex }
Function GetBaseAdr(PortIndex : Byte) : Word;
Var LowAdr : Word;
Begin
 { ����塞 ������� ���� ���� � ⠡��� }
 LowAdr := (PortIndex-1)*2;
 { ����砥� ������ ���� ���� �� ⠡���� }
 GetBaseAdr:= MemW[$0040:LowAdr];
End;

{���⪠ ����. �����⮥ �⥭�� ����.}
Procedure ClearRSPort;
Begin
 Asm
  mov  dx, BaseAdr { ॣ���� ������         }
  in   al, dx      { ����� ���� �ਥ��  }
 End;
End;

{��⠭���� ᪮��� ������ � �ࠪ���⨪ ���� }
Procedure SetPortState(Speed : Longint; COMPar : Byte);
Var Freq : Word; FreqH, FreqL : Byte;
Begin
 Freq:= 115200 div Speed;
 FreqH:= Freq shr 8;
 FreqL:= Freq and $00FF;

 Asm
  mov  dx, BaseAdr { ॣ���� �ࠢ����� ������ }
  add  dx, 3       { BaseAdr + 3}
  in   al,dx
  or   al,80h      { ��⠭����� ��� DLAB }
  out  dx,al

  mov  dx, BaseAdr
  mov  al, FreqL
  out  dx,al      { ����訩 ���� ᪮��� }

  inc  dx          { BaseAdr+1  }
  mov  al,FreqH
  out  dx,al       { ���訩 ���� ᪮��� }

  mov  dx, BaseAdr { ॣ���� �ࠢ����� ������ }
  add  dx, 3       { BaseAdr + 3               }
  mov  al, COMPar
  out  dx,al

  mov  dx, BaseAdr { ॣ���� ࠧ�襭�� ���뢠���  }
  add  dx, 1       { BaseAdr+1                      }
  mov  al, 1       { ࠧ���� ���뢠��� �� �ਥ�� }
  out  dx, al
 End;
End;

{ ���樠������ COM ���� }
Procedure InitRS232(ComIndex : Byte; Proc : TCallBackRS; Speed : Longint; COMPar : Byte);
Begin
 CallBackPtr:= Proc; {��࠭��� ���� call-back}

 {������� ������ ���� ����}
 BaseAdr:= GetBaseAdr(ComIndex);

 {���� �� ������ - ��室}
 If BaseAdr = 0 then Exit;

 {���樠������ ��६�����, �������� �� ����� COM}
 Case ComIndex of {����� IRQ ����}
  1: IRQ:= 4; {��� COM1/IRQ4}
  2: IRQ:= 3; {��� COM2/IRQ3}
 End;
 Case IRQ of {����� INT ����� ���뢠��� }
  3: INTVect:= $0B; {��� IRQ3}
  4: INTVect:= $0C; {��� IRQ4}
 End;
 Case IRQ of {������ EOI ����஫���� ���뢠���}
  3: EOI:= $63; {��� IRQ3}
  4: EOI:= $64; {��� IRQ4}
 End;
 Case IRQ of {������ EOI ����஫���� ���뢠���}
  3: IRQMask:= $08; {��� IRQ3}
  4: IRQMask:= $10; {��� IRQ4}
 End;

 Asm
  cli { ������� ���뢠��� }
 End;

 {������� IRQ ���뢠��� }
 DisableIRQ;

 {������� ⥪�騩 ��ࠡ��稪 INT}
 GetIntVec(INTVect, SerOldVec);
 {��⠭����� ���� ��ࠡ��稪 INT}
 SetIntVec(INTVect, Addr(Ser_Int));

 {������� IRQ ���뢠���}
 EnableIRQ;

 {������� ᪮��� ������ � �ࠪ���⨪ ����}
 SetPortState(Speed, COMPar);

 Asm
  sti { ࠧ���� ���뢠��� }
 End;

 {���⪠ ����}
 ClearRSPort;
End;

{ �����⨥ ����. ����⠭������� ��ࠡ��稪�� INT }
Procedure CloseRS232;
Begin
 Asm
@Wait_Free:
   mov  dx, BaseAdr { ॣ���� ���ﭨ� ����� }
   add  dx, 5       { BaseAdr+5               }
   in   al, dx
   nop
   nop
   test al,60h     { ��।�� ����祭�?            }
   jz   @Wait_Free { ����, �᫨ ���                }
   mov  dx, BaseAdr{ ॣ���� ࠧ�襭�� ���뢠��� }
   add  dx, 1      { BaseAdr+1                     }
   mov  al,0       { ������� ���뢠���          }
   out  dx,al
   nop
   nop
   nop
   nop
   mov  dx, BaseAdr  { ॣ���� �ࠢ����� ������� }
   add  dx,4         { BaseAdr+4}
   mov  al,00000011b { ��⨢�஢��� DTR � RTS }
   out  dx,al
   nop
   nop
   nop
   nop
  End;

  {������ ���� ��ࠡ��稪 INT}
  SetIntVec(INTVect, SerOldVec);

  Asm
   cli            { ����� ���뢠��� }
   in   al,21h    { ���� ���� ���뢠��� }
   nop
   nop
   or   al,IRQMask { ������� IRQ ���뢠��� }
   out  21h,al
   sti             { ࠧ�襭�� ���뢠���    }
  End;
End;

{ ����ணࠬ�� �뢮�� ᨬ���� AL � ����.    }
{ �� �訡�� �����頥� CF=1, ���� CF=0.   }
Procedure OutByteToRS232(b:Byte); assembler;
Asm
@Wait_Line:
  mov  dx, BaseAdr { ॣ���� ���ﭨ� ����� }
  add  dx, 5       { BaseAdr+5               }
  in   al,dx
  test al,20h     { ��� ��⮢ � ��।��? }
  jnz  @Output    { �� }
  nop
  loop @Wait_Line { ���, ���� }
  ret

@Output:
  mov  al, B
  mov  dx, BaseAdr  { ॣ���� ������ }
  out  dx,al        { �뢥�� ᨬ��� }
  nop
End;


{����� � ���稪� �宦����� � INT }
function  GetIntRSCount : Longint;
begin
 GetIntRSCount:= CountInt;
end;

{��⠭���� callback ��� �㭪樨 ���樠����樨}
procedure SetCallBackRS(Proc : TCallBackRS);
begin
 CallBackPtr:= Proc;
end;

END.