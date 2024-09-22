@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Whs Sales Details'
define root view entity ZR_SSD054
  as select from I_ProductPlantBasic as _ProductPlantBasic
  
  inner join I_Product as _Product on _ProductPlantBasic.Product = _Product.Product
  association [0..1] to I_Plant as _Plant on _ProductPlantBasic.Plant = _Plant.Plant
  association [0..1] to I_ProductGroupText_2 as _ProductGroupText_2 on _ProductGroupText_2.ProductGroup = _Product.ProductGroup
                                                                   and _ProductGroupText_2.Language = 'E'
{
    key _ProductPlantBasic.Product as ItemCode,
    key _ProductPlantBasic.Plant   as WHCode,
    _Plant.PlantName as WHName,
    _Product.ProductType as MaterialType,
    _Product.ProductGroup as MaterialGroup,
    _ProductGroupText_2.ProductGroupName as MaterialGroupName,
    _ProductGroupText_2.ProductGroupText as MaterialGroupText,
    _Product.ItemCategoryGroup as GenItemCatGroup
}
