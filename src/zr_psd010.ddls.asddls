@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Header'
define root view entity ZR_PSD010
  as select from    I_BillingDocument as _BillingDocument
    left outer join ZR_PSD024         as _PSD024 on _PSD024.BillingDocument = _BillingDocument.BillingDocument

  association [0..1] to I_BillingDocumentPartner as _Billto            on  _Billto.BillingDocument = $projection.BillingDocument
                                                                       and _Billto.PartnerFunction = 'RE'
  association [0..1] to I_Address_2              as _BilltoAddress     on  _BilltoAddress.AddressID = $projection.BilltoAddressID

  association [0..1] to I_BillingDocumentPartner as _Deliveryto        on  _Deliveryto.BillingDocument = $projection.BillingDocument
                                                                       and _Deliveryto.PartnerFunction = 'WE'
  association [0..1] to I_Address_2              as _DeliverytoAddress on  _DeliverytoAddress.AddressID = $projection.DeliveryAddressID

  association [0..1] to I_BillingDocumentPartner as _SalesRep          on  _SalesRep.BillingDocument = $projection.BillingDocument
                                                                       and _SalesRep.PartnerFunction = 'Z0'
  association [0..1] to I_Address_2              as _SalesRepAddress   on  _SalesRepAddress.AddressID = $projection.SalesRepAddressID

  association [0..1] to I_BusinessPartner        as _BusinessPartner   on  _BusinessPartner.BusinessPartner = _BillingDocument.SoldToParty
  association [0..1] to I_PaymentTermsText       as _PaymentTermsText  on  _PaymentTermsText.PaymentTerms = $projection.PaymentTerms
                                                                       and _PaymentTermsText.Language     = $session.system_language
  association [0..1] to I_Plant                  as _Plant             on  _Plant.Plant = $projection.Plant
  association [0..1] to I_ShippingTypeText       as _ShippingTypeText  on  _ShippingTypeText.ShippingType = $projection.ShippingType
                                                                       and _ShippingTypeText.Language     = $session.system_language

  association [0..1] to ZR_PSD020                as _AcctgDocItem1     on  _AcctgDocItem1.BillingDocument = $projection.BillingDocument
  association [0..1] to ZR_PSD021                as _AcctgDocItem2     on  _AcctgDocItem2.BillingDocument = $projection.BillingDocument
  association [0..1] to ZR_PSD022                as _AcctgDocItem3     on  _AcctgDocItem3.BillingDocument = $projection.BillingDocument

  association [0..*] to ZR_PSD030                as _InvoiceItem       on  _InvoiceItem.BillingDocument = $projection.BillingDocument
  association [0..1] to ZR_SSD037                as _SSD037            on  _SSD037.BillingDocument = $projection.BillingDocument

{
  key  cast( _BillingDocument.BillingDocument as zzesd015 preserving type )                    as BillingDocument,
       _BillingDocument.AccountingTransferStatus                                               as PostingStatus,
       _BillingDocument.BillingDocumentDate,
       _PSD024.PurchaseOrderByCustomer                                                         as PurchaseOrder,
       cast( _PSD024.SalesDocument as zzesd014 preserving type )                               as SalesOrder,
       _Billto.AddressID                                                                       as BilltoAddressID,
       _Deliveryto.AddressID                                                                   as DeliveryAddressID,
       _SalesRep.AddressID                                                                     as SalesRepAddressID,

       case when _BusinessPartner.BusinessPartnerIDByExtSystem is not initial
            then concat_with_space( concat_with_space( ltrim( cast( _BillingDocument.SoldToParty as zzesd004 preserving type ), '0' ), '/', 1),
                                    _BusinessPartner.BusinessPartnerIDByExtSystem, 1 )
            else ltrim( cast( _BillingDocument.SoldToParty as zzesd004 preserving type ), '0' )
            end                                                                                as CustomerID,

       _BillingDocument.CustomerPaymentTerms                                                   as PaymentTerms,
       _AcctgDocItem1.NetDueDate                                                               as DueDate,

       _PSD024.Plant,

       concat( concat( _Plant.PlantName, '-' ), _PSD024.Plant )                                as ShipFrom,

       _PSD024.ShippingType,

       _BillingDocument.YY1_TrackingNumber_BDH                                                 as TrackingNumber,

       @Semantics.amount.currencyCode: 'Currency'
       case when _BillingDocument.BillingDocumentType = 'G2' or _BillingDocument.BillingDocumentType = 'S2'
            then _BillingDocument.TotalNetAmount * -1
            else _BillingDocument.TotalNetAmount end                                           as TotalNetAmount,

       @Semantics.amount.currencyCode: 'Currency'
       case when _BillingDocument.BillingDocumentType = 'G2' or _BillingDocument.BillingDocumentType = 'S2'
            then _BillingDocument.TotalTaxAmount * -1
            else _BillingDocument.TotalTaxAmount end                                           as TotalTaxAmount,

       @Semantics.amount.currencyCode: 'Currency'
       case when _BillingDocument.BillingDocumentType = 'G2' or _BillingDocument.BillingDocumentType = 'S2'
            then ( _BillingDocument.TotalNetAmount + _BillingDocument.TotalTaxAmount ) * -1
            else _BillingDocument.TotalNetAmount + _BillingDocument.TotalTaxAmount end         as InvoiceTotal,

       @Semantics.amount.currencyCode: 'Currency'
       case when _AcctgDocItem2.Amount is not null
            then _AcctgDocItem2.Amount
            else _AcctgDocItem3.Amount end                                                     as OpenBalance,

       _BillingDocument.TransactionCurrency                                                    as Currency,

       concat_with_space( 'A_R Invoice -', ltrim( _BillingDocument.BillingDocument, '0' ), 1 ) as FileName,

       case when _SSD037.BillingDocument is null then 'X' else '' end                          as isAllowSend,

       _BillingDocument.SalesOrganization,
       _BillingDocument.BillingDocumentType,

       _BilltoAddress,
       _DeliverytoAddress,
       _SalesRepAddress,
       _PaymentTermsText,
       _Plant,
       _ShippingTypeText,
       _InvoiceItem
}
