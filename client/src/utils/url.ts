export function openUrl(url: string) {
    window.location.href = url;
}

export function getQueryParam(key: string) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(key);
}
