@EndUserText.label: 'Order Status Report'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_018'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define custom entity ZC_SSD048
{
    @UI:{
        lineItem: [ { position: 3,
                      importance: #HIGH,
                      label: 'Sales Order Number' } ],
        selectionField: [{ position: 2 }]
    }
    @EndUserText.label: 'Sales Order Number'
    key SalesOrderNumber    : zzesd014;
    @UI.hidden: true
    key SalesDocumentItem   : abap.numc( 6 );
    @UI:{
        lineItem: [ { position: 1,
                      importance: #HIGH,
                      label: 'Customer Code' } ],
        selectionField: [{ position: 1 }]
    }
    @EndUserText.label: 'Customer Code'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer_VH', element: 'Customer' }}]
    CustomerCode            : abap.char( 10 );
    @UI:{
        lineItem: [ { position: 2,
                      importance: #HIGH,
                      label: 'Customer Name' } ]
    }
    @EndUserText.label: 'Customer Name'
    CustomerName            : abap.char( 81 );
    @UI:{
        lineItem: [ { position: 4,
                      importance: #HIGH,
                      label: 'Order Entry Date' } ],
        selectionField: [{ position: 3 }]
    }
    @EndUserText.label: 'Order Entry Date'
    OrderEntryDate : abap.dats;
    @UI:{
        lineItem: [ { position: 5,
                      importance: #HIGH,
                      label: 'Ship-to Store Number' } ],
        selectionField: [{ position: 4 }]
    }
    @EndUserText.label: 'Ship-to Store Number'
    ShipToStoreNumber : abap.sstring( 255 );
    @UI:{
        lineItem: [ { position: 6,
                      importance: #HIGH,
                      label: 'Buyer/Destination Contact Name' } ]
    }
    BuyerDestinationContactName : abap.sstring( 255 );
    @UI:{
        lineItem: [ { position: 7,
                      importance: #HIGH,
                      label: 'Item Status' } ],
        selectionField: [{ position: 5 }]
    }
    @EndUserText.label: 'Item Status'
    ItemStatus : abap.char( 1 );
    @UI:{
        lineItem: [ { position: 8,
                      importance: #HIGH,
                      label: 'Item Code' } ]
    }
    ItemCode    : abap.char( 40 );
    @UI:{
        lineItem: [ { position: 9,
                      importance: #HIGH,
                      label: 'Item Description' } ]
    }
    ItemDescription : abap.sstring( 255 );
    @UI:{
        lineItem: [ { position: 10,
                      importance: #HIGH,
                      label: 'Ship-from Warehouse' } ]
    }
    ShipFromWarehouse   : abap.char( 30 );
    @UI:{
        lineItem: [ { position: 11,
                      importance: #HIGH,
                      label: 'Ordered Quantity' } ]
    }
    OrderedQauntity     : abap.dec( 15, 3 );
    @UI:{
        lineItem: [ { position: 12,
                      importance: #HIGH,
                      label: 'Unit Price' } ]
    }
    UnitPrice : abap.dec( 15, 2 );
    @UI:{
        lineItem: [ { position: 13,
                      importance: #HIGH,
                      label: 'Item Total' } ]
    }
    ItemTotal : abap.dec( 15, 2 );
    @UI:{
        lineItem: [ { position: 14,
                      importance: #HIGH,
                      label: 'Remaining Quantity' } ]
    }
    RemainingQuantity : abap.dec( 15, 2 );
    @UI:{
        lineItem: [ { position: 15,
                      importance: #HIGH,
                      label: 'Sales Order Status' } ]
    }
    SalesOrderStatus : abap.char( 1 );
    @UI:{
        lineItem: [ { position: 16,
                      importance: #HIGH,
                      label: 'Properties' } ]
    }
    Properties : abap.sstring( 255 );
    @UI:{
        lineItem: [ { position: 17,
                      importance: #HIGH,
                      label: 'Project' } ]
    }
    Project : abap.sstring( 255 );
    @UI.hidden: true
    Product : abap.char( 40 );
}
