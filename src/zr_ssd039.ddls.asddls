@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Open Qty of Backorder Reoprt'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD039 
as select from I_MaterialDocumentItem_2 as _MaterialDocumentItem_2
inner join ZR_SSD038 as _SSD038 on _SSD038.MaterialDocument = _MaterialDocumentItem_2.MaterialDocument
                                and _SSD038.MaterialDocumentYear = _MaterialDocumentItem_2.MaterialDocumentYear
{
    key _MaterialDocumentItem_2.MaterialDocument,
    key _MaterialDocumentItem_2.MaterialDocumentItem,
    _MaterialDocumentItem_2.DeliveryDocument,
    _MaterialDocumentItem_2.DeliveryDocumentItem,
    _MaterialDocumentItem_2.GoodsMovementType,
    @Semantics.quantity.unitOfMeasure: 'EntryUnit'
    _MaterialDocumentItem_2.QuantityInEntryUnit,
    _MaterialDocumentItem_2.EntryUnit
}
where _MaterialDocumentItem_2.GoodsMovementType = '601' or _MaterialDocumentItem_2.GoodsMovementType = '602'
