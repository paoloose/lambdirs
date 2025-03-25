import { createTheme } from '@mantine/core';

export const theme = createTheme({
    primaryColor: 'primary',
    fontFamily: 'AmazonEmber, system-ui, Verdana, sans-serif',
    fontFamilyMonospace: 'Monaco, Courier, monospace',
    radius: {
        xs: '2px',
        sm: '4px',
        md: '8px',
        lg: '12px',
        xl: '16px',
    },
    primaryShade: {
        dark: 3,
        light: 6,
    },
    autoContrast: true,
    colors: {
        primary: [
            '#a6cef2',
            '#90c1ee',
            '#7ab5eb',
            '#539fe5',
            '#2183de',
            '#1e76c7',
            '#1b69b1',
            '#175c9b',
            '#144f85',
            '#0d3559'
        ],
        dark: [
            '#d1d5db',
            '#d1d5db',
            '#a8afba',
            '#6a737e',
            '#424650',
            '#424650',
            '#1b1b1f',
            '#101013',
            '#121214',
            '#09090a',
        ],
    }
});
