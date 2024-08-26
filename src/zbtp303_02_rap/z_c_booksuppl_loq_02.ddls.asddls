@EndUserText.label: 'Comsuption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPL_LOQ_02
  as projection on Z_I_BOOKSUPPL_LOG_02
{
  key TravelId              as TravelID,
  key BookingId             as BookingID,
  key BookingSupplementId   as BookingSupplementID,
      SupplementId          as SupplementID,
      _SuppText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'Currency'
      Price                 as Price,
      @Semantics.currencyCode: true
      Currency              as Currency,
      Lastchangedat         as Lastchangedat,
      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_LOG_02,
      _Booking : redirected to parent Z_C_BOOKING_LOG_02,
      _Product,
      _SuppText

}
