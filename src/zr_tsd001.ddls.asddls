@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD001'
define root view entity ZR_TSD001
  as select from ztsd001
{
  key uuid as UUID,
  z_warranty_material as ZWarrantyMaterial,
  z_warranty_type as ZWarrantyType,
  product_group as ProductGroup,
  product as Product,
  z_warranty_defalut as ZWarrantyDefalut,
  z_warranty_months as ZWarrantyMonths,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
