import glfw
import opengl
import strutils
import typeinfo

import mymodule/perspective
import mymodule/shaderProgram
import mymodule/mesh

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
 
    vshaderID: int
    fshaderID: int
    shaderProg: int
 
    vertexPosAttrLoc: GLuint
    colorPosAttrLoc: GLuint
    
    startTime: cdouble

    vertex_vbo: GLuint
    color_vbo: GLuint
    
    mvpMatrixUniLoc: int

    pMatrix: array[0..15, float32]  = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]

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
    
## -----------------------------------------------------------------------------
 
proc InitializeBuffers() =
   
    var vertices = [ 0.0'f32,   0.5'f32,  0.0'f32, 
                    -0.5'f32,  -0.5'f32,  0.0'f32, 
                     0.5'f32,  -0.5'f32,  0.0'f32,
                   ]
 
    glGenBuffers(1, addr(vertex_vbo))
 
    glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo)
 
    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * vertices.len, addr(vertices[0]), GL_STATIC_DRAW)
 
    var colors = [   1.0'f32,   1.0'f32,  0.0'f32, 
                     0.0'f32,   1.0'f32,  1.0'f32, 
                     1.0'f32,   0.0'f32,  1.0'f32,
                 ]
 
    glGenBuffers(1, addr(color_vbo))
 
    glBindBuffer(GL_ARRAY_BUFFER, color_vbo)
 
    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * colors.len, addr(colors[0]), GL_STATIC_DRAW)

    mymesh = createMesh(9)

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
    
    vertexPosAttrLoc = shader.GetAttribLocation("a_position")
    colorPosAttrLoc = shader.GetAttribLocation("a_color")
    
    InitializeBuffers()
 
 
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
    
    shader.Begin

    shader.SetUniformMatrix("u_pMatrix", addr(pMatrix[0]))   

    glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo)
    glEnableVertexAttribArray(0)
    glVertexAttribPointer(vertexPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)
    
    glBindBuffer(GL_ARRAY_BUFFER, color_vbo)
    glEnableVertexAttribArray(1)
    glVertexAttribPointer(colorPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)

    glDrawArrays(GL_TRIANGLES, 0, 3)
 
    shader.Begin
    
    glfwSwapBuffers()

## --------------------------------------------------------------------------------
 
proc Run() =

    while running:
   
        if resized:
          resized = false
          
          glViewport(0, 0, windowW, windowH)

          #PerspectiveProjection(60.0, float32(windowW) / float32(windowH), -1.0, -50.0, pMatrix)
          pMatrix = PerspectiveProjection2(60.0, float32(windowW) / float32(windowH), -1.0, -50.0)


        Update()
 
        Render()
  
        running = glfwGetKey(GLFW_KEY_ESC) == GLFW_RELEASE and
                  glfwGetWindowParam(GLFW_OPENED) == GL_TRUE

 
## ==============================================================================
 
Initialize()
 
Run()
 
glfwTerminate()
