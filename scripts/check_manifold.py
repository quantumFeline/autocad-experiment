"""STL sanity check for the thumb_v3 parts.

For each STL given on the command line, verifies that the mesh is
watertight (every edge shared by exactly two triangles), free of
degenerate faces, and reports shells, volume, bounding box, and each
shell's lowest point (print layouts should rest every shell on z=0).

Usage:
    python3 scripts/check_manifold.py stl/*.stl

Exit code 0 if every file passes, 1 otherwise. Handles both ASCII and
binary STL. Requires numpy only.
"""
import struct
import sys

import numpy as np


def load_stl(path):
    """Return triangles as an (n, 3, 3) float array."""
    with open(path, "rb") as f:
        head = f.read(5)
    if head == b"solid":  # ASCII (OpenSCAD's default output)
        coords = []
        with open(path) as f:
            for line in f:
                s = line.split()
                if s and s[0] == "vertex":
                    coords.append([float(s[1]), float(s[2]), float(s[3])])
        return np.array(coords).reshape(-1, 3, 3)
    with open(path, "rb") as f:
        f.seek(80)
        (n,) = struct.unpack("<I", f.read(4))
        data = np.frombuffer(f.read(n * 50), dtype=np.uint8).reshape(n, 50)
    return data[:, 12:48].copy().view("<f4").reshape(n, 3, 3).astype(np.float64)


def shell_labels(faces, n_verts):
    """Union-find over faces sharing vertices; returns a root id per face."""
    parent = np.arange(n_verts)

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for f in faces:
        r = find(f[0])
        parent[find(f[1])] = r
        parent[find(f[2])] = r
    return np.array([find(f[0]) for f in faces])


def check(path):
    tri = load_stl(path)
    verts = tri.reshape(-1, 3)
    # weld vertices exactly; OpenSCAD emits identical coords for shared verts
    uniq, inv = np.unique(verts.round(6), axis=0, return_inverse=True)
    faces = inv.reshape(-1, 3)

    degen = np.sum(
        (faces[:, 0] == faces[:, 1])
        | (faces[:, 1] == faces[:, 2])
        | (faces[:, 0] == faces[:, 2])
    )

    edges = np.sort(
        np.concatenate([faces[:, [0, 1]], faces[:, [1, 2]], faces[:, [2, 0]]]),
        axis=1,
    )
    _, counts = np.unique(edges, axis=0, return_counts=True)
    bad_edges = np.sum(counts != 2)

    labels = shell_labels(faces, len(uniq))

    v0, v1, v2 = tri[:, 0], tri[:, 1], tri[:, 2]
    vol = np.sum(np.einsum("ij,ij->i", v0, np.cross(v1, v2))) / 6.0
    size = verts.max(axis=0) - verts.min(axis=0)

    ok = bad_edges == 0 and degen == 0 and vol > 0
    name = path.split("/")[-1]
    print(
        f"{name:>16}: {'OK' if ok else 'PROBLEM'}  tris={len(tri)}  "
        f"badEdges={bad_edges}  degen={degen}  "
        f"shells={len(np.unique(labels))}  vol={vol:8.1f} mm^3  "
        f"size={size[0]:.1f} x {size[1]:.1f} x {size[2]:.1f} mm"
    )
    for r in np.unique(labels):
        pts = tri[labels == r].reshape(-1, 3)
        mn, mx = pts.min(axis=0), pts.max(axis=0)
        print(
            f"{'':>18}shell x={mn[0]:6.1f}..{mx[0]:6.1f}  "
            f"zmin={mn[2]:6.3f}  zmax={mx[2]:6.2f}"
        )
    return ok


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    results = [check(p) for p in sys.argv[1:]]
    sys.exit(0 if all(results) else 1)
