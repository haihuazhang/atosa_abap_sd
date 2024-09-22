@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions:true
@EndUserText.label: 'Print CDS of Delivery Note'
define root view entity ZC_PSD026C
   provider contract transactional_query
  as projection on ZR_PSD026C
{

  key     ZR_PSD026C.DeliveryDocument,
          ZR_PSD026C.CreationDate,
          ZR_PSD026C.OverallPickingStatus,
          ZR_PSD026C.PlannedGoodsIssueDate,
          ZR_PSD026C.PersonFullName,
          ZR_PSD026C.SalesDocument,
          ZR_PSD026C.PurchaseOrderByCustomer,
          ZR_PSD026C.Customer,
          ZR_PSD026C.YY1_BusinessName_SDH,
          ZR_PSD026C.StreetName,
          ZR_PSD026C.CityRegionZipCode,
          ZR_PSD026C.Country,
          ZR_PSD026C.PlantName,
          ZR_PSD026C.ShippingTypeName,
          ZR_PSD026C.CurrentDateTime,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_004'
  virtual LongText : abap.sstring( 255 ),
          ZR_PSD026C.ShippingPoint,
//          _Item : redirected to composition child ZC_PSD003_TEST,
          _Item: redirected to ZC_PSD027
}
