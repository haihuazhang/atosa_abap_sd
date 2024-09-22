@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outbound Delivery Item CDS for Picking'
@Metadata.ignorePropagatedAnnotations:true
define root view entity ZR_SSD021 
  as select from I_OutboundDeliveryItem as _OutboundDeliveryItem
    inner join ZR_SSD012 as _OutboundDelivery on _OutboundDelivery.OutboundDelivery = _OutboundDeliveryItem.OutboundDelivery
    inner join I_ProductPlantBasic as _ProductPlant on  _ProductPlant.Product = _OutboundDeliveryItem.Product
                                                    and _ProductPlant.Plant   = _OutboundDeliveryItem.Plant
//    association [0..1] to I_BusinessUserBasic as _BusinessUserBasic on _BusinessUserBasic.UserID = _OutboundDelivery.LastChangedByUser
    left outer join ZR_SSD035 as _LatestRecord on _OutboundDeliveryItem.OutboundDelivery = _LatestRecord.DeliveryNumber
                                                      and _OutboundDeliveryItem.OutboundDeliveryItem = _LatestRecord.DeliveryItem
    association [0..1] to ZR_TSD013 as _ScannedRecord on _ScannedRecord.DeliveryNumber = $projection.OutboundDelivery
                                                     and _ScannedRecord.DeliveryItem = $projection.OutboundDeliveryItem
                                                     and _ScannedRecord.ScannedDate = _LatestRecord.ScannedDate
                                                     and _ScannedRecord.ScannedTime = _LatestRecord.ScannedTime
{
    
    key _OutboundDeliveryItem.OutboundDelivery,
    key _OutboundDeliveryItem.OutboundDeliveryItem,
    _OutboundDelivery.DeliveryDocumentType,
    _OutboundDelivery.SalesOrder,
    _OutboundDeliveryItem.Material,
    _OutboundDeliveryItem.Plant,
    _OutboundDeliveryItem.StorageLocation,
    _OutboundDeliveryItem.BaseUnit,
    _OutboundDeliveryItem.DeliveryQuantityUnit,
    @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
    _OutboundDeliveryItem.ActualDeliveryQuantity as TotalQty,
    _OutboundDeliveryItem.PickingStatus,
    _ScannedRecord.ScannedUserName as PickedByUser,
    _ScannedRecord.ScannedDate     as PickedTime,
    _ProductPlant.SerialNumberProfile,
    cast( case when _OutboundDeliveryItem.PickingStatus = 'C' then 'X'
    else '' end as abap_boolean )      as IsFullyScanned
//    _CustomerReturnItem.ReferenceSDDocument,
//    _CustomerReturnItem.ReferenceSDDocumentItem
}
where _OutboundDeliveryItem.PickingStatus <> ''
union select from I_CustomerReturnDeliveryItem as _CustomerReturnDeliveryItem
    inner join ZR_SSD012 as _OutboundDelivery on _OutboundDelivery.OutboundDelivery = _CustomerReturnDeliveryItem.CustomerReturnDelivery
    inner join I_ProductPlantBasic as _ProductPlant on  _ProductPlant.Product = _CustomerReturnDeliveryItem.Material
                                                    and _ProductPlant.Plant   = _CustomerReturnDeliveryItem.Plant
//    association [0..1] to I_BusinessUserBasic as _BusinessUserBasic on _BusinessUserBasic.UserID = _OutboundDelivery.LastChangedByUser
//    association [0..1] to ZR_TSD013 as _ScannedRecord on $projection.OutboundDelivery = _ScannedRecord.DeliveryNumber
//                                                      and $projection.OutboundDeliveryItem = _ScannedRecord.DeliveryItem
    left outer join ZR_SSD035 as _LatestRecord on _CustomerReturnDeliveryItem.CustomerReturnDelivery = _LatestRecord.DeliveryNumber
                                                      and _CustomerReturnDeliveryItem.CustomerReturnDeliveryItem = _LatestRecord.DeliveryItem
    association [0..1] to ZR_TSD013 as _ScannedRecord on _ScannedRecord.DeliveryNumber = $projection.OutboundDelivery
                                                     and _ScannedRecord.DeliveryItem = $projection.OutboundDeliveryItem
                                                     and _ScannedRecord.ScannedDate = _LatestRecord.ScannedDate
                                                     and _ScannedRecord.ScannedTime = _LatestRecord.ScannedTime
{
    key _CustomerReturnDeliveryItem.CustomerReturnDelivery as OutboundDelivery,
    key _CustomerReturnDeliveryItem.CustomerReturnDeliveryItem as OutboundDeliveryItem,
    _OutboundDelivery.DeliveryDocumentType,
    _OutboundDelivery.SalesOrder,
    _CustomerReturnDeliveryItem.Material,
    _CustomerReturnDeliveryItem.Plant,
    _CustomerReturnDeliveryItem.StorageLocation,
    _CustomerReturnDeliveryItem.BaseUnit,
    _CustomerReturnDeliveryItem.DeliveryQuantityUnit,
    _CustomerReturnDeliveryItem.ActualDeliveryQuantity as TotalQty,
    _CustomerReturnDeliveryItem.PickingStatus,
    _ScannedRecord.ScannedUserName          as PickedByUser,
    _ScannedRecord.ScannedDate              as PickedTime,
    _ProductPlant.SerialNumberProfile,
    cast( case when _CustomerReturnDeliveryItem.PickingStatus = 'C' then 'X'
    else '' end as abap_boolean )                as IsFullyScanned
//    _CustomerReturnItem.ReferenceSDDocument,
//    _CustomerReturnItem.ReferenceSDDocumentItem
}
where _CustomerReturnDeliveryItem.PickingStatus <> ''
