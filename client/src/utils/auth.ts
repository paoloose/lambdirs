import { base64encode } from './encoding';
import { openUrl } from './url';

export const CODE_VERIFIER_KEY = 'auth.code_verifier';
const OAUTH_SCOPES = 'email+openid+profile';

function generateCodeVerifier(length: number) {
    const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const values = crypto.getRandomValues(new Uint8Array(length));
    return values.reduce((acc, x) => acc + possible[x % possible.length], "");
}

async function generateCodeChallenge(codeVerifier: string) {
    const encoder = new TextEncoder();
    const data = encoder.encode(codeVerifier);
    const digest = await crypto.subtle.digest("SHA-256", data);
    return base64encode(digest);
}

async function generateOAuth2Codes() {
    const codeVerifier = generateCodeVerifier(100);
    const codeChallenge = await generateCodeChallenge(codeVerifier);
    return { codeVerifier, codeChallenge };
}


interface OpenOAuthUrlProps {
    url: string;
    clientId: string;
    redirectUri: string;
}

/*
Authorization endpoint

See AWS documentation
https://docs.aws.amazon.com/cognito/latest/developerguide/login-endpoint.html#get-login
*/
export async function openOAuthUrl({ url, clientId, redirectUri }: OpenOAuthUrlProps) {
    const { codeChallenge, codeVerifier } = await generateOAuth2Codes();
    window.localStorage.setItem(CODE_VERIFIER_KEY, codeVerifier);
    const oauthUrl = `${url}/oauth2/authorize?response_type=code&client_id=${clientId}&scope=${OAUTH_SCOPES}&redirect_uri=${encodeURIComponent(redirectUri)}&code_challenge=${codeChallenge}&code_challenge_method=S256`;
    openUrl(oauthUrl);
}

interface FetchOAuthTokensProps {
    url: string;
    clientId: string;
    redirectUri: string;
    code: string;
}

interface FetchOAuthTokensResponse {
    id_token: string,
    access_token: string,
    refresh_token: string,
    expires_in: number,
    token_type: string
}

/*
Fetches the user access tokens from the previously stored code verifier
Meant to be called in the OAuth2.0 redirect callback logic

See AWS documentation
https://docs.aws.amazon.com/cognito/latest/developerguide/token-endpoint.html
*/
export async function fetchOAuthTokens({ url, clientId, redirectUri, code }: FetchOAuthTokensProps): Promise<FetchOAuthTokensResponse> {
    const codeVerifier = window.localStorage.getItem(CODE_VERIFIER_KEY);

    if (!codeVerifier) {
        throw new Error('Code verifier not found');
    }

    const response = await fetch(`${url}/oauth2/token`, {
        method: 'POST',
        headers:{
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
            'redirect_uri': redirectUri,
            'client_id': clientId,
            'code': code,
            'grant_type': 'authorization_code',
            'code_verifier': codeVerifier,
        }).toString(),
    });

    if (!response.ok) {
        window.localStorage.removeItem(CODE_VERIFIER_KEY);
        throw new Error('Failed to fetch tokens:');
    }
    return response.json();
}
