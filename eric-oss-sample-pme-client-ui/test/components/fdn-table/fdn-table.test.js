import { expect, fixture } from '@open-wc/testing';
import FdnTable from '../../../src/components/fdn-table/fdn-table.js';

describe('FdnTable Component Tests', () => {
  before(() => {
    FdnTable.register();
  });

  describe('Basic component setup', () => {
    it('should render <e-fdn-table>', async () => {
      const component = await fixture(
        '<e-fdn-table></e-fdn-table>',
      );
      const headingTag = component.shadowRoot.querySelector('h1');

      expect(
        headingTag.textContent,
        '"Your component markup goes here" was not found',
      ).to.equal('Your component markup goes here');
    });
  });
});
