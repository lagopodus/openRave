document.getElementById('startRaveButton')?.addEventListener('click', startRave);
document.getElementById('joinRaveButton')?.addEventListener('click', joinRave);

function startRave(): void {
    let raveCode = Math.floor(100000 + Math.random() * 900000).toString();
    alert('Starting rave with code: ' + raveCode);
    window.location.replace("https://openRave.zeitvertreib.vip/room?room=" + raveCode);
}

function joinRave(): void {
    let raveCodeInputField = document.getElementById('joinRaveCode') as HTMLInputElement;
    let raveCode = raveCodeInputField.value;

    if (/^\d{6}$/.test(raveCode)) {
        alert('Joining rave with code: ' + raveCode);
        window.location.replace("https://openRave.zeitvertreib.vip/room?room=" + raveCode);
    } else {
        alert('Invalid rave code. Please enter a 6-digit numeric code.');
    }
}