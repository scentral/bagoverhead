$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.action == "open") {
            $(".bag").fadeIn(150);
        } else if (event.data.action == "close") {
            $(".bag").fadeOut(150);
        }
    })
})