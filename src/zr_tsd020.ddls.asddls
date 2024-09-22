@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Current Process Record of PGI'
define root view entity ZR_TSD020
  as select from ztsd020
{
  key deliverynumber as Deliverynumber,
  current_process_uuid as CurrentProcessUUID,
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
