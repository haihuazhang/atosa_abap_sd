@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Order Confirmation Output Address'
define root view entity ZR_PSD023
    as select from I_SalesDocument as _SalesDocument
    inner join I_SalesDocumentPartner as _SalesOrderPartner1
    on _SalesOrderPartner1.SalesDocument = _SalesDocument.SalesDocument
        and _SalesOrderPartner1.PartnerFunction = 'RE'
    inner join I_SalesDocumentPartner as _SalesOrderPartner2
    on _SalesOrderPartner2.SalesDocument = _SalesDocument.SalesDocument
        and _SalesOrderPartner2.PartnerFunction = 'WE'
    inner join I_SalesDocumentPartner as _SalesOrderPartner3
    on _SalesOrderPartner3.SalesDocument = _SalesDocument.SalesDocument
        and _SalesOrderPartner3.PartnerFunction = 'Z0'
    association [0..1] to I_Address_2 as _Address1 on _Address1.AddressID = _SalesOrderPartner1.AddressID
    association [0..1] to I_Address_2 as _Address2 on _Address2.AddressID = _SalesOrderPartner2.AddressID
    association [0..1] to I_Address_2 as _Address3 on _Address3.AddressID = _SalesOrderPartner3.AddressID
{
    key _SalesDocument.SalesDocument,
    concat(_Address1.OrganizationName1,_Address1.OrganizationName2) as BillToLine1,
    _Address1.StreetName as BillToLine2,
    concat_with_space(_Address1.CityName,concat_with_space(_Address1.Region,_Address1.PostalCode,1),1)
    as BillToLine3,
    concat(_Address2.OrganizationName1,_Address2.OrganizationName2) as ShipToLine1,
    _Address2.StreetName as ShipToLine2,
    concat_with_space(_Address2.CityName,concat_with_space(_Address2.Region,_Address2.PostalCode,1),1)
    as ShipToLine3,
    concat(_Address3.OrganizationName1,_Address3.OrganizationName2) as SalesRep
}
