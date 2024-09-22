@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'get condition amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY13 
as select from ZR_WARRANTY10 as _warranty10
inner join ZR_WARRANTY12 as _warranty12   on _warranty10.SalesDoc = _warranty12.SalesDoc
{
   key _warranty10.SalesDocument,
   key _warranty10.SalesDocumentItem,
   @Semantics.amount.currencyCode: 'TransactionCurrency'
   case
      when (_warranty12.countConditionType > 1)
      then _warranty10.ConditionAmount
   end as ConditionAmount,
   _warranty10.TransactionCurrency
}
where _warranty10.ConditionType = 'PMP0'
union
select from ZR_WARRANTY10 as _warranty10
inner join ZR_WARRANTY12 as _warranty12   on _warranty10.SalesDoc = _warranty12.SalesDoc
{
   key _warranty10.SalesDocument,
   key _warranty10.SalesDocumentItem,
//   @Semantics.amount.currencyCode: 'TransactionCurrency'
   case
      when (_warranty12.countConditionType = 1)
      then _warranty10.ConditionAmount
   end as ConditionAmount,
   _warranty10.TransactionCurrency
}
where _warranty10.ConditionType = 'PPR0'
