object FSort: TFSort
  Left = 300
  Top = 124
  Width = 291
  Height = 107
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object LSorted: TLabel
    Left = 0
    Top = 55
    Width = 283
    Height = 25
    Align = alBottom
    Alignment = taCenter
    AutoSize = False
  end
  object EArray: TEdit
    Left = 8
    Top = 8
    Width = 185
    Height = 21
    TabOrder = 0
  end
  object BSort: TButton
    Left = 200
    Top = 8
    Width = 75
    Height = 25
    Caption = #1057#1086#1088#1090#1080#1088#1086#1074#1082#1072
    TabOrder = 1
    OnClick = BSortClick
  end
end
