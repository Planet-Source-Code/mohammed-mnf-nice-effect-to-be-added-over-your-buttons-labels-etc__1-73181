VERSION 5.00
Begin VB.UserControl RgheedButton 
   AutoRedraw      =   -1  'True
   ClientHeight    =   660
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3135
   KeyPreview      =   -1  'True
   ScaleHeight     =   44
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   209
   Begin VB.Timer tmr 
      Interval        =   20
      Left            =   0
      Top             =   0
   End
End
Attribute VB_Name = "RgheedButton"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit


' -----------------------------------------------

Private Declare Function GetSysColor Lib "user32" (ByVal nIndex As Long) As Long
Private Declare Function RoundRect Lib "gdi32" (ByVal hDC As Long, ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long, ByVal X3 As Long, ByVal Y3 As Long) As Long
Private Declare Function CreateRoundRectRgn Lib "gdi32" (ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long, ByVal X3 As Long, ByVal Y3 As Long) As Long
Private Declare Function SetWindowRgn Lib "user32" (ByVal hwnd As Long, ByVal hRgn As Long, ByVal bRedraw As Boolean) As Long
Private Declare Function WindowFromPoint Lib "user32" (ByVal xPoint As Long, ByVal yPoint As Long) As Long
Private Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long
Private Declare Function SetCapture Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function DrawTextEx Lib "user32" Alias "DrawTextExA" (ByVal hDC As Long, ByVal lpsz As String, ByVal N As Long, lpRect As RECT, ByVal un As Long, lpDrawTextParams As DRAWTEXTPARAMS) As Long
Private Declare Function DrawStateText Lib "user32" Alias "DrawStateA" (ByVal hDC As Long, ByVal hBrush As Long, ByVal lpDrawStateProc As Long, ByVal lParam As String, ByVal wParam As Long, ByVal n1 As Long, ByVal n2 As Long, ByVal n3 As Long, ByVal n4 As Long, ByVal un As Long) As Long

Dim Hgt As Long
Dim Wdt As Long

Private Type RECT
    Left As Long
    Top As Long
    Right As Long
    Bottom As Long
End Type

Private Type POINTAPI
    X As Long
    Y As Long
End Type

Private Enum ButtonStateConstants
    btnNone = 0
    btnPressed = 1
    btnMouseOver = 2
End Enum

Private Type DRAWTEXTPARAMS
    cbSize As Long
    iTabLength As Long
    iLeftMargin As Long
    iRightMargin As Long
    uiLengthDrawn As Long
End Type

Private Const DT_WORDBREAK = &H10
Private Const DT_CALCRECT = &H400
Private Const DT_VCENTER = &H4
Private Const DT_CENTER = &H1

Event Click()
Event KeyDown(KeyCode As Integer, Shift As Integer)
Event KeyPress(KeyAscii As Integer)
Event KeyUp(KeyCode As Integer, Shift As Integer)
Event MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Event MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Event MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)


Dim MosButton As Integer
Dim IsFocused As Boolean
Dim MosShift  As Integer
Dim mCaption  As String
Dim State     As ButtonStateConstants
Dim MosX      As Single
Dim MosY      As Single

Dim UpdateColor As Boolean
'Default Property Values:
Const m_def_FocusColor = vbBlue
'Property Variables:
Dim m_FocusColor As OLE_COLOR


Private Sub DrawMyButton()
    Dim Max As Single
    Dim Pos As Integer
    Dim Clr As Long
    Dim Sd1 As Long
    Dim Sd2 As Long
    Dim Sd3 As Long
    Dim Sd4 As Long
    Dim Fre As Long
    
  'max value
    Max = Abs(50 / (Hgt + 0.00001))
      
  'based on state give color
    Select Case State
     Case btnNone:
             Clr = GetColor(GetRightColor(BackColor), -20)
             Sd1 = GetColor(Clr, -10)
             Sd2 = GetColor(Clr, -5)
             Sd3 = GetColor(Clr, 60)
             Sd4 = GetColor(Clr, 55)
           ' ------------------------------------------------
     Case btnMouseOver:
             Clr = GetColor(GetRightColor(BackColor), -35)
             Sd1 = GetColor(Clr, -10)
             Sd2 = GetColor(Clr, -5)
             Sd3 = GetColor(Clr, 60)
             Sd4 = GetColor(Clr, 55)
           ' ------------------------------------------------
     Case btnPressed:
             Clr = GetColor(GetRightColor(BackColor), 40)
             Sd1 = GetColor(Clr, 25)
             Sd2 = GetColor(Clr, 12)
             Sd3 = GetColor(Clr, -10)
             Sd4 = GetColor(Clr, -5)
             Max = -Max
           ' ------------------------------------------------
    End Select
    
  ' Gradient effect
    For Pos = 1 To Hgt - 1
        Line (1, Pos)-(Wdt - 1, Pos), GetColor(Clr, Pos * Max)
    Next Pos
    
  ' graphing the edges
    Line (2, 1)-(Wdt - 2, 1), Sd1
    Line (2, 2)-(Wdt - 2, 2), Sd2
    Line (1, 2)-(1, Hgt - 2), Sd1
    Line (2, 2)-(2, Hgt - 2), Sd2
    Line (2, Hgt - 2)-(Wdt - 2, Hgt - 2), Sd3
    Line (2, Hgt - 3)-(Wdt - 2, Hgt - 3), Sd4
    Line (Wdt - 2, 2)-(Wdt - 2, Hgt - 2), Sd3
    Line (Wdt - 3, 2)-(Wdt - 3, Hgt - 2), Sd4
    
  ' save current color and then changing it
    UpdateColor = False
    Fre = Me.ForeColor
    Me.ForeColor = vbBlack
    
  ' rounding the edges
    RoundRect hDC, 0, 0, Wdt, Hgt, 5, 5
    
  ' regaining the original color
    Me.ForeColor = Fre
    UpdateColor = True
    
 	'writing on the button
    PrintCaption State
    
  '
    If IsFocused Then
       Dim C As Long
       
       C = UserControl.ForeColor
       UserControl.ForeColor = m_FocusColor
       RoundRect UserControl.hDC, 3, 3, Wdt - 3, Hgt - 3, 3, 3
       UserControl.DrawWidth = 1
       UserControl.ForeColor = C
    End If
End Sub

Private Sub PrintCaption(State As ButtonStateConstants)
    Dim RC As RECT
    Dim R2 As RECT
    Dim TP As DRAWTEXTPARAMS
    Dim Ht As Integer
    Dim Wt As Integer
    Dim Pr As Integer
    Dim En As Long
    
  ' assumptional values
    RC.Left = 1: RC.Top = 0: RC.Right = Wdt: RC.Bottom = Hgt
    TP.iTabLength = 1: TP.iLeftMargin = 1: TP.iRightMargin = 1: TP.cbSize = Len(TP)

  ' knowing the area for the button
    DrawTextEx hDC, mCaption, Len(Caption), RC, DT_CALCRECT + DT_CENTER + DT_VCENTER + DT_WORDBREAK, TP
    
  ' width and hight of the writting
    Wt = RC.Right - RC.Left
    Ht = RC.Bottom - RC.Top
    
  ' knowing the required area
    Pr = IIf(State = btnPressed, 1, 0)
    RC.Left = RC.Left + (Wdt - Wt - 1) \ 2 + Pr
    RC.Top = RC.Top + (Hgt - Ht - 1) \ 2 + Pr
    RC.Right = RC.Left + Wt + Pr
    RC.Bottom = RC.Top + Ht + Pr
    
  ' writing on the button
    If Not Me.Enabled Then En = 32
    DrawStateText UserControl.hDC, 0, 0, mCaption, Len(mCaption), RC.Left, RC.Top, 0, 0, En + 2
End Sub

Private Function GetColor(ByVal Clr As Long, ByVal Z As Integer)
    Dim R As Integer
    Dim B As Integer
    Dim G As Integer
    
  ' knowing the colors
    GetRGB R, G, B, Clr
    
  ' reducing the value
    B = B - Z
    G = G - Z
    R = R - Z
    
  ' defining the brders
    If R < 0 Then R = 0: If R > 255 Then R = 255
    If B < 0 Then B = 0: If B > 255 Then B = 255
    If G < 0 Then G = 0: If G > 255 Then G = 255
    
  ' Çregaining the color after adjusting
    GetColor = RGB(R, G, B)
End Function

Private Function GetRightColor(Clr As Long) As Long
    If Clr > vbWhite Or Clr < 0 Then
       GetRightColor = GetSysColor(Clr And vbWhite)
    Else
       GetRightColor = Clr
    End If
End Function

Private Sub GetRGB(R As Integer, G As Integer, B As Integer, ByVal Clr As Long)
    Dim TMP As Long
    
  ' temporary values.
    Const Total = 256
    TMP = Clr \ Total
    
  ' Çknowing the basic values for the colors
    R = Clr Mod Total
    G = TMP Mod Total
    B = TMP \ Total
End Sub

Public Property Get BackColor() As OLE_COLOR
Attribute BackColor.VB_ProcData.VB_Invoke_Property = ";*-Rgheed"
    BackColor = UserControl.BackColor
End Property

Public Property Let BackColor(ByVal New_BackColor As OLE_COLOR)
    UserControl.BackColor() = New_BackColor
    PropertyChanged "BackColor"
    DrawMyButton
End Property

Public Property Get ForeColor() As OLE_COLOR
Attribute ForeColor.VB_ProcData.VB_Invoke_Property = ";*-Rgheed"
    ForeColor = UserControl.ForeColor
End Property

Public Property Let ForeColor(ByVal New_ForeColor As OLE_COLOR)
    UserControl.ForeColor() = New_ForeColor
    PropertyChanged "ForeColor"
    
    If UpdateColor Then DrawMyButton
End Property

Public Property Get Enabled() As Boolean
    Enabled = UserControl.Enabled
End Property

Public Property Let Enabled(ByVal New_Enabled As Boolean)
    UserControl.Enabled() = New_Enabled
    PropertyChanged "Enabled"
    DrawMyButton
End Property

Public Property Get Font() As Font
    Set Font = UserControl.Font
End Property

Public Property Set Font(ByVal New_Font As Font)
    Set UserControl.Font = New_Font
    PropertyChanged "Font"
    DrawMyButton
End Property

Private Sub tmr_Timer()
    Dim H As Long
    Dim P As POINTAPI
    
    On Error Resume Next
  ' if stil in design process do not check
    If Not UserControl.Ambient.UserMode Then Exit Sub
    
  ' where is the mouse
    Call GetCursorPos(P)
    H = WindowFromPoint(P.X, P.Y)
    
  ' if the mouse is slightly above the button slightly chnge color
    If H <> hwnd And State = btnMouseOver Then
       State = btnNone
       DrawMyButton
    ElseIf H = hwnd And State <> btnMouseOver Then
       State = btnMouseOver
       DrawMyButton
    End If
End Sub

Private Sub UserControl_Click()
    RaiseEvent Click
End Sub

Private Sub UserControl_DblClick()
    SetCapture hwnd
    Call UserControl_MouseDown(MosButton, MosShift, MosX, MosY)
End Sub

Private Sub UserControl_GotFocus()
    IsFocused = True
    DrawMyButton
End Sub

Private Sub UserControl_Initialize()
    UpdateColor = True
    DrawMyButton
End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
    RaiseEvent KeyDown(KeyCode, Shift)
    If KeyCode = 13 Then RaiseEvent Click
End Sub

Private Sub UserControl_KeyPress(KeyAscii As Integer)
    RaiseEvent KeyPress(KeyAscii)
End Sub

Private Sub UserControl_KeyUp(KeyCode As Integer, Shift As Integer)
    RaiseEvent KeyUp(KeyCode, Shift)
End Sub

Private Sub UserControl_LostFocus()
    IsFocused = False
    DrawMyButton
End Sub

Private Sub UserControl_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    
    tmr = False
    If UserControl.Ambient.UserMode And Button = 1 Then
       IsFocused = True
       State = btnPressed
       DrawMyButton
    End If
    
    MosButton = Button
    MosShift = Shift
    MosX = X
    MosY = Y
    
    RaiseEvent MouseDown(Button, Shift, X, Y)
End Sub

Private Sub UserControl_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    RaiseEvent MouseMove(Button, Shift, X, Y)
End Sub

Private Sub UserControl_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If UserControl.Ambient.UserMode Then
       State = btnMouseOver
       DrawMyButton
       tmr = True
    End If
    RaiseEvent MouseUp(Button, Shift, X, Y)
End Sub

Private Sub UserControl_InitProperties()
    Set UserControl.Font = Ambient.Font
    m_FocusColor = m_def_FocusColor
End Sub

Private Sub UserControl_Paint()
    DrawMyButton
End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)

    UserControl.BackColor = PropBag.ReadProperty("BackColor", &H8000000F)
    UserControl.ForeColor = PropBag.ReadProperty("ForeColor", &H80000012)
    UserControl.Enabled = PropBag.ReadProperty("Enabled", True)
    Set UserControl.Font = PropBag.ReadProperty("Font", Ambient.Font)
    mCaption = PropBag.ReadProperty("Caption", "Original design Ragheed Al Tayeb, Comment translation Mohammed MNF")
    Set MouseIcon = PropBag.ReadProperty("MouseIcon", Nothing)
    UserControl.MousePointer = PropBag.ReadProperty("MousePointer", 0)
    m_FocusColor = PropBag.ReadProperty("FocusColor", m_def_FocusColor)
End Sub

Private Sub UserControl_Resize()
    Dim Rgn As Long
        
  ' knowing the new size of the button
    Hgt = UserControl.ScaleHeight - 1
    Wdt = UserControl.ScaleWidth - 1
    
  ' making the rounded edges opaque
    Rgn = CreateRoundRectRgn(0, 0, Wdt + 1, Hgt + 1, 4, 4)
    Call SetWindowRgn(hwnd, Rgn, True)
    
  ' drafting the button in its original state
    DrawMyButton
End Sub

Private Sub UserControl_Show()
  ' knowing the size of the button
    Hgt = UserControl.ScaleHeight - 1
    Wdt = UserControl.ScaleWidth - 1
    
  ' sketching the button in its original state
    DrawMyButton
    tmr = UserControl.Ambient.UserMode
End Sub

Private Sub UserControl_WriteProperties(PropBag As PropertyBag)

    Call PropBag.WriteProperty("BackColor", UserControl.BackColor, &H8000000F)
    Call PropBag.WriteProperty("ForeColor", UserControl.ForeColor, &H80000012)
    Call PropBag.WriteProperty("Enabled", UserControl.Enabled, True)
    Call PropBag.WriteProperty("Font", UserControl.Font, Ambient.Font)
    Call PropBag.WriteProperty("Caption", mCaption, "ÑÛíÏ ÇáØíÈ")
    Call PropBag.WriteProperty("MouseIcon", MouseIcon, Nothing)
    Call PropBag.WriteProperty("MousePointer", UserControl.MousePointer, 0)
    Call PropBag.WriteProperty("FocusColor", m_FocusColor, m_def_FocusColor)
End Sub

Public Property Get Caption() As String
Attribute Caption.VB_ProcData.VB_Invoke_Property = ";*-Rgheed"
    Caption = mCaption
End Property

Public Property Let Caption(ByVal New_Caption As String)
    mCaption = New_Caption
    PropertyChanged "Caption"
    
    DrawMyButton
End Property

Public Property Get MouseIcon() As Picture
    Set MouseIcon = UserControl.MouseIcon
End Property

Public Property Set MouseIcon(ByVal New_MouseIcon As Picture)
    Set UserControl.MouseIcon = New_MouseIcon
    PropertyChanged "MouseIcon"
End Property

Public Property Get MousePointer() As MousePointerConstants
    MousePointer = UserControl.MousePointer
End Property

Public Property Let MousePointer(ByVal New_MousePointer As MousePointerConstants)
    UserControl.MousePointer() = New_MousePointer
    PropertyChanged "MousePointer"
End Property

Public Property Get FocusColor() As OLE_COLOR
Attribute FocusColor.VB_ProcData.VB_Invoke_Property = ";*-Rgheed"
    FocusColor = m_FocusColor
End Property

Public Property Let FocusColor(ByVal New_FocusColor As OLE_COLOR)
    m_FocusColor = New_FocusColor
    PropertyChanged "FocusColor"
End Property

Sub SetFocus()
    Me.SetFocus
End Sub

