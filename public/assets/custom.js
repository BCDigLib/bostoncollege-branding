$(function() {
    // HACK! We wait for the AJAX call to finish loading the infinite scroll side panel,
    //       then we check to see if the AJAX settings.url string matches one we expect.
    // settings.url = repositories/2/resources/287/tree/node?node=%2Frepositories%2F2%2Farchival_objects%2F12345
    $(document).ajaxComplete(function( event, xhr, settings ) {
        if (settings.url.match(/tree\/node\?node=%2Frepositories%2F2%2Farchival_objects%2F/)) {
            // include a title attribute for each infinite-tree-view button
            $("button.expandme").prop("title", "expand me");
        }
    });
});