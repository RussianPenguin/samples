Uses Crt, Dos, Rs232Int;

Begin
 {callback ��� �� �㦭�, ��।��� nil ���� ��ࠬ��஬}
 InitRS232(2, nil, 9600, 3);

 While (True) do begin

  {�� ����⨨ ������ <1> ��।��� ᨬ��� $31}
  {�� ����⨨ ������ <2> ��।��� ᨬ��� $32}
  If KeyPressed then
   Case ReadKey of
    '1': OutByteToRS232($31);
    '2': OutByteToRS232($32);
    #27: Break;
   End;

 End;

 CloseRS232;
End.