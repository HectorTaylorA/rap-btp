@AbapCatalog.sqlViewName: 'ZV_RENT02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Renting'
@Metadata.allowExtensions: true

define view Z_I_RENTING_02
  as select from Z_B_CARS_02 as CARS
  association [1]    to Z_B_REM_DAYS303_02      as _REMDAYS on CARS.Matricula = _REMDAYS.Matricula
  association [0..*] to Z_B_BRANDSS02           as _BRANDS  on CARS.Marca = _BRANDS.Marca
  association [0..*] to Z_B_DETAILS_COSTUMER_02 as _DETCUST on CARS.Matricula = _DETCUST.Matricula
{
  key Matricula,
      Marca,
      Modelo,
      Color,
      Motor,
      Potencia,
      UndPotencia,
      Combustible,
      Consumo,
      FechaFabricacion,
      Puertas,
      Precio,
      Moneda,
      Alquilado,
      Desde,
      Hasta,
      case
      when _REMDAYS.Dias <= 0 then 0               //Gris
      when _REMDAYS.Dias between 1 and 30  then 1  //Rojo
      when _REMDAYS.Dias between 31 and 100 then 2 //Amarillo
      when _REMDAYS.Dias > 100 then 3              //Verde
      else 0
      end as TiempoRenta,
      ''  as Estado,
      _BRANDS.Imagen,
      _DETCUST


}
