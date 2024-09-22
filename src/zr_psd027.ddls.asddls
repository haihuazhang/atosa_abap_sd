@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Delivery Note Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD027
  as select from I_DeliveryDocumentItem as _OutboundDeliveryItem
  association [0..*] to ZR_PSD028       as _SerialNumberDeliveryDocument        on  _SerialNumberDeliveryDocument.DeliveryDocument     = $projection.DeliveryDocument
                                                                                and _SerialNumberDeliveryDocument.DeliveryDocumentItem = $projection.DeliveryDocumentItem
{
  key _OutboundDeliveryItem.DeliveryDocument     as DeliveryDocument,
  key _OutboundDeliveryItem.DeliveryDocumentItem as DeliveryDocumentItem,
      _OutboundDeliveryItem.Material,
      _OutboundDeliveryItem.StorageLocation,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _OutboundDeliveryItem.ActualDeliveryQuantity,
      //        @Semantics.unitOfMeasure: true
      _OutboundDeliveryItem.DeliveryQuantityUnit,
      _SerialNumberDeliveryDocument
}
where _OutboundDeliveryItem.PickingStatus is not initial
//union select from I_CustomerReturnDeliveryItem as _OutboundDeliveryItem
//composition[0..*] of ZR_PSD004        as _SerialNumberDeliveryDocument
//association        to parent ZR_PSD001 as _Header                       on  $projection.DeliveryDocumet = _Header.Delivery
//{
//  key _OutboundDeliveryItem.CustomerReturnDelivery     as DeliveryDocumet,
//  key _OutboundDeliveryItem.CustomerReturnDeliveryItem as DeliveryDocumetItem,
//      _OutboundDeliveryItem.Material,
//      _OutboundDeliveryItem.StorageLocation,
//      _OutboundDeliveryItem.ActualDeliveryQuantity,
//      _OutboundDeliveryItem.DeliveryQuantityUnit,
//      _Header,
//      _SerialNumberDeliveryDocument
//}
