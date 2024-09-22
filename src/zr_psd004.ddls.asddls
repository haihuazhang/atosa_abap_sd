@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'print CDS of  Pick List serialnumber'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD004 
as select from I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument
left outer join ztmm001 as _ztmm001 on _SerialNumberDeliveryDocument.SerialNumber = _ztmm001.zserialnumber
{
    key _SerialNumberDeliveryDocument.Equipment,
    key _SerialNumberDeliveryDocument.DeliveryDocument,
    key _SerialNumberDeliveryDocument.DeliveryDocumentItem,
    _SerialNumberDeliveryDocument.Material,
    case
    when _ztmm001.zoldserialnumber is not initial
    then
    cast(concat(concat(concat(_SerialNumberDeliveryDocument.SerialNumber,'('),_ztmm001.zoldserialnumber),')') as abap.char(59))
    else
    cast(_SerialNumberDeliveryDocument.SerialNumber as abap.char(59))
    end as SerialNumber
//    _Item,
//    _Header
}
