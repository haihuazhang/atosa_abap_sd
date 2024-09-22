@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD004'
@ObjectModel.semanticKey: [ 'DeliveryNumber', 'DeliveryItem', 'Material', 'SerialNumber' ]
define root view entity ZC_TSD004
  provider contract transactional_query
  as projection on ZR_TSD004
{
  key DeliveryNumber,
  key DeliveryItem,
  key Material,
  key SerialNumber,
      Plant,
      StorageLocation,
      OldSerialNumber,
      PostingDate,
      PgiIndicator,
      CurrentProcessUUID,
      LocalLastChangedAt
}
