var _a, _b;
(_a = document.getElementById('startRaveButton')) === null || _a === void 0 ? void 0 : _a.addEventListener('click', startRave);
(_b = document.getElementById('joinRaveButton')) === null || _b === void 0 ? void 0 : _b.addEventListener('click', joinRave);
function startRave() {
    var raveCode = Math.floor(100000 + Math.random() * 900000).toString();
    alert('Starting rave with code: ' + raveCode);
    window.location.replace("https://openRave.zeitvertreib.vip/room?room=" + raveCode);
}
function joinRave() {
    var raveCodeInputField = document.getElementById('joinRaveCode');
    var raveCode = raveCodeInputField.value;
    if (/^\d{6}$/.test(raveCode)) {
        alert('Joining rave with code: ' + raveCode);
        window.location.replace("https://openRave.zeitvertreib.vip/room?room=" + raveCode);
    }
    else {
        alert('Invalid rave code. Please enter a 6-digit numeric code.');
    }
}
