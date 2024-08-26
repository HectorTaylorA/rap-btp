@AbapCatalog.sqlViewName: 'Z_V_HCM_02'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interfaces - Master'
define root view Z_I_HCM_MASTER_02
  as select from zhcm_master_02 as HCMMaster
{
  key e_number       as ENumber,
      e_name         as EName,
      e_department   as EDepartment,
      status         as Status,
      job_tittle     as JobTittle,
      start_date     as StartDate,
      end_date       as EndDate,
      email          as Email,
      m_number       as MNumber,
      m_name         as MName,
      m_department   as MDepartment,
      crea_date_time as CreaDateTime,
      crea_user_name as CreaUserName,
      lchg_date_time as LchgDateTime,
      lchg_user_name as LchgUserName
}
