@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AdditionalCustomerGroup1 of Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD045
  as select from I_BillingDocumentItem as _BillingDocumentItem
{
  key _BillingDocumentItem.BillingDocument,
      max(_BillingDocumentItem.AdditionalCustomerGroup1) as AdditionalCustomerGroup1
}
group by
  _BillingDocumentItem.BillingDocument
