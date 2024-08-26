FUNCTION z_suppl_log_02.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPL) TYPE  ZTT_SUPPLMENT_LOG_02
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG_LOG_02
*"  EXPORTING
*"     REFERENCE(EV_UPDATE) TYPE  ZDE_FLAG_LOG_02
*"----------------------------------------------------------------------
  CHECK it_suppl IS NOT INITIAL.

  CASE iv_op_type.
    WHEN 'C'.

      INSERT zbooksupp_log_02 FROM TABLE @it_suppl.

    WHEN 'U'.

      UPDATE zbooksupp_log_02 FROM TABLE @it_suppl.

    WHEN 'D'.

      DELETE zbooksupp_log_02 FROM TABLE @it_suppl.

  ENDCASE.

  IF sy-subrc EQ 0.
    ev_update = abap_true.
  ENDIF.


ENDFUNCTION.
