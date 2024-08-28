const { nodeResolve } = require('@rollup/plugin-node-resolve');
const { devDependencies } = require('./package.json');
const externalModules = require('./public/config.package.json').modules;

/** @type {import("snowpack").SnowpackUserConfig } */
module.exports = {
  workspaceRoot: '/',
  mount: {
    public: '/',
    src: '/src',
    './node_modules/@eui/theme/dist/fonts': {
      url: '/assets/fonts',
      resolve: false,
      static: true,
    },
    './node_modules/@eui/theme': {
      url: '/libs/shared/@eui/theme',
      static: true,
    },
    './node_modules/@eui/container': {
      url: '/libs/shared/@eui/container',
      static: true,
    },
  },
  plugins: ['@eui/import-css-plugin'],
  packageOptions: {
    rollup: {
      plugins: [nodeResolve()],
    },
    external: [
      ...Object.keys(devDependencies),
      ...externalModules.map(module => module.name),
    ],
    knownEntrypoints: ['@open-wc/testing-helpers'],
  },
  devOptions: {},
  buildOptions: {
    metaUrlPath: 'libs',
  },
};
