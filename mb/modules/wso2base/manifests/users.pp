class users{

    user { 'kurumba':
        password   => 'nyHwvYMqvhXmoDpon85EGawzg', 
        ensure     => present,                            
        managehome => true,
	home	   => '/home/kurumba',
        shell      => '/bin/bash',
    }
}
