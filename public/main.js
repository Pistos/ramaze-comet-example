function get_more_lines() {
    $( '#tailer' ).load( '/next_lines' );
}

$( document ).ready( function() {
    get_more_lines();
} );