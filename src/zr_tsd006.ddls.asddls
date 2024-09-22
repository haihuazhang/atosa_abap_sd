@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD006'
define root view entity ZR_TSD006
  as select from ztsd006
{
  key uuid as UUID,
  z_order_type as ZOrderType,
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
