@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Order Confirmation Output Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD006 
    as select from I_SalesDocumentItem as _SalesDocumentItem
    association [0..1] to ZR_PSD032 as _PricingElement1 on _PricingElement1.SalesDocument = $projection.SalesDocument
                                                       and _PricingElement1.SalesDocumentItem = $projection.SalesDocumentItem
    association [0..1] to ZR_PSD031 as _PricingElement2 on _PricingElement2.SalesDocument = $projection.SalesDocument
                                                       and _PricingElement2.SalesDocumentItem = $projection.SalesDocumentItem
    association [1..1] to ZR_PSD008 as _WarrantyInfo on _WarrantyInfo.SalesDocument = $projection.SalesDocument
                                                    and _WarrantyInfo.SalesDocumentItem = $projection.SalesDocumentItem
    association [0..1] to I_SalesDocumentTypeLangDepdnt as _SalesDocumentTypeLangDepdnt
    on _SalesDocumentItem.SalesDocumentType = _SalesDocumentTypeLangDepdnt.SalesDocumentType
    and _SalesDocumentTypeLangDepdnt.Language = $session.system_language
{
    key _SalesDocumentItem.SalesDocument,
    key _SalesDocumentItem.SalesDocumentItem,
    _SalesDocumentItem.Material,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    _PricingElement1.ConditionRateAmount as UnitPrice,
    _PricingElement1.TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    _PricingElement2.ConditionAmount as Dis,
    @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
    case when _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt is not null
    then
        case when _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt <> 'CR'
            and _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt <> 'DR'
            and _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt <> 'GA2'
        then _SalesDocumentItem.OrderQuantity
            when _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt = 'CR'
                or _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt = 'DR'
                or _SalesDocumentTypeLangDepdnt.SalesDocumentTypeLangDepdnt = 'GA2'
            then _SalesDocumentItem.RequestedQuantity
        end
    else
        _SalesDocumentItem.OrderQuantity
    end                as OrderQuantity,
    _SalesDocumentItem.OrderQuantityUnit,
    _SalesDocumentItem.MaterialByCustomer,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    _SalesDocumentItem.NetAmount,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    _SalesDocumentItem.Subtotal1Amount,
    _WarrantyInfo
}
where _SalesDocumentItem.SalesDocumentRjcnReason = ''
