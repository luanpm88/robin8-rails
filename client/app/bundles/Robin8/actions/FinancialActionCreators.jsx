import actionTypes from '../constants/brandConstants';

const baseUrl = '/brand_api/v1';

export function alipayRecharge(credits, invite_code) {
  const data = { credits, invite_code };
  return {
    type: actionTypes.ALIPAY_RECHARGE,
    promise: fetch(`${baseUrl}/alipay_orders`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
      },
      credentials: 'same-origin',
      method: 'POST',
      body: JSON.stringify(data),
    }),
  };
}

export function fetchTransactions(current_page) {
  return {
    type: actionTypes.FETCH_TRANSACTIONS,
    promise: fetch(`${baseUrl}/transactions?page=${current_page.page}`, { credentials: 'same-origin' })
  };
}

export function fetchCredits(current_page) {
  return {
    type: actionTypes.FETCH_CREDITS,
    promise: fetch(`${baseUrl}/credits?page=${current_page.page}`, { credentials: 'same-origin' })
  };
}

export function fetchCommonInvoice() {
  return {
    type: actionTypes.FETCH_COMMON_INVOICE,
    promise: fetch(`${baseUrl}/invoices/common`, { credentials: 'same-origin' })
  }
}

export function saveCommonInvoice(title) {
  const data = { title };
  return {
    type: actionTypes.SAVE_COMMON_INVOICE,
    promise: fetch(`${baseUrl}/invoices/common`, {
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

export function updateCommonInvoice(title) {
  const data = { title };
  return {
    type: actionTypes.UPDATE_COMMON_INVOICE,
    promise: fetch(`${baseUrl}/invoices/common`, {
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


export function fetchSpecialInvoice() {
  return {
    type: actionTypes.FETCH_SPECIAL_INVOICE,
    promise: fetch(`${baseUrl}/invoices/special`, { credentials: 'same-origin' })
  }
}

export function saveSpecialInvoice(title, taxpayer_id, company_address, company_mobile, bank_name, bank_account) {
  const data = { title, taxpayer_id, company_address, company_mobile, bank_name, bank_account };
  return {
    type: actionTypes.SAVE_SPECIAL_INVOICE,
    promise: fetch(`${baseUrl}/invoices/special`, {
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

export function updateSpecialInvoice(title, taxpayer_id, company_address, company_mobile, bank_name, bank_account) {
  // { "title":"<TITLE>", "invoice_type":"special", "taxpayer_id":"<ID>", "company_address":"<ADDRESS>", "company_mobile":"<MOBILE>", "bank_name":"<BANK NAME>", "bank_account":"<BANK ACCOUNT>" }
  const data = { title, taxpayer_id, company_address, company_mobile, bank_name, bank_account };
  return {
    type: actionTypes.UPDATE_SPECIAL_INVOICE,
    promise: fetch(`${baseUrl}/invoices/special`, {
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

export function saveInvoiceHistory(credits, type, price_sheet) {
  const data = { credits, type, price_sheet };
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
