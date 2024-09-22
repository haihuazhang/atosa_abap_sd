@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Select  BillingDocumentItem amount of Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD041
  as select from I_BillingDocumentItem as _BillingDocumentItem
//    inner join   I_GLAccountLineItem   as _GLAccountLineItem on _BillingDocumentItem.BillingDocument = _GLAccountLineItem.ReferenceDocument
{
  key _BillingDocumentItem.BillingDocument,
      cast(sum(_BillingDocumentItem.NetAmount) as abap.dec(15,2) ) as NetAmount
}
where
       _BillingDocumentItem.ProductGroup         = 'Z001'
//  and  _GLAccountLineItem.SourceLedger           = '0L'
//  and(
//       _GLAccountLineItem.AccountingDocumentType = 'DR'
//    or _GLAccountLineItem.AccountingDocumentType = 'DG'
//    or _GLAccountLineItem.AccountingDocumentType = 'RV'
//  )
//  and(
//       _GLAccountLineItem.FinancialAccountType   = 'D'
//    or _GLAccountLineItem.FinancialAccountType   = 'S'
//  )
group by
  _BillingDocumentItem.BillingDocument
