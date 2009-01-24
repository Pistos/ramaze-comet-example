function get_more_lines() {
    $.get(
        '/next_lines',
        function( data ) {
            $( '#tailer' ).append( data + "\n" );
            setTimeout( get_more_lines(), 0 );
        }
    );
}

$( document ).ready( function() {
    get_more_lines();
} );