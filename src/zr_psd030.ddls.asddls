@EndUserText.label: 'Print CDS of Invoice Item'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_030'
@UI: {
  headerInfo: {
    typeName: 'Item',
    typeNamePlural: 'Item',
    title: { type: #STANDARD, value: 'BillingDocumentItem' }
  },
  presentationVariant: [ {
    sortOrder: [ { by: 'BillingDocumentItem', direction: #ASC } ],
    visualizations: [ { type: #AS_LINEITEM } ]
  } ]
}
define custom entity ZR_PSD030
{

      @UI.facet                : [ {
        id                     : 'idIdentification',
        type                   : #IDENTIFICATION_REFERENCE,
        label                  : 'General information',
        position               : 10
      },
      {
        id                     : 'idItem',
        purpose                : #STANDARD,
        type                   : #LINEITEM_REFERENCE,
        label                  : 'Serial Number',
        position               : 10,
        targetElement          : '_InvoiceItemSerialNumber'
      } ]

      @UI.hidden               : true
  key BillingDocument          : zzesd015;

      @UI.lineItem             : [ { position: 10 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 10 } ]
      @EndUserText.label       : 'Billing Document Item'
  key BillingDocumentItem      : abap.numc( 6 );

      @UI.lineItem             : [ { position: 20 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 20 } ]
      @EndUserText.label       : 'Material'
      Material                 : zzesd009;

      @EndUserText.label       : 'Item Text'
      BillingDocumentItemText  : abap.char( 40 );

      @UI.lineItem             : [ { position: 30 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 30 } ]
      @EndUserText.label       : 'Description'
      Description              : abap.sstring( 255 );

      @UI.lineItem             : [ { position: 40 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 40 } ]
      @EndUserText.label       : 'Unit Price'
      @Semantics.amount.currencyCode: 'Currency'
      UnitPrice                : abap.dec( 24, 9 );

      @UI.lineItem             : [ { position: 50 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 50 } ]
      @EndUserText.label       : 'Discount'
      @Semantics.amount.currencyCode: 'Currency'
      DiscountAmount           : abap.curr( 15, 2 );

      @UI.hidden               : true
      Currency                 : waers;

      @UI.lineItem             : [ { position: 60 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 60 } ]
      @EndUserText.label       : 'Quantity'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Quantity                 : abap.quan( 13, 3 );

      @UI.hidden               : true
      Unit                     : meins;

      @UI.lineItem             : [ { position: 70 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 70 } ]
      @EndUserText.label       : 'Net Amount'
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount                : abap.curr( 15, 2 );

      @UI.lineItem             : [ { position: 80 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 80 } ]
      @EndUserText.label       : 'Amount'
      @Semantics.amount.currencyCode: 'Currency'
      Subtotal1Amount          : abap.curr( 13, 2 );

      @EndUserText.label       : 'Warranty Info'
      WarrantyInfo             : abap.sstring( 255 );

      @UI.lineItem             : [ { position: 90 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 90 } ]
      @EndUserText.label       : 'Extend Warranty Material'
      WarrantyMaterial         : abap.sstring( 255 );

      @UI.lineItem             : [ { position: 100 , importance: #MEDIUM } ]
      @UI.identification       : [ { position: 100 } ]
      @EndUserText.label       : 'Extend Warranty Serial'
      WarrantySerial           : abap.sstring( 255 );

      @EndUserText.label       : 'Business Name'
      BusinessName             : abap.sstring( 255 );
      @EndUserText.label       : 'Warranty Regist Info'
      WarrantyRegistInfo       : abap.sstring( 255 );
      @EndUserText.label       : 'First Name'
      FirstName                : abap.sstring( 255 );
      @EndUserText.label       : 'Last Name'
      LastName                 : abap.sstring( 255 );
      @EndUserText.label       : 'Phone Number'
      PhoneNumber              : abap.sstring( 255 );
      @EndUserText.label       : 'Street'
      Street                   : abap.sstring( 255 );
      @EndUserText.label       : 'Sales Document Category'
      SalesSDDocumentCategory  : abap.char( 4 );
      @EndUserText.label       : 'Billing Document Type'
      BillingDocumentType      : abap.char( 4 );

      @ObjectModel.filter.enabled: false
      _InvoiceItemSerialNumber : association [0..*] to ZR_PSD012 on  _InvoiceItemSerialNumber.BillingDocument     = $projection.BillingDocument
                                                                 and _InvoiceItemSerialNumber.BillingDocumentItem = $projection.BillingDocumentItem;
}
