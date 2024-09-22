@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Pick List/DN Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD003
//provider contract transactional_query
  as projection on ZR_PSD003
{
  key     ZR_PSD003.DeliveryDocument,
  key     ZR_PSD003.DeliveryDocumentItem,
          ZR_PSD003.Material,
          ZR_PSD003.StorageLocation,
          @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
          ZR_PSD003.ActualDeliveryQuantity,
          //        @Semantics.unitOfMeasure: true
          ZR_PSD003.DeliveryQuantityUnit,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_005'
  virtual ProductLongText : abap.sstring( 255 ),
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_017'
  virtual LongTextItem : abap.sstring( 255 ),
//          _Header : redirected to parent ZC_PSD001,
          _SerialNumberDeliveryDocument : redirected to ZC_PSD004
}
