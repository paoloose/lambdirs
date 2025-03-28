import { useEffect, useState } from 'react';
import { ACCESS_TOKEN_KEY, fetchOAuthTokens, REFRESH_TOKEN_KEY } from '@/utils/auth';
import { getQueryParam } from '@/utils/url';
import { OAUTH_CLIENT_ID, OAUTH_REDIRECT_URI, OAUTH_SERVER_URL } from '@/utils/env';
import { Redirect } from 'wouter';
import { LoadingFullscreenOverlay } from '../overlays/loading-fullscreen';

export function OAuthCallback() {
  const [redirect, setRedirect] = useState(false);

  useEffect(() => {
    const code = getQueryParam('code');
    if (!code) {
      alert('redirecting...');
      return;
    }

    fetchOAuthTokens({
      code: code,
      clientId: OAUTH_CLIENT_ID,
      redirectUri: OAUTH_REDIRECT_URI,
      url: OAUTH_SERVER_URL,
    }).then((tokens) => {
      window.localStorage.setItem(ACCESS_TOKEN_KEY, tokens.access_token);
      window.localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refresh_token);
      setRedirect(true);
    }).catch((err) => {
      console.error(err);
      setRedirect(true);
    });
  }, []);

  if (redirect) {
    return <Redirect to='/' />
  }

  return (
    <LoadingFullscreenOverlay />
  );
}
