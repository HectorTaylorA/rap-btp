CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS: acceptTravel           FOR MODIFY IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result,
      createTravelByTemplate FOR MODIFY IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result,
      rejectTravel           FOR MODIFY IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_instance_features  FOR INSTANCE FEATURES IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS: validateCustomer FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateCustomer,
      validateDate FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateDate,
      validateStatus FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

* Nos permite habiltiar las acciones de los botones

    READ ENTITIES OF z_i_travel_log_02 "IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelId OverallStatus )
        WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
        RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
             %key                 = ls_travel-%key
             %field-TravelId      = if_abap_behv=>fc-f-read_only
             %field-OverallStatus = if_abap_behv=>fc-f-read_only
             %assoc-_Booking      = if_abap_behv=>fc-o-enabled
             %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                            THEN if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled )
             %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                            THEN if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    "CB9980007345
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980007345'
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized  ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_results>).
      <fs_results> = VALUE #( %key = <fs_key>-%key
                              %op-%update = lv_auth "if_abap_behv=>auth-allowed
                              %delete = lv_auth "''
                              %action-acceptTravel = lv_auth "if_abap_behv=>auth-allowed
                              %action-rejectTravel = lv_auth "if_abap_behv=>auth-allowed
                              %action-createTravelByTemplate = lv_auth "if_abap_behv=>auth-allowed
                              %assoc-_Booking = lv_auth ). "if_abap_behv=>auth-allowed ).

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    "Modificar en local mode BO relacion de actualizacion no es relevantes la autorización de objetos
    MODIFY ENTITIES OF z_i_travel_log_02 IN LOCAL MODE
            ENTITY Travel
            UPDATE FIELDS ( OverallStatus )
            WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                                OverallStatus = 'A' ) )
            FAILED failed
            REPORTED reported.

    "Leer la entidad y pasarlos a una tabla interna
    READ ENTITIES OF z_i_travel_log_02 IN LOCAL MODE
            ENTITY Travel
            FIELDS ( AgencyId
            CustomerId
            BeginDate
            EndDate
            BookingFee
            TotalPrice
            CurrencyCode
            OverallStatus
            Description
            CreatedBy
            CreatedAt
            LastChangedBy
            LastChangedAt )
            WITH VALUE #( FOR key_row1 IN keys ( TravelId = key_row1-TravelId ) )
            RESULT DATA(lt_travel).

    "Esponer los datos extraidos de la entidad y que se guarddaron en la tabla interna con las modificaciones
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param = ls_travel ) ).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_travel) = <fs_travel>-TravelId.
      SHIFT lv_travel LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelId = <fs_travel>-TravelId
                          %msg = new_message( id = 'Z_MC_TRAVEL_LOG_02'
                                          number = '005'
                                              v1 = lv_travel "<fs_travel>-TravelId
                                        severity = if_abap_behv_message=>severity-success )
                             %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD createTravelByTemplate.

*  tabla interna leer index 1
*  keys[ 1 ]-TravelId
*  result[ 1 ]-
*  mapped-booking Lectura de los mapeos
*  failed-supplement De volver errores
*  reported-%other reportar fallos

*  Seleccionar registro
    READ ENTITIES OF z_i_travel_log_02 ENTITY Travel
         FIELDS ( TravelId AgencyId BookingFee TotalPrice CurrencyCode )
         WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
         RESULT DATA(lt_entity_travel)
         FAILED failed
         REPORTED reported.

*    READ ENTITY z_i_travel_log_02
*         FIELDS ( TravelId AgencyId BookingFee TotalPrice CurrencyCode )
*         WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
*         RESULT lt_read_entity_travel
*         FAILED failed
*         REPORTED reported.

    CHECK failed IS INITIAL.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_log_02\\Travel.

*   variable con la fecha del dia
    DATA(lv_hoy) = cl_abap_context_info=>get_system_date( ).

*   Obtener el registro de mayor valor
    SELECT MAX( travel_id ) FROM ztravel_log_02
    INTO @DATA(lv_travelID).

*   crear un nuevo registro sumando un 1 al correlativo del id
    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
                                ( TravelId      = lv_travelid + idx
                                  AgencyId      = create_row-AgencyId
                                  CustomerId    = create_row-CustomerId
                                  BeginDate     = lv_hoy
                                  EndDate       = lv_hoy + 30
                                  BookingFee    = create_row-BookingFee
                                  TotalPrice    = create_row-TotalPrice
                                  CurrencyCode  = create_row-CurrencyCode
                                  Description   = 'Add Comments'
                                  OverallStatus = 'O' )
                                ).

*   Modificar entidad con los registros nuevos
    MODIFY ENTITIES OF z_i_travel_log_02
        IN LOCAL MODE ENTITY Travel
        CREATE FIELDS ( TravelId
                        AgencyId
                        CustomerId
                        BeginDate
                        EndDate
                        BookingFee
                        TotalPrice
                        CurrencyCode
                        Description
                        OverallStatus
                         )
         WITH lt_create_travel
         MAPPED mapped
         FAILED failed
         REPORTED reported.

*        Enviar los valores nuevos con el resultado
    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                          ( %cid_ref = keys[ idx ]-%cid_ref
                            %key     = keys[ idx ]-%key
                            %param   = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    "Modificar en local mode BO relacion de actualizacion no es relevantes la autorización de objetos
    MODIFY ENTITIES OF z_i_travel_log_02 IN LOCAL MODE
            ENTITY Travel
            UPDATE FIELDS ( OverallStatus )
            WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                                OverallStatus = 'X' ) )
            FAILED failed
            REPORTED reported.

    "Leer la entidad y pasarlos a una tabla interna
    READ ENTITIES OF z_i_travel_log_02 IN LOCAL MODE
            ENTITY Travel
            FIELDS ( AgencyId
            CustomerId
            BeginDate
            EndDate
            BookingFee
            TotalPrice
            CurrencyCode
            OverallStatus
            Description
            CreatedBy
            CreatedAt
            LastChangedBy
            LastChangedAt )
            WITH VALUE #( FOR key_row1 IN keys ( TravelId = key_row1-TravelId ) )
            RESULT DATA(lt_travel).

    "Esponer los datos extraidos de la entidad y que se guarddaron en la tabla interna con las modificaciones
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param = ls_travel ) ).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_travel) = <fs_travel>-TravelId.
      SHIFT lv_travel LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelId = <fs_travel>-TravelId
                          %msg = new_message( id = 'Z_MC_TRAVEL_LOG_02'
                                          number = '006'
                                              v1 = lv_travel "<fs_travel>-TravelId
                                        severity = if_abap_behv_message=>severity-error )
                             %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF z_i_travel_log_02 IN LOCAL MODE
        ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
       FOR ALL ENTRIES IN @lt_customer
       WHERE customer_id EQ @lt_customer-customer_id
       INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      IF <fs_travel>-CustomerId IS INITIAL
        OR NOT line_exists( lt_customer_db[ customer_id = <fs_travel>-CustomerId  ] ).

        APPEND VALUE #( travelId = <fs_travel>-TravelId ) TO failed-travel.

        APPEND VALUE #( travelId = <fs_travel>-TravelId
                            %msg = new_message( id = 'Z_MC_TRAVEL_LOG_02'
                                                number = '001'
                                                v1 = <fs_travel>-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                            %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDate.
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_log_02\\Travel
    "z_i_travel_log_02 IN LOCAL MODE
    "    ENTITY Travel
         FIELDS ( OverallStatus )
         WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
          RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-OverallStatus.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO
          failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
          %msg = new_message( id = 'Z_MC_TRAVEL_LOG_02'
                          number = '004'
                              v1 = ls_travel_result-OverallStatus
                        severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LOG_02 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: c_create TYPE c LENGTH 6 VALUE 'Create',
               c_update TYPE c LENGTH 6 VALUE 'Update',
               c_delete TYPE c LENGTH 6 VALUE 'Delete'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_LOG_02 IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF zlog_log_02,
          lt_travel_log_u TYPE STANDARD TABLE OF zlog_log_02.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    "Se crea un registro nuevo
    IF create-travel IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log>).

        GET TIME STAMP FIELD <fs_travel_log>-created_at.
        <fs_travel_log>-changing_operation = lsc_z_i_travel_log_02=>c_create. "'Create'.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS TravelId =  <fs_travel_log>-travel_id
             INTO DATA(ls_travel).
        IF sy-subrc EQ 0.
          IF ls_travel-%control-BookingFee = cl_abap_behv=>flag_changed.
            <fs_travel_log>-changed_field_name = 'BookingFee'.
            <fs_travel_log>-changed_value      = ls_travel-BookingFee.
            <fs_travel_log>-user_mod           = lv_user.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <fs_travel_log> TO lt_travel_log_u.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDIF.
    "Se actualiza un registro
    IF update-travel IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travel_id = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<ls_travel_log_bd>).
        GET TIME STAMP FIELD <ls_travel_log_bd>-created_at.
        <ls_travel_log_bd>-changing_operation = lsc_z_i_travel_log_02=>c_update.

        IF  ls_update_travel-%control-CustomerId = cl_abap_behv=>flag_changed.
          <ls_travel_log_bd>-changed_field_name = 'CustomerId'.
          <ls_travel_log_bd>-changed_value      = ls_update_travel-CustomerId.
          <ls_travel_log_bd>-user_mod           = lv_user.
          TRY.
              <ls_travel_log_bd>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
        ENDIF.
      ENDLOOP.
    ENDIF.


    "Se elimina un registro
    IF delete-travel IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).
      LOOP AT lt_travel_log ASSIGNING <fs_travel_log>.

        GET TIME STAMP FIELD <fs_travel_log>-created_at.
        <fs_travel_log>-changing_operation = lsc_z_i_travel_log_02=>c_delete.
        <fs_travel_log>-user_mod           = lv_user.
        TRY.
            <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <fs_travel_log> TO lt_travel_log_u.
      ENDLOOP.
    ENDIF.

    IF lt_travel_log_u IS NOT INITIAL.

      INSERT zlog_log_02 FROM TABLE @lt_travel_log_u.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
