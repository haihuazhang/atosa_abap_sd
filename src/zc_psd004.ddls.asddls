@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'print CDS of  Pick List serialnumber'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD004
  as projection on ZR_PSD004
{
  key     ZR_PSD004.Equipment,
  key     ZR_PSD004.DeliveryDocument,
  key     ZR_PSD004.DeliveryDocumentItem,
          ZR_PSD004.SerialNumber,
          ZR_PSD004.Material
}
