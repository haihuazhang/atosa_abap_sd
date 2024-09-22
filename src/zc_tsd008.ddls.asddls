@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD008'
@ObjectModel.semanticKey: [ 'PropertyGroupCode' ]
define root view entity ZC_TSD008
  provider contract transactional_query
  as projection on ZR_TSD008
{
  key PropertyGroupCode,
  PropertyName,
  LocalLastChangedAt
  
}
