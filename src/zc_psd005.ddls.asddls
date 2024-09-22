@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Order Confirmation Output'
define root view entity ZC_PSD005
    provider contract transactional_query
    as projection on ZR_PSD005
{
    key SalesDocument,
        PurchaseOrderByCustomer,
        CreationDate,
        RequestedDeliveryDate,
        @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_006'
        virtual SoldToParty : abap.sstring( 255 ),
        BillToLine1,
        BillToLine2,
        BillToLine3,
        PaymentTermsName,
        ShipToLine1,
        ShipToLine2,
        ShipToLine3,
        YY1_ContactName_SDH,
        YY1_ContactPhone_SDH,
        ShippingTypeName,
        YY1_TrackingNumber_SDH,
        ShipFrom,
        SalesRep,
        @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_006'
    virtual CustomerNote : abap.sstring( 255 ),
        YY1_WhiteGlovesShipto_SDH,
        TotalNetAmount,
        SumTaxAmount,
        TransactionCurrency,
        _Item : redirected to ZC_PSD006
}
