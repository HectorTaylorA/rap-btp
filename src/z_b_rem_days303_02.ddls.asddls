@AbapCatalog.sqlViewName: 'ZV_REM_DAYZ_02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dias Restantes'
define view Z_B_REM_DAYS303_02
  as select from zrent_cars_02
{
  key matricula as Matricula,
      marca     as Marca,
      case
      when alq_hasta <> ''
      then dats_days_between( cast( $session.system_date as abap.dats ), alq_hasta)
      end       as Dias



}
