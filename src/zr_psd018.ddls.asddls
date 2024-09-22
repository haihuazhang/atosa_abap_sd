@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Order Confirmation Sum Tax Amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD018
    as select from I_SalesDocumentItem as _SalesDocumentItem
{
    key SalesDocument,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    round(sum( TaxAmount ),2) as SumTaxAmount,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    round(sum( NetAmount ),2) as TotalNetAmount,
    TransactionCurrency
}
where _SalesDocumentItem.SalesDocumentRjcnReason = ''
group by _SalesDocumentItem.SalesDocument,
    _SalesDocumentItem.TransactionCurrency
