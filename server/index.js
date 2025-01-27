"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var WebSocket = require("ws");
var wss = new WebSocket.Server({ port: 3000 });
var rooms = {};
wss.on('connection', function connection(ws, request) {
    console.log('New client connected to room ' + getRoomId(request.url || ''));
    var roomId = getRoomId(request.url || '');
    if (!rooms[roomId]) {
        rooms[roomId] = {
            videoId: '',
            timestamp: 0,
            state: 'paused',
            users: [ws]
        };
    }
    else {
        rooms[roomId].users.push(ws);
        updateUserOnCurrentRoomState(ws, rooms[roomId]);
    }
    ws.on('message', function (message) {
        console.log("Received message: ".concat(message));
        wss.clients.forEach(function (client) {
            if (message.toString() === 'keepalive') {
                ws.send('keepalive');
                return;
            }
            if (message.toString().startsWith('videoId:')) {
                rooms[roomId].videoId = message.toString().split(': ')[1];
            }
            if (message.toString().startsWith('seek:')) {
                rooms[roomId].timestamp = parseFloat(message.toString().split(': ')[1]);
            }
            if (message.toString() === 'playing') {
                rooms[roomId].state = 'playing';
            }
            if (message.toString() === 'paused') {
                rooms[roomId].state = 'paused';
            }
            if (client !== ws) {
                client.send(message.toString());
            }
        });
    });
    ws.on('close', function () {
        console.log('Client disconnected');
        if (!rooms[roomId])
            return;
        rooms[roomId].users = rooms[roomId].users.filter(function (user) { return user !== ws; });
        if (rooms[roomId].users.length === 0) {
            delete rooms[roomId];
        }
    });
});
function getRoomId(path) {
    var re = /room=([^&/]*)/;
    var match = re.exec(path);
    return match ? match[1] : 'default';
}
function updateUserOnCurrentRoomState(ws, room) {
    var videoId = room.videoId;
    var timestamp = room.timestamp;
    var state = room.state;
    ws.send("videoId: " + videoId);
    ws.send("seek: " + timestamp);
    ws.send(state);
}
