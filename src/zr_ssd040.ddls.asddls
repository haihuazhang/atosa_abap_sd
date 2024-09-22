@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD040
  as select from    I_GLAccountLineItem            as _GLAccountLineItem
    left outer join I_JournalEntry                 as _JournalEntry                 on  _GLAccountLineItem.AccountingDocument = _JournalEntry.AccountingDocument
                                                                                    and _GLAccountLineItem.CompanyCode        = _JournalEntry.CompanyCode
                                                                                    and _GLAccountLineItem.FiscalYear         = _JournalEntry.FiscalYear
  //    left outer join I_JournalEntryItem             as _JournalEntryItem             on _JournalEntry.AccountingDocument = _JournalEntryItem.AccountingDocument
    left outer join I_BillingDocument              as _BillingDocument              on _GLAccountLineItem.ReferenceDocument = _BillingDocument.BillingDocument
    left outer join I_BusinessPartner              as _BusinessPartner              on _GLAccountLineItem.Customer = _BusinessPartner.BusinessPartner
    left outer join I_CustomerGroupText            as _CustomerGroupText            on  _BillingDocument.CustomerGroup = _CustomerGroupText.CustomerGroup
                                                                                    and _CustomerGroupText.Language    = 'E'
    left outer join ZR_SSD041                      as _SSD041                       on _GLAccountLineItem.ReferenceDocument = _SSD041.BillingDocument
    left outer join ZR_SSD042                      as _SSD042                       on _GLAccountLineItem.ReferenceDocument = _SSD042.BillingDocument
    left outer join ZR_SSD043                      as _SSD043                       on _GLAccountLineItem.ReferenceDocument = _SSD043.BillingDocument
    left outer join ZR_SSD044                      as _SSD044                       on _GLAccountLineItem.ReferenceDocument = _SSD044.ReferenceDocument
    left outer join ZR_SSD045                      as _SSD045                       on _GLAccountLineItem.ReferenceDocument = _SSD045.BillingDocument
    left outer join I_AdditionalCustomerGroup1Text as _AdditionalCustomerGroup1Text on  _SSD045.AdditionalCustomerGroup1       = _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1
                                                                                    and _AdditionalCustomerGroup1Text.Language = 'E'
  //    left outer join I_SalesDocItmSubsqntProcFlow   as _SalesDocItmSubsqntProcFlow   on _GLAccountLineItem.ReferenceDocument             = _SalesDocItmSubsqntProcFlow.SubsequentDocument
  //                                                                                    and(
  //                                                                                      _SalesDocItmSubsqntProcFlow.SDDocumentCategory    = 'C'
  //                                                                                      or _SalesDocItmSubsqntProcFlow.SDDocumentCategory = 'I'
  //                                                                                      or _SalesDocItmSubsqntProcFlow.SDDocumentCategory = 'K'
  //                                                                                      or _SalesDocItmSubsqntProcFlow.SDDocumentCategory = 'L'
  //                                                                                    )
  //    left outer join I_SalesDocument                as _SalesDocument                on _SalesDocItmSubsqntProcFlow.SalesDocument = _SalesDocument.SalesDocument
{
  key    _GLAccountLineItem.ReferenceDocument,
  key    case
      when ( _GLAccountLineItem.ProfitCenter = '')
      then
      _GLAccountLineItem.CostCenter
      else
      _GLAccountLineItem.ProfitCenter
      end                                                                                                                                           as Plant,
         _GLAccountLineItem.Customer,
         case
         when (_GLAccountLineItem.AccountingDocumentType = 'DG')
         then
         cast('Customer credit memo' as abap.char(40))
         when (_GLAccountLineItem.AccountingDocumentType = 'DR')
         then
         cast('Customer invoice' as abap.char(40))
         end                                                                                                                                        as AccountingDocumentType,
         case
         when(_GLAccountLineItem.ReferenceDocument is null)
         then
         cast(_JournalEntry.DocumentReferenceID as abap.char(35))
         else
         cast(_BillingDocument.PurchaseOrderByCustomer as abap.char(35))
         end                                                                                                                                        as AssignmentReference,
         _GLAccountLineItem.PostingDate,
         _GLAccountLineItem.NetDueDate,
         //      @Semantics.amount.currencyCode:'CompanyCodeCurrency'
         _GLAccountLineItem.CompanyCodeCurrency,
         @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
         _GLAccountLineItem.AmountInCompanyCodeCurrency,
         _BusinessPartner.BusinessPartnerIDByExtSystem,
         _BusinessPartner.BusinessPartnerName,
         _BusinessPartner.YY1_RebateConsolidati_bus,
         _BillingDocument.YY1_Project_BDH,
         _GLAccountLineItem.IsReversed                                                                                                              as BillingDocumentIsCancelled,
         _GLAccountLineItem.ReversalReferenceDocument                                                                                               as CancelledBillingDocument,
         _CustomerGroupText.CustomerGroupName,
         cast(case when _SSD041.NetAmount is null then 0 else _SSD041.NetAmount end as abap.dec(23,2))                                              as Freight,
         cast(case when _SSD042.NetAmount is null then 0 else _SSD042.NetAmount end as abap.dec(23,2))                                              as Parts,
         cast(case when _SSD043.NetAmount is null then 0 else _SSD043.NetAmount end as abap.dec(23,2))                                              as OtherOCI,
         cast(case when _SSD044.AmountInCompanyCodeCurrency is null then 0 else _SSD044.AmountInCompanyCodeCurrency * ( -1 ) end as abap.dec(23,2)) as Tax,
         _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1Name,
         _GLAccountLineItem.SalesOrganization,
         _GLAccountLineItem.DistributionChannel,
         _GLAccountLineItem.OrganizationDivision

}
where
  (
       _GLAccountLineItem.AccountingDocumentType = 'DR'
    or _GLAccountLineItem.AccountingDocumentType = 'DG'
  )
  and  _GLAccountLineItem.SourceLedger           = '0L'
  and  _GLAccountLineItem.FinancialAccountType   = 'D'
union select from I_GLAccountLineItem            as _GLAccountLineItem
  left outer join I_GLAccountLineItem            as _GLAccountLineItem1           on  _GLAccountLineItem.ReferenceDocument       =  _GLAccountLineItem1.ReferenceDocument
                                                                                  and _GLAccountLineItem1.SourceLedger           =  '0L'
                                                                                  and _GLAccountLineItem1.AccountingDocumentType =  'RV'
                                                                                  and _GLAccountLineItem1.FinancialAccountType   =  'S'
                                                                                  and _GLAccountLineItem1.Plant                  <> ''
  left outer join I_JournalEntry                 as _JournalEntry                 on  _GLAccountLineItem.AccountingDocument = _JournalEntry.AccountingDocument
                                                                                  and _GLAccountLineItem.CompanyCode        = _JournalEntry.CompanyCode
                                                                                  and _GLAccountLineItem.FiscalYear         = _JournalEntry.FiscalYear
  left outer join I_BillingDocument              as _BillingDocument              on _GLAccountLineItem.ReferenceDocument = _BillingDocument.BillingDocument
  left outer join I_BillingDocumentTypeText      as _BillingDocumentTypeText      on  _BillingDocument.BillingDocumentType = _BillingDocumentTypeText.BillingDocumentType
                                                                                  and _BillingDocumentTypeText.Language    = 'E'
  left outer join I_BusinessPartner              as _BusinessPartner              on _GLAccountLineItem.Customer = _BusinessPartner.BusinessPartner
  left outer join I_CustomerGroupText            as _CustomerGroupText            on  _BillingDocument.CustomerGroup = _CustomerGroupText.CustomerGroup
                                                                                  and _CustomerGroupText.Language    = 'E'
  left outer join ZR_SSD041                      as _SSD041                       on _GLAccountLineItem.ReferenceDocument = _SSD041.BillingDocument
  left outer join ZR_SSD042                      as _SSD042                       on _GLAccountLineItem.ReferenceDocument = _SSD042.BillingDocument
  left outer join ZR_SSD043                      as _SSD043                       on _GLAccountLineItem.ReferenceDocument = _SSD043.BillingDocument
  left outer join ZR_SSD044                      as _SSD044                       on _GLAccountLineItem.ReferenceDocument = _SSD044.ReferenceDocument
  left outer join ZR_SSD045                      as _SSD045                       on _GLAccountLineItem.ReferenceDocument = _SSD045.BillingDocument
  left outer join I_AdditionalCustomerGroup1Text as _AdditionalCustomerGroup1Text on  _SSD045.AdditionalCustomerGroup1       = _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1
                                                                                  and _AdditionalCustomerGroup1Text.Language = 'E'
{
  key    _GLAccountLineItem.ReferenceDocument,
  key    _GLAccountLineItem1.Plant,
         _GLAccountLineItem.Customer,
         _BillingDocumentTypeText.BillingDocumentTypeName                                                                                           as AccountingDocumentType,
         case
         when(_GLAccountLineItem.ReferenceDocument is null)
         then
         cast(_JournalEntry.DocumentReferenceID as abap.char(35))
         else
         cast(_BillingDocument.PurchaseOrderByCustomer as abap.char(35))
         end                                                                                                                                        as AssignmentReference,
         _GLAccountLineItem.PostingDate,
         _GLAccountLineItem.NetDueDate,
         //      @Semantics.currencyCode:true
         _GLAccountLineItem.CompanyCodeCurrency,
         //      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
         _GLAccountLineItem.AmountInCompanyCodeCurrency,
         _BusinessPartner.BusinessPartnerIDByExtSystem,
         _BusinessPartner.BusinessPartnerName,
         _BusinessPartner.YY1_RebateConsolidati_bus,
         _BillingDocument.YY1_Project_BDH,
         _BillingDocument.BillingDocumentIsCancelled,
         _BillingDocument.CancelledBillingDocument,
         _CustomerGroupText.CustomerGroupName,
         cast(case when _SSD041.NetAmount is null then 0 else _SSD041.NetAmount end as abap.dec(23,2))                                              as Freight,
         cast(case when _SSD042.NetAmount is null then 0 else _SSD042.NetAmount end as abap.dec(23,2))                                              as Parts,
         cast(case when _SSD043.NetAmount is null then 0 else _SSD043.NetAmount end as abap.dec(23,2))                                              as OtherOCI,
         cast(case when _SSD044.AmountInCompanyCodeCurrency is null then 0 else _SSD044.AmountInCompanyCodeCurrency * ( -1 ) end as abap.dec(23,2)) as Tax,
         //      cast((_SSD041.NetAmount + _SSD043.NetAmount + _SSD044.AmountInCompanyCodeCurrency) as abap.dec(15,2)) as NonRebatable,
         //      _SSD046.NonRebatable,
         _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1Name,
         _GLAccountLineItem.SalesOrganization,
         _GLAccountLineItem.DistributionChannel,
         _GLAccountLineItem.OrganizationDivision
}
where
  (
      _GLAccountLineItem.AccountingDocumentType = 'RV'
  )
  and _GLAccountLineItem.SourceLedger           = '0L'
  and _GLAccountLineItem.FinancialAccountType   = 'D'
