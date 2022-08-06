//*********************************************************************************************
//*********************************************************************************************
//***                                                                                       ***
//***     CODI FONT DE LA CLASSE TArounder                                                  ***
//***                                                                                       ***
//*********************************************************************************************
//*********************************************************************************************

#include "TArounder.h"



//=================================================================================================================
//====== ACTION_PARAR ===============================================================================================
//=================================================================================================================
void TArounder::PARAR;
{
  if (ORIENT <> CENTRE)
  {
      if (ORIENT = DRETA)
      {
          girar_dreta_centre();
          return AR_OK;
      }
      else
      {
          girar_esquerra_centre();
          return AR_OK;
      }
  return AR_ERR_PARAR;	          // "Final imposible en PARAR-ORIENT"
  }
  
  if (PASOS = INICIALITZANT)
  {
      init_parar();	  // dins, al acavar l'animació, fer: PASOS = EXECUTANT
      return AR_OK;
  }
  if (PASOS = EXECUTANT)
  {
      exec_parar();	  // no hi ha possibilitat interna de eixir
      return AR_OK;
  }
  if (PASOS = FINALITZANT)
  {
      finish_parar();	// CONTROL = QUERY , PASOS = INICIALITZANT
      return AR_OK;
  }

  return AR_ERR_PARAR;	          // "Final imposible en PARAR-PARAR"
}



//=================================================================================================================
//====== ACTION_TALADRAR ============================================================================================
//=================================================================================================================

void TArounder::TALADRAR;
{
  if (ORIENT <> CENTRE)
  {
      if (ORIENT = DRETA)
      {
          girar_dreta_centre();
          return AR_OK;
      }
      else
      {
          girar_esquerra_centre();
          return AR_OK;
      }
      return AR_ERR_TALADRAR;		// "Final imposible en TALADRAR-ORIENT"
  }

  if (PASOS = INICIALITZANT)
  {
      init_taladrar();	// dins, al acavar l'animació, fer: PASOS = EXECUTANT
      return AR_OK;
  }

  if (PASOS = EXECUTANT)
  {
      exec_taladrar();	// possibilitat de que PASOS = FINALITZANT , QUERY = TIPO_ACTION
      return AR_OK;
  }

  if (PASOS = FINALITZANT)
  {
      finish_taladrar();	// CONTROL = QUERY , PASOS = INICIALITZANT
      return AR_OK;
  }

  return AR_ERR_TALADRAR;	// "Final imposible en TALADRAR-TALADRAR"
}