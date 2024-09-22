@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD019'
define root view entity ZC_TSD019
  provider contract transactional_query
  as projection on ZR_TSD019
{
  key ProcessUUID,
  Deliverynumber,
  DeliveryItem,
  OriginalQuantity,
  LatestQuantity,
  UnitOfMeasure,
  LocalLastChangedAt
  
}
