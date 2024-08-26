CLASS zcl_insert_data_log_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_DATA_LOG_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel   TYPE TABLE OF ztravel_log_02,
          lt_booking  TYPE TABLE OF zbooking_log_02,
          lt_book_sup TYPE TABLE OF zbooksupp_log_02.


    SELECT travel_id,
           agency_id,
           customer_id,
           begin_date,
           end_date,
           booking_fee,
           total_price,
           currency_code,
           description,
           status AS overall_status,
           createdby AS created_by,
           createdat AS created_at,
           lastchangedby AS last_changed_by,
           lastchangedat AS last_changed_at
    FROM /dmo/travel INTO CORRESPONDING FIELDS OF
    TABLE @lt_travel
    UP TO 50 ROWS.

    SELECT * FROM /dmo/booking
        FOR ALL ENTRIES IN @lt_travel
        WHERE travel_id EQ @lt_travel-travel_id
        INTO CORRESPONDING FIELDS OF TABLE
        @lt_booking.

*    SELECT * FROM /dmo/book_suppl
*        FOR ALL ENTRIES IN @lt_booking
*        WHERE travel_id EQ @lt_booking-travel_id
*         AND booking_id EQ @lt_booking-booking_id
*        INTO CORRESPONDING FIELDS OF TABLE
*        @lt_book_sup.

    SELECT travel_id,
           booking_id,
           booking_supplement_id,
           supplement_id,
           price,
           currency_code AS currency
     FROM /dmo/book_suppl
        FOR ALL ENTRIES IN @lt_booking
        WHERE travel_id EQ @lt_booking-travel_id
         AND booking_id EQ @lt_booking-booking_id
        INTO CORRESPONDING FIELDS OF TABLE
        @lt_book_sup.


    DELETE FROM: ztravel_log_02,
                 zbooking_log_02,
                 zbooksupp_log_02.

    INSERT: ztravel_log_02   FROM TABLE @lt_travel,
            zbooking_log_02  FROM TABLE @lt_booking,
            zbooksupp_log_02 FROM TABLE @lt_book_sup.

    out->write( 'DONE!' ).


  ENDMETHOD.
ENDCLASS.
