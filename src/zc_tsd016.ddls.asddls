@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD016'
@ObjectModel.semanticKey: [ 'BillingDocument' ]
define root view entity ZC_TSD016
  provider contract transactional_query
  as projection on ZR_TSD016
{
  key BillingDocument,
  LocalLastChangedAt
  
}
