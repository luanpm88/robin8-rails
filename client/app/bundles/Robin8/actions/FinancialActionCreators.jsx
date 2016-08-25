import actionTypes from '../constants/brandConstants';

const baseUrl = "/brand_api/v1"

export function alipayRecharge(credits, tax, need_invoice, invite_code) {
  const data = { credits, tax, need_invoice, invite_code};
  return {
    type: actionTypes.ALIPAY_RECHARGE,
    promise: fetch(`${baseUrl}/alipay_orders`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data)
    })
  }
}

export function fetchTransactions(current_page) {
  return {
    type: actionTypes.FETCH_TRANSACTIONS,
    promise: fetch(`${baseUrl}/transactions?page=${current_page.page}`, { credentials: 'same-origin' })
  };
}

export function fetchInvoice() {
  return {
    type: actionTypes.FETCH_INVOICE,
    promise: fetch(`${baseUrl}/invoice`, { credentials: 'same-origin' })
  }
}

export function saveInvoice(title) {
  const data = { title };
  return {
    type: actionTypes.SAVE_INVOICE,
    promise: fetch(`${baseUrl}/invoice`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data)
    })
  }
}

export function updateInvoice(title) {
  const data = { title };
  return {
    type: actionTypes.UPDATE_INVOICE,
    promise: fetch(`${baseUrl}/invoice`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'put',
      body: JSON.stringify(data)
    })
  }
}

export function fetchInvoiceReceiver() {
  return {
    type: actionTypes.FETCH_INVOICE_RECEIVER,
    promise: fetch(`${baseUrl}/invoice_receiver`, { credentials: 'same-origin' })
  }
}

export function saveInvoiceReceiver(name, phone_number, address) {
  const data = { name, phone_number, address };
  return {
    type: actionTypes.SAVE_INVOICE_RECEIVER,
    promise: fetch(`${baseUrl}/invoice_receiver`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data)
    })
  }
}

export function updateInvoiceReceiver(name, phone_number, address) {
  const data = { name, phone_number, address };
  return {
    type: actionTypes.UPDATE_INVOICE_RECEIVER,
    promise: fetch(`${baseUrl}/invoice_receiver`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'put',
      body: JSON.stringify(data)
    })
  }
}

export function fetchAppliableCredits() {
  return {
    type: actionTypes.FETCH_APPLIABLE_CREDITS,
    promise: fetch(`${baseUrl}/invoice_histories/appliable_credits`, { credentials: 'same-origin' })
  }
}

export function fetchInvoiceHistories(current_page) {
  return {
    type: actionTypes.FETCH_INVOICE_HISTORIES,
    promise: fetch(`${baseUrl}/invoice_histories?page=${current_page.page}`, { credentials: 'same-origin' })
  }
}

export function saveInvoiceHistory(credits) {
  const data = { credits };
  return {
    type: actionTypes.SAVE_INVOICE_HISTORY,
    promise: fetch(`${baseUrl}/invoice_histories`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        "X-CSRF-Token": $('meta[name="csrf-token"]').attr('content')
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data)
    })
  }
}
