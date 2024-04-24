{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/CODER/FRAMTEXT)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit DIALOGS;

INTERFACE

Const
 kbNoKey=0;{Pas de touche}
 kbDn=$5000;{Fleche Bas}
 kbEnter=$1C0D;{Enter}
 kbEsc=$011B;{Escape}
 kbShiftTab=$0F00;{Shift+Tabulation}
 kbTab=$0F09;{Tabulation}
 kbUp=$4800;{Fleche Haut}

Procedure Box(X1,Y1,X2,Y2,Couleur:Byte);
Procedure FrameEmpty(X1,Y1,X2,Y2,Couleur:Byte);
Procedure DialogBox(X1,Y1,X2,Y2,Couleur:Byte);
Function  GetASCII128:Boolean;
Function  LengthButton(ButtonList:String):Integer;
Function  ReadHorizontalButton(ButtonList:String):Word;
Function  ReadLine(Var S:String):Word;
Procedure SetASCII128(X:Boolean);
Procedure ShowButton(ButtonList:String;PosButton:Byte);

IMPLEMENTATION

Uses Crt,DOS;

Var
 CurrDialog:Byte;
 ShowASCII128:Boolean;

{$IFNDEF FPC}
 Procedure CursorOff;
 Var
  Regs:Registers;
 Begin
  Regs.AH:=1;
  Regs.CH:=32;
  Regs.CL:=0;
  Intr($10,Regs);
 End;

 Procedure CursorOn;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0100;
  Regs.CX:=(7 shl 8)+9;
  Intr($10,Regs);
 End;
{$ENDIF}

Function DuplicateString(C:Char;Num:Integer):String;
Var
 I:Byte;
 S:String;
Begin
 S:='';
 For I:=1 to Num do S:=S+C;
 DuplicateString:=S;
End;

Procedure SetASCII128(X:Boolean);Begin
 ShowASCII128:=X;
End;

Function GetASCII128:Boolean;Begin
 GetASCII128:=ShowASCII128;
End;

Procedure Box(X1,Y1,X2,Y2,Couleur:Byte);Begin
 Window(X1,Y1,X2,Y2);
 TextBackground((Couleur shr 4)and 15);
 {$IFDEF FPC}
  If Couleur and $80=$80 Then Begin
   TextColor((Couleur and 15)+BLINK);
  End
   Else
  TextColor(Couleur and 15);
 {$ELSE}
  TextColor(Couleur and 15);
 {$ENDIF}
 ClrScr;
 Window(1,1,80,25);
End;

Procedure FrameEmpty(X1,Y1,X2,Y2,Couleur:Byte);
Var
 I:Byte;
 ChrHori,ChrVert:Char;
 Chr218,Chr192,Chr191,Chr217:Char;
Begin
 TextBackground((Couleur shr 4)and 15);
 {$IFDEF FPC}
  If Couleur and $80=$80 Then Begin
   TextColor((Couleur and 15)+BLINK);
  End
   Else
  TextColor(Couleur and 15);
 {$ELSE}
  TextColor(Couleur and 15);
 {$ENDIF}
 If(ShowASCII128)Then Begin
  ChrHori:='-';
  ChrVert:='|';
  Chr218:='+';
  Chr192:='+';
  Chr191:='+';
  Chr217:='+';
 End
  Else
 Begin
  ChrHori:=#$C4;
  ChrVert:=#$B3;
  Chr218:=#218;
  Chr192:=#192;
  Chr191:=#191;
  Chr217:=#217;
  End;
 For I:=Y1+1 to Y2-1 do Begin
  GotoXY(X1,I);
  Write(ChrVert);
  GotoXY(X2,I);
  Write(ChrVert);
 End;
 GotoXY(X1+1,Y1);
 Write(DuplicateString(ChrHori,X2-X1-1));
 GotoXY(X1+1,Y2);
 Write(DuplicateString(ChrHori,X2-X1-1));
 GotoXY(X1,Y1);
 Write(Chr218);
 GotoXY(X1,Y2);
 Write(Chr192);
 GotoXY(X2,Y1);
 Write(Chr191);
 GotoxY(X2,Y2);
 Write(Chr217);
End;

Procedure DialogBox(X1,Y1,X2,Y2,Couleur:Byte);Begin
 Box(X1,Y1,X2,Y2,Couleur);
 FrameEmpty(X1,Y1,X2,Y2,Couleur);
 TextAttr:=Couleur;
End;

Function ReadLine(Var S:String):Word;
Var
 Rec:SearchRec;
 K:Char;
 X,Y,I:Byte;
 CurrHistory:Integer;
Begin
 ReadLine:=0;
 X:=WhereX;
 Y:=WhereY;
 S:='';
 Repeat
  GotoXY(X,Y);
  Write(S);
  ClrEol;
  K:=ReadKey;
  Case K of
   #0:Case ReadKey of
    #72:Begin
     ReadLine:=kbUp;
     Exit;
    End;
    #80:Begin
     ReadLine:=kbDn;
     Exit;
    End;
   End;
   #8:Begin
    If S<>''Then S:=Copy(S,1,Length(S)-1);
   End;
   #9:Begin
    ReadLine:=kbTab;
    Exit;
   End;
   #13:Begin
    ReadLine:=kbEnter;
   End;
   Else S:=S+K;
  End;
  If S[Length(S)]=#13Then Begin
   S:=Copy(S,1,Length(S)-1);
   K:=#13;
  End;
 Until K=#13;
 GotoXY(X,Y);
 WriteLn(S);
End;

Procedure SetDialogTextColor;Begin
 TextBackground(CurrDialog shr 4);
 TextColor(CurrDialog and$F);
End;

Procedure SetButtonColor;Begin
 TextBackground(7);
 TextColor(0);
End;

Procedure SetSelectedButtonColor;Begin
 TextBackground(7);
 TextColor(13);
End;

Procedure ShowButton(ButtonList:String;PosButton:Byte);
Var
 I,CurrPosButton:Integer;
 First:Boolean;
 CurrButton:String;
Begin
 CurrButton:='';
 First:=True;
 CurrPosButton:=0;
 For I:=1 to Length(ButtonList)do Begin
  If ButtonList[I]='|'Then Begin
   SetDialogTextColor;
   If Not(First)Then Write('  ');
   If(PosButton=CurrPosButton)Then SetSelectedButtonColor
                              Else SetButtonColor;
   Write('  ',CurrButton,'  ');
   SetDialogTextColor;
   CurrButton:='';
   First:=False;
   Inc(CurrPosButton);
  End
   Else
  CurrButton:=CurrButton+ButtonList[I];
 End;
 If Not(First)Then Write('  ');
 If(PosButton=CurrPosButton)Then SetSelectedButtonColor
                            Else SetButtonColor;
 Write('  ',CurrButton,'  ');
End;

Function LengthButton(ButtonList:String):Integer;
Var
 I,CurrPosButton,LenButton:Integer;
 First:Boolean;
 CurrButton:String;
Begin
 LengthButton:=0;
 LenButton:=0;
 CurrButton:='';
 First:=True;
 CurrPosButton:=0;
 For I:=1 to Length(ButtonList)do Begin
  If ButtonList[I]='|'Then Begin
   If Not(First)Then Inc(LenButton,Length('  '));
   Inc(LenButton,Length('  '+CurrButton+'  '));
   CurrButton:='';
   First:=False;
   Inc(CurrPosButton);
  End
   Else
  CurrButton:=CurrButton+ButtonList[I];
 End;
 If Not(First)Then Inc(LenButton,Length('  '));
 Inc(LenButton,Length('  '+CurrButton+'  '));
 LengthButton:=LenButton;
End;

Function ReadHorizontalButton(ButtonList:String):Word;
Var
 X,Y:Byte;
 K:Char;
 I,NumButton,CurrButton:Integer;
Begin
 CurrDialog:=TextAttr;
 CursorOff;
 ReadHorizontalButton:=kbEsc;
 CurrButton:=0;
 NumButton:=1;
 X:=WhereX;
 Y:=WhereY;
 For I:=1 to Length(ButtonList)do If ButtonList[I]='|'Then Inc(NumButton);
 ShowButton(ButtonList,0);
 Repeat
  K:=ReadKey;
  Case K of
   #0:Case ReadKey of
    #15:Begin { Shift+Tab }
     If(CurrButton>0)Then Begin
      Dec(CurrButton);
      GotoXY(X,Y);
      ShowButton(ButtonList,CurrButton);
     End
      Else
     Begin
      ReadHorizontalButton:=kbShiftTab;
      Break;
     End;
    End;
    #75:Begin { Gauche }
     If(CurrButton>0)Then Dec(CurrButton)
                     Else CurrButton:=NumButton-1;
     GotoXY(X,Y);
     ShowButton(ButtonList,CurrButton);
    End;
    #77:Begin { Droite }
     If(CurrButton+1>=NumButton)Then CurrButton:=0
                                Else Inc(CurrButton);
     GotoXY(X,Y);
     ShowButton(ButtonList,CurrButton);
    End;
   End;
   #9:Begin
    If(CurrButton+1>=NumButton)Then Begin
     ReadHorizontalButton:=kbTab;
     Break;
    End
     Else
    Begin
     Inc(CurrButton);
     GotoXY(X,Y);
     ShowButton(ButtonList,CurrButton);
    End;
   End;
   #13:ReadHorizontalButton:=CurrButton;
   #27:ReadHorizontalButton:=kbEsc;
  End;
 Until K in[#13,#27];
 SetDialogTextColor;
 CursorOn;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 ShowASCII128:=False;
 CurrDialog:=TextAttr;
END.
