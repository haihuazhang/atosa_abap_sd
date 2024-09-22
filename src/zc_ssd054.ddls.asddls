@EndUserText.label: 'Whs Sales Details Report'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_026'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define custom entity ZC_SSD054
{   
    @UI:{
        lineItem: [ { position: 1,
                      importance: #HIGH,
                      label: 'Item Code' } ],
        selectionField: [{ position: 1 }]
    }
    @EndUserText.label: 'Item Code'
    key ItemCode          : matnr;
    @UI:{
        lineItem: [ { position: 3,
                      importance: #HIGH,
                      label: 'Warehouse' } ],
        selectionField: [{ position: 2 }]
    }
    @EndUserText.label: 'Warehouse'
    key WHCode            : werks_d;
    @UI:{
        lineItem: [ { position: 2,
                      importance: #HIGH,
                      label: 'Item Description' } ]
    }
    @EndUserText.label: 'Item Description'
    ItemDescription       : abap.sstring( 255 );
    @UI:{
        lineItem: [ { position: 4,
                      importance: #HIGH,
                      label: 'WHName' } ]
    }
    @EndUserText.label: 'WHName'
    WHName                : abap.char( 30 );
    @UI:{
        lineItem: [ { position: 5,
                      importance: #HIGH,
                      label: 'Qty' } ]
    }
    @EndUserText.label: 'Qty'
    Qty                   : abap.dec( 7, 0 );
    @UI:{
        lineItem: [ { position: 6,
                      importance: #HIGH,
                      label: 'Sales Amount (item)' } ]
    }
    @EndUserText.label: 'Sales Amount (item)'
    SalesAmountItem       : abap.dec( 15, 2 );
    @UI:{
        lineItem: [ { position: 7,
                      importance: #HIGH,
                      label: 'Stock Value' } ]
    }
    @EndUserText.label: 'Stock Value'
    StockValue            : abap.dec( 15, 2 );
    @UI:{
        lineItem: [ { position: 8,
                      importance: #HIGH,
                      label: 'Material Type' } ],
        selectionField: [{ position: 3 }]
    }
    @EndUserText.label: 'Material Type'
    MaterialType          : abap.char( 4 );
    @UI:{
        lineItem: [ { position: 9,
                      importance: #HIGH,
                      label: 'Material Group' } ],
        selectionField: [{ position: 4 }]
    }
    @EndUserText.label: 'Material Group'
    MaterialGroup         : abap.char( 9 );
    @UI:{
        lineItem: [ { position: 10,
                      importance: #HIGH,
                      label: 'Material Group Description 1' } ]
    }
    @EndUserText.label: 'Material Group Description 1'
    MaterialGroupName     : abap.char( 20 );
    @UI:{
        lineItem: [ { position: 11,
                      importance: #HIGH,
                      label: 'Material Group Description 2' } ]
    }
    @EndUserText.label: 'Material Group Description 2'
    MaterialGroupText     : abap.char( 60 );
    @UI:{
        lineItem: [ { position: 12,
                      importance: #HIGH,
                      label: 'Gen.Item cat.grp' } ],
        selectionField: [{ position: 5 }]
    }
    @EndUserText.label: 'Gen.Item cat.grp'
    GenItemCatGroup       : abap.char( 4 );
}
