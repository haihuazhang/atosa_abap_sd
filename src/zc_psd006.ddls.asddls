@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Print CDS of Order Confirmation Output Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_PSD006
    as projection on ZR_PSD006
{
    key SalesDocument,
    key SalesDocumentItem,
    Material,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_007'
    virtual SalesDocumentItemText : abap.sstring( 255 ),
//    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_007'
//    virtual ProductBasicText : abap.sstring( 255 ),
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    UnitPrice,
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    Dis,
    @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
    OrderQuantity,
    OrderQuantityUnit,
    MaterialByCustomer,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    NetAmount,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_007'
    virtual MaterialNote : abap.sstring( 255 ),
    _WarrantyInfo : redirected to ZC_PSD008
//    YY1_WarrantyMaterial_SDI,
//    YY1_WarrantySerial_SDI,
//    YY1_BusinessAddress_SDI,
//    YY1_BusinessNameSOITEM_SDI,
//    YY1_FirstName_SDI,
//    YY1_LastName_SDI,
//    YY1_PhoneNumber_SDI
}
