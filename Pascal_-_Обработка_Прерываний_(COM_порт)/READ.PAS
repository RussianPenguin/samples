Uses Crt, Dos, Rs232Int;

   { �� ��楤�� �㤥� �맢��� �� ����祭�� ���� }
   procedure COMCallBack(Status : Byte; b : byte); far;
   begin
    {� ॠ�쭮� �ணࠬ�� ⠪ ������ �� ४���������! }
    {�뢮� �� ��࠭ - �祭� ������ ������ ��� ��     }
    {�ᯮ�짮����� � ��ࠡ��稪� �����⭮�� ���뢠���}
    WriteLn(b);
   End;

Begin
 {���樠������ ���� � ॣ������ callback ��楤���}
 InitRS232(1, COMCallBack, 9600, 3);

 {�����⮩ 横�}
 While (True) do begin

  {������� ���饭�� � �����!}
  If KeyPressed then
   If ReadKey = #27 then Break;

 End;

 CloseRS232;
End.