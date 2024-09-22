@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Scanned Qty CDS for Picking'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SSD024 as select from ZR_TSD013
    inner join  I_DeliveryDocumentItem as _DeliveryItem on  _DeliveryItem.DeliveryDocument     = ZR_TSD013.DeliveryNumber
                                                        and _DeliveryItem.DeliveryDocumentItem = ZR_TSD013.DeliveryItem
{
    key ZR_TSD013.DeliveryNumber    as OutboundDelivery,
    key ZR_TSD013.DeliveryItem      as OutboundDeliveryItem,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    cast ( count( distinct ZR_TSD013.SerialNumber ) as abap.quan( 13, 3 ) ) as ScannedQty,
    _DeliveryItem.DeliveryQuantityUnit
}
group by
    ZR_TSD013.DeliveryNumber,
    ZR_TSD013.DeliveryItem,
    _DeliveryItem.DeliveryQuantityUnit
union select from ZR_TSD015
{
    key DeliveryNumber  as OutboundDelivery,
    key DeliveryItem    as OutboundDeliveryItem,
        Scannedquantity as ScannedQty,
        Unitofmeasure   as DeliveryQuantityUnit
}
    
