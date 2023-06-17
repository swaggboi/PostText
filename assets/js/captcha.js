'use strict';

(() => {
    let captchaValue = document
        .querySelector('label[for="captcha"]')
        .textContent
        .match(/'(flag|bump)'/)[1];
    let captchaForm = document
        .querySelector('form[class="form-body"]');

    captchaForm.captcha.value = captchaValue;
    // Make 'em work for it
    window.crypto.subtle.generateKey({
        name: 'RSA-OAEP',
        modulusLength: 4096,
        publicExponent: new Uint8Array([1, 0, 1]),
        hash: 'SHA-512'
    }, false, ['encrypt', 'decrypt'])
        .finally(() => captchaForm.submit());
})();
