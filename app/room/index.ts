// 2. This code loads the IFrame Player API code asynchronously.
const tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
const firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode?.insertBefore(tag, firstScriptTag);

let player: YT.Player | null = null;
let lastPlayerTime = 0;

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

function onPlayerStateChange(event: YT.OnStateChangeEvent) {
    if (event.data === YT.PlayerState.ENDED) {
        console.log('ended');
    }
    if (event.data === YT.PlayerState.BUFFERING) {
        console.log('buffering');
    }
    if (event.data === YT.PlayerState.PAUSED) {
        userPressedPause();
    } else if (event.data === YT.PlayerState.PLAYING) {
        userPressedPlay();
    }

    refreshMostMetadata();
}

setInterval(() => {
    if (player && (lastPlayerTime - 4 > player.getCurrentTime() || player.getCurrentTime() > lastPlayerTime + 4)) {
        userSeeked(player.getCurrentTime());
    }
    lastPlayerTime = player?.getCurrentTime() || 0;
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

function userSeeked(time: number) {
    socket.send('seek: ' + time);
}

function getVideoIdFromUrl(url: string): string {
    const regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    const match = url.match(regExp);
    if (match && match[2].length === 11) {
        return match[2];
    } else {
        return '';
    }
}

// RECEIVING
function receivedPlay() {
    player?.playVideo();
}

function receivedPause() {
    player?.pauseVideo();
}

function receivedSeek(time: number) {
    player?.seekTo(time, true);
}

function receivedVideoId(videoId: string) {
    player?.loadVideoById(videoId);
}

function submitNewUrl(url: string): void {
    const videoId = getVideoIdFromUrl(url);
    if (videoId === '') {
        alert('Invalid YouTube URL');
        return;
    }
    socket.send('videoId: ' + videoId);
    player?.loadVideoById(videoId);
}

// Player Wrapper
setInterval(() => {
    if (player) {
        refreshCurrentTimeElement(player.getCurrentTime());
        refreshScrubberCursorPosition((player.getCurrentTime() / player.getDuration()) * 1000);
        refreshCoverImage(getVideoIdFromUrl(player.getVideoUrl()));
    }
}, 1000);

setInterval(() => {
    socket.send('keepalive');
}, 10000);

function onScrubbed(position: number) {
    const scrubBar = document.getElementById('scrubBar') as HTMLDivElement;
    scrubBar.style.background = `linear-gradient(to right, #FFF1E6 0%, #FFF1E6 ${position / 10}%, gray ${position / 10}%, gray 100%)`;

    if (player) {
        refreshCurrentTimeElement((position / 1000) * player.getDuration());
    }
}

var socket: WebSocket;

async function onReady() {
    if (player) {
        refreshEndTimeElement(player.getDuration());
        refreshCurrentTimeElement(player.getCurrentTime());

        const coverImage = document.getElementById('coverImage') as HTMLImageElement;
        const videoId = getVideoIdFromUrl(player.getVideoUrl());
        coverImage.src = `https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=${videoId}`;
    }

    socket = new WebSocket('https://openRave.zeitvertreib.vip/backend?room=' + getQueryVariable('room'));
    console.log(getQueryVariable('room'));

    function getQueryVariable(variable: string): string {
        var query: String = window.location.search.substring(1);
        var vars: String[] = query.split("&");
        for (var i=0;i<vars.length;i++) {
        var pair: string[] = vars[i].split("=");
        if (pair[0] == variable) {
            return pair[1];
        }
        } 
        alert('You are not supposed to be here!!!');
        return '';
    }

    socket.onopen = () => {
        console.log('WebSocket is connected.');
    };

    socket.onmessage = (event) => {
        console.log('Message from server: ', event.data.toString());
        const message = event.data.toString();
        if (message.startsWith('playing')) {
            receivedPlay();
        }
        if (message.startsWith('paused')) {
            receivedPause();
        }
        if (message.startsWith('seek')) {
            const time = parseFloat(message.split(': ')[1]);
            receivedSeek(time);
        }
        if (message.startsWith('videoId')) {
            const videoId = message.split(': ')[1];
            receivedVideoId(videoId);
        }
    };

    socket.onclose = () => {
        console.log('WebSocket is closed.');
    };

    socket.onerror = (error) => {
        console.log('WebSocket error: ', error);
    };
}

function str_pad_left(string: string, pad: string, length: number) {
    return (new Array(length + 1).join(pad) + string).slice(-length);
}

interface OembedMetadata {
    title: string;
    author_name: string;
    author_url: string;
    type: string;
    height: number;
    width: number;
    version: string;
    provider_name: string;
    provider_url: string;
    thumbnail_height: number;
    thumbnail_width: number;
    thumbnail_url: string;
    html: string;
}

async function refreshMostMetadata(): Promise<void> {
    const metadata: OembedMetadata = await getOembedObject(getVideoIdFromUrl(player?.getVideoUrl() || ''));
    refreshSongInfo(metadata.author_name, metadata.title);
    return;
}

function refreshCurrentTimeElement(currentTimeInSeconds: number): void {
    currentTimeInSeconds = Number(currentTimeInSeconds.toFixed(0));
    const currentTimeElement = document.getElementById('currentTime') as HTMLDivElement;

    const minutes = Math.floor(currentTimeInSeconds / 60);
    const seconds = currentTimeInSeconds - minutes * 60;
    const finalCurrentTimeTime = str_pad_left(minutes.toString(), '0', 2) + ':' + str_pad_left(seconds.toString(), '0', 2);

    currentTimeElement.innerHTML = finalCurrentTimeTime;
}

function refreshEndTimeElement(endTimeInSeconds: number): void {
    endTimeInSeconds = Number(endTimeInSeconds.toFixed(0));
    const endTimeElement = document.getElementById('endTime') as HTMLDivElement;

    const minutes = Math.floor(endTimeInSeconds / 60);
    const seconds = endTimeInSeconds - minutes * 60;
    const finalEndTime = str_pad_left(minutes.toString(), '0', 2) + ':' + str_pad_left(seconds.toString(), '0', 2);

    endTimeElement.innerHTML = finalEndTime;
}

function refreshScrubberCursorPosition(position: number): void {
    position = Number(position.toFixed(0));

    const scrubber = document.getElementById('scrubBar') as HTMLInputElement;
    scrubber.value = position.toString();

    onScrubbed(position);
}

function refreshCoverImage(videoId: string): void {
    const coverImage = document.getElementById('coverImage') as HTMLImageElement;
    coverImage.src = `https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=${videoId}`;
}

function refreshSongInfo(artistName: string, songName: string): void {
    const artistNameElement = document.getElementById('artistName') as HTMLDivElement;
    const songNameElement = document.getElementById('songName') as HTMLDivElement;
    artistNameElement.innerHTML = artistName;
    songNameElement.innerHTML = songName;
}

function getOembedObject(videoId: string): Promise<OembedMetadata> {
    return fetch(`https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${videoId}&format=json`)
        .then(response => response.json());
}