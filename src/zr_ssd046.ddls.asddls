@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get NonRebatable of Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_SSD046
  as select from ZR_SSD040 as _SSD040
{
  key     _SSD040.ReferenceDocument,
  key     _SSD040.Plant,
          _SSD040.Customer,
          _SSD040.AccountingDocumentType,
          _SSD040.AssignmentReference,
          _SSD040.PostingDate,
          _SSD040.NetDueDate,
          _SSD040.CompanyCodeCurrency,
          //       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
          cast(_SSD040.AmountInCompanyCodeCurrency as abap.dec(23,2))                                  as AmountInCompanyCodeCurrency,
          _SSD040.BusinessPartnerIDByExtSystem,
          _SSD040.BusinessPartnerName,
          _SSD040.YY1_RebateConsolidati_bus,
          _SSD040.YY1_Project_BDH,
          _SSD040.BillingDocumentIsCancelled,
          _SSD040.CancelledBillingDocument,
          _SSD040.CustomerGroupName,
          _SSD040.Freight,
          _SSD040.Parts,
          _SSD040.OtherOCI,
          _SSD040.Tax,
          _SSD040.AdditionalCustomerGroup1Name,
          cast((_SSD040.Freight + _SSD040.OtherOCI + _SSD040.Tax) as abap.dec(23,2))                   as NonRebatable,
          cast(($projection.AmountInCompanyCodeCurrency - $projection.NonRebatable) as abap.dec(23,2)) as Rebatable,
         _SSD040.SalesOrganization,
         _SSD040.DistributionChannel,
         _SSD040.OrganizationDivision
}
