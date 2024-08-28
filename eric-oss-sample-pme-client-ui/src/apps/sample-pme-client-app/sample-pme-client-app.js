/**
 * EricOssSamplePmeClientApp is defined as
 * `<e-eric-oss-sample-pme-client-app>`
 *
 * @extends {App}
 */
import { App, html, definition } from '@eui/app';
import { Table } from '@eui/table';
import { Button, Dialog, Textarea, Spinner, Loader } from '@eui/base';
import { FlyoutPanel } from '@eui/layout';
import style from './sample-pme-client-app.css';
import FdnTable from '../../components/fdn-table/fdn-table.js';

export default class SamplePmeClientApp extends App {
  // Uncomment this block to add initialization code
  // constructor() {
  //   super();
  //   // initialize
  // }

  static get components() {
    return {
      // register components here
      'eui-button': Button,
      'eui-table': Table,
      'eui-dialog': Dialog,
      'eui-spinner': Spinner,
      'eui-textarea': Textarea,
      'eui-flyout-panel': FlyoutPanel,
      'e-fdn-table': FdnTable,
      'eui-loader': Loader,
    };
  }

  didConnect() {
    this.bubble('app:title', { displayName: 'EPME Client' });
    this.bubble('app:subtitle', { subtitle: 'EPME Client Subtitle' });
  }

  /**
   * Returns the columns object for expandable table.
   *
   * @function _getColumnHeaders
   * @private
   */
  _getExpandableTableColumnHeaders() {
    return [
      { title: 'KPI', attribute: 'kpiName' },
      { title: 'Type', attribute: 'kpiType' },
      { title: 'Threshold', attribute: 'thresholdValue' },
      { title: 'Value', attribute: 'kpiValue' },
      {
        title: 'Verdict',
        attribute: 'verdict',
        cell: (row) => this._customVerdictCell(row),
      },
    ];
  }

  _getTableElement() {
    return this.shadowRoot.querySelector('e-fdn-table');
  }

  /**
   * Returns the custom table cell html based on the 'kpiVerdict'.
   *
   * @function customVerdictCell
   * @param row The current row of data.
   * @returns The table cell html.
   */
  _customVerdictCell(row) {
    let tableCellIcon;
    const rowVerdict = row.verdict;
    if (rowVerdict === 'NOT_DEGRADED') {
      tableCellIcon = html`<eui-icon
        name="success"
        color="var(--green-35)"
      ></eui-icon>`;
    } else if (rowVerdict === 'NOT_POSSIBLE') {
      tableCellIcon = html`<eui-icon
        name="triangle-warning"
        color="var(--yellow-43)"
      ></eui-icon>`;
    } else if (rowVerdict === 'DEGRADED') {
      tableCellIcon = html`<eui-icon
        name="failed"
        color="var(--red-52)"
      ></eui-icon>`;
    }
    return html` <div class="table__cell">
      <span class="table__cell-content"
        >${tableCellIcon}&nbsp;${rowVerdict.replace('_', ' ')}</span
      >
    </div>`;
  }

  /**
   * Returns the name text field element.
   *
   * @returns The name text field element.
   * @function _getNameField
   * @private
   */
  _getNameField() {
    return this.shadowRoot.querySelector('eui-text-field#name');
  }

  /**
   * Returns the duration field element.
   *
   * @returns The duration field element.
   * @function _getDurationField
   * @private
   */
  _getDurationField() {
    return this.shadowRoot.querySelector('eui-spinner');
  }

  /**
   * Returns the configId field element.
   *
   * @returns The configId field element.
   * @function _getPmeConfigIdField
   * @private
   */
  _getPmeConfigIdField() {
    return this.shadowRoot.querySelector('eui-text-field#configuration-id');
  }

  /**
   * Returns the fdns field element.
   *
   * @returns The fdns field element.
   * @function _getFdnsField
   * @private
   */
  _getFdnsField() {
    return this.shadowRoot.querySelector('eui-textarea#fdns');
  }

  parseFdns(fdns) {
    console.log(fdns.replaceAll('"', '').split('\n'));
    return fdns.replaceAll('"', '').split('\n');
  }

  /**
   * Creates the 'Create Session' button if there is execution data.
   *
   * @function _createSession
   * @private
   */
  _createSession() {
    fetch('http://localhost:55654/v1/sessions', {
      method: 'POST',
      headers: {
        'Content-Type': `application/json; charset=utf-8`,
        Accept: 'application/json',
      },
      body: JSON.stringify({
        name: this._getNameField().value,
        duration: this._getDurationField().value,
        pmeConfigId: this._getPmeConfigIdField().value,
        fdns: this.parseFdns(this._getFdnsField().value),
      }),
    })
      .then(response => {
        if (!response.ok) {
          console.log(
            `Post Job failed, reason: status code: ${response.status}, status text: ${response.statusText}`,
          );
          return Promise.reject(response.status);
        }
        this._getDialogElement().hideDialog();
        this._getTableElement()._updateTableData();
        console.log(response.json());
        return response.json();
      })
      .catch(error => {
        console.log(error);
      });
  }

  /**
   * Returns the eui dialog.
   *
   * @returns The eui dialog.
   * @function _getDialogElement
   * @private
   */
  _getDialogElement() {
    return this.shadowRoot.querySelector('eui-dialog');
  }

  /**
   * Creates the 'Upload FDNs' button if there is execution data.
   *
   * @function _showDialog
   * @private
   */
  _showDialog() {
    this._getDialogElement().showDialog();
  }

  _getFlyoutElement() {
    return this.shadowRoot.querySelector('eui-flyout-panel');
  }

  _showFlyout(row) {
    this.flyoutData = row;
    this._getFlyoutElement().show = true;
  }

  /**
   * Render the <e-eric-oss-sample-pme-client-app> app. This function is called each time a
   * prop changes.
   */
  render() {
    const header = html` <p class="app-header">
      <eui-button
        @click="${() => this._showDialog()}"
        class="create-session-button"
        id="createSessionButton"
        >Create Session</eui-button
      >
    </p>`;

    const dialog = html` <eui-dialog
      label="Create PME Session"
      id="dialogElement"
    >
      <div slot="content">
        <div>
          <p>Name</p>
          <eui-text-field id="name" maxlength="255" fullwidth></eui-text-field>
        </div>
        <div>
          <p>Configuration ID</p>
          <eui-text-field
            id="configuration-id"
            fullwidth
            maxlength="255"
          ></eui-text-field>
        </div>
        <p>Monitoring Period (hours)</p>
        <eui-spinner step="1" value="1" max="24" min="1"></eui-spinner>
        <div style="min-width:700px">
          <p>FDNs</p>
          <eui-textarea id="fdns" fullwidth></eui-textarea>
        </div>
      </div>
      <eui-button
        slot="bottom"
        primary
        @click="${() => this._createSession()}"
        ?disabled="${this.disableSave}"
        >Start</eui-button
      >
    </eui-dialog>`;

    const flyout = html`<eui-flyout-panel
      width="1500"
      panel-title="Kpi Verdicts for ${this.flyoutData.fdn}"
    >
      <div slot="content">
        <eui-table
          .columns=${this._getExpandableTableColumnHeaders()}
          .data=${this.flyoutData.kpiVerdicts.filter(
            element => element.verdict !== 'NOT_POSSIBLE',
          )}
        ></eui-table>
      </div>
    </eui-flyout-panel>`;

    const table = html`<e-fdn-table
      @trigger-flyout=${event => this._showFlyout(event.detail)}
    ></e-fdn-table>`;
    return html`${header}${dialog}${table}${flyout}`;
  }
}

definition('e-eric-oss-sample-pme-client-app', {
  style,
  props: {
    flyoutData: {
      type: Object,
      default: { kpiVerdicts: [] },
    },
  },
})(SamplePmeClientApp);

SamplePmeClientApp.register();
