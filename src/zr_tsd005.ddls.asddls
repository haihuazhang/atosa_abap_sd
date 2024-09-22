@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD005'
define root view entity ZR_TSD005
  as select from ztsd005
{
  key uuid as UUID,
  sales_document_type as SalesDocumentType,
  sales_document_item_category as SalesDocumentItemCategory,
  material as Material,
  @Semantics.quantity.unitOfMeasure: 'OrderUnit'
  order_quantity as OrderQuantity,
  order_unit as OrderUnit,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
