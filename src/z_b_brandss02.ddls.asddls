@AbapCatalog.sqlViewName: 'ZV_BRANDS02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Marcas'
define view Z_B_BRANDSS02
  as select from zrent_brands_02
{
  key marca as Marca,
      @UI.hidden: true
      url   as Imagen
}
