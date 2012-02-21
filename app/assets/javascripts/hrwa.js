jQuery(function($) {
  // Dropdown example for topbar nav
  // ===============================

/* //using bootstrap-dropdown.js now
  $("body").bind("click", function (e) {
    $('a.menu').parent("li").removeClass("open");
  });

  $("a.menu").click(function (e) {
    var $li = $(this).parent("li").toggleClass('open');
    return false;
  });
*/
  $('.topbar').dropdown()

  $('.donothing').click(function (e) {
		alert('this does nothing... yet.');
		return false;
  });
  $('.nofollow').click(function (e) {
        alert('disallowing external (non-cu) clicks for now while testing.');
        return false;
  });
  $('div.alert-message a.close').live('click', function (e) {
	$(this).parent('.alert-message').hide();
	return false;
  });
  $('.alert-link').click(function (e) {
	window.location = $(this).find('a').attr('href');
	//return false;
  });
  $('.toggler').hide(0);
  $(".toggle_section").bind('click', function (e) {
	$(this).next('.toggler').slideToggle();
    	$(this).text(($(this).text() == 'Show Less-') ? 'Show More+' : 'Show Less-');
	$(this).blur();
	return false;
  });
  $('#advanced_options').hide(0).append(
                '<div id="gen-query" class="clearfix"></div>'+
                '<h6>Find Pages/Sites that have&hellip;</h6>'+
                '<div class="input-prepend">'+
                '        <label class="add-on">all these words:</label>'+
                '        <input class="span9" placeholder="Enter search terms..." id="as_q" name="as_q" size="16" type="text"> <a title="You can do this in simple search by adding a + (plus sign) to the beginning of the word you require." rel="twipsy" href="#">tip</a>'+
                '</div>'+
                '<div class="input-prepend">'+
                '        <label class="add-on">this exact wording or phrase:</label>'+
                '        <input class="span9" placeholder="Enter search terms..." id="as_epq" name="as_epq" size="16" type="text"> <a title="You can do this in simple search by &quot;surrounding your phrase with quotes&quot;." rel="twipsy" href="#">tip</a>'+
                '</div>'+
                '<div class="input-prepend">'+
                '        <label class="add-on">one or more of these words:</label>'+
                '        <input class="span9" placeholder="Enter search terms..." id="as_oq0" name="as_oq0" size="16" type="text">'+
                '</div>'+
                '<h6>But don\'t show results that have&hellip;</h6>'+
                '<div class="input-prepend">'+
                '        <label class="add-on">any of these unwanted words:</label>'+
                '        <input class="span9" placeholder="Enter search terms..." id="as_eq" name="as_eq" size="16" type="text"> <a title="You can do this in simple search by adding a - (minus sign) to the beginning of the word you don\'t want." rel="twipsy" href="#">tip</a>'+
                '</div>'+
                '<p>'+
                '<input id="advsubmit" type="submit" value="submit" class="btn small success nopad" /> '+
                '<input id="advreset" type="reset" value="reset all" class="btn small nopad" />'+
                '</p>');
  $('#advo').css('visibility','visible');
  $('.advtoggle').bind('click', function (e) {
	$('#advanced_options').toggle();
    	$(this).text(($(this).text() == '-') ? '+' : '-');
	$(this).blur();
	return false;
  });

  $('#advsubmit').live('click', function(e) {
    if ($('#as_q').val() != '' || $('#as_epq').val() != '' || $('#as_oq0').val() != '' || $('#as_eq').val() != '') {
        if ($('#as_q').val() != '') { var as_q = '+'+$('#as_q').val(); } else { var as_q = ''; }
        if ($('#as_epq').val() != '') { var as_epq = ' "'+$('#as_epq').val()+'" '; } else { var as_epq = ' '; }
        if ($('#as_oq0').val() != '') { var as_oq0 = $('#as_oq0').val()+' '; } else { var as_oq0 = ' '; }
        if ($('#as_eq').val() != '') { var as_eq = '-'+$('#as_eq').val(); } else { var as_eq = ''; }
        var newaq = as_q.replace(/ /g,' +')+as_epq+as_oq0+as_eq.replace(/ /g,' -');
        //$('#q').val(newaq.replace(/"/g, "&quot;").replace(/'/g, "&#039;"));
        $('#q, #q_t').val(newaq);
        $('#searchform').submit();
        return false;
    } else {
	alert('Please enter your search before submitting.');
	$(this).blur();
    }
  });
  $('#advreset').live('click', function(e) {
	$('#advanced_options input[type=text]').val('');
  });

  $('.submitss').parent().css('visibility','visible');
  $('.submitss').live('click', function (e) {
	var cform = $(this).closest('form');
	if ($('#q_t').val() != '' || $('#q').val()) {
		cform.submit();
	} else {
		alert('Please enter your search before submitting.');
		$(this).blur();
	}
	return false;
  });

$('.moreless').live('click', function() {
    $(this).text(($(this).text() == 'Show Less-') ? 'Show More+' : 'Show Less-');
});

// faceting attempt
// multiple facets broken for ff3.6...must fix
$(".addfq").live('click',function(e) {
	var facet_id = $(this).attr('id').replace(/^facet_[0-9]+\-\-/g,''); // this will need to be double-checked
	var facet_cat = $(this).attr('title');
        $('#searchform').append("<input type='hidden' name='fq[]' value='"+facet_cat+":"+facet_id+"' />"); //new attempt
    	$('#searchform').submit();
	return false;
});
$(".delfq").live('click',function(e) {
        $(this).hide(0, function() { $(this).attr('name',''); $(this).find('input').attr('name',''); $(this).closest('form').submit(); }); //hacky but necessary
    	////$('#searchform').submit();
	return false;
});

// resubmit
$('.submit_topsearch').live('click',function(e) {
	$('#topsearchform').submit();
	return false;
});

$('a.quicklook').live('click', function() {
    var permalink = this.href;
    var url = this.href+' #sdf_table';
    var dlog = $("#sdf_dialog");
    if ($("#sdf_dialog").length == 0) {
        dlog = $('<div id="sdf_dialog" style="font-size:80%;display:hidden"><p>Loading Quicklook...</p></div>').appendTo('body');
    }

    // load remote content
    dlog.load( url);
    $('#sdf_dialog').dialog({zIndex:10001,title:'HRWA SDF Quicklook [<a class="blue" href="'+permalink+'">permalink</a>]',position:['center',60],width:920,modal:true, close: function(event, ui)
            { $(this).html('Loading Quicklook...'); }
        });
    return false;
});

$('a.ccf_quicklook').live('click', function() {
    var permalink = this.href;
    var url = this.href+' #crawl_calendar';
    var dlog = $("#ccf_dialog");
    if ($("#ccf_dialog").length == 0) {
        dlog = $('<div id="ccf_dialog" style="font-size:100%;display:hidden"><p>Loading Quicklook...</p></div>').appendTo('body');
    }

    // load remote content
    dlog.load( url);
    $('#ccf_dialog').dialog({zIndex:10001,title:'HRWA CCF Quicklook [<a class="blue" href="'+permalink+'">permalink</a>]',position:['center',60],width:940,modal:true, close: function(event, ui)
            { $(this).html('Loading Quicklook...'); }
        });
    return false;
});

// avf stuff

  var hrwaxcoh = $('iframe#x_container').height();
  var hrwaxcow = $('iframe#x_container').width();
  $('iframe#x_container').load(function() {
	$(this).height(hrwaxcoh).width(hrwaxcow);
	if ($(this).height() < $(this).contents().height()) {
        	$(this).height($(this).contents().height()+10);
	}
	if ($(this).width() < $(this).contents().width()) {
		$(this).width($(this).contents().width()+20);
	}
	$('img.loader').hide();
	$(this).contents().find('a').click(function() { 
		alert('HRWA detected this click. We\'ll let you proceed :)'); 
		$('#avf-infoalert').remove();
		return true; 
	});
	if ($('#avf-infoalert').css('visibility','visible')) {
		$('#avf-infoalert').remove();
		$('#contentttt').append('<div id="avf-infoalert" class="alert-message"><a href="#" class="close">x</a>You are viewing an archived web page that is part of the Columbia University Libraries <strong>Human Rights Web Archive</strong>. This will be a useful info section. <em>See All versions of this archived page</em>. More useful info here.</div>');
	}
  });

// sorting
// toggle all menu stuff
  $('.results_control').show();
  $('.toggle_all_btn').live('click', function() { 
        $('article.post .toggle_section').trigger('click');
        $(this).text(($(this).text() == 'Toggle-') ? 'Toggle+' : 'Toggle-');
        $(this).blur();
        return false;
  });

function sortState(foo) {
$('.results_control').find('a').removeClass('success');
foo.addClass('success');
}
$('#primary .sort_default').live('click', function() { $('article.post').tinysort({attr:"id"}); sortState($(this)); });
$('#primary .sort_a-z').live('click', function() { $('article.post').tinysort({order:"asc"}); sortState($(this)); });
$('#primary .sort_z-a').live('click', function() { $('article.post').tinysort({order:"desc"}); sortState($(this)); });

$('#secondary .results_control, #cbf .results_control').prepend('<a class="sort_default btn small" title="Sort by Count">#</a> <a class="sort_a-z btn small" title="Sort by A-Z">A-Z</a> <a class="sort_z-a btn small" title="Sort by Z-A">Z-A</a>');
$('#cbf .results_control:first .sort_default').hide();
$('.sort_default').live('click', function() { var c = $(this).parent().next('ul'); $('li',c).tinysort('span', {order:"desc"}); sortState($(this)); }); 
$('.sort_a-z').live('click', function() { var a = $(this).parent().next('ul'); $('li',a).tinysort({order:"asc"}); sortState($(this)); });
$('.sort_z-a').live('click', function() { var z = $(this).parent().next('ul'); $('li',z).tinysort({order:"desc"}); sortState($(this)); });
$('#cbf .results_control:first').parent().find('.sort_a-z').trigger('click');

// results_controls and show more for sidebar and cbf
  $('#secondary ul, #cbf_widgets ul').each(function() {
// If there are less than 8 list items, don't do anything
  if($(this).children('li').size() <= 8) return;
  // Hide all list items after the 6th one
  var self = this,
      items = $('li',this),
      listElements = items.filter(':gt(5)').hide();
// Set the toggler link text to "... nn More Choices" where nn is equal to the number of hidden choices
    var linkText = listElements.size() + ' More Choices&hellip;';
  
    // Insert the toggler link as the very last list element
    //$(this).parent().append(
    $(this).prepend(
  
      // Create the toggler list elemenet and make it toggle
      $('<p class="widgetmore"><a class="lime" href="#">' + linkText + '</a></p>')
  
      // Toggle the display list element text when the toggler is clicked.
        .toggle(
          function() { 
            listElements.show();
            $("a", this).text('Fewer Choices').blur();
          }, 
          function() { 
            listElements.hide();
            $("a", this).text(linkText).blur();
          }
        )
    );
  });

  $('a[rel=twipsy], .results_control a').twipsy({'placement': 'above'});
  $('.topbar a[rel=twipsy]').twipsy({'placement': 'right'});
// autocomplete
/*
	function log( message ) {
		$( "<div/>" ).text( message ).prependTo( "#primary" );
		$( "#primary" ).scrollTop( 0 );
	}

	$( "#topsearchform" ).autocomplete({
		source: "inc/autocomplete.php",
		minLength: 2,
		select: function( event, ui ) {
			log( ui.item ?
				"Selected: " + ui.item.value + " aka " + ui.item.id :
				"Nothing selected, input was " + this.value );
		}
	});
*/

}); // ready