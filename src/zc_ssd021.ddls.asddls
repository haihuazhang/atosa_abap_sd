@EndUserText.label: 'Outbound Delivery Item CDS for Picking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_SSD021 as projection on ZR_SSD021
{
    key OutboundDelivery,
    key OutboundDeliveryItem,
    DeliveryDocumentType,
    Material,
    Plant,
    StorageLocation,
    BaseUnit,
    DeliveryQuantityUnit,
    TotalQty,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_003'
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    virtual PickedQty : abap.quan( 13, 0 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_003'
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    virtual OpenQty : abap.quan( 13, 0 ),
    PickingStatus,
    SerialNumberProfile,
//    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_003'
    IsFullyScanned,
    PickedByUser,
    PickedTime
}
