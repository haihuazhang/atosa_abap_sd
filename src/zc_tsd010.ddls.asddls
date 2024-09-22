@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD010'
@ObjectModel.semanticKey: [ 'NationalAccountsTeamCsr' ]
define root view entity ZC_TSD010
  provider contract transactional_query
  as projection on ZR_TSD010
{
  key NationalAccountsTeamCsr,
  LocalLastChangedAt
  
}
