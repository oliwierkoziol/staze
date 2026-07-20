const http = require("http");
const { WebSocketServer } = require("ws");

const PORT = Number(process.env.PORT || 9090);
const rooms = new Map();

function makeRoomCode() {
  let code = "";
  do {
    code = String(Math.floor(100000 + Math.random() * 900000));
  } while (rooms.has(code));
  return code;
}

function send(ws, payload) {
  if (ws.readyState === ws.OPEN) {
    ws.send(JSON.stringify(payload));
  }
}

const server = http.createServer((_req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("TurnBaseGame signaling server\n");
});

const wss = new WebSocketServer({ server });

wss.on("connection", (ws) => {
  ws.roomCode = "";
  ws.role = "";

  ws.on("message", (raw) => {
    let message;
    try {
      message = JSON.parse(String(raw));
    } catch (_err) {
      send(ws, { type: "room_error", reason: "invalid_json" });
      return;
    }

    switch (message.type) {
      case "create_room": {
        const roomCode = makeRoomCode();
        ws.roomCode = roomCode;
        ws.role = "host";
        rooms.set(roomCode, { host: ws, guest: null });
        send(ws, { type: "room_created", room_code: roomCode });
        break;
      }
      case "join_room": {
        const roomCode = String(message.room_code || "");
        const room = rooms.get(roomCode);
        if (!room || !room.host || room.guest) {
          send(ws, { type: "room_error", reason: "room_unavailable" });
          return;
        }
        ws.roomCode = roomCode;
        ws.role = "guest";
        room.guest = ws;
        send(ws, { type: "room_joined", room_code: roomCode });
        send(room.host, { type: "guest_joined", room_code: roomCode });
        break;
      }
      case "signal": {
        const roomCode = String(message.room_code || ws.roomCode || "");
        const room = rooms.get(roomCode);
        if (!room) {
          return;
        }
        const target = ws.role === "host" ? room.guest : room.host;
        if (target) {
          send(target, { type: "signal", room_code: roomCode, payload: message.payload || {} });
        }
        break;
      }
      default:
        send(ws, { type: "room_error", reason: "unknown_type" });
    }
  });

  ws.on("close", () => {
    const roomCode = ws.roomCode;
    if (!roomCode || !rooms.has(roomCode)) {
      return;
    }
    const room = rooms.get(roomCode);
    if (ws.role === "host") {
      if (room.guest) {
        send(room.guest, { type: "room_closed", room_code: roomCode });
      }
      rooms.delete(roomCode);
      return;
    }
    if (ws.role === "guest") {
      room.guest = null;
      if (room.host) {
        send(room.host, { type: "guest_left", room_code: roomCode });
      }
    }
  });
});

server.listen(PORT, () => {
  console.log(`Signaling server listening on :${PORT}`);
});
