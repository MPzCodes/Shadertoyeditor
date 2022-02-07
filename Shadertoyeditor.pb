;/ GLSL example to test new OpenGLGadget - PJ 06/2014.
; Updated and adapted to test shaders from Shadertoy.com
; Mpz Jan 2022
;
; Version 0.01.02 - 07.02.2022
; 
; Changelog: Work now with RASPberry PI

EnableExplicit

Enumeration ;/ Window
  #Window_Main
EndEnumeration
Enumeration ;/ Gadget
  #Gad_OpenGL
  #Gad_Editor
  #Gad_ShaderSelector_Combo
EndEnumeration
Enumeration ;/ Menu
  #Menu_Open
  #Menu_Save
  #Menu_Texturload
  #Menu_Run
EndEnumeration


Structure System
  Width.i
  Height.i
  Shader_Width.i
  Shader_Height.i
  Event.i
  Exit.i
  MouseX.i
  MouseY.i
  MouseZ.i
  MouseW.i
  Key.i
  App_CurrentTime.i
  App_StartTime.i
  Editor_LastText.s
  
  Shader_Vertex_Text.s
  Shader_Fragment_Text.s
  Shader_Vertex.i
  Shader_Fragment.i
  Shader_Program.i
  
  Shader_Uniform_iTime.i
  Shader_Uniform_iDate.i
  Shader_Uniform_iFrame.i
  Shader_Uniform_Resolution.i
  Shader_Uniform_iMouse.i
  Shader_Uniform_iKey.i
  Shader_Uniform_SurfacePosition.i
  Shader_Uniform_Texture.i
  
  FPS_Timer.i
  Frames.i
  FPS.i
EndStructure

Global System.System, Texture.i, Title.s, buttondown, buttonoff, key

Title = "Shadereditor to use Shaders from www.shadertoy.com, greetings MPz - FPS: "


Procedure Init_Main()
  Protected MyLoop.i
  
  System\Width.i = 1120
  System\Height = 480
  System\Shader_Width = 640
  System\Shader_Height = 480
  
  OpenWindow(#Window_Main,0,0,System\Width,System\Height,"",#PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
  
  If CreateMenu(0, WindowID(#Window_Main))
    MenuTitle("File")
    MenuItem(#Menu_Open,"Open")
    MenuItem(#Menu_Save,"Save")
    MenuItem(#Menu_Texturload,"Load Texture")
    MenuBar()
    MenuItem(#Menu_Run,"Run Shader")
    
  EndIf
  
  OpenGLGadget(#Gad_OpenGL,0,0,System\Shader_Width,System\Shader_Height,#PB_OpenGL_Keyboard)
  ComboBoxGadget(#Gad_ShaderSelector_Combo,System\Shader_Width+4,2,System\Width - (System\Shader_Width+8),24)
  AddGadgetItem(#Gad_ShaderSelector_Combo,-1,"Shader: "+Str(1)) 
  AddGadgetItem(#Gad_ShaderSelector_Combo,-1,"Shader: "+Str(2)) 
  AddGadgetItem(#Gad_ShaderSelector_Combo,-1,"FreeShader: "+Str(3)) 
  
  SetGadgetState(#Gad_ShaderSelector_Combo,0)
  EditorGadget(#Gad_Editor,System\Shader_Width+4,30,System\Width - (System\Shader_Width+8),System\Height-30)
  
  System\App_StartTime = ElapsedMilliseconds()
  
  If #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64
    System\Shader_Vertex_Text = "#version 330"+Chr(10)
  Else                                                                ; Oh it must be a RASPI 
    System\Shader_Vertex_Text = "#version 300 es"+Chr(10)
  EndIf  
  System\Shader_Vertex_Text + "precision mediump float;"+Chr(10) 
  System\Shader_Vertex_Text + "in vec3 position;"+Chr(10)
  System\Shader_Vertex_Text + " void main() {"+Chr(10)
  System\Shader_Vertex_Text + " gl_Position = vec4( position, 1.0 );"+Chr(10)
  System\Shader_Vertex_Text + " };"+Chr(10)

  ;System\Shader_Vertex_Text + "attribute vec3 position;" ; Alternate code works good with linux
  ;System\Shader_Vertex_Text + "attribute vec2 surfacePosAttrib;"
  ;System\Shader_Vertex_Text + "varying vec2 surfacePosition;"
  ;System\Shader_Vertex_Text + "	void main() {"
  ;System\Shader_Vertex_Text + "		surfacePosition = surfacePosAttrib;"
  ;System\Shader_Vertex_Text + "		gl_Position = vec4( position, 1.0 );"
  ;System\Shader_Vertex_Text + "	}"
  
  
EndProcedure

Init_Main()

;{ Opengl shader setup & routines

#GL_VERTEX_SHADER = $8B31
#GL_FRAGMENT_SHADER = $8B30

CompilerIf #PB_Compiler_OS = #PB_OS_MacOS

  ImportC "-framework OpenGL"
    glCreateShader(type.l) As "_glCreateShader" 
    glCreateProgram() As "_glCreateProgram"
    glDeleteShader(shader.l) As "_glDeleteShader"
    glCompileShader(shader.l) As  "_glCompileShader"
    glLinkProgram(shader.l) As "_glLinkProgram" 
    glUseProgram(shader.l) As "_glUseProgram" 
    glAttachShader(Program.l, shader.l) As  "_glAttachShader"
    glShaderSource(shader.l, numOfStrings.l, *strings, *lenOfStrings) As  "_glShaderSource"
    glGetUniformLocation(Program.i, name.p-ascii) As  "_glGetUniformLocation"
    glUniform1i(location.i, v0.i) As "_glUniform1i"
    glUniform2i(location.i, v0.i, v1.i) As  "_glUniform2i"
    glUniform1f(location.i, v0.f) As  "_glUniform1f"
    glUniform1d(location.i, v0.d) As  "_glUniform1d"
    glUniform2f(location.i, v0.f, v1.f) As  "_glUniform2f"
    glUniform4f(location.i, v0.f, v1.f, v2.f, v3.f) As  "_glUniform4f"
    glUniform2d(location.i, v0.d, v1.d) As  "_glUniform2d"
    glGetShaderInfoLog(shader.i, bufSize.l, *length_l, *infoLog) As  "_glGetShaderInfoLog"
  EndImport
  
CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
  
  ImportC "-lGL"
    glCreateShader(type.l)
    glCreateProgram()
    glDeleteShader(shader.l)
    glCompileShader(shader.l)
    glLinkProgram(shader.l)
    glUseProgram(shader.l)
    glAttachShader(Program.l, shader.l)
    glShaderSource(shader.l, numOfStrings.l, *strings, *lenOfStrings) : 
    glGetUniformLocation(Program.i, name.p-ascii)
    glUniform1i(location.i, v0.i)
    glUniform2i(location.i, v0.i, v1.i)
    glUniform1f(location.i, v0.f)
    glUniform1d(location.i, v0.d)
    glUniform4f(location.i, v0.f, v1.f, v2.f, v3.f)
    glUniform2f(location.i, v0.f, v1.f)
    glUniform2d(location.i, v0.d, v1.d)
    glGetShaderInfoLog(shader.i, bufSize.l, *length_l, *infoLog)
  EndImport


CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
  
   Prototype glCreateShader(type.l)
   Prototype glCreateProgram()
   Prototype glDeleteShader(shader.l)
   Prototype glCompileShader(shader.l)
   Prototype glLinkProgram(shader.l)
   Prototype glUseProgram(shader.l)
   Prototype glAttachShader(Program.l, shader.l)
   Prototype glShaderSource(shader.l, numOfStrings.l, *strings, *lenOfStrings) : 
   Prototype glGetUniformLocation(Program.i, name.p-ascii)
   Prototype glUniform1i(location.i, v0.i)
   Prototype glUniform2i(location.i, v0.i, v1.i)
   Prototype glUniform1f(location.i, v0.f)
   Prototype glUniform1d(location.i, v0.d)
   Prototype glUniform4f(location.i, v0.f, v1.f, v2.f, v3.f)
   Prototype glUniform2f(location.i, v0.f, v1.f)
   Prototype glUniform2d(location.i, v0.d, v1.d)
   Prototype glGetShaderInfoLog(shader.i, bufSize.l, *length_l, *infoLog)
   Global glCreateShader.glCreateShader             = wglGetProcAddress_("glCreateShader")
   Global glCreateProgram.glCreateProgram           = wglGetProcAddress_("glCreateProgram")
   Global glDeleteShader.glDeleteShader             = wglGetProcAddress_("glDeleteShader")
   Global glCompileShader.glCompileShader           = wglGetProcAddress_("glCompileShader")
   Global glLinkProgram.glLinkProgram               = wglGetProcAddress_("glLinkProgram")
   Global glUseProgram.glUseProgram                 = wglGetProcAddress_("glUseProgram")
   Global glAttachShader.glAttachShader             = wglGetProcAddress_("glAttachShader")
   Global glShaderSource.glShaderSource             = wglGetProcAddress_("glShaderSource")
   Global glGetUniformLocation.glGetUniformLocation = wglGetProcAddress_("glGetUniformLocation")
   Global glUniform1i.glUniform1i                   = wglGetProcAddress_("glUniform1i")
   Global glUniform2i.glUniform2i                   = wglGetProcAddress_("glUniform2i")
   Global glUniform1f.glUniform1f                   = wglGetProcAddress_("glUniform1f")
   Global glUniform1d.glUniform1d                   = wglGetProcAddress_("glUniform1d")
   Global glUniform4f.glUniform4f                   = wglGetProcAddress_("glUniform4f")
   Global glUniform2f.glUniform2f                   = wglGetProcAddress_("glUniform2f")
   Global glUniform2d.glUniform2d                   = wglGetProcAddress_("glUniform2d")
   Global glGetShaderInfoLog.glGetShaderInfoLog     = wglGetProcAddress_("glGetShaderInfoLog")

CompilerEndIf

Procedure LoadGLTextures(Names.s)
  Protected *pointer, TextureID.i, FrameBufferID.i
  
  LoadImage(0, Names) ; Load texture with name
  *pointer = EncodeImage(0, #PB_ImagePlugin_BMP,0,24);  
  FreeImage(0)
  
  ; ----- Generate texture
  glGenTextures_(1, @TextureID.i)
  glBindTexture_(#GL_TEXTURE_2D, TextureID)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MIN_FILTER, #GL_LINEAR)
  glTexParameteri_(#GL_TEXTURE_2D, #GL_TEXTURE_MAG_FILTER, #GL_LINEAR)
  glTexImage2D_(#GL_TEXTURE_2D, 0, 3,  PeekL(*pointer+18),  PeekL(*pointer+22), 0, #GL_BGR_EXT, #GL_UNSIGNED_BYTE,  *pointer+54);
  FreeMemory(*pointer)
  ProcedureReturn TextureID

EndProcedure


Global Texture.i = LoadGLTextures(#PB_Compiler_Home + "examples/3d/Data/Textures/Geebee2.bmp")
Debug Texture

Procedure Shader_Compile_Link_Use(Vertex.s,Fragment.s,Use.i=1)
  Protected VertShader.i, FragShader.i, *TxtPointer, Program.i
  Protected Textlength.i, Mytext.s = Space(1024), info.s, info2.s
  
  ;/ Compile Vertex shader
  VertShader.i = glCreateShader(#GL_VERTEX_SHADER)
  *TxtPointer = Ascii(Vertex)
  glShaderSource(VertShader, 1, @*TxtPointer, #Null)
  glCompileShader(VertShader)
  glGetShaderInfoLog(VertShader,1023,@Textlength,@Mytext)
  Debug "VertexShader: "+PeekS(@Mytext,1023,#PB_Ascii)
  info.s = PeekS(@Mytext,1023,#PB_Ascii)
  If info : info.s = "VertexShader: "+info.s+Chr(10) : EndIf
  
  ;/ Compile Fragment Shader
  FragShader.i = glCreateShader(#GL_FRAGMENT_SHADER)
  *TxtPointer = Ascii(Fragment)
  glShaderSource(FragShader, 1, @*TxtPointer, #Null)
  glCompileShader(FragShader)
  glGetShaderInfoLog(FragShader,1023,@Textlength,@Mytext)
  Debug "FragmentShader: "+PeekS(@Mytext,1023,#PB_Ascii)
  info2.s = PeekS(@Mytext,1023,#PB_Ascii)
  If info2 : info2.s = "FragmentShader: "+info2.s : info = info + info2 : EndIf
  If info : MessageRequester("Shaderinfo", info) : EndIf 
  
  ;/ Create Shader Program
  Program = glCreateProgram()
  glAttachShader(Program,VertShader)
  glAttachShader(Program,FragShader)
  glLinkProgram(Program)
  
  If Use = 1
    glUseProgram(Program)
  EndIf
  
  ProcedureReturn Program  
EndProcedure
;}

Procedure Shader_Set(Fragment.i, shader$="")
  
  If System\Shader_Program <> 0 ;/ delete the previous shaders
    glUseProgram(0);
  EndIf
  
  If Fragment = -2 ; run the shader    
    System\Shader_Fragment_Text = GetGadgetText(#Gad_Editor)    
  ElseIf Fragment = -1 ; load the shader
      System\Shader_Fragment_Text = shader$+Chr(10)
  Else
    
   Select Fragment
     Case 0
       
      If #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64
         System\Shader_Fragment_Text = "#version 330"+Chr(10)
      Else                                                                ; Oh it must be a RASPI 
         System\Shader_Fragment_Text = "#version 300 es"+Chr(10)
      EndIf  
      System\Shader_Fragment_Text + "precision mediump float;"+Chr(10)
      System\Shader_Fragment_Text + "uniform float iTime;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec2 iResolution;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec4 iMouse;"+Chr(10)
      System\Shader_Fragment_Text + "out vec4 fragColor;"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "void main( void ) {"+Chr(10)
      System\Shader_Fragment_Text + "	 vec2  fragCoord = gl_FragCoord.xy;"+Chr(10)
      System\Shader_Fragment_Text + "	 vec2 p = ( fragCoord.xy / iResolution.xy ) - 0.2;"+Chr(10)
      System\Shader_Fragment_Text + "	 float sx = 0.3 * (p.x + 0.8) * sin( 3.0 * p.x - 1. * iTime);"+Chr(10)
      System\Shader_Fragment_Text + "	 float dy = 4./ ( 123. * abs(p.y - sx));"+Chr(10)
      System\Shader_Fragment_Text + "	 dy += 1./ (160. * length(p - vec2(p.x, 0.)));"+Chr(10)
      System\Shader_Fragment_Text + "	 fragColor = vec4( (p.x + 0.1) * dy, 0.3 * dy, dy, 2.1 );"+Chr(10)
      System\Shader_Fragment_Text + "}"+Chr(10)
      
    Case 1
  
      If #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64
         System\Shader_Fragment_Text = "#version 330"+Chr(10)
      Else                                                                ; Oh it must be a RASPI 
         System\Shader_Fragment_Text = "#version 300 es"+Chr(10)
      EndIf 
      System\Shader_Fragment_Text + "precision mediump float;"+Chr(10)
      System\Shader_Fragment_Text + "uniform float iTime;"+Chr(10)
      System\Shader_Fragment_Text + "uniform int iFrame;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec2 iResolution;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec4 iMouse;"+Chr(10)
      System\Shader_Fragment_Text + "out vec4 fragColor;"+Chr(10)
      System\Shader_Fragment_Text + "uniform sampler2D iChannel0;"+Chr(10)
      System\Shader_Fragment_Text + "#define fragCoord gl_FragCoord.xy"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "void main( void ) {"+Chr(10)
      System\Shader_Fragment_Text + "	 fragColor =  texture(iChannel0, fragCoord/iResolution+iTime/4.0);"+Chr(10)
      System\Shader_Fragment_Text + "}"+Chr(10)   
      
    Case 2
      
      If #PB_Compiler_Processor = #PB_Processor_x86 Or #PB_Compiler_Processor = #PB_Processor_x64
         System\Shader_Fragment_Text = "#version 330"+Chr(10)
      Else                                                                ; Oh it must be a RASPI 
         System\Shader_Fragment_Text = "#version 300 es"+Chr(10)
      EndIf 
      System\Shader_Fragment_Text + "precision mediump float;"+Chr(10)
      System\Shader_Fragment_Text + "uniform float iTime;"+Chr(10)
      System\Shader_Fragment_Text + "uniform float iDate;"+Chr(10)
      System\Shader_Fragment_Text + "uniform int iFrame;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec2 iResolution;"+Chr(10)
      System\Shader_Fragment_Text + "uniform vec4 iMouse;"+Chr(10)
      System\Shader_Fragment_Text + "uniform float iKey;"+Chr(10)
      System\Shader_Fragment_Text + "out vec4 fragColor;"+Chr(10)
      System\Shader_Fragment_Text + "uniform sampler2D iChannel0;"+Chr(10)
      System\Shader_Fragment_Text + "#define fragCoord gl_FragCoord.xy"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "// how to use: copy the shader from www.shadertoy.com in this text editor"+Chr(10)
      System\Shader_Fragment_Text + "// the text #version ...to... iChannel0; must stay before the shader script"+Chr(10)
      System\Shader_Fragment_Text + "// now you search the following lines in the shader"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "void mainImage( out vec4 fragColor, in vec2 fragCoord )"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "// This must be replaces with the following line"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "void main( void )"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      System\Shader_Fragment_Text + "// if you are ready start the <Run Shader> function in the Menu"+Chr(10)
      System\Shader_Fragment_Text + ""+Chr(10)
      
  EndSelect
  
  EndIf

  System\Shader_Program = Shader_Compile_Link_Use(System\Shader_Vertex_Text,System\Shader_Fragment_Text)
  
  If System\Shader_Program = 0
    MessageRequester("Unsupported Device?","No Shader Support Available",#PB_MessageRequester_Ok)
  EndIf
  
  ;/ store shader uniform locations
  Debug "Shader: "+System\Shader_Program
  System\Shader_Uniform_iTime = glGetUniformLocation(System\Shader_Program, "iTime")
  System\Shader_Uniform_iDate = glGetUniformLocation(System\Shader_Program, "iDate")
  System\Shader_Uniform_iFrame = glGetUniformLocation(System\Shader_Program, "iFrame")
  System\Shader_Uniform_iMouse = glGetUniformLocation(System\Shader_Program, "iMouse")
  System\Shader_Uniform_iKey = glGetUniformLocation(System\Shader_Program, "iKey")
  System\Shader_Uniform_Texture = glGetUniformLocation(System\Shader_Program, "iChannel0")
  System\Shader_Uniform_Resolution = glGetUniformLocation(System\Shader_Program, "iResolution")
  System\Shader_Uniform_SurfacePosition = glGetUniformLocation(System\Shader_Program, "surfacePosition")
  Debug "Time location: "+System\Shader_Uniform_iTime
  Debug "Date location: "+System\Shader_Uniform_iDate
  Debug "Mouse location: "+System\Shader_Uniform_iMouse
  Debug "iFrame location: "+System\Shader_Uniform_iFrame  
  Debug "Texture location: "+System\Shader_Uniform_Texture
  Debug "Res location: "+System\Shader_Uniform_Resolution
  Debug "SurfacePos location: "+System\Shader_Uniform_SurfacePosition
  
  SetGadgetText(#Gad_Editor,System\Shader_Fragment_Text)
  
EndProcedure

Procedure OpenShader()
  Define filename$ ="", txt$ = ""
  
  filename$ = OpenFileRequester("Open shader","","All|*.*",0)
  
  If filename$ <> ""
    
    If ReadFile(0, filename$) 
      While Eof(0) = 0           
        txt$ + ReadString(0) +Chr(10) 
      Wend
      CloseFile(0)  
      Shader_Set(-1,txt$)

    Else
      MessageRequester("Information","Impossible d'ouvrir le fichier!")
    EndIf

  EndIf
  
EndProcedure

Procedure SaveShader()
  Define filename$ =""
  
  filename$ = SaveFileRequester("Save","","txt|*.txt",0)
  
  If filename$ <> ""
    
    If OpenFile(0, filename$) 
      WriteStringN(0, GetGadgetText(#Gad_Editor))
      CloseFile(0)
    EndIf
    
  EndIf
  
EndProcedure

Procedure Texturload()
    Define Pattern$, File.s
    Pattern$ = "Graficfiles |*.jpg;*.bmp"
    File.s = OpenFileRequester("Bitte Datei zum Laden auswählen", "", Pattern$, 0)
    If File.s = ""
       MessageRequester("Information", "Der Requester wurde abgebrochen.", 0)
       ProcedureReturn #False 
    EndIf
     
    Texture.i = LoadGLTextures(File)
    
  EndProcedure
  
Procedure RunShader()
  
  System\App_StartTime = ElapsedMilliseconds()
  Shader_Set(-2)
  
EndProcedure

Shader_Set(0)

Procedure Render()
  Define MyDate.f, Time.f
  
  ;/ set shader Uniform values
  glUniform2f(System\Shader_Uniform_Resolution,System\Shader_Width,System\Shader_Height)
  MyDate.f = Hour(Date()) * 3600 + Minute(Date())*60 + Second(Date())+System\Frames/60
  glUniform4f(System\Shader_Uniform_iDate,Year(Date()),Month(Date()), Day(Date()),MyDate)
  glUniform4f(System\Shader_Uniform_iMouse,System\MouseX,System\Shader_Height-System\MouseY,System\MouseZ,System\Shader_Height-System\MouseW)
  glUniform1f(System\Shader_Uniform_iKey, System\Key)
  glUniform1f(System\Shader_Uniform_iTime,(System\App_CurrentTime-System\App_StartTime) / 1000)
  glUniform1f(System\Shader_Uniform_Texture, Texture)
  glUniform2i(System\Shader_Uniform_SurfacePosition.i,1.0,1.0)
  
  glBegin_(#GL_QUADS)
    glVertex2f_(-1,-1) 
    glVertex2f_( 1,-1) 
    glVertex2f_( 1, 1) 
    glVertex2f_(-1, 1) 
  glEnd_()           
  
  System\Frames + 1
  If System\App_CurrentTime > System\FPS_Timer
    System\FPS = System\Frames
    System\Frames = 0
    System\FPS_Timer = System\App_CurrentTime  + 1000
    SetWindowTitle(#Window_Main,Title+Str(System\FPS))
  EndIf
  
  SetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_FlipBuffers,1)
  
EndProcedure

Repeat
  
  Repeat
    
    System\Event = WindowEvent()
    
    Select System\Event
        
      Case #PB_Event_Menu
        Select EventMenu()
          Case #Menu_Open
            OpenShader()
          Case #Menu_Save
            SaveShader()
          Case #Menu_Texturload
            Texturload()
          Case #Menu_Run
            RunShader()
            
        EndSelect
        
      Case #PB_Event_CloseWindow        
        System\Exit = #True
        
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gad_ShaderSelector_Combo
            Select EventType()
              Case #PB_EventType_Change
                Debug "Set to: "+GetGadgetState(#Gad_ShaderSelector_Combo)
                Shader_Set(GetGadgetState(#Gad_ShaderSelector_Combo))
            EndSelect
          Case #Gad_OpenGL
            Select EventType()
              Case #PB_EventType_KeyDown
                
                System\Key = GetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_Key  )
                ; Key function for shader will coming soon
                
              Case #PB_EventType_LeftButtonDown
                buttondown = 1
                If buttonoff = 0
                   System\MouseX = GetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_MouseX)
                   System\MouseY = GetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_MouseY)
                   System\MouseZ = System\MouseX
                   System\MouseW = System\MouseY
                 EndIf
                buttonoff = 1  
              Case #PB_EventType_LeftButtonUp
                
                buttonoff = 0
                buttondown = 0
                
              Case #PB_EventType_MouseMove
                If buttondown 
                  System\MouseX = GetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_MouseX)
                  System\MouseY = GetGadgetAttribute(#Gad_OpenGL,#PB_OpenGL_MouseY)
                EndIf  
                ;glUniform4f(System\Shader_Uniform_iMouse,System\MouseX,(System\Shader_Height-System\MouseY) / System\Shader_Height,0,0)
            EndSelect
        EndSelect
    EndSelect
    
  Until System\Event = 0

  System\App_CurrentTime = ElapsedMilliseconds()
  
  Render()
  
Until System\Exit 
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; ExecutableFormat = Shared dll
; CursorPosition = 101
; FirstLine = 60
; Folding = --
; EnableXP
; Executable = ..\..\dll\MP3D.dll
; HideErrorLog