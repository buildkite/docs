import { INITIAL_VIEWPORTS } from '@storybook/addon-viewport';
import '../app/assets/stylesheets/application.scss';

const docsViewports = {
  screenXs: {
    name: 'screen-xs',
    styles: {
      width: '480px',
      height: '768px',
    },
  },
  screenSm: {
    name: 'screen-sm',
    styles: {
      width: '768px',
      height: '1024px',
    },
  },
  screenMd: {
    name: 'screen-md',
    styles: {
      width: '960px',
      height: '768px',
    },
  },
  screenLg: {
    name: 'screen-lg',
    styles: {
      width: '1280px',
      height: '832px',
    },
  },
  screenXl: {
    name: 'screen-xl',
    styles: {
      width: '1536px',
      height: '982px',
    },
  },
}

export const parameters = {
  actions: { argTypesRegex: "^on[A-Z].*" },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
  viewport: {
    viewports: { 
      ...docsViewports,
      ...INITIAL_VIEWPORTS,
    },
  },
};
