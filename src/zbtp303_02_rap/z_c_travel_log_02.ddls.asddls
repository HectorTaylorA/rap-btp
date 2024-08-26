@EndUserText.label: 'Comsumption - Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity Z_C_TRAVEL_LOG_02
  as projection on Z_I_TRAVEL_LOG_02
{
  key     TravelId           as TravelID,
          @ObjectModel.text.element: [ 'AgencyName' ]
          AgencyId           as AgencyID,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'CustomerName' ]
          CustomerId         as CustomerID,
          _Customer.LastName as CustomerName,
          BeginDate          as BeginDate,
          EndDate            as EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee         as BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice         as TotalPrice,
          @Semantics.currencyCode: true
          CurrencyCode       as CurrencyCode,
          Description        as Description,
          OverallStatus      as OverallStatus,
          // @Semantics.systemDateTime.lastChangedAt: true
          LastChangedAt      as LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_LOG_02'
  virtual DiscountPrice : /dmo/total_price,

          /* Associations */
          _Agency,
          _Booking : redirected to composition child Z_C_BOOKING_LOG_02,
          _Currency,
          _Customer


}
