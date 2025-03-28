import React, { useEffect } from 'react';
import { NoLogin } from '@/components/no-login/no-login';
import { useUser } from '@/stores/user-store';
import { LoadingFullscreenOverlay } from '@/components/overlays/loading-fullscreen';

interface WithLoggedUserProps {
  children: React.ReactNode;
}

export function WithLoggedUser({ children }: WithLoggedUserProps) {
  const user = useUser();

  useEffect(() => {
    useUser.getState().fetch();
  }, []);

  if (user.data === 'loading') {
    return <LoadingFullscreenOverlay />;
  }

  if (!user.data || user.data === 'error') {
    // maybe showing an 'error ocurred' popup?
    return <NoLogin />;
  }

  return children;
}
