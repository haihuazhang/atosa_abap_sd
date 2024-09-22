@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Report for Sales Volume 107.01.1.1'
@Metadata.allowExtensions: true
define root view entity ZC_SSD065 
as projection on ZR_SSD065
{
    key BillingDocument,
    key BillingDocumentItem,
    VendorName,
    SoldToParty,
    PurchaseOrderByCustomer,
    PostingDate,
    INorCR,
    Product,
//    BillingDocumentItemText,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_031'
    virtual LongText:abap.sstring(255),
    ProductGroup,
    ProductGroupText,
    BillingQuantity,
    ConditionRateAmount,
    ConditionAmount,
    NetAmount,
    Rebatable,
    NonRebatable,
    Rebate,
    ManagementFree,
    MarketingAllowance,
    PostingMonth,
    PostingYear,
    Notes,
    CustomerGroup,
    CustomerGroupName
}
