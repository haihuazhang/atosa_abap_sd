@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Item - SerialNumber'
@Metadata.allowExtensions: true
define root view entity ZR_PSD012
  as select from    I_BillingDocumentItem          as _BillingDocumentItem

    inner join      I_SerialNumberDeliveryDocument as _SerialNumber    on  _SerialNumber.DeliveryDocument     = _BillingDocumentItem.ReferenceSDDocument
                                                                       and _SerialNumber.DeliveryDocumentItem = _BillingDocumentItem.ReferenceSDDocumentItem

    left outer join ztmm001                        as _OldSerialNumber on  _OldSerialNumber.product       = _SerialNumber.Material
                                                                       and _OldSerialNumber.zserialnumber = _SerialNumber.SerialNumber
{

  key cast( _BillingDocumentItem.BillingDocument as zzesd015 preserving type ) as BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,

  key case when _OldSerialNumber.zoldserialnumber is null
           then ltrim( _SerialNumber.SerialNumber, '0' )
           when _OldSerialNumber.zoldserialnumber is initial
           then ltrim( _SerialNumber.SerialNumber, '0' )
           else concat( concat( concat_with_space( ltrim( _SerialNumber.SerialNumber, '0' ), '(', 1 ), _OldSerialNumber.zoldserialnumber ), ')' )
           end                                                                 as SerialNumber,

      _BillingDocumentItem.ReferenceSDDocumentCategory,
      _BillingDocumentItem.ReferenceSDDocument,
      _BillingDocumentItem.ReferenceSDDocumentItem
}
where
  _BillingDocumentItem.ReferenceSDDocumentCategory = 'J'
