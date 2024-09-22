@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD003'
define root view entity ZC_TSD003
  provider contract transactional_query
  as projection on ZR_TSD003
{
  key UUID,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer', element: 'Customer' }}]
  Customer,
  FullName,
  LocalLastChangedAt
  
}
