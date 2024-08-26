@EndUserText.label: 'Comsuption - Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKING_LOG_02
  as projection on Z_I_BOOKING_LOG_02
{
  key TravelId      as TravelID,
  key BookingId     as BooklingID,
      BookingDate   as BookingDate,
      CustomerId    as CustomerID,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId     as CarrierID,
      _Carrier.Name as CarrierName,
      ConnectionId  as ConnectionID,
      FlightDate    as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice   as FlightPrices,
      @Semantics.currencyCode: true
      CurrencyCode  as CurrencyCode,
      BookingStatus as BookingStatus,
      LastChangeAt  as LastChangeAt,
      /* Associations */
      _Travel      : redirected to parent Z_C_TRAVEL_LOG_02,
      _BookingSupp : redirected to composition child Z_C_BOOKSUPPL_LOQ_02,
      _Carrier,
      _Connection,
      _Customer

}
