@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD009'
@ObjectModel.semanticKey: [ 'ConsolidationKey' ]
define root view entity ZC_TSD009
  provider contract transactional_query
  as projection on ZR_TSD009
{
  key ConsolidationKey,
  LocalLastChangedAt
  
}
