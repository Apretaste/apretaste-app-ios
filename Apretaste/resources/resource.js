
var apretaste = {

    url: "",
    popup: false,
    message: "",
    wait: false,
    doaction: function (href, popup, desc, wait) {
        apretaste.url =  href;
        apretaste.message = desc;
        apretaste.popup = popup;
        apretaste.wait = wait;
    }
};
