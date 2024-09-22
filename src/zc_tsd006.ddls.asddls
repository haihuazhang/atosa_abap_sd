@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD006'
define root view entity ZC_TSD006
  provider contract transactional_query
  as projection on ZR_TSD006
{
  key UUID,
  ZOrderType,
  LocalLastChangedAt
  
}
