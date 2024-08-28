/**
 * Integration tests for <e-eric-oss-sample-pme-client-app>
 */
import { expect, fixture } from '@open-wc/testing';
import '../../../src/apps/sample-pme-client-app/sample-pme-client-app.js';

describe('SamplePmeClientApp Application Tests', () => {
  describe('Basic application setup', () => {
    it('should create a new <e-eric-oss-sample-pme-client-app>', async () => {
      const element = await fixture('<e-eric-oss-sample-pme-client-app></e-eric-oss-sample-pme-client-app>');
      const headingTag = element.shadowRoot.querySelector('h1');

      expect(
        headingTag.textContent,
        '"Your app markup goes here" was not found',
      ).to.equal('Your app markup goes here');
    });
  });
});
