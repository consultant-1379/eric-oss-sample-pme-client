/** customStatusCell
 * Component FdnTable is defined as
 * `<e-fdn-table>`
 *
 * @extends {LitComponent}
 */
import { LitComponent, html, definition } from '@eui/lit-component';
import style from './fdn-table.css';
import { logWarning } from '../../utils/logUtils.js';

export default class FdnTable extends LitComponent {
  // Uncomment this block to add initialization code
  // constructor() {
  //   super();
  //   // initialize
  // }

  static get components() {
    return {
      // register components here
    };
  }

  didConnect() {
    this._pollTableData();
  }

  /**
   * Returns the columns object.
   *
   * @function _getColumnHeaders
   * @private
   */
  _getColumnHeaders() {
    return [
      { title: 'FDN', attribute: 'fdn', sortable: true },
      { title: 'Session ID', attribute: 'pmeSessionId', resizable: false },
      { title: 'Timestamp', attribute: 'timestamp', resizable: false },
      {
        title: 'Status',
        attribute: 'status',
        cell: (row, column) => this._customStatusCell(row, column),
        resizable: false,
      },
    ];
  }

  /**
   * Returns the custom table cell html based on the 'status'.
   *
   * @function customStatusCell
   * @param row The current row of data.
   * @returns The table cell html.
   */
  _customStatusCell(row) {
    let content;
    const rowStatus = row.status || '';
    if (rowStatus === 'PENDING') {
      content = html`<eui-loader></eui-loader>`;
    } else {
      content = rowStatus;
    }
    return html`
      <div class="table__cell">
        <span class="table__cell-content">${content}</span>
      </div>
    `;
  }

  /**
   * Polls the verdicts endpoint for updates.
   *
   * @function _pollTableData
   * @private
   */
  _pollTableData = async () => {
    try {
      this._updateTableData();
      setTimeout(this._pollTableData, 1800000);
    } catch (err) {
      logWarning(`Failed to update executions data, reason: ${err}`);
    }
  };

  /**
   * Makes a REST call to get all rows from back-end.
   *
   * @function _updateTableData
   * @private
   */
  _updateTableData() {
    fetch('http://localhost:55654/v1/verdicts')
      .then(response => {
        if (!response.ok) {
          logWarning(
            `Get executions failed, reason: status code: ${response.status}, status text: ${response.statusText}`,
          );
          return Promise.reject(response.status);
        }
        return response.json();
      })
      .then(res => {
        this.data = res;
        console.log(res);
      })
      .catch(error => {
        console.log(error);
      });
  }

  /**
   * Render the <e-fdn-table> component. This function is called each time a
   * prop changes.
   */
  render() {
    const rowcount = html`<div class="table-row-count">
      <h3>Table Row Count (${this.data.length})</h3>
    </div>`;

    const table = html` <div class="app-table-container">
      <eui-table
        .columns=${this._getColumnHeaders()}
        .data=${this.data}
        .custom=${{
          onCreatedActionCell: row => html`
            <eui-tooltip message="My Action">
              <eui-icon
                name="document"
                @click="${() => {
                  this.bubble('trigger-flyout', row);
                }}"
              ></eui-icon>
            </eui-tooltip>
          `,
        }}
        sortable
        resizable
      ></eui-table>
    </div>`;
    return html`${rowcount}${table}`;
  }
}

/**
 * @property {Boolean} propOne - show active/inactive state.
 * @property {String} propTwo - shows the "Hello World" string.
 */
definition('e-fdn-table', {
  style,
  props: {
    data: {
      type: Array,
      default: [],
    },
  },
})(FdnTable);
