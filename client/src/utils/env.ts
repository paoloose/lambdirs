export const OAUTH_CLIENT_ID = ensureEnv('VITE_OAUTH_CLIENT_ID');
export const OAUTH_SERVER_URL = ensureEnv('VITE_OAUTH_SERVER_URL');
export const OAUTH_REDIRECT_URI = 'http://localhost:6969/callback';

function ensureEnv(name: string) {
    const value = import.meta.env[name];
    if (!value) {
        alert(`🗣️ Missing environment variable: ${name}`);
        throw new Error(`Missing environment variable: ${name}`);
    }
    return value;
}
