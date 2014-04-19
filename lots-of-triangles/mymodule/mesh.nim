# Mesh

import opengl

type
  TMesh = object
    data: array[0..4096, float32]
    count: GLsizei
    blockLength: GLsizei
    vertex_vbo: GLuint
    attrs: seq[TMeshAttr]

  PMesh* = ref TMesh

  TMeshAttr* = object
    attrType*: GLuint
    numberOfElements*: GLint


proc createMesh*(attribs: seq[TMeshAttr]) : PMesh =
  result = new(TMesh)

  result.attrs = attribs
  result.count = 0
  result.blockLength = 0

  for attr in attribs:
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
    glVertexAttribPointer(attr.attrType, attr.numberOfElements, cGL_FLOAT, false, mesh.blockLength, cast[GLvoid](index))
    index += attr.numberOfElements

  glDrawArrays(GL_TRIANGLES, 0, mesh.count)
  mesh.Reset

