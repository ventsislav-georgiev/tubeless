function loadPlayer(id, options) {
    disposePlayer(id);
    videojs(id, options);
}

function disposePlayer(id) {
    const player = videojs.getPlayer(id);
    if (player) {
        player.dispose();
    }
}