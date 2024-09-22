@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '111.01 AR Invoice List-All'
define root view entity ZR_SSD056
  as select from I_BillingDocument     as _BillingDocument
    inner join   I_BillingDocumentItem as _BillingDocumentItem on _BillingDocumentItem.BillingDocument = _BillingDocument.BillingDocument

  association [0..1] to I_BillingDocumentTypeText as _BillingDocumentTypeText on  _BillingDocumentTypeText.BillingDocumentType = $projection.BillingDocumentType
                                                                              and _BillingDocumentTypeText.Language            = $session.system_language
  association [0..1] to I_CustomerGroupText       as _CustomerGroupText       on  _CustomerGroupText.CustomerGroup = $projection.CustomerGroup
                                                                              and _CustomerGroupText.Language      = $session.system_language
  association [0..1] to I_BusinessPartner         as _BusinessPartner         on  _BusinessPartner.BusinessPartner = $projection.SoldToParty
  association [0..1] to I_JournalEntryItem        as _JournalEntryItem        on  _JournalEntryItem.ReferenceDocument     = $projection.BillingDocument
                                                                              and _JournalEntryItem.ReferenceDocumentItem = '000000'
                                                                              and _JournalEntryItem.Ledger                = '0L'
  association [0..1] to I_Plant                   as _Plant                   on  _Plant.Plant = $projection.Plant
  association [0..1] to ZR_SSD055                 as _SSD055                  on  _SSD055.BillingDocument     = $projection.BillingDocument
                                                                              and _SSD055.BillingDocumentItem = $projection.BillingDocumentItem
{
  key _BillingDocument.BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,

      _BillingDocument.BillingDocumentType,
      _BillingDocument.SalesOrganization,
      _BillingDocument.SoldToParty,
      _BillingDocument.YY1_Project_BDH,
      _BillingDocument.BillingDocumentDate,
      _BillingDocument.BillingDocumentIsCancelled,
      _BillingDocument.CancelledBillingDocument,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _BillingDocument.TotalNetAmount + _BillingDocument.TotalTaxAmount                               as TotalAmount,
      _BillingDocument.TransactionCurrency,
      _BillingDocument.CustomerGroup,
      _BillingDocument.CompanyCode,

      _BillingDocumentItem.Plant,

      _BusinessPartner.BusinessPartnerIDByExtSystem,
      _BusinessPartner.BusinessPartnerName,
      concat_with_space( _BusinessPartner.OrganizationBPName3,_BusinessPartner.OrganizationBPName4,1) as OrganizationBPName,

      /* association */
      _BillingDocumentTypeText,
      _CustomerGroupText,
      _JournalEntryItem,
      _Plant,
      _SSD055
}
