@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions:true
@EndUserText.label: 'Print CDS of Delivery Note'
define root view entity ZC_PSD026
   provider contract transactional_query
  as projection on ZR_PSD026
{

  key     ZR_PSD026.DeliveryDocument,
          ZR_PSD026.CreationDate,
          ZR_PSD026.PickDate,
          ZR_PSD026.OverallPickingStatus,
          ZR_PSD026.Status,
          ZR_PSD026.PlannedGoodsIssueDate,
          ZR_PSD026.DeliveryDate,
          ZR_PSD026.PersonFullName,
          ZR_PSD026.SalesDocument,
          ZR_PSD026.PurchaseOrderByCustomer,
          ZR_PSD026.Customer,
          ZR_PSD026.YY1_BusinessName_SDH,
          ZR_PSD026.StreetName,
          ZR_PSD026.CityRegionZipCode,
          ZR_PSD026.Country,
          ZR_PSD026.PlantName,
          ZR_PSD026.ShippingTypeName,
          ZR_PSD026.CurrentDateTime,
          ZR_PSD026.Plant,
          ZR_PSD026.Address,
          _Item: redirected to ZC_PSD027
}
