@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Extended Warranty Registration Information'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD008 
    as select from I_SalesDocumentItem as _SalesDocumentItem
{
    key _SalesDocumentItem.SalesDocument,
    key _SalesDocumentItem.SalesDocumentItem,
    case
    when(_SalesDocumentItem.YY1_WarrantyMaterial_SDI is not initial and _SalesDocumentItem.YY1_WarrantySerial_SDI is initial)
    then
    concat_with_space(_SalesDocumentItem.YY1_WarrantyMaterial_SDI,concat_with_space('-','(N/A)',1),1)
    when(_SalesDocumentItem.YY1_WarrantyMaterial_SDI is not initial and _SalesDocumentItem.YY1_WarrantySerial_SDI is not initial)
    then
    concat_with_space(_SalesDocumentItem.YY1_WarrantyMaterial_SDI,concat_with_space('-',_SalesDocumentItem.YY1_WarrantySerial_SDI,1),1)
    when(_SalesDocumentItem.YY1_WarrantyMaterial_SDI is initial and _SalesDocumentItem.YY1_WarrantySerial_SDI is not initial)
    then
    _SalesDocumentItem.YY1_WarrantySerial_SDI
    end as WarrantyInfo,
    concat_with_space(_SalesDocumentItem.YY1_BusinessNameSOITEM_SDI,_SalesDocumentItem.YY1_StoreNumber_SDI,1) as BusinessNameInfo,
    concat_with_space(concat_with_space(_SalesDocumentItem.YY1_FirstName_SDI,_SalesDocumentItem.YY1_LastName_SDI,1),_SalesDocumentItem.YY1_PhoneNumber_SDI,1)
    as PersonInfo,
    _SalesDocumentItem.YY1_BusinessAddress_SDI
}
