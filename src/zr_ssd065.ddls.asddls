@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Report for Sales Volume 107.01.1.1'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SSD065
  as select from    I_BillingDocumentItem          as _BillingDocumentItem
    left outer join I_BillingDocument              as _BillingDocument               on _BillingDocumentItem.BillingDocument = _BillingDocument.BillingDocument
    left outer join I_JournalEntry                 as _JournalEntry                  on  _BillingDocument.AccountingDocument  = _JournalEntry.AccountingDocument
                                                                                     and _BillingDocument.FiscalYear          = _JournalEntry.FiscalYear
                                                                                     and _BillingDocument.CompanyCode         = _JournalEntry.CompanyCode
                                                                                     and _JournalEntry.AccountingDocumentType = 'RV'
    left outer join I_Product                      as _Product                       on _BillingDocumentItem.Material = _Product.Product
    left outer join I_ProductGroupText_2           as _ProductGroupText_2            on  _Product.ProductGroup        = _ProductGroupText_2.ProductGroup
                                                                                     and _ProductGroupText_2.Language = 'E'
    left outer join I_CustomerSalesArea            as _CustomerSalesArea             on  _BillingDocument.SoldToParty       = _CustomerSalesArea.Customer
                                                                                     and _BillingDocument.SalesOrganization = _CustomerSalesArea.SalesOrganization
    left outer join I_CustomerGroupText            as _CustomerGroupText             on  _CustomerSalesArea.CustomerGroup = _CustomerGroupText.CustomerGroup
                                                                                     and _CustomerGroupText.Language      = 'E'
    left outer join I_BillingDocItemPrcgElmntBasic as _BillingDocItemPrcGelMntBasic  on  _BillingDocumentItem.BillingDocument                  = _BillingDocItemPrcGelMntBasic.BillingDocument
                                                                                     and _BillingDocumentItem.BillingDocumentItem              = _BillingDocItemPrcGelMntBasic.BillingDocumentItem
                                                                                     and _BillingDocItemPrcGelMntBasic.ConditionType           = 'PPR0'
                                                                                     and _BillingDocItemPrcGelMntBasic.ConditionInactiveReason = ''
    left outer join I_BillingDocItemPrcgElmntBasic as _BillingDocItemPrcGelMntBasic1 on  _BillingDocumentItem.BillingDocument                   = _BillingDocItemPrcGelMntBasic1.BillingDocument
                                                                                     and _BillingDocumentItem.BillingDocumentItem               = _BillingDocItemPrcGelMntBasic1.BillingDocumentItem
                                                                                     and _BillingDocItemPrcGelMntBasic1.ConditionType           = 'ZDRN'
                                                                                     and _BillingDocItemPrcGelMntBasic1.ConditionInactiveReason = ''
{
  key _BillingDocumentItem.BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,
      cast('Atosa USA' as abap.char(10))                                        as VendorName,
      _BillingDocument.SoldToParty,
      _BillingDocument.PurchaseOrderByCustomer,
      _JournalEntry.PostingDate,
      case
      when (_BillingDocument.BillingDocumentType = 'F2' or _BillingDocument.BillingDocumentType = 'S1' or _BillingDocument.BillingDocumentType = 'L2')
      then
      cast('INV' as abap.char(3))
      when (_BillingDocument.BillingDocumentType = 'G2' or _BillingDocument.BillingDocumentType = 'S2')
      then
      cast('CR' as abap.char(3))
      end                                                                       as INorCR,
      _BillingDocumentItem.Product,
//      _BillingDocumentItem.BillingDocumentItemText,
      _Product.ProductGroup,
      _ProductGroupText_2.ProductGroupText,
      cast(_BillingDocumentItem.BillingQuantity as abap.dec(13,3))              as BillingQuantity,
      cast(_BillingDocItemPrcGelMntBasic.ConditionRateAmount as abap.dec(24,9)) as ConditionRateAmount,
      cast(_BillingDocItemPrcGelMntBasic1.ConditionAmount as abap.dec(24,9))    as ConditionAmount,
      cast(_BillingDocumentItem.NetAmount as abap.dec(15,2))                    as NetAmount,
      case
      when (_Product.ProductGroup <> 'Z001' and _Product.ProductGroup <> 'Z002' and _Product.ProductGroup <> 'Z004' and _Product.ProductGroup <> 'Z005')
      then
      cast(_BillingDocumentItem.NetAmount as abap.dec(15,2))
      else
      cast(0 as abap.dec(15,2))
      end                                                                       as Rebatable,
      case
      when (_Product.ProductGroup = 'Z001' or _Product.ProductGroup = 'Z002' or _Product.ProductGroup = 'Z004' or _Product.ProductGroup = 'Z005')
      then
      cast(_BillingDocumentItem.NetAmount as abap.dec(15,2))
      else
      cast(0 as abap.dec(15,2))
      end                                                                       as NonRebatable,
      cast('' as abap.char(10))                                                 as Rebate,
      cast('' as abap.char(10))                                                 as ManagementFree,
      cast('' as abap.char(10))                                                 as MarketingAllowance,
      substring(_JournalEntry.PostingDate,5,2)                                  as PostingMonth,
      substring(_JournalEntry.PostingDate,1,4)                                  as PostingYear,
      case
      when($projection.NonRebatable is null)
      then
      cast('Nonrebatable' as abap.char(12))
      else
      cast('' as abap.char(12))
      end                                                                       as Notes,
      _CustomerSalesArea.CustomerGroup,
      _CustomerGroupText.CustomerGroupName
}
union 
select from I_JournalEntryItem    as _JournalEntryItem
  left outer join I_JournalEntry        as _JournalEntry        on _JournalEntryItem.AccountingDocument = _JournalEntry.AccountingDocument
                                                                and _JournalEntryItem.FiscalYear = _JournalEntry.FiscalYear
                                                                and _JournalEntry.AccountingDocumentType = 'DR'
  left outer join I_ChartOfAccountsText as _ChartOfAccountsText on _JournalEntryItem.GLAccount = _ChartOfAccountsText.ChartOfAccounts
  left outer join I_CustomerSalesArea   as _CustomerSalesArea   on _JournalEntryItem.Customer = _CustomerSalesArea.Customer
  left outer join I_CustomerGroupText   as _CustomerGroupText   on  _CustomerSalesArea.CustomerGroup = _CustomerGroupText.CustomerGroup
                                                                and _CustomerGroupText.Language      = 'E'
{
  key _JournalEntryItem.AccountingDocument                                  as BillingDocument,
  key _JournalEntryItem.LedgerGLLineItem                                    as BillingDocumentItem,
      cast('Atosa USA' as abap.char(10))                                    as VendorName,
      _JournalEntryItem.Customer                                            as SoldToParty,
      _JournalEntry.DocumentReferenceID                                     as PurchaseOrderByCustomer,
      _JournalEntry.PostingDate,
      cast('INV' as abap.char(3))                                           as INorCR,
      _JournalEntryItem.GLAccount                                           as Product,
//      _ChartOfAccountsText.ChartOfAccountsName                              as BillingDocumentItemText,
      cast('' as abap.char(9))                                              as ProductGroup,
      cast('' as abap.char(60))                                             as ProductGroupText,
      cast(0 as abap.dec(13,3))                                             as BillingQuantity,
      cast(0 as abap.dec(24,9))                                             as ConditionRateAmount,
      cast(0 as abap.dec(24,9))                                             as ConditionAmount,
      cast(_JournalEntryItem.AmountInCompanyCodeCurrency as abap.dec(15,2)) as NetAmount,
      cast(0 as abap.dec(15,2))                                             as Rebatable,
      cast(0 as abap.dec(15,2))                                             as NonRebatable,
      cast('' as abap.char(10))                                             as Rebate,
      cast('' as abap.char(10))                                             as ManagementFree,
      cast('' as abap.char(10))                                             as MarketingAllowance,
      substring(_JournalEntry.PostingDate,5,2)                              as PostingMonth,
      substring(_JournalEntry.PostingDate,1,4)                              as PostingYear,
      cast('' as abap.char(12))                                             as Notes,
      _CustomerSalesArea.CustomerGroup,
      _CustomerGroupText.CustomerGroupName
}
where
      _JournalEntryItem.Ledger                 = '0L'
  and _JournalEntryItem.AccountingDocumentType = 'DR'
