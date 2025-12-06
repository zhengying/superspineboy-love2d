return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 400,
  height = 40,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 13,
  nextobjectid = 1,
  backgroundcolor = { 41, 173, 94 },
  properties = {
    ["atlas"] = "map.atlas"
  },
  tilesets = {
    {
      name = "Walls",
      firstgid = 1,
      class = "",
      tilewidth = 512,
      tileheight = 512,
      spacing = 0,
      margin = 0,
      columns = 0,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 512,
        height = 512
      },
      properties = {},
      wangsets = {},
      tilecount = 8,
      tiles = {
        {
          id = 0,
          image = "../tiles/walls/wall-01.png",
          width = 512,
          height = 512
        },
        {
          id = 1,
          image = "../tiles/walls/wall-02.png",
          width = 512,
          height = 512
        },
        {
          id = 2,
          image = "../tiles/walls/wall-03.png",
          width = 512,
          height = 512
        },
        {
          id = 3,
          image = "../tiles/walls/wall-04.png",
          width = 512,
          height = 512
        },
        {
          id = 4,
          image = "../tiles/rock/rock-01.png",
          width = 512,
          height = 512
        },
        {
          id = 5,
          image = "../tiles/rock/rock-02.png",
          width = 512,
          height = 512
        },
        {
          id = 6,
          image = "../tiles/rock/rock-03.png",
          width = 512,
          height = 512
        },
        {
          id = 7,
          image = "../tiles/rock/rock-04.png",
          width = 512,
          height = 512
        }
      }
    },
    {
      name = "Decals",
      firstgid = 9,
      class = "",
      tilewidth = 512,
      tileheight = 512,
      spacing = 0,
      margin = 0,
      columns = 0,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 512,
        height = 512
      },
      properties = {},
      wangsets = {},
      tilecount = 32,
      tiles = {
        {
          id = 0,
          image = "../tiles/decals02/ground-01.png",
          width = 512,
          height = 128
        },
        {
          id = 1,
          image = "../tiles/decals02/ceiling-01.png",
          width = 512,
          height = 128
        },
        {
          id = 2,
          image = "../tiles/decals02/wall-left-01.png",
          width = 128,
          height = 512
        },
        {
          id = 3,
          image = "../tiles/decals02/wall-right-01.png",
          width = 128,
          height = 512
        },
        {
          id = 4,
          image = "../tiles/decals02/wall-left_bottom-01.png",
          width = 128,
          height = 128
        },
        {
          id = 5,
          image = "../tiles/decals02/wall-right_top-01.png",
          width = 128,
          height = 128
        },
        {
          id = 6,
          image = "../tiles/decals/collision.png",
          width = 64,
          height = 64
        },
        {
          id = 7,
          image = "../tiles/decals/crate-01.png",
          width = 256,
          height = 256
        },
        {
          id = 8,
          image = "../tiles/decals/crate-02.png",
          width = 128,
          height = 128
        },
        {
          id = 9,
          image = "../tiles/decals/crate-3.png",
          width = 128,
          height = 128
        },
        {
          id = 10,
          image = "../tiles/decals/fusebox-01.png",
          width = 128,
          height = 128
        },
        {
          id = 11,
          image = "../tiles/decals/ceiling_lamp-01.png",
          width = 128,
          height = 128
        },
        {
          id = 12,
          image = "../tiles/decals/metal-01.png",
          width = 512,
          height = 128
        },
        {
          id = 13,
          image = "../tiles/decals02/concrete-01.png",
          width = 512,
          height = 128
        },
        {
          id = 14,
          image = "../tiles/decals/column-01.png",
          width = 512,
          height = 320
        },
        {
          id = 15,
          image = "../tiles/decals/column-02.png",
          width = 512,
          height = 64
        },
        {
          id = 16,
          image = "../tiles/decals/column-03.png",
          width = 512,
          height = 256
        },
        {
          id = 17,
          image = "../tiles/decals/fill.png",
          width = 64,
          height = 64
        },
        {
          id = 18,
          image = "../tiles/decals02/edge-left-01.png",
          width = 64,
          height = 64
        },
        {
          id = 19,
          image = "../tiles/decals03/concrete-02.png",
          width = 512,
          height = 128
        },
        {
          id = 20,
          image = "../tiles/decals03/concrete-03.png",
          width = 512,
          height = 128
        },
        {
          id = 21,
          image = "../tiles/decals03/metal-02.png",
          width = 512,
          height = 128
        },
        {
          id = 22,
          image = "../tiles/decals03/metal-03.png",
          width = 512,
          height = 128
        },
        {
          id = 23,
          image = "../tiles/tint03/tint-05.png",
          width = 128,
          height = 128
        },
        {
          id = 24,
          image = "../tiles/tint03/tint-06.png",
          width = 128,
          height = 128
        },
        {
          id = 25,
          image = "../tiles/tint03/tint-07.png",
          width = 128,
          height = 128
        },
        {
          id = 26,
          image = "../tiles/tint03/tint-08.png",
          width = 128,
          height = 128
        },
        {
          id = 27,
          image = "../tiles/tint03/tint-09.png",
          width = 128,
          height = 128
        },
        {
          id = 28,
          image = "../tiles/tint03/tint-10.png",
          width = 128,
          height = 128
        },
        {
          id = 29,
          image = "../tiles/tint03/tint-11.png",
          width = 128,
          height = 128
        },
        {
          id = 30,
          image = "../tiles/tint03/tint-12.png",
          width = 128,
          height = 128
        },
        {
          id = 31,
          image = "../tiles/decals/ceiling-lamp-wire-01.png",
          width = 128,
          height = 128
        }
      }
    },
    {
      name = "Lights",
      firstgid = 41,
      class = "",
      tilewidth = 512,
      tileheight = 512,
      spacing = 0,
      margin = 0,
      columns = 0,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 512,
        height = 512
      },
      properties = {},
      wangsets = {},
      tilecount = 2,
      tiles = {
        {
          id = 0,
          image = "../tiles/lights/light-01.png",
          width = 512,
          height = 512
        },
        {
          id = 1,
          image = "../tiles/lights/light-02.png",
          width = 512,
          height = 512
        }
      }
    },
    {
      name = "Tint",
      firstgid = 43,
      class = "",
      tilewidth = 512,
      tileheight = 512,
      spacing = 0,
      margin = 0,
      columns = 0,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 512,
        height = 512
      },
      properties = {},
      wangsets = {},
      tilecount = 12,
      tiles = {
        {
          id = 0,
          image = "../tiles/tint01/tint-01.png",
          width = 512,
          height = 512
        },
        {
          id = 1,
          image = "../tiles/tint01/tint-02.png",
          width = 512,
          height = 512
        },
        {
          id = 2,
          image = "../tiles/tint01/tint-03.png",
          width = 512,
          height = 512
        },
        {
          id = 3,
          image = "../tiles/tint01/tint-04.png",
          width = 512,
          height = 512
        },
        {
          id = 4,
          image = "../tiles/tint02/tint-01.png",
          width = 512,
          height = 512
        },
        {
          id = 5,
          image = "../tiles/tint02/tint-02.png",
          width = 512,
          height = 512
        },
        {
          id = 6,
          image = "../tiles/tint02/tint-03.png",
          width = 512,
          height = 512
        },
        {
          id = 7,
          image = "../tiles/tint03/tint-01.png",
          width = 64,
          height = 64
        },
        {
          id = 8,
          image = "../tiles/tint03/tint-02.png",
          width = 64,
          height = 64
        },
        {
          id = 9,
          image = "../tiles/tint03/tint-03.png",
          width = 64,
          height = 64
        },
        {
          id = 10,
          image = "../tiles/tint02/tint-04.png",
          width = 512,
          height = 512
        },
        {
          id = 11,
          image = "../tiles/tint03/tint-04.png",
          width = 512,
          height = 192
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 1,
      name = "Collisions",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3cO25CQRAEQG7A/W/ryJmFEJreXg9V0gYkvGB6mj+PBwAAAAAAAOzxdL7iAEzTLfuZMZCgW/YzYyBBt+xnxkCCbtnPjIEE3bKfGQMJumU/MwYSdMt+Zgwk6Jb9zBhI0C37mTGQoFv2M2MgQbfsZ8ZAgm7Zz4yBhA3d0v5vwv9wAKZNdcvJHtOPcIf28yKnfyacvtar28AZdo+bvfM4JMPQYfe42Tv5lGHosHvc5JP3vGQYOuweN/kkjzIMHXaPponP2GUYOuweTRP5k2HosHs0TH6nV4ahw+7RMJk7GYYOu8cJqd8S/t43cJ7d44RkzmQYOuweSYnXG39dAzjP7pF0Il8yDB3t/+5znIkDAAAAAAAAAAAAAACb/QC4IhCPAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 2,
      name = "Background",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3dyQ3CUBBEQbOTAJxY8s+SEBrZDPOlX3V98hJBz7IAAAAAAAAAAAAAM3qGfp+8A1Q5hX4e/HkAWOMd+m3yDgAAAAAAAAAAAMBYLqFfB38eANbYh34MfVfc0/cPxR0AAAAAAAD4Xve+tF7bH6EDAMA/de9L67X9FXr3/Q73PwAAAAAAAAAAAAAAIOver0596z539X53+r+t76/e9+6+3+H+BwAAAAAAAAAAAAAAAMDvfQCqWZEeAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 3,
      name = "Background Decals",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3cQQqAIBRFUffQJpoF7X9xzSWQXkR+OQccCSJOLg60NQAAAAAAAAAAqjm7AcDc9knW1g8AEvoBUIv7BwCV6QcACf0AIKEfANw5BvP6AcBb+gFAQj8ASPT92H7ZRa7afgFW4f4BQEI/AAAAAPjT6C0IAAAAAAAAAAAAAAAAAACwDv9XP+O8AAAAAAAAAAAAAAAAAACAr1z7AaWEAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 4,
      name = "Background Tint",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3cywnDMBAEUPeTxJDg/mtLA8YLUcRo8XswJ4F/h/VpZ9sAAAAAAAAAAOjuI5cB4Fx6Pq8egFn25ueHXAaAc+n5vHoAAAAAAAAAAAAAWEt6f2P0HAB+8SzOX5Pv/558/UdxXr0/AAAAAMBdpftBRT8r0FN6fon/B9BTuh9U9LMCPaXnl2ST3t+w/wEAAAAAAAAAAAAAALWq/zndjz3baD92+vuMPn96f8P+BwAAAAAAAAAAAAAAAMD/fQFmZRZyAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 5,
      name = "Background Tint2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3cMQoCQRBE0T1KKaI38P5HM9HASGiEYun3kglmg58Vk+xxAAAAAAAAAABwVpd2AMBy95Oe1wOAprQDhrw/ALrSDhiyHwBdaQcM2Q8AJuwHQFfaAUOf/Xj++G77PQDfvD8AutIOGLIfAEzYD4CutAOG7AcAE/YDoCvtgCH7AcCE/QDoSjsAAABYI+0AAABgjbQDAACANdIOAE6r/X9p9917AJhIOwAAAFgj7QAAAGCN2/t8lE4AAAAAAAAAAAAAAAAA/u8F5Lc02gD6AAA="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 6,
      name = "Background Lights",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3c0QkAIAhAQddp/wUbQUgko7tfQd8ERgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADALOt2QGJ6HwAAAAAAAAAAAAAAAAAAAAAAAAAAAMBvsv/R1Xn3/er+bq/3AwAAAAAAAAAAAHBuAzp5pcAA+gAA"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 7,
      name = "Objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAE+3cQQqAIBAFUI+Q0v3P2qYgohltEWG8t1FBxO131FIAAAAAAAAAACC2Tr4+AAAAAACQe/OsXh0AAAAAAAAAAAAAAAAAAACAp9re1k93AXzN/9i52fcPAAAAAH+2dMYAAACj2qW95otWYu5fAQAAI87ZIcoY5zl3dY8smwAAAGR6d6vkDQAAIHPUMHrvOOpNP5rjDQgAAAAAAAAAAAAAAABA3wZLC7bAAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 8,
      name = "Foreground Tint",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3cTW6DMBAGUE6UVkG9/9W66qILYhg8DNjvSawQ4x8p8ykJsCwAAAAAAAAAALwnOkYx45qB+6nu6fLjuBnXDNxPdU+XH8fNuGbgfs72ncw+3js/vg+MveWrcf6KMeQHcAdPzw8AasgPACLkBwAR8gOACPkBQIT8ACBiqy//3Yfa817SjNoA1OjZizP7/FbdV+O6Hs9jfPKTXL+Vsa31A2R5en4AUEN+ABAhP4CoyP+fVZ/lq/pFzz2p6HVV87u69tqhLhD3xP6YTX70HzejtvyAWk/sj9nkR/9xM2rLD6jVsz/O+H7sq/cnc/6t+Z0ZN6O2/AAYT4/vHOuOA4CxyA8AIvbkx7r8/y0qcgAwFvkBQMSn/IhmhfwAGJ/8ACBCfsD4Wu9/9n7sc+ez9+fs/KPz2/O8xlZt+QEAAAAAAAAAAAAAAACQ6xeqGQeZAPoAAA=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 9,
      name = "Foreground Tint2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3ZMQrAIAxAUW9UqPe/W5cKUhpMdSjCeyAuGdw+xFIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYH/17wcAsCX9AGCGfgAwQz8AyKjdfd4HALL0A4BI68Pbjko/AIjoBwAjmX/wZy/0AwD9AGDFl72UfgDQ9P04BrP6AQAAAAAAAAAAAAAAABC7AJuko8IA+gAA"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 10,
      name = "Foreground Lights",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3cQQqDMBRFUdfTSaXQ/W+tdCqlv3lKNck5kKGSUS5q4rIAAJzjUQwA2KraoSUAfKIfACT0A2BOe9d2/QCYk34AkNAPABL6AUCiWtvvDdf/Mtb9UwbgAo5c2z1zAJDQDwASI/Tj1vn9AXo0Qj8A+D/9ACChHwC8tb6rb+mH7wAA80jPgjjzATAeazsAAAAAAAAAAAAAXF91FsS+YICxPM+eAEDI/7G/633+AAAAAAAAAAAAtLEvGAAAAAAAAAAAAKD2ApmR58wA+gAA"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 11,
      name = "Borders",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3cwQqCQBQFULdltWwR/f93trFNIOJz5DbMOfAQvCqu5iLITBOjeZnhBqCF9Fpm9AfQp/RaZvQH0CdrCgAVv/1x3bhe3ncO0IrvDwAq9AcAFfoDgAr9AUCF/gCg4tsfc/pFAOiK7w8AKvQHABX6A4AK/QFAhf4AWknvDWoyA3BUeh0zmfH/LgAjeyzHy0q+dn6UHM6U3l9ansnvG/ft8VyO74bPBAAAAAAAAAAAAAD+zy39AgAAAAAAAAAAAAA7pfeXlsuP5P7fBQAAAAAAAAAAAHryAX2DmCsA+gAA"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 400,
      height = 40,
      id = 12,
      name = "Foreground",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "gzip",
      data = "H4sIAAAAAAAAC+3csQ2AMBRDwWwBrMH+w9FTRRHCsXQn0bp8vyJjAAAAAAAAAAAAAADANw77ACw47QOwoL3v7gdARnvf3Q+AjPa+ux8AGe19dz8AMtr77n4AZLT33f0AAAAAAICMe/JLuOwDbGvn+wEAAADQ/n61fYCM9v+n7ANktPfRPkBGex/tA2S099E+QEZ7H+0DZLT30T5ARnsf7QMAAAAAAG/t71fbBwAAAAAAAAAAAOAvD6TMpK4A+gAA"
    }
  }
}
