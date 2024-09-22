@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Billing Document Rows'
define view entity ZR_SSD036
  as select from I_BillingDocumentItem
{
  key BillingDocument,
      count(*) as RowsCount
}
group by
  BillingDocument
