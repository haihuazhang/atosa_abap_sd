@EndUserText.label: 'Print CDS of Invoice Item - SerialNumber'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PSD012
//  provider contract transactional_query
  as projection on ZR_PSD012
{
  key BillingDocument,
  key BillingDocumentItem,
  key SerialNumber,
      ReferenceSDDocumentCategory,
      ReferenceSDDocument,
      ReferenceSDDocumentItem
}
