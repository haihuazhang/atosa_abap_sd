@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Report of SD Order Details 113.01.1'
@Metadata.allowExtensions: true
define root view entity ZC_SSD058 
as projection on ZR_SSD058
{
    key SalesDocument,
    key SalesDocumentItem,
    YY1_NatAccountsTeamCS_SDH,
    SoldToParty,
    YY1_Project_SDH,
    PurchaseOrderByCustomer,
    CreationDate,
    RequestedDeliveryDate,
    YY1_BusinessName_SDH,
    YY1_ContactName_SDH,
    YY1_ContactPhone_SDH,
    YY1_WhiteGlovesShipto_SDH,
    TotalNetAmount,
    TransactionCurrency,
    YY1_TrackingNumber_SDH,
    SalesDocumentRjcnReason,
    Material,
    OrderQuantity,
    OrderQuantityUnit,
    NetAmount,
    FullName,
    YY1_ChainAccount_bus,
    YY1_NationalAccount_bus,
    SalesDocumentRjcnReasonName,
    PlantName,
    Street,
    CityName,
    Region,
    PostalCode,
    ShippingTypeName,
    status,
    OpenQuantity,
    ItemTotal,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_028'
    virtual FreeText:abap.sstring(255),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_028'
    virtual InvoiceRemarks:abap.sstring(255),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_028'
    virtual InternalRemarks:abap.sstring(255),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_029'
    virtual InvoiceNo:abap.sstring(255),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_029'
    virtual InvoiceDate:abap.sstring(255)
}
