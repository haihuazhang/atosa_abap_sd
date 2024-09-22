@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions:true
@EndUserText.label: 'print CDS of  Pick List/DN'
define root view entity ZC_PSD001
   provider contract transactional_query
  as projection on ZR_PSD001
{

  key     ZR_PSD001.DeliveryDocument,
          ZR_PSD001.CreationDate,
          ZR_PSD001.PickDate,
          ZR_PSD001.OverallPickingStatus,
          ZR_PSD001.Status,
          ZR_PSD001.PlannedGoodsIssueDate,
          ZR_PSD001.DeliveryDate,
          ZR_PSD001.PersonFullName,
          ZR_PSD001.SalesDocument,
          ZR_PSD001.PurchaseOrderByCustomer,
          ZR_PSD001.Customer,
          ZR_PSD001.YY1_BusinessName_SDH,
          ZR_PSD001.StreetName,
          ZR_PSD001.CityRegionZipCode,
          ZR_PSD001.Country,
          ZR_PSD001.PlantName,
          ZR_PSD001.ShippingTypeName,
          ZR_PSD001.CurrentDateTime,
          ZR_PSD001.Plant,
          ZR_PSD001.Address,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_004'
  virtual LongText : abap.sstring( 255 ),
          ZR_PSD001.SDDocumentCategory,
//          _Item : redirected to composition child ZC_PSD003_TEST,
          _Item: redirected to ZC_PSD003
}
