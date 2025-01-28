"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
var WebSocket = require("ws");
var wss = new WebSocket.Server({ port: 3000 });
var rooms = {};
setInterval(function () {
    for (var _i = 0, _a = Object.entries(rooms); _i < _a.length; _i++) {
        var _b = _a[_i], roomId = _b[0], room = _b[1];
        if (room.state === 'playing') {
            room.timestamp += 1;
        }
    }
}, 1000);
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
        if (message.toString() === 'ended') {
            rooms[roomId].state = 'paused';
            return;
        }
        wss.clients.forEach(function (client) {
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
    return __awaiter(this, void 0, void 0, function () {
        var videoId, timestamp, state;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    videoId = room.videoId;
                    timestamp = room.timestamp;
                    state = room.state;
                    ws.send("videoId: " + videoId);
                    return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, 1000); })];
                case 1:
                    _a.sent();
                    ws.send("seek: " + timestamp);
                    ws.send(state);
                    return [2 /*return*/];
            }
        });
    });
}
