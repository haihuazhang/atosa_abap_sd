@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Header - DueDate'
define view entity ZR_PSD020
  as select distinct from I_OperationalAcctgDocItem
{
  key BillingDocument,
      NetDueDate
}
where
  BillingDocument is not initial
