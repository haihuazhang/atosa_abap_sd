@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Billing Document SDDocumentCategory'
define view entity ZR_SSD037
  as select distinct from I_BillingDocumentItem as _BillingDocumentItem
    inner join            ZR_SSD036             as _SSD036 on _SSD036.BillingDocument = _BillingDocumentItem.BillingDocument
{
  key _BillingDocumentItem.BillingDocument
}
where
      _SSD036.RowsCount                            >= 1
  and _BillingDocumentItem.SalesSDDocumentCategory = 'I'
