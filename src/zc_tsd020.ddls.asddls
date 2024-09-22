@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD020'
@ObjectModel.semanticKey: [ 'Deliverynumber' ]
define root view entity ZC_TSD020
  provider contract transactional_query
  as projection on ZR_TSD020
{
  key Deliverynumber,
  CurrentProcessUUID,
  LocalLastChangedAt
  
}
