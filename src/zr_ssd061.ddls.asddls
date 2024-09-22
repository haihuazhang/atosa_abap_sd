@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Status of 113.01.1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD061 
as select from I_SalesDocumentScheduleLine as _SalesDocumentScheduleLine
{
    key _SalesDocumentScheduleLine.SalesDocument,
    key _SalesDocumentScheduleLine.SalesDocumentItem,
    cast(_SalesDocumentScheduleLine.OpenReqdDelivQtyInOrdQtyUnit as abap.dec(15,2)) as OpenReqdDelivQtyInOrdQtyUnit
}where _SalesDocumentScheduleLine.OpenReqdDelivQtyInOrdQtyUnit is not initial
