@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Status Report'
define root view entity ZR_SSD048
    as select from I_SalesDocument as _SalesDocument
    
    inner join I_SalesDocumentItem as _SalesDocumentItem
    on _SalesDocument.SalesDocument = _SalesDocumentItem.SalesDocument
    
    association [0..1] to I_Customer as _Customer
    on _Customer.Customer = _SalesDocument.SoldToParty
    
    association [0..1] to I_Plant as _Plant
    on _Plant.Plant = _SalesDocumentItem.Plant
    
    association [0..1] to I_BusinessPartner as _BusinessPartner
    on _BusinessPartner.BusinessPartner = _SalesDocument.SoldToParty
    and (_BusinessPartner.YY1_ChainAccount_bus = '102'
    or _BusinessPartner.YY1_ChainAccount_bus = '103'
    or _BusinessPartner.YY1_ChainAccount_bus = '104')
{
    key _SalesDocumentItem.SalesDocument as SalesOrderNumber,
    key _SalesDocumentItem.SalesDocumentItem as SalesDocumentItem,
    _SalesDocument.SoldToParty as CustomerCode,
    _Customer.BPCustomerName as CustomerName,
    _SalesDocument.CreationDate as OrderEntryDate,
    _SalesDocument.YY1_BusinessName_SDH as ShipToStoreNumber,
    _SalesDocument.YY1_ContactName_SDH as BuyerDestinationContactName,
    _SalesDocumentItem.Product as ItemCode,
    _Plant.PlantName as ShipFromWarehouse,
    cast(_SalesDocumentItem.OrderQuantity as abap.dec( 15, 3 )) as OrderedQauntity,
    cast(_SalesDocumentItem.NetAmount as abap.dec( 15, 2 )) as ItemTotal,
    _BusinessPartner.YY1_ChainAccount_bus as Properties,
    _SalesDocument.YY1_Project_SDH as Project,
    _SalesDocumentItem.Product,
    _SalesDocument.SalesOrganization as SalesOrganization
}
where ( ( _BusinessPartner.YY1_ChainAccount_bus = '103' 
        and _SalesDocument.CreationDate >= dats_add_days( $session.system_date,-28,'UNCHANGED' )
        and _SalesDocument.CreationDate <= $session.system_date )
        or _BusinessPartner.YY1_ChainAccount_bus = '102'
        or _BusinessPartner.YY1_ChainAccount_bus = '104' ) and
    ( _SalesDocument.SDDocumentCategory = 'C'
   or _SalesDocument.SDDocumentCategory = 'I' )
