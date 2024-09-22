@EndUserText.label: 'Product Inventory and Availability Report'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_021'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define custom entity ZR_SSD049
{
  @UI:{
        lineItem: [ { position: 1,
                      importance: #HIGH,
                      label: 'Item No' } ],
        selectionField: [{ position: 1 }]
  }
  @EndUserText.label: 'Item No'
  key ItemNo : matnr;
  @UI:{
        lineItem: [ { position: 3,
                      importance: #HIGH,
                      label: 'Plant' } ]
  }
  @EndUserText.label: 'Plant'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'PlantName' }}]
  key PlantName : abap.char( 30 );
  @UI:{
        selectionField: [{ position: 2 }]
  }
  @EndUserText.label: 'Plant'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' }}]
  Plant : werks_d;
  @UI:{
        lineItem: [ { position: 2,
                      importance: #HIGH,
                      label: 'Item Description' } ]
    }
  @EndUserText.label: 'Item Description'
  ItemDescription : abap.sstring( 255 );
  @UI:{
        lineItem: [ { position: 4,
                      importance: #HIGH,
                      label: 'Committed' } ]
    }
  @EndUserText.label: 'Committed'
  Committed_ : abap.dec( 13, 0 );
  @UI:{
        lineItem: [ { position: 5,
                      importance: #HIGH,
                      label: 'Regular Bin Inventory' } ]
    }
  @EndUserText.label: 'Regular Bin Inventory'
  RegularBinInventory : abap.dec( 15, 0 );
  @UI:{
        lineItem: [ { position: 6,
                      importance: #HIGH,
                      label: 'Available Quantity' } ]
    }
  @EndUserText.label: 'Available Quantity'
  AvailableQuantity : abap.dec( 15, 0 );
  @UI:{
        lineItem: [ { position: 7,
                      importance: #HIGH,
                      label: 'Material Group' } ]
    }
  @EndUserText.label: 'Material Group'
  MaterialGroup : abap.char( 9 );
  @UI:{
        lineItem: [ { position: 8,
                      importance: #HIGH,
                      label: 'Material Group Description' } ]
    }
  @EndUserText.label: 'Material Group Description'
  MaterialGroupDescription : abap.sstring( 255 );
}
