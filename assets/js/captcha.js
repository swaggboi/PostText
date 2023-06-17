'use strict';

(() => {
    // Make 'em work for it!
    let doCryptoStuff = window.crypto.subtle.generateKey({
        name: 'RSA-OAEP',
        modulusLength: 4096,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-512'
    }, false, ['encrypt', 'decrypt']);
    let captchaValue = document
        .querySelector('label[for="captcha"]')
        .textContent
        .match(/'(flag|bump)'/)[1];
    let captchaForm = document
        .querySelector('form[class="form-body"]');

    captchaForm.captcha.readOnly = true;
    captchaForm.captcha.value = '⏳';

    doCryptoStuff
        .then(() => {
            captchaForm.captcha.value = captchaValue;
            captchaForm.submit();
        })
        .catch((err) => {
            captchaForm.captcha.value = null;
            captchaForm.captcha.readOnly = false;
            console.log(err);
        });
})();
