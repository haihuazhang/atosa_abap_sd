@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AmountInCompanyCodeCurrency of Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD044
  as select from I_GLAccountLineItem as _GLAccountLineItem
{
  key _GLAccountLineItem.ReferenceDocument,
      cast(sum(_GLAccountLineItem.AmountInCompanyCodeCurrency) as abap.dec(23,2)) as AmountInCompanyCodeCurrency
}
where
       _GLAccountLineItem.SourceLedger = '0L'
  and(
       _GLAccountLineItem.GLAccount    = '2200000000'
    or _GLAccountLineItem.GLAccount    = '2200000004'
  )
group by
  _GLAccountLineItem.ReferenceDocument
