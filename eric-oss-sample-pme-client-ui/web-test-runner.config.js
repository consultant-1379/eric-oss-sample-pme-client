process.env.NODE_ENV = 'test';
const webTestRunner = require('@snowpack/web-test-runner-plugin');
const { defaultReporter } = require('@web/test-runner');
const { junitReporter } = require('@web/test-runner-junit-reporter');

module.exports = {
  coverage: true,
  coverageConfig: {
    exclude: [
      'libs/**',
      '**/node_modules/**/*',
      '**/web_modules/**/*',
      '**/npm/**/*',
    ],
  },
  nodeResolve: true,
  plugins: [webTestRunner()],
  files: 'test/**/*.test.js',
  reporters: [
    defaultReporter({ reportTestResults: true, reportTestProgress: true }),
    junitReporter({
      outputPath: './coverage/junit/test-results.xml',
      reportLogs: true,
    }),
  ],
};
