@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Print CDS of Order Confirmation Output'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD005
    as select from I_SalesDocument as _SalesDocument                             
    association [0..1] to I_ShippingTypeText as _ShippingTypeText on _SalesDocument.ShippingType = _ShippingTypeText.ShippingType
                                                                 and _ShippingTypeText.Language = 'E'
    association [0..1] to I_PaymentTermsText as _PaymentTermsText on _PaymentTermsText.PaymentTerms = _SalesDocument.CustomerPaymentTerms
                                                                     and _PaymentTermsText.Language = 'E'
    association [0..1] to I_SalesDocumentTypeLangDepdnt as _SalesDocumentTypeLangDepdnt
    on _SalesDocument.SalesDocumentType = _SalesDocumentTypeLangDepdnt.SalesDocumentType
    and _SalesDocumentTypeLangDepdnt.Language = $session.system_language
                                                                        
    association [1..1] to ZR_PSD023 as _Address on _Address.SalesDocument = $projection.SalesDocument
    association [1..1] to ZR_PSD009 as _Plant on _Plant.SalesDocument = $projection.SalesDocument
    association [1..1] to ZR_PSD018 as _SumTaxAmount on _SumTaxAmount.SalesDocument = $projection.SalesDocument
    association [0..*] to ZR_PSD006 as _Item on _Item.SalesDocument = $projection.SalesDocument
{
    key _SalesDocument.SalesDocument,
        case when 
        _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt is null
        then _SalesDocument.SalesDocumentType
        else _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt
        end as SalesDocumentType,
        _SalesDocument.PurchaseOrderByCustomer,
        _SalesDocument.CreationDate,
        _SalesDocument.RequestedDeliveryDate,
        _Address.BillToLine1,
        _Address.BillToLine2,
        _Address.BillToLine3,
        _PaymentTermsText.PaymentTermsName,
        _Address.ShipToLine1,
        _Address.ShipToLine2,
        _Address.ShipToLine3,
        _SalesDocument.YY1_ContactName_SDH,
        _SalesDocument.YY1_ContactPhone_SDH,
        _ShippingTypeText.ShippingTypeName,
        _SalesDocument.YY1_TrackingNumber_SDH,
        concat_with_space(_Plant.Plant,concat_with_space('-',_Plant.PlantName,1),1) as ShipFrom,
        _Address.SalesRep as SalesRep,
        _SalesDocument.YY1_WhiteGlovesShipto_SDH,
        @Semantics.amount.currencyCode: 'TransactionCurrency'
        _SumTaxAmount.TotalNetAmount,
        @Semantics.amount.currencyCode: 'TransactionCurrency'
        _SumTaxAmount.SumTaxAmount,
        _SalesDocument.TransactionCurrency,
        _Item
}
