@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Print CDS of Extended Warranty Registration Information'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD008
    as projection on ZR_PSD008
{
    key SalesDocument,
    key SalesDocumentItem,
    WarrantyInfo,
    BusinessNameInfo,
    PersonInfo,
    YY1_BusinessAddress_SDI
}
