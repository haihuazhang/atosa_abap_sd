@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD014'
@ObjectModel.semanticKey: [ 'StorageLocation' ]
define root view entity ZC_TSD014
  provider contract transactional_query
  as projection on ZR_TSD014
{
  key StorageLocation,
  WriteBackSN,
  LocalLastChangedAt
  
}
