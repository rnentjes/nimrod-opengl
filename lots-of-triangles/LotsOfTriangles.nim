import glfw3 as glfw
import opengl as gl
import strutils
import typeinfo
import math

import opengl-util/perspective
import opengl-util/shaderProgram
import opengl-util/mesh
import opengl-util/matrix

## -------------------------------------------------------------------------------
 
var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0

    window: glfw.Window   
    windowW: GLint = 1024
    windowH: GLint = 768
 
    startTime: cdouble

    mvpMatrixUniLoc: int

    pmatrix: PMatrix
    backmatrix: PMatrix                                   
    mymatrix: PMatrix                                   

    resized: bool = true
    
    shader: PShaderProgram
    mymesh: PMesh

type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------

proc Resize(window: glfw.Window; width, height: cint) {.cdecl.} = 
    windowW = width
    windowH = height
    
    resized = true

## ---------------------------------------------------------------------
 
proc InitializeGL() =

    glClearColor(0.2,0.0,0.2,1.0)
    
## -------------------------------------------------------------------------------

proc Initialize() =
    startTime = glfw.GetTime()
   
    if glfw.Init() == 0:
        write(stdout, "Could not initialize GLFW! \n")
 
    glfw.WindowHint(RESIZABLE, GL_FALSE)
    #glfw.WindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
    glfw.WindowHint(CONTEXT_VERSION_MAJOR, 2)
    glfw.WindowHint(CONTEXT_VERSION_MINOR, 0)
    glfw.WindowHint(OPENGL_DEBUG_CONTEXT, GL_TRUE)
    
    #glfw.OpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE)
 
    # GLFW_WINDOW or GLFW_FULLSCREEN
    window =  glfw.CreateWindow(cint(windowW), cint(windowH), "TEST", nil, nil)

    echo("Window: ")
    echo(cast[int64](window))

    glfw.MakeContextCurrent(window)
 
    discard glfw.SetWindowSizeCallback(window, Resize)
 
    glfw.SwapInterval(1)
 
    gl.loadExtensions()
 
    InitializeGL()
 
    lastTime = glfw.GetTime()
    lastFPSTime = lastTime

    shader = createShaderProgram("shaders/shader")

    mymesh = createMesh(shader, GL_TRIANGLES,
        @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
          TMeshAttr(attribute: "a_color", numberOfElements: 3)] ) 

    mymatrix = createMatrix()        
    backmatrix = createMatrix()        
    pmatrix = CreateMatrix()
     
 
## -------------------------------------------------------------------------------
proc Update() =
   
    currentTime = glfw.GetTime()
 
    frameDelta = currentTime - lastTime
 
    lastTime = currentTime
 
    if currentTime - lastFPSTime > 1.0:
        frameRate = int(float(frameCount) / (currentTime - lastFPSTime))
        #echo("FPS: $1" % intToStr(frameRate))
        
        lastFPSTime = currentTime
        frameCount = 0
    
    var delta = currentTime - startTime

    frameCount += 1
 
## --------------------------------------------------------------------------------
 
proc Render() =
   
    gl.glClear(GL_COLOR_BUFFER_BIT)

    var z : float32

    z = float32(-2 + sin(currentTime / 3) * 1)
    var r = float32((1 + sin(currentTime * 0.7)) / 2.0)
    var g = float32((1 + sin(currentTime * 0.3)) / 2.0)
    var b = float32((1 + sin(currentTime * 0.5)) / 2.0)
    
    var r1 = float32((1 + sin(currentTime * 0.3)) / 2.0)
    var g1 = float32((1 + sin(currentTime * 0.5)) / 2.0)
    var b1 = float32((1 + sin(currentTime * 0.7)) / 2.0)

    mymesh.Begin

    backmatrix.Rotatez(frameDelta * 0.005'f32)
    mymatrix.Rotatez(frameDelta * 0.003'f32)
    mymatrix.Rotatex(frameDelta * 0.007'f32)

    mymesh.program.SetUniformMatrix("u_pMatrix", pmatrix.Address)
    mymesh.program.SetUniformMatrix("u_mMatrix", backmatrix.Address)

    mymesh.AddVertices( -4'f32,  -4'f32,   -2'f32, 1-r1,  1-g1,  1-b1)
    mymesh.AddVertices(  4'f32,  -4'f32,   -2'f32, r1,    g1,     b1)
    mymesh.AddVertices(  4'f32,   4'f32,   -2'f32, g1,    b1,     r1)

    mymesh.AddVertices(  4'f32,   4'f32,   -2'f32, g1,    b1,     r1)
    mymesh.AddVertices( -4'f32,  -4'f32,   -2'f32, 1-r1,  1-g1,  1-b1)
    mymesh.AddVertices( -4'f32,   4'f32,   -2'f32, r1,    g1,     b1)

    mymesh.Draw

    mymesh.program.SetUniformMatrix("u_mMatrix", mymatrix.Address)

    mymesh.AddVertices(-0.5'f32, 0.1'f32, z, r,     g,     0'f32)
    mymesh.AddVertices( 0.5'f32, 0.1'f32, z, 0'f32, g,     b)
    mymesh.AddVertices( 0.0'f32, 1'f32,   z, r,     0'f32, b)

    mymesh.AddVertices(-0.5'f32, -0.1'f32,  z, r,     g,     0'f32)
    mymesh.AddVertices( 0.5'f32, -0.1'f32,  z, 0'f32, g,     b)
    mymesh.AddVertices( 0.0'f32, -1'f32,    z, r,     0'f32, b)
    
    mymesh.Done

    glFlush()
    glfw.SwapBuffers(window)

## --------------------------------------------------------------------------------
 
proc Run() =
    GC_disable()

    echo("Window: ")
    echo(cast[int64](window))

    while running:
        glfw.PollEvents()
        
        if resized:

          resized = false
          
          glViewport(0, 0, windowW, windowH)

          #mymatrix.PerspectiveProjection(60.0, float32(windowW) / float32(windowH), 1.0, 25.0)
          pmatrix.PerspectiveProjection(60.0, float32(windowW) / float32(windowH), 1.0, 500.0)
          #pmatrix.OrthographicProjection(-5'f32, 5'f32, -5'f32, 5'f32, -1'f32, -25'f32)
          #OrthographicProjection(-5'f32, 5'f32, -5'f32, 5'f32, -1'f32, -25'f32, pMatrix);

        Update()
 
        Render()

        GC_step(1000)

        glfw.SwapBuffers(window)
  
        running = (glfw.GetKey(window, glfw.KEY_SPACE) != glfw.PRESS) and glfw.windowShouldClose(window) != gl.GL_TRUE

        if glfw.GetKey(window, glfw.KEY_SPACE) != glfw.RELEASE:
          echo("KEY_STATE: ", intToStr(glfw.GetKey(window, glfw.KEY_SPACE)))
        # and
        #          glfw.GetWindowAttrib(window, glfw.VISIBLE) == GL_TRUE

 
## ==============================================================================
 
Initialize()
 
Run()
 
Terminate()