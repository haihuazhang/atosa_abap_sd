@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD015'
@ObjectModel.semanticKey: [ 'DeliveryNumber', 'DeliveryItem' ]
define root view entity ZC_TSD015
  provider contract transactional_query
  as projection on ZR_TSD015
{
  key DeliveryNumber,
  key DeliveryItem,
  Material,
  Plant,
  StorageLocation,
  Scannedquantity,
  Unitofmeasure,
  LocalLastChangedAt
  
}
