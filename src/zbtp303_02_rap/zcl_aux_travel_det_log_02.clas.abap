CLASS zcl_aux_travel_det_log_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reporting   TYPE TABLE FOR REPORTED z_i_travel_log_02,
           tt_booking_reporting  TYPE TABLE FOR REPORTED z_i_booking_log_02,
           tt_booksupp_reporting TYPE TABLE FOR REPORTED z_i_booksuppl_log_02.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id  TYPE tt_travel_id
                                  EXPORTING et_travel_rep TYPE tt_travel_reporting.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AUX_TRAVEL_DET_LOG_02 IMPLEMENTATION.


  METHOD calculate_price.

    DATA: lv_bookingprice TYPE /dmo/total_price,
          lv_supplprice   TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_log_02
        ENTITY Travel
        FIELDS ( TravelId CurrencyCode )
       " FROM VALUE #( FOR lv_travel_id IN it_travel_id ( TravelId = lv_travel_id ) )
        WITH VALUE #( FOR lv_travel_id IN it_travel_id ( TravelId = lv_travel_id ) )
        RESULT DATA(lt_read_travel).

    READ ENTITIES OF z_i_travel_log_02
        ENTITY Travel BY \_Booking
        FROM VALUE #( FOR lv_travel_id IN it_travel_id ( TravelId = lv_travel_id
                                                         %control-FlightPrice  = if_abap_behv=>mk-on
                                                         %control-CurrencyCode = if_abap_behv=>mk-on ) )

        RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_Read_booking)
            GROUP BY ls_read_booking-TravelId INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ]
          TO FIELD-SYMBOL(<fs_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_Result)
         GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_curr).

        lv_bookingprice = 0.
        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
          lv_bookingprice += ls_booking_line-FlightPrice.
        ENDLOOP.

        IF lv_curr EQ <fs_travel>-CurrencyCode.
          <fs_travel>-TotalPrice += lv_bookingprice.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_bookingprice
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <fs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(lv_converted) ).

          <fs_travel>-TotalPrice += lv_converted.

        ENDIF.
      ENDLOOP.
    ENDLOOP.

    READ ENTITIES OF z_i_travel_log_02
        ENTITY Booking BY \_BookingSupp
        FROM VALUE #( FOR ls_travel IN lt_read_booking ( TravelId          = ls_travel-TravelId
                                                         BookingId         = ls_Travel-BookingId
                                                         %control-Price    = if_abap_behv=>mk-on
                                                         %control-Currency = if_abap_behv=>mk-on ) )
        RESULT DATA(lt_suppl).

    LOOP AT lt_suppl INTO DATA(ls_suppl)
    GROUP BY ls_suppl-TravelId INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ] TO <fs_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_suppl_Result)
           GROUP BY ls_suppl_Result-Currency INTO lv_curr.

        lv_supplprice = 0.
        LOOP AT GROUP lv_curr INTO DATA(ls_suppl_line).
          lv_supplprice += ls_suppl_line-Price.
        ENDLOOP.

        IF lv_curr EQ <fs_travel>-CurrencyCode.
          <fs_travel>-TotalPrice += lv_supplprice.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_supplprice
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <fs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_converted ).

          <fs_travel>-TotalPrice += lv_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.


    MODIFY ENTITIES OF z_i_travel_log_02
    ENTITY Travel
    UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                            TravelId = ls_travel_bo-TravelId
                            TotalPrice = ls_travel_bo-TotalPrice
                            %control-TotalPrice = if_abap_behv=>mk-on ) ).

*                            et_travel_rep[ 1 ]-

  ENDMETHOD.
ENDCLASS.
