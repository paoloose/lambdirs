
export function openUrl(url: string) {
    window.location.href = url;
}

interface OpenOAuthUrlProps {
    url: string;
    clientId: string;
    redirectUri: string;
}

const OAUTH_SCOPES = 'email+openid+profile';

function generateCodeVerifier() {
    const array = new Uint8Array(32);
    window.crypto.getRandomValues(array);
    return btoa(String.fromCharCode.apply(null, array as any))
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=+$/, ''); // Base64 URL Encoding
}

async function generateCodeChallenge(codeVerifier: string) {
    const encoder = new TextEncoder();
    const data = encoder.encode(codeVerifier);
    const digest = await crypto.subtle.digest("SHA-256", data);
    return btoa(String.fromCharCode(...new Uint8Array(digest)))
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=+$/, ''); // Base64 URL Encoding
}

async function generateOAuth2Codes() {
    const codeVerifier = generateCodeVerifier();
    const codeChallenge = await generateCodeChallenge(codeVerifier);
    return { codeVerifier, codeChallenge };
}

/*
Authorization endpoint

See AWS documentation
https://docs.aws.amazon.com/cognito/latest/developerguide/login-endpoint.html#get-login
*/
export function openOAuthUrl({ url, clientId, redirectUri }: OpenOAuthUrlProps) {
    const oauthUrl = `${url}/oauth2/authorize?client_id=${clientId}&response_type=code&scope=${OAUTH_SCOPES}&redirect_uri=${encodeURIComponent(redirectUri)}`;
    openUrl(oauthUrl);
}
