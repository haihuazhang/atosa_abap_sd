@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Atosa Plant List'
define root view entity ZR_TSD003
  as select from ztsd003
{
  key uuid as UUID,
  customer as Customer,
  full_name as FullName,
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
