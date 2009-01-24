function get_more_lines() {
    $.get(
        '/next_lines',
        function( data ) {
            if( data != '' ) {
                $( '#tailer' ).append( data + "\n" );
                var tailer = $( '#tailer' ).get( 0 );
                tailer.scrollTop = tailer.scrollHeight;
            }
            setTimeout( get_more_lines(), 0 );
        }
    );
}

$( document ).ready( function() {
    get_more_lines();
} );