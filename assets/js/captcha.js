/*
'use strict';

document.getElementById('captcha').value =
*/

'use strict';

let captchaValue =
    document
        .querySelector('label[for="captcha"]')
        .textContent
        .match(/'(flag|bump)'/)[1];
