#!/usr/bin/awk -f

# ##############################################################################
#
# Parser to generate parameter export scripts from ini type input files.
#
# Author : Krishna Singh Chauhan
# Email  : krishnasingh07@gmail.com
#
# Last Fixed on : 
# Version : 
# Public Release : 
#
# ##############################################################################

{

# TO process stmts of type : "LVAL   =   RVAL"

if( $2 == "=" )
 { 
	 for ( i=1 ; i<=3 ; i++ ) printf ("%s" ,$i);
	 for ( i=4 ; i<=NF ; i++ ) printf (" %s" ,$i);
         printf ("\n");
 } 
 else {   

# TO process $1= $2 type of stmts , example : "LVAL=   RVAL"

          if( substr($1, length($1) , 1) == "=" )
	  {
		printf( "%s" , $1) ; 
		for ( i=2 ; i<=NF ; i++ ) printf ("%s " ,$i);
                printf ("\n");
	  } 
	  else {  

# TO process stmts of type : "LVAL   =RVAL"

                   if( substr($2, 1, 1) == "=" )
		   {
			 printf ("%s" ,$1);
			 printf ("=");
			 printf ("%s", substr($2, 2, length($2)) );
			 for ( i=3 ; i<=NF ; i++ ) printf ("%s " ,$i);
                         printf ("\n");
		   }

# TO process stmts of type : "LVAL=RVAL"

		   else print $0
		 }
	}
}

