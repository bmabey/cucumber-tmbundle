Event.addBehavior({
	
	'dt.failure' : function() {
	  this.ancestors().each(function(e){
	    if (e.hasClassName('passed'))
	    {
	      e.addClassName('failed')
    		e.removeClassName('passed')
    	}	    
	  })
	},
  'li.pending' : function(){
	  this.ancestors().each(function(e){
	    if (e.hasClassName('passed'))
	    {
	      e.addClassName('pending')
    		e.removeClassName('passed')
    	}	    
	  })
	},	
	'dd.exception p[rel=full_message]' : function() {
	  var message = this.previous()
	  message.update(message.innerHTML.gsub(/...$/,"<a href='#' rel='show_full_message'>...</a>"))
	},
	'dd.exception p[rel=message]:click,': function() {
       var full_message = this.next()
       this.toggle()
       full_message.toggle()
       return false
     },
  // 'dd.exception p[rel=message] a[rel=show_full_message]:click' : function() {
  //      var truncated_message = this.up('p[rel=message]')
  //      var full_message = truncated_message.next()
  //      truncated_message.toggle()
  //      full_message.toggle()
  //      return false
  //    },
   'dd.exception p[rel=full_message]:click' : function() {
 	  var message = this.previous()
 	  this.toggle()
 	  message.toggle()
 	  return false
 	}
	
  // 'body' : function() {
  //  passed_container = $div({id:'passed'})
  //  failing_or_pending_container = $div({id:'failing_or_pending'})
  //  passed_container.addClassName('results')
  //  var toggle_link = $a({id:'toggle_passed'}, "Show passing specs.")
  //  toggle_link.setStyle({color: 'green'})
  //  this.appendChild( toggle_link)
  //  this.appendChild( failing_or_pending_container )
  //  this.appendChild( passed_container )
  //  passed_container.hide();
  // },
  // // 'div#rspec-header' : function() {
  // //   if (this.style.width!="100%")
  // //   {
  // //     setTimeout(function() 
  // //     { 
  // //       history.go(0)
  // //     }, 100)
  // //   }
  // // },
  // 
  // 'dl' : function() {
  //  var has_failures_or_pendings = false
  //  var passed = new Array()
  //  this.getElementsBySelector('dd').each(function(dd) 
  //                                        {
  //                                          if (dd.hasClassName('passed')) 
  //                                          { 
  //                                            passed.push(dd)
  //                                          }
  //                                          else 
  //                                          { 
  //                                            has_failures_or_pendings = true
  //                                          }
  //                                        })
  //  if (!has_failures_or_pendings) 
  //  { 
  //    passed_container.appendChild(this.remove())
  //  }
  //  else
  //  {
  //    passed.invoke('hide') // Hide the passing specs in the behavious that have failing ones
  //    failing_or_pending_container.appendChild(this.remove())
  //  }
  // },
  // 'a#toggle_passed:click' : function() {
  //  var dd_in_failed_container = failing_or_pending_container.getElementsBySelector('dd')
  //  if ( passed_container.visible() )
  //  {
  //    this.innerHTML='Show passing specs'
  //    this.setStyle({color: 'green'})
  //    new Effect.BlindUp(passed_container, {duration: 0.5})
  //    dd_in_failed_container.each(function(dd) 
  //                                          {
  //                                            if (dd.hasClassName('passed')) 
  //                                            {
  //                                              new Effect.Fade(dd, {duration: 0.5})
  //                                            }
  //                                          }
  //                                        )
  //  }
  //  else
  //  {
  //    this.innerHTML='Hide passing specs'
  //    this.setStyle({color: 'red'})
  //    new Effect.BlindDown(passed_container, {duration: 0.5})
  //    dd_in_failed_container.each(function(dd) 
  //                                          {
  //                                            if (dd.hasClassName('passed')) 
  //                                            {
  //                                              new Effect.Appear(dd, {duration: 0.5})
  //                                            }
  //                                          }
  //                                        )
  //  } 
  //  
  //  return false;
  // }
})