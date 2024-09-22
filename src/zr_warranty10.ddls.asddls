@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warranty Report- get condition amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY10
  as select from I_SalesDocItemPricingElement as _SalesDocItemPricingElement
//    inner join   I_SalesDocumentItem          as _SalesDocumentItem on  _SalesDocItemPricingElement.SalesDocument     = _SalesDocumentItem.SalesDocument
//                                                                    and _SalesDocItemPricingElement.SalesDocumentItem = _SalesDocumentItem.SalesDocumentItem
{
  _SalesDocItemPricingElement.SalesDocument,
  _SalesDocItemPricingElement.SalesDocumentItem,
  _SalesDocItemPricingElement.ConditionType,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  _SalesDocItemPricingElement.ConditionAmount,
  _SalesDocItemPricingElement.TransactionCurrency,
  concat(_SalesDocItemPricingElement.SalesDocument,_SalesDocItemPricingElement.SalesDocumentItem) as SalesDoc
}
where _SalesDocItemPricingElement.ConditionType = 'PMP0'
  or  _SalesDocItemPricingElement.ConditionType = 'PPR0'
