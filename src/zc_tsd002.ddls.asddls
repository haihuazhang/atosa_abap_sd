@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD002'
define root view entity ZC_TSD002
  provider contract transactional_query
  as projection on ZR_TSD002
//  association [0..*] to I_SalesOrganization as _SalesOrganization
{
  key UUID,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' }}]
  Salesorganization,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentType', element: 'SalesDocumentType' }}]
  Salesdocumenttype,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_StorageLocation', element: 'StorageLocation' }}]
  Storagelocation,
  LocalLastChangedAt
  
}
