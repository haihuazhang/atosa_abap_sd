@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Total of 113.01.1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD062 
as select from I_SalesDocumentScheduleLine as _SalesDocumentScheduleLine
{
    key _SalesDocumentScheduleLine.SalesDocument,
    key _SalesDocumentScheduleLine.SalesDocumentItem,
    sum(cast(_SalesDocumentScheduleLine.OpenReqdDelivQtyInOrdQtyUnit as abap.dec(10,0))) as OpenReqdDelivQtyInOrdQtyUnit
}group by _SalesDocumentScheduleLine.SalesDocument,
          _SalesDocumentScheduleLine.SalesDocumentItem
