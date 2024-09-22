@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD001'
//@ObjectModel.semanticKey: [ 'ZWarrantyMaterial', 'ZWarrantyType', 'ProductGroup', 'Product','ZWarrantyDefalut' ]
define root view entity ZC_TSD001
  provider contract transactional_query
  as projection on ZR_TSD001
{
  key UUID,
  ZWarrantyMaterial,
  ZWarrantyType,
  ProductGroup,
  Product,
  ZWarrantyDefalut,
  ZWarrantyMonths,
  LocalLastChangedAt
  
}
