CLASS lcl_buffer DEFINITION.

  PUBLIC SECTION.

    CONSTANTS: c_create TYPE c VALUE 'C',
               c_delete TYPE c VALUE 'D',
               c_update TYPE c VALUE 'U'.

    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhcm_master_02 AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_number.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.

CLASS lhc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR HCMMaster RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE HCMMaster.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE HCMMaster.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE HCMMaster.

    METHODS read FOR READ
      IMPORTING keys FOR READ HCMMaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK HCMMaster.

ENDCLASS.

CLASS lhc_HCMMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    GET TIME STAMP FIELD DATA(lv_time).
    DATA(lv_name) = cl_abap_context_info=>get_user_technical_name(  ).

    SELECT MAX( e_number ) FROM  zhcm_master_02 INTO @DATA(lv_number_mx).

    LOOP AT entities INTO DATA(ls_entity).

      ls_entity-%data-CreaDateTime = lv_time.
      ls_entity-%data-CreaUserName = sy-uname.
      ls_entity-%data-ENumber     += lv_number_mx.

      INSERT VALUE #( flag = lcl_buffer=>c_create
                      data = CORRESPONDING #( ls_entity-%data ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF ls_entity-%cid IS NOT INITIAL.

        INSERT VALUE #( %cid = ls_entity-%cid
                        enumber = ls_entity-ENumber ) INTO TABLE  mapped-hcmmaster.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    GET TIME STAMP FIELD DATA(lv_time).
    DATA(lv_name) = cl_abap_context_info=>get_user_technical_name(  ).


    LOOP AT entities INTO DATA(ls_entity).

      SELECT SINGLE * FROM  zhcm_master_02
        WHERE e_number EQ @ls_entity-%data-ENumber
        INTO @DATA(ls_bbdd).

      ls_entity-%data-LchgDateTime = lv_time.
      ls_entity-%data-LchgUserName = sy-uname.

      INSERT VALUE #( flag = lcl_buffer=>c_update
                      data = VALUE #( e_number     = ls_bbdd-e_number
                                      e_name       = COND #( WHEN ls_entity-%control-EName EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-EName ELSE ls_bbdd-e_name )
                                      e_department = COND #( WHEN ls_entity-%control-edepartment EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-edepartment ELSE ls_bbdd-e_department )
                                      status       = COND #( WHEN ls_entity-%control-status EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-status ELSE ls_bbdd-status )
                                      job_tittle   = COND #( WHEN ls_entity-%control-jobtittle EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-jobtittle ELSE ls_bbdd-job_tittle )
                                      start_date   = COND #( WHEN ls_entity-%control-startdate EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-enddate ELSE ls_bbdd-end_date )
                                      end_date     = COND #( WHEN ls_entity-%control-enddate EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-EName ELSE ls_bbdd-e_name )
                                      email        = COND #( WHEN ls_entity-%control-email EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-email ELSE ls_bbdd-email )
                                      m_number     = COND #( WHEN ls_entity-%control-mnumber EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-mnumber ELSE ls_bbdd-m_number )
                                      m_name       = COND #( WHEN ls_entity-%control-mname EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-mname ELSE ls_bbdd-m_name )
                                      m_department = COND #( WHEN ls_entity-%control-mdepartment EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-mdepartment ELSE ls_bbdd-m_department )
                                      crea_date_Time = COND #( WHEN ls_entity-%control-creadateTime EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-creadateTime ELSE ls_bbdd-crea_date_Time )
                                      crea_user_name = COND #( WHEN ls_entity-%control-creausername EQ if_abap_behv=>mk-on
                                                       THEN  ls_entity-%data-creausername ELSE ls_bbdd-crea_user_name )
                       ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF ls_entity-ENumber IS NOT INITIAL.

        INSERT VALUE #( %cid    = ls_entity-%data-ENumber
                        enumber = ls_entity-%data-ENumber ) INTO TABLE  mapped-hcmmaster.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys INTO DATA(ls_key).

      INSERT VALUE #( flag = lcl_buffer=>c_delete
                      data = VALUE #( e_number = ls_key-ENumber ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF ls_key-ENumber IS NOT INITIAL.

        INSERT VALUE #( %cid    = ls_key-%key-ENumber
                        enumber = ls_key-%key-ENumber ) INTO TABLE  mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_HCM_MASTER_02 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_HCM_MASTER_02 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA: lt_data_created TYPE STANDARD TABLE OF zhcm_master_02,
          lt_data_updated TYPE STANDARD TABLE OF zhcm_master_02,
          lt_data_deleted TYPE STANDARD TABLE OF zhcm_master_02.

    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                        WHERE ( flag = lcl_buffer=>c_create ) ( <row>-data ) ).

    IF lt_data_created IS NOT INITIAL.
      INSERT zhcm_master_02 FROM TABLE @lt_data_created.
    ENDIF.
    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                    WHERE ( flag = lcl_buffer=>c_update ) ( <row>-data ) ).

    IF lt_data_updated IS NOT INITIAL.
      UPDATE zhcm_master_02 FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                WHERE ( flag = lcl_buffer=>c_delete ) ( <row>-data ) ).

    IF lt_data_deleted IS NOT INITIAL.
      DELETE zhcm_master_02 FROM TABLE @lt_data_deleted.
    ENDIF.

    CLEAR lcl_buffer=>mt_buffer_master.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
