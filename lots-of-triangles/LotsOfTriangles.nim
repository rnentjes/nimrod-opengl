import glfw
import opengl
import strutils
import typeinfo
import math

import mymodule/perspective
import mymodule/shaderProgram
import mymodule/mesh
import mymodule/matrix

## -------------------------------------------------------------------------------
 
var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0
   
    windowW: GLint = 1024
    windowH: GLint = 768
 
    startTime: cdouble

    mvpMatrixUniLoc: int

    pMatrix: array[0..15, float32]  = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]

    mymatrix: PMatrix                                   

    resized: bool = true
    
    shader: PShaderProgram
    mymesh: PMesh
 
type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------

proc Resize(width, height: cint) = 
    windowW = width
    windowH = height
    
    resized = true
 
## ---------------------------------------------------------------------
 
proc InitializeGL() =

    glClearColor(0.2,0.0,0.2,1.0)
    
## -------------------------------------------------------------------------------
 
proc Initialize() =
    startTime = glfwGetTime()
   
    if glfwInit() == 0:
        write(stdout, "Could not initialize GLFW! \n")
 
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_FALSE)
    #glfwOpenWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 2)
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 0)
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE)
    
    #glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE)
 
    # GLFW_WINDOW or GLFW_FULLSCREEN
    if glfwOpenWindow(cint(windowW), cint(windowH), 0, 0, 0, 0, 0, 0, GLFW_WINDOW) == 0:
        glfwTerminate()
 
    glfwSetWindowSizeCallback(Resize)
 
    glfwSwapInterval(1)
 
    opengl.loadExtensions()
 
    InitializeGL()
 
    lastTime = glfwGetTime()
    lastFPSTime = lastTime

    shader = createShaderProgram("shaders/shader")

    mymesh = createMesh(shader, 
        @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
          TMeshAttr(attribute: "a_color", numberOfElements: 3)] ) 

    mymatrix = createMatrix()        
     
 
## -------------------------------------------------------------------------------
proc Update() =
   
    currentTime = glfwGetTime()
 
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
   
    glClear(GL_COLOR_BUFFER_BIT)

    var z : float32

    z = float32(-13 + sin(currentTime) * 12)
    var r = float32((1 + sin(currentTime * 3)) / 2.0)
    var g = float32((1 + sin(currentTime * 5)) / 2.0)
    var b = float32((1 + sin(currentTime * 7)) / 2.0)
    
    mymesh.Begin

    #mymesh.program.SetUniformMatrix("u_pMatrix", addr(pMatrix[0]))
    mymatrix.Rotatez(0.001'f32)
    mymesh.program.SetUniformMatrix("u_pMatrix", mymatrix.Address)

    mymesh.AddVertices(-0.5'f32, 0.1'f32, z, r,     g,     0'f32)
    mymesh.AddVertices( 0.5'f32, 0.1'f32, z, 0'f32, g,     b)
    mymesh.AddVertices( 0.0'f32, 1'f32,   z, r,     0'f32, b)

    mymesh.AddVertices(-0.5'f32, -0.1'f32,  z, r,     g,     0'f32)
    mymesh.AddVertices( 0.5'f32, -0.1'f32,  z, 0'f32, g,     b)
    mymesh.AddVertices( 0.0'f32, -1'f32,    z, r,     0'f32, b)

    #mymesh.Draw
    
    mymesh.Done

    #shader.Begin

    #shader.SetUniformMatrix("u_pMatrix", addr(pMatrix[0]))   

    #glEnableVertexAttribArray(vertexPosAttrLoc)
    #glEnableVertexAttribArray(colorPosAttrLoc)

    #glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo)
    #glVertexAttribPointer(vertexPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)
    
    #glBindBuffer(GL_ARRAY_BUFFER, color_vbo)
    #glVertexAttribPointer(colorPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)

    #glDrawArrays(GL_TRIANGLES, 0, 3)
 
    #glDisableVertexAttribArray(vertexPosAttrLoc)
    #glDisableVertexAttribArray(colorPosAttrLoc)

    #shader.Done
    #shader.Done

    glfwSwapBuffers()

## --------------------------------------------------------------------------------
 
proc Run() =
    #GC_disable()

    while running:
   
        if resized:
          resized = false
          
          glViewport(0, 0, windowW, windowH)

          mymatrix.PerspectiveProjection(60.0, float32(windowW) / float32(windowH), 1.0, 25.0)
          PerspectiveProjection(60.0, float32(windowW) / float32(windowH), 1.0, 25.0, pMatrix)
          #OrthographicProjection(-5'f32, 5'f32, -5'f32, 5'f32, -1'f32, -25'f32, pMatrix);

        Update()
 
        Render()

        #GC_step(2000)
  
        running = glfwGetKey(GLFW_KEY_ESC) == GLFW_RELEASE and
                  glfwGetWindowParam(GLFW_OPENED) == GL_TRUE

 
## ==============================================================================
 
Initialize()
 
Run()
 
glfwTerminate()
