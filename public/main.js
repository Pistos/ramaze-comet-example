function get_more_lines( receiver_id, data_uri ) {
    $.get(
        data_uri,
        function( data ) {
            if( data != '' ) {
                $( receiver_id ).append( data + "\n" );
                var receiver = $( receiver_id ).get( 0 );
                receiver.scrollTop = receiver.scrollHeight;
            }
            setTimeout( get_more_lines( receiver_id, data_uri ), 0 );
        }
    );
}

$( document ).ready( function() {
    if( $( '#tailer' ).length ) {
        get_more_lines( '#tailer', '/next_tailer_lines' );
    }
    if( $( '#chitchat' ).length ) {
        get_more_lines( '#chitchat', '/next_chat_lines' );
    }
} );