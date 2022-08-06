//*********************************************************************************************
//*********************************************************************************************
//***                                                                                       ***
//***     DECLARACIÓ DE LA CLASSE TArounder                                                 ***
//***                                                                                       ***
//*********************************************************************************************
//*********************************************************************************************

#ifndef TAROUNDER_DEFINIT
#define TAROUNDER_DEFINIT

class
  TArounder
  {
    public:
      
      // VARIABLES PÚBLIQUES ////////////////////////////////////////////////////////////////////////////////////////////


      // Variables públiques de la llista de Arounders

      TArounder *Seguent;
      TArounder *Anterior;
      


      // FUNCIONS PÚBLIQUES /////////////////////////////////////////////////////////////////////////////////////////////


      // Funcions públiques de incialització i destrucció de l'objecte TArounder

      TArounder(unsigned int Xinici, unsigned char Yinici, unsigned char Oinici);      // Constructor
      ~TArounder();                                                                    // Destructor

      
      // Funcions públiques de control del arounder
      
      char EstaActiu();
      

      // Funcions públiques de dibuixat                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      del arounder

      int   getX();
      int   getY();
      RECT  getRect();
      int   getTemps();


      
    private:

      // VARIABLES PRIVADES /////////////////////////////////////////////////////////////////////////////////////////////


      // Variables privades de la AI del Arounder

      unsigned int	X;  		  // Coordinada X virtual del Arounder
      unsigned int	Y;	    	// Coordinada Y virtual del Arounder
      unsigned char	ORIENT;		// Orientació del Arounder
      unsigned char	ACTION;		// Acció base en execució
      unsigned char	QUERY;		// Acció base a executar (per cocos)
      unsigned char	WAITING;	// Acció base en espera  (si li deixen)
      unsigned char	PASOS;		// Acció filla en execució


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

      void PARAR();		          // ACCIÓ BASE PARAR
      void init_parar();		          // Inicialització de la acció PARAR
      void exec_parar();		          // Execució de la acció PARAR
      void finish_parar();		        // Finalització de la acció PARAR

      void GIRAR();		          // ACCIÓ BASE GIRAR
      void init_girar();		          // Inicialització de la acció GIRAR
      void exec_girar();		          // Execució de la acció GIRAR
      void finish_girar();		        // Finalització de la acció GIRAR

      void CAMINAR();	          // ACCIÓ BASE CAMINAR
      void init_parar();		          // Inicialització de la acció CAMINAR
      void exec_parar();		          // Execució de la acció CAMINAR
      void finish_parar();		        // Finalització de la acció CAMINAR

      void ESCALAR();	          // ACCIÓ BASE ESCALAR
      void init_parar();		          // Inicialització de la acció ESCALAR
      void exec_parar();		          // Execució de la acció ESCALAR
      void finish_parar();		        // Finalització de la acció ESCALAR

      void TALADRAR();          // ACCIÓ BASE TALADRAR
      void init_taladrar();		        // Inicialització de la acció TALADRAR
      void exec_taladrar();		        // Execució de la acció TALADRAR
      void finish_taladrar();		      // Finalització de la acció TALADRAR
      
  };

#endif