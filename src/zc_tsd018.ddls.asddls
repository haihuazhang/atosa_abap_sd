@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD018'
@ObjectModel.semanticKey: [ 'Material', 'Category' ]
define root view entity ZC_TSD018
  provider contract transactional_query
  as projection on ZR_TSD018
{
  key Material,
  key Category,
  LocalLastChangedAt
  
}
