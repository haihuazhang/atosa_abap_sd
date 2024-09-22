@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Open Qty of Backorder Reoprt'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD038 
as select from I_MaterialDocumentItem_2 as _MaterialDocumentItem_2
{
    key max(_MaterialDocumentItem_2.MaterialDocument) as MaterialDocument,
    max(_MaterialDocumentItem_2.MaterialDocumentYear) as MaterialDocumentYear
}group by _MaterialDocumentItem_2.DeliveryDocument
//          _MaterialDocumentItem_2.DeliveryDocumentItem
