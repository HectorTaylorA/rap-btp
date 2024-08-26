@AbapCatalog.sqlViewName: 'ZV_BOOK_LOG02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interfaces - Booking Supplement'
define view Z_I_BOOKSUPPL_LOG_02
  as select from zbooksupp_log_02 as BookingSupp
  association        to parent Z_I_BOOKING_LOG_02 as _Booking  on  $projection.TravelId  = _Booking.TravelId
                                                               and $projection.BookingId = _Booking.BookingId
  association [1..1] to Z_I_TRAVEL_LOG_02         as _Travel   on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement         as _Product  on  $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText     as _SuppText on  $projection.SupplementId = _SuppText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'currency'
      price                 as Price,
      @Semantics.currencyCode: true
      currency              as Currency,
      last_changed_at       as Lastchangedat,
      _Booking,
      _Travel,
      _Product,
      _SuppText
}
