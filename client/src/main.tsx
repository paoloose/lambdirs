import { WithLoggedUser } from './wrappers/with-logged-user.tsx';
import { MantineProvider } from '@mantine/core';
import { createRoot } from 'react-dom/client';
import { StrictMode } from 'react';
import { theme } from './theme.ts';
import { App } from './app.tsx';
import '@mantine/core/styles.css';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <MantineProvider theme={theme} defaultColorScheme='dark'>
      <WithLoggedUser>
        <App />
      </WithLoggedUser>
    </MantineProvider>
  </StrictMode>,
);
