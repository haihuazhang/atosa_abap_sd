@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD011'
@ObjectModel.semanticKey: [ 'Project' ]
define root view entity ZC_TSD011
  provider contract transactional_query
  as projection on ZR_TSD011
{
  key Project,
  LocalLastChangedAt
  
}
