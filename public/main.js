function get_more_lines() {
    $.get(
        '/next_lines',
        function( data ) {
            $( '#tailer' ).append( data )
        }
    );
}

$( document ).ready( function() {
    get_more_lines();
} );