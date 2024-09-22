@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of InvoiceHeader - OpenBalance'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD022
  as select from I_BillingDocument         as _BillingDocument
    inner join   I_OperationalAcctgDocItem as _AcctgDocItem on  _AcctgDocItem.PaymentReference = _BillingDocument.BillingDocument
                                                            and _AcctgDocItem.FiscalYear       = _BillingDocument.FiscalYear
                                                            and _AcctgDocItem.CompanyCode      = _BillingDocument.CompanyCode

{
  key _BillingDocument.BillingDocument,

      sum( case when _AcctgDocItem.ClearingJournalEntry is initial
                then cast( _AcctgDocItem.AmountInCompanyCodeCurrency as abap.dec( 23, 2 ) )
                else 0 end )            as Amount,

      _AcctgDocItem.CompanyCodeCurrency as Currency
}
where
  _AcctgDocItem.AccountingDocument is not initial
group by
  _BillingDocument.BillingDocument,
  _AcctgDocItem.CompanyCodeCurrency
