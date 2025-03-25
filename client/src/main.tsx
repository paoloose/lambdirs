import { MantineProvider } from '@mantine/core';
import { createRoot } from 'react-dom/client';
import { theme } from './theme.ts';
import { App } from './app.tsx';
import '@mantine/core/styles.css';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <MantineProvider theme={theme} defaultColorScheme='dark'>
    <App />
  </MantineProvider>
);
