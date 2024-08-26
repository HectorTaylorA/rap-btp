CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplPrice.

    IF keys IS NOT INITIAL.
      zcl_aux_travel_det_log_02=>calculate_price( it_travel_id =
                                                  VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
                                                         GROUP BY booking_key-TravelId WITHOUT MEMBERS ( <booking_suppl> )  ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_saver_class DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS: c_create TYPE string VALUE 'C',
               c_UPDATE TYPE string VALUE 'U',
               c_DELETE TYPE string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.


ENDCLASS.

CLASS lcl_saver_class IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplement TYPE STANDARD TABLE OF zbooksupp_log_02,
          lv_op_type    TYPE zde_flag_log_02,
          lv_updated    TYPE zde_flag_log_02.


    IF create-supplement IS NOT INITIAL.
      lt_supplement = CORRESPONDING #( create-supplement ).
      lv_op_type = lcl_saver_class=>c_create.
    ENDIF.

    IF update-supplement IS NOT INITIAL.
      lt_supplement = CORRESPONDING #( update-supplement ).
      lv_op_type = lcl_saver_class=>c_update.
    ENDIF.

    IF delete-supplement IS NOT INITIAL.
      lt_supplement = CORRESPONDING #( delete-supplement ).
      lv_op_type = lcl_saver_class=>c_delete.
    ENDIF.

    IF lt_supplement IS NOT INITIAL.

      CALL FUNCTION 'Z_SUPPL_LOG_02'
        EXPORTING
          it_suppl   = lt_supplement
          iv_op_type = lv_op_type
        IMPORTING
          ev_update  = lv_updated.

      IF lv_updated EQ abap_true.

*REPORTED-supplement.
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
