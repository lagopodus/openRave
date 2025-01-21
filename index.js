// 2. This code loads the IFrame Player API code asynchronously.
var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

var player = false;
function onYouTubeIframeAPIReady() {
    player = new YT.Player('video', {
        height: '360',
        width: '640',
        videoId: 'xmhtV4270NU',
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
    if (event.data == YT.PlayerState.ENDED) {
        console.log('ended');
    }
    if (event.data == YT.PlayerState.BUFFERING) {
        console.log('buffering');
    }
    if (event.data == YT.PlayerState.PAUSED) {
        userPressedPause();
    } else if (event.data == YT.PlayerState.PLAYING) {
        userPressedPlay();
    }
}

var lastPlayerTime = 0;
setInterval(function () {
    if (player && (lastPlayerTime - 4 > player.getCurrentTime() || player.getCurrentTime() > lastPlayerTime + 4)) {
        userSeeked(player.getCurrentTime());
    }
    lastPlayerTime = player.getCurrentTime();
}, 1000);

//SENDING
function userPressedPlay() {
    console.log('user pressed play');
    socket.send('play');
}

function userPressedPause() {
    console.log('user pressed pause');
    socket.send('pause');
}

function userSeeked(time) {
    socket.send('seek: ' + time);
}

function getVideoIdFromUrl(url) {
    var regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    var match = url.match(regExp);
    if (match && match[2].length == 11) {
        socket.send('videoId: ' + match[2]);
        player.loadVideoById(match[2]);
    } else {
        alert('Invalid YouTube URL');
    }
}

//RECEIVING
function receivedPlay() {
    player.playVideo();
}

function receivedPause() {
    player.pauseVideo();
}

function receivedSeek(time) {
    player.seekTo(time);
}

function receivedVideoId(videoId) {
    player.loadVideoById(videoId);
}

var socket = new WebSocket('ws://10.20.135.12:8081');

socket.onopen = function (event) {
    console.log('WebSocket is connected.');
};

socket.onmessage = function (event) {
    var message = event.data;
    if (message.startsWith('play')) {
        receivedPlay();
    }
    if (message.startsWith('pause')) {
        receivedPause();
    }
    if (message.startsWith('seek')) {
        var time = message.split(': ')[1];
        receivedSeek(time);
    }
    if (message.startsWith('videoId')) {
        var videoId = message.split(': ')[1];
        receivedVideoId(videoId);
    }
};

socket.onclose = function (event) {
    console.log('WebSocket is closed.');
};

socket.onerror = function (error) {
    console.log('WebSocket error: ', error);
};


//Player Wrapper

setInterval(function () {
    //sync player progress with scrub bar
    refreshCurrentTimeElement(player.getCurrentTime());
    refreshScrubberCursorPosition(player.getCurrentTime() / player.getDuration() * 1000);
}, 1000);

function onScrubbed(position) {
    console.log('scrubbed to ' + position);
    var scrubBar = document.getElementById('scrubBar');
    scrubBar.style.background = `linear-gradient(to right, #FFF1E6 0%, #FFF1E6 ${position / 10}%, gray ${position / 10}%, gray 100%)`;

    refreshCurrentTimeElement(position / 1000 * player.getDuration());
    console.log(position / 1000 * player.getDuration());
}

function onReady() {
    refreshEndTimeElement(player.getDuration());
    refreshCurrentTimeElement(player.getCurrentTime());
}

function str_pad_left(string, pad, length) {
    return (new Array(length + 1).join(pad) + string).slice(-length);
}

function refreshCurrentTimeElement(currentTimeInSeconds) {
    currentTimeInSeconds = Number(currentTimeInSeconds).toFixed(0);
    var currentTimeElement = document.getElementById('currentTime');

    var minutes = Math.floor(currentTimeInSeconds / 60);
    var seconds = currentTimeInSeconds - minutes * 60;
    const finalCurrentTimeTime = str_pad_left(minutes, '0', 2) + ':' + str_pad_left(seconds, '0', 2);

    currentTimeElement.innerHTML = finalCurrentTimeTime;
}

function refreshEndTimeElement(endTimeInSeconds) {
    endTimeInSeconds = Number(endTimeInSeconds).toFixed(0);
    var endTimeElement = document.getElementById('endTime');

    minutes = Math.floor(endTimeInSeconds / 60);
    seconds = endTimeInSeconds - minutes * 60;
    const finalEndTime = str_pad_left(minutes, '0', 2) + ':' + str_pad_left(seconds, '0', 2);

    endTimeElement.innerHTML = finalEndTime;
}

function refreshScrubberCursorPosition(position) {
    position = Number(position).toFixed(0);

    var scrubber = document.getElementById('scrubBar');
    scrubber.value = position;

    onScrubbed(position);
}