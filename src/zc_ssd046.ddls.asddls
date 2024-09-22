@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rebate Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZC_SSD046 
provider contract transactional_query
  as projection on ZR_SSD046
{
    key ReferenceDocument,
    key Plant,
    Customer,
    AccountingDocumentType,
    AssignmentReference,
    PostingDate,
    NetDueDate,
    CompanyCodeCurrency,
    AmountInCompanyCodeCurrency,
    BusinessPartnerIDByExtSystem,
    BusinessPartnerName,
    YY1_RebateConsolidati_bus,
    YY1_Project_BDH,
    BillingDocumentIsCancelled,
    CancelledBillingDocument,
    CustomerGroupName,
    Freight,
    Parts,
    OtherOCI,
    Tax,
    AdditionalCustomerGroup1Name,
    NonRebatable,
    Rebatable,
    SalesOrganization,
    DistributionChannel,
    OrganizationDivision
}
