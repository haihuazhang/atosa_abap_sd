@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'print CDS of  Delivery Note serialnumber'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD028
  as select from    I_DeliveryDocumentItem         as _DeliveryDocumentItem
    left outer join ztsd001                        as _ztsd001                      on  _ztsd001.z_warranty_material = _DeliveryDocumentItem.Product
                                                                                    and _ztsd001.z_warranty_type     = 'EXTEND'
    left outer join ztmm001                        as _ztmm001s                     on  _DeliveryDocumentItem.Material               = _ztmm001s.product
                                                                                    and _DeliveryDocumentItem.YY1_WarrantySerial_DLI = _ztmm001s.zserialnumber
    left outer join I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument on  _SerialNumberDeliveryDocument.DeliveryDocument     = _DeliveryDocumentItem.DeliveryDocument
                                                                                    and _SerialNumberDeliveryDocument.DeliveryDocumentItem = _DeliveryDocumentItem.DeliveryDocumentItem
    left outer join ztmm001                        as _ztmm001                      on _SerialNumberDeliveryDocument.SerialNumber = _ztmm001.zserialnumber
{
//  key _SerialNumberDeliveryDocument.Equipment,
  key _DeliveryDocumentItem.DeliveryDocument,
  key _DeliveryDocumentItem.DeliveryDocumentItem,
      _DeliveryDocumentItem.Material,
      case
        when _ztsd001.z_warranty_material is not initial
      then
        case
            when _ztmm001s.zoldserialnumber is not initial
        then
            cast(concat_with_space(_DeliveryDocumentItem.YY1_WarrantySerial_DLI,_ztmm001s.zoldserialnumber,1) as abap.char(59))
        else
            cast(_DeliveryDocumentItem.YY1_WarrantySerial_DLI as abap.char(59))
        end
      else
        case
            when _ztmm001.zoldserialnumber is not initial
        then
            cast(concat_with_space(_SerialNumberDeliveryDocument.SerialNumber,_ztmm001.zoldserialnumber,1) as abap.char(59))
        else
            cast(_SerialNumberDeliveryDocument.SerialNumber as abap.char(59))
        end
      end as SerialNumber
      //    _Item,
      //    _Header
}
