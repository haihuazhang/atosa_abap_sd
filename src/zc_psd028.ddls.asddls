@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'print CDS of  Delivery Note serialnumber'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD028
  as projection on ZR_PSD028
{
  key     ZR_PSD028.DeliveryDocument,
  key     ZR_PSD028.DeliveryDocumentItem,
          ZR_PSD028.SerialNumber,
          ZR_PSD028.Material
}
