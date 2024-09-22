@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Consolidation Keys'
define root view entity ZR_TSD009
  as select from ztsd009
{
  key consolidation_key as ConsolidationKey,
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
