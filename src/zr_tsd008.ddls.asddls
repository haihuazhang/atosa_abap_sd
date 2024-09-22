@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Maintain Property Group Code'
define root view entity ZR_TSD008
  as select from ztsd008 as PropertyGroup
{
  key property_group_code as PropertyGroupCode,
  property_name as PropertyName,
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
