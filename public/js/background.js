const bodyStyle = document.body.style;

function setImage(url) {
    bodyStyle.backgroundImage = "url('" + url + "')";
}

switch (new Date().getMonth()) {
    case 0:
        setImage('/images/jwsfp1.gif');
        break;
    case 3:
        setImage('/images/background2.gif');
        break;
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
