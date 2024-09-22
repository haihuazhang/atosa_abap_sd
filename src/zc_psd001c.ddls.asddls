@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions:true
@EndUserText.label: 'print CDS of  Pick List/DN'
define root view entity ZC_PSD001C
   provider contract transactional_query
  as projection on ZR_PSD001C
{

  key     ZR_PSD001C.DeliveryDocument,
          ZR_PSD001C.CreationDate,
          ZR_PSD001C.OverallPickingStatus,
          ZR_PSD001C.PlannedGoodsIssueDate,
          ZR_PSD001C.PersonFullName,
          ZR_PSD001C.SalesDocument,
          ZR_PSD001C.PurchaseOrderByCustomer,
          ZR_PSD001C.Customer,
          ZR_PSD001C.YY1_BusinessName_SDH,
          ZR_PSD001C.StreetName,
          ZR_PSD001C.CityRegionZipCode,
          ZR_PSD001C.Country,
          ZR_PSD001C.PlantName,
          ZR_PSD001C.ShippingTypeName,
          ZR_PSD001C.CurrentDateTime,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_004'
  virtual LongText : abap.sstring( 255 ),
          ZR_PSD001C.ShippingPoint,
//          _Item : redirected to composition child ZC_PSD003_TEST,
          _Item: redirected to ZC_PSD003
}
