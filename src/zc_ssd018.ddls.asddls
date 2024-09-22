@EndUserText.label: 'Outbound Delivery Item CDS for PGI'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_SSD018 as projection on ZR_SSD018
{
    key OutboundDelivery,
    key OutboundDeliveryItem,
    StorageLocation,
    ActualDeliveryQuantity,
    DeliveryQuantityUnit,
    Product,
    PickedByUser,
    PickedTime,
    SerialNumberProfile,
    IsFullyScanned,
    PickedByUserName,
    ScannedQty,
    /* Associations */
    _ItemScannedQuantity
}
