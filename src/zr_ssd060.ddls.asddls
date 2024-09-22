@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AR Invoice Date of 113.01.1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD060 
as select from I_JournalEntry as _JournalEntry
left outer join I_BillingDocumentBasic as _BillingDocumentBasic on _JournalEntry.AccountingDocument = _BillingDocumentBasic.AccountingDocument
                                                                and _JournalEntry.FiscalYear = _BillingDocumentBasic.FiscalYear
                                                                and _JournalEntry.CompanyCode = _BillingDocumentBasic.CompanyCode
left outer join ZR_SSD059 as _SSD059 on _BillingDocumentBasic.BillingDocument = _SSD059.SubsequentDocument
{
    key _JournalEntry.PostingDate,
    _SSD059.SalesDocument,
    _SSD059.SalesDocumentItem
}
where _JournalEntry.AccountingDocumentType = 'RV'
