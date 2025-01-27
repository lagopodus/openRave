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
var _a;
// 2. This code loads the IFrame Player API code asynchronously.
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
(_a = firstScriptTag.parentNode) === null || _a === void 0 ? void 0 : _a.insertBefore(tag, firstScriptTag);
var player = null;
var lastPlayerTime = 0;
function onYouTubeIframeAPIReady() {
    player = new YT.Player('video', {
        height: '360',
        width: '640',
        videoId: 'FmrKm7q-V6c',
        playerVars: {
            'playsinline': 1,
        },
        events: {
            'onStateChange': onPlayerStateChange,
            'onReady': onReady
        }
    });
}
function onPlayerStateChange(event) {
    if (event.data === YT.PlayerState.ENDED) {
        console.log('ended');
    }
    if (event.data === YT.PlayerState.BUFFERING) {
        console.log('buffering');
    }
    if (event.data === YT.PlayerState.PAUSED) {
        userPressedPause();
    }
    else if (event.data === YT.PlayerState.PLAYING) {
        userPressedPlay();
    }
    refreshMostMetadata();
}
setInterval(function () {
    if (player && (lastPlayerTime - 4 > player.getCurrentTime() || player.getCurrentTime() > lastPlayerTime + 4)) {
        userSeeked(player.getCurrentTime());
    }
    lastPlayerTime = (player === null || player === void 0 ? void 0 : player.getCurrentTime()) || 0;
}, 1000);
// SENDING
function userPressedPlay() {
    console.log('user pressed play');
    socket.send('playing');
}
function userPressedPause() {
    console.log('user pressed pause');
    socket.send('paused');
}
function userSeeked(time) {
    socket.send('seek: ' + time);
}
function getVideoIdFromUrl(url) {
    var regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    var match = url.match(regExp);
    if (match && match[2].length === 11) {
        return match[2];
    }
    else {
        return '';
    }
}
// RECEIVING
function receivedPlay() {
    player === null || player === void 0 ? void 0 : player.playVideo();
}
function receivedPause() {
    player === null || player === void 0 ? void 0 : player.pauseVideo();
}
function receivedSeek(time) {
    player === null || player === void 0 ? void 0 : player.seekTo(time, true);
}
function receivedVideoId(videoId) {
    player === null || player === void 0 ? void 0 : player.loadVideoById(videoId);
}
var socket = new WebSocket('https://openRave.zeitvertreib.vip/backend?room=' + getQueryVariable('room'));
console.log(getQueryVariable('room'));
function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split("=");
        if (pair[0] == variable) {
            return pair[1];
        }
    }
    alert('You are not supposed to be here!!!');
    return '';
}
socket.onopen = function () {
    console.log('WebSocket is connected.');
};
socket.onmessage = function (event) {
    console.log('Message from server: ', event.data.toString());
    var message = event.data.toString();
    if (message.startsWith('playing')) {
        receivedPlay();
    }
    if (message.startsWith('paused')) {
        receivedPause();
    }
    if (message.startsWith('seek')) {
        var time = parseFloat(message.split(': ')[1]);
        receivedSeek(time);
    }
    if (message.startsWith('videoId')) {
        var videoId = message.split(': ')[1];
        receivedVideoId(videoId);
    }
};
socket.onclose = function () {
    console.log('WebSocket is closed.');
};
socket.onerror = function (error) {
    console.log('WebSocket error: ', error);
};
function submitNewUrl(url) {
    var videoId = getVideoIdFromUrl(url);
    if (videoId === '') {
        alert('Invalid YouTube URL');
        return;
    }
    socket.send('videoId: ' + videoId);
    player === null || player === void 0 ? void 0 : player.loadVideoById(videoId);
}
// Player Wrapper
setInterval(function () {
    if (player) {
        refreshCurrentTimeElement(player.getCurrentTime());
        refreshScrubberCursorPosition((player.getCurrentTime() / player.getDuration()) * 1000);
        refreshCoverImage(getVideoIdFromUrl(player.getVideoUrl()));
    }
}, 1000);
function onScrubbed(position) {
    var scrubBar = document.getElementById('scrubBar');
    scrubBar.style.background = "linear-gradient(to right, #FFF1E6 0%, #FFF1E6 ".concat(position / 10, "%, gray ").concat(position / 10, "%, gray 100%)");
    if (player) {
        refreshCurrentTimeElement((position / 1000) * player.getDuration());
    }
}
function onReady() {
    return __awaiter(this, void 0, void 0, function () {
        var coverImage, videoId;
        return __generator(this, function (_a) {
            if (player) {
                refreshEndTimeElement(player.getDuration());
                refreshCurrentTimeElement(player.getCurrentTime());
                coverImage = document.getElementById('coverImage');
                videoId = getVideoIdFromUrl(player.getVideoUrl());
                coverImage.src = "https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=".concat(videoId);
            }
            return [2 /*return*/];
        });
    });
}
function str_pad_left(string, pad, length) {
    return (new Array(length + 1).join(pad) + string).slice(-length);
}
function refreshMostMetadata() {
    return __awaiter(this, void 0, void 0, function () {
        var metadata;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, getOembedObject(getVideoIdFromUrl((player === null || player === void 0 ? void 0 : player.getVideoUrl()) || ''))];
                case 1:
                    metadata = _a.sent();
                    refreshSongInfo(metadata.author_name, metadata.title);
                    return [2 /*return*/];
            }
        });
    });
}
function refreshCurrentTimeElement(currentTimeInSeconds) {
    currentTimeInSeconds = Number(currentTimeInSeconds.toFixed(0));
    var currentTimeElement = document.getElementById('currentTime');
    var minutes = Math.floor(currentTimeInSeconds / 60);
    var seconds = currentTimeInSeconds - minutes * 60;
    var finalCurrentTimeTime = str_pad_left(minutes.toString(), '0', 2) + ':' + str_pad_left(seconds.toString(), '0', 2);
    currentTimeElement.innerHTML = finalCurrentTimeTime;
}
function refreshEndTimeElement(endTimeInSeconds) {
    endTimeInSeconds = Number(endTimeInSeconds.toFixed(0));
    var endTimeElement = document.getElementById('endTime');
    var minutes = Math.floor(endTimeInSeconds / 60);
    var seconds = endTimeInSeconds - minutes * 60;
    var finalEndTime = str_pad_left(minutes.toString(), '0', 2) + ':' + str_pad_left(seconds.toString(), '0', 2);
    endTimeElement.innerHTML = finalEndTime;
}
function refreshScrubberCursorPosition(position) {
    position = Number(position.toFixed(0));
    var scrubber = document.getElementById('scrubBar');
    scrubber.value = position.toString();
    onScrubbed(position);
}
function refreshCoverImage(videoId) {
    var coverImage = document.getElementById('coverImage');
    coverImage.src = "https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=".concat(videoId);
}
function refreshSongInfo(artistName, songName) {
    var artistNameElement = document.getElementById('artistName');
    var songNameElement = document.getElementById('songName');
    artistNameElement.innerHTML = artistName;
    songNameElement.innerHTML = songName;
}
function getOembedObject(videoId) {
    return fetch("https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=".concat(videoId, "&format=json"))
        .then(function (response) { return response.json(); });
}
