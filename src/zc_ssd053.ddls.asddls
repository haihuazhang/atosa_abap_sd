@EndUserText.label: '103.14.1 Pick List Details'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_SSD053
  provider contract transactional_query
  as projection on ZR_SSD053
{

  key     DeliveryDocument,
  key     DeliveryDocumentItem,
          @ObjectModel: { text.element: [ 'DeliveryDocumentTypeName' ] }
          DeliveryDocumentType,
          _SalesDocItmFlow.SalesDocument,
          @ObjectModel: { text.element: [ 'OverallPickingStatusDesc' ] }
          OverallPickingStatus,
          @ObjectModel: { text.element: [ 'BusinessPartnerName' ] }
          SoldToParty,
          CreationDate,
          @ObjectModel: { text.element: [ 'PersonFullName' ] }
          CreatedByUser,
          Product,
          @ObjectModel: { text.element: [ 'PlantName' ] }
          Plant,
          @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
          ActualDeliveryQuantity,
          @Semantics.unitOfMeasure: true
          DeliveryQuantityUnit,

          @UI.hidden: true
          ShippingPoint,
          @UI.hidden: true
          _DeliveryDocumentTypeText.DeliveryDocumentTypeName,
          @UI.hidden: true
          _OverallPickingStatusText.OverallPickingStatusDesc,
          @UI.hidden: true
          _BusinessPartner.BusinessPartnerName,
          @UI.hidden: true
          _BusinessUserBasic.PersonFullName,
          @UI.hidden: true
          _Plant.PlantName,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_025'
  virtual ItemDescription : abap.sstring( 255 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_025'
          @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  virtual QuantityPicked  : abap.quan( 13, 3 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_025'
  virtual Remarks         : abap.sstring( 255 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_025'
  virtual FirstPickDate   : abap.dats,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_025'
  virtual WarehousePicker : abap.sstring( 255 )

}
