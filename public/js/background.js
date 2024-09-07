(function () {
    function setImage(url) {
        document.body.style.backgroundImage = "url('" + url + "')";
    }

    switch (new Date().getMonth()) {
        case 0:
            setImage('/images/jwsfp1.gif');
            break;
        case 1:
            setImage('/images/outofthedarknessbkgtile.gif');
            break;
        case 2:
            setImage('/images/background2.gif');
            break;
        case 8:
        case 9:
            setImage('/images/halloween_background_1.gif');
            break;
        case 10:
            setImage('/images/topwwbackground.gif');
            break;
        case 11:
            setImage('/images/christmas.gif');
            break;
    }
})();
