@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD012'
@ObjectModel.semanticKey: [ 'DeliveryNumber', 'DeliveryItem' ]
define root view entity ZC_TSD012
  provider contract transactional_query
  as projection on ZR_TSD012
{
  key DeliveryNumber,
  key DeliveryItem,
  Material,
  Plant,
  StorageLocation,
  PgiIndicator,
  ZoldSerialNumber,
  Scannedquantity,
  Unitofmeasure,
  CreatedAt,
  LocalLastChangedAt
  
}
