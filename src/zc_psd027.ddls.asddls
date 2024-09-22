@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Delivery Note Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD027
//provider contract transactional_query
  as projection on ZR_PSD027
{
  key     ZR_PSD027.DeliveryDocument,
  key     ZR_PSD027.DeliveryDocumentItem,
          ZR_PSD027.Material,
          ZR_PSD027.StorageLocation,
          @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
          ZR_PSD027.ActualDeliveryQuantity,
          //        @Semantics.unitOfMeasure: true
          ZR_PSD027.DeliveryQuantityUnit,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_005'
  virtual ProductLongText : abap.sstring( 255 ),
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_017'
  virtual LongTextItem : abap.sstring( 255 ),
//          _Header : redirected to parent ZC_PSD001,
          _SerialNumberDeliveryDocument : redirected to ZC_PSD028
}
