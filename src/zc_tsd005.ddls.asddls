@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD005'
define root view entity ZC_TSD005
  provider contract transactional_query
  as projection on ZR_TSD005
{
  key UUID,
  SalesDocumentType,
  SalesDocumentItemCategory,
  Material,
  OrderQuantity,
  OrderUnit,
  LocalLastChangedAt
  
}
