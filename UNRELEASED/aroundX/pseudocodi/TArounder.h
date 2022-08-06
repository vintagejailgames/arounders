//*********************************************************************************************
//*********************************************************************************************
//***                                                                                       ***
//***     DECLARACI� DE LA CLASSE TArounder                                                 ***
//***                                                                                       ***
//*********************************************************************************************
//*********************************************************************************************

#ifndef TAROUNDER_DEFINIT
#define TAROUNDER_DEFINIT

class
  TArounder
  {
    public:
      
      // VARIABLES P�BLIQUES ////////////////////////////////////////////////////////////////////////////////////////////


      // Variables p�bliques de la llista de Arounders

      TArounder *Seguent;
      TArounder *Anterior;
      


      // FUNCIONS P�BLIQUES /////////////////////////////////////////////////////////////////////////////////////////////


      // Funcions p�bliques de incialitzaci� i destrucci� de l'objecte TArounder

      TArounder(unsigned int Xinici, unsigned char Yinici, unsigned char Oinici);      // Constructor
      ~TArounder();                                                                    // Destructor

      
      // Funcions p�bliques de control del arounder
      
      char EstaActiu();
      

      // Funcions p�bliques de dibuixat                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      del arounder

      int   getX();
      int   getY();
      RECT  getRect();
      int   getTemps();


      
    private:

      // VARIABLES PRIVADES /////////////////////////////////////////////////////////////////////////////////////////////


      // Variables privades de la AI del Arounder

      unsigned int	X;  		  // Coordinada X virtual del Arounder
      unsigned int	Y;	    	// Coordinada Y virtual del Arounder
      unsigned char	ORIENT;		// Orientaci� del Arounder
      unsigned char	ACTION;		// Acci� base en execuci�
      unsigned char	QUERY;		// Acci� base a executar (per cocos)
      unsigned char	WAITING;	// Acci� base en espera  (si li deixen)
      unsigned char	PASOS;		// Acci� filla en execuci�


      // Variables privades de dibuixat del Arounder

      int		Xreal;        		// Coordinada X real del Arounder
      int		Yreal;		        // Coordinada Y real del Arounder
      unsigned int	top;		  // Pixel de dalt del frame actual del Arounder
      unsigned int	bottom;		// Pixel de baix del frame actual del Arounder
      unsigned int	left;		  // Pixel de l'esquerra del frame actual del Arounder
      unsigned int	right;		// Pixel de la dreta del frame actual del Arounder
      unsigned char	temps;		// Temps de espera del frame actual del Arounder


      // Variables privades de control del Arounder
      
      char ACTIU;             // Indica si el arounder funciona o no

      


      // FUNCIONS PRIVADES //////////////////////////////////////////////////////////////////////////////////////////////


      // Funcions privades de la AI del Arounder

      void girar_dreta_centre();  	  // Gira al Arounder de dreta al centre
      void girar_esquerra_centre();	  // Gira al Arounder de esquerra al centre
      void girar_centre_dreta();	    // Gira al Arounder del centre a la dreta
      void girar_centre_esquerra();	  // Gira al Arounder del centre a la esquerra

      void PARAR();		          // ACCI� BASE PARAR
      void init_parar();		          // Inicialitzaci� de la acci� PARAR
      void exec_parar();		          // Execuci� de la acci� PARAR
      void finish_parar();		        // Finalitzaci� de la acci� PARAR

      void GIRAR();		          // ACCI� BASE GIRAR
      void init_girar();		          // Inicialitzaci� de la acci� GIRAR
      void exec_girar();		          // Execuci� de la acci� GIRAR
      void finish_girar();		        // Finalitzaci� de la acci� GIRAR

      void CAMINAR();	          // ACCI� BASE CAMINAR
      void init_parar();		          // Inicialitzaci� de la acci� CAMINAR
      void exec_parar();		          // Execuci� de la acci� CAMINAR
      void finish_parar();		        // Finalitzaci� de la acci� CAMINAR

      void ESCALAR();	          // ACCI� BASE ESCALAR
      void init_parar();		          // Inicialitzaci� de la acci� ESCALAR
      void exec_parar();		          // Execuci� de la acci� ESCALAR
      void finish_parar();		        // Finalitzaci� de la acci� ESCALAR

      void TALADRAR();          // ACCI� BASE TALADRAR
      void init_taladrar();		        // Inicialitzaci� de la acci� TALADRAR
      void exec_taladrar();		        // Execuci� de la acci� TALADRAR
      void finish_taladrar();		      // Finalitzaci� de la acci� TALADRAR
      
  };

#endif