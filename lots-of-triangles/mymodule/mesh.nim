# Mesh

type
  TMesh = object
    data: array[0..4096, float32]
    count: int
    blockLength: int

  PMesh* = ref TMesh


proc createMesh*(blockLength: int) : PMesh =
  result = new(TMesh)

  result.count = 0
  result.blockLength = blockLength


proc AddVertices*(mesh: PMesh, verts: varargs[float32]) =
  assert verts.len == mesh.blockLength

  for v in verts:
    mesh.data[mesh.count] = v
    mesh.count = mesh.count + 1


proc Reset*(mesh: PMesh) =
  mesh.count = 0

