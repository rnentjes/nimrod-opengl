# Mesh

import opengl
import shaderProgram
import tables

type
  TMesh = object
    drawType: GLenum
    data: array[0..4096, float32]
    count: GLsizei
    blockLength: GLsizei
    vertex_vbo: GLuint
    program*: PShaderProgram
    attrs: seq[TMeshAttr]
    attrLocations: TTable[string, GLuint]

  PMesh* = ref TMesh

  TMeshAttr* = object
    attribute*: string
    attrIndex*: GLuint
    numberOfElements*: GLint

  PMeshAttr* = ref TMeshAttr

proc createMesh*(program: PShaderProgram, drawType: GLenum, attribs: seq[TMeshAttr]) : PMesh =
  result = new(TMesh)

  result.drawType = drawType
  result.program = program
  result.attrs = attribs
  result.count = 0
  result.blockLength = 0
  result.attrLocations = initTable[string, GLuint]()

  for attr in attribs:
    result.attrLocations[attr.attribute] = program.GetAttribLocation(attr.attribute)
    result.blockLength = result.blockLength + attr.numberOfElements

  glGenBuffers(1, addr(result.vertex_vbo))
  glBindBuffer(GL_ARRAY_BUFFER, result.vertex_vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * result.data.len, addr(result.data[0]), GL_DYNAMIC_DRAW)


proc AddVertices*(mesh: PMesh, verts: varargs[float32]) =
  assert verts.len == mesh.blockLength
  #assert (verts.len + mesh.count) < mesh.len

  for v in verts:
    mesh.data[mesh.count] = v
    mesh.count = mesh.count + 1

proc Reset*(mesh: PMesh) =
  mesh.count = 0

proc Draw*(mesh: PMesh) =
  glBindBuffer(GL_ARRAY_BUFFER, mesh.vertex_vbo)

  var index = 0
  for attr in mesh.attrs:
    glVertexAttribPointer(mesh.attrLocations[attr.attribute], attr.numberOfElements, 
      cGL_FLOAT, false, cast[GLsizei](mesh.blockLength * sizeof(GL_FLOAT)), cast[pointer](index * sizeof(GL_FLOAT)))
    index += attr.numberOfElements
 
  glBufferSubData(GL_ARRAY_BUFFER, 0, cast[GLsizeiptr](sizeof(GL_FLOAT) * int(mesh.count)), addr(mesh.data[0]))
  #glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](sizeof(GL_FLOAT) * int(mesh.count)), addr(mesh.data[0]), GL_DYNAMIC_DRAW)

  glDrawArrays(mesh.drawType, 0, cast[GLsizei](uint(mesh.count / mesh.blockLength)))

  mesh.Reset

proc Begin*(mesh: PMesh) =
  mesh.program.Begin()

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vertex_vbo)

  for attr in mesh.attrs:
    glEnableVertexAttribArray(mesh.attrLocations[attr.attribute])

proc Done*(mesh: PMesh) =
  if (mesh.count > 0):
    mesh.Draw()
  
  for attr in mesh.attrs:
    glDisableVertexAttribArray(mesh.attrLocations[attr.attribute])

  glBindBuffer(GL_ARRAY_BUFFER, 0)
  mesh.program.Done()
