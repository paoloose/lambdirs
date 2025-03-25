
export function openUrl(url: string) {
    window.location.href = url;
}

interface OpenOAuthUrlProps {
    url: string;
    clientId: string;
    redirectUri: string;
}

const OAUTH_SCOPES = 'email+openid+profile';

/*
Authorization endpoint

See AWS documentation
https://docs.aws.amazon.com/cognito/latest/developerguide/login-endpoint.html#get-login
*/
export function openOAuthUrl({ url, clientId, redirectUri }: OpenOAuthUrlProps) {
    const oauthUrl = `${url}/oauth2/authorize?client_id=${clientId}&response_type=code&scope=${OAUTH_SCOPES}&redirect_uri=${encodeURIComponent(redirectUri)}`;
    openUrl(oauthUrl);
}
