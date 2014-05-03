# Mesh

import opengl
import shaderProgram
import tables

type
  TMesh = object
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

proc createMesh*(program: PShaderProgram, attribs: seq[TMeshAttr]) : PMesh =
  result = new(TMesh)

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
  glEnableVertexAttribArray(0)

  var index = 0
  for attr in mesh.attrs:
    glVertexAttribPointer(mesh.attrLocations[attr.attribute], attr.numberOfElements, 
      cGL_FLOAT, false, mesh.blockLength, cast[pointer](index))
    index += attr.numberOfElements

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vertex_vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * mesh.data.len, addr(mesh.data[0]), GL_DYNAMIC_DRAW)

  glDrawArrays(GL_TRIANGLES, 0, cast[GLsizei](mesh.count / mesh.blockLength))
  mesh.Reset

proc Begin*(mesh: PMesh) =
  mesh.program.Begin()

  for attr in mesh.attrs:
    glEnableVertexAttribArray(mesh.attrLocations[attr.attribute])

proc Done*(mesh: PMesh) =
  if (mesh.count > 0):
    mesh.Draw()
  
  for attr in mesh.attrs:
    glDisableVertexAttribArray(mesh.attrLocations[attr.attribute])

  mesh.program.Done()
