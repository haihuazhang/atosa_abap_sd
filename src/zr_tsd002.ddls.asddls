@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD002'
define root view entity ZR_TSD002
  as select from ztsd002
{
  key uuid as UUID,
  salesorganization as Salesorganization,
  salesdocumenttype as Salesdocumenttype,
  storagelocation as Storagelocation,
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
