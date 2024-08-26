@AbapCatalog.sqlViewName: 'ZV_DET_CUS02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Detalle Cliente'
@Metadata.allowExtensions: true
define view Z_B_DETAILS_COSTUMER_02
  as select from zrent_customer02
{
  key doc_id    as ID,
  key matricula as Matricula,
      nombres   as Nombre,
      apellidos as Apellido,
      email     as Correo,
      cntr_type as Tipo_Contrato
}
