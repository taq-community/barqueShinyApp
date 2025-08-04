Shiny.addCustomMessageHandler('scrollLogToBottom', function (id) {
    var el = document.getElementById(id);
    if (el) {
        el.scrollTop = el.scrollHeight;
    }
});
