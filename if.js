$(function(){

	// Change ref links to numbers
	$( 'a[href^="#"]' )
		.addClass( 'ref' )
		.html( function () {
			return '<sup>' + ( $( $( this ).attr( 'href' ) ).index() + 1 ) + '</sup>';
		} )
		.click( function() {
			$( $( this ).attr( 'href' ) ).addClass( 'target' );
		} );

	// Change the ref IDs to back links
	$( '.references li a:not([href])' )
		.text( '^' )
		.attr( 'title', 'Go back' )
		.click( function() {
			$( '.references .target' ).removeClass( 'target' );
			history.back();
		} );

});