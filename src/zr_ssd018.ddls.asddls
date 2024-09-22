@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outbound Delivery Item CDS for PGI'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SSD018
  as select from I_OutboundDeliveryItem as _OutboundDeliveryItem
    inner join   I_OutboundDelivery     as _OutboundDelivery on _OutboundDelivery.OutboundDelivery = _OutboundDeliveryItem.OutboundDelivery
  //    inner join   I_Product              as _Product          on _Product.Product = _OutboundDeliveryItem.Product
    inner join   I_ProductPlantBasic    as _ProductPlant     on  _ProductPlant.Product = _OutboundDeliveryItem.Product
                                                             and _ProductPlant.Plant   = _OutboundDeliveryItem.Plant

  association [0..1] to ZR_SSD019           as _ItemScannedQuantity on  _ItemScannedQuantity.OutboundDelivery     = $projection.OutboundDelivery
                                                                    and _ItemScannedQuantity.OutboundDeliveryItem = $projection.OutboundDeliveryItem
  association [0..1] to I_BusinessUserBasic as _BusinessUser        on  _BusinessUser.UserID = _OutboundDelivery.LastChangedByUser
{
  key _OutboundDeliveryItem.OutboundDelivery,
  key _OutboundDeliveryItem.OutboundDeliveryItem,
      _OutboundDeliveryItem.StorageLocation,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _OutboundDeliveryItem.ActualDeliveryQuantity,
      _OutboundDeliveryItem.DeliveryQuantityUnit,
      _OutboundDeliveryItem.Product,
      _OutboundDelivery.LastChangedByUser as PickedByUser,
      _OutboundDelivery.LastChangeDate    as PickedTime,
      _ProductPlant.SerialNumberProfile,

      cast( case when _ItemScannedQuantity.ScannedQty = _OutboundDeliveryItem.ActualDeliveryQuantity then 'X'
       else '' end as abap_boolean )      as IsFullyScanned,
      _ItemScannedQuantity,
      _BusinessUser.PersonFullName        as PickedByUserName,
      _OutboundDeliveryItem.Plant,
      _OutboundDeliveryItem.ReferenceSDDocument,
      _OutboundDeliveryItem.ReferenceSDDocumentItem,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _ItemScannedQuantity.ScannedQty,
      _OutboundDeliveryItem.DeliveryDocumentItemCategory,
      _OutboundDeliveryItem.HigherLevelItem


}

where
  _OutboundDeliveryItem.PickingStatus <> ''


union select from I_CustomerReturnDeliveryItem as _CustomerReturnDeliveryItem
  inner join      I_CustomerReturnDelivery     as _CustomerReturnDelivery on _CustomerReturnDelivery.CustomerReturnDelivery = _CustomerReturnDeliveryItem.CustomerReturnDelivery
//    inner join   I_Product              as _Product          on _Product.Product = _OutboundDeliveryItem.Product
  inner join      I_ProductPlantBasic          as _ProductPlant           on  _ProductPlant.Product = _CustomerReturnDeliveryItem.Material
                                                                          and _ProductPlant.Plant   = _CustomerReturnDeliveryItem.Plant

association [0..1] to ZR_SSD019           as _ItemScannedQuantity on  _ItemScannedQuantity.OutboundDelivery     = $projection.OutboundDelivery
                                                                  and _ItemScannedQuantity.OutboundDeliveryItem = $projection.OutboundDeliveryItem
association [0..1] to I_BusinessUserBasic as _BusinessUser        on  _BusinessUser.UserID = _CustomerReturnDelivery.LastChangedByUser
{
  key _CustomerReturnDeliveryItem.CustomerReturnDelivery     as OutboundDelivery,
  key _CustomerReturnDeliveryItem.CustomerReturnDeliveryItem as OutboundDeliveryItem,
      _CustomerReturnDeliveryItem.StorageLocation,
      _CustomerReturnDeliveryItem.ActualDeliveryQuantity,
      _CustomerReturnDeliveryItem.DeliveryQuantityUnit,
      _CustomerReturnDeliveryItem.Material                   as Product,
      _CustomerReturnDelivery.LastChangedByUser              as PickedByUser,
      _CustomerReturnDeliveryItem.LastChangeDate             as PickedTime,
      _ProductPlant.SerialNumberProfile,

      cast( case when _ItemScannedQuantity.ScannedQty = _CustomerReturnDeliveryItem.ActualDeliveryQuantity then 'X'
       else '' end as abap_boolean )                         as IsFullyScanned,
      _ItemScannedQuantity,
      _BusinessUser.PersonFullName                           as PickedByUserName,
      _CustomerReturnDeliveryItem.Plant,
      _CustomerReturnDeliveryItem.ReferenceSDDocument,
      _CustomerReturnDeliveryItem.ReferenceSDDocumentItem,
      //      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _ItemScannedQuantity.ScannedQty,
      _CustomerReturnDeliveryItem.DeliveryDocumentItemCategory,
      _CustomerReturnDeliveryItem.HigherLevelItem

}

where
  _CustomerReturnDeliveryItem.PickingStatus <> ''
