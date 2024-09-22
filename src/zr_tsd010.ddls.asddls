@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED National Accounts Team CSR'
define root view entity ZR_TSD010
  as select from ztsd010
{
  key national_accounts_team_csr as NationalAccountsTeamCsr,
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
