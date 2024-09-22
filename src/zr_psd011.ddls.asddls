@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Item'
define root view entity ZR_PSD011
  as select from    I_BillingDocumentItem as _BillingDocumentItem
    left outer join I_BillingDocument     as _BillingDocument on _BillingDocument.BillingDocument = _BillingDocumentItem.BillingDocument

  association [0..1] to I_BillingDocItemPrcgElmntBasic as _PPR0                    on  _PPR0.BillingDocument         = $projection.BillingDocument
                                                                                   and _PPR0.BillingDocumentItem     = $projection.BillingDocumentItem
                                                                                   and _PPR0.ConditionType           = 'PPR0'
                                                                                   and _PPR0.ConditionInactiveReason = ''

  association [0..1] to I_BillingDocItemPrcgElmntBasic as _ZDRN                    on  _ZDRN.BillingDocument         = $projection.BillingDocument
                                                                                   and _ZDRN.BillingDocumentItem     = $projection.BillingDocumentItem
                                                                                   and _ZDRN.ConditionType           = 'ZDRN'
                                                                                   and _ZDRN.ConditionInactiveReason = ''

  association [0..1] to I_BillingDocItemPrcgElmntBasic as _ZDC7                    on  _ZDC7.BillingDocument         = $projection.BillingDocument
                                                                                   and _ZDC7.BillingDocumentItem     = $projection.BillingDocumentItem
                                                                                   and _ZDC7.ConditionType           = 'ZDC7'
                                                                                   and _ZDC7.ConditionInactiveReason = ''

  association [0..1] to I_BillingDocItemPrcgElmntBasic as _D100                    on  _D100.BillingDocument         = $projection.BillingDocument
                                                                                   and _D100.BillingDocumentItem     = $projection.BillingDocumentItem
                                                                                   and _D100.ConditionType           = 'D100'
                                                                                   and _D100.ConditionInactiveReason = ''

  association [0..*] to ZR_PSD012                      as _InvoiceItemSerialNumber on  _InvoiceItemSerialNumber.BillingDocument     = $projection.BillingDocument
                                                                                   and _InvoiceItemSerialNumber.BillingDocumentItem = $projection.BillingDocumentItem
{

  key cast( _BillingDocumentItem.BillingDocument as zzesd015 preserving type ) as BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,
      cast( _BillingDocumentItem.Product as zzesd009 preserving type )         as Material,
      _BillingDocumentItem.BillingDocumentItemText,
      @Semantics.amount.currencyCode: 'Currency'
      _PPR0.ConditionRateAmount                                                as UnitPrice,

      @Semantics.amount.currencyCode: 'Currency'
      case when _BillingDocumentItem.SalesSDDocumentCategory = 'I'
           then _D100.ConditionAmount
           else _ZDRN.ConditionAmount    end                                   as DiscountAmount,

      case when _ZDRN.ConditionAmount is not null
           then cast( _ZDRN.ConditionAmount as abap.dec( 15, 2 ) )
           else 0 end                                                          as ConditionAmount_ZDRN,

      case when _ZDC7.ConditionAmount is not null
           then cast( _ZDC7.ConditionAmount as abap.dec( 15, 2 ) )
           else 0 end                                                          as ConditionAmount_ZDC7,

      case when _D100.ConditionAmount is not null
           then cast( _D100.ConditionAmount as abap.dec( 15, 2 ) )
           else 0 end                                                          as ConditionAmount_D001,

      _BillingDocumentItem.TransactionCurrency                                 as Currency,
      @Semantics.quantity.unitOfMeasure: 'Unit'
      _BillingDocumentItem.BillingQuantity                                     as Quantity,
      _BillingDocumentItem.BillingQuantityUnit                                 as Unit,
      @Semantics.amount.currencyCode: 'Currency'
      _BillingDocumentItem.NetAmount,
      _BillingDocumentItem.Subtotal1Amount,

      concat_with_space(_BillingDocumentItem.YY1_WarrantyMaterial_BDI,
                        _BillingDocumentItem.YY1_WarrantySerial_BDI, 1 )       as WarrantyInfo,

      _BillingDocumentItem.YY1_WarrantyMaterial_BDI                            as WarrantyMaterial,
      _BillingDocumentItem.YY1_WarrantySerial_BDI                              as WarrantySerial,
      _BillingDocumentItem.YY1_BusinessNameSOITEM_BDI                          as BusinessName,

      concat_with_space( concat_with_space(_BillingDocumentItem.YY1_FirstName_BDI,
                                           _BillingDocumentItem.YY1_LastName_BDI, 1 ),
                        _BillingDocumentItem.YY1_PhoneNumber_BDI, 1 )          as WarrantyRegistInfo,

      _BillingDocumentItem.YY1_FirstName_BDI                                   as FirstName,
      _BillingDocumentItem.YY1_LastName_BDI                                    as LastName,
      _BillingDocumentItem.YY1_PhoneNumber_BDI                                 as PhoneNumber,
      _BillingDocumentItem.YY1_BusinessAddress_BDI                             as Street,

      _BillingDocumentItem.SalesSDDocumentCategory                             as SalesSDDocumentCategory,

      _BillingDocument.BillingDocumentType,

      _InvoiceItemSerialNumber
}
